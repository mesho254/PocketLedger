package com.pocketledger.analytics.service;

import com.pocketledger.analytics.dto.CategoryBreakdownResponse;
import com.pocketledger.analytics.dto.MonthlySummaryResponse;
import com.pocketledger.analytics.validation.AnalyticsValidator;
import com.pocketledger.auth.model.User;
import com.pocketledger.auth.security.UserPrincipal;
import com.pocketledger.auth.service.AuthService;
import com.pocketledger.transaction.enums.TransactionType;
import com.pocketledger.transaction.repository.TransactionRepository;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.temporal.TemporalAdjusters;
import java.util.ArrayList;
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AnalyticsServiceImpl implements AnalyticsService {

  private final TransactionRepository transactionRepository;
  private final AuthService authService;
  private final AnalyticsValidator analyticsValidator;

  @Autowired
  public AnalyticsServiceImpl(
      TransactionRepository transactionRepository,
      AuthService authService,
      AnalyticsValidator analyticsValidator) {
    this.transactionRepository = transactionRepository;
    this.authService = authService;
    this.analyticsValidator = analyticsValidator;
  }

  public AnalyticsServiceImpl(
      TransactionRepository transactionRepository, AuthService authService) {
    this(transactionRepository, authService, new AnalyticsValidator());
  }

  @Override
  @Transactional(readOnly = true)
  public MonthlySummaryResponse getMonthlySummary(UserPrincipal principal, int year, int month) {
    if (analyticsValidator != null) {
      analyticsValidator.validateYearAndMonth(year, month);
    }
    User user = authService.getUserEntity(principal);

    LocalDate startDate = LocalDate.of(year, month, 1);
    LocalDate endDate = startDate.with(TemporalAdjusters.lastDayOfMonth());

    BigDecimal totalIncome = transactionRepository.sumAmountByUserAndTypeAndDateRange(
        user, TransactionType.INCOME, startDate, endDate);
    if (totalIncome == null) {
      totalIncome = BigDecimal.ZERO;
    }

    BigDecimal totalExpense = transactionRepository.sumAmountByUserAndTypeAndDateRange(
        user, TransactionType.EXPENSE, startDate, endDate);
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

    List<TransactionRepository.CategorySumProjection> categorySums = transactionRepository.sumAmountByCategory(
        user, TransactionType.EXPENSE, startDate, endDate);

    List<CategoryBreakdownResponse> breakdown = new ArrayList<>();
    for (TransactionRepository.CategorySumProjection item : categorySums) {
      double percentage = 0.0;
      if (totalExpense.compareTo(BigDecimal.ZERO) > 0) {
        percentage = item.getTotalAmount()
            .divide(totalExpense, 4, RoundingMode.HALF_UP)
            .multiply(BigDecimal.valueOf(100))
            .doubleValue();
      }
      breakdown.add(
          CategoryBreakdownResponse.builder()
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
