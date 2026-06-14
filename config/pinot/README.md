# PinotGraph

A real-time OLAP backend. PinotGraph virtualises an **Apache Pinot** cluster — a distributed, columnar analytics store used at LinkedIn, Uber, and others. Pinot speaks SQL but requires its **multi-stage query engine** (MSE, based on Apache Calcite) for JOINs and CTEs, both of which Neo4j Virtual Graphs generates. MSE is enabled automatically in this setup.

```
CSV files (shared from config/minio/)
    ↓  ingested at startup via Pinot batch ingestion (LaunchDataIngestionJob)
Apache Pinot cluster (ZooKeeper + Controller + Broker + Server)
    ↓  queried via Pinot JDBC driver with useMultistageEngine=true
Neo4j Virtual Graphs
    ↓  queried with Cypher
You
```

## Activate

```dotenv
COMPOSE_FILE=docker-compose.yml:config/pinot/docker-compose.yml
```

## Setup

**1. Build the Pinot JDBC fat jar** (one-time, requires Docker):

The Pinot JDBC client has many transitive dependencies that are not bundled in the Maven artifact. The build script uses a Maven container to assemble them into a single self-contained jar. Maven dependencies (~300 MB) are downloaded on the first run and cached in a named Docker volume for subsequent runs.

```bash
cd config/pinot
./build-pinot-jdbc.sh
```

This places `pinot-jdbc-client-1.3.0.jar` in `config/pinot/jdbc/`.

**2. Start the stack:**

```bash
docker compose up -d
```

## Startup sequence

1. **ZooKeeper** starts and passes its healthcheck
2. **Pinot Controller** registers with ZooKeeper and becomes healthy
3. **Pinot Broker** registers with the cluster and becomes healthy
4. **Pinot Server** joins the cluster and becomes healthy
5. **pinot-init** enables MSE cluster-wide, creates 6 schemas and 6 OFFLINE tables, then ingests data from the shared CSV files — exits 0 when done
6. **Neo4j** waits for `pinot-init` to complete successfully, then boots with the JDBC driver mounted

On subsequent `docker compose up`, `pinot-init` detects existing segments and exits immediately — no duplicate schema/table creation errors.

## Services

| Service | Port | Notes |
|---------|------|-------|
| Pinot Controller + Query Console | `9000` | Web UI, REST API, ad-hoc SQL |
| Pinot Broker | `8099` | JDBC query endpoint |
| Neo4j Browser | `7474` | As usual |

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
MATCH (p:Person)-[:ACTED_IN]->(m:Movie)
RETURN p.name, m.title LIMIT 10

MATCH path = (p:Person)-[:ACTED_IN]->(m:Movie)-[:IN_GENRE]->(g:Genre)
RETURN path LIMIT 25

MATCH (p:Person)-[:DIRECTED]->(m:Movie)-[:IN_GENRE]->(g:Genre)
RETURN p.name AS director, collect(DISTINCT g.name) AS genres
ORDER BY director
```

## Exploring Pinot directly

The Pinot Query Console is available at `http://localhost:9000`. Run SQL there to inspect table contents independently of Neo4j:

```sql
SELECT title, release_year FROM movies ORDER BY release_year DESC LIMIT 5;
SELECT p.name, COUNT(*) AS films
FROM people p JOIN movie_actors ma ON p.person_id = ma.person_id
GROUP BY p.name ORDER BY films DESC;
```

## Technical notes

- The JDBC URL uses `useMultistageEngine=true` (lowercase `s` in `stage`) — the exact string of `QueryOptionKey.USE_MULTISTAGE_ENGINE` in Pinot's source. `useMultiStageEngine` (capital `S`) is silently ignored by the driver.
- MSE is also set cluster-wide via `POST /cluster/configs` on startup so it persists across Neo4j reconnects.
- Tables are `OFFLINE` type — static batch data, no real-time ingestion.
- The broker config (`broker.conf`) passes `pinot.broker.enableMultiStagePipeline=true` as a belt-and-suspenders fallback.

## Known limitations

**Multiple relationship types in a single pattern not supported:** The `|` operator in `MATCH` patterns (e.g. `[:ACTED_IN|DIRECTED]`) returns no results — NVG maps each relationship type to a specific table and does not generate the required SQL union. Run separate queries instead.
