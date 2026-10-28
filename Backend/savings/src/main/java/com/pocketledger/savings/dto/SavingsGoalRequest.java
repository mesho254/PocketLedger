package com.pocketledger.savings.dto;

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
public class SavingsGoalRequest {

  @NotBlank(message = "Title is required")
  private String title;

  @NotNull(message = "Target amount is required")
  @DecimalMin(value = "1.00", message = "Target amount must be at least 1.00")
  private BigDecimal targetAmount;

  private LocalDate targetDate;
}
