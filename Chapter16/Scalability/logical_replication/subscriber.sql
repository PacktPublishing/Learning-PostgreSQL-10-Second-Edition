SET ROLE postgres;
CREATE SUBSCRIPTION car_portal CONNECTION 'dbname=car_portal host=publisher user=car_portal_app' PUBLICATION car_portal;
