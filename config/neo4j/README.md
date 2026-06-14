# Neo4jGraph

The most exotic backend. Neo4jGraph virtualises a *remote Neo4j database* through Neo4j Virtual Graphs using the **Neo4j JDBC driver** and its built-in `sql2cypher` translation layer. The result is a delightfully recursive query pipeline:

```
You write Cypher
    ↓  NVG translates to SQL  (cypher2sql)
Neo4j JDBC driver receives SQL
    ↓  driver translates back to Cypher  (sql2cypher)
Remote Neo4j instance executes native Cypher
    ↓  results flow back up the chain
You see a graph
```

In other words: **Cypher → cypher2sql → sql2cypher → Cypher**. The intermediate SQL hop is entirely transparent — you write and read Cypher all the way through.

The "remote" Neo4j (`neo4j2`) is a second Neo4j instance running in the same Compose stack. It is seeded automatically on startup with the classic movies dataset using [neo4j-config-cli](https://github.com/graphaware/neo4j-config-cli).

## Activate

```dotenv
COMPOSE_FILE=docker-compose.yml:config/neo4j/docker-compose.yml
```

## Properties

| Property | Value |
|----------|-------|
| JDBC driver | `neo4j-jdbc-driver-6.13.0.jar` (committed) |
| Remote Neo4j Bolt | `bolt://neo4j2:7687` |
| Remote credentials | `neo4j` / `hellopassword` |
| Seed tool | `graphaware/neo4j-config-cli:2.7.3` |
| Remote Neo4j Browser | `http://localhost:17474` |

## Setup

No extra steps — the JDBC driver is committed. Start the stack:

```bash
docker compose up -d
```

## Startup sequence

1. **neo4j2** starts and passes its healthcheck (cypher-shell probe)
2. **neo4j-config-cli** connects to `neo4j2`, applies seed Cypher, then exits
3. **neo4j** (the Virtual Graphs instance) waits for `neo4j-config-cli` to complete successfully, then boots

## Graph model

The remote instance holds the standard movies graph seeded by `neo4j-config-cli`:

```
(Person)-[:ACTED_IN]->(Movie)
```

## Sample queries

```cypher
MATCH path = (n:Person {name: "Keanu Reeves"})-[:ACTED_IN]->(m:Movie)
RETURN path
```

> The Cypher above travels through two translation layers before any real data is touched — NVG renders it as SQL for the JDBC driver, which re-interprets that SQL as Cypher against `neo4j2`. Both hops are invisible to the query author.
