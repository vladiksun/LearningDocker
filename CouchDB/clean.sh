#!/usr/bin/env bash

docker-compose -f ./docker-compose.yml stop server-2 server-0 server-1
docker-compose rm -f server-0
docker-compose rm -f server-1
docker-compose rm -f server-2