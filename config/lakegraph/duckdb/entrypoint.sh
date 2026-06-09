#!/bin/sh

DB=/data/movies.duckdb

echo "Initializing DuckDB — loading tables from MinIO..."
duckdb "$DB" < /init.sql
echo "Tables ready: movies, genres, movie_genres, people, movie_crew, movie_actors, movie_directors"

echo ""
echo "DuckDB playground is ready."
echo "Connect with:  docker exec -it duckdb-playground duckdb /data/movies.duckdb"
echo ""

exec sleep infinity
