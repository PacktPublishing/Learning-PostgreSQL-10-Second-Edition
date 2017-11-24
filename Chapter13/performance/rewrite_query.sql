\o /dev/null
\timing

SELECT id, name, (SELECT count(*) FROM success_story where guru_id=id) FROM guru;
WITH counts AS (SELECT count(*), guru_id FROM success_story group by guru_id) SELECT id, name, COALESCE(count,0) FROM guru LEFT JOIN counts on guru_id = id;
SELECT guru.id, name, COALESCE(count(*),0) FROM guru LEFT JOIN success_story on guru_id = guru.id group by guru.id, name ;
SELECT id, name, COALESCE(count,0) FROM guru LEFT JOIN ( SELECT count(*), guru_id FROM success_story group by guru_id )as counts on guru_id = id;
SELECT guru.id, name, count(*) FROM guru LEFT JOIN success_story on guru_id = guru.id group by guru.id, name ;
SELECT id, name, count FROM guru , LATERAL (SELECT count(*) FROM success_story WHERE guru_id=id ) as foo(count);
SELECT id, name, count FROM guru LEFT JOIN LATERAL (SELECT count(*) FROM success_story WHERE guru_id=id ) AS foo ON true;
