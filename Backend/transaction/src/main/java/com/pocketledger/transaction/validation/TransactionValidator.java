package com.pocketledger.transaction.validation;

import com.pocketledger.transaction.dto.TransactionRequest;
import com.pocketledger.transaction.exception.TransactionValidationException;
import java.math.BigDecimal;
import org.springframework.stereotype.Component;

@Component
public class TransactionValidator {

  public void validateForCreate(TransactionRequest request) {
    validateCommon(request);
  }

  public void validateForUpdate(TransactionRequest request) {
    validateCommon(request);
  }

  private void validateCommon(TransactionRequest request) {
    if (request == null) {
      throw new TransactionValidationException("Transaction request cannot be null");
    }
    if (request.getAmount() == null || request.getAmount().compareTo(BigDecimal.ZERO) <= 0) {
      throw new TransactionValidationException("amount must be greater than zero");
    }
    if (request.getType() == null) {
      throw new TransactionValidationException("type is required");
    }
    requireText(request.getCategory(), "category");
    if (request.getTransactionDate() == null) {
      throw new TransactionValidationException("transactionDate is required");
    }
  }

  private void requireText(String value, String fieldName) {
    if (value == null || value.trim().isEmpty()) {
      throw new TransactionValidationException(fieldName + " is required");
    }
  }
}
