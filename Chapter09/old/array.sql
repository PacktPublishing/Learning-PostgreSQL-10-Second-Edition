 WITH arr AS (SELECT '[0:1]={1,2}'::INT[] as arr) SELECT arr, arr[0];

SELECT array['red','green','blue'] AS primary_colors;

SELECT
	array_ndims(two_dim_array) AS "Number of dimensions",
	array_dims(two_dim_array) AS "Dimensions index range",
	array_length(two_dim_array, 1) AS "The array length of 1st dimension",
	cardinality(two_dim_array) AS "Number of elements",
	two_dim_array[1][1] AS "The first element"
FROM
(VALUES ('{{red,green,blue}, {red,green,blue}}'::text[][])) AS foo(two_dim_array);

SELECT tablename, attname, most_common_vals, most_common_freqs FROM pg_stats WHERE array_length(most_common_vals,1) < 10 AND schemaname NOT IN ('pg_catalog','information_schema') LIMIT 1;

CREATE OR REPLACE FUNCTION null_count (VARIADIC arr int[]) RETURNS INT AS
$$
	SELECT count(CASE WHEN m IS NOT NULL THEN 1 ELSE NULL END)::int FROM unnest($1) m(n)
$$ LANGUAGE SQL


CREATE TABLE car (
	car_id SERIAL PRIMARY KEY,
	car_number_of_doors INT DEFAULT 5
);
CREATE TABLE bus (
	bus_id SERIAL PRIMARY KEY,
	bus_number_of_passengers INT DEFAULT 50
);
CREATE TABLE vehicle (
	vehicle_id SERIAL PRIMARY KEY,
	registration_number TEXT,
	car_id INT REFERENCES car(car_id),
	bus_id INT REFERENCES bus(bus_id),
	CHECK (null_count(car_id, bus_id) = 1)
);

INSERT INTO public.vehicle VALUES (default, 'a234', null, null);
INSERT INTO public.vehicle VALUES (default, 'a234', 1, 1);
INSERT INTO public.vehicle VALUES (default, 'a234', null, 1);
INSERT INTO public.vehicle VALUES (default, 'a234', 1, null);

SELECT * FROM null_count(VARIADIC ARRAY [null, 1]);


CREATE TABLE prefix (
	network TEXT,
	prefix_code TEXT NOT NULL
);
INSERT INTO prefix VALUES ('Palestine Jawwal', 97059), ('Palestine Jawwal',970599), ('Palestine watania',970597);
CREATE OR REPLACE FUNCTION prefixes(TEXT) RETURNS TEXT[] AS $$
	SELECT ARRAY(SELECT substring($1,1,i) FROM generate_series(1,length($1)) g(i))::TEXT[];
$$ LANGUAGE SQL IMMUTABLE;

SELECT * FROM prefix WHERE prefix_code = any (prefixes('97059973456789')) ORDER BY length(prefix_code) DESC limit 1;
SELECT array(SELECT DISTINCT unnest (array [1,1,1,2,3,3]) ORDER BY 1);

SELECT make, array_agg(model) FROM car_model group by make;


CREATE TABLE color(
	color text []
);

INSERT INTO color(color) VALUES ('{red, green}'::text[]);
INSERT INTO color(color) VALUES ('{red}'::text[]);

SELECT color [3]IS NOT DISTINCT FROM null FROM color;

SELECT color [1:2] FROM color;

CREATE INDEX ON color USING GIN (color);