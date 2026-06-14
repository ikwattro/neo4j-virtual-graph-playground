---
description: Add a new database backend to the Neo4j Virtual Graph Playground
---

# add-backend

Add a new database backend to the Neo4j Virtual Graph Playground.

## What to gather first

If the user hasn't specified, ask for:
- Backend name (e.g. `mysql`, `snowflake`) — used as directory name and compose file suffix
- Database image + version
- JDBC driver jar name and how to obtain it (Maven Central URL, or manual download)
- Database name, username, password (default: `nvg`/`nvg`)
- Schema/catalog values (see table below)
- Whether to use the standard movies dataset or a custom schema

## Architecture in one paragraph

Each backend is a Docker Compose **overlay file** (`docker-compose-<name>.yml`) that defines the database service and extends the base `neo4j` service with `depends_on`, the JDBC driver volume, and the nvg-config volume. The base `docker-compose.yml` runs Neo4j with virtual graphs enabled via `NEO4J_internal_virtual__graph_home=/nvg_home`. The active backend is selected in `.env` by setting `COMPOSE_FILE=docker-compose.yml:docker-compose-<name>.yml`. Configuration lives in `config/<name>/`.

## Files to create

```
config/<name>/
├── jdbc/<driver>.jar          # JDBC driver binary (committed or downloaded at setup)
├── nvg-config/
│   ├── datasource.json        # connection URL
│   ├── secret.json            # credentials
│   └── schema.json            # graph model mapping
└── initdb/
    └── init.sql               # DDL + seed data (optional, auto-run on first start)
docker-compose-<name>.yml
```

---

## File templates

### `config/<name>/nvg-config/datasource.json`

JDBC backend:
```json
{
  "type": "generic",
  "url": "jdbc:<dialect>://<service-name>:<port>/<database>"
}
```

DuckDB embedded:
```json
{
  "type": "duckdb",
  "path": "/duckdb-data/<name>.duckdb"
}
```

### `config/<name>/nvg-config/secret.json`
```json
{
  "type": "basic",
  "username": "nvg",
  "password": "nvg"
}
```

### `config/<name>/nvg-config/schema.json` — movies dataset

```json
{
  "catalog": "<database-name>",
  "schema": "public",
  "entities": {
    "nodes": [
      {
        "label": "Movie",
        "table": "movies",
        "properties": [
          {"name": "title",        "column": "TITLE",    "type": "STRING"},
          {"name": "tagline",      "column": "TAGLINE",  "type": "STRING"},
          {"name": "release_year", "column": "RELEASED", "type": "INTEGER"}
        ],
        "key": [{"column": "ID"}]
      },
      {
        "label": "Person",
        "table": "people",
        "properties": [
          {"name": "name", "column": "NAME", "type": "STRING"},
          {"name": "born", "column": "BORN", "type": "INTEGER"}
        ],
        "key": [{"column": "ID"}]
      }
    ],
    "relationships": [
      {
        "label": "ACTED_IN",
        "table": "movie_actors",
        "start": {
          "targetEntity": "Person",
          "keys": [{"nodeColumn": "ID", "relationshipColumn": "PERSON_ID"}]
        },
        "end": {
          "targetEntity": "Movie",
          "keys": [{"nodeColumn": "ID", "relationshipColumn": "MOVIE_ID"}]
        },
        "properties": [
          {"name": "role", "column": "ROLE", "type": "String"}
        ],
        "key": [{"column": "PERSON_ID"}, {"column": "MOVIE_ID"}, {"column": "ROLE"}]
      }
    ]
  }
}
```

### `config/<name>/initdb/init.sql` — movies dataset DDL

Use PostgreSQL syntax as the base; adapt for dialect differences noted below.

```sql
CREATE TABLE IF NOT EXISTS people (
    id       INTEGER PRIMARY KEY,
    name     VARCHAR(32) NOT NULL,
    born     SMALLINT
);

CREATE TABLE IF NOT EXISTS movies (
    id       INTEGER PRIMARY KEY,
    title    VARCHAR(64)  NOT NULL,
    tagline  VARCHAR(256),
    released SMALLINT
);

CREATE TABLE IF NOT EXISTS movie_actors (
    person_id INTEGER NOT NULL REFERENCES people(id),
    movie_id  INTEGER NOT NULL REFERENCES movies(id),
    role      VARCHAR(64) NOT NULL,
    PRIMARY KEY (person_id, movie_id, role)
);

-- seed data: copy INSERT blocks from config/postgres/initdb/init.sql
```

Dialect notes:
- MySQL/SingleStore: no `SMALLINT` shorthand for bool; use `INT`; replace `REFERENCES` with explicit FK constraints if needed
- Oracle: use `NUMBER` instead of `INTEGER`; init dir is `/docker-entrypoint-initdb.d` for some images, varies — check image docs

---

## Docker Compose overlay template

`docker-compose-<name>.yml`:

```yaml
volumes:
  nvg_<name>_data:

services:
  <name>-vg:
    image: <image>:<tag>
    container_name: <name>-vg
    environment:
      - <ENV_VAR>=<value>
    volumes:
      - "nvg_<name>_data:/var/lib/<dbdir>/data"
      - "./config/<name>/initdb:/docker-entrypoint-initdb.d"
    healthcheck:
      test: ["CMD-SHELL", "<healthcheck-command>"]
      interval: 5s
      timeout: 5s
      retries: 10
      start_period: 30s

  neo4j:
    depends_on:
      <name>-vg:
        condition: service_healthy
    volumes:
      - "./config/<name>/jdbc/<driver>.jar:/var/lib/neo4j/lib/<driver>.jar"
      - "./config/<name>/nvg-config:/nvg_home"
```

No explicit `networks:` block needed — Docker Compose default network connects all services in the same project.

---

## Dialect reference

| Backend     | JDBC URL pattern                                                                      | catalog       | schema  | healthcheck                                        |
|-------------|--------------------------------------------------------------------------------------|---------------|---------|---------------------------------------------------|
| PostgreSQL  | `jdbc:postgresql://<svc>:5432/<db>`                                                  | db name       | public  | `pg_isready -U nvg`                               |
| MySQL       | `jdbc:mysql://<svc>:3306/<db>`                                                       | db name       | (omit)  | `mysqladmin ping -h localhost -u nvg --password=nvg` |
| Oracle      | `jdbc:oracle:thin:@<svc>:1521/FREE`                                                  | (omit)        | schema  | `healthcheck.sh`                                  |
| SingleStore | `jdbc:singlestore://<svc>:3306/<db>`                                                 | db name       | public  | `mysqladmin ping -h 127.0.0.1 -u nvg -pnvg`     |
| DuckDB      | use `"type":"duckdb"` + `"path"` in datasource.json                                  | movies        | main    | n/a (embedded)                                    |
| Pinot       | `jdbc:pinot://<ctrl>:9000?brokers=<broker>:8099&useMultistageEngine=true`            | "" (empty)    | default | curl controller healthcheck                       |
| Neo4j       | `jdbc:neo4j://<host>:7687`                                                           | (omit)        | (omit)  | wget/curl bolt endpoint                           |

---

## .env.template — register the backend

Append to `.env.template`:
```bash
# <BackendName> backend
# COMPOSE_FILE=docker-compose.yml:docker-compose-<name>.yml
```

To activate, the user sets this in `.env`.

---

## Constraints and gotchas

- The JDBC driver jar path inside Neo4j is always `/var/lib/neo4j/lib/<driver>.jar` — not `plugins/`
- `nvg-config` directory mounts to `/nvg_home` and replaces the entire config — all three JSON files must be present
- `catalog` in schema.json must match the actual database/catalog name the JDBC driver sees, not necessarily what you named the Docker service
- For DuckDB, `schema` is `main` not `public`
- `key` arrays in relationships must match the actual PK columns of the junction table
- Property `type` values: `STRING`, `INTEGER`, `Long`, `String` (mixed case seen in existing configs — use `STRING`/`INTEGER` for nodes, check existing relationship configs for precedent)
- `depends_on` with `condition: service_healthy` requires a `healthcheck` on the database service — don't skip it
- Named volumes in overlays must be declared at the top-level `volumes:` key of the overlay file
