FROM openjdk:8-jre-slim
COPY ./target/embedash-1.1-SNAPSHOT.jar .
COPY ./application.properties .
ENTRYPOINT [ "java", "-jar", "./embedash-1.1-SNAPSHOT.jar" , "--spring.config.location=./application.properties" ]


