# Stage 1: Build application with Maven
FROM eclipse-temurin:21-jdk-alpine AS builder

WORKDIR /build

# Copy Maven wrapper and POM first for efficient layer caching
COPY mvnw mvnw.cmd pom.xml ./
COPY .mvn .mvn

# Download dependencies (offline cache layer)
RUN ./mvnw dependency:go-offline -B || true

# Copy source code and build executable jar
COPY src ./src
RUN ./mvnw clean package -DskipTests -B

# Stage 2: Minimal runtime image
FROM eclipse-temurin:21-jre-alpine

WORKDIR /app

# Create a non-root application user for container security
RUN addgroup -S pocketledger && adduser -S pocketledger -G pocketledger

# Copy packaged jar from builder
COPY --from=builder /build/target/pocketledger-api-0.0.1-SNAPSHOT.jar app.jar

# Change ownership
RUN chown pocketledger:pocketledger app.jar

USER pocketledger:pocketledger

EXPOSE 8080

ENV JAVA_OPTS="-XX:+UseG1GC -XX:MaxRAMPercentage=75.0"

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
