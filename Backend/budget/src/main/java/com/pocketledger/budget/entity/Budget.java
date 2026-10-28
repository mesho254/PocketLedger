package com.pocketledger.budget.entity;

import com.pocketledger.auth.model.BaseAuditableEntity;
import com.pocketledger.auth.model.User;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;
import java.math.BigDecimal;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.experimental.SuperBuilder;

@Entity
@Table(name = "budgets", uniqueConstraints = {
    @UniqueConstraint(name = "uk_user_year_month_category", columnNames = { "user_id", "budget_year", "budget_month",
        "category" })
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@SuperBuilder
public class Budget extends BaseAuditableEntity {

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @JoinColumn(name = "user_id", nullable = false)
  private User user;

  @Column(nullable = false, length = 50)
  private String category;

  @Column(name = "monthly_limit", nullable = false, precision = 12, scale = 2)
  private BigDecimal monthlyLimit;

  @Column(name = "budget_month", nullable = false)
  private int month;

  @Column(name = "budget_year", nullable = false)
  private int year;
}
