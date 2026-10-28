package com.pocketledger.transaction.dto;

import com.pocketledger.transaction.enums.TransactionType;
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
public class TransactionResponse {
  private UUID id;
  private BigDecimal amount;
  private TransactionType type;
  private String category;
  private LocalDate transactionDate;
  private String description;
  private LocalDateTime createdAt;
}
