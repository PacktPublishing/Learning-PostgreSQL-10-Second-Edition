MODULES = fact

PG_CONFIG = pg_config
PGXS = $(shell $(PG_CONFIG) --pgxs)
INCLUDEDIR = $(shell $(PG_CONFIG) --includedir-server)
include $(PGXS)

fact.so: fact.o
	cc -shared -o fact.so fact.o

fact.o: fact.c
	cc -o fact.o -c fact.c $(CFLAGS) -I$(INCLUDEDIR)