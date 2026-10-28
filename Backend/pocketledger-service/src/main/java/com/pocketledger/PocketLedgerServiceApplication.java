package com.pocketledger;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication(scanBasePackages = "com.pocketledger")
@EnableScheduling
public class PocketLedgerServiceApplication {

  public static void main(String[] args) {
    SpringApplication.run(PocketLedgerServiceApplication.class, args);
  }
}
