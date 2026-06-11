CREATE TABLE IF NOT EXISTS workspace_nodes
(
    workspace_id VARCHAR(64) NOT NULL,
    record_id    VARCHAR(64) NOT NULL,
    class        VARCHAR(64) NOT NULL,
    properties   JSONB       NOT NULL DEFAULT '{}',
    PRIMARY KEY (workspace_id, record_id)
);

CREATE TABLE IF NOT EXISTS workspace_edges
(
    workspace_id   VARCHAR(64) NOT NULL,
    record_id      VARCHAR(64) NOT NULL,
    type           VARCHAR(64) NOT NULL,
    properties     JSONB       NOT NULL DEFAULT '{}',
    record_id_from VARCHAR(64) NOT NULL,
    record_id_to   VARCHAR(64) NOT NULL,
    PRIMARY KEY (workspace_id, record_id),
    FOREIGN KEY (workspace_id, record_id_from) REFERENCES workspace_nodes (workspace_id, record_id),
    FOREIGN KEY (workspace_id, record_id_to)   REFERENCES workspace_nodes (workspace_id, record_id)
);

-- ============================================================
-- Materialisation function
-- Creates one flat table per node class  : nodes_{class}
-- Creates one flat table per edge type   : edges_{type}
-- workspace_id is always included as a column.
-- Property keys are unioned across all workspaces for that class/type.
-- ============================================================

CREATE OR REPLACE FUNCTION refresh_materialized_tables() RETURNS void
LANGUAGE plpgsql AS $$
DECLARE
    v_class      TEXT;
    v_type       TEXT;
    v_ws_id      TEXT;
    v_ws_safe    TEXT;  -- workspace_id with hyphens replaced: safe for table names
    v_table      TEXT;
    v_view       TEXT;
    v_col_list   TEXT;
    v_sql        TEXT;
BEGIN
    -- ---- NODE TABLES (one per class, all workspaces) --------
    FOR v_class IN
        SELECT DISTINCT class FROM workspace_nodes ORDER BY class
    LOOP
        v_table := 'nodes_' || lower(v_class);

        SELECT string_agg(
                   format('properties->>%L AS %s', k, lower(k)),
                   ', ' ORDER BY k
               )
        INTO   v_col_list
        FROM  (
            SELECT DISTINCT key AS k
            FROM   workspace_nodes, jsonb_object_keys(properties) AS key
            WHERE  class = v_class
        ) keys;

        EXECUTE format('DROP TABLE IF EXISTS %I CASCADE', v_table);
        EXECUTE format(
            'CREATE TABLE %I AS SELECT workspace_id, record_id, %s FROM workspace_nodes WHERE class = %L',
            v_table, v_col_list, v_class
        );
    END LOOP;

    -- ---- EDGE TABLES (one per type, all workspaces) ---------
    FOR v_type IN
        SELECT DISTINCT type FROM workspace_edges ORDER BY type
    LOOP
        v_table := 'edges_' || lower(replace(v_type, ' ', '_'));

        SELECT string_agg(
                   format('properties->>%L AS %s', k, lower(k)),
                   ', ' ORDER BY k
               )
        INTO   v_col_list
        FROM  (
            SELECT DISTINCT key AS k
            FROM   workspace_edges, jsonb_object_keys(properties) AS key
            WHERE  type = v_type
        ) keys;

        EXECUTE format('DROP TABLE IF EXISTS %I CASCADE', v_table);

        IF v_col_list IS NOT NULL THEN
            v_sql := format(
                'CREATE TABLE %I AS SELECT workspace_id, record_id, record_id_from, record_id_to, %s FROM workspace_edges WHERE type = %L',
                v_table, v_col_list, v_type
            );
        ELSE
            v_sql := format(
                'CREATE TABLE %I AS SELECT workspace_id, record_id, record_id_from, record_id_to FROM workspace_edges WHERE type = %L',
                v_table, v_type
            );
        END IF;

        EXECUTE v_sql;
    END LOOP;

    -- ---- WORKSPACE-SCOPED NODE VIEWS ------------------------
    -- For every (workspace_id, class) pair, create a filtered view:
    -- {ws_safe}_nodes_{class}  e.g. ws_techco_nodes_person
    FOR v_ws_id, v_class IN
        SELECT DISTINCT workspace_id, class FROM workspace_nodes ORDER BY workspace_id, class
    LOOP
        v_ws_safe := lower(replace(v_ws_id, '-', '_'));
        v_view    := v_ws_safe || '_nodes_' || lower(v_class);
        v_table   := 'nodes_' || lower(v_class);

        EXECUTE format('DROP VIEW IF EXISTS %I', v_view);
        EXECUTE format(
            'CREATE VIEW %I AS SELECT * FROM %I WHERE workspace_id = %L',
            v_view, v_table, v_ws_id
        );
    END LOOP;

    -- ---- WORKSPACE-SCOPED EDGE VIEWS ------------------------
    -- {ws_safe}_edges_{type}  e.g. ws_techco_edges_works_at
    FOR v_ws_id, v_type IN
        SELECT DISTINCT workspace_id, type FROM workspace_edges ORDER BY workspace_id, type
    LOOP
        v_ws_safe := lower(replace(v_ws_id, '-', '_'));
        v_view    := v_ws_safe || '_edges_' || lower(replace(v_type, ' ', '_'));
        v_table   := 'edges_' || lower(replace(v_type, ' ', '_'));

        EXECUTE format('DROP VIEW IF EXISTS %I', v_view);
        EXECUTE format(
            'CREATE VIEW %I AS SELECT * FROM %I WHERE workspace_id = %L',
            v_view, v_table, v_ws_id
        );
    END LOOP;
END;
$$;

-- ============================================================
-- Workspace 1: ws-movies  (films & people)
-- ============================================================

INSERT INTO workspace_nodes (workspace_id, record_id, class, properties) VALUES

-- People
('ws-movies', 'p-keanu',    'Person', '{"id":"keanu-reeves",    "firstName":"Keanu",    "lastName":"Reeves",    "born":1964}'),
('ws-movies', 'p-carrie',   'Person', '{"id":"carrie-moss",     "firstName":"Carrie",   "lastName":"Moss",      "born":1967}'),
('ws-movies', 'p-laurence', 'Person', '{"id":"laurence-fish",   "firstName":"Laurence", "lastName":"Fishburne", "born":1961}'),
('ws-movies', 'p-hugo',     'Person', '{"id":"hugo-weaving",    "firstName":"Hugo",     "lastName":"Weaving",   "born":1960}'),
('ws-movies', 'p-lana',     'Person', '{"id":"lana-wachowski",  "firstName":"Lana",     "lastName":"Wachowski", "born":1965}'),
('ws-movies', 'p-lilly',    'Person', '{"id":"lilly-wachowski", "firstName":"Lilly",    "lastName":"Wachowski", "born":1967}'),
('ws-movies', 'p-tom',      'Person', '{"id":"tom-hanks",       "firstName":"Tom",      "lastName":"Hanks",     "born":1956}'),
('ws-movies', 'p-robin',    'Person', '{"id":"robin-wright",    "firstName":"Robin",    "lastName":"Wright",    "born":1966}'),
('ws-movies', 'p-gary',     'Person', '{"id":"gary-sinise",     "firstName":"Gary",     "lastName":"Sinise",    "born":1955}'),
('ws-movies', 'p-zemeckis', 'Person', '{"id":"robert-zemeckis", "firstName":"Robert",   "lastName":"Zemeckis",  "born":1951}'),
('ws-movies', 'p-brad',     'Person', '{"id":"brad-pitt",       "firstName":"Brad",     "lastName":"Pitt",      "born":1963}'),
('ws-movies', 'p-edward',   'Person', '{"id":"edward-norton",   "firstName":"Edward",   "lastName":"Norton",    "born":1969}'),
('ws-movies', 'p-fincher',  'Person', '{"id":"david-fincher",   "firstName":"David",    "lastName":"Fincher",   "born":1962}'),

-- Movies
('ws-movies', 'm-matrix',    'Movie', '{"id":"the-matrix",           "title":"The Matrix",           "released":1999, "tagline":"Welcome to the Real World"}'),
('ws-movies', 'm-reloaded',  'Movie', '{"id":"the-matrix-reloaded",  "title":"The Matrix Reloaded",  "released":2003, "tagline":"Free your mind"}'),
('ws-movies', 'm-forrest',   'Movie', '{"id":"forrest-gump",         "title":"Forrest Gump",         "released":1994, "tagline":"Life is like a box of chocolates"}'),
('ws-movies', 'm-castaway',  'Movie', '{"id":"cast-away",            "title":"Cast Away",            "released":2000, "tagline":"At the edge of the world, his journey begins"}'),
('ws-movies', 'm-fightclub', 'Movie', '{"id":"fight-club",           "title":"Fight Club",           "released":1999, "tagline":"Mischief. Mayhem. Soap."}'),

-- Genres
('ws-movies', 'g-action',  'Genre', '{"name":"Action"}'),
('ws-movies', 'g-scifi',   'Genre', '{"name":"Sci-Fi"}'),
('ws-movies', 'g-drama',   'Genre', '{"name":"Drama"}'),
('ws-movies', 'g-thriller','Genre', '{"name":"Thriller"}');

INSERT INTO workspace_edges (workspace_id, record_id, type, properties, record_id_from, record_id_to) VALUES

-- ACTED_IN
('ws-movies', 'e-keanu-matrix',    'ACTED_IN', '{"role":"Neo"}',          'p-keanu',    'm-matrix'),
('ws-movies', 'e-carrie-matrix',   'ACTED_IN', '{"role":"Trinity"}',      'p-carrie',   'm-matrix'),
('ws-movies', 'e-laurence-matrix', 'ACTED_IN', '{"role":"Morpheus"}',     'p-laurence', 'm-matrix'),
('ws-movies', 'e-hugo-matrix',     'ACTED_IN', '{"role":"Agent Smith"}',  'p-hugo',     'm-matrix'),
('ws-movies', 'e-keanu-reload',    'ACTED_IN', '{"role":"Neo"}',          'p-keanu',    'm-reloaded'),
('ws-movies', 'e-carrie-reload',   'ACTED_IN', '{"role":"Trinity"}',      'p-carrie',   'm-reloaded'),
('ws-movies', 'e-laurence-reload', 'ACTED_IN', '{"role":"Morpheus"}',     'p-laurence', 'm-reloaded'),
('ws-movies', 'e-hugo-reload',     'ACTED_IN', '{"role":"Agent Smith"}',  'p-hugo',     'm-reloaded'),
('ws-movies', 'e-tom-forrest',     'ACTED_IN', '{"role":"Forrest Gump"}', 'p-tom',      'm-forrest'),
('ws-movies', 'e-robin-forrest',   'ACTED_IN', '{"role":"Jenny"}',        'p-robin',    'm-forrest'),
('ws-movies', 'e-gary-forrest',    'ACTED_IN', '{"role":"Lt. Dan"}',      'p-gary',     'm-forrest'),
('ws-movies', 'e-tom-castaway',    'ACTED_IN', '{"role":"Chuck Noland"}', 'p-tom',      'm-castaway'),
('ws-movies', 'e-brad-fight',      'ACTED_IN', '{"role":"Tyler Durden"}', 'p-brad',     'm-fightclub'),
('ws-movies', 'e-edward-fight',    'ACTED_IN', '{"role":"The Narrator"}', 'p-edward',   'm-fightclub'),

-- DIRECTED
('ws-movies', 'e-lana-matrix',     'DIRECTED', '{}', 'p-lana',     'm-matrix'),
('ws-movies', 'e-lilly-matrix',    'DIRECTED', '{}', 'p-lilly',    'm-matrix'),
('ws-movies', 'e-lana-reload',     'DIRECTED', '{}', 'p-lana',     'm-reloaded'),
('ws-movies', 'e-lilly-reload',    'DIRECTED', '{}', 'p-lilly',    'm-reloaded'),
('ws-movies', 'e-zemeckis-forrest','DIRECTED', '{}', 'p-zemeckis', 'm-forrest'),
('ws-movies', 'e-zemeckis-cast',   'DIRECTED', '{}', 'p-zemeckis', 'm-castaway'),
('ws-movies', 'e-fincher-fight',   'DIRECTED', '{}', 'p-fincher',  'm-fightclub'),

-- HAS_GENRE
('ws-movies', 'eg-matrix-action',     'HAS_GENRE', '{}', 'm-matrix',    'g-action'),
('ws-movies', 'eg-matrix-scifi',      'HAS_GENRE', '{}', 'm-matrix',    'g-scifi'),
('ws-movies', 'eg-reloaded-action',   'HAS_GENRE', '{}', 'm-reloaded',  'g-action'),
('ws-movies', 'eg-reloaded-scifi',    'HAS_GENRE', '{}', 'm-reloaded',  'g-scifi'),
('ws-movies', 'eg-forrest-drama',     'HAS_GENRE', '{}', 'm-forrest',   'g-drama'),
('ws-movies', 'eg-castaway-drama',    'HAS_GENRE', '{}', 'm-castaway',  'g-drama'),
('ws-movies', 'eg-fightclub-drama',   'HAS_GENRE', '{}', 'm-fightclub', 'g-drama'),
('ws-movies', 'eg-fightclub-thriller','HAS_GENRE', '{}', 'm-fightclub', 'g-thriller');


-- ============================================================
-- Workspace 2: ws-techco  (tech company org graph)
-- ============================================================

INSERT INTO workspace_nodes (workspace_id, record_id, class, properties) VALUES

-- People
('ws-techco', 'p-alice',  'Person',  '{"id":"alice-nguyen",  "firstName":"Alice",  "lastName":"Nguyen",  "title":"Senior Engineer"}'),
('ws-techco', 'p-bob',    'Person',  '{"id":"bob-chen",      "firstName":"Bob",    "lastName":"Chen",    "title":"Software Engineer"}'),
('ws-techco', 'p-carol',  'Person',  '{"id":"carol-smith",   "firstName":"Carol",  "lastName":"Smith",   "title":"Lead Designer"}'),
('ws-techco', 'p-david',  'Person',  '{"id":"david-park",    "firstName":"David",  "lastName":"Park",    "title":"Engineering Manager"}'),
('ws-techco', 'p-emma',   'Person',  '{"id":"emma-wilson",   "firstName":"Emma",   "lastName":"Wilson",  "title":"CTO"}'),
('ws-techco', 'p-frank',  'Person',  '{"id":"frank-torres",  "firstName":"Frank",  "lastName":"Torres",  "title":"DevOps Engineer"}'),
('ws-techco', 'p-grace',  'Person',  '{"id":"grace-kim",     "firstName":"Grace",  "lastName":"Kim",     "title":"Data Engineer"}'),

-- Companies
('ws-techco', 'c-nova',    'Company', '{"id":"nova-tech",    "name":"NovaTech",    "industry":"Software",  "size":"mid"}'),
('ws-techco', 'c-datacorp','Company', '{"id":"data-corp",    "name":"DataCorp",    "industry":"Analytics", "size":"large"}'),
('ws-techco', 'c-pixel',   'Company', '{"id":"pixel-agency", "name":"PixelAgency", "industry":"Design",    "size":"small"}'),

-- Teams
('ws-techco', 't-platform', 'Team', '{"name":"Platform",  "focus":"backend infrastructure"}'),
('ws-techco', 't-design',   'Team', '{"name":"Design",    "focus":"product design & UX"}'),
('ws-techco', 't-data',     'Team', '{"name":"Data",      "focus":"analytics & pipelines"}'),

-- Skills
('ws-techco', 's-python',     'Skill', '{"name":"Python"}'),
('ws-techco', 's-typescript', 'Skill', '{"name":"TypeScript"}'),
('ws-techco', 's-neo4j',      'Skill', '{"name":"Neo4j"}'),
('ws-techco', 's-figma',      'Skill', '{"name":"Figma"}'),
('ws-techco', 's-kubernetes', 'Skill', '{"name":"Kubernetes"}'),
('ws-techco', 's-spark',      'Skill', '{"name":"Apache Spark"}'),

-- Projects
('ws-techco', 'pr-api',       'Project', '{"name":"API Redesign",     "status":"active",    "priority":"high"}'),
('ws-techco', 'pr-dashboard', 'Project', '{"name":"Dashboard v2",     "status":"active",    "priority":"high"}'),
('ws-techco', 'pr-pipeline',  'Project', '{"name":"Data Pipeline",    "status":"active",    "priority":"medium"}'),
('ws-techco', 'pr-infra',     'Project', '{"name":"K8s Migration",    "status":"completed", "priority":"high"}');

INSERT INTO workspace_edges (workspace_id, record_id, type, properties, record_id_from, record_id_to) VALUES

-- WORKS_AT
('ws-techco', 'e-alice-nova',  'WORKS_AT', '{"since":2021}', 'p-alice', 'c-nova'),
('ws-techco', 'e-bob-nova',    'WORKS_AT', '{"since":2022}', 'p-bob',   'c-nova'),
('ws-techco', 'e-carol-nova',  'WORKS_AT', '{"since":2021}', 'p-carol', 'c-nova'),
('ws-techco', 'e-david-nova',  'WORKS_AT', '{"since":2020}', 'p-david', 'c-nova'),
('ws-techco', 'e-emma-nova',   'WORKS_AT', '{"since":2019}', 'p-emma',  'c-nova'),
('ws-techco', 'e-frank-nova',  'WORKS_AT', '{"since":2022}', 'p-frank', 'c-nova'),
('ws-techco', 'e-grace-nova',  'WORKS_AT', '{"since":2023}', 'p-grace', 'c-nova'),

-- MEMBER_OF (team membership)
('ws-techco', 'e-alice-platform',  'MEMBER_OF', '{"role":"senior engineer"}', 'p-alice', 't-platform'),
('ws-techco', 'e-bob-platform',    'MEMBER_OF', '{"role":"engineer"}',        'p-bob',   't-platform'),
('ws-techco', 'e-frank-platform',  'MEMBER_OF', '{"role":"devops engineer"}', 'p-frank', 't-platform'),
('ws-techco', 'e-david-platform',  'MEMBER_OF', '{"role":"manager"}',         'p-david', 't-platform'),
('ws-techco', 'e-carol-design',    'MEMBER_OF', '{"role":"lead designer"}',   'p-carol', 't-design'),
('ws-techco', 'e-grace-data',      'MEMBER_OF', '{"role":"data engineer"}',   'p-grace', 't-data'),
('ws-techco', 'e-emma-platform',   'MEMBER_OF', '{"role":"sponsor"}',         'p-emma',  't-platform'),

-- HAS_SKILL
('ws-techco', 'e-alice-python', 'HAS_SKILL', '{"level":"expert"}',        'p-alice', 's-python'),
('ws-techco', 'e-alice-ts',     'HAS_SKILL', '{"level":"advanced"}',      'p-alice', 's-typescript'),
('ws-techco', 'e-alice-neo4j',  'HAS_SKILL', '{"level":"intermediate"}',  'p-alice', 's-neo4j'),
('ws-techco', 'e-bob-ts',       'HAS_SKILL', '{"level":"expert"}',        'p-bob',   's-typescript'),
('ws-techco', 'e-bob-k8s',      'HAS_SKILL', '{"level":"advanced"}',      'p-bob',   's-kubernetes'),
('ws-techco', 'e-carol-figma',  'HAS_SKILL', '{"level":"expert"}',        'p-carol', 's-figma'),
('ws-techco', 'e-carol-ts',     'HAS_SKILL', '{"level":"intermediate"}',  'p-carol', 's-typescript'),
('ws-techco', 'e-emma-python',  'HAS_SKILL', '{"level":"advanced"}',      'p-emma',  's-python'),
('ws-techco', 'e-emma-neo4j',   'HAS_SKILL', '{"level":"expert"}',        'p-emma',  's-neo4j'),
('ws-techco', 'e-frank-k8s',    'HAS_SKILL', '{"level":"expert"}',        'p-frank', 's-kubernetes'),
('ws-techco', 'e-grace-python', 'HAS_SKILL', '{"level":"advanced"}',      'p-grace', 's-python'),
('ws-techco', 'e-grace-spark',  'HAS_SKILL', '{"level":"expert"}',        'p-grace', 's-spark'),

-- WORKS_ON (project assignment)
('ws-techco', 'e-alice-api',       'WORKS_ON', '{}', 'p-alice', 'pr-api'),
('ws-techco', 'e-bob-api',         'WORKS_ON', '{}', 'p-bob',   'pr-api'),
('ws-techco', 'e-carol-dashboard', 'WORKS_ON', '{}', 'p-carol', 'pr-dashboard'),
('ws-techco', 'e-alice-dashboard', 'WORKS_ON', '{}', 'p-alice', 'pr-dashboard'),
('ws-techco', 'e-grace-pipeline',  'WORKS_ON', '{}', 'p-grace', 'pr-pipeline'),
('ws-techco', 'e-bob-infra',       'WORKS_ON', '{}', 'p-bob',   'pr-infra'),
('ws-techco', 'e-frank-infra',     'WORKS_ON', '{}', 'p-frank', 'pr-infra'),

-- MANAGES
('ws-techco', 'e-david-api',       'MANAGES', '{}', 'p-david', 'pr-api'),
('ws-techco', 'e-david-dashboard', 'MANAGES', '{}', 'p-david', 'pr-dashboard'),
('ws-techco', 'e-emma-pipeline',   'MANAGES', '{}', 'p-emma',  'pr-pipeline'),

-- PARTNER_OF / CLIENT_OF
('ws-techco', 'e-nova-pixel',    'PARTNER_OF', '{"since":2022}', 'c-nova', 'c-pixel'),
('ws-techco', 'e-datacorp-nova', 'CLIENT_OF',  '{"since":2021}', 'c-datacorp', 'c-nova');

-- ============================================================
-- Materialise flat tables from the generic store
-- ============================================================
SELECT refresh_materialized_tables();

