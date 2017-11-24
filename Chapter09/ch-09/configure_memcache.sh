#!/bin/bash
echo "pgmemcache.default_servers = 'localhost'">>/etc/postgresql/10/main/postgresql.conf
/etc/init.d/postgresql reload