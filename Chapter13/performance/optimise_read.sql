\h EXPLAIN
CREATE TABLE guru ( id INT PRIMARY KEY, name TEXT NOT NULL );
INSERT INTO guru SELECT n , md5 (random()::text) FROM generate_series (1, 100000) AS foo(n);
ANALYSE guru;
EXPLAIN SELECT * FROM guru;
ELECT relpages*current_setting('seq_page_cost')::numeric + reltuples*current_setting('cpu_tuple_cost')::numeric as cost FROM pg_class WHERE relname='guru';
EXPLAIN ANALYZE SELECT * FROM guru WHERE id >= 10 and id < 20;
EXPLAIN (ANALYZE, FORMAT YAML, BUFFERS) SELECT * FROM guru;
EXPLAIN (ANALYZE, FORMAT YAML, BUFFERS) SELECT * FROM guru;