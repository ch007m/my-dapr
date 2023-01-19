# my-dapr

Project used to test/demo dapr on kind kubernetes

## HelloWorld

To setup a kind kubernetes cluster on your local machine, install [dapr](https://dapr.io/) and play with the Kubernetes [Order quickstart](https://github.com/dapr/quickstarts/tree/master/tutorials/hello-kubernetes),
execute this `all-in-one` instructions bash script where you pass your `HOST_VM_IP` address.

```bash
HOST_VM_IP=192.168.1.90 ../setup-dapr.sh
```

You can access the dapr dashboard using the url: `https://dapr.<HOST_VM_IP>.nip.io` 

like also to get orders (or post) with the RUL: `http://nodeapp.<HOST_VM_IP>.nip.io/order`
