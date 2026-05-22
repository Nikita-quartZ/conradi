#!/bin/sh
set -e

echo "Применяю миграции БД..."
flask db upgrade

echo "Проверяю наличие админа..."
flask create-admin "${ADMIN_LOGIN:-admin}" "${ADMIN_PASSWORD:-admin123}" || true

echo "Заполняю каталог из дампа (если пусто)..."
python ../migration/migrate_data.py || true

echo "Запускаю gunicorn на :5050"
exec gunicorn --bind 0.0.0.0:5050 --workers 2 --access-logfile - "app:create_app()"
