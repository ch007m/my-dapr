# Dapr on kind

Project used to test/demo dapr on kind kubernetes

## Prerequisites

- [Helm](https://helm.sh/docs/intro/install/)
- Kubectl
- [Kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installation)
- Docker desktop

## Dapr setup

Create a kind kubernetes cluster on your local machine:

```bash
HOST_VM_IP=192.168.1.90 ./kind.sh
```

**NOTE**: The kind cluster can be deleted using the argument `./kind.sh delete` or during the creation `delete=y ./kind.sh`.
You can also change the version of the cluster to be used `k8s_version=latest ./kind.sh` or `k8s_version=1.24 ./kind.sh`.

Next, install [dapr](https://dapr.io/) using the bash [script](./setup-dapr.sh) where you pass the `HOST_VM_IP` address
which is used to expose the ingress route (e.g. dashboard, etc). The installation can be cleaned using `./setup-dapr.sh cleanup`

```bash
HOST_VM_IP=192.168.1.90 ./setup-dapr.sh
```

You can define the following variables:
```bash
HOST_VM_IP=<HOST_VM_IP> (e.g. 127.0.0.1.nip.io)
DAPR_VERSION=<DAPR_VERSION> (e.g. version of dapr to be installed. Default: 1.9.6)
DAPR_NS=<DAPR_NS> (e.g. namespace where dapr is installed on the cluster. Default: dapr)
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

To clean up the demo:

```bash
./demo_order.sh cleanup
```

## Collect Metrics

- To collect the Dapr metrics of the system like the sidecarss it is needed to install promethus, grafana and to deploy the grafana templates

```bash
helm install grafana grafana/grafana -n dapr-monitoring --create-namespace --set ingress.enabled=true --set ingress.hosts="{dapr-monitoring.127.0.0.1.nip.io}"

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install dapr-prom prometheus-community/prometheus -n dapr-monitoring
```
- You can get the grafana admin user using the command `kubectl get secret --namespace dapr-monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo`
- Next configure the prometheus [datasource](https://docs.dapr.io/operations/monitoring/metrics/grafana/#configure-prometheus-as-data-source)
- And import the [templates](https://docs.dapr.io/operations/monitoring/metrics/grafana/#import-dashboards-in-grafana)

