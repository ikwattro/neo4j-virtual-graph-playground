# ClickHouse

A column-oriented OLAP database exposed via JDBC — the classic movies graph, adapted to ClickHouse's `MergeTree` engine model (no primary/foreign key enforcement, explicit sort keys, and default-`NOT NULL` columns).

## Activate

```dotenv
COMPOSE_FILE=docker-compose.yml:config/clickhouse/docker-compose.yml
```

## Properties

| Property | Value |
|----------|-------|
| Image | `clickhouse/clickhouse-server:latest-alpine` |
| Host port | `8123` (HTTP), `9000` (native) |
| Database | `nvg` |
| User / Password | `nvg` / `nvg` |
| JDBC URL | `jdbc:clickhouse://clickhouse-vg:8123/nvg` |
| JDBC driver | `clickhouse-jdbc-0.9.0-all.jar` (downloaded, not committed) |

## Setup

The JDBC driver is not committed to the repo (it's a large shaded uber-jar) — download it first:

```bash
mkdir -p config/clickhouse/jdbc
curl -L -o config/clickhouse/jdbc/clickhouse-jdbc-0.9.0-all.jar \
  https://repo1.maven.org/maven2/com/clickhouse/clickhouse-jdbc/0.9.0/clickhouse-jdbc-0.9.0-all.jar
```

Then start the stack:

```bash
docker compose up -d
```

## Graph model

```
(Person)-[:ACTED_IN {role}]->(Movie)
```

| Node | Table | Key properties |
|------|-------|----------------|
| `Movie` | `movies` | `title`, `tagline`, `release_year` |
| `Person` | `people` | `name`, `born` |

| Relationship | Table | Properties |
|---|---|---|
| `ACTED_IN` | `movie_actors` | `role` |

## Sample queries

```cypher
MATCH (m:Movie) RETURN m.title, m.release_year ORDER BY m.release_year DESC LIMIT 10

MATCH path = (p:Person)-[:ACTED_IN]->(m:Movie) RETURN path LIMIT 25
```

## Known limitations

**JDBC catalog/schema inversion:** ClickHouse's JDBC driver exposes the database name through the JDBC "schema" concept, not "catalog" (`getCatalogs()` returns nothing; `getSchemas()` lists databases). `schema.json` uses `"catalog": ""` and `"schema": "nvg"` accordingly — the reverse of the Postgres/MySQL pattern.

**No foreign key enforcement:** ClickHouse's `MergeTree` engine has no `REFERENCES`/FK constraint support — referential integrity in the seed data is not enforced by the database.

**`CLICKHOUSE_DB` does not redirect init scripts:** despite setting `CLICKHOUSE_DB=nvg`, the official image still runs `/docker-entrypoint-initdb.d/*.sql` against the `default` database. `init.sql` must qualify every table with the `nvg.` prefix explicitly (`CREATE TABLE nvg.people ...`, `INSERT INTO nvg.people ...`) or the seed data silently lands in the wrong database.

**Healthcheck must target `127.0.0.1`, not `localhost`:** in this Alpine container `localhost` resolves to `::1` first, but ClickHouse only binds the IPv4 listener reliably — a `wget ... http://localhost:8123/ping` healthcheck fails with "Connection refused" even though the server is up. Use `http://127.0.0.1:8123/ping`.
