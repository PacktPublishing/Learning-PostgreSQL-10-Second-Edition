CREATE OR REPLACE FUNCTION is_updatable_view (text) RETURNS BOOLEAN AS
$$
    SELECT is_insertable_into='YES' FROM information_schema.tables WHERE table_type = 'VIEW' AND table_name = $1
$$ LANGUAGE SQL;

CREATE FUNCTION drop_table (text) RETURNS VOID AS
$$
    DROP TABLE $1;
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION fact(fact INT) RETURNS INT AS
$$
DECLARE
    count INT = 1;
    result INT = 1;
BEGIN
    FOR count IN 1..fact LOOP
        result = result* count;
    END LOOP;
    RETURN result;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION test_dep (INT) RETURNS INT AS $$
BEGIN
          RETURN $1;
END;
$$
LANGUAGE plpgsql;
CREATE OR REPLACE FUNCTION test_dep_2(INT) RETURNS INT AS
$$
BEGIN
    RETURN test_dep($1);
END;
$$
LANGUAGE plpgsql;
DROP FUNCTION test_dep(int);

SELECT test_dep_2 (5);

BEGIN;
SELECT now();
SELECT 'Some time has passed', now();

CREATE user select_only;
DO $$
    DECLARE r record;
BEGIN
    FOR r IN SELECT table_schema, table_name FROM information_schema.tables WHERE table_schema = 'car_portal_app' LOOP
        EXECUTE 'GRANT SELECT ON ' || quote_ident(r.table_schema) || '.'|| quote_ident(r.table_name) || ' TO select_only';
    END LOOP;
END$$;
