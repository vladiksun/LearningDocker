#!/usr/bin/env bash

docker build -t friendlyhello .  # Create image using this directory's Dockerfile
docker tag <image> username/repository:tag  # Tag <image> for upload to registry
docker push username/repository:tag            # Upload tagged image to registry

