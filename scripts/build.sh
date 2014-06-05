#!/bin/bash

exec 2>&1
set -e
set -x

# Install gitreceived
mkdir -p /gopath
GOPATH=/gopath go get github.com/tools/godep
GOPATH=/gopath go get github.com/flynn/gitreceived

echo -e "\nSuccess!"
exit 0