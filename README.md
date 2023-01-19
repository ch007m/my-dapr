# Dapr on kind

Project used to test/demo dapr on kind kubernetes

## Prerequisites

- [Helm](https://helm.sh/docs/intro/install/)
- Kubectl
- [Kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installation)
- Docker desktop

## Dapr setup

To create a kind kubernetes cluster on your local machine and install [dapr](https://dapr.io/), execute this `all-in-one` instructions bash script where you pass your `HOST_VM_IP` address.

```bash
HOST_VM_IP=192.168.1.90 ../setup-dapr.sh
```

**NOTE**: You can access the dapr dashboard using the url: `https://dapr.<HOST_VM_IP>.nip.io`

## Node and Python Order quickstart

To play with the [Order quickstart](https://github.com/dapr/quickstarts/tree/master/tutorials/hello-kubernetes), execute the following bash command:
```bash
HOST_VM_IP=192.168.1.90 ../demo_order.sh
```

To get orders (or post orders), do some cUrl requests using the endpoint: `http://nodeapp.<HOST_VM_IP>.nip.io/order`

E.g.
```bash
NODEAPP_URL=nodeapp.<HOST_VM_IP>.nip.io
curl --request POST --data \"@quickstarts/tutorials/hello-kubernetes/sample.json\" --header Content-Type:application/json http://${NODEAPP_URL}/neworder
curl http://${NODEAPP_URL}/order"
```
