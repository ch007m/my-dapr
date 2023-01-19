#!/usr/bin/env bash

DAPR_DIR="$(cd $(dirname "${BASH_SOURCE}") && pwd)"

. ${DAPR_DIR}/common.sh
. ${DAPR_DIR}/play-demo.sh

# Parameters to play the scenario
TYPE_SPEED=100
NO_WAIT=true

# Script parameters
: ${HOST_VM_IP:=1.1.1.1.nip.io}
: ${DAPR_QUICKSTARTS_GIT_REPO:=https://github.com/dapr/quickstarts.git}
: ${DAPR_FOLDER:=quickstarts}

if [ ! -d "$DAPR_FOLDER" ] ; then
    pe "git clone $DAPR_QUICKSTARTS_GIT_REPO $DAPR_FOLDER"
fi

pe "cd quickstarts/tutorials/hello-kubernetes"

order_demo() {
  pe "helm install redis bitnami/redis --wait"
  pe "k apply -f ./deploy/redis.yaml"
  pe "k apply -f ./deploy/node.yaml"
  pe "k rollout status deploy/nodeapp"

  pe "NODEAPP_URL=nodeapp.${HOST_VM_IP}.nip.io"
  pe "k create ingress nodeapp --class=nginx --rule=\"${NODEAPP_URL}/*=nodeapp:80\""

  until [ "$(curl -s -w '%{http_code}' -o /dev/null "http://${NODEAPP_URL}/ports")" -eq 200 ]
  do
    pe "sleep 5"
  done

  pe "curl http://${NODEAPP_URL}/ports"
  pe "curl --request POST --data \"@quickstarts/tutorials/hello-kubernetes/sample.json\" --header Content-Type:application/json http://${NODEAPP_URL}/neworder"
  pe "curl http://${NODEAPP_URL}/order"

  pe "k apply -f ./deploy/python.yaml"
  pe "k rollout status deploy/pythonapp"
  pe "k logs --selector=app=node -c node --tail=-1"
}

remove_order_demo() {
  pe "k delete -f ./deploy/redis.yaml"
  pe "k delete -f ./deploy/node.yaml"
  pe "k delete -f ./deploy/python.yml"
}

order_demo