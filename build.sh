#!/bin/bash

echo "-----> Building receiver"
docker build -t pebbles/receiver .

echo "-----> Running receiver"
docker stop receiver
docker rm receiver
export SSH_PRIVATE_KEYS=`sudo cat /etc/ssh/ssh_host_rsa_key`
docker run -i -t --rm --name receiver -p 2341:22 -e SSH_PRIVATE_KEYS="$SSH_PRIVATE_KEYS" -v /var/run/docker.sock:/var/run/docker.sock -v /tmp/pebble-repos:/tmp/pebble-repos:rw -v /tmp/pebble-cache:/tmp/pebble-cache:rw --entrypoint bash pebbles/receiver -
# docker run -d --rm --name receiver -p 2341:22 -e SSH_PRIVATE_KEYS="$SSH_PRIVATE_KEYS" -v /var/run/docker.sock:/var/run/docker.sock -v /tmp/pebble-repos:/tmp/pebble-repos:rw -v /tmp/pebble-cache:/tmp/pebble-cache:rw pebbles/receiver