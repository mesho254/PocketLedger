package com.pocketledger.transaction.event;

import java.io.Serializable;
import java.time.Instant;
import java.util.UUID;
import org.springframework.context.ApplicationEvent;

public abstract class DomainEvent extends ApplicationEvent implements Serializable {

  private static final long serialVersionUID = 1L;

  private final UUID userId;
  private final String occurredAt;
  private final String eventType;

  public DomainEvent(Object source, UUID userId) {
    super(source);
    this.userId = userId;
    this.occurredAt = Instant.now().toString();
    this.eventType = this.getClass().getSimpleName();
  }

  public UUID getUserId() {
    return userId;
  }

  public String getOccurredAt() {
    return occurredAt;
  }

  public String getEventType() {
    return eventType;
  }
}
