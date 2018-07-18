#!/bin/sh

cd $(dirname $0)

if [ "$1"  == "--local-dev" ]; then
  PORT=8000
else
  PORT=80
fi

# require that commands run successfully
set -e

# wait for Postgres to start
# sleep 10

# migrate the database schema as necessary
python manage.py migrate

# run the rest services
python manage.py runserver 0.0.0.0:$PORT
