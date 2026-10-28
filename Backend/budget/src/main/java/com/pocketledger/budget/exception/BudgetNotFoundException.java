package com.pocketledger.budget.exception;

import java.util.UUID;

public class BudgetNotFoundException extends RuntimeException {

  public BudgetNotFoundException(String message) {
    super(message);
  }

  public BudgetNotFoundException(UUID budgetId) {
    super("Budget not found or access denied: " + budgetId);
  }
}
