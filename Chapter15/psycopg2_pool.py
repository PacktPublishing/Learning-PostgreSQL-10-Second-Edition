#!/usr/bin/python3

from psycopg2.pool import ThreadedConnectionPool
from multiprocessing.pool import ThreadPool


pool = ThreadedConnectionPool(0, 2, host="localhost", user="car_portal_app",
                              dbname="car_portal")

queries = ["SELECT 1 FROM pg_sleep(10)",
           "SELECT 2 FROM pg_sleep(10)",
           "SELECT 3 FROM pg_sleep(10)"]


def execute_query(query):
    conn = pool.getconn(query)
    with conn.cursor() as cur:
        cur.execute(query)
        row = cur.fetchone()
        value = row[0]
    pool.putconn(conn, query)
    return value


thread_pool = ThreadPool(2)
results = thread_pool.map(execute_query, queries)

print(results)

pool.closeall()
