#!/bin/bash

echo "-----> Building receiver"
docker build -t pebbles/receiver .

echo "-----> Running receiver"
docker stop receiver
docker rm receiver
export SSH_PRIVATE_KEYS=`sudo cat /etc/ssh/ssh_host_rsa_key`
# docker run -d -p 2341:22 -e SSH_PRIVATE_KEYS="$SSH_PRIVATE_KEYS" --name receiver -v /var/run/docker.sock:/var/run/docker.sock pebbles/receiver
docker run -i -t --rm -p 2341:22 -e SSH_PRIVATE_KEYS="$SSH_PRIVATE_KEYS" -v /var/run/docker.sock:/var/run/docker.sock --entrypoint bash pebbles/receiver -
# docker run -i -t --rm -p 2341:22 -e SSH_PRIVATE_KEYS="$SSH_PRIVATE_KEYS" -v /var/run/docker.sock:/var/run/docker.sock -v /tmp/repos:/tmp/repos:rw --entrypoint bash pebbles/receiver -