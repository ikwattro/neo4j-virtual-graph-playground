# Known Limitations

## MySQL — `ORDER BY ... NULLS LAST` not supported

**Backends affected:** MySQL

**Symptom:**

```
You have an error in your SQL syntax; check the manual that corresponds to your MySQL server
version for the right syntax to use near 'NULLS LAST\nLIMIT 10'
```

**Cause:** NVG generates standard SQL `ORDER BY <col> DESC NULLS LAST` for any ordered query. MySQL has never implemented `NULLS FIRST` / `NULLS LAST` (SQL:2003). The clause is silently supported in MariaDB 10.6+ but not in MySQL 8.x.

**Impact:** Any Cypher query with `ORDER BY` on a nullable column will fail at the SQL layer.

**Workaround:** None at the JDBC URL or NVG config level. Either avoid `ORDER BY` in Cypher queries against this backend, or migrate to MariaDB.

---

## PostgreSQL — boolean columns not supported

**Backends affected:** Any PostgreSQL backend (confirmed on Sakila)

**Symptom:**

```
For input string: "t" under radix 2
```

**Cause:** PostgreSQL represents booleans as `t`/`f` on the wire. NVG's JDBC type mapper attempts to read them as binary integers and fails to parse the string `"t"`.

**Impact:** Any node or relationship property mapped to a PostgreSQL `boolean` column will cause the query to fail.

**Workaround:** Exclude all boolean columns from `schema.json`. Do not map `boolean` columns as node or relationship properties. Affected columns in the Sakila dataset: `customer.activebool`, `customer.active`, `staff.active`.

---

## All backends — multiple relationship types in a single pattern not supported

**Backends affected:** All

**Symptom:** Query returns no results or throws an error.

**Example:**

```cypher
MATCH path = (p:Person)-[:ACTED_IN|DIRECTED]->(m:Movie) RETURN path LIMIT 25
```

**Cause:** NVG maps each relationship type to a specific table. The `|` operator requires a union across multiple tables, which NVG does not currently generate.

**Workaround:** Split into separate queries and union the results in application code, or run them independently:

```cypher
MATCH path = (p:Person)-[:ACTED_IN]->(m:Movie) RETURN path LIMIT 25
MATCH path = (p:Person)-[:DIRECTED]->(m:Movie) RETURN path LIMIT 25
```
