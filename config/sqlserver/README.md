# SQL Server

[Microsoft SQL Server](https://www.microsoft.com/en-us/sql-server) 2022 backend exposing the classic movies graph via the Microsoft JDBC Driver for SQL Server.

## Activate

```dotenv
COMPOSE_FILE=docker-compose.yml:config/sqlserver/docker-compose.yml
```

## Properties

| Property | Value |
|----------|-------|
| Image | `mcr.microsoft.com/mssql/server:2022-latest` |
| Host port | `1433` |
| Database | `nvg` |
| User / Password | `nvg` / `nvg` |
| JDBC URL | `jdbc:sqlserver://sqlserver-vg:1433;databaseName=nvg;trustServerCertificate=true` |
| JDBC driver | `mssql-jdbc-12.8.1.jre11.jar` (committed) |

## Setup

No extra steps — the JDBC driver is committed. Start the stack:

```bash
docker compose up -d
```

> SQL Server 2022 takes 20–40 seconds to initialize. The healthcheck gates Neo4j startup automatically.

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

Avoid `LIMIT` — SQL Server does not support the `LIMIT` clause (see Known Limitations below).

```cypher
MATCH path = (p:Person)-[:ACTED_IN]->(m:Movie) RETURN path

MATCH path = (keanu:Person {name: 'Keanu Reeves'})-[:ACTED_IN]->(m:Movie)<-[:ACTED_IN]-(co:Person)
RETURN path
```

## Known limitations

**`LIMIT` not supported:** NVG's `Default` SQL dialect generates `LIMIT ?` for result pagination. SQL Server T-SQL has no `LIMIT` keyword — it uses `TOP n` or `FETCH FIRST n ROWS ONLY`. There is no config knob to change the NVG SQL dialect. Any Cypher query that uses `LIMIT` will fail with:

```
Incorrect syntax near 'LIMIT'.
```

Workaround: avoid `LIMIT` in Cypher queries against this backend.
