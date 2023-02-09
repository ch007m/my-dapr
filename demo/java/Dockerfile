FROM eclipse-temurin:17-jdk-alpine
VOLUME /tmp
COPY target/order-service-1.0.jar order.jar
ENTRYPOINT ["java","-jar","/order.jar"]