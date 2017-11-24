\timing
\o /dev/null
SELECT * FROM guru;
SELECT DISTINCT * FROM guru;
SELECT * FROM guru UNION SELECT * FROM guru;
SELECT DISTINCT * FROM guru UNION SELECT DISTINCT * FROM guru;

CREATE OR REPLACE VIEW guru_vw AS SELECT * FROM guru order by 1 asc;
SELECT * FROM guru_vw;

--SELECT guru.id, name, COALESCE(count(*),0) FROM guru LEFT JOIN success_story on guru_id = guru.id group by guru.id, name ;