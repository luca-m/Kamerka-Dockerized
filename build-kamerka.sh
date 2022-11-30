#/bin/bash
#

if [ "$1" = "--delete" ]; then
docker image rm kamerka:1.0 -f

exit 0
fi 

docker build -t kamerka:1.0 .
docker run --memory 4096m --cpu-shares 2048 -p 8000:8000 --env-file test-kamerka.env kamerka:1.0
