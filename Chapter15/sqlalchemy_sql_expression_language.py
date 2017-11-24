#!/usr/bin/python3

from sqlalchemy import *

engine = create_engine(
    "postgresql+pg8000://car_portal_app@localhost/car_portal",
    echo=True)

metadata = MetaData()

# Defining the table car_model explicitly
car_model = Table(
    'car_model', metadata,
    Column('car_model_id', Integer, primary_key=True),
    Column('make', String),
    Column('model', String),
    schema='car_portal_app')

# Loading the definition of the table car from the database
car = Table('car', metadata, schema='car_portal_app',
            autoload=True, autoload_with=engine)

# Print the names of the columns of the table car
for column in car.columns:
    print(column)

# Obtaining a database connection
conn = engine.connect()

# Query car models
query = select([car_model])
result = conn.execute(query)
for row in result:
    print(row)

# Create a new car model
ins = car_model.insert()
conn.execute(ins, [
    {'make': 'Jaguar', 'model': 'XF'},
    {'make': 'Jaguar', 'model': 'XJ'}])
print(ins)

# Query the new model
query = select([car_model]).where(car_model.c.make == "Jaguar")
for record in conn.execute(query):
    print(record)
