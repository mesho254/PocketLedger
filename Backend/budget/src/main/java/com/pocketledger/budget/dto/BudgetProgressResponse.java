package com.pocketledger.budget.dto;

import java.math.BigDecimal;
import java.util.UUID;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class BudgetProgressResponse {
  private UUID id;
  private String category;
  private BigDecimal monthlyLimit;
  private BigDecimal actualSpent;
  private BigDecimal remaining;
  private double percentageSpent;
  private String status; // "SAFE", "WARNING_80", "EXCEEDED"
}
