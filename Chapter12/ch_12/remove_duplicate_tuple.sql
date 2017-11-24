CREATE TABLE duplicate AS SELECT (random () * 9 + 1)::INT as f1 , (random () * 9 + 1)::INT as f2 FROM generate_series (1,40);
SELECT count(*), f1, f2 FROM duplicate GROUP BY f1, f2;
SELECT ctid, f1, f2 FROM duplicate;
DELETE FROM duplicate a USING duplicate b WHERE a.f1= b.f1 and a.f2= b.f2 and a.ctid > b.ctid;
