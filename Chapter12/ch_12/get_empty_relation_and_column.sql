SELECT relname FROM pg_stat_user_tables WHERE n_live_tup= 0;
SELECT schemaname, tablename, attname FROM pg_stats WHERE null_frac= 1 and schemaname NOT IN ('pg_catalog', 'information_schema');
