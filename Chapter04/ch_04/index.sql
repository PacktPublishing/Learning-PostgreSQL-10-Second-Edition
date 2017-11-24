CREATE TABLE no_date_overlap (
    date_range daterange,
    EXCLUDE USING GIST (date_range WITH &&)
);
INSERT INTO no_date_overlap values('[2010-01-01, 2020-01-01)');
INSERT INTO no_date_overlap values('[2010-01-01, 2017-01-01)');


SELECT search_key FROM account_history WHERE account_id = <account> GROUP BY search_key ORDER BY max(search_date) limit 10;

WITH test_account AS( INSERT INTO account VALUES (1000, 'test_first_name', 'test_last_name','test@email.com', 'password') RETURNING account_id
),car AS ( SELECT i as car_model FROM (VALUES('brand=BMW'), ('brand=WV')) AS foo(i)
),manufacturing_date AS ( SELECT 'year='|| i as date FROM generate_series (2015, 2014, -1) as foo(i))
INSERT INTO account_history (account_id, search_key, search_date) SELECT account_id, car.car_model||'&'||manufacturing_date.date, current_date
FROM test_account, car, manufacturing_date;

VACUUM ANALYZE;

SELECT search_key FROM account_history WHERE account_id = 1000 GROUP BY search_key ORDER BY max(search_date) limit 10;
EXPLAIN SELECT search_key FROM account_history WHERE account_id = 1000 GROUP BY search_key ORDER BY max(search_date) limit 10;

WITH test_account AS( INSERT INTO account VALUES (2000, 'test_first_name', 'test_last_name','test2@email.com', 'password') RETURNING account_id
),car AS ( SELECT i as car_model FROM (VALUES('brand=BMW'), ('brand=WV'), ('brand=Audi'), ('brand=MB')) AS foo(i)
),manufacturing_date AS ( SELECT 'year='|| i as date FROM generate_series (2017, 1900, -1) as foo(i))
INSERT INTO account_history (account_id, search_key, search_date) SELECT account_id, car.car_model||'&'||manufacturing_date.date, current_date
FROM test_account, car, manufacturing_date;

VACUUM ANALYZE;
EXPLAIN SELECT search_key FROM account_history WHERE account_id = 2000 GROUP BY search_key ORDER BY max(search_date) limit 10;
SELECT count(*), account_id FROM account_history group by account_id;
EXPLAIN SELECT search_key FROM account_history WHERE account_id = 1000 GROUP BY search_key ORDER BY max(search_date) limit 10;

CREATE index on account(lower(first_name));

SELECT * FROM account WHERE lower(first_name) = 'foo';

CREATE TABLE employee (employee_id INT PRIMARY KEY, supervisor_id INT);
ALTER TABLE employee ADD CONSTRAINT supervisor_id_fkey FOREIGN KEY
(supervisor_id) REFERENCES employee(employee_id);
CREATE UNIQUE INDEX ON employee ((1)) WHERE supervisor_id IS NULL;
INSERT INTO employee VALUES (1, NULL);
INSERT INTO employee VALUES (2, 1);
INSERT INTO employee VALUES (3, NULL);

CREATE index on car_portal_app.account(first_name);
CREATE index on car_portal_app.account(first_name);

REINDEX index car_portal_app.account_history_account_id_search_key_search_date_key;
CREATE UNIQUE INDEX CONCURRENTLY ON car_portal_app.account_history(account_id, search_key, search_date);
ALTER TABLE car_portal_app.account_history DROP CONSTRAINT account_history_account_id_search_key_search_date_key;
ALTER TABLE account_history ADD CONSTRAINT account_history_account_id_search_key_search_date_key UNIQUE USING INDEX account_history_account_id_search_key_search_date_idx;