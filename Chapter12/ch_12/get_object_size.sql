SELECT pg_database.datname, pg_size_pretty(pg_database_size(pg_database.datname)) AS size FROM pg_database;
SELECT tablename, pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) FROM pg_tables LIMIT 2;
SELECT indexrelid::regclass, pg_size_pretty(pg_relation_size(indexrelid::regclass)) FROM pg_index LIMIT 2;