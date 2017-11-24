CREATE FUNCTION test_security_definer () RETURNS TEXT AS $$
	SELECT format ('current_user:%s   session_user:%s', current_user, session_user);
$$ LANGUAGE SQL SECURITY DEFINER;

CREATE FUNCTION test_security_invoker () RETURNS TEXT AS $$
	SELECT format ('current_user:%s   session_user:%s', current_user, session_user);
$$ LANGUAGE SQL SECURITY INVOKER;

psql -U postgres car_portal
SELECT test_security_definer() , test_security_invoker();
psql -U car_portal_app  car_portal
SELECT test_security_definer() , test_security_invoker();

CREATE OR REPLACE FUNCTION a() RETURNS SET OF INTEGER AS $$
	SELECT 1;
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION slow_function (anyelement) RETURNS BOOLEAN AS $$
BEGIN
	RAISE NOTICE 'Slow function %', $1;
	RETURN TRUE;
END; $$ LANGUAGE PLPGSQL COST 10000;

CREATE OR REPLACE FUNCTION fast_function (anyelement) RETURNS BOOLEAN AS $$
BEGIN
	RAISE NOTICE 'Fast function %', $1;
	RETURN TRUE;
END; $$ LANGUAGE PLPGSQL COST 0.0001;

EXPLAIN SELECT * FROM pg_language WHERE fast_function(lanname) AND slow_function(lanname) AND lanname ILIKE '%sql%';
EXPLAIN SELECT * FROM pg_language WHERE slow_function(lanname) AND fast_function(lanname) AND lanname ILIKE '%sql%';
SELECT lanname FROM pg_language WHERE lanname ILIKE '%sql%' AND slow_function(lanname)AND fast_function(lanname);

CREATE OR REPLACE VIEW pg_sql_pl AS SELECT lanname FROM pg_language WHERE lanname ILIKE '%sql%';
ALTER FUNCTION fast_function(anyelement) LEAKPROOF;
SELECT * FROM pg_sql_pl WHERE fast_function(lanname);


SET enable_seqscan TO OFF;
CREATE OR REPLACE FUNCTION configuration_test () RETURNS
VOID AS
$$
BEGIN
	RAISE NOTICE 'Current session enable_seqscan value: %', (SELECT setting FROM pg_settings WHERE name ='enable_seqscan')::text;
	RAISE NOTICE 'Function work_mem: %', (SELECT setting FROM pg_settings WHERE name ='work_mem')::text;
---
---SQL statement here will use index scan when possible
---
	SET LOCAL enable_seqscan TO TRUE;
	RAISE NOTICE 'Override session enable_seqscan value: %', (SELECT setting FROM pg_settings WHERE name ='enable_seqscan')::text;
---
---SQL statement here will use index scan when possible
---
END;
$$ LANGUAGE PLPGSQL
SET enable_seqscan FROM current
SET work_mem = '10MB';

SELECT md5(random()::text) FROM generate_series(1, 1000000) order by 1;

CREATE OR REPLACE FUNCTION configuration_test () RETURNS TABLE(md5 text) AS
$$
		SELECT md5(random()::text) FROM generate_series(1, 1000000) order by 1;
$$ LANGUAGE SQL
SET enable_seqscan FROM current
SET work_mem = '100MB';
EXPLAIN (ANALYZE ,BUFFERS) SELECT * FROM configuration_test();

SET work_mem = '100MB';
SELECT md5(random()::text) FROM generate_series(1, 1000000) order by 1;


CREATE OR REPLACE FUNCTION factorial(INTEGER ) RETURNS INTEGER AS $$
BEGIN
	IF $1 IS NULL OR $1 < 0 THEN RAISE NOTICE 'Invalid Number';
		RETURN NULL;
	ELSIF $1 = 1 THEN
		RETURN 1;
	ELSE
		RETURN factorial($1 - 1) * $1;
END IF;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION factorial(INTEGER ) RETURNS INTEGER AS $$
	DECLARE
		fact ALIAS FOR $1;
	BEGIN
	IF fact IS NULL OR fact < 0 THEN
		RAISE NOTICE 'Invalid Number';
		RETURN NULL;
	ELSIF fact = 1 THEN
		RETURN 1;
	END IF;
	DECLARE
		result INT;
	BEGIN
		result = factorial(fact - 1) * fact;
		RETURN result;
	END;
END;
$$ LANGUAGE 'plpgsql'


CREATE OR REPLACE FUNCTION cast_numeric_to_int (numeric_value numeric, round boolean = TRUE /*correct use of "=". Using ":=" will raise a syntax error */)
RETURNS INT AS
$$
	BEGIN
	RETURN (CASE WHEN round = TRUE THEN CAST (numeric_value AS INTEGER)
	WHEN numeric_value>= 0 THEN CAST (numeric_value -.5 AS INTEGER)
	WHEN numeric_value< 0 THEN CAST (numeric_value +.5 AS INTEGER)
	ELSE NULL
	END);
END;
$$ LANGUAGE plpgsql;

SELECT cast_numeric_to_int(2.3, round:= true);

SELECT cast_numeric_to_int(2.3, round= true);

DO $$
	DECLARE
		test record;
	BEGIN
		test = ROW (1,'hello', 3.14);
		RAISE notice '%', test;
	END;
$$ LANGUAGE plpgsql;


DO $$
DECLARE
	number_of_accounts INT:=0;
BEGIN
	number_of_accounts:= (SELECT COUNT(*) FROM car_portal_app.account)::INT;
	RAISE NOTICE 'number_of accounts: %', number_of_accounts;
END;$$
LANGUAGE plpgsql;

CREATE TABLE test (
	id SERIAL PRIMARY KEY,
	name TEXT NOT NULL
);


DO $$
	DECLARE
		auto_generated_id INT;
	BEGIN
		INSERT INTO test(name) VALUES ('Hello World') RETURNING id INTO auto_generated_id;
		RAISE NOTICE 'The primary key is: %', auto_generated_id;
END
$$;

CREATE OR REPLACE FUNCTION cast_rank_to_text (rank int) RETURNS TEXT AS $$
DECLARE
	rank ALIAS FOR $1;
	rank_result TEXT;
BEGIN
	IF rank = 5 THEN rank_result = 'Excellent';
	ELSIF rank = 4 THEN rank_result = 'Very Good';
	ELSIF rank = 3 THEN rank_result = 'Good';
	ELSIF rank = 2 THEN rank_result ='Fair';
	ELSIF rank = 1 THEN rank_result ='Poor';
	ELSE rank_result ='No such rank';
	END IF;
	RETURN rank_result;
END;
$$ Language plpgsql;


CREATE OR REPLACE FUNCTION cast_rank_to_text (rank int) RETURNS TEXT AS $$
DECLARE
	rank ALIAS FOR $1;
	rank_result TEXT;
BEGIN
	CASE rank
		WHEN 5 THEN rank_result = 'Excellent';
		WHEN 4 THEN rank_result = 'Very Good';
		WHEN 3 THEN rank_result = 'Good';
		WHEN 2 THEN rank_result ='Fair';
		WHEN 1 THEN rank_result ='Poor';
		ELSE rank_result ='No such rank';
	END CASE;
	RETURN rank_result;
END;$$ Language plpgsql;


CREATE OR REPLACE FUNCTION cast_rank_to_text (rank int) RETURNS TEXT AS $$
DECLARE
	rank ALIAS FOR $1;
	rank_result TEXT;
BEGIN
	CASE
		WHEN rank=5 THEN rank_result = 'Excellent';
		WHEN rank=4 THEN rank_result = 'Very Good';
		WHEN rank=3 THEN rank_result = 'Good';
		WHEN rank=2 THEN rank_result ='Fair';
		WHEN rank=1 THEN rank_result ='Poor';
		WHEN rank IS NULL THEN RAISE EXCEPTION 'Rank should be not NULL';
		ELSE rank_result ='No such rank';
	END CASE;
	RETURN rank_result;
END;
$$ Language plpgsql;
--- to test
SELECT cast_rank_to_text(null);

DO $$
DECLARE
	i int := 0;
BEGIN
	case WHEN i=1 then
		RAISE NOTICE 'i is one';
	END CASE;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION factorial (fact int) RETURNS BIGINT AS $$
DECLARE
	result bigint = 1;
BEGIN
	IF fact = 1 THEN RETURN 1;
	ELSIF fact IS NULL or fact < 1 THEN RAISE EXCEPTION 'Provide a positive integer';
	ELSE
		LOOP
			result = result*fact;
			fact = fact-1;
			EXIT WHEN fact = 1;
		END Loop;
	END IF;
	RETURN result;
END; $$ LANGUAGE plpgsql;

DO $$
DECLARE
	first_day_in_month date := date_trunc('month', current_date)::date;
	last_day_in_month date := (date_trunc('month', current_date)+ INTERVAL '1 MONTH - 1 day')::date;
	counter date = first_day_in_month;
BEGIN
	WHILE (counter <= last_day_in_month) LOOP
		RAISE notice '%', counter;
		counter := counter + interval '1 day';
	END LOOP;
END;
$$ LANGUAGE plpgsql;


DO $$
BEGIN
	FOR j IN REVERSE -1 .. -10 BY 2 LOOP
			Raise notice '%', j;
	END LOOP;
END; $$ LANGUAGE plpgsql;

DO $$
DECLARE
	table_name text;
BEGIN
		FOR table_name IN SELECT tablename FROM pg_tables WHERE schemaname ='car_portal_app' LOOP
				RAISE NOTICE 'Analyzing %', table_name;
				EXECUTE 'ANALYZE car_portal_app.' || table_name;
		END LOOP;
END;
$$;

DO $$
DECLARE
	database RECORD;
BEGIN
	FOR database IN SELECT * FROM pg_database LOOP
		RAISE notice '%', database.datname;
	END LOOP;
END; $$;

DO $$
BEGIN
	RETURN;
	RAISE NOTICE 'This statement will not be executed';
END
$$
LANGUAGE plpgsql;
-- in sql
CREATE OR REPLACE FUNCTION car_portal_app.get_account_in_json (account_id INT) RETURNS JSON AS $$
	SELECT row_to_json(account) FROM car_portal_app.account WHERE account_id = $1;
$$ LANGUAGE SQL;

--- in plpgsql
CREATE OR REPLACE FUNCTION car_portal_app.get_account_in_json1 (acc_id INT) RETURNS JSON AS $$
BEGIN
	RETURN (SELECT row_to_json(account) FROM car_portal_app.account WHERE account_id = acc_id);
END;
$$ LANGUAGE plpgsql;

-- In SQL
CREATE OR REPLACE FUNCTION car_portal_app.car_model(model_name TEXT) RETURNS SETOF car_portal_app.car_model AS $$
	SELECT car_model_id, make, model FROM car_portal_app.car_model WHERE model = model_name;
$$ LANGUAGE SQL;

-- In plpgSQL
CREATE OR REPLACE FUNCTION car_portal_app.car_model1(model_name TEXT) RETURNS SETOF car_portal_app.car_model AS $$
BEGIN
	RETURN QUERY SELECT car_model_id, make, model FROM car_portal_app.car_model WHERE model = model_name;
END;
$$ LANGUAGE plpgsql;

-- SQL
CREATE OR REPLACE FUNCTION car_portal_app.car_model2(model_name TEXT) RETURNS TABLE (car_model_id INT , make TEXT) AS $$
	SELECT car_model_id, make FROM car_portal_app.car_model WHERE model = model_name;
$$ LANGUAGE SQL;

-- plpgSQL
CREATE OR REPLACE FUNCTION car_portal_app.car_model3(model_name TEXT) RETURNS TABLE (car_model_id INT , make TEXT) AS $$
BEGIN
	RETURN QUERY SELECT car_model_id, make FROM car_portal_app.car_model WHERE model = model_name;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION car_portal_app.car_model3(model_name TEXT) RETURNS TABLE (car_model_id INT , make TEXT) AS $$
BEGIN
	RETURN QUERY SELECT a.car_model_id, a.make FROM car_portal_app.car_model a WHERE model = model_name;
END;
$$ LANGUAGE plpgsql;
SELECT * FROM car_portal_app.car_model3('A1');

CREATE OR REPLACE FUNCTION car_portal_app.car_model4(model_name TEXT, OUT car_model_id INT, OUT make TEXT ) RETURNS SETOF RECORD AS $$
BEGIN
	RETURN QUERY SELECT a.car_model_id, a.make FROM car_portal_app.car_model a WHERE model = model_name;
END;
$$ LANGUAGE plpgsql;
SELECT * FROM car_portal_app.car_model4('A1'::text);

DO $$
BEGIN
	CREATE TABLE t1(f1 int);

	INSERT INTO t1 VALUES (1);
	RAISE NOTICE '%', FOUND;

	PERFORM* FROM t1 WHERE f1 = 0;
	RAISE NOTICE '%', FOUND;
	DROP TABLE t1;
END;
$$LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION check_not_null (value anyelement ) RETURNS VOID AS
$$
BEGIN
	IF (value IS NULL) THEN RAISE EXCEPTION USING ERRCODE = 'check_violation'; END IF;
END;
$$ LANGUAGE plpgsql;


DO $$
BEGIN
	RAISE EXCEPTION USING ERRCODE = '1234X', MESSAGE = 'test customized SQLSTATE:';
	EXCEPTION WHEN SQLSTATE '1234X' THEN
		RAISE NOTICE '% %', SQLERRM, SQLSTATE;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS factorial( INTEGER );
CREATE OR REPLACE FUNCTION factorial(INTEGER ) RETURNS BIGINT AS $$
DECLARE
	fact ALIAS FOR $1;
BEGIN
	PERFORM check_not_null(fact);
	IF fact > 1 THEN RETURN factorial(fact - 1) * fact;
	ELSIF fact IN (0,1) THEN RETURN 1;
	ELSE RETURN NULL;
	END IF;

	EXCEPTION
		WHEN check_violation THEN RETURN NULL;
		WHEN OTHERS THEN RAISE NOTICE '% %', SQLERRM, SQLSTATE;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION car_portal_app.get_account (predicate TEXT) RETURNS SETOF car_portal_app.account AS
$$
BEGIN
	RETURN QUERY EXECUTE 'SELECT * FROM car_portal_app.account WHERE ' || predicate;
END;
$$ LANGUAGE plpgsql;
SELECT * FROM car_portal_app.get_account ('true') limit 1;
SELECT * FROM car_portal_app.get_account (E'first_name=\'James\'');

CREATE OR REPLACE FUNCTION car_portal_app.get_advertisement_count (some_date timestamptz ) RETURNS BIGINT AS $$
BEGIN
	RETURN (SELECT count (*) FROM car_portal_app.advertisement WHERE advertisement_date >=some_date)::bigint;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION car_portal_app.get_advertisement_count (some_date timestamptz ) RETURNS BIGINT AS $$
DECLARE
	count BIGINT;
BEGIN
	EXECUTE 'SELECT count (*) FROM car_portal_app.advertisement WHERE advertisement_date >= $1' USING some_date INTO count;
	RETURN count;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION car_portal_app.can_login (email text, pass text) RETURNS BOOLEAN AS $$
DECLARE
	stmt TEXT;
	result bool;
BEGIN
	stmt = E'SELECT COALESCE (count(*)=1, false) FROM car_portal_app.account WHERE email = \''|| $1 || E'\' and password = \''||$2||E'\'';
	RAISE NOTICE '%' , stmt;
	EXECUTE stmt INTO result;
	RETURN result;
END;
$$ LANGUAGE plpgsql;

SELECT car_portal_app.can_login('jbutt@gmail.com', md5('jbutt@gmail.com'));
SELECT car_portal_app.can_login('jbutt@gmail.com', md5('jbutt@yahoo.com'));
SELECT car_portal_app.can_login(E'jbutt@gmail.com\'--', 'Do not know password');

CREATE OR REPLACE FUNCTION car_portal_app.can_login (email text, pass text) RETURNS BOOLEAN AS
$$
DECLARE
	stmt TEXT;
result bool;
BEGIN
	stmt = format('SELECT COALESCE (count(*)=1, false) FROM car_portal_app.account WHERE email = %Land password = %L', $1,$2);
	RAISE NOTICE '%' , stmt;
	EXECUTE stmt INTO result;
	RETURN result;
END;
$$ LANGUAGE plpgsql;