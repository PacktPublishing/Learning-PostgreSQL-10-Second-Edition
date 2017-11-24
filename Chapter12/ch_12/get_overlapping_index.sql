SELECT
 conrelid::regclass AS relation_name,
 conname AS constraint_name,
 reltuples::bigint AS number_of_rows,
 indkey AS index_attributes,
 conkey AS constraint_attributes,
 CASE WHEN conkey && string_to_array(indkey::text, ' ')::SMALLINT[] THEN FALSE ELSE TRUE END as might_require_index
FROM
 pg_constraint JOIN pg_class ON (conrelid = pg_class.oid) JOIN
 pg_index ON indrelid = conrelid
WHERE
 contype = 'f';