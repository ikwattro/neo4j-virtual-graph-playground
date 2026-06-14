# Neo4j Virtual Graph Playground

Docker Compose project that virtualizes relational databases as Neo4j graphs via the Virtual Graphs feature. Each backend is a separate compose overlay.

## Key facts

- **No package.json / Node.js** — pure Docker Compose + JSON/SQL config
- **Active backend** set in `.env` via `COMPOSE_FILE=docker-compose.yml:config/<name>/docker-compose.yml`
- **Base file** `docker-compose.yml` runs Neo4j enterprise with virtual graphs enabled
- **Config root** `config/<backend-name>/` — one directory per backend

## Adding a backend

Run `/add-backend` — the skill has all templates and dialect-specific patterns baked in. No need to read existing files.

## Existing backends

| Name        | Type           | Compose file                           |
|-------------|----------------|----------------------------------------|
| postgres    | Simple JDBC    | config/postgres/docker-compose.yml     |
| oracle      | Simple JDBC    | config/oracle/docker-compose.yml       |
| singlestore | Simple JDBC    | config/singlestore/docker-compose.yml  |
| sakila      | Complex JDBC   | config/sakila/docker-compose.yml       |
| lakegraph   | CSV→DuckDB     | config/lakegraph/docker-compose.yml    |
| icegraph    | Iceberg→DuckDB | config/icegraph/docker-compose.yml     |
| pinot       | OLAP cluster   | config/pinot/docker-compose.yml        |
| neo4j       | Remote Neo4j   | config/neo4j/docker-compose.yml        |
| workspaces  | PG workspaces  | config/workspaces/docker-compose.yml   |

## NVG config shape (3 files per backend)

```
config/<name>/nvg-config/
├── datasource.json   # { "type": "generic", "url": "jdbc:..." }
├── secret.json       # { "type": "basic", "username": "...", "password": "..." }
└── schema.json       # catalog + schema + entities (nodes/relationships)
```

JDBC drivers mount to `/var/lib/neo4j/lib/<driver>.jar` inside Neo4j.
