openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout tls.key -out tls.crt -subj "/CN=hydra.dev/O=snowdrop"
kubectl create secret tls tls-secret --key tls.key --cert tls.crt -n ingress

# Kind cluster config template
cfg=$(cat <<EOF
controller:
  service:
    type: NodePort
  hostPort:
    enabled: true
  watchIngressWithoutClass: true
  podAnnotations:
    dapr.io/enabled: "true"
    dapr.io/app-id: "nginx-ingress"
    dapr.io/port: "80"
    dapr.io/sidecar-listen-addresses: "0.0.0.0"
)

helm uninstall ingress-nginx -n ingress
echo "${cfg}" | helm upgrade --install ingress-nginx ingress-nginx --repo https://kubernetes.github.io/ingress-nginx -n ingress --create-namespace -f -
kubectl create ingress -n ingress ingress-dapr --class=nginx --rule="hydra.dev/*=nginx-ingress-dapr:80,tls=tls-secret"

cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: dni-function
  namespace: default
  labels:
    app: dni-function
spec:
  replicas: 1
  selector:
    matchLabels:
      app: dni-function
  template:
    metadata:
      labels:
        app: dni-function
      annotations:
        dapr.io/enabled: "true"
        dapr.io/app-id: "dni"
        dapr.io/port: "80"
        dapr.io/sidecar-listen-addresses: "0.0.0.0"
    spec:
      containers:
        - name: dni-function
          image: cmendibl3/dni:1.0.0
          ports:
            - containerPort: 80
EOF

curl --resolve 'hydra.dev:80:127.0.0.1' http://hydra.dev/v1.0/invoke/dni/method/api/validate?dni=54495436H