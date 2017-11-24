
\l
\c template0

SELECT datconnlimit FROM pg_database WHERE datname='postgres';
ALTER DATABASE postgres CONNECTION LIMIT 1;
SELECT datconnlimit FROM pg_database WHERE datname='postgres';

SELECT count(*) FROM pg_settings;

SET default_transaction_read_only to on;
CREATE TABLE test_readonly AS SELECT 1;

SHOW search_path;

CREATE TABLE customer (
	customer_id SERIAL
);


CREATE SEQUENCE custome_customer_id_seq;
CREATE TABLE customer (
	customer_id integer NOT NULL DEFAULT nextval('customer_customer_id_seq')
);
ALTER SEQUENCE customer_customer_id_seq OWNED BY customer.Customer_id;


SELECT CAST (5.9 AS INT) AS rounded_up, CAST(5.1 AS INTEGER) AS rounded_down, 5.5::INT AS another_syntax;
SELECT 2/3 AS "2/3", 1/3 AS "1/3", 3/2 AS "3/2";

SELECT 'a'::CHAR(2) = 'a '::CHAR(2) ,length('a '::CHAR(10));
SELECT 'a '::VARCHAR(2)='a '::text, 'a '::CHAR(2)='a '::text, 'a '::CHAR(2)='a '::VARCHAR(2);
SELECT length ('a '::CHAR(2)), length ('a '::VARCHAR(2));



CREATE TABLE char_size_test (
	size CHAR(10)
);
CREATE TABLE varchar_size_test(
	size varchar(10)
);
WITH test_data AS (
	SELECT substring(md5(random()::text), 1, 10) FROM generate_series (1, 1000000)
),char _data_insert AS (
	INSERT INTO char_size_test SELECT * FROM test_data
)INSERT INTO varchar_size_test SELECT * FROM test_date;


CREATE TABLE emulate_varchar(
    test VARCHAR(4)
);
--semantically equivalent to
CREATE TABLE emulate_varchar (
    test TEXT,
    CONSTRAINT test_length CHECK (length(test) <= 4)
);


SET timezone TO 'Asia/jerusalem';
SELECT now();
SHOW timezone;
SELECT now(), now()::timestamp, now() AT TIME ZONE 'CST', now()::timestamp AT TIME ZONE 'CST';
SELECT ('2017-11-02 18:07:33.8087'::timestamp AT time zone 'CST' AT TIME ZONE 'Asia/jerusalem')::timestamptz;


SET timezone TO 'Europe/Berlin';
SELECT '2017-03-26 2:00:00'::timestamptz;


CREATE TABLE account (
	account_id SERIAL PRIMARY KEY,
	first_name TEXT NOT NULL,
	last_name TEXT NOT NULL,
	email TEXT NOT NULL UNIQUE,
	password TEXT NOT NULL,
	CHECK(first_name !~ '\s' AND last_name !~ '\s'),
	CHECK (email ~* '^\w+@\w+[.]\w+$'),
	CHECK (char_length(password)>=8)
);

CREATE TABLE seller_account (
	seller_account_id SERIAL PRIMARY KEY,
	account_id INT UNIQUE NOT NULL REFERENCES
	account(account_id),
	number_of_advertizement advertisement INT DEFAULT 0,
	user_ranking float,
	total_rank float
);

CREATE TABLE seller_account (
	account_id INT PRIMARY KEY REFERENCES account(account_id)
	...
);