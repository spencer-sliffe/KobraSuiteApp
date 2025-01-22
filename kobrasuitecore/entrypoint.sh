#!/bin/bash

set -e

echo "Collecting static files..."
python manage.py collectstatic --noinput

echo "Starting Daphne server..."
exec "$@"


fsdaf