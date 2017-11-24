#!/usr/bin/python3

from psycopg2 import connect

conn = connect(host="localhost", user="car_portal_app", dbname="car_portal")
query = "SELECT make, model FROM car_portal_app.car_model"

print("--- cursor as iterator ---")
with conn.cursor() as cur:
    cur.execute(query)
    for record in cur:
        print("Make: {}, model: {}".format(record[0], record[1]))

print("--- cursor.fetchone() ---")
with conn.cursor() as cur:
    cur.execute(query)
    while True:
        record = cur.fetchone()
        if record is None:
            break
        print("Make: {}, model: {}".format(record[0], record[1]))

print("--- cursor.fetchmany() ---")
with conn.cursor() as cur:
    cur.execute(query)
    while True:
        records = cur.fetchmany(10)
        if len(records) == 0:
            break
        print("Set of {} records: {}".format(len(records), str(records)))

conn.close()
