#!/bin/bash

# get virtual environment and pip
sudo apt-get install pip
sudo pip install --upgrade pip
sudo pip install virtualenvwrapper

# create a virtual environment and activate it
virtualenv pgadmin && cd pgadmin && source bin/activate

# get recent version f pgadmin and install it.
wget https://ftp.postgresql.org/pub/pgadmin/pgadmin4/v2.0/pip/pgadmin4-2.0-py2.py3-none-any.whl
pip install pgadmin4-2.0-py2.py3-none-any.whl

# create a configuration based on config.py and run it
cp ./lib/python2.7/site-packages/pgadmin4/config.py ./lib/python2.7/site-packages/pgadmin4/config-local.py
python  ./lib/python2.7/site-packages/pgadmin4/pgAdmin4.py