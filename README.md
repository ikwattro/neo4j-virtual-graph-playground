# Neo4j Virtual Graphs — Relational Backend Playground

A hands-on sandbox for exploring the **Neo4j Virtual Graphs** feature, which lets you query relational database tables as if they were a native graph — using Cypher, with no ETL required.

The repository ships with three pre-configured relational backends: **PostgreSQL**, **Oracle Free**, and **Sakila (PostgreSQL)**. Switching between them is a single line change in `.env`.

---

## How It Works

Neo4j Virtual Graphs reads a small set of JSON configuration files (`datasource.json`, `schema.json`, `secret.json`) at startup and exposes the relational tables as virtual nodes and relationships. Queries execute live against the relational source; no data is copied into Neo4j.

The PostgreSQL and Oracle backends use the classic **movies graph**: `Person` nodes, `Movie` nodes, and `ACTED_IN` relationships. The Sakila backend maps the full [Sakila](https://github.com/sakiladb/postgres) DVD rental dataset to a richer graph with 12 node types and 16 relationship types.

```
# Movies backends
(Person)-[:ACTED_IN {role}]->(Movie)

# Sakila backend
(Actor)-[:ACTED_IN]->(Film)-[:IN_CATEGORY]->(Category)
(Customer)-[:MADE]->(Rental)-[:RENTS]->(Inventory)-[:COPY_OF]->(Film)
(Customer)-[:HAS_ADDRESS]->(Address)-[:IN_CITY]->(City)-[:IN_COUNTRY]->(Country)
```

---

## Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (or Docker Engine + Compose plugin)
- A valid **Neo4j Enterprise** license — the image used is `neo4j:2026.05.0-enterprise` and will not start without accepting the license agreement (already set in the compose file via `NEO4J_ACCEPT_LICENSE_AGREEMENT=yes`)
- For Oracle: the `gvenzl/oracle-free:23-slim` image takes 60–120 seconds to initialize on first run

---

## Quick Start

### 1. Choose a backend

Open `.env` and uncomment the line for the backend you want:

```dotenv
# PostgreSQL (movies graph)
# COMPOSE_FILE=docker-compose.yml:docker-compose-postgres.yml

# Oracle (movies graph)
# COMPOSE_FILE=docker-compose.yml:docker-compose-oracle.yml

# Sakila — DVD rental dataset (active by default)
COMPOSE_FILE=docker-compose.yml:docker-compose-sakila.yml
```

### 2. Start the stack

```bash
docker compose up -d
```

Docker Compose automatically reads `.env`, so no extra flags are needed. The database container starts first and Neo4j waits for its healthcheck to pass before booting.

### 3. Open Neo4j Browser

Navigate to `http://localhost:7474` and connect with:

| Field    | Value           |
|----------|-----------------|
| URL      | `bolt://localhost:7687` |
| Username | `neo4j`         |
| Password | `hellopassword` |

### 4. Query the virtual graph

```cypher
// List all movies in the virtual graph
MATCH (m:Movie) RETURN m.title, m.release_year ORDER BY m.release_year DESC LIMIT 10;

// Find actors and the films they appeared in
MATCH path=(p:Person)-[r:ACTED_IN]->(m:Movie)
RETURN path;

// Find co-actors of Keanu Reeves
MATCH path=(keanu:Person {name: 'Keanu Reeves'})-[:ACTED_IN]->(m:Movie)<-[:ACTED_IN]-(coactor:Person)
RETURN path;
```
![virtual graphs](./screenshot1.png)
---

## Repository Structure

```
.
├── .env                              # Backend selector — edit this to switch databases
├── docker-compose.yml                # Base Neo4j service definition
├── docker-compose-postgres.yml       # PostgreSQL overlay (movies graph)
├── docker-compose-oracle.yml         # Oracle overlay (movies graph)
├── docker-compose-sakila.yml         # Sakila overlay (DVD rental graph)
└── config/
    ├── postgres/
    │   ├── initdb/
    │   │   └── init.sql              # Schema + seed data (runs on first container start)
    │   ├── jdbc/
    │   │   └── postgresql-42.7.11.jar
    │   └── nvg-config/
    │       ├── datasource.json       # JDBC connection URL
    │       ├── secret.json           # Credentials
    │       └── schema.json           # Table → node/relationship mapping
    ├── oracle/
    │   ├── initdb/
    │   │   └── init.sql
    │   ├── jdbc/
    │   │   └── ojdbc17.jar
    │   └── nvg-config/
    │       ├── datasource.json
    │       ├── secret.json
    │       └── schema.json
    └── sakila/
        └── nvg-config/               # No initdb — data ships inside the Docker image
            ├── datasource.json
            ├── secret.json
            └── schema.json           # 12 node types, 16 relationship types
```

### NVG configuration files

| File             | Purpose |
|------------------|---------|
| `datasource.json` | JDBC driver type and connection URL |
| `secret.json`     | Authentication credentials |
| `schema.json`     | Maps tables/columns to graph labels, properties, and relationship keys |

---

## Backend Details

### PostgreSQL

| Property | Value |
|----------|-------|
| Image | `postgres:17-alpine` |
| Host port | `5488` |
| Database | `nvg` |
| User / Password | `nvg` / `nvg` |
| JDBC URL | `jdbc:postgresql://postgres-vg:5432/nvg` |

WAL logical replication is enabled (`wal_level=logical`) to support future CDC use cases.

### Oracle Free

| Property | Value |
|----------|-------|
| Image | `gvenzl/oracle-free:23-slim` |
| Host port | `1521` |
| PDB | `FREEPDB1` |
| Schema / Password | `NVG` / `nvg` |
| JDBC URL | `jdbc:oracle:thin:@//oracle-vg:1521/FREEPDB1` |

> Oracle's container takes 60–120 seconds to initialize on the first run. The healthcheck (`healthcheck.sh`) gates Neo4j startup, so the virtual graph will become available automatically once Oracle is ready.

### Sakila (PostgreSQL)

| Property | Value |
|----------|-------|
| Image | `sakiladb/postgres:latest` |
| Host port | `5489` |
| Database | `sakila` |
| User / Password | `sakila` / `p_ssW0rd` |
| JDBC URL | `jdbc:postgresql://sakila-vg:5432/sakila` |

The image ships pre-populated with the full [Sakila dataset](https://github.com/sakiladb/postgres) — no `init.sql` needed. The graph model covers the complete rental domain:

| Node | Source table |
|------|-------------|
| `Actor`, `Film`, `Category`, `Language` | `actor`, `film`, `category`, `language` |
| `Customer`, `Store`, `Staff` | `customer`, `store`, `staff` |
| `Inventory`, `Rental` | `inventory`, `rental` |
| `Address`, `City`, `Country` | `address`, `city`, `country` |

| Relationship | Mapped from |
|---|---|
| `(Actor)-[:ACTED_IN]->(Film)` | `film_actor` junction table |
| `(Film)-[:IN_CATEGORY]->(Category)` | `film_category` junction table |
| `(Film)-[:IN_LANGUAGE]->(Language)` | `film.language_id` FK |
| `(Inventory)-[:COPY_OF]->(Film)`, `(Inventory)-[:IN_STORE]->(Store)` | `inventory` FKs |
| `(Customer)-[:MADE]->(Rental)-[:RENTS]->(Inventory)` | `rental` FKs |
| `(Rental)-[:PROCESSED_BY]->(Staff)` | `rental.staff_id` FK |
| `(Customer/Store/Staff)-[:HAS_ADDRESS]->(Address)` | respective table FKs |
| `(Address)-[:IN_CITY]->(City)-[:IN_COUNTRY]->(Country)` | `address`, `city` FKs |
| `(Store)-[:MANAGED_BY]->(Staff)`, `(Staff)-[:WORKS_AT]->(Store)` | `store`, `staff` FKs |
| `(Customer)-[:SHOPS_AT]->(Store)` | `customer.store_id` FK |

Example queries:

```cypher
// Rental journey: who rented what film and in which category
MATCH p = (cust:Customer)-[:MADE]->(r:Rental)-[:RENTS]->(inv:Inventory)-[:COPY_OF]->(f:Film)-[:IN_CATEGORY]->(cat:Category)
RETURN p LIMIT 10
```

![sakila virtual graph](./screenshot-sakila.png)

```cypher
// Actor → Film → Language chain
MATCH p = (a:Actor)-[:ACTED_IN]->(f:Film)-[:IN_LANGUAGE]->(lang:Language)
RETURN p LIMIT 10
```

> **Note:** PostgreSQL `boolean` columns (`activebool`, `active`) are not mapped — NVG's JDBC bit mapper cannot handle PostgreSQL's `t`/`f` wire format.

---

## Adding a New Relational Backend

Follow these steps to add a new database (e.g. MySQL, SQL Server, or any JDBC-compatible source).

### 1. Create the configuration directory

```
config/
└── <backend-name>/
    ├── initdb/
    │   └── init.sql          # DDL + seed data
    ├── jdbc/
    │   └── <driver>.jar      # JDBC driver for the database
    └── nvg-config/
        ├── datasource.json
        ├── secret.json
        └── schema.json
```

### 2. Write the NVG config files

**`datasource.json`** — specify the JDBC URL using the Docker Compose service name as the host:

```json
{
  "type": "generic",
  "url": "jdbc:<dialect>://<service-name>:<port>/<database>"
}
```

**`secret.json`** — credentials used to connect:

```json
{
  "type": "basic",
  "username": "<user>",
  "password": "<password>"
}
```

**`schema.json`** — map your tables to graph entities. The structure mirrors the existing backends:

```json
{
  "catalog": "",
  "schema": "<db-schema>",
  "entities": {
    "nodes": [
      {
        "label": "Movie",
        "table": "movies",
        "properties": [
          { "name": "title", "column": "TITLE", "type": "STRING" }
        ],
        "key": [{ "column": "ID" }]
      }
    ],
    "relationships": [
      {
        "label": "ACTED_IN",
        "table": "movie_actors",
        "start": {
          "targetEntity": "Person",
          "keys": [{ "nodeColumn": "ID", "relationshipColumn": "PERSON_ID" }]
        },
        "end": {
          "targetEntity": "Movie",
          "keys": [{ "nodeColumn": "ID", "relationshipColumn": "MOVIE_ID" }]
        },
        "properties": [],
        "key": [
          { "column": "PERSON_ID" },
          { "column": "MOVIE_ID" }
        ]
      }
    ]
  }
}
```

### 3. Create the Docker Compose overlay

Create `docker-compose-<backend-name>.yml` at the root of the repo. The file has two responsibilities: define the database service, and extend the `neo4j` service with the JDBC driver and NVG config volume mounts.

```yaml
# docker-compose-mysql.yml (example)
volumes:
  nvg_mysql_data:

services:
  mysql-vg:
    image: mysql:8.4
    environment:
      MYSQL_DATABASE: nvg
      MYSQL_USER: nvg
      MYSQL_PASSWORD: nvg
      MYSQL_ROOT_PASSWORD: root
    ports:
      - 3306:3306
    volumes:
      - "nvg_mysql_data:/var/lib/mysql"
      - "./config/mysql/initdb:/docker-entrypoint-initdb.d"
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost", "-unvg", "-pnvg"]
      interval: 5s
      retries: 10
      start_period: 30s
      timeout: 5s

  neo4j:
    depends_on:
      mysql-vg:
        condition: service_healthy
    volumes:
      - "./config/mysql/jdbc/mysql-connector-j-8.4.0.jar:/var/lib/neo4j/lib/mysql-connector-j-8.4.0.jar"
      - "./config/mysql/nvg-config:/nvg_home"
```

### 4. Register it in `.env`

Add a new commented-out line so users can switch to it:

```dotenv
# COMPOSE_FILE=docker-compose.yml:docker-compose-mysql.yml
```

### 5. Checklist

- [ ] JDBC driver `.jar` placed in `config/<backend-name>/jdbc/`
- [ ] `datasource.json` uses the Compose service name as the JDBC host
- [ ] `schema.json` catalog/schema fields match the database dialect (Oracle requires an empty `catalog`)
- [ ] Healthcheck in the compose overlay is reliable before Neo4j starts
- [ ] `init.sql` is idempotent (`CREATE TABLE IF NOT EXISTS`, `INSERT OR IGNORE`, etc.)

---

## Stopping and Resetting

```bash
# Stop all containers
docker compose down

# Stop and delete volumes (full reset — re-runs init.sql on next start)
docker compose down -v
```

---

## Credentials Reference

| Service | Username | Password |
|---------|----------|----------|
| Neo4j | `neo4j` | `hellopassword` |
| PostgreSQL (movies) | `nvg` | `nvg` |
| Oracle (movies) | `nvg` | `nvg` |
| Sakila (PostgreSQL) | `sakila` | `p_ssW0rd` |
