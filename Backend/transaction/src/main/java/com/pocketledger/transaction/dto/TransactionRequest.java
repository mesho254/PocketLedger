package com.pocketledger.transaction.dto;

import com.pocketledger.transaction.enums.TransactionType;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;
import java.time.LocalDate;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TransactionRequest {

  @NotNull(message = "Amount is required")
  @DecimalMin(value = "0.01", message = "Amount must be greater than zero")
  private BigDecimal amount;

  @NotNull(message = "Transaction type (INCOME or EXPENSE) is required")
  private TransactionType type;

  @NotBlank(message = "Category is required")
  private String category;

  @NotNull(message = "Transaction date is required")
  private LocalDate transactionDate;

  private String description;
}
