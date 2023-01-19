#!/usr/bin/env bash

DAPR_DIR="$(cd $(dirname "${BASH_SOURCE}") && pwd)"

. ${DAPR_DIR}/common.sh
. ${DAPR_DIR}/play-demo.sh

# Parameters to play the scenario
TYPE_SPEED=100
NO_WAIT=true

: ${HOST_VM_IP:=1.1.1.1.nip.io}

DAPR_VERSION=1.9.5
DAPR_NS=dapr-system

curl -s -L "https://raw.githubusercontent.com/snowdrop/k8s-infra/main/kind/kind-reg-ingress.sh" | bash -s y latest 0

pe "helm upgrade --install dapr dapr/dapr \
  --version=${DAPR_VERSION} \
  -n ${DAPR_NS} \
  --create-namespace \
  --wait"

pe "k create ingress -n dapr-system dapr --class=nginx --rule=\"dapr.${HOST_VM_IP}.nip.io/*=dapr-dashboard:8080\""