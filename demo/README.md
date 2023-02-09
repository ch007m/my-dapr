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
- Opn a 3rd terminal from where you can curl the Spring Boot Endpoint:
  ```bash
  curl -v localhost:8080/generateOrder
  curl -v localhost:3501/v1.0/invoke/springbootapp/method/generateOrder
  
  using Httpie tool
  http :8080/generateOrder
  http :3501/v1.0/invoke/springbootapp/method/generateOrder
  ```