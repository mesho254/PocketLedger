package com.pocketledger.transaction.entity;

import com.pocketledger.auth.model.BaseAuditableEntity;
import com.pocketledger.auth.model.User;
import com.pocketledger.transaction.enums.TransactionType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.Index;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.math.BigDecimal;
import java.time.LocalDate;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.experimental.SuperBuilder;

@Entity
@Table(name = "transactions", indexes = {
    @Index(name = "idx_tx_user_date", columnList = "user_id, transaction_date DESC"),
    @Index(name = "idx_tx_user_type", columnList = "user_id, type")
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@SuperBuilder
public class Transaction extends BaseAuditableEntity {

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @JoinColumn(name = "user_id", nullable = false)
  private User user;

  @Column(nullable = false, precision = 12, scale = 2)
  private BigDecimal amount;

  @Enumerated(EnumType.STRING)
  @Column(nullable = false, length = 10)
  private TransactionType type;

  @Column(nullable = false, length = 50)
  private String category;

  @Column(name = "transaction_date", nullable = false)
  private LocalDate transactionDate;

  @Column(length = 255)
  private String description;
}
