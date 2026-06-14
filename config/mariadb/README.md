# MariaDB

[MariaDB](https://mariadb.org/) is an open-source MySQL-compatible database with its own native JDBC connector. This backend uses the MariaDB Connector/J (`jdbc:mariadb://`) rather than the MySQL Connector/J, making it a useful companion to the MySQL backend for comparing driver behaviour.

## Activate

```dotenv
COMPOSE_FILE=docker-compose.yml:config/mariadb/docker-compose.yml
```

## Properties

| Property | Value |
|----------|-------|
| Image | `mariadb:11` |
| Host port | `3389` |
| Database | `nvg` |
| User / Password | `nvg` / `nvg` |
| JDBC URL | `jdbc:mariadb://mariadb-vg:3306/nvg?sessionVariables=sql_mode=ANSI_QUOTES` |
| JDBC driver | `mariadb-java-client-3.4.1.jar` (not committed — download below) |

## Setup

**1. Download the JDBC driver:**

```bash
curl -L -o config/mariadb/jdbc/mariadb-java-client-3.4.1.jar \
  https://repo1.maven.org/maven2/org/mariadb/jdbc/mariadb-java-client/3.4.1/mariadb-java-client-3.4.1.jar
```

**2. Start the stack:**

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

Avoid `ORDER BY` — MariaDB does not support `NULLS LAST` (see Known Limitations below).

```cypher
MATCH (m:Movie) RETURN m.title, m.release_year LIMIT 10

MATCH path = (p:Person)-[:ACTED_IN]->(m:Movie) RETURN path LIMIT 25

MATCH path = (keanu:Person {name: 'Keanu Reeves'})-[:ACTED_IN]->(m:Movie)<-[:ACTED_IN]-(co:Person)
RETURN path
```

## Known limitations

**`ORDER BY` not supported:** NVG generates standard SQL `ORDER BY <col> DESC NULLS LAST` for any ordered query. MariaDB 11 does not implement `NULLS FIRST` / `NULLS LAST` in regular `ORDER BY` clauses (MariaDB 10.6 added it for window functions only). Any Cypher query with `ORDER BY` will fail with:

```
You have an error in your SQL syntax; check the manual that corresponds to your MariaDB
server version for the right syntax to use near 'NULLS LAST\nLIMIT 10'
```

Workaround: avoid `ORDER BY` in Cypher queries against this backend.

**`ANSI_QUOTES` required:** The JDBC URL includes `?sessionVariables=sql_mode=ANSI_QUOTES`. NVG generates double-quoted identifiers (ANSI SQL); without this flag MariaDB silently misinterprets them as string literals.
