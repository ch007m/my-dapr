## OpenShift

Dapr can be installed on OpenShift 4 using the upstream [helm chart](https://github.com/dapr/dapr/tree/master/charts/dapr).
To be successfully, it is needed, as discussed [here](https://github.com/dapr/dapr/issues/3069), to configure the Dapr containers to start them as `nonRoot`.
For that purpose, create a values.yml file and pass it to the helm client when you will deploy it:

```bash
cat <<EOF > values.yml
  dapr_dashboard:
    image:
      registry: ghcr.io/dapr
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
    registry: ghcr.io/dapr
EOF
```

Add the following role `system:openshift:scc:anyuid` to the service account of the `Dapr operator` to avoid to get warnings messages `e.g. Warning: would violate PodSecurity ...`
```bash
oc policy add-role-to-user system:openshift:scc:anyuid -z dapr-operator
```

Deploy th helm chart
```bash
helm repo add dapr https://dapr.github.io/helm-charts/
helm upgrade --install dapr dapr/dapr -f dapr.yml --version=1.10 -n dapr    
```

>**TIP**: You can use our installation script to execute the different commands `HOST_VM_IP=<HOSTNAME_OF_THE_CLUSTER> ./ocp/dapr.sh`.

To test if the dapr deployment succeeded, execute the following bash script able to install a demo project, redis, etc
```bash
HOST_VM_IP=<HOSTNAME_OF_THE_CLUSTER> ./ocp/demo_order.sh
```
If the script is played without errors, then you should be able to see the following output messages
```text
$ cd quickstarts/tutorials/hello-kubernetes
$ helm install redis bitnami/redis -n dapr --set master.podSecurityContext.enabled=false --set master.containerSecurityContext.enabled=false
NAME: redis
LAST DEPLOYED: Wed May 10 14:32:49 2023
NAMESPACE: dapr
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
CHART NAME: redis
CHART VERSION: 17.10.3
APP VERSION: 7.0.11

** Please be patient while the chart is being deployed **

Redis&reg; can be accessed on the following DNS names from within your cluster:

    redis-master.dapr.svc.cluster.local for read/write operations (port 6379)
    redis-replicas.dapr.svc.cluster.local for read-only operations (port 6379)



To get your password run:

    export REDIS_PASSWORD=$(kubectl get secret --namespace dapr redis -o jsonpath="{.data.redis-password}" | base64 -d)

To connect to your Redis&reg; server:

1. Run a Redis&reg; pod that you can use as a client:

   kubectl run --namespace dapr redis-client --restart='Never'  --env REDIS_PASSWORD=$REDIS_PASSWORD  --image docker.io/bitnami/redis:7.0.11-debian-11-r7 --command -- sleep infinity

   Use the following command to attach to the pod:

   kubectl exec --tty -i redis-client \
   --namespace dapr -- bash

2. Connect using the Redis&reg; CLI:
   REDISCLI_AUTH="$REDIS_PASSWORD" redis-cli -h redis-master
   REDISCLI_AUTH="$REDIS_PASSWORD" redis-cli -h redis-replicas

To connect to your database from outside the cluster execute the following commands:

    kubectl port-forward --namespace dapr svc/redis-master 6379:6379 &
    REDISCLI_AUTH="$REDIS_PASSWORD" redis-cli -h 127.0.0.1 -p 6379
$ k -n dapr apply -f ./deploy/redis.yaml
component.dapr.io/statestore created
$ k -n dapr apply -f ./deploy/node.yaml
service/nodeapp created
deployment.apps/nodeapp created
$ k -n dapr rollout status deploy/nodeapp
Waiting for deployment "nodeapp" rollout to finish: 0 of 1 updated replicas are available...
deployment "nodeapp" successfully rolled out
$ k -n dapr create ingress nodeapp --rule="nodeapp.snowdrop-eu-de-1-bx2-4x16-0c576f1a70d464f092d8591997631748-0000.eu-de.containers.appdomain.cloud/*=nodeapp:80"
ingress.networking.k8s.io/nodeapp created
$ Post an order
$ curl --request POST --data "@sample.json" --header Content-Type:application/json http://nodeapp.snowdrop-eu-de-1-bx2-4x16-0c576f1a70d464f092d8591997631748-0000.eu-de.containers.appdomain.cloud/neworder
$ Get last order created
$ curl http://nodeapp.snowdrop-eu-de-1-bx2-4x16-0c576f1a70d464f092d8591997631748-0000.eu-de.containers.appdomain.cloud/order
{"orderId":"42"}
```
Enjoy ;-)