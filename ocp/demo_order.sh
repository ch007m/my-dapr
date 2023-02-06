#!/usr/bin/env bash

DAPR_DIR="$(cd $(dirname "${BASH_SOURCE}") && pwd)"

. ${DAPR_DIR}/../common.sh
. ${DAPR_DIR}/../play-demo.sh

# Parameters to play the scenario
TYPE_SPEED=100
NO_WAIT=true

# Script parameters
: ${HOST_VM_IP:=1.1.1.1.nip.io}
: ${DAPR_QUICKSTARTS_GIT_REPO:=https://github.com/dapr/quickstarts.git}
: ${DAPR_FOLDER:=quickstarts}
: ${DAPR_NS:=dapr}
NODEAPP_URL=nodeapp.${HOST_VM_IP}

if [ ! -d "$DAPR_FOLDER" ] ; then
    pe "git clone $DAPR_QUICKSTARTS_GIT_REPO $DAPR_FOLDER"
fi

pe "cd ${DAPR_FOLDER}/tutorials/hello-kubernetes"

install() {
  pe "helm install redis bitnami/redis -n ${DAPR_NS} --set master.podSecurityContext.enabled=false --set master.containerSecurityContext.enabled=false"
  pe "k -n ${DAPR_NS} apply -f ./deploy/redis.yaml"
  pe "k -n ${DAPR_NS} apply -f ./deploy/node.yaml"
  pe "k -n ${DAPR_NS} rollout status deploy/nodeapp"
  pe "k -n ${DAPR_NS} create ingress nodeapp --rule=\"${NODEAPP_URL}/*=nodeapp:80\""

  until [ "$(curl -s -w '%{http_code}' -o /dev/null "http://${NODEAPP_URL}/ports")" -eq 200 ]
  do
    pe "sleep 5"
  done
}

play() {
  p "Post an order"
  pe "curl --request POST --data \"@sample.json\" --header Content-Type:application/json http://${NODEAPP_URL}/neworder"
  p "Get last order created"
  pe "curl http://${NODEAPP_URL}/order"
}

cleanup() {
  pe "k -n ${DAPR_NS} delete -f ./deploy/redis.yaml"
  pe "k -n ${DAPR_NS} delete -f ./deploy/node.yaml"
  pe "k -n ${DAPR_NS} delete ingress nodeapp"
  pe "helm uninstall redis -n ${DAPR_NS}"
}

case $1 in
    install) "$@"; exit;;
    play) "$@"; exit;;
    cleanup) "$@"; exit;;
esac

install
play