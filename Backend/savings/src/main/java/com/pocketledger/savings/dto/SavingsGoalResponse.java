package com.pocketledger.savings.dto;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SavingsGoalResponse {
  private UUID id;
  private String title;
  private BigDecimal targetAmount;
  private BigDecimal currentAmount;
  private LocalDate targetDate;
  private String status;
  private double percentageCompleted;
  private LocalDateTime createdAt;
}
