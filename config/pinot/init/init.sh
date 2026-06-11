#!/bin/bash
set -e

CONTROLLER="http://pinot-controller:9000"

echo "==> Waiting for Pinot controller at ${CONTROLLER}..."
until curl -sf "${CONTROLLER}/health" > /dev/null; do
  sleep 3
done
echo "    Controller ready."

echo "==> Waiting for Pinot broker at http://pinot-broker:8099..."
until curl -sf "http://pinot-broker:8099/health" > /dev/null; do
  sleep 3
done
echo "    Broker ready."

echo "==> Enabling multi-stage query engine cluster-wide..."
curl -sf -X POST "${CONTROLLER}/cluster/configs" \
  -H 'Content-Type: application/json' \
  -d '{"pinot.multistage.engine.enabled":"true"}' > /dev/null || true
echo "    MSE enabled."

# Idempotency guard — if the movies table already has segments, we already seeded.
if curl -sf "${CONTROLLER}/segments/movies" 2>/dev/null | grep -q "OFFLINE"; then
  echo "==> Data already loaded, skipping seed."
  exit 0
fi

echo "==> Deriving movie_actors and movie_directors from movie_crew.csv..."
mkdir -p /tmp/derived

awk -F',' 'NR==1 { print "movie_id,person_id,character_name" }
           NR>1  && $3=="Actor" { print $1","$2","$4 }' \
  /csv/movie_crew.csv > /tmp/derived/movie_actors.csv

awk -F',' 'NR==1 { print "movie_id,person_id" }
           NR>1  && $3=="Director" { print $1","$2 }' \
  /csv/movie_crew.csv > /tmp/derived/movie_directors.csv

echo "    Derived $(( $(wc -l < /tmp/derived/movie_actors.csv) - 1 )) actor rows."
echo "    Derived $(( $(wc -l < /tmp/derived/movie_directors.csv) - 1 )) director rows."

echo "==> Creating Pinot schemas..."
for schema in /schemas/*.json; do
  name=$(basename "$schema" _schema.json)
  echo "    Schema: ${name}"
  curl -sf -X POST "${CONTROLLER}/schemas" \
    -H 'Content-Type: application/json' \
    --data-binary "@${schema}" > /dev/null
done

echo "==> Creating Pinot tables..."
for table in /tables/*.json; do
  name=$(basename "$table" _table.json)
  echo "    Table: ${name}"
  curl -sf -X POST "${CONTROLLER}/tables" \
    -H 'Content-Type: application/json' \
    --data-binary "@${table}" > /dev/null
done

echo "==> Running batch ingestion jobs..."
for job in /ingestion/*.json; do
  name=$(basename "$job" _job.json)
  echo "    Ingesting: ${name}"
  /opt/pinot/bin/pinot-admin.sh LaunchDataIngestionJob \
    -jobSpecFile "${job}"
done

echo "==> Pinot seed complete."
