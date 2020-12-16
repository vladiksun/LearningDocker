#!/usr/bin/env bash

docker run -p 11211:11211 --name memcached-0 -e MEMCACHED_EXTRA_FLAGS="-I 128m -m 1024" bitnami/memcached:latest

docker run -p 11212:11211 --name memcached-1 -e MEMCACHED_EXTRA_FLAGS="-I 128m -m 1024" bitnami/memcached:latest


