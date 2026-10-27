package com.pocketledger.service;

import com.pocketledger.dto.CategoryBreakdownResponse;
import com.pocketledger.dto.MonthlySummaryResponse;
import com.pocketledger.model.TransactionType;
import com.pocketledger.model.User;
import com.pocketledger.repository.TransactionRepository;
import com.pocketledger.security.UserPrincipal;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.temporal.TemporalAdjusters;
import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class AnalyticsService {

    private final TransactionRepository transactionRepository;
    private final AuthService authService;

    @Transactional(readOnly = true)
    public MonthlySummaryResponse getMonthlySummary(UserPrincipal principal, int year, int month) {
        User user = authService.getUserEntity(principal);

        LocalDate startDate = LocalDate.of(year, month, 1);
        LocalDate endDate = startDate.with(TemporalAdjusters.lastDayOfMonth());

        BigDecimal totalIncome = transactionRepository.sumAmountByUserAndTypeAndDateRange(
            user, TransactionType.INCOME, startDate, endDate
        );
        if (totalIncome == null) {
            totalIncome = BigDecimal.ZERO;
        }

        BigDecimal totalExpense = transactionRepository.sumAmountByUserAndTypeAndDateRange(
            user, TransactionType.EXPENSE, startDate, endDate
        );
        if (totalExpense == null) {
            totalExpense = BigDecimal.ZERO;
        }

        BigDecimal netSavings = totalIncome.subtract(totalExpense);

        double savingsRatePercentage = 0.0;
        if (totalIncome.compareTo(BigDecimal.ZERO) > 0) {
            savingsRatePercentage = netSavings
                .divide(totalIncome, 4, RoundingMode.HALF_UP)
                .multiply(BigDecimal.valueOf(100))
                .doubleValue();
        }

        List<TransactionRepository.CategorySumProjection> categorySums =
            transactionRepository.sumAmountByCategory(user, TransactionType.EXPENSE, startDate, endDate);

        List<CategoryBreakdownResponse> breakdown = new ArrayList<>();
        for (TransactionRepository.CategorySumProjection item : categorySums) {
            double percentage = 0.0;
            if (totalExpense.compareTo(BigDecimal.ZERO) > 0) {
                percentage = item.getTotalAmount()
                    .divide(totalExpense, 4, RoundingMode.HALF_UP)
                    .multiply(BigDecimal.valueOf(100))
                    .doubleValue();
            }
            breakdown.add(CategoryBreakdownResponse.builder()
                .category(item.getCategory())
                .amount(item.getTotalAmount())
                .percentage(percentage)
                .build());
        }

        return MonthlySummaryResponse.builder()
            .year(year)
            .month(month)
            .totalIncome(totalIncome)
            .totalExpense(totalExpense)
            .netSavings(netSavings)
            .savingsRatePercentage(savingsRatePercentage)
            .categoryBreakdown(breakdown)
            .build();
    }
}
