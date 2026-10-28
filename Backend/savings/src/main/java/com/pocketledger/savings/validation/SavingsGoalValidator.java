package com.pocketledger.savings.validation;

import com.pocketledger.savings.dto.SavingsContributionRequest;
import com.pocketledger.savings.dto.SavingsGoalRequest;
import com.pocketledger.savings.exception.SavingsValidationException;
import java.math.BigDecimal;
import org.springframework.stereotype.Component;

@Component
public class SavingsGoalValidator {

  public void validateGoalForCreate(SavingsGoalRequest request) {
    if (request == null) {
      throw new SavingsValidationException("Savings goal request cannot be null");
    }
    if (request.getTitle() == null || request.getTitle().trim().isEmpty()) {
      throw new SavingsValidationException("title is required");
    }
    if (request.getTargetAmount() == null
        || request.getTargetAmount().compareTo(BigDecimal.ONE) < 0) {
      throw new SavingsValidationException("targetAmount must be at least 1.00");
    }
  }

  public void validateContribution(SavingsContributionRequest request) {
    if (request == null) {
      throw new SavingsValidationException("Savings contribution request cannot be null");
    }
    if (request.getAmount() == null || request.getAmount().compareTo(BigDecimal.ZERO) <= 0) {
      throw new SavingsValidationException("amount must be greater than zero");
    }
  }
}
