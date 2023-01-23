#!/usr/bin/env bash

: ${delete:=n}
: ${k8s_version:=latest}

KIND_DIR="$(cd $(dirname "${BASH_SOURCE}") && pwd)"

. ${KIND_DIR}/common.sh
. ${KIND_DIR}/play-demo.sh

# Parameters to play the scenario
TYPE_SPEED=100
NO_WAIT=true

install() {
 curl -s -L "https://raw.githubusercontent.com/snowdrop/k8s-infra/main/kind/kind-reg-ingress.sh" | bash -s ${delete} ${k8s_version} 0
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