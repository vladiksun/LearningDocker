#!/bin/sh
set -o errexit

# create registry container unless it already exists
REG_NAME='kind-registry'
REG_PORT='5000'

running="$(docker inspect -f '{{.State.Running}}' "${REG_NAME}" 2>/dev/null || true)"

if [ "${running}" != 'true' ]; then
  docker run \
    -d --restart=always -p "${REG_PORT}:5000" --name "${REG_NAME}" \
    registry:2
fi

REG_IP="$(docker inspect -f '{{.NetworkSettings.IPAddress}}' "${REG_NAME}")"
