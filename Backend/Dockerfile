# Multi-stage build for the pocketledger-service Spring Boot app (Optimized for Render 512MB RAM)
FROM gradle:8.10-jdk21 AS build
WORKDIR /workspace
COPY . .
RUN gradle :pocketledger-service:bootJar -x test --no-daemon -Dorg.gradle.jvmargs="-Xmx384m -XX:MaxMetaspaceSize=192m"

FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
COPY --from=build /workspace/pocketledger-service/build/libs/pocketledger-service-0.0.1-SNAPSHOT.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-XX:+UseContainerSupport", "-XX:MaxRAMPercentage=75.0", "-Djava.security.egd=file:/dev/./urandom", "-jar", "/app/app.jar"]
