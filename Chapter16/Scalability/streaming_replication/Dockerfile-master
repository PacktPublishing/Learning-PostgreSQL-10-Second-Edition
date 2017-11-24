FROM ubuntu:16.04

RUN apt-get update 

RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main" >  /etc/apt/sources.list.d/pgdg.list && \
	apt-get install -y wget && \
	wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
	apt-get update && \
	apt-get install -y language-pack-en && \
	apt-get install -y postgresql-10    

ADD *.sql ./

RUN sed -i 's/md5/trust/g' /etc/postgresql/10/main/pg_hba.conf && \
	echo "host  all  car_portal_app  0.0.0.0/0  trust" >> /etc/postgresql/10/main/pg_hba.conf && \
	echo "host  replication  streamer  0.0.0.0/0  trust" >> /etc/postgresql/10/main/pg_hba.conf && \
	echo "listen_addresses = '*'" >> /etc/postgresql/10/main/postgresql.conf && \
	echo "wal_level = replica" >> /etc/postgresql/10/main/postgresql.conf && \
	echo "max_wal_senders = 1" >> /etc/postgresql/10/main/postgresql.conf && \
	echo "max_replication_slots = 1" >> /etc/postgresql/10/main/postgresql.conf && \
	service postgresql start && \
	psql -h localhost -U postgres -f master.sql && \
	service postgresql stop && \
	echo "synchronous_standby_names = 'standby1'" >> /etc/postgresql/10/main/postgresql.conf

VOLUME /etc/postgresql/10/main
VOLUME /var/lib/postgresql/10/main

ENTRYPOINT ["su", "-", "postgres", "-c", "/usr/lib/postgresql/10/bin/postgres --config-file=/etc/postgresql/10/main/postgresql.conf"]