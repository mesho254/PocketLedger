package com.pocketledger.savings.validation;

import static org.junit.jupiter.api.Assertions.assertDoesNotThrow;
import static org.junit.jupiter.api.Assertions.assertThrows;

import com.pocketledger.savings.dto.SavingsContributionRequest;
import com.pocketledger.savings.dto.SavingsGoalRequest;
import com.pocketledger.savings.exception.SavingsValidationException;
import java.math.BigDecimal;
import org.junit.jupiter.api.Test;

class SavingsGoalValidatorTest {

  private final SavingsGoalValidator validator = new SavingsGoalValidator();

  @Test
  void shouldValidateValidGoal() {
    SavingsGoalRequest req = SavingsGoalRequest.builder()
        .title("Emergency Fund")
        .targetAmount(new BigDecimal("1000.00"))
        .build();
    assertDoesNotThrow(() -> validator.validateGoalForCreate(req));
  }

  @Test
  void shouldRejectNonPositiveContribution() {
    SavingsContributionRequest req = SavingsContributionRequest.builder().amount(BigDecimal.ZERO).build();
    assertThrows(SavingsValidationException.class, () -> validator.validateContribution(req));
  }
}
