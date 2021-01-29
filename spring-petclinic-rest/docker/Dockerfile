FROM openjdk:8-alpine as builder
ARG environment
ARG product
ARG service
ENV environment=${environment}
ENV product=${product}
ENV service=${service}
WORKDIR /usr/src/javaapp
COPY spring-petclinic-rest* ./
RUN chmod +x mvnw
RUN ./mvnw package
FROM openjdk:8-alpine as javaapp
WORKDIR /javaapi
COPY --from=builder /usr/src/javaapp/target/spring-petclinic-rest-2.2.5.jar ./
CMD java -jar spring-petclinic-rest-2.2.5.jar

