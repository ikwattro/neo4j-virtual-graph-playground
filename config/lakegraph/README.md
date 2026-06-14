# LakeGraph

An advanced data lake backend. Instead of connecting to a relational database, this setup builds a full data lake pipeline and exposes it as a graph:

```
CSV files in MinIO (S3-compatible object storage)
    ↓  materialized on startup by DuckDB
DuckDB (embedded, file-based)
    ↓  read via JDBC driver (shared Docker volume)
Neo4j Virtual Graphs
    ↓  queried with Cypher
You
```

The movies dataset lives as CSV files in a MinIO bucket. On startup, DuckDB pulls them over S3 and materializes them as physical tables in a `.duckdb` file. Neo4j mounts that file via a shared Docker volume and connects using DuckDB's JDBC driver — no network connection to DuckDB, it's embedded directly in the JDBC layer.

## Activate

```dotenv
COMPOSE_FILE=docker-compose.yml:config/lakegraph/docker-compose.yml
```

## Setup

**1. Download the DuckDB JDBC driver:**

```bash
curl -L -o config/lakegraph/jdbc/duckdb_jdbc-1.5.3.0.jar \
  https://repo1.maven.org/maven2/org/duckdb/duckdb_jdbc/1.5.3.0/duckdb_jdbc-1.5.3.0.jar
```

**2. Start the stack:**

```bash
docker compose up --build -d
```

> Use `--build` any time you change files under `config/lakegraph/duckdb/` — Docker won't rebuild the DuckDB image otherwise.

## Startup sequence

1. **MinIO** starts and passes its healthcheck
2. **minio-mc** uploads 5 CSV files to the `movies-data` bucket, then exits
3. **DuckDB** waits for mc to complete, materializes 7 tables from MinIO, and writes `movies.duckdb`
4. **Neo4j** waits for DuckDB's healthcheck (file exists), then mounts the volume and boots

## Services

| Service | Port | Credentials |
|---------|------|-------------|
| MinIO API | `9000` | `minio` / `hellopassword` |
| MinIO Console | `9001` | `minio` / `hellopassword` |
| DuckDB CLI | — | `docker exec -it duckdb-playground duckdb /data/movies.duckdb` |

## Graph model

```
(Person)-[:DIRECTED]->(Movie)
(Person)-[:ACTED_IN {character}]->(Movie)
(Movie)-[:IN_GENRE]->(Genre)
```

| Node | Source table | Key properties |
|------|-------------|----------------|
| `Movie` | `movies` | `title`, `release_year`, `runtime_minutes`, `budget_usd`, `revenue_usd` |
| `Person` | `people` | `name`, `birth_year`, `nationality` |
| `Genre` | `genres` | `name` |

| Relationship | Source table | Notes |
|---|---|---|
| `ACTED_IN` | `movie_actors` | derived from `movie_crew WHERE role = 'Actor'`; has `character` property |
| `DIRECTED` | `movie_directors` | derived from `movie_crew WHERE role = 'Director'` |
| `IN_GENRE` | `movie_genres` | junction table |

## Sample queries

```cypher
// All paths through the graph
MATCH path = (p:Person)-[:ACTED_IN]->(m:Movie)-[:IN_GENRE]->(g:Genre)
RETURN path LIMIT 25

// Director → films → genres
MATCH path = (p:Person {name: 'Christopher Nolan'})-[:DIRECTED]->(m:Movie)-[:IN_GENRE]->(g:Genre)
RETURN path

// Actors in Crime films with budget info
MATCH (p:Person)-[:ACTED_IN]->(m:Movie)-[:IN_GENRE]->(g:Genre {name: 'Crime'})
RETURN p.name, m.title, m.release_year, m.budget_usd
ORDER BY m.release_year
```

## Exploring DuckDB directly

```bash
docker exec -it duckdb-playground duckdb /data/movies.duckdb
```

```sql
SHOW TABLES;
SELECT title, revenue_usd FROM movies ORDER BY revenue_usd DESC LIMIT 5;
SELECT p.name, count(*) AS films
FROM people p JOIN movie_crew mc ON p.person_id = mc.person_id
WHERE mc.role = 'Actor'
GROUP BY p.name ORDER BY films DESC;
```

## Known limitations

**Multiple relationship types in a single pattern not supported:** The `|` operator in `MATCH` patterns (e.g. `[:ACTED_IN|DIRECTED]`) returns no results — NVG maps each relationship type to a specific table and does not generate the required SQL union. Run separate queries instead.
