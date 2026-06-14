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
- **Which tier** the backend belongs to — ask explicitly:
  - **Simple** — single JDBC service, no extra setup, movies dataset
  - **Intermediate** — richer schema or slightly more involved config
  - **Advanced** — multi-service stack, custom dataset, or non-trivial setup
  - **Exotic** — unusual protocol or architecture

## Architecture in one paragraph

Each backend is a Docker Compose **overlay file** (`config/<name>/docker-compose.yml`) that defines the database service and extends the base `neo4j` service with `depends_on`, the JDBC driver volume, and the nvg-config volume. The base `docker-compose.yml` runs Neo4j with virtual graphs enabled via `NEO4J_internal_virtual__graph_home=/nvg_home`. The active backend is selected in `.env` by setting `COMPOSE_FILE=docker-compose.yml:config/<name>/docker-compose.yml`. Configuration lives in `config/<name>/`.

## Files to create

```
config/<name>/
├── docker-compose.yml         # Compose overlay for this backend
├── jdbc/<driver>.jar          # JDBC driver binary (committed or downloaded at setup)
├── nvg-config/
│   ├── datasource.json        # connection URL
│   ├── secret.json            # credentials
│   └── schema.json            # graph model mapping
└── initdb/
    └── init.sql               # DDL + seed data (optional, auto-run on first start)
```

---

## File templates

### `config/<name>/nvg-config/datasource.json`

JDBC backend (`generic` type — used for PostgreSQL, Oracle, MySQL, MariaDB, and any other driver not listed as a first-class type):
```json
{
  "type": "generic",
  "url": "jdbc:<dialect>://<service-name>:<port>/<database>"
}
```

> **Dialect note:** `generic` backends always run with the `Default` SQL dialect inside Graph Engine. There is no config knob to change this. The `Default` dialect generates standard SQL including `ORDER BY … NULLS LAST`, which MySQL and MariaDB do not support. Plan around this before choosing a `generic` backend.

DuckDB embedded:
```json
{
  "type": "duckdb",
  "path": "/duckdb-data/<name>.duckdb"
}
```

SQLite embedded (first-class type, useful for demos — no server needed):
```json
{
  "type": "sqlite",
  "path": "/sqlite-data/<name>.db"
}
```

Any datasource type also accepts an optional `additionalProperties` object. Graph Engine intercepts three reserved keys before forwarding the rest verbatim to the JDBC driver via HikariCP:

```json
{
  "type": "generic",
  "url": "jdbc:postgresql://db:5432/nvg",
  "additionalProperties": {
    "hikari.minimumIdle": "1",
    "hikari.maximumPoolSize": "5",
    "jdbc.fetch_size": "1000"
  }
}
```

- `hikari.minimumIdle` / `hikari.maximumPoolSize` — connection pool sizing (handled by Graph Engine, not forwarded to the driver)
- `jdbc.fetch_size` — row fetch size; SQLite honours this fully, most other drivers ignore it
- anything else is forwarded as-is to the driver (e.g. `ApplicationName`, `defaultRowPrefetch`)

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

`config/<name>/docker-compose.yml`:

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
      - "./initdb:/docker-entrypoint-initdb.d"
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
      - "./jdbc/<driver>.jar:/var/lib/neo4j/lib/<driver>.jar"
      - "./nvg-config:/nvg_home"
```

No explicit `networks:` block needed — Docker Compose default network connects all services in the same project.

---

## Dialect reference

| Backend     | JDBC URL pattern                                                                      | catalog       | schema  | healthcheck                                        | ORDER BY safe? |
|-------------|--------------------------------------------------------------------------------------|---------------|---------|---------------------------------------------------|----------------|
| PostgreSQL  | `jdbc:postgresql://<svc>:5432/<db>`                                                  | db name       | public  | `pg_isready -U nvg`                               | yes |
| MySQL       | `jdbc:mysql://<svc>:3306/<db>?sessionVariables=sql_mode=ANSI_QUOTES`                 | db name       | db name | `mysqladmin ping -h localhost -u nvg --password=nvg` | **no** — no NULLS LAST |
| MariaDB     | `jdbc:mariadb://<svc>:3306/<db>?sessionVariables=sql_mode=ANSI_QUOTES`               | db name       | db name | `mariadb-admin ping -h localhost -u nvg --password=nvg` | **no** — no NULLS LAST |
| Oracle      | `jdbc:oracle:thin:@<svc>:1521/FREE`                                                  | "" (empty)    | schema name (e.g. `NVG`) | `healthcheck.sh`              | yes |
| SingleStore | `jdbc:singlestore://<svc>:3306/<db>`                                                 | db name       | public  | `mysqladmin ping -h 127.0.0.1 -u nvg -pnvg`     | yes |
| DuckDB      | use `"type":"duckdb"` + `"path"` in datasource.json                                  | movies        | main    | n/a (embedded)                                    | yes |
| SQLite      | use `"type":"sqlite"` + `"path"` in datasource.json                                  | db name       | main    | n/a (embedded)                                    | yes |
| Pinot       | `jdbc:pinot://<ctrl>:9000?brokers=<broker>:8099&useMultistageEngine=true`            | "" (empty)    | default | curl controller healthcheck                       | yes |
| Neo4j       | `jdbc:neo4j://<host>:7687`                                                           | db name (e.g. `movies`) | public | wget/curl bolt endpoint              | yes |

---

## .env.template — register the backend

Append to `.env.template`:
```bash
# <BackendName> backend
# COMPOSE_FILE=docker-compose.yml:config/<name>/docker-compose.yml
```

To activate, the user sets this in `.env`.

---

## README.md — update all four locations

After creating the files, update `README.md` in every place that lists backends. Never skip a section.

### 1. Overview tier table (top of file)

Add a row to the table that starts with `| Tier | Backend |`:

```markdown
| **<Tier>** | [<BackendName>](#<anchor>) | <one-line description> |
```

Use the tier the user chose. The anchor is the lowercase section heading (e.g. `mysql` → `#mysql`).

### 2. Quick Start `.env` block

Add a commented entry inside the `\`\`\`dotenv` block in the Quick Start section:

```dotenv
# <BackendName> — <short description>
# COMPOSE_FILE=docker-compose.yml:config/<name>/docker-compose.yml
```

### 3. Backend section body

Add a full section for the new backend under the correct tier heading:

- **Simple** → under `## Simple Backends`
- **Intermediate** → under `## Advanced Backends` (Intermediate backends live in this section — Sakila is the precedent)
- **Advanced** → under `## Advanced Backends`
- **Exotic** → under the last `---` before `## Repository Structure`

Minimum content for a Simple/Intermediate backend section:

```markdown
### <BackendName>

<One-sentence description of what makes this backend interesting.>

| Property | Value |
|----------|-------|
| Image | `<image>:<tag>` |
| Host port | `<host-port>` |
| Database | `<db>` |
| User / Password | `<user>` / `<password>` |
| JDBC URL | `jdbc:<dialect>://<svc>:<port>/<db>` |

**Sample queries:**

\`\`\`cypher
MATCH (m:Movie) RETURN m.title, m.release_year ORDER BY m.release_year DESC LIMIT 10

MATCH path = (p:Person)-[:ACTED_IN]->(m:Movie) RETURN path LIMIT 25
\`\`\`
```

### 4. Repository Structure tree

Add the new backend's directory to the `config/` tree:

```
├── <name>/
│   ├── docker-compose.yml
│   ├── initdb/init.sql
│   ├── jdbc/<driver>.jar
│   └── nvg-config/
```

### 5. Credentials Reference table

Add a row at the bottom of the credentials table:

```markdown
| <BackendName> | `<username>` | `<password>` |
```

---

## Constraints and gotchas

- The JDBC driver jar path inside Neo4j is always `/var/lib/neo4j/lib/<driver>.jar` — not `plugins/`
- **Never use wildcard volume mounts into `/var/lib/neo4j/lib/`** — Docker does not support them into existing directories; a wildcard mount shadows the entire `lib/` folder and Neo4j cannot start. Always mount each driver JAR individually as a named path.
- `nvg-config` directory mounts to `/nvg_home` and replaces the entire config — all three JSON files must be present
- `catalog` in schema.json must match the actual database/catalog name the JDBC driver sees, not necessarily what you named the Docker service
- For DuckDB, `schema` is `main` not `public`
- `key` arrays in relationships must match the actual PK columns of the junction table
- Property `type` values: `STRING`, `INTEGER`, `Long`, `String` (mixed case seen in existing configs — use `STRING`/`INTEGER` for nodes, check existing relationship configs for precedent)
- `depends_on` with `condition: service_healthy` requires a `healthcheck` on the database service — don't skip it
- Named volumes in overlays must be declared at the top-level `volumes:` key of the overlay file
- For MySQL: always append `?sessionVariables=sql_mode=ANSI_QUOTES` to the JDBC URL — NVG generates double-quoted identifiers (ANSI SQL) and MySQL silently misinterprets them as string literals without this flag
- The `"schema"` field in schema.json is **always required** — omitting it causes NVG to fail to resolve tables regardless of dialect. Use the value from the dialect reference table (`public`, `main`, `default`, etc.)
- PostgreSQL `boolean` columns must **never** be mapped in schema.json — NVG's JDBC type mapper cannot handle PostgreSQL's `t`/`f` wire format and will throw `For input string: "t" under radix 2`
- For MySQL: `"schema"` must equal the **database name** (e.g. `"nvg"`), NOT `"public"` — MySQL has no `public` schema; the database name IS the schema, and NVG uses it to qualify generated SQL table references (e.g. `"nvg"."people"`)
