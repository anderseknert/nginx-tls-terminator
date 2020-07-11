#!/usr/bin/env bash

# docker run --user 1000 -p 8443:8443 -v ${PWD}/test/cert:/etc/nginx/ssl nginx-tls-terminator:latest

# Create self signed cert
# openssl req -nodes -x509 -newkey rsa:4096 -keyout cert/tls.key -out cert/tls.crt -days 10000 -subj "/C=SE/ST=Stockholm/L=Stockholm/O=eknert/OU=Org/CN=localhost

# Store it to tls-terminator-cert secret

# Deploy the service and deployment

# Query the service to make sure it works as expected
