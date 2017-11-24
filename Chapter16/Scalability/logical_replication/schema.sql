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

CREATE TABLE account_history (
	account_history_id BIGSERIAL PRIMARY KEY,
	account_id INT NOT NULL REFERENCES account(account_id),
	search_key TEXT NOT NULL,
	search_date DATE NOT NULL,
	UNIQUE (account_id, search_key, search_date)
);

CREATE TABLE seller_account (
	seller_account_id SERIAL PRIMARY KEY,
	account_id INT NOT NULL REFERENCES account(account_id),
	total_rank FLOAT,
	number_of_advertisement INT,
	street_name TEXT NOT NULL,
	street_number TEXT NOT NULL,
	zip_code TEXT NOT NULL,
	city TEXT NOT NULL
);

CREATE TABLE car_model
(
	car_model_id SERIAL PRIMARY KEY,
	make text,
	model text,
	UNIQUE (make, model)
);

CREATE TABLE car (
	car_id SERIAL PRIMARY KEY,
	number_of_owners INT NOT NULL,
	registration_number TEXT UNIQUE NOT NULL,
	manufacture_year INT NOT NULL,
	number_of_doors INT DEFAULT 5 NOT NULL,
	car_model_id INT NOT NULL REFERENCES car_model (car_model_id),
	mileage INT
);

CREATE TABLE advertisement(
	advertisement_id SERIAL PRIMARY KEY,
	advertisement_date TIMESTAMP WITH TIME ZONE NOT  NULL,
	car_id INT NOT NULL REFERENCES car(car_id),
	seller_account_id INT NOT NULL REFERENCES seller_account (seller_account_id)
);

CREATE TABLE advertisement_picture(
	advertisement_picture_id SERIAL PRIMARY KEY,
	advertisement_id INT REFERENCES advertisement(advertisement_id),
	picture_location TEXT UNIQUE
);

CREATE TABLE advertisement_rating (
	advertisement_rating_id SERIAL PRIMARY KEY,
	advertisement_id INT NOT NULL REFERENCES advertisement(advertisement_id),
	account_id INT NOT NULL REFERENCES account(account_id),
	advertisement_rating_date DATE NOT NULL,
	rank INT NOT NULL,
	review TEXT NOT NULL,
	CHECK (char_length(review)<= 200),
	CHECK (rank IN (1,2,3,4,5))
);

CREATE TABLE favorite_ads(
	account_id INT NOT NULL REFERENCES account(account_id),
	advertisement_id INT NOT NULL REFERENCES advertisement(advertisement_id),
	primary key(account_id,advertisement_id)
);

