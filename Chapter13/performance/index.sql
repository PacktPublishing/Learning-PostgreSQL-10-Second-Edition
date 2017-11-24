CREATE TABLE success_story (id int, description text, guru_id int references guru(id));
INSERT INTO success_story (id, description, guru_id) SELECT n, md5(n::text), random()*99999+1 from generate_series(1,200000) as foo(n) ;
EXPLAIN ANALYZE SELECT * FROM guru inner JOIN success_story on guru.id =success_story.guru_id WHERE guru_id = 1000;
CREATE index on success_story (guru_id);
EXPLAIN ANALYZE SELECT * FROM guru inner JOIN success_story on guru.id =success_story.guru_id WHERE guru_id = 1000;

CREATE OR REPLACE FUNCTION generate_random_text ( int ) RETURNS TEXT AS
$$
	SELECT string_agg(substr('0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ', trunc(random() * 62)::integer + 1, 1), '') FROM generate_series(1, $1)
$$
LANGUAGE SQL;

CREATE TABLE login as SELECT n, generate_random_text(8) as login_name FROM generate_series(1, 1000) as foo(n);
CREATE INDEX ON login(login_name);
VACUUM ANALYZE login;

EXPLAIN SELECT * FROM login WHERE login_name = 'jxaG6gjJ';
EXPLAIN SELECT * FROM login WHERE login_name = lower('jxaG6gjJ');
EXPLAIN SELECT * FROM login WHERE lower(login_name) = lower('jxaG6gjJ');
CREATE INDEX ON login(lower(login_name));
analyze login;
EXPLAIN SELECT * FROM login WHERE lower(login_name) = lower('jxaG6gjJ');
CREATE INDEX on login (login_name text_pattern_ops);
EXPLAIN ANaLYZE SELECT * FROM login WHERE login_name like 'a%';
CREATE INDEX login_lower_idx1 ON login (lower(login_name) text_pattern_ops);
EXPLAIN ANaLYZE SELECT * FROM login WHERE lower(login_name) like 'a%';
