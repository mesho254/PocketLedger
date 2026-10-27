package com.pocketledger.model;

import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.util.UUID;

@Entity
@Table(
    name = "budgets",
    uniqueConstraints = {
        @UniqueConstraint(name = "uk_user_year_month_category", columnNames = {"user_id", "budget_year", "budget_month", "category"})
    }
)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Budget {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

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
