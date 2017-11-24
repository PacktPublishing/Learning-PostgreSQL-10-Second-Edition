CREATE TABLE test_view_dep AS SELECT 1;
CREATE VIEW a AS SELECT 1 FROM test_view_dep;
CREATE VIEW b AS SELECT 1 FROM a;
CREATE VIEW c AS SELECT 1 FROM a;
CREATE VIEW d AS SELECT 1 FROM b,c;
CREATE VIEW e AS SELECT 1 FROM c;
CREATE VIEW f AS SELECT 1 FROM d,c;

CREATE OR REPLACE FUNCTION get_dependency (schema_name text, view_name text) RETURNS TABLE (schema_name text, view_name text, level int) AS $$
WITH RECURSIVE view_tree(parent_schema, parent_view, child_schema, child_view, level) as
(
    SELECT parent.view_schema, parent.view_name ,parent.table_schema, parent.table_name, 1
    FROM information_schema.view_table_usage parent
    WHERE parent.view_schema = $1 AND parent.view_name = $2
    UNION ALL
    SELECT child.view_schema, child.view_name, child.table_schema, child.table_name, parent.level + 1
    FROM view_tree parent JOIN information_schema.view_table_usage child ON child.table_schema = parent.parent_schema AND child.table_name = parent.parent_view
)
SELECT DISTINCT
    parent_schema, parent_view, level
FROM (
  SELECT parent_schema, parent_view, max (level) OVER (PARTITION BY parent_schema, parent_view) as max_level,level
  FROM view_tree) AS FOO
WHERE level = max_level
ORDER BY 3 ASC;
$$
LANGUAGE SQL;

SELECT * FROM get_dependency('public', 'a');
