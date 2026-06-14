# IceGraph

The most advanced backend. IceGraph demonstrates a proper modern data lake stack — the movies dataset is stored as **Apache Iceberg tables** (Parquet data files + Iceberg metadata) in MinIO. DuckDB reads them natively via its `iceberg` extension and exposes them through Neo4j Virtual Graphs.

```
Pre-built Apache Iceberg warehouse (committed to the repo)
    ↓  uploaded to MinIO by minio-mc on startup
MinIO (S3-compatible object storage)
    ↓  iceberg_scan() via DuckDB iceberg extension
DuckDB (embedded, file-based)
    ↓  read via JDBC driver (shared Docker volume)
Neo4j Virtual Graphs
    ↓  queried with Cypher
You
```

The Iceberg warehouse (Parquet data files + Avro manifests + metadata JSON) is pre-generated and committed under `config/icegraph/warehouse/`. No runtime init container or catalog service is needed — `minio-mc` uploads the warehouse tree on startup and DuckDB reads it directly.

## Activate

```dotenv
COMPOSE_FILE=docker-compose.yml:config/icegraph/docker-compose.yml
```

## Setup

**1. Download the DuckDB JDBC driver:**

The driver is stored in `config/lakegraph/jdbc/` and shared between LakeGraph and IceGraph.

```bash
curl -L -o config/lakegraph/jdbc/duckdb_jdbc-1.5.3.0.jar \
  https://repo1.maven.org/maven2/org/duckdb/duckdb_jdbc/1.5.3.0/duckdb_jdbc-1.5.3.0.jar
```

**2. Start the stack:**

```bash
docker compose up --build -d
```

> Use `--build` any time you change files under `config/icegraph/duckdb/` — Docker won't rebuild the DuckDB image otherwise.

## Startup sequence

1. **MinIO** starts and passes its healthcheck
2. **minio-mc** uploads the full Iceberg warehouse to the `iceberg-data` bucket, then exits
3. **DuckDB** waits for mc to complete, reads 7 Iceberg tables via `iceberg_scan`, and materializes them to `movies.duckdb`
4. **Neo4j** waits for DuckDB's healthcheck (file exists), then mounts the volume and boots

## Services

| Service | Port | Credentials |
|---------|------|-------------|
| MinIO API | `9000` | `minio` / `hellopassword` |
| MinIO Console | `9001` | `minio` / `hellopassword` |
| DuckDB CLI | — | `docker exec -it duckdb-icegraph-playground duckdb /data/movies.duckdb` |

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
| `ACTED_IN` | `movie_actors` | has `character` property |
| `DIRECTED` | `movie_directors` | |
| `IN_GENRE` | `movie_genres` | junction table |

## Sample queries

```cypher
// All paths through the graph
MATCH path = (p:Person)-[:ACTED_IN]->(m:Movie)-[:IN_GENRE]->(g:Genre)
RETURN path LIMIT 25

// 3-hop path: actor → shared movie ← co-actor → another movie
MATCH path = (p:Person)-[:ACTED_IN]->(m:Movie)<-[:ACTED_IN]-(co:Person)-[:ACTED_IN]->(m2:Movie)
WHERE p <> co AND m <> m2
RETURN p.name AS actor, m.title AS shared_movie, co.name AS co_actor, m2.title AS other_movie
LIMIT 10

// Directors and their genres
MATCH (p:Person)-[:DIRECTED]->(m:Movie)-[:IN_GENRE]->(g:Genre)
RETURN p.name, collect(DISTINCT g.name) AS genres
```

## Exploring DuckDB directly

```bash
docker exec -it duckdb-icegraph-playground duckdb /data/movies.duckdb
```

```sql
SHOW TABLES;
SELECT title, revenue_usd FROM movies ORDER BY revenue_usd DESC LIMIT 5;
-- The underlying Parquet files are in MinIO — browse them at http://localhost:9001
```

## Regenerating the warehouse

The Iceberg warehouse is pre-built and committed to the repo. If you need to regenerate it (e.g. after changing the source CSVs), install PyIceberg in a temporary environment and run the script below from the **repo root**:

```bash
python3 -m venv /tmp/iceberg-gen
/tmp/iceberg-gen/bin/pip install "pyiceberg[sql-sqlite,pyarrow]" pyarrow
/tmp/iceberg-gen/bin/python3 - <<'EOF'
import os, shutil, pyarrow.csv as pcsv, pyarrow.compute as pc
from pyiceberg.catalog import load_catalog
from pyiceberg.schema import Schema
from pyiceberg.types import NestedField, StringType, LongType
import pyarrow as pa

WAREHOUSE = os.path.abspath("config/icegraph/warehouse")
if os.path.exists(WAREHOUSE):
    shutil.rmtree(WAREHOUSE)
os.makedirs(WAREHOUSE)

catalog = load_catalog("local", **{
    "type": "sql",
    "uri": f"sqlite:///{WAREHOUSE}/iceberg_catalog.db",
    "warehouse": f"file://{WAREHOUSE}",
})
catalog.create_namespace("movies")

def iceberg_schema(pa_schema):
    fields = []
    for i, f in enumerate(pa_schema, 1):
        t = LongType() if pa.types.is_int64(f.type) or pa.types.is_int32(f.type) else StringType()
        fields.append(NestedField(i, f.name, t, required=False))
    return Schema(*fields)

def write(df, name):
    t = catalog.create_table(f"movies.{name}", schema=iceberg_schema(df.schema))
    t.overwrite(df)
    print(f"  {name}: {len(df)} rows")

crew = pcsv.read_csv("config/minio/movie_crew.csv")
write(pcsv.read_csv("config/minio/movies.csv"),      "movies")
write(pcsv.read_csv("config/minio/genres.csv"),      "genres")
write(pcsv.read_csv("config/minio/movie_genres.csv"),"movie_genres")
write(pcsv.read_csv("config/minio/people.csv"),      "people")
write(crew,                                           "movie_crew")
write(crew.filter(pc.equal(crew["role"],"Actor")).select(["movie_id","person_id","character_name"]), "movie_actors")
write(crew.filter(pc.equal(crew["role"],"Director")).select(["movie_id","person_id"]),               "movie_directors")
EOF

# Add version-hint.text and v1.metadata.json aliases for DuckDB compatibility
for table in movies genres movie_genres people movie_crew movie_actors movie_directors; do
  dir="config/icegraph/warehouse/movies/${table}/metadata"
  printf "1" > "${dir}/version-hint.text"
  cp "${dir}"/00001-*.metadata.json "${dir}/v1.metadata.json"
done
rm -f config/icegraph/warehouse/iceberg_catalog.db
```

## Known limitations

**Multiple relationship types in a single pattern not supported:** The `|` operator in `MATCH` patterns (e.g. `[:ACTED_IN|DIRECTED]`) returns no results — NVG maps each relationship type to a specific table and does not generate the required SQL union. Run separate queries instead.
