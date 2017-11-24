CREATE ROLE car_portal_app LOGIN;

DROP DATABASE IF EXISTS car_portal;

--For linux
CREATE DATABASE car_portal ENCODING 'UTF-8' LC_COLLATE 'en_US.UTF-8' LC_CTYPE 'en_US.UTF-8' TEMPLATE template0 OWNER car_portal_app;

-- For Windows:
CREATE DATABASE car_portal ENCODING 'UTF-8' LC_COLLATE 'English_United States' LC_CTYPE 'English_United States' TEMPLATE template0 OWNER car_portal_app;

\c car_portal

CREATE SCHEMA car_portal_app AUTHORIZATION car_portal_app;

SET search_path to car_portal_app;
SET ROLE car_portal_app;

CREATE TABLE car_model
(
	car_model_id SERIAL PRIMARY KEY,
	make text NOT NULL,
	model text NOT NULL,
	CONSTRAINT car_model_uq1 UNIQUE (make, model)
);

ALTER TABLE car_model REPLICA IDENTITY USING INDEX car_model_uq1;