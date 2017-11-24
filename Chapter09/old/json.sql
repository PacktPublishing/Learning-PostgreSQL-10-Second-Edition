SELECT '{"name":"some name", "name":"some name" }'::json;
SELECT '{"name":"some name", "name":"some name" }'::jsonb;
SELECT '{"name":"John", "Address":{"Street":"Some street", "city":"Some city"}, "rank":[5,3,4,5,2,3,4,5]}'::JSONB;

CREATE TABLE json_doc ( doc jsonb );
INSERT INTO json_doc SELECT '{"name":"John", "Address":{"Street":"Some street", "city":"Some city"}, "rank":[5,3,4,5,2,3,4,5]}'::JSONB ;

SELECT doc->'Address'->>'city', doc#>>'{Address, city}' FROM json_doc WHERE doc->>'name' = 'John';

SELECT (regexp_replace(doc::text, '"rank":(.*)],',''))::jsonb FROM test_jsonb WHERE doc->>'name' = 'John';

update json_doc SET doc = jsonb_insert(doc, '{hoppy}','["swim", "read"]', true) RETURNING * ;
update json_doc SET doc = jsonb_set(doc, '{hoppy}','["read"]', true) RETURNING * ;
update json_doc SET doc = doc -'hoppy' RETURNING * ;

CREATE INDEX ON json_doc(doc);
SET enable_seqscan = off;

EXPLAIN SELECT * FROM jso_doc WHERE doc @> '{"name":"John"}';


SELECT to_json (row(account_id,first_name, last_name, email)) FROM car_portal_app.account LIMIT 1;
SELECT to_json (account) FROM car_portal_app.account LIMIT 1;

WITH account_info(account_id, first_name, last_name, email) AS ( SELECT account_id,first_name, last_name, email FROM car_portal_app. account LIMIT 1
) SELECT to_json(account_info) FROM account_info;

SELECT memcache_add('/'||account_id, (SELECT to_json(foo) FROM (SELECT account_id, first_name,last_name, email ) AS FOO )::text) FROM car_portal_app.account;

BEGIN;
SELECT memcache_add('is_transactional?', 'No');
Rollback;
SELECT memcache_get('is_transactional?');