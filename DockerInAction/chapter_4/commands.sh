#!/usr/bin/env bash

#############################################  Chapter 4  #################################################

################# Read only mount #################
docker run --name bmweb_ro \
--volume ~/example-docs:/usr/local/apache2/htdocs/:ro \
-p 80:80 \
httpd:latest

################# Read only mount assert the file creation attempt will fail #################
docker run --rm \
-v ~/example-docs:/testspace:ro \
alpine \
/bin/sh -c 'echo test > /testspace/test'

################# Docker managed volume #################
docker run -d \
-v /var/lib/cassandra/data \
--name cass-shared \
alpine echo Data Container

docker inspect -f "{{json .Volumes}}" cass-shared