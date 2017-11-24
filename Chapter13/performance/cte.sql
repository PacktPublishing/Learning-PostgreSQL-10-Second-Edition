\o /dev/null
\timing
SELECT * FROM guru WHERE id = 4;
WITH gurus as (SELECT * FROM guru) SELECT * FROM gurus WHERE id = 4;

