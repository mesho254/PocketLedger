package com.pocketledger.dto;

import com.pocketledger.model.TransactionType;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

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
