CREATE TABLE car_log (LIKE car);
ALTER TABLE car_log ADD COLUMN car_log_action varchar (1) NOT NULL, ADD COLUMN car_log_time TIMESTAMP WITH TIME ZONE NOT NULL;

CREATE RULE car_log AS ON INSERT TO car DO ALSO
INSERT INTO car_log (car_id, number_of_owners, regestration_number, number_of_doors, car_log_action, car_log_time) VALUES (new.car_id, new.number_of_owners, new.regestration_number, new.number_of_doors, 'I', now());

INSERT INTO car (car_id, number_of_owners, regestration_number, number_of_doors) VALUES (1, 2, '2015xyz', 3);

TRUNCATE car CASCADE;
TRUNCATE car CAScade;
INSERT INTO car (car_id, number_of_owners, regestration_number, number_of_doors) VALUES (DEFAULT, 2, '2015xyz', 3);

TABLE car;
TABLE car_log;