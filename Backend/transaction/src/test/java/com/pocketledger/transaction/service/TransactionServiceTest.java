package com.pocketledger.transaction.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.argThat;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.pocketledger.auth.model.User;
import com.pocketledger.auth.security.UserPrincipal;
import com.pocketledger.auth.service.AuthService;
import com.pocketledger.transaction.dto.TransactionRequest;
import com.pocketledger.transaction.dto.TransactionResponse;
import com.pocketledger.transaction.entity.Transaction;
import com.pocketledger.transaction.enums.TransactionType;
import com.pocketledger.transaction.exception.TransactionNotFoundException;
import com.pocketledger.transaction.repository.TransactionRepository;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.Optional;
import java.util.UUID;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
class TransactionServiceTest {

    @Mock
    private TransactionRepository transactionRepository;

    @Mock
    private AuthService authService;

    private TransactionServiceImpl transactionService;

    private User sampleUser;
    private UserPrincipal samplePrincipal;
    private Transaction sampleTransaction;

    @BeforeEach
    void setUp() {
        transactionService = new TransactionServiceImpl(transactionRepository, authService);

        sampleUser = User.builder()
                .id(UUID.randomUUID())
                .email("test@pocketledger.com")
                .fullName("Jane Doe")
                .currency("USD")
                .build();

        samplePrincipal = UserPrincipal.create(sampleUser);

        sampleTransaction = Transaction.builder()
                .id(UUID.randomUUID())
                .user(sampleUser)
                .amount(new BigDecimal("45.50"))
                .type(TransactionType.EXPENSE)
                .category("FOOD")
                .transactionDate(LocalDate.now())
                .description("Groceries")
                .build();
    }

    @Test
    @DisplayName("Should create transaction linked to the authenticated user")
    void testCreateTransaction() {
        TransactionRequest request = TransactionRequest.builder()
                .amount(new BigDecimal("45.50"))
                .type(TransactionType.EXPENSE)
                .category("FOOD")
                .transactionDate(LocalDate.now())
                .description("Groceries")
                .build();

        when(authService.getUserEntity(samplePrincipal)).thenReturn(sampleUser);
        when(transactionRepository.save(any(Transaction.class))).thenReturn(sampleTransaction);

        TransactionResponse response = transactionService.createTransaction(samplePrincipal, request);

        assertThat(response).isNotNull();
        assertThat(response.getAmount()).isEqualByComparingTo("45.50");
        assertThat(response.getType()).isEqualTo(TransactionType.EXPENSE);
        assertThat(response.getCategory()).isEqualTo("FOOD");

        verify(transactionRepository)
                .save(
                        argThat(
                                tx -> tx.getUser().equals(sampleUser)
                                        && tx.getAmount().compareTo(new BigDecimal("45.50")) == 0));
    }

    @Test
    @DisplayName("Should prevent deleting transaction belonging to another user")
    void testDeleteTransactionOwnershipEnforcement() {
        UUID txId = UUID.randomUUID();
        when(authService.getUserEntity(samplePrincipal)).thenReturn(sampleUser);
        when(transactionRepository.findByIdAndUser(txId, sampleUser)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> transactionService.deleteTransaction(samplePrincipal, txId))
                .isInstanceOf(TransactionNotFoundException.class)
                .hasMessageContaining("Transaction not found or access denied");

        verify(transactionRepository, never()).delete(any(Transaction.class));
    }
}
