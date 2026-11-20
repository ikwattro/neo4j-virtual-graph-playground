# Microsoft Fabric

[Microsoft Fabric](https://learn.microsoft.com/fabric/data-warehouse/data-warehousing) Data Warehouse backend exposing the classic movies graph through the SQL Server JDBC driver and an Entra service principal.

Unlike the other backends there's no database container here. You need your own Fabric capacity (F2 is enough), and it bills while it runs.

## Activate

```dotenv
COMPOSE_FILE=docker-compose.yml:config/fabric/docker-compose.yml
```

## Properties

| Property | Value |
|----------|-------|
| Database | Fabric Warehouse named `nvg` |
| Auth | Entra service principal (client id / secret) |
| JDBC URL | `jdbc:sqlserver://<sql-endpoint>:1433;database=nvg;encrypt=true;authentication=ActiveDirectoryServicePrincipal` |
| JDBC driver | `mssql-jdbc-12.8.1.jre11.jar` (shared with the `sqlserver` backend). `msal4j`, which it needs for Entra auth, already ships with Neo4j. |

## Setup

1. Create a Warehouse named `nvg` in a workspace on your capacity. The name matters, it's the `catalog` in `schema.json`.

2. Run [`init.sql`](init.sql) against it, either in the Fabric query editor or with sqlcmd.

3. Create a service principal and give it access to the workspace:

   ```bash
   az ad sp create-for-rbac --display-name nvg-fabric
   ```

   Add it as `Contributor` under *Manage access* in the workspace. The tenant setting *Service principals can use Fabric APIs* has to allow it.

4. Fill in the connection details. Both files are git-ignored:

   ```bash
   cp config/fabric/nvg-config/datasource.json.template config/fabric/nvg-config/datasource.json
   cp config/fabric/nvg-config/secret.json.template config/fabric/nvg-config/secret.json
   ```

   The SQL endpoint is under the Warehouse's *SQL connection string*. In `secret.json`, the service principal's `appId` is the username and its `password` is the password.

5. Start the stack:

   ```bash
   docker compose up -d
   ```

Neo4j connects to Fabric at boot and won't start if the capacity is paused.

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

Avoid `LIMIT` and `ORDER BY` (see Known limitations below).

```cypher
MATCH (m:Movie) RETURN count(m)

MATCH path = (keanu:Person {name: 'Keanu Reeves'})-[:ACTED_IN]->(m:Movie)<-[:ACTED_IN]-(co:Person)
RETURN path

MATCH (p:Person)-[:ACTED_IN]->(m:Movie)
RETURN p.name, count(m) AS movies
```

## Known limitations

Fabric speaks T-SQL, so it has the same problems as the `sqlserver` backend with NVG's `Default` dialect:

**`LIMIT` not supported:** fails with `Incorrect syntax near 'LIMIT'.`

**`ORDER BY` not supported:** NVG adds `NULLS LAST` or `NULLS FIRST`, which fails with `Incorrect syntax near 'NULLS'.`

To sort or limit anyway, do it in Neo4j after a `collect`/`UNWIND`:

```cypher
MATCH (p:Person)-[:ACTED_IN]->(m:Movie)
WITH p.name AS name, count(m) AS movies
WITH collect({name: name, movies: movies}) AS rows
UNWIND rows AS r
RETURN r.name, r.movies ORDER BY r.movies DESC LIMIT 5
```

**Case-sensitive by default:** new warehouses use the `Latin1_General_100_BIN2_UTF8` collation, so column names in `schema.json` have to match the DDL exactly (that's why they're lowercase here) and `{name: 'keanu reeves'}` won't match.
