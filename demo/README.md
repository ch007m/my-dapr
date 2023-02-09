## How To play with the demo

The demo implements the service invocation pattern using a Node backend application storing orders in a redis database. The Spring Boot 
application will call the nodeapp using the dapr id of the `nodeapp`. Likewise, the Spring Boot application exposes a service `/generateOrder` that we can curl
using its endpoint `http://localhost:8080/generateOrder` or dapr HTTP port `localhost:3501/v1.0/invoke/springbootapp/method/generateOrder`

## Using docker

- Start docker or podman
- run `dpar init`
- Open a terminal under the Spring Boot project and run:
  ```bash
  dapr run --app-id springbootapp --app-port 8080 --dapr-http-port 3501 mvn spring-boot:run
  ```
- Open a terminal under the node project and run:
  ```bash
  npm install
  dapr run --app-id nodeapp --app-port 3000 --dapr-http-port 3500 node app.js
  ```
- Opn a 3rd terminal from where you can curl the Spring Boot Endpoint or Dapr endpoint:
  ```bash
  curl -v localhost:8080/generateOrder
  curl -v localhost:3501/v1.0/invoke/springbootapp/method/generateOrder
  
- using Httpie tool
  ```bash
  http :8080/generateOrder
  http :3501/v1.0/invoke/springbootapp/method/generateOrder
  ```
  
## And now kubernetes

- Setup a kind k8s cluster and install dapr using this [script](../setup-dapr.sh)
- Build and push the Spring Boot image on the local registry
  ```bash
  mvn clean package -Ddekorate.build=true -Ddekorate.push=true -Ddekorate.docker.registry=kind-registry:5000 -Ddekorate.docker.group=dapr
  # mvn spring-boot:build-image -Dspring-boot.build-image.imageName=kind-registry:5000/dapr/order-service:1.0 -Dspring-boot.build-image.publish=true
  ```
- Install redis `helm install redis bitnami/redis -n demo --create-namespace --wait`
- Install the redis dapr component
```bash
cat <<-EOF | kubectl apply -n demo -f -
apiVersion: dapr.io/v1alpha1
kind: Component
metadata:
  name: statestore
spec:
  type: state.redis
  version: v1
  metadata:
  - name: redisHost
    value: redis-master:6379
  - name: redisPassword
    secretKeyRef:
       name: redis
       key: redis-password
auth:
  secretStore: kubernetes
EOF
```

- Deploy within the demo namespace the SB and Nodejs applications
  ```bash
  kubectl apply -n demo -f ./deploy/node.yaml
  kubectl rollout -n demo status deploy/nodeapp
  kubectl apply -n demo -f ./java/target/classes/META-INF/dekorate/kubernetes.yml
  kubectl set image -n demo deployment/order-service order-service=localhost:5000/dapr/order-service:1.0
  ```
- Create an ingress route to access the Spring Boot app
  ```bash
  kubectl create ingress -n demo sbapp --class=nginx --rule="sb.127.0.0.1.nip.io/*=order-service:8080"
  ```
- Curl or http the SpringBoot endpoint
  ```bash
  curl -v sb.127.0.0.1.nip.io/generateOrder
  http sb.127.0.0.1.nip.io/generateOrder
  ```
- Check the log of the nodeapp to see if orders have been created
  ```bash
  kubectl logs -n demo -lapp=node
  Defaulted container "node" out of: node, daprd
  Node App listening on port 3000!
  Got a new order! Order ID: 10
  Successfully persisted state for Order ID: 10
  Got a new order! Order ID: 11
  Successfully persisted state for Order ID: 11
  ```