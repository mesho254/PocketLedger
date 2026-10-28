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
public class BudgetResponse {
  private UUID id;
  private String category;
  private BigDecimal monthlyLimit;
  private int month;
  private int year;
}
