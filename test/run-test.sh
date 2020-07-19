#!/usr/bin/env bash

# Pre-requisites:
# Self-signed cert created with..
#
# openssl req -nodes -x509 -newkey rsa:4096 -keyout cert/tls.key -out cert/tls.crt -days 10000 -subj "/C=SE/ST=Stockholm/L=Stockholm/O=eknert/OU=Org/CN=nginx-tls-terminator.default.svc.cluster.local"
#
# ..and placed in certs/

set -eu -o pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

test_cluster_name=nginx-tls-terminator-test

kind create cluster --name="${test_cluster_name}"

k() {
    kubectl --context kind-${test_cluster_name} "$@"
}

k create secret tls tls-terminator-cert --cert="${DIR}"/cert/tls.crt --key="${DIR}"/cert/tls.key
k create service clusterip nginx-tls-terminator --tcp=443:8443
k apply -f "${DIR}"/deployment.yaml

# Wait some time for the pods to be created..
sleep 20

# ..and even more time for them to be ready
k wait pods -l app=nginx-tls-terminator --for=condition=Ready --timeout=90s

nginx_pod=$(k get pod -l app=nginx-tls-terminator -o name)

k cp "${DIR}"/cert/tls.crt "${nginx_pod:4}:/tmp" -c nginx
k exec "${nginx_pod}" -c nginx -- curl \
    --fail -s -o /dev/null -I -w "%{http_code}" \
    --cacert /tmp/tls.crt \
    https://nginx-tls-terminator.default.svc.cluster.local

# Cleanup
kind delete cluster --name "${test_cluster_name}"