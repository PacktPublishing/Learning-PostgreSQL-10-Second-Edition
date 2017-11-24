
SELECT schemaname, relname, indexrelname FROM pg_stat_user_indexes s JOIN pg_index i ON s.indexrelid = i.indexrelid WHERE idx_scan=0 AND NOT indisunique AND NOT indisprimary;

CREATE TABLE test_index_overlap(a int, b int);
CREATE INDEX ON test_index_overlap (a,b);
CREATE INDEX ON test_index_overlap (b,a);

WITH index_info AS (
SELECT
    pg_get_indexdef(indexrelid) AS index_def,
    indexrelid::regclass
    index_name ,
    indrelid::regclass table_name, array_agg(attname order by attnum) AS index_att
 FROM
     pg_index i JOIN
     pg_attribute a ON i.indexrelid = a.attrelid
GROUP BY
    pg_get_indexdef(indexrelid), indrelid, indexrelid
 ) SELECT DISTINCT
    CASE WHEN a.index_name > b.index_name THEN a.index_def ELSE b.index_def END AS index_def,
    CASE WHEN a.index_name > b.index_name THEN a.index_name ELSE b.index_name END AS index_name,
    CASE WHEN a.index_name > b.index_name THEN b.index_def ELSE a.index_def END AS overlap_index_def,
    CASE WHEN a.index_name > b.index_name THEN b.index_name ELSE a.index_name END AS overlap_index_name,
    a.index_att = b.index_att as full_match,
    a.table_name
 FROM
     index_info a INNER JOIN
    index_info b ON (a.index_name != b.index_name AND a.table_name = b.table_name AND a.index_att && b.index_att );

