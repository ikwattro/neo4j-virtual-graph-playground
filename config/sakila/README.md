# Sakila

The [Sakila dataset](https://github.com/sakiladb/postgres) is a DVD rental store — customers, films, inventory, staff, stores, addresses. The graph model covers 12 node types and 16 relationship types, making it a good intermediate step up from the simple movies graph backends.

## Activate

```dotenv
COMPOSE_FILE=docker-compose.yml:config/sakila/docker-compose.yml
```

## Properties

| Property | Value |
|----------|-------|
| Image | `sakiladb/postgres:latest` |
| Host port | `5489` |
| Database | `sakila` |
| User / Password | `sakila` / `p_ssW0rd` |
| JDBC URL | `jdbc:postgresql://sakila-vg:5432/sakila` |
| JDBC driver | `postgresql-42.7.11.jar` (committed, shared from `config/postgres/jdbc/`) |

## Setup

No extra steps — the image ships pre-populated with the Sakila dataset. Start the stack:

```bash
docker compose up -d
```

## Graph model

```
(Actor)-[:ACTED_IN]->(Film)-[:IN_CATEGORY]->(Category)
(Customer)-[:MADE]->(Rental)-[:RENTS]->(Inventory)-[:COPY_OF]->(Film)
(Customer)-[:HAS_ADDRESS]->(Address)-[:IN_CITY]->(City)-[:IN_COUNTRY]->(Country)
(Store)-[:MANAGED_BY]->(Staff)-[:WORKS_AT]->(Store)
```

<details>
<summary>Full relationship table</summary>

| Relationship | Mapped from |
|---|---|
| `(Actor)-[:ACTED_IN]->(Film)` | `film_actor` junction table |
| `(Film)-[:IN_CATEGORY]->(Category)` | `film_category` junction table |
| `(Film)-[:IN_LANGUAGE]->(Language)` | `film.language_id` FK |
| `(Inventory)-[:COPY_OF]->(Film)`, `(Inventory)-[:IN_STORE]->(Store)` | `inventory` FKs |
| `(Customer)-[:MADE]->(Rental)-[:RENTS]->(Inventory)` | `rental` FKs |
| `(Rental)-[:PROCESSED_BY]->(Staff)` | `rental.staff_id` FK |
| `(Customer/Store/Staff)-[:HAS_ADDRESS]->(Address)` | respective table FKs |
| `(Address)-[:IN_CITY]->(City)-[:IN_COUNTRY]->(Country)` | `address`, `city` FKs |
| `(Store)-[:MANAGED_BY]->(Staff)`, `(Staff)-[:WORKS_AT]->(Store)` | `store`, `staff` FKs |
| `(Customer)-[:SHOPS_AT]->(Store)` | `customer.store_id` FK |

</details>

## Sample queries

```cypher
// Rental journey: who rented what film in which category
MATCH p = (c:Customer)-[:MADE]->(r:Rental)-[:RENTS]->(inv:Inventory)-[:COPY_OF]->(f:Film)-[:IN_CATEGORY]->(cat:Category)
RETURN p LIMIT 10

// Actor → Film → Language chain
MATCH p = (a:Actor)-[:ACTED_IN]->(f:Film)-[:IN_LANGUAGE]->(lang:Language)
RETURN p LIMIT 10
```

## Known limitations

**Boolean columns not supported:** PostgreSQL `boolean` columns cannot be mapped in `schema.json` — NVG's JDBC type mapper cannot handle PostgreSQL's `t`/`f` wire format and will throw `For input string: "t" under radix 2`. The Sakila columns `customer.activebool`, `customer.active`, and `staff.active` are excluded from the schema for this reason.

**Multiple relationship types in a single pattern not supported:** The `|` operator in `MATCH` patterns (e.g. `[:ACTED_IN|DIRECTED]`) returns no results — NVG maps each relationship type to a specific table and does not generate the required SQL union. Run separate queries instead.
