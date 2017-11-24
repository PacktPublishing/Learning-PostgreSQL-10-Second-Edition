CREATE OR REPLACE FUNCTION monitor_view_usage (view_name TEXT) RETURNS BOOLEAN AS $$
BEGIN
    RAISE LOG 'The view % is used on % by % ', view_name, current_time, session_user;
    RETURN TRUE;
END;
$$LANGUAGE plpgsql cost .001;

CREATE OR REPLACE VIEW dummy_view AS
SELECT dummy_text FROM (VALUES('dummy')) as dummy(dummy_text);

-- Recreat the view and inject the monitor_view_usage
CREATE OR REPLACE VIEW dummy_view AS
SELECT dummy_text FROM (VALUES('dummy')) as dummy(dummy_text) cross join monitor_view_usage('dummy_view');

SELECT * FROM dummy_view;
