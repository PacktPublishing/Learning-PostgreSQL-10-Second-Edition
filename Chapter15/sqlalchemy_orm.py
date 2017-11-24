#!/usr/bin/python3

from sqlalchemy import *
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, relationship

engine = create_engine(
    "postgresql+pg8000://car_portal_app@localhost/car_portal",
    echo=False)

Base = declarative_base()
Session = sessionmaker(bind=engine)


class Car_model(Base):
    __tablename__ = "car_model"
    __table_args__ = {'schema': 'car_portal_app'}

    car_model_id = Column(Integer, primary_key=True)
    make = Column(String)
    model = Column(String)


class Car(Base):
    __tablename__ = "car"
    __table_args__ = {'schema': 'car_portal_app'}

    car_id = Column(Integer, primary_key=True)
    number_of_owners = Column(Integer, nullable=False)
    registration_number = Column(String, nullable=False)
    manufacture_year = Column(Integer, nullable=False)
    number_of_doors = Column(Integer, nullable=False)
    car_model_id = Column(Integer, ForeignKey(Car_model.car_model_id),
                          nullable=False)
    mileage = Column(Integer)
    car_model = relationship(Car_model)

    def __repr__(self):
        car_text = ("Car: ID={}, {} {}, Registration plate: '{}', "
                    "Number of owners: {}, Manufacture year: {}, "
                    "Number of doors: {}".format(
                        self.car_id, self.car_model.make, self.car_model.model,
                        self.registration_number,
                        self.number_of_owners, self.manufacture_year,
                        self.number_of_doors))
        if self.mileage is not None:
            car_text = car_text + ", Mileage: {}".format(self.mileage)
        return car_text


# Query cars
session = Session()

query = session.query(Car).order_by(Car.car_id).limit(5)
for car in query.all():
    print(car)

# Update a car
car = query.first()
car.registration_number = 'BOND007'
print(query.first())

session.commit()
session.close()

# Create a new car model
new_car_model = Car_model(make="Jaguar", model="XE")
session = Session()
session.add(new_car_model)
session.commit()
session.close()

# Delete a car model
session = Session()
old_car_model = session.query(Car_model).filter(
    and_(Car_model.make == "Jaguar", Car_model.model == "XE")).one()
session.delete(old_car_model)
session.commit()
session.close()
