package com.pocketledger.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class BudgetProgressResponse {
    private UUID id;
    private String category;
    private BigDecimal monthlyLimit;
    private BigDecimal actualSpent;
    private BigDecimal remaining;
    private double percentageSpent;
    private String status; // "SAFE", "WARNING_80", "EXCEEDED"
}
