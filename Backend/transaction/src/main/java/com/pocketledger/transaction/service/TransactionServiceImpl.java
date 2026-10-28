package com.pocketledger.transaction.service;

import com.pocketledger.auth.model.User;
import com.pocketledger.auth.security.UserPrincipal;
import com.pocketledger.auth.service.AuthService;
import com.pocketledger.transaction.dto.TransactionRequest;
import com.pocketledger.transaction.dto.TransactionResponse;
import com.pocketledger.transaction.entity.Transaction;
import com.pocketledger.transaction.enums.TransactionType;
import com.pocketledger.transaction.event.TransactionRecordedEvent;
import com.pocketledger.transaction.exception.TransactionNotFoundException;
import com.pocketledger.transaction.repository.TransactionRepository;
import com.pocketledger.transaction.validation.TransactionValidator;
import jakarta.persistence.criteria.Predicate;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class TransactionServiceImpl implements TransactionService {

  private final TransactionRepository transactionRepository;
  private final AuthService authService;
  private final TransactionValidator transactionValidator;
  private final ApplicationEventPublisher eventPublisher;

  @Autowired
  public TransactionServiceImpl(
      TransactionRepository transactionRepository,
      AuthService authService,
      TransactionValidator transactionValidator,
      ApplicationEventPublisher eventPublisher) {
    this.transactionRepository = transactionRepository;
    this.authService = authService;
    this.transactionValidator = transactionValidator;
    this.eventPublisher = eventPublisher;
  }

  public TransactionServiceImpl(
      TransactionRepository transactionRepository, AuthService authService) {
    this(transactionRepository, authService, new TransactionValidator(), null);
  }

  @Override
  @Transactional
  public TransactionResponse createTransaction(
      UserPrincipal principal, TransactionRequest request) {
    if (transactionValidator != null) {
      transactionValidator.validateForCreate(request);
    }
    User user = authService.getUserEntity(principal);

    Transaction transaction = Transaction.builder()
        .user(user)
        .amount(request.getAmount())
        .type(request.getType())
        .category(request.getCategory().toUpperCase().trim())
        .transactionDate(request.getTransactionDate())
        .description(request.getDescription())
        .build();

    Transaction saved = transactionRepository.save(transaction);
    if (eventPublisher != null && user != null) {
      eventPublisher.publishEvent(
          new TransactionRecordedEvent(
              this,
              user.getId(),
              saved.getId(),
              saved.getType(),
              saved.getCategory(),
              saved.getAmount(),
              "CREATED"));
    }
    return mapToResponse(saved);
  }

  @Override
  @Transactional
  public TransactionResponse updateTransaction(
      UserPrincipal principal, UUID id, TransactionRequest request) {
    if (transactionValidator != null) {
      transactionValidator.validateForUpdate(request);
    }
    User user = authService.getUserEntity(principal);

    Transaction transaction = transactionRepository
        .findByIdAndUser(id, user)
        .orElseThrow(
            () -> new TransactionNotFoundException("Transaction not found or access denied"));

    transaction.setAmount(request.getAmount());
    transaction.setType(request.getType());
    transaction.setCategory(request.getCategory().toUpperCase().trim());
    transaction.setTransactionDate(request.getTransactionDate());
    transaction.setDescription(request.getDescription());

    Transaction updated = transactionRepository.save(transaction);
    if (eventPublisher != null && user != null) {
      eventPublisher.publishEvent(
          new TransactionRecordedEvent(
              this,
              user.getId(),
              updated.getId(),
              updated.getType(),
              updated.getCategory(),
              updated.getAmount(),
              "UPDATED"));
    }
    return mapToResponse(updated);
  }

  @Override
  @Transactional
  public void deleteTransaction(UserPrincipal principal, UUID id) {
    User user = authService.getUserEntity(principal);

    Transaction transaction = transactionRepository
        .findByIdAndUser(id, user)
        .orElseThrow(
            () -> new TransactionNotFoundException("Transaction not found or access denied"));

    transactionRepository.delete(transaction);
  }

  @Override
  @Transactional(readOnly = true)
  public TransactionResponse getTransactionById(UserPrincipal principal, UUID id) {
    User user = authService.getUserEntity(principal);

    Transaction transaction = transactionRepository
        .findByIdAndUser(id, user)
        .orElseThrow(
            () -> new TransactionNotFoundException("Transaction not found or access denied"));

    return mapToResponse(transaction);
  }

  @Override
  @Transactional(readOnly = true)
  public Page<TransactionResponse> getTransactions(
      UserPrincipal principal,
      LocalDate startDate,
      LocalDate endDate,
      TransactionType type,
      String category,
      Pageable pageable) {
    User user = authService.getUserEntity(principal);

    Specification<Transaction> spec = (root, query, cb) -> {
      List<Predicate> predicates = new ArrayList<>();
      predicates.add(cb.equal(root.get("user"), user));

      if (startDate != null) {
        predicates.add(cb.greaterThanOrEqualTo(root.get("transactionDate"), startDate));
      }
      if (endDate != null) {
        predicates.add(cb.lessThanOrEqualTo(root.get("transactionDate"), endDate));
      }
      if (type != null) {
        predicates.add(cb.equal(root.get("type"), type));
      }
      if (category != null && !category.isBlank()) {
        predicates.add(cb.equal(root.get("category"), category.toUpperCase().trim()));
      }

      return cb.and(predicates.toArray(new Predicate[0]));
    };

    return transactionRepository.findAll(spec, pageable).map(this::mapToResponse);
  }

  @Override
  public TransactionResponse mapToResponse(Transaction tx) {
    return TransactionResponse.builder()
        .id(tx.getId())
        .amount(tx.getAmount())
        .type(tx.getType())
        .category(tx.getCategory())
        .transactionDate(tx.getTransactionDate())
        .description(tx.getDescription())
        .createdAt(tx.getCreatedAt())
        .build();
  }
}
