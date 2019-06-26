#!/usr/bin/env bash

DB_CID=$(docker run -d -e MYSQL_ROOT_PASSWORD=ch2demo mysql:5)
MAILER_CID=$(docker run -d dockerinaction/ch2_mailer)

if [ ! -n "$CLIENT_ID" ]; then
    echo "Client ID not set”
    exit 1
fi


WP_CID=$(docker create \
--link $DB_CID:mysql \
--name wp_$CLIENT_ID \
-p 80 \
-v /run/lock/apache2/ -v /run/apache2/ \
-e WORDPRESS_DB_NAME=$CLIENT_ID \
--read-only wordpress:4)

docker start $WP_CID

AGENT_CID=$(docker create \
--name agent_$CLIENT_ID \
--link $WP_CID:insideweb \
--link $MAILER_CID:insidemailer \
dockerinaction/ch2_agent)
docker start $AGENT_CID