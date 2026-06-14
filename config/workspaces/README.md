# Workspaces

A PostgreSQL backend exposing a workspaces dataset via the PostgreSQL JDBC driver.

## Activate

```dotenv
COMPOSE_FILE=docker-compose.yml:config/workspaces/docker-compose.yml
```

## Properties

| Property | Value |
|----------|-------|
| Image | `postgres:17-alpine` |
| Host port | `5489` |
| Database | `workspaces` |
| User / Password | `workspaces` / `workspaces` |
| JDBC URL | `jdbc:postgresql://postgres-workspaces:5432/workspaces` |
| JDBC driver | `postgresql-42.7.11.jar` (committed, shared from `config/postgres/jdbc/`) |

## Setup

No extra steps — the JDBC driver is committed. Start the stack:

```bash
docker compose up -d
```

## Notes

WAL logical replication is enabled (`wal_level=logical`).

**Boolean columns:** PostgreSQL `boolean` columns cannot be mapped in `schema.json` — NVG's JDBC type mapper cannot handle PostgreSQL's `t`/`f` wire format and will throw `For input string: "t" under radix 2`. Exclude all `boolean` columns from node/relationship property mappings.
