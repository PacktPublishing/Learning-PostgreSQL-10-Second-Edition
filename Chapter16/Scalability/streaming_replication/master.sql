CREATE USER streamer REPLICATION;
SELECT * FROM pg_create_physical_replication_slot('slot1');