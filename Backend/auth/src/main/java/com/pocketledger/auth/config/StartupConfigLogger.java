package com.pocketledger.auth.config;

import java.util.Arrays;
import java.util.stream.Collectors;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.core.env.Environment;
import org.springframework.stereotype.Component;

@Slf4j
@Component
@RequiredArgsConstructor
public class StartupConfigLogger implements ApplicationRunner {

  private final Environment environment;

  @Override
  public void run(ApplicationArguments args) {
    String profiles = Arrays.stream(environment.getActiveProfiles()).collect(Collectors.joining(", "));

    if (profiles.isBlank()) {
      profiles = "default";
    }

    log.info(
        "PocketLedger Startup config: activeProfiles=[{}], datasource=[{}]",
        profiles,
        environment.getProperty("spring.datasource.url", "not-set"));
  }
}
