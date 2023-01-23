#!/usr/bin/env bash

: ${HOST_VM_IP:=1.1.1.1.nip.io}
DAPR_DIR="$(cd $(dirname "${BASH_SOURCE}") && pwd)"
DAPR_VERSION=1.9.5
DAPR_NS=dapr-system

. ${DAPR_DIR}/common.sh
. ${DAPR_DIR}/play-demo.sh

# Parameters to play the scenario
TYPE_SPEED=100
NO_WAIT=true

install() {
  pe "helm upgrade --install dapr dapr/dapr \
    --version=${DAPR_VERSION} \
    -n ${DAPR_NS} \
    --create-namespace \
    --wait"

  pe "k create ingress -n ${DAPR_NS} dapr --class=nginx --rule=\"dapr.${HOST_VM_IP}.nip.io/*=dapr-dashboard:8080\""
}

cleanup() {
  pe "k delete ingress -n ${DAPR_NS}"
  pe "helm uninstall dapr -n ${DAPR_NS}"
}

case $1 in
    install) "$@"; exit;;
    cleanup) "$@"; exit;;
esac

install