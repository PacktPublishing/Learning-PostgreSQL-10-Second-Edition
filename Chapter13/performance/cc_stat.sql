CREATE TABLE client (
    id serial primary key,
    name text,
    country text,
    language text
);

INSERT INTO client(name, country, language) SELECT generate_random_text(8), 'Germany', 'German' FROM generate_series(1, 10);
INSERT INTO client(name, country, language) SELECT generate_random_text(8), 'USA', 'English' FROM generate_series(1, 10);
VACUUM ANALYZE client;

EXPLAIN SELECT * FROM client WHERE country = 'Germany' and language='German';

CREATE TABLE client2 (
    id serial primary key,
    name text,
    client_information jsonb
);
INSERT INTO client2(name, client_information) SELECT generate_random_text(8),'{"country":"Germany", "language":"German"}' FROM generate_series(1,10);
INSERT INTO client2(name, client_information) SELECT generate_random_text(8),'{"country":"USA", "language":"English"}' FROM generate_series(1, 10);
VACUUM ANALYZE client2;
EXPLAIN SELECT * FROM client2 WHERE client_information = '{"country":"USA","language":"English"}';

CREATE STATISTICS stats (dependencies) ON country, language FROM client;
analyze client;
SELECT stxname, stxkeys, stxdependencies FROM pg_statistic_ext WHERE stxname = 'stats';
EXPLAIN SELECT * FROM client WHERE country = 'Germany' and language='German';
