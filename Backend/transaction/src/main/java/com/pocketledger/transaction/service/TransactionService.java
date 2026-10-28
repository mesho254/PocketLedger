package com.pocketledger.transaction.service;

import com.pocketledger.auth.security.UserPrincipal;
import com.pocketledger.transaction.dto.TransactionRequest;
import com.pocketledger.transaction.dto.TransactionResponse;
import com.pocketledger.transaction.entity.Transaction;
import com.pocketledger.transaction.enums.TransactionType;
import java.time.LocalDate;
import java.util.UUID;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

public interface TransactionService {

  TransactionResponse createTransaction(UserPrincipal principal, TransactionRequest request);

  TransactionResponse updateTransaction(
      UserPrincipal principal, UUID id, TransactionRequest request);

  void deleteTransaction(UserPrincipal principal, UUID id);

  TransactionResponse getTransactionById(UserPrincipal principal, UUID id);

  Page<TransactionResponse> getTransactions(
      UserPrincipal principal,
      LocalDate startDate,
      LocalDate endDate,
      TransactionType type,
      String category,
      Pageable pageable);

  TransactionResponse mapToResponse(Transaction tx);
}
