package com.pocketledger.savings.dto;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SavingsContributionResponse {
  private UUID id;
  private BigDecimal amount;
  private LocalDate contributionDate;
  private String note;
  private LocalDateTime createdAt;
}
