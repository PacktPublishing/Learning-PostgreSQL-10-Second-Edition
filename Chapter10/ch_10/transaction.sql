BEGIN;
CREATE TABLE employee (id serial primary key, name text, salary numeric);
COMMIT;

BEGIN;
UPDATE employee set salary = salary*1.1;
SAVEPOINT increase_salary;
UPDATE employee set salary = salary + 500 WHERE name =’john’;
ROLLBACK to increase_salary;
COMMIT;


SELECT txid_current();
SELECT 1;
SELECT txid_current();

BEGIN;
SELECT txid_current();
SELECT 1;
SELECT txid_current();

 CREATE TABLE  test_tx_level AS SELECT 1 as val;

-------------------------------------------------- repeatable read
 --- session 1
BEGIN;
SELECT * FROM test_tx_level ;

 --- session 2
BEGIN;
UPDATE test_tx_level SET val = 2;
COMMIT;

---  session1
SELECT * FROM test_tx_level ;
COMMIT;


-------------------------------------------------- phantom read
 --- session 1
BEGIN;
SELECT count(*) FROM test_tx_level ;

 --- session 2
BEGIN;
INSERT INTO test_tx_level SELECT 2;
COMMIT;

---  session1
SELECT count(*) FROM test_tx_level ;
COMMIT;



-------------------------------------------------- phantom read /serializable
 --- session 1
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE ;
SELECT count(*) FROM test_tx_level ;

 --- session 2
BEGIN;
INSERT INTO test_tx_level SELECT 2;
COMMIT;

---  session1
SELECT count(*) FROM test_tx_level ;
COMMIT;


---------------------------------------------- Repeatabl read anamoly
CREATE TABLE zero_or_one (val int);
INSERT INTO zero_or_one SELECT n % 2 FROM generate_series(1,10) as foo(n) ;
SELECT array_agg(val) FROM zero_or_one ;


-- session 1
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ ;
UPDATE zero_or_one SET val = 1 WHERE val = 0;
--- session 2
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ ;
UPDATE zero_or_one SET val =0 WHERE val =1;
COMMIT;
-- session 1
COMMIT;

SELECT * FROM zero_or_one ;


---------------------------------------------- with serializable
truncate zero_or_one ;
INSERT INTO zero_or_one SELECT n % 2 FROM generate_series(1,10) as foo(n) ;



--- sesion 1
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE ;
UPDATE zero_or_one SET val = 1 WHERE val = 0;

--- session2
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE ;
UPDATE zero_or_one SET val =0 WHERE val =1;
COMMIT;
---

SELECT array_agg(val) FROM zero_or_one ;

--------------------------------------------- Lock level
--- session1
BEGIN;
SELECT COUNT(*) FROM test_tx_level ;
SELECT mode, granted FROM pg_locks where relation ='test_tx_level'::regclass::oid;

--- Session 2

BEGIN;
DROP TABLE test_tx_level;

--- session1
SELECT mode, granted FROM pg_locks where relation ='test_tx_level'::regclass::oid;


-------------------------------------------- pg_locks info

CREATE OR REPLACE VIEW lock_info AS
SELECT
    lock1.pid as locked_pid,
    stat1.usename as locked_user,
    stat1.query as locked_statement,
    stat1.state as locked_statement_state,
    stat2.query as locking_statement,
    stat2.state as locking_statement_state,
    now() - stat1.query_start as locking_duration,
    lock2.pid as locking_pid,
    stat2.usename as locking_user
FROM pg_catalog.pg_locks lock1
     JOIN pg_catalog.pg_stat_activity stat1 on lock1.pid = stat1.pid
     JOIN pg_catalog.pg_locks lock2 on
    (lock1.locktype,lock1.database,lock1.relation,lock1.page,lock1.tuple,lock1.virtualxid,lock1.transactionid,lock1.classid,lock1.objid,lock1.objsubid) IS NOT DISTINCT FROM
        (lock2.locktype,lock2.DATABASE,lock2.relation,lock2.page,lock2.tuple,lock2.virtualxid,lock2.transactionid,lock2.classid,lock2.objid,lock2.objsubid)
     JOIN pg_catalog.pg_stat_activity stat2 on lock2.pid = stat2.pid
WHERE NOT lock1.granted AND lock2.granted;

SELECT * FROM lock_info


----------------------------------------- row level locks

truncate test_tx_level ;
insert into test_tx_level Values(1), (2);


--- Session 1
BEGIN;
SELECT * FROM test_tx_level WHERE val = 1 FOR update;

--- Session2
BEGIN;
update test_tx_level SET val =2 WHERE val =1;

SELECT * FROM lock_info ;


--------------------------------------- deadlock

--- session 1
begin;
SELECT * FROM test_tx_level WHERE val = 1 FOR SHARE;

---session 2
begin;
SELECT * FROM test_tx_level WHERE val = 1 FOR SHARE;

--- session 1
UPDATE test_tx_level SET val = 2 WHERE val=1;

--- session 2
UPDATE test_tx_level SET val = 2 WHERE val=1;

------------------------------------------advisory locks

---  session1
SELECT pg_try_advisory_lock(1);

--- session2
SELECT pg_try_advisory_lock(1);

--- session 1
select pg_advisory_unlock(1);

--- session2
SELECT pg_try_advisory_lock(1);

------------------------------
SELECT pg_try_advisory_lock(1);
SELECT pg_try_advisory_lock(1);
-- To release
select pg_advisory_unlock(1);
select pg_advisory_unlock(1);

