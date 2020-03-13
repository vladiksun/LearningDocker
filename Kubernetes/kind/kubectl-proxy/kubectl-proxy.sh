#!/bin/sh

#/kubectl proxy

/kubectl proxy --server="http://localhost:8001" --accept-paths='^.*'
