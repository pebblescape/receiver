#!/bin/bash

docker rm -f receiver
export SSH_PRIVATE_KEYS=`sudo cat /etc/ssh/ssh_host_rsa_key`
docker run -i -t --name receiver -p 2341:22 -e SSH_PRIVATE_KEYS="$SSH_PRIVATE_KEYS" -e MIKE_AUTH_KEY="somesuch" -v /var/run/docker.sock:/var/run/docker.sock -v /tmp/pebble-repos:/tmp/pebble-repos:rw -v /tmp/pebble-cache:/tmp/pebble-cache:rw --link mike:mike pebbles/receiver