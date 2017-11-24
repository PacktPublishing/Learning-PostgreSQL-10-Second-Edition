\set PROMPT1 '(%n@%M:%>) [%/]%R%#%x > '
BEGIN;
SELECT 1;
SELECT 1/0;
ROLLBACK;
SELECT
1;