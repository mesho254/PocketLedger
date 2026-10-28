package com.pocketledger.transaction.event;

import com.pocketledger.transaction.enums.TransactionType;
import java.math.BigDecimal;
import java.util.UUID;

public class TransactionRecordedEvent extends DomainEvent {

  private static final long serialVersionUID = 1L;

  private final UUID transactionId;
  private final TransactionType type;
  private final String category;
  private final BigDecimal amount;
  private final String action;

  public TransactionRecordedEvent(
      Object source,
      UUID userId,
      UUID transactionId,
      TransactionType type,
      String category,
      BigDecimal amount,
      String action) {
    super(source, userId);
    this.transactionId = transactionId;
    this.type = type;
    this.category = category;
    this.amount = amount;
    this.action = action;
  }

  public UUID getTransactionId() {
    return transactionId;
  }

  public TransactionType getType() {
    return type;
  }

  public String getCategory() {
    return category;
  }

  public BigDecimal getAmount() {
    return amount;
  }

  public String getAction() {
    return action;
  }
}
