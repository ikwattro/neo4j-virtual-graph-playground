# MySQL

[MySQL](https://www.mysql.com/) is the world's most widely deployed open-source relational database. This backend exposes the classic movies graph via the MySQL Connector/J JDBC driver.

## Activate

```dotenv
COMPOSE_FILE=docker-compose.yml:config/mysql/docker-compose.yml
```

## Properties

| Property | Value |
|----------|-------|
| Image | `mysql:8.4` |
| Host port | `3388` |
| Database | `nvg` |
| User / Password | `nvg` / `nvg` |
| JDBC URL | `jdbc:mysql://mysql-vg:3306/nvg?sessionVariables=sql_mode=ANSI_QUOTES` |
| JDBC driver | `mysql-connector-j-9.1.0.jar` (not committed — download below) |

## Setup

**1. Download the JDBC driver:**

```bash
curl -L -o config/mysql/jdbc/mysql-connector-j-9.1.0.jar \
  https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/9.1.0/mysql-connector-j-9.1.0.jar
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

Avoid `ORDER BY` — MySQL does not support `NULLS LAST` (see Known Limitations below).

```cypher
MATCH (m:Movie) RETURN m.title, m.release_year LIMIT 10

MATCH path = (p:Person)-[:ACTED_IN]->(m:Movie) RETURN path LIMIT 25

MATCH path = (keanu:Person {name: 'Keanu Reeves'})-[:ACTED_IN]->(m:Movie)<-[:ACTED_IN]-(co:Person)
RETURN path
```

## Known limitations

**`ORDER BY` not supported:** NVG generates standard SQL `ORDER BY <col> DESC NULLS LAST` for any ordered query. MySQL 8.x does not implement `NULLS FIRST` / `NULLS LAST` (SQL:2003) in regular `ORDER BY` clauses. Any Cypher query with `ORDER BY` will fail with:

```
You have an error in your SQL syntax; check the manual that corresponds to your MySQL
server version for the right syntax to use near 'NULLS LAST\nLIMIT 10'
```

Workaround: avoid `ORDER BY` in Cypher queries against this backend.

**`ANSI_QUOTES` required:** The JDBC URL includes `?sessionVariables=sql_mode=ANSI_QUOTES`. NVG generates double-quoted identifiers (ANSI SQL); without this flag MySQL silently misinterprets them as string literals.
