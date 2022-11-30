#!/bin/bash
##
##

echo "[+] starting redis server"
redis-server &
#systemctl start redis-server
sleep 10

echo "[+] configuring acccess keys"
echo $KAMERKA_KEY | jq . > keys.json

echo "[+] preparing kamerka databases"
python3 manage.py makemigrations
python3 manage.py migrate

echo "[+] setting up kamerka celery worker "
celery --app kamerka worker &
sleep 5

echo "[+] starting kamerka web interface"
python3 manage.py runserver 0.0.0.0:8000


