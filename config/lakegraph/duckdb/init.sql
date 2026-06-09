LOAD httpfs;
CREATE OR REPLACE SECRET minio (
    TYPE S3,
    KEY_ID 'minio',
    SECRET 'hellopassword',
    ENDPOINT 'minio:9000',
    USE_SSL false,
    URL_STYLE 'path',
    REGION 'us-east-1'
);

-- Materialize CSVs from MinIO as physical tables so JDBC reads need no httpfs
CREATE OR REPLACE TABLE movies AS
    SELECT * FROM read_csv_auto('s3://movies-data/movies.csv', header=true);

CREATE OR REPLACE TABLE genres AS
    SELECT * FROM read_csv_auto('s3://movies-data/genres.csv', header=true);

CREATE OR REPLACE TABLE movie_genres AS
    SELECT * FROM read_csv_auto('s3://movies-data/movie_genres.csv', header=true);

CREATE OR REPLACE TABLE people AS
    SELECT * FROM read_csv_auto('s3://movies-data/people.csv', header=true);

CREATE OR REPLACE TABLE movie_crew AS
    SELECT * FROM read_csv_auto('s3://movies-data/movie_crew.csv', header=true);

-- Derived tables so ACTED_IN and DIRECTED can be separate graph relationships
CREATE OR REPLACE TABLE movie_actors AS
    SELECT movie_id, person_id, character_name FROM movie_crew WHERE role = 'Actor';

CREATE OR REPLACE TABLE movie_directors AS
    SELECT movie_id, person_id FROM movie_crew WHERE role = 'Director';
