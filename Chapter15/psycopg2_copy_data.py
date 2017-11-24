#!/usr/bin/python3

from psycopg2 import connect
from io import StringIO

conn = connect(host="localhost", user="car_portal_app", dbname="car_portal")

with conn.cursor() as cur, StringIO() as s:
    cur.copy_to(table='car_portal_app.car_model', file=s)
    print(s.getvalue())


new_records = [
    ["Tesla", "Model X"],
    ["Tesla", "Model S"],
    ["Tesla", "Model 3"]]

copy_string = '\n'.join(['\t'.join(record) for record in new_records])

with conn.cursor() as cur, StringIO(copy_string) as s:
    cur.copy_from(table='car_portal_app.car_model', file=s,
                  columns=['make', 'model'])

conn.commit()
conn.close()
