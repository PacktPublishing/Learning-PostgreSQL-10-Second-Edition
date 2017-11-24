--This example shows how to create a composite data type.
CREATE TYPE phone_number AS (
    area_code varchar(3),
    line_number varchar(7)
);
CREATE OR REPLACE FUNCTION phone_number_equal (phone_
number,phone_number) RETURNS boolean AS $$
BEGIN
    IF $1.area_code=$2.area_code AND $1.line_number=$2.line_number THEN
        RETURN TRUE ;
    ELSE
        RETURN FALSE;
    END IF;
END; $$ LANGUAGE plpgsql;
CREATE OPERATOR = (
LEFTARG = phone_number,
RIGHTARG = phone_number,
PROCEDURE = phone_number_equal
);
--For test purpose
SELECT row('123','222244')::phone_number = row('1','222244')::phone_number;