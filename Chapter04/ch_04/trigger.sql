CREATE OR REPLACE FUNCTION car_log_trg () RETURNS TRIGGER AS
$$
BEGIN
IF TG_OP = 'INSERT' THEN
		INSERT INTO car_log SELECT NEW.*, 'I', NOW();
ELSIF TG_OP = 'UPDATE' THEN
		INSERT INTO car_log SELECT NEW.*, 'U', NOW();
ELSIF TG_OP = 'DELETE' THEN
		INSERT INTO car_log SELECT OLD.*, 'D', NOW();
END IF;
RETURN NULL; --ignored since this is after trigger
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER car_log AFTER INSERT OR UPDATE OR DELETE ON car FOR EACH ROW EXECUTE PROCEDURE car_log_trg ();


SET search_path to car_portal_app;
CREATE extension hstore;
CREATE TABLE car_portal_app.log
(
		schema_name text NOT NULL,
		table_name text NOT NULL,
		old_row hstore,
		new_row hstore,
		action TEXT check (action IN ('I','U','D')) NOT NULL,
		created_by text NOT NULL,
		created_on timestamp without time zone NOT NULL
);

CREATE OR REPLACE FUNCTION car_portal_app.log_audit() RETURNS trigger AS
$$
DECLARE
		log_row log;
		excluded_columns text[] = NULL;
BEGIN
		log_row = ROW (TG_TABLE_SCHEMA::text, TG_TABLE_NAME::text,NULL,NULL,NULL,current_user::TEXT,
current_timestamp);

		IF TG_ARGV[0] IS NOT NULL THEN excluded_columns = TG_ARGV[0]::text[]; END IF;

		IF (TG_OP = 'INSERT') THEN
				log_row.new_row = hstore(NEW.*) - excluded_columns;
				log_row.action ='I';
		ELSIF (TG_OP = 'UPDATE' AND (hstore(OLD.*) - excluded_columns!= hstore(NEW.*)-excluded_columns)) THEN
				log_row.old_row = hstor(OLD.*) - excluded_columns;
				log_row.new_row = hstore(NEW.* )- excluded_columns;
				log_row.action ='U';
		ELSIF (TG_OP = 'DELETE') THEN
				log_row.old_row = hstore (OLD.*) - excluded_columns;
				log_row.action ='D';
		ELSE
				RETURN NULL; -- update on excluded columns
		END IF;
		INSERT INTO log SELECT log_row.*;
		RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER car_log_trg AFTER INSERT OR UPDATE OR DELETE ON car_portal_app.car FOR EACH ROW EXECUTE PROCEDURE log_audit('{number_of_doors}');

INSERT INTO car (car_id, car_model_id, number_of_owners, registration_number, number_of_doors, manufacture_year) VALUES (default, 2, 2, 'z', 3, 2017);
SELECT jsonb_pretty((to_json(log))::jsonb) FROM car_portal_app.log WHERE action = 'I' and new_row->'registration_number'='z';

CREATE OR REPLACE VIEW seller_account_info AS SELECT account.account_id, first_name, last_name, email, password, seller_account_id, total_rank, number_of_advertisement, street_name, street_number, zip_code , city
FROM
	account INNER JOIN
	seller_account ON (account.account_id = seller_account.account_id);


SELECT is_insertable_into FROM information_schema.tables WHERE table_name = 'seller_account_info';

CREATE OR REPLACE FUNCTION seller_account_info_update () RETURNS TRIGGER AS $$
DECLARE
		acc_id INT;
		seller_acc_id INT;
BEGIN
		IF (TG_OP = 'INSERT') THEN
				WITH inserted_account AS (
						INSERT INTO car_portal_app.account (account_id, first_name, last_name, password, email) VALUES (DEFAULT, NEW.first_name, NEW.last_name, NEW.password, NEW.email) RETURNING account_id
			), inserted_seller_account AS (
			INSERT INTO car_portal_app.seller_account(seller_account_id, account_id, total_rank, number_of_advertisement, street_name, street_number, zip_code, city)
			SELECT nextval('car_portal_app.seller_account_seller_account_id_seq'::regclass), account_id, NEW.total_rank, NEW.number_of_advertisement, NEW.street_name, NEW.street_number, NEW.zip_code, NEW.city FROM inserted_account RETURNING account_id, seller_account_id)
			SELECT account_id, seller_account_id INTO acc_id, seller_acc_id FROM inserted_seller_account;
		NEW.account_id = acc_id;
		NEW.seller_account_id = seller_acc_id;
		RETURN NEW;
	ELSIF (TG_OP = 'UPDATE' AND OLD.account_id = NEW.account_id AND OLD.seller_account_id = NEW.seller_account_id) THEN
		UPDATE car_portal_app.account SET first_name = new.first_name, last_name = new.last_name, password= new.password, email = new.email WHERE account_id = new.account_id;
		UPDATE car_portal_app.seller_account SET total_rank = NEW.total_rank, number_of_advertisement= NEW.number_of_advertisement, street_name= NEW.street_name, street_number = NEW.street_number, zip_code = NEW.zip_code, city = NEW.city WHERE seller_account_id = NEW.seller_account_id;
		RETURN NEW;
	ELSIF (TG_OP = 'DELETE') THEN
		DELETE FROM car_portal_app.seller_account WHERE seller_account_id = OLD.seller_account_id;
		DELETE FROM car_portal_app.account WHERE account_id = OLD.account_id;
		RETURN OLD;
	ELSE
		RAISE EXCEPTION 'An error occurred for % operation', TG_OP;
		RETURN NULL;
	END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER seller_account_info_trg INSTEAD OF INSERT OR UPDATE OR DELETE ON car_portal_app.seller_account_info FOR EACH ROW EXECUTE PROCEDURE seller_account_info_update ();

INSERT INTO car_portal_app.seller_account_info (first_name,last_name, password, email, total_rank, number_of_advertisement, street_name, street_number, zip_code, city) VALUES ('test_first_name', 'test_last_name', 'test_password', 'test_email@test.com', NULL, 0, 'test_street_name', 'test_street_number', 'test_zip_code','test_city') RETURNING account_id, seller_account_id;

UPDATE car_portal_app.seller_account_info set email = 'test2@test.com' WHERE seller_account_id=147 RETURNING seller_account_id;

DELETE FROM car_portal_app.seller_account_info WHERE seller_account_id=147;
DELETE FROM car_portal_app.seller_account_info;


