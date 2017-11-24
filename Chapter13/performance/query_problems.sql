-- confuse planner
EXPLAIN SELECT * FROM guru WHERE upper(id::text)::int < 20;

-- generate nested loop issue
EXPLAIN ANALYZE WITH tmp AS (SELECT * FROM guru WHERE id <10000) SELECT * FROM tmp a inner join tmp b on a.id = b.id;
set enable_mergejoin to off ;
set enable_hashjoin to off ;
EXPLAIN ANALYZE WITH tmp AS (SELECT * FROM guru WHERE id <10000) SELECT * FROM tmp a inner join tmp b on a.id = b.id;
EXPLAIN ANALYZE SELECT * FROM guru as a inner join guru b on a.id = b.id WHERE a.id < 10000;
