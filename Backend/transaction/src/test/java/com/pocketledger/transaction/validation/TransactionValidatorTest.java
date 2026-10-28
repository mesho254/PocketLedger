package com.pocketledger.transaction.validation;

import static org.junit.jupiter.api.Assertions.assertDoesNotThrow;
import static org.junit.jupiter.api.Assertions.assertThrows;

import com.pocketledger.transaction.dto.TransactionRequest;
import com.pocketledger.transaction.enums.TransactionType;
import com.pocketledger.transaction.exception.TransactionValidationException;
import java.math.BigDecimal;
import java.time.LocalDate;
import org.junit.jupiter.api.Test;

class TransactionValidatorTest {

  private final TransactionValidator validator = new TransactionValidator();

  @Test
  void shouldValidateValidTransaction() {
    TransactionRequest req = TransactionRequest.builder()
        .amount(new BigDecimal("100.00"))
        .type(TransactionType.INCOME)
        .category("SALARY")
        .transactionDate(LocalDate.now())
        .build();
    assertDoesNotThrow(() -> validator.validateForCreate(req));
  }

  @Test
  void shouldRejectNegativeOrZeroAmount() {
    TransactionRequest req = TransactionRequest.builder()
        .amount(BigDecimal.ZERO)
        .type(TransactionType.EXPENSE)
        .category("FOOD")
        .transactionDate(LocalDate.now())
        .build();
    assertThrows(TransactionValidationException.class, () -> validator.validateForCreate(req));
  }

  @Test
  void shouldRejectBlankCategory() {
    TransactionRequest req = TransactionRequest.builder()
        .amount(new BigDecimal("25.00"))
        .type(TransactionType.EXPENSE)
        .category("   ")
        .transactionDate(LocalDate.now())
        .build();
    assertThrows(TransactionValidationException.class, () -> validator.validateForCreate(req));
  }
}
