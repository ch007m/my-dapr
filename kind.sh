#!/usr/bin/env bash

KIND_DELETE=${KIND_DELETE:-n}
K8S_VERSION=${K8S_VERSION:-latest}
KIND_NAME=${KIND_NAME:-kind}
HOST_VM_IP=${HOST_VM_IP:-127.0.0.1}

KIND_DIR="$(cd $(dirname "${BASH_SOURCE}") && pwd)"

. ${KIND_DIR}/common.sh
. ${KIND_DIR}/play-demo.sh

# Parameters to play the scenario
TYPE_SPEED=100
NO_WAIT=true

install() {
 curl -s -L "https://raw.githubusercontent.com/snowdrop/k8s-infra/main/kind/kind-reg-ingress.sh" | bash -s ${KIND_DELETE} ${K8S_VERSION} ${KIND_NAME} 0 ${HOST_VM_IP}
}

delete() {
  docker rm -f kind-registry
  kind delete cluster
}

case $1 in
    install) "$@"; exit;;
    delete) "$@"; exit;;
esac

install