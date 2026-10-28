package com.pocketledger.budget.validation;

import com.pocketledger.budget.dto.BudgetRequest;
import com.pocketledger.budget.exception.BudgetValidationException;
import java.math.BigDecimal;
import org.springframework.stereotype.Component;

@Component
public class BudgetValidator {

  public void validateForCreateOrUpdate(BudgetRequest request) {
    if (request == null) {
      throw new BudgetValidationException("Budget request cannot be null");
    }
    if (request.getCategory() == null || request.getCategory().trim().isEmpty()) {
      throw new BudgetValidationException("category is required");
    }
    if (request.getMonthlyLimit() == null
        || request.getMonthlyLimit().compareTo(BigDecimal.ZERO) <= 0) {
      throw new BudgetValidationException("monthlyLimit must be greater than zero");
    }
    if (request.getMonth() < 1 || request.getMonth() > 12) {
      throw new BudgetValidationException("month must be between 1 and 12");
    }
    if (request.getYear() < 2000 || request.getYear() > 2100) {
      throw new BudgetValidationException("year must be between 2000 and 2100");
    }
  }
}
