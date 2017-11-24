#!/bin/bash
sudo su - postgres

pgbench -i
pgbench -t 1000 -c 15 -f test.sql

psql -U postgres << EOF
ALTER SYSTEM RESET ALL;
ALTER SYSTEM SET fsync to off;
EOF
/etc/init.d/postgresql restart
pgbench -t 1000 -c 15 -f test.sql

psql -U postgres << EOF
ALTER SYSTEM RESET ALL;
ALTER SYSTEM SET synchronous_commit to off;
ALTER SYSTEM SET commit_delay to 100000;
EOF
/etc/init.d/postgresql restart
pgbench -t 1000 -c 15 -f test.sql