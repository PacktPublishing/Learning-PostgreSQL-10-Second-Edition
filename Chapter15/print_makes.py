#!/usr/bin/python3

from psycopg2 import connect

conn = connect(host="localhost", user="car_portal_app", dbname="car_portal")

with conn.cursor() as cur:
    cur.execute("SELECT DISTINCT make FROM car_portal_app.car_model")
    for row in cur:
        print(row[0])

conn.close()
