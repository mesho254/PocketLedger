package com.pocketledger.savings.event;

import com.pocketledger.transaction.event.DomainEvent;
import java.math.BigDecimal;
import java.util.UUID;

public class SavingsContributionRecordedEvent extends DomainEvent {

  private static final long serialVersionUID = 1L;

  private final UUID goalId;
  private final BigDecimal amount;
  private final BigDecimal updatedGoalAmount;
  private final String status;

  public SavingsContributionRecordedEvent(
      Object source,
      UUID userId,
      UUID goalId,
      BigDecimal amount,
      BigDecimal updatedGoalAmount,
      String status) {
    super(source, userId);
    this.goalId = goalId;
    this.amount = amount;
    this.updatedGoalAmount = updatedGoalAmount;
    this.status = status;
  }

  public UUID getGoalId() {
    return goalId;
  }

  public BigDecimal getAmount() {
    return amount;
  }

  public BigDecimal getUpdatedGoalAmount() {
    return updatedGoalAmount;
  }

  public String getStatus() {
    return status;
  }
}
