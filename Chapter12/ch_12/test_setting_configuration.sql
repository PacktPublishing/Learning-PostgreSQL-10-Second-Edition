SELECT current_setting('work_mem');
show work_mem;
SELECT set_config('work_mem', '8 MB', false);
SELECT set_config('shared_buffers', '1 GB', false);
SELECT name, current_setting(name), source FROM pg_settings WHERE source IN ('configuration file');