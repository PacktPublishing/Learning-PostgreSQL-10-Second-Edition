CREATE VIEW test AS SELECT 1 as v;
CREATE VIEW test2 AS SELECT v FROM test;
CREATE OR REPLACE VIEW test AS SELECT 1 as val;

CREATE VIEW account_information AS SELECT account_id, first_name, last_name, email FROM account;
\d account_information

CREATE OR REPLACE VIEW account_information (account_id,first_name,last_name,email) AS SELECT account_id, first_name, last_name, email FROM account;

CREATE OR REPLACE VIEW account_information AS SELECT account_id, last_name, first_name, email FROM account;

CREATE MATERIALIZED VIEW test_mat AS SELECT 1 WITH NO DATA;
REFRESH MATERIALIZED VIEW test_mat;
TABLE test_mat;

CREATE VIEW user_account AS SELECT account_id, first_name, last_name, email, password  FROM account WHERE account_id NOT IN (SELECT account_id FROM seller_account);
INSERT INTO user_account VALUES (default,'test_first_name','test_last_name','test@email.com','password');

WITH account_info AS ( INSERT INTO user_account VALUES (default,'test_first_name','test_last_name','test@example.com','password') RETURNING account_id)
INSERT INTO seller_account (account_id, street_name, street_number, zip_code, city) SELECT account_id, 'test_street', '555', '555', 'test_city' FROM account_info;

DELETE FROM user_account WHERE first_name = 'test_first_name';

CREATE TABLE a (val INT);
CREATE VIEW test_check_option AS SELECT * FROM a WHERE val > 0 WITH CHECK OPTION;
INSERT INTO test_check_option VALUES (-1);

SELECT table_name, is_insertable_into FROM information_schema.tables WHERE table_name = 'user_account';

