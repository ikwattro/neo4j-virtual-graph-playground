LOAD httpfs;
LOAD iceberg;

CREATE OR REPLACE SECRET minio (
    TYPE S3,
    KEY_ID 'minio',
    SECRET 'hellopassword',
    ENDPOINT 'minio:9000',
    USE_SSL false,
    URL_STYLE 'path',
    REGION 'us-east-1'
);


CREATE OR REPLACE TABLE movies          AS SELECT * FROM iceberg_scan('s3://iceberg-data/movies/movies',          allow_moved_paths=true);
CREATE OR REPLACE TABLE genres          AS SELECT * FROM iceberg_scan('s3://iceberg-data/movies/genres',          allow_moved_paths=true);
CREATE OR REPLACE TABLE movie_genres    AS SELECT * FROM iceberg_scan('s3://iceberg-data/movies/movie_genres',    allow_moved_paths=true);
CREATE OR REPLACE TABLE people          AS SELECT * FROM iceberg_scan('s3://iceberg-data/movies/people',          allow_moved_paths=true);
CREATE OR REPLACE TABLE movie_crew      AS SELECT * FROM iceberg_scan('s3://iceberg-data/movies/movie_crew',      allow_moved_paths=true);
CREATE OR REPLACE TABLE movie_actors    AS SELECT * FROM iceberg_scan('s3://iceberg-data/movies/movie_actors',    allow_moved_paths=true);
CREATE OR REPLACE TABLE movie_directors AS SELECT * FROM iceberg_scan('s3://iceberg-data/movies/movie_directors', allow_moved_paths=true);
