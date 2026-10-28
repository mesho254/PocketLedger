package com.pocketledger.analytics.dto;

import java.math.BigDecimal;
import java.util.List;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MonthlySummaryResponse {
  private int year;
  private int month;
  private BigDecimal totalIncome;
  private BigDecimal totalExpense;
  private BigDecimal netSavings;
  private double savingsRatePercentage;
  private List<CategoryBreakdownResponse> categoryBreakdown;
}
