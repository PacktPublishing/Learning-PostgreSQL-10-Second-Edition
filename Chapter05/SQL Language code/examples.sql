SELECT car_id, number_of_doors FROM car_portal_app.car;

----------------------------------------------------------------------

BEGIN;

DELETE FROM car_portal_app.a;

ROLLBACK;

----------------------------------------------------------------------

SELECT now();

----------------------------------------------------------------------

SELECT 1, 1.2, 0.3, .5, 1e15, 12.65e-6; 

----------------------------------------------------------------------

SELECT 'a', 'aa''aa', E'aa\naa', $$aa'aa$$, U&'\041C\0418\0420';

----------------------------------------------------------------------

SELECT $str1$SELECT $$dollar-quoted string$$;$str1$; 

----------------------------------------------------------------------

SELECT B'01010101'::int, X'AB21'::int; 

----------------------------------------------------------------------

SELECT car_id, registration_number, manufacture_year  
  FROM car_portal_app.car 
  WHERE number_of_doors=3 
  ORDER BY car_id
  LIMIT 5;  

----------------------------------------------------------------------

SELECT * FROM car_portal_app.car;

----------------------------------------------------------------------

SELECT 1;

----------------------------------------------------------------------

SELECT car.car_id, car.number_of_owners FROM car_portal_app.car;

----------------------------------------------------------------------

SELECT 1+1 AS two, 13%4 AS one, -5 AS minus_five, 5! AS factorial, |/25  AS square_root ;

----------------------------------------------------------------------

SELECT substring('this is a string constant',11,6); 

----------------------------------------------------------------------

SELECT (SELECT 1) + (SELECT 2) AS three;

----------------------------------------------------------------------

SELECT 'One plus one equals ' || (1+1) AS str; 

----------------------------------------------------------------------

SELECT CASE WHEN now() > date_trunc('day', now()) + interval '12 hours' 
  THEN 'PM' ELSE 'AM' END;

----------------------------------------------------------------------

SELECT ALL make FROM car_portal_app.car_model;

----------------------------------------------------------------------

SELECT DISTINCT make FROM car_portal_app.car_model;

----------------------------------------------------------------------

SELECT DISTINCT substring(make, 1, 1) FROM car_portal_app.car_model;

----------------------------------------------------------------------

SELECT a.car_id, a.number_of_doors FROM car_portal_app.car AS a; 

----------------------------------------------------------------------

SELECT * FROM car_portal_app.a;

----------------------------------------------------------------------

SELECT * FROM car_portal_app.b;

----------------------------------------------------------------------

SELECT * FROM car_portal_app.a, car_portal_app.b;

----------------------------------------------------------------------

SELECT * FROM car_portal_app.a, car_portal_app.b WHERE a_int=b_int;

----------------------------------------------------------------------

SELECT * FROM car_portal_app.a JOIN car_portal_app.b ON a_int=b_int;

----------------------------------------------------------------------

SELECT * FROM car_portal_app.a JOIN car_portal_app.b ON a_int=b_int;

----------------------------------------------------------------------

SELECT * FROM car_portal_app.a LEFT JOIN car_portal_app.b ON a_int=b_int;

----------------------------------------------------------------------

SELECT * FROM car_portal_app.a RIGHT JOIN car_portal_app.b ON a_int=b_int;

----------------------------------------------------------------------

SELECT * FROM car_portal_app.a FULL JOIN car_portal_app.b ON a_int=b_int;

----------------------------------------------------------------------

SELECT * 
  FROM car_portal_app.a 
  INNER JOIN 
    (SELECT * FROM car_portal_app.b WHERE b_text = 'two') subq 
    ON a.a_int=subq.b_int; 

----------------------------------------------------------------------

SELECT * FROM car_portal_app.a CROSS JOIN car_portal_app.b;

----------------------------------------------------------------------

SELECT * FROM car_portal_app.a, car_portal_app.b;

----------------------------------------------------------------------

SELECT * FROM car_portal_app.a INNER JOIN car_portal_app.b ON a.a_int=b.b_int;

----------------------------------------------------------------------

SELECT * FROM car_portal_app.a, car_portal_app.b WHERE a.a_int=b.b_int; 

----------------------------------------------------------------------

SELECT t1.a_int AS current, t2.a_int AS bigger 
  FROM car_portal_app.a t1
    INNER JOIN car_portal_app.a t2 ON t2.a_int > t1.a_int; 

----------------------------------------------------------------------

SELECT t1.a_int AS current, t2.a_int AS bigger 
  FROM car_portal_app.a t1 
    LEFT JOIN car_portal_app.a t2 ON t2.a_int > t1.a_int; 

----------------------------------------------------------------------

SELECT * FROM car_portal_app.car_model WHERE make='Peugeot';

----------------------------------------------------------------------

SELECT * FROM car_portal_app.car WHERE mileage < 25000;

----------------------------------------------------------------------

SELECT * FROM car_portal_app.car WHERE number_of_doors > 3 AND number_of_owners <= 2;

----------------------------------------------------------------------

SELECT * FROM car_portal_app.car_model WHERE length(model)=4;

----------------------------------------------------------------------

 SELECT 1 WHERE (date '2017-10-15', date '2017-10-31') 
  OVERLAPS (date '2017-10-25', date '2017-11-15');

----------------------------------------------------------------------

SELECT * FROM car_portal_app.car_model WHERE model ILIKE 's___';

----------------------------------------------------------------------

 SELECT * FROM car_portal_app.car_model WHERE model ~ '^\w+\W+\w+$'; 

----------------------------------------------------------------------

SELECT * FROM car_portal_app.car_model 
  WHERE car_model_id IN (SELECT car_model_id FROM car_portal_app.car); 

----------------------------------------------------------------------

SELECT car_model.* 
  FROM car_portal_app.car_model INNER JOIN car_portal_app.car USING (car_model_id);

----------------------------------------------------------------------

SELECT a.make, a.model 
  FROM car_portal_app.car_model a 
    INNER JOIN car_portal_app.car b ON a.car_model_id=b.car_model_id 
  GROUP BY   a.marke, a.model; 

----------------------------------------------------------------------

SELECT a.make, a.model, count(*) 
  FROM car_portal_app.car_model a 
    INNER JOIN car_portal_app.car b ON a.car_model_id=b.car_model_id 
  GROUP BY a.make, a.model; 

----------------------------------------------------------------------

SELECT a_int, a_text FROM car_portal_app.a GROUP BY a_int;

----------------------------------------------------------------------

SELECT count(*) FROM car_portal_app.car; 

----------------------------------------------------------------------

SELECT count(*) FROM car_portal_app.car WHERE number_of_doors = 15; 

----------------------------------------------------------------------

SELECT count(*), count(DISTINCT car_model_id) FROM car_portal_app.car; 

----------------------------------------------------------------------

SELECT make, model FROM 
(
  SELECT a.make, a.model, count(*) c
    FROM car_portal_app.car_model a
      INNER JOIN car_portal_app.car b ON a.car_model_id=b.car_model_id
    GROUP BY a.make, a.model
) subq 
WHERE c >5;

----------------------------------------------------------------------

SELECT a.make, a.model
  FROM car_portal_app.car_model a
    INNER JOIN car_portal_app.car b ON a.car_model_id=b.car_model_id
  GROUP BY a.make, a.model
  HAVING count(*)>5;

----------------------------------------------------------------------

SELECT number_of_owners, manufacture_year, trunc(mileage/1000) as kmiles 
  FROM car_portal_app.car 
  ORDER BY number_of_owners, manufacture_year, trunc(mileage/1000) DESC;

----------------------------------------------------------------------

SELECT number_of_owners, manufacture_year, trunc(mileage/1000) as kmiles 
  FROM car_portal_app.car 
  ORDER BY number_of_owners, manufacture_year, kmiles DESC;

----------------------------------------------------------------------

SELECT number_of_owners, manufacture_year, trunc(mileage/1000) as kmiles 
  FROM car_portal_app.car 
  ORDER BY 1, 2, 3 DESC; 

----------------------------------------------------------------------

SELECT * FROM car_portal_app.car_model LIMIT 5;

----------------------------------------------------------------------

SELECT * FROM car_portal_app.car_model OFFSET 5 LIMIT 5;

----------------------------------------------------------------------

SELECT * FROM 
  (SELECT car_model_id, count(*) c FROM car_portal_app.car GROUP BY car_model_id) subq 
WHERE c = 1;

----------------------------------------------------------------------

SELECT car_id, registration_number 
FROM car_portal_app.car 
WHERE car_model_id IN (SELECT car_model_id FROM car_portal_app.car_model WHERE make='Peugeot');

----------------------------------------------------------------------

SELECT (SELECT count(*) FROM car_portal_app.car_model) 
FROM car_portal_app.car 
LIMIT (SELECT MIN(car_id)+2 FROM car_portal_app.car);

----------------------------------------------------------------------

SELECT marke, model, 
    (SELECT count(*) FROM car_portal_app.car WHERE car_model_id = main.car_model_id) 
  FROM car_portal_app.car_model main 
  ORDER BY 3 DESC 
  LIMIT 5;

----------------------------------------------------------------------

SELECT 'a', * FROM 
(
  SELECT * FROM car_portal_app.a 
  EXCEPT ALL 
  SELECT * FROM car_portal_app.b
) v1
UNION ALL
SELECT 'b', * FROM 
(
  SELECT * FROM car_portal_app.b 
  EXCEPT ALL 
  SELECT * FROM car_portal_app.a
) v2; 

----------------------------------------------------------------------

SELECT true AND NULL, false AND NULL, true OR NULL, false OR NULL, NOT NULL;

----------------------------------------------------------------------

SELECT 1 IN (1, NULL) as in;

----------------------------------------------------------------------

SELECT 2 IN (1, NULL) as in;

----------------------------------------------------------------------

SELECT a IS NULL, b IS NULL, a = b FROM (SELECT ''::text a, NULL::text b) v;  

----------------------------------------------------------------------

INSERT INTO car_portal_app.a (a_int) VALUES (6); 

----------------------------------------------------------------------

INSERT INTO car_portal_app.a (a_text) VALUES (default); 

----------------------------------------------------------------------

INSERT INTO car_portal_app.a DEFAULT VALUES; 

----------------------------------------------------------------------

INSERT INTO car_portal_app.a (a_int, a_text) VALUES (7, 'seven'), (8, 'eight');  

----------------------------------------------------------------------

SELECT * FROM (VALUES (7, 'seven'), (8, 'eight')) v; 

----------------------------------------------------------------------

INSERT INTO car_portal_app.a SELECT * FROM car_portal_app.b;

----------------------------------------------------------------------

INSERT INTO car_portal_app.a SELECT * FROM car_portal_app.b RETURNING a_int; 


----------------------------------------------------------------------

INSERT INTO b VALUES (2, 'new_two');

----------------------------------------------------------------------

INSERT INTO b VALUES (2, 'new_two') 
  ON CONFLICT (b_int) DO UPDATE SET b_text = excluded.b_text 
  RETURNING *;

----------------------------------------------------------------------

UPDATE car_portal_app.a u SET a_text = 
  (SELECT b_text FROM car_portal_app.b WHERE b_int = u.a_int);

----------------------------------------------------------------------

UPDATE car_portal_app.a SET a_int = b_int FROM car_portal_app.b WHERE a.a_text=b.b_text;

----------------------------------------------------------------------

UPDATE car_portal_app.a SET a_int = (SELECT b_int FROM car_portal_app.b WHERE a.a_text=b.b_text) 
  WHERE a_text IN (SELECT b_text FROM car_portal_app.b);

----------------------------------------------------------------------

UPDATE car_portal_app.a SET a_int = b_int FROM car_portal_app.b;

----------------------------------------------------------------------

UPDATE car_portal_app.a SET a_int = b_int FROM car_portal_app.b WHERE b_int>=a_int;

----------------------------------------------------------------------

UPDATE car_portal_app.a SET a_int = 0 RETURNING *;

----------------------------------------------------------------------

DELETE FROM car_portal_app.a USING car_portal_app.b WHERE a.a_int=b.b_int;

----------------------------------------------------------------------

DELETE FROM car_portal_app.a 
  WHERE a_int IN (SELECT b_int FROM car_portal_app.b);

----------------------------------------------------------------------

DELETE FROM car_portal_app.a RETURNING *; 

----------------------------------------------------------------------

TRUNCATE TABLE car_portal_app.a;   

----------------------------------------------------------------------










