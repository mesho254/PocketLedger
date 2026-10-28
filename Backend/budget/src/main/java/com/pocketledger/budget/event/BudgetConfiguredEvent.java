package com.pocketledger.budget.event;

import com.pocketledger.transaction.event.DomainEvent;
import java.math.BigDecimal;
import java.util.UUID;

public class BudgetConfiguredEvent extends DomainEvent {

  private static final long serialVersionUID = 1L;

  private final UUID budgetId;
  private final String category;
  private final BigDecimal monthlyLimit;
  private final int year;
  private final int month;

  public BudgetConfiguredEvent(
      Object source,
      UUID userId,
      UUID budgetId,
      String category,
      BigDecimal monthlyLimit,
      int year,
      int month) {
    super(source, userId);
    this.budgetId = budgetId;
    this.category = category;
    this.monthlyLimit = monthlyLimit;
    this.year = year;
    this.month = month;
  }

  public UUID getBudgetId() {
    return budgetId;
  }

  public String getCategory() {
    return category;
  }

  public BigDecimal getMonthlyLimit() {
    return monthlyLimit;
  }

  public int getYear() {
    return year;
  }

  public int getMonth() {
    return month;
  }
}
