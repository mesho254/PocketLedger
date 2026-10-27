package com.pocketledger.service;

import com.pocketledger.dto.TransactionRequest;
import com.pocketledger.dto.TransactionResponse;
import com.pocketledger.exception.ResourceNotFoundException;
import com.pocketledger.model.Transaction;
import com.pocketledger.model.TransactionType;
import com.pocketledger.model.User;
import com.pocketledger.repository.TransactionRepository;
import com.pocketledger.security.UserPrincipal;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class TransactionServiceTest {

    @Mock
    private TransactionRepository transactionRepository;

    @Mock
    private AuthService authService;

    @InjectMocks
    private TransactionService transactionService;

    private User sampleUser;
    private UserPrincipal samplePrincipal;
    private Transaction sampleTransaction;

    @BeforeEach
    void setUp() {
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

        verify(transactionRepository).save(argThat(tx ->
            tx.getUser().equals(sampleUser) &&
            tx.getAmount().compareTo(new BigDecimal("45.50")) == 0
        ));
    }

    @Test
    @DisplayName("Should prevent deleting transaction belonging to another user")
    void testDeleteTransactionOwnershipEnforcement() {
        UUID txId = UUID.randomUUID();
        when(authService.getUserEntity(samplePrincipal)).thenReturn(sampleUser);
        when(transactionRepository.findByIdAndUser(txId, sampleUser)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> transactionService.deleteTransaction(samplePrincipal, txId))
            .isInstanceOf(ResourceNotFoundException.class)
            .hasMessageContaining("Transaction not found or access denied");

        verify(transactionRepository, never()).delete(any(Transaction.class));
    }
}
