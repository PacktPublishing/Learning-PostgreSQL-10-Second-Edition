-- Get the content of pg_hba.conf file
SELECT * FROM pg_hba_file_rules limit 1;

-- PostgreSQL default access privileges

CREATE ROLE test_user LOGIN;
CREATE DATABASE test
\c test
CREATE TABLE test_permissions(id serial , name text);
SET ROLE test_user;
\d
\du

SET ROLE postgres;
REVOKE ALL PRIVILEGES ON SCHEMA PUBLIC FROM public;
SET ROLE test_user;
CREATE TABLE b();

-- Role system and proxy authentication

SELECT session_user, current_user;
SET SESSION AUTHORIZATION test_user;
SELECT session_user, current_user;
--
CREATE ROLE web_app_user LOGIN NOINHERIT;
CREATE ROLE public_user NOLOGIN;
GRANT SELECT ON car_portal_app.advertisement_picture, car_portal_app.advertisement_rating , car_portal_app.advertisement TO public_user;
GRANT public_user TO web_app_user;
GRANT USAGE ON SCHEMA car_portal_app TO web_app_user, public_user;

---  PostgreSQL security levels
-- Column permisions
CREATE DATABASE test_column_acl;
\c test_column_acl;
CREATE TABLE test_column_acl AS SELECT * FROM (values (1,2), (3,4)) as n(f1, f2);
CREATE ROLE test_column_acl;
GRANT SELECT (f1) ON test_column_acl TO test_column_acl;

---- RLS
CREATE DATABASE test_rls;
\c test_rls
CREATE USER admin;
CREATE USER guest;
CREATE TABLE account (
  account_name NAME,
  password TEXT
  );
INSERT INTO account VALUES('admin', 'admin'), ('guest', 'guest');
GRANT ALL ON  account to admin, guest;
ALTER TABLE account ENABLE ROW LEVEL SECURITY;

CREATE POLICY account_policy_user ON account USING (account_name = current_user);
CREATE POLICY account_policy_write_protected ON account USING (true) WITH CHECK (account_name = current_user);
CREATE POLICY account_policy_time ON account AS RESTRICTIVE USING ( date_part('hour', statement_timestamp()) BETWEEN 8 AND 16 ) WITH CHECK (account_name = current_user);

-- Data encryption
CREATE TABLE account_md5 (id INT, password TEXT);
INSERT INTO account_md5 VALUES (1, md5('my password'));
SELECT (md5('my password') = password) AS authenticated FROM account_md5;


CREATE TABLE account_crypt (id INT, password TEXT);
INSERT INTO account_crypt VALUES (1, crypt ('my password', gen_salt('md5')));
INSERT INTO account_crypt VALUES (2, crypt ('my password', gen_salt('md5')));
SELECT * FROM account_crypt;
SELECT crypt ('my password', password) = password AS authenticated FROM account_crypt;

\timing
SELECT crypt('my password', gen_salt('bf',4));
SELECT crypt('my password', gen_salt('bf',16));


--two-way encryption
SELECT encrypt ('Hello World', 'Key', 'aes');
SELECT decrypt(encrypt ('Hello World', 'Key', 'aes'),'Key','aes');
SELECT convert_from(decrypt(encrypt ('Hello World', 'Key', 'aes'),'Key','aes'), 'utf-8');


--A symetric two-way encryption
CREATE OR REPLACE FUNCTION encrypt (text) RETURNS bytea AS
$$
BEGIN
  RETURN pgp_pub_encrypt($1, dearmor(pg_read_file('public.key')));
END;
$$ Language plpgsql;
CREATE OR REPLACE FUNCTION decrypt (bytea) RETURNS text AS
$$
BEGIN
  RETURN pgp_pub_decrypt($1, dearmor(pg_read_file('secret.key')));
END;
$$ Language plpgsql;

SELECT substring(encrypt('Hello World'), 1, 50);
SELECT decrypt(encrypt('Hello World'));