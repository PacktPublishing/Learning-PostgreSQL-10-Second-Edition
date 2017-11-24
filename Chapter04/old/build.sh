#!/bin/bash
make -f makefile
sudo cp fact.so $(pg_config --pkglibdir)/
psql -d template1 -c "CREATE FUNCTION fact(INTEGER) RETURNS INTEGER AS 'fact', 'fact' LANGUAGE C STRICT;"
psql -d template1 -c "SELECT fact(5);"