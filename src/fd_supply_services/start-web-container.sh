#!/bin/sh

cd $(dirname $0)

# require that commands run successfully
set -e

# wait for Postgres to start
# sleep 10

# migrate the database schema as necessary
python manage.py migrate

# run the rest services
python manage.py runserver 0.0.0.0:8000
