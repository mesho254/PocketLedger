package com.pocketledger;

import java.net.URI;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication(scanBasePackages = "com.pocketledger")
@EnableScheduling
public class PocketLedgerServiceApplication {

  public static void main(String[] args) {
    configureCloudDatabaseUrl();
    SpringApplication.run(PocketLedgerServiceApplication.class, args);
  }

  /**
   * Automatically converts Render's native PostgreSQL connection URLs
   * (e.g., postgresql://user:password@dpg-xxx-a/pocketledger_db or postgres://...)
   * from DATABASE_URL or SPRING_DATASOURCE_URL into standard Spring Boot JDBC properties.
   */
  private static void configureCloudDatabaseUrl() {
    String rawUrl = firstNonBlank(
        System.getenv("DATABASE_URL"),
        System.getenv("SPRING_DATASOURCE_URL"));

    if (rawUrl == null) {
      return;
    }

    String trimmed = rawUrl.trim();
    if (trimmed.startsWith("jdbc:postgresql://")) {
      return;
    }

    // Handle "jdbc:postgres://..." or "postgres://..." or "postgresql://..."
    String normalizedUri = trimmed;
    if (normalizedUri.startsWith("jdbc:")) {
      normalizedUri = normalizedUri.substring(5);
    }
    if (normalizedUri.startsWith("postgres://")) {
      normalizedUri = "postgresql://" + normalizedUri.substring("postgres://".length());
    }

    if (!normalizedUri.startsWith("postgresql://")) {
      return;
    }

    try {
      URI uri = URI.create(normalizedUri);
      String host = uri.getHost();
      int port = uri.getPort() > 0 ? uri.getPort() : 5432;
      String path = uri.getPath() != null && !uri.getPath().isEmpty() ? uri.getPath() : "/pocketledger_db";
      String query = uri.getRawQuery();

      String jdbcUrl = "jdbc:postgresql://" + host + ":" + port + path
          + (query != null && !query.isEmpty() ? "?" + query : "");
      System.setProperty("spring.datasource.url", jdbcUrl);

      String userInfo = uri.getRawUserInfo();
      if (userInfo != null && !userInfo.isEmpty()) {
        int colonIdx = userInfo.indexOf(':');
        if (colonIdx >= 0) {
          String user = URLDecoder.decode(userInfo.substring(0, colonIdx), StandardCharsets.UTF_8);
          String pass = URLDecoder.decode(userInfo.substring(colonIdx + 1), StandardCharsets.UTF_8);
          if (firstNonBlank(System.getenv("SPRING_DATASOURCE_USERNAME"), System.getenv("DB_USER")) == null) {
            System.setProperty("spring.datasource.username", user);
          }
          if (firstNonBlank(System.getenv("SPRING_DATASOURCE_PASSWORD"), System.getenv("DB_PASSWORD")) == null) {
            System.setProperty("spring.datasource.password", pass);
          }
        } else {
          String user = URLDecoder.decode(userInfo, StandardCharsets.UTF_8);
          if (firstNonBlank(System.getenv("SPRING_DATASOURCE_USERNAME"), System.getenv("DB_USER")) == null) {
            System.setProperty("spring.datasource.username", user);
          }
        }
      }
    } catch (Exception ignored) {
      // Fallback to default application.properties resolution if URI parsing fails
    }
  }

  private static String firstNonBlank(String a, String b) {
    if (a != null && !a.isBlank()) {
      return a;
    }
    if (b != null && !b.isBlank()) {
      return b;
    }
    return null;
  }
}
