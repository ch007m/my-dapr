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
HOST_VM_IP=192.168.1.90 ./setup-dapr.sh
```

**NOTE**: You can access the dapr dashboard using the url: `https://dapr.<HOST_VM_IP>.nip.io`

## Order quickstart

To play with the [Order quickstart](https://github.com/dapr/quickstarts/tree/master/tutorials/hello-kubernetes) which is an application composed of 2 microservices: node order app and python backend issuing
order requests, execute the following bash command:
```bash
HOST_VM_IP=192.168.1.90 ./demo_order.sh install
```

To get orders (or post orders), do some cUrl requests using the nodeapp endpoint: `http://nodeapp.<HOST_VM_IP>.nip.io/order`

Post an order
```bash
curl --request POST --data \"@quickstarts/tutorials/hello-kubernetes/sample.json\" --header Content-Type:application/json http://${NODEAPP_ENDPOINT}/neworder
```

Get the last order:
```bash
curl http://${NODEAPP_ENDPOINT}/order"
```

or using the demo bash script:
```bash
HOST_VM_IP=192.168.1.90 ./demo_order.sh play
```

To cleanup the demo:

```bash
./demo_order.sh cleanup
```
