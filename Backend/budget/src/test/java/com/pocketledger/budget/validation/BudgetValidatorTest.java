package com.pocketledger.budget.validation;

import static org.junit.jupiter.api.Assertions.assertDoesNotThrow;
import static org.junit.jupiter.api.Assertions.assertThrows;

import com.pocketledger.budget.dto.BudgetRequest;
import com.pocketledger.budget.exception.BudgetValidationException;
import java.math.BigDecimal;
import org.junit.jupiter.api.Test;

class BudgetValidatorTest {

  private final BudgetValidator validator = new BudgetValidator();

  @Test
  void shouldValidateValidBudgetRequest() {
    BudgetRequest req = BudgetRequest.builder()
        .category("FOOD")
        .monthlyLimit(new BigDecimal("400.00"))
        .month(10)
        .year(2026)
        .build();
    assertDoesNotThrow(() -> validator.validateForCreateOrUpdate(req));
  }

  @Test
  void shouldRejectInvalidMonth() {
    BudgetRequest req = BudgetRequest.builder()
        .category("FOOD")
        .monthlyLimit(new BigDecimal("400.00"))
        .month(13)
        .year(2026)
        .build();
    assertThrows(BudgetValidationException.class, () -> validator.validateForCreateOrUpdate(req));
  }
}
