#!/usr/bin/env bash

USER='couchdb'
PASSWORD='password'

NODE0='localhost:5984'
NODE1='localhost:15984'
NODE2='localhost:25984'

COORDINATION_NODE=$NODE0
NODE1_IP='couchdb1'
NODE2_IP='couchdb2'
COMMON_PORT=5984


#curl -X POST -H "Content-Type: application/json" http://${USER}:${PASSWORD}@${COORDINATION_NODE}/_cluster_setup -d '{"action": "enable_cluster", "bind_address":"0.0.0.0", "username": "'"${USER}"'", "password":"'"${PASSWORD}"'", "node_count":"3"}'
#curl -X POST -H "Content-Type: application/json" http://${USER}:${PASSWORD}@${NODE1}/_cluster_setup -d '{"action": "enable_cluster", "bind_address":"0.0.0.0", "username": "'"${USER}"'", "password":"'"${PASSWORD}"'", "node_count":"3"}'
#curl -X POST -H "Content-Type: application/json" http://${USER}:${PASSWORD}@${NODE2}/_cluster_setup -d '{"action": "enable_cluster", "bind_address":"0.0.0.0", "username": "'"${USER}"'", "password":"'"${PASSWORD}"'", "node_count":"3"}'



## Add NODE1 to cluster
# Init node
#curl -X POST -H "Content-Type: application/json" http://${USER}:${PASSWORD}@${COORDINATION_NODE}/_cluster_setup -d '{"action": "enable_cluster", "bind_address":"0.0.0.0", "username": "'"${USER}"'", "password":"'"${PASSWORD}"'", "port": '${COMMON_PORT}', "node_count": "3", "remote_node": "'"${NODE1_IP}"'"}'

# Add node
curl -X POST -H "Content-Type: application/json" http://${USER}:${PASSWORD}@${COORDINATION_NODE}/_cluster_setup -d '{"action": "add_node", "host":"'"${NODE1_IP}"'", "port": '${COMMON_PORT}', "username": "'"${USER}"'", "password":"'"${PASSWORD}"'"}'
#


### Add NODE2 to cluster
#curl -X POST -H "Content-Type: application/json" http://${USER}:${PASSWORD}@${COORDINATION_NODE}/_cluster_setup -d '{"action": "enable_cluster", "bind_address":"0.0.0.0", "username": "'"${USER}"'", "password":"'"${PASSWORD}"'", "port": '${COMMON_PORT}', "node_count": "3", "remote_node": "'"${NODE2_IP}"'", "remote_current_user": "'"${USER}"'", "remote_current_password": "'"${PASSWORD}"'" }'
#curl -X POST -H "Content-Type: application/json" http://${USER}:${PASSWORD}@${COORDINATION_NODE}/_cluster_setup -d '{"action": "add_node", "host":"'"${NODE2_IP}"'", "port": '${COMMON_PORT}', "username": "'"${USER}"'", "password":"'"${PASSWORD}"'"}'

# Init
#curl -X POST -H "Content-Type: application/json" http://${USER}:${PASSWORD}@${COORDINATION_NODE}/_cluster_setup -d '{"action": "enable_cluster", "bind_address":"0.0.0.0", "username": "'"${USER}"'", "password":"'"${PASSWORD}"'", "port": '${COMMON_PORT}', "node_count": "3", "remote_node": "'"${NODE2_IP}"'"}'



## Finish the cluster
#curl -X POST -H "Content-Type: application/json" http://${USER}:${PASSWORD}@${COORDINATION_NODE}/_cluster_setup -d '{"action": "finish_cluster"}'