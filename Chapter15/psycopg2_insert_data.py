#!/usr/bin/python3

from psycopg2 import connect

conn = connect(host="localhost", user="car_portal_app", dbname="car_portal")

with conn.cursor() as cur:
    new_make = "Ford"
    new_model = "Mustang"
    query = "INSERT INTO car_portal_app.car_model (make, model) " \
            "VALUES (%s, %s)"
    cur.execute(query, [new_make, new_model])

conn.commit()
conn.close()
