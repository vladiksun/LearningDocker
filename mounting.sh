#!/usr/bin/env bash
################  Mount local folder ################
# Windows
docker run -it --rm --name builder --volume %cd%:/home/project node:latest /bin/bash
docker run -it --rm --name builder --volume %cd%:/home/project node:latest ls -la /home/project

# Linux via mount syntax
docker run -it \
  --rm \
  --name builder \
  --mount type=bind,source="$(pwd)"/,target=/home/project \
    node:latest \
    ls -la /home/project