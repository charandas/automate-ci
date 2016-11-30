#!/bin/bash

rm -rf tmp
mkdir -p tmp/certs
./get_discovery_token.sh
terraform apply
