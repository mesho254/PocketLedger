package com.pocketledger.controller;

import com.pocketledger.dto.TransactionRequest;
import com.pocketledger.dto.TransactionResponse;
import com.pocketledger.model.TransactionType;
import com.pocketledger.security.UserPrincipal;
import com.pocketledger.service.TransactionService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/transactions")
@RequiredArgsConstructor
@Tag(name = "Transactions", description = "Endpoints for managing income and expense transactions")
public class TransactionController {

    private final TransactionService transactionService;

    @PostMapping
    @Operation(summary = "Create a new transaction")
    public ResponseEntity<TransactionResponse> createTransaction(
        @AuthenticationPrincipal UserPrincipal principal,
        @Valid @RequestBody TransactionRequest request
    ) {
        TransactionResponse response = transactionService.createTransaction(principal, request);
        return new ResponseEntity<>(response, HttpStatus.CREATED);
    }

    @GetMapping
    @Operation(summary = "List transactions with optional filtering and pagination")
    public ResponseEntity<Page<TransactionResponse>> getTransactions(
        @AuthenticationPrincipal UserPrincipal principal,
        @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
        @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate,
        @RequestParam(required = false) TransactionType type,
        @RequestParam(required = false) String category,
        @RequestParam(defaultValue = "0") int page,
        @RequestParam(defaultValue = "20") int size,
        @RequestParam(defaultValue = "transactionDate,desc") String[] sort
    ) {
        Sort sortOrder = Sort.by(Sort.Direction.DESC, "transactionDate").and(Sort.by(Sort.Direction.DESC, "createdAt"));
        Pageable pageable = PageRequest.of(page, size, sortOrder);

        Page<TransactionResponse> response = transactionService.getTransactions(
            principal, startDate, endDate, type, category, pageable
        );
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get a single transaction by ID")
    public ResponseEntity<TransactionResponse> getTransactionById(
        @AuthenticationPrincipal UserPrincipal principal,
        @PathVariable UUID id
    ) {
        TransactionResponse response = transactionService.getTransactionById(principal, id);
        return ResponseEntity.ok(response);
    }

    @PutMapping("/{id}")
    @Operation(summary = "Update an existing transaction")
    public ResponseEntity<TransactionResponse> updateTransaction(
        @AuthenticationPrincipal UserPrincipal principal,
        @PathVariable UUID id,
        @Valid @RequestBody TransactionRequest request
    ) {
        TransactionResponse response = transactionService.updateTransaction(principal, id, request);
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Delete a transaction")
    public ResponseEntity<Void> deleteTransaction(
        @AuthenticationPrincipal UserPrincipal principal,
        @PathVariable UUID id
    ) {
        transactionService.deleteTransaction(principal, id);
        return ResponseEntity.noContent().build();
    }
}
