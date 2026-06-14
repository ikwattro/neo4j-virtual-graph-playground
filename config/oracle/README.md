# Oracle Free

Single-service JDBC backend exposing the classic movies graph via the Oracle JDBC driver (ojdbc17).

## Activate

```dotenv
COMPOSE_FILE=docker-compose.yml:config/oracle/docker-compose.yml
```

## Properties

| Property | Value |
|----------|-------|
| Image | `gvenzl/oracle-free:23-slim` |
| Host port | `1521` |
| PDB | `FREEPDB1` |
| Schema / Password | `NVG` / `nvg` |
| JDBC URL | `jdbc:oracle:thin:@//oracle-vg:1521/FREEPDB1` |
| JDBC driver | `ojdbc17.jar` (committed) |

## Setup

No extra steps — the JDBC driver is committed. Start the stack:

```bash
docker compose up -d
```

> Oracle's container takes 60–120 seconds to initialize on the first run. The healthcheck gates Neo4j startup automatically — Neo4j will not boot until Oracle is ready.

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

Avoid `LIMIT` — Oracle does not support the `LIMIT` clause (see Known Limitations below).

```cypher
MATCH path = (p:Person)-[:ACTED_IN]->(m:Movie) RETURN path

MATCH path = (keanu:Person {name: 'Keanu Reeves'})-[:ACTED_IN]->(m:Movie)<-[:ACTED_IN]-(co:Person)
RETURN path
```

## Known limitations

**`LIMIT` not supported:** NVG's `Default` SQL dialect generates `LIMIT ?` for result pagination. Oracle does not support the `LIMIT` clause — it uses `FETCH FIRST n ROWS ONLY` with a mandatory `ORDER BY` (since 12c). There is no config knob to change the NVG SQL dialect. Any Cypher query that uses `LIMIT` will fail with:

```
ORA-03049: SQL keyword 'LIMIT' is not syntactically valid following '...FROM "NVG"."MOVIES" "m"'
```

Workaround: avoid `LIMIT` in Cypher queries against this backend.
