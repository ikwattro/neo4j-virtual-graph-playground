# Neo4j Virtual Graph Playground

Docker Compose project that virtualizes relational databases as Neo4j graphs via the Virtual Graphs feature. Each backend is a separate compose overlay.

## Key facts

- **No package.json / Node.js** — pure Docker Compose + JSON/SQL config
- **Active backend** set in `.env` via `COMPOSE_FILE=docker-compose.yml:docker-compose-<name>.yml`
- **Base file** `docker-compose.yml` runs Neo4j enterprise with virtual graphs enabled
- **Config root** `config/<backend-name>/` — one directory per backend

## Adding a backend

Run `/add-backend` — the skill has all templates and dialect-specific patterns baked in. No need to read existing files.

## Existing backends

| Name        | Type         | Compose file                     |
|-------------|--------------|----------------------------------|
| postgres    | Simple JDBC  | docker-compose-postgres.yml      |
| oracle      | Simple JDBC  | docker-compose-oracle.yml        |
| singlestore | Simple JDBC  | docker-compose-singlestore.yml   |
| sakila      | Complex JDBC | docker-compose-sakila.yml        |
| lakegraph   | CSV→DuckDB   | docker-compose-lakegraph.yml     |
| icegraph    | Iceberg→DuckDB | docker-compose-icegraph.yml    |
| pinot       | OLAP cluster | docker-compose-pinot.yml         |
| neo4j       | Remote Neo4j | docker-compose-neo4j.yml         |
| workspaces  | PG workspaces | docker-compose-workspaces.yml   |

## NVG config shape (3 files per backend)

```
config/<name>/nvg-config/
├── datasource.json   # { "type": "generic", "url": "jdbc:..." }
├── secret.json       # { "type": "basic", "username": "...", "password": "..." }
└── schema.json       # catalog + schema + entities (nodes/relationships)
```

JDBC drivers mount to `/var/lib/neo4j/lib/<driver>.jar` inside Neo4j.
