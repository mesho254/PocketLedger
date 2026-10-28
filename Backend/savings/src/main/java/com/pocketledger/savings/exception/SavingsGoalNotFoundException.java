package com.pocketledger.savings.exception;

import java.util.UUID;

public class SavingsGoalNotFoundException extends RuntimeException {

  public SavingsGoalNotFoundException(String message) {
    super(message);
  }

  public SavingsGoalNotFoundException(UUID goalId) {
    super("Savings goal not found: " + goalId);
  }
}
