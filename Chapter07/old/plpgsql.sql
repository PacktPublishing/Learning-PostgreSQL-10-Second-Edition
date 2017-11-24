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