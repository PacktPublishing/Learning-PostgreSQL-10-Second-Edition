SELECT table_catalog, table_schema, table_name
FROM
  information_schema.tables
WHERE
table_schema NOT IN ('information_schema','pg_catalog')
EXCEPT
SELECT
  table_catalog, table_schema, table_name
FROM
  information_schema.table_constraints
WHERE
  constraint_type IN ('PRIMARY KEY', 'UNIQUE') AND table_schema NOT IN ('information_schema', 'pg_catalog');