# PostgreSQL

Single-service JDBC backend exposing the classic movies graph via the PostgreSQL JDBC driver.

## Activate

```dotenv
COMPOSE_FILE=docker-compose.yml:config/postgres/docker-compose.yml
```

## Properties

| Property | Value |
|----------|-------|
| Image | `postgres:17-alpine` |
| Host port | `5488` |
| Database | `nvg` |
| User / Password | `nvg` / `nvg` |
| JDBC URL | `jdbc:postgresql://postgres-vg:5432/nvg` |
| JDBC driver | `postgresql-42.7.11.jar` (committed) |

## Setup

No extra steps — the JDBC driver is committed. Start the stack:

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

MATCH path = (keanu:Person {name: 'Keanu Reeves'})-[:ACTED_IN]->(m:Movie)<-[:ACTED_IN]-(co:Person)
RETURN path
```

## Notes

WAL logical replication is enabled (`wal_level=logical`) to support future CDC use cases.

**Boolean columns:** PostgreSQL `boolean` columns cannot be mapped in `schema.json` — NVG's JDBC type mapper cannot handle PostgreSQL's `t`/`f` wire format and will throw `For input string: "t" under radix 2`. Exclude all `boolean` columns from node/relationship property mappings.
