#!/usr/bin/env bash

docker network ls

# inspect default network
docker network inspect bridge

docker network inspect <network_name>


#   Create the alpine-net network.
#   You do not need the --driver bridge flag since it’s the default, but this example shows how to specify it.

docker network create --driver bridge alpine-net

# run and connect to the network
docker run -dit --name alpine1 --network <network_name> alpine ash

# connect to existing network
docker network connect <network_name> <container_name>





