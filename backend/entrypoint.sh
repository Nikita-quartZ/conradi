#!/bin/sh
exec gunicorn --bind 0.0.0.0:5050 --workers 2 --access-logfile - "app:create_app()"
