SET ROLE postgres;
ALTER TABLE car_portal_app.car_model DROP CONSTRAINT car_model_pkey;
CREATE SUBSCRIPTION car_model_a CONNECTION 'dbname=car_portal host=publisher-a user=car_portal_app' PUBLICATION car_model;
CREATE SUBSCRIPTION car_model_b CONNECTION 'dbname=car_portal host=publisher-b user=car_portal_app' PUBLICATION car_model;
