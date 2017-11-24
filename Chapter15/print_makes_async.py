#!/usr/bin/python3

from psycopg2 import connect
from psycopg2.extras import wait_select
from time import sleep

aconn = connect(host="localhost", user="car_portal_app", dbname="car_portal",
                async=1)
wait_select(aconn)

acur = aconn.cursor()
acur.execute("SELECT DISTINCT make FROM car_portal_app.car_model, "
             "pg_sleep(10)")

for i in range(8):
    print("waiting... " + str(i))
    sleep(1)

wait_select(aconn)

for row in acur:
    print(row[0])

acur.close()
aconn.close()
