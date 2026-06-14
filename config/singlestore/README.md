# SingleStore

[SingleStore](https://www.singlestore.com/) is a distributed SQL database with MySQL-compatible syntax optimized for real-time analytics. It uses columnar storage by default, making it well-suited for analytical queries over the movies graph.

## Activate

```dotenv
COMPOSE_FILE=docker-compose.yml:config/singlestore/docker-compose.yml
```

## Properties

| Property | Value |
|----------|-------|
| Image | `ghcr.io/singlestore-labs/singlestoredb-dev:latest` |
| Host port | `3306` (MySQL protocol), `8080` (Studio UI) |
| Database | `nvg` |
| User / Password | `root` / `nvg` |
| JDBC URL | `jdbc:singlestore://singlestore-vg:3306/nvg` |
| JDBC driver | `singlestore-jdbc-client-1.1.3.jar` (committed) |

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

## Exploring SingleStore directly

The SingleStore Studio UI is available at `http://localhost:8080`. Connect with `root` / `nvg` to browse tables and run SQL.
