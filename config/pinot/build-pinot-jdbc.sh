#!/usr/bin/env bash
set -e
cd "$(dirname "$0")"

JAR_OUT="jdbc/pinot-jdbc-client-1.3.0.jar"

if [ -f "$JAR_OUT" ]; then
  echo "JAR already exists at ${JAR_OUT} — delete it first to rebuild."
  exit 0
fi

echo "Building Pinot JDBC fat jar via Docker + Maven..."
echo "(First run downloads ~300 MB of Maven dependencies — subsequent runs use the cache.)"

docker run --rm \
  -v "$(pwd)/build:/build" \
  -v "$(pwd)/jdbc:/output" \
  -v "pinot-jdbc-m2-cache:/root/.m2" \
  maven:3.9-eclipse-temurin-21 \
  sh -c "cd /build && mvn package -q && cp target/pinot-jdbc-shaded-1.0.jar /output/pinot-jdbc-client-1.3.0.jar"

echo ""
echo "Done → ${JAR_OUT}"
echo "You can now run: docker compose up"
