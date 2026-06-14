# Neo4j Virtual Graphs Playground

A hands-on sandbox for exploring the **Neo4j Virtual Graphs** feature, which lets you query relational database tables as if they were a native graph — using Cypher, with no ETL required.

| Tier | Backend | What makes it interesting |
|------|---------|--------------------------|
| **Simple** | [PostgreSQL](config/postgres/README.md) | Single-service JDBC connection, classic movies graph |
| **Simple** | [Oracle Free](config/oracle/README.md) | Single-service JDBC connection, classic movies graph |
| **Simple** | [SingleStore](config/singlestore/README.md) | MySQL-compatible distributed SQL, classic movies graph |
| **Simple** | [MySQL](config/mysql/README.md) | Single-service JDBC connection, classic movies graph |
| **Simple** | [MariaDB](config/mariadb/README.md) | MySQL-compatible with native MariaDB Connector/J, classic movies graph |
| **Simple** | [SQL Server](config/sqlserver/README.md) | Microsoft SQL Server 2022, classic movies graph |
| **Intermediate** | [Sakila](config/sakila/README.md) | More complex relational schema — DVD rental store |
| **Advanced** | [LakeGraph](config/lakegraph/README.md) | CSV files in MinIO, materialized by DuckDB on startup |
| **Advanced** | [IceGraph](config/icegraph/README.md) | Pre-built Apache Iceberg tables (Parquet) in MinIO, queried via DuckDB |
| **Advanced** | [PinotGraph](config/pinot/README.md) | Apache Pinot OLAP cluster — real-time analytics store with multi-stage SQL engine |
| **Exotic** | [Neo4jGraph](config/neo4j/README.md) | Remote Neo4j instance virtualised via Neo4j JDBC — Cypher → cypher2sql → sql2cypher |

> Some backends have known query limitations (unsupported SQL syntax, unsupported column types). See each backend's README and [LIMITATIONS.md](LIMITATIONS.md) for details.

---

## How It Works

Neo4j Virtual Graphs reads a small set of JSON configuration files (`datasource.json`, `schema.json`, `secret.json`) at startup and exposes the relational tables as virtual nodes and relationships. Queries execute live against the relational source — no data is copied into Neo4j.

---

## Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (or Docker Engine + Compose plugin)
- A valid **Neo4j Enterprise** license — the image used is `neo4j:2026.05.0-enterprise` and will not start without accepting the license agreement (already set in the compose file via `NEO4J_ACCEPT_LICENSE_AGREEMENT=yes`)
- **SSL certificates** — required for features such as remote aliases; self-signed demo certs are included in the repository (see [SSL Certificates](#ssl-certificates))
- Some backends require a one-time setup step (driver download or fat jar build) — see each backend's README

---

## SSL Certificates

Some Neo4j features (e.g. remote aliases) require TLS to be configured. The compose file expects self-signed certificates at `ssl/bolt/` and `ssl/https/`. **These are committed to the repository** — no generation step is needed. They are demo-only, self-signed certs with no CA trust and no real-world value.

---

## Quick Start

### 1. Set up your environment file

Copy the template to create your local `.env` (this file is git-ignored so your changes won't be committed):

```bash
cp .env.template .env
```

Open `.env` and uncomment the line for the backend you want. For example:

```dotenv
COMPOSE_FILE=docker-compose.yml:config/postgres/docker-compose.yml
```

Each backend's README has its exact activation line.

### 2. Start the stack

```bash
docker compose up -d
```

Docker Compose automatically reads `.env`, so no extra flags are needed. The database container starts first and Neo4j waits for its healthcheck to pass before booting.

### 3. Open Neo4j Browser

Navigate to `http://localhost:7474` and connect with:

| Field    | Value |
|----------|-------|
| URL      | `bolt://localhost:7687` |
| Username | `neo4j` |
| Password | `hellopassword` |

---

## Stopping and Resetting

```bash
# Stop all containers (data volumes preserved)
docker compose down

# Full reset — deletes volumes, re-runs init on next start
docker compose down -v
```

---

## Credentials Reference

| Service | Username | Password |
|---------|----------|----------|
| Neo4j | `neo4j` | `hellopassword` |
| PostgreSQL (movies) | `nvg` | `nvg` |
| Oracle (movies) | `NVG` | `nvg` |
| MySQL (movies) | `nvg` | `nvg` |
| MariaDB (movies) | `nvg` | `nvg` |
| SingleStore (movies) | `root` | `nvg` |
| Sakila (PostgreSQL) | `sakila` | `p_ssW0rd` |
| Workspaces (PostgreSQL) | `workspaces` | `workspaces` |
| MinIO (LakeGraph) | `minio` | `hellopassword` |
| MinIO (IceGraph) | `minio` | `hellopassword` |
| Pinot Controller / Broker | — | no authentication |
| SQL Server (movies) | `nvg` | `nvg` |

---

## Backends

- [PostgreSQL](config/postgres/README.md)
- [Oracle Free](config/oracle/README.md)
- [SingleStore](config/singlestore/README.md)
- [MySQL](config/mysql/README.md)
- [MariaDB](config/mariadb/README.md)
- [SQL Server](config/sqlserver/README.md)
- [Sakila](config/sakila/README.md)
- [LakeGraph](config/lakegraph/README.md)
- [IceGraph](config/icegraph/README.md)
- [PinotGraph](config/pinot/README.md)
- [Neo4jGraph](config/neo4j/README.md)
- [Workspaces](config/workspaces/README.md)

---

## Adding a New Backend

Each backend lives entirely in `config/<name>/` — a `docker-compose.yml` overlay, JDBC driver, NVG config files, and optional init SQL. Use the `/add-backend` skill in Claude Code, which has all templates and dialect-specific patterns baked in.

The activation line in `.env` follows the pattern:

```dotenv
COMPOSE_FILE=docker-compose.yml:config/<name>/docker-compose.yml
```
