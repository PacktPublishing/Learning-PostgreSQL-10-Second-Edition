CREATE DOMAIN text_without_space_and_null AS TEXT NOT NULL CHECK (value!~ '\s');
CREATE TABLE test_domain (
	test_att text_without_space_and_null
);
INSERT INTO test_domain values ('hello');
INSERT INTO test_domain values ('hello world');
INSERT INTO test_domain values (null);

CREATE SEQUENCE global_id_seq;
CREATE DOMAIN global_serial INT DEFAULT NEXTVAL('global_id_seq') NOT NULL;


ALTER DOMAIN text_without_space_and_null ADD CONSTRAINT text_without_space_and_null_length_chk check (length(value)<=15);

ALTER DOMAIN text_without_space_and_null ADD CONSTRAINT text_without_ space_and_null_length_chk check (length(value)<=15) NOT VALID;

CREATE TYPE seller_information AS (seller_id INT, seller_name TEXT,number_of_advertisements BIGINT, total_rank float);

CREATE OR REPLACE FUNCTION seller_information (account_id INT ) RETURNS seller_information AS
$$
SELECT seller_id, first_name || last_name as seller_name, count(*), sum(rank)::float/count(*)
FROM account INNER JOIN
    seller_account ON account.account_id = seller_account.account_id LEFT JOIN
    advertisement ON advertisement.seller_account_id = seller_account.seller_account_id LEFT JOIN
    advertisement_rating ON advertisement.advertisement_id = advertisement_rating.advertisement_id
WHERE account.account_id = $1
GROUP BY seller_id, first_name, last_name
$$
LANGUAGE SQL;


CREATE TABLE rank (
    rank_id SERIAL PRIMARY KEY,
    rank_name TEXT NOT NULL
);
INSERT INTO rank VALUES (1, 'poor') , (2, 'fair'), (3, 'good') , (4,'very good') ,( 5, 'excellent');

CREATE TYPE rank AS ENUM ('poor', 'fair', 'good', 'very good','excellent');
SELECT enum_range(null::rank);
SELECT unnest(enum_range(null::rank)) order by 1 desc;
