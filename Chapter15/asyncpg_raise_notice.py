#!/usr/bin/python3

import asyncio
import asyncpg


async def main():
    conn = await asyncpg.connect(host='localhost', user='car_portal_app',
                                 database='car_portal')

    conn.add_log_listener(lambda conn, msg: print(msg))

    print("Executing a command")
    await conn.execute('''
        DO $$
            BEGIN
                RAISE NOTICE 'Start';
                PERFORM pg_sleep(2);
                RAISE NOTICE '1 second';
                PERFORM pg_sleep(2);
                RAISE NOTICE '2 second';
                PERFORM pg_sleep(2);
                RAISE NOTICE 'Finish';
            END;
        $$;''')
    print("Finished execution")

    await conn.close()

asyncio.get_event_loop().run_until_complete(main())
