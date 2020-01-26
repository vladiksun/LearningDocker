#!/usr/bin/env bash

#############################################  Chapter 2  #################################################

docker run --detach --name web nginx:latest

docker build -t mailer .
docker run -d --name mailer mailer:latest

docker run --interactive --tty --link web:web --name web_test busybox:latest /bin/sh

docker build -t agent .
docker run -it --name agent --link web:insideweb --link mailer:insidemailer agent

docker logs web

docker stop web

docker logs mailer

docker run -d --name wp --read-only wordpress:4

docker run -d --name wpdb -e MYSQL_ROOT_PASSWORD=ch2demo mysql:5
docker run -d --name wp2 --link wpdb:mysql -p 80 --read-only wordpress:4
docker inspect --format "{{.State.Running}}" wp2


# Start the container with specific volumes for read only exceptions
docker run -d --name wp3 --link wpdb:mysql -p 80 \
-v /run/lock/apache2/ \
-v /run/apache2/ \
--read-only wordpress:4


docker run --env MY_ENVIRONMENT_VAR="this is a test" \
busybox:latest \
env


docker run -d -p 80:80 --name lamp-test tutum/lamp
docker top lamp-test
docker exec lamp-test ps
docker exec lamp-test kill <PID>