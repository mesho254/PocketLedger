package com.pocketledger.service;

import com.pocketledger.dto.TransactionRequest;
import com.pocketledger.dto.TransactionResponse;
import com.pocketledger.exception.ResourceNotFoundException;
import com.pocketledger.model.Transaction;
import com.pocketledger.model.TransactionType;
import com.pocketledger.model.User;
import com.pocketledger.repository.TransactionRepository;
import com.pocketledger.security.UserPrincipal;
import jakarta.persistence.criteria.Predicate;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class TransactionService {

    private final TransactionRepository transactionRepository;
    private final AuthService authService;

    @Transactional
    public TransactionResponse createTransaction(UserPrincipal principal, TransactionRequest request) {
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
        return mapToResponse(saved);
    }

    @Transactional
    public TransactionResponse updateTransaction(UserPrincipal principal, UUID id, TransactionRequest request) {
        User user = authService.getUserEntity(principal);

        Transaction transaction = transactionRepository.findByIdAndUser(id, user)
            .orElseThrow(() -> new ResourceNotFoundException("Transaction not found or access denied"));

        transaction.setAmount(request.getAmount());
        transaction.setType(request.getType());
        transaction.setCategory(request.getCategory().toUpperCase().trim());
        transaction.setTransactionDate(request.getTransactionDate());
        transaction.setDescription(request.getDescription());

        Transaction updated = transactionRepository.save(transaction);
        return mapToResponse(updated);
    }

    @Transactional
    public void deleteTransaction(UserPrincipal principal, UUID id) {
        User user = authService.getUserEntity(principal);

        Transaction transaction = transactionRepository.findByIdAndUser(id, user)
            .orElseThrow(() -> new ResourceNotFoundException("Transaction not found or access denied"));

        transactionRepository.delete(transaction);
    }

    @Transactional(readOnly = true)
    public TransactionResponse getTransactionById(UserPrincipal principal, UUID id) {
        User user = authService.getUserEntity(principal);

        Transaction transaction = transactionRepository.findByIdAndUser(id, user)
            .orElseThrow(() -> new ResourceNotFoundException("Transaction not found or access denied"));

        return mapToResponse(transaction);
    }

    @Transactional(readOnly = true)
    public Page<TransactionResponse> getTransactions(
        UserPrincipal principal,
        LocalDate startDate,
        LocalDate endDate,
        TransactionType type,
        String category,
        Pageable pageable
    ) {
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
