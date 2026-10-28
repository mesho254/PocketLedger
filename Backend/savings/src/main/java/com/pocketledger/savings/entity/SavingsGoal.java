package com.pocketledger.savings.entity;

import com.pocketledger.auth.model.BaseAuditableEntity;
import com.pocketledger.auth.model.User;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.math.BigDecimal;
import java.time.LocalDate;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.experimental.SuperBuilder;

@Entity
@Table(name = "savings_goals")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@SuperBuilder
public class SavingsGoal extends BaseAuditableEntity {

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @JoinColumn(name = "user_id", nullable = false)
  private User user;

  @Column(nullable = false, length = 100)
  private String title;

  @Column(name = "target_amount", nullable = false, precision = 12, scale = 2)
  private BigDecimal targetAmount;

  @Builder.Default
  @Column(name = "current_amount", nullable = false, precision = 12, scale = 2)
  private BigDecimal currentAmount = BigDecimal.ZERO;

  @Column(name = "target_date")
  private LocalDate targetDate;

  @Builder.Default
  @Column(nullable = false, length = 20)
  private String status = "IN_PROGRESS";
}
