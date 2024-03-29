#!/usr/bin/env bash

: ${HOST_VM_IP:=1.1.1.1}
DAPR_DIR="$(cd $(dirname "${BASH_SOURCE}") && pwd)"
DAPR_VERSION=1.10
DAPR_NS=dapr

. ${DAPR_DIR}/../common.sh
. ${DAPR_DIR}/../play-demo.sh

# Parameters to play the scenario
TYPE_SPEED=100
NO_WAIT=true

helm_values() {
cat <<EOF > dapr.yml
  dapr_dashboard:
    runAsNonRoot: true
  dapr_placement:
    runAsNonRoot: true
  dapr_operator:
    runAsNonRoot: true
  dapr_sentry:
    runAsNonRoot: true
  dapr_sidecar_injector:
    runAsNonRoot: true
    logLevel: info
    debug:
      enabled: false
  global:
    logAsJson: false
EOF
}

setup() {
  pe "oc new-project ${DAPR_NS}"
}

install() {
  pe "oc policy add-role-to-user system:openshift:scc:anyuid -z dapr-operator"
  pe "helm upgrade --install dapr dapr/dapr \
    -f dapr.yml \
    --version=${DAPR_VERSION} \
    -n ${DAPR_NS}"

  pe "k create ingress -n ${DAPR_NS} dapr --rule=\"dapr.${HOST_VM_IP}/*=dapr-dashboard:8080\""
}

cleanup() {
  pe "oc delete project ${DAPR_NS}"
  pe "helm uninstall dapr -n ${DAPR_NS}"
}

case $1 in
    setup) exit;;
    install) "$@"; exit;;
    cleanup) "$@"; exit;;
esac

helm_values
install