SELECT 'pg_catalog.pg_class'::regclass::oid;
SELECT 1259::regclass::text;
SELECT c.oid FROM pg_class c join pg_namespace n ON (c.relnamespace = n.oid) WHERE relname ='pg_class' AND nspname ='pg_catalog';