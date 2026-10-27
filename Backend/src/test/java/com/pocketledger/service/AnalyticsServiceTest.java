package com.pocketledger.service;

import com.pocketledger.dto.MonthlySummaryResponse;
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
import java.util.List;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class AnalyticsServiceTest {

    @Mock
    private TransactionRepository transactionRepository;

    @Mock
    private AuthService authService;

    @InjectMocks
    private AnalyticsService analyticsService;

    private User sampleUser;
    private UserPrincipal samplePrincipal;

    @BeforeEach
    void setUp() {
        sampleUser = User.builder()
            .id(UUID.randomUUID())
            .email("test@pocketledger.com")
            .fullName("Jane Doe")
            .currency("USD")
            .build();

        samplePrincipal = UserPrincipal.create(sampleUser);
    }

    @Test
    @DisplayName("Should accurately compute monthly income, expenses, and savings rate")
    void testGetMonthlySummary() {
        when(authService.getUserEntity(samplePrincipal)).thenReturn(sampleUser);

        when(transactionRepository.sumAmountByUserAndTypeAndDateRange(
            eq(sampleUser), eq(TransactionType.INCOME), any(LocalDate.class), any(LocalDate.class)
        )).thenReturn(new BigDecimal("5000.00"));

        when(transactionRepository.sumAmountByUserAndTypeAndDateRange(
            eq(sampleUser), eq(TransactionType.EXPENSE), any(LocalDate.class), any(LocalDate.class)
        )).thenReturn(new BigDecimal("2000.00"));

        TransactionRepository.CategorySumProjection foodProj = new TransactionRepository.CategorySumProjection() {
            @Override public String getCategory() { return "FOOD"; }
            @Override public BigDecimal getTotalAmount() { return new BigDecimal("1000.00"); }
        };
        TransactionRepository.CategorySumProjection rentProj = new TransactionRepository.CategorySumProjection() {
            @Override public String getCategory() { return "RENT"; }
            @Override public BigDecimal getTotalAmount() { return new BigDecimal("1000.00"); }
        };

        when(transactionRepository.sumAmountByCategory(
            eq(sampleUser), eq(TransactionType.EXPENSE), any(LocalDate.class), any(LocalDate.class)
        )).thenReturn(List.of(foodProj, rentProj));

        MonthlySummaryResponse summary = analyticsService.getMonthlySummary(samplePrincipal, 2026, 10);

        assertThat(summary).isNotNull();
        assertThat(summary.getTotalIncome()).isEqualByComparingTo("5000.00");
        assertThat(summary.getTotalExpense()).isEqualByComparingTo("2000.00");
        assertThat(summary.getNetSavings()).isEqualByComparingTo("3000.00");
        assertThat(summary.getSavingsRatePercentage()).isEqualTo(60.0);
        assertThat(summary.getCategoryBreakdown()).hasSize(2);
        assertThat(summary.getCategoryBreakdown().get(0).getPercentage()).isEqualTo(50.0);
    }
}
