package com.pocketledger.budget.service;

import com.pocketledger.auth.model.User;
import com.pocketledger.auth.security.UserPrincipal;
import com.pocketledger.auth.service.AuthService;
import com.pocketledger.budget.dto.BudgetProgressResponse;
import com.pocketledger.budget.dto.BudgetRequest;
import com.pocketledger.budget.dto.BudgetResponse;
import com.pocketledger.budget.entity.Budget;
import com.pocketledger.budget.enums.BudgetStatus;
import com.pocketledger.budget.event.BudgetConfiguredEvent;
import com.pocketledger.budget.exception.BudgetNotFoundException;
import com.pocketledger.budget.repository.BudgetRepository;
import com.pocketledger.budget.validation.BudgetValidator;
import com.pocketledger.transaction.enums.TransactionType;
import com.pocketledger.transaction.repository.TransactionRepository;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.temporal.TemporalAdjusters;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class BudgetServiceImpl implements BudgetService {

  private final BudgetRepository budgetRepository;
  private final TransactionRepository transactionRepository;
  private final AuthService authService;
  private final BudgetValidator budgetValidator;
  private final ApplicationEventPublisher eventPublisher;

  @Autowired
  public BudgetServiceImpl(
      BudgetRepository budgetRepository,
      TransactionRepository transactionRepository,
      AuthService authService,
      BudgetValidator budgetValidator,
      ApplicationEventPublisher eventPublisher) {
    this.budgetRepository = budgetRepository;
    this.transactionRepository = transactionRepository;
    this.authService = authService;
    this.budgetValidator = budgetValidator;
    this.eventPublisher = eventPublisher;
  }

  public BudgetServiceImpl(
      BudgetRepository budgetRepository,
      TransactionRepository transactionRepository,
      AuthService authService) {
    this(budgetRepository, transactionRepository, authService, new BudgetValidator(), null);
  }

  @Override
  @Transactional
  public BudgetResponse setBudget(UserPrincipal principal, BudgetRequest request) {
    if (budgetValidator != null) {
      budgetValidator.validateForCreateOrUpdate(request);
    }
    User user = authService.getUserEntity(principal);
    String category = request.getCategory().toUpperCase().trim();

    Budget budget = budgetRepository
        .findByUserAndYearAndMonthAndCategory(
            user, request.getYear(), request.getMonth(), category)
        .orElseGet(
            () -> Budget.builder()
                .user(user)
                .category(category)
                .year(request.getYear())
                .month(request.getMonth())
                .build());

    budget.setMonthlyLimit(request.getMonthlyLimit());
    Budget saved = budgetRepository.save(budget);

    if (eventPublisher != null && user != null) {
      eventPublisher.publishEvent(
          new BudgetConfiguredEvent(
              this,
              user.getId(),
              saved.getId(),
              saved.getCategory(),
              saved.getMonthlyLimit(),
              saved.getYear(),
              saved.getMonth()));
    }

    return mapToResponse(saved);
  }

  @Override
  @Transactional(readOnly = true)
  public List<BudgetResponse> getBudgets(UserPrincipal principal, int year, int month) {
    User user = authService.getUserEntity(principal);
    return budgetRepository.findByUserAndYearAndMonth(user, year, month).stream()
        .map(this::mapToResponse)
        .collect(Collectors.toList());
  }

  @Override
  @Transactional(readOnly = true)
  public List<BudgetProgressResponse> getBudgetProgress(
      UserPrincipal principal, int year, int month) {
    User user = authService.getUserEntity(principal);
    List<Budget> budgets = budgetRepository.findByUserAndYearAndMonth(user, year, month);

    LocalDate startDate = LocalDate.of(year, month, 1);
    LocalDate endDate = startDate.with(TemporalAdjusters.lastDayOfMonth());

    List<TransactionRepository.CategorySumProjection> categoryExpenses = transactionRepository.sumAmountByCategory(
        user, TransactionType.EXPENSE, startDate, endDate);

    Map<String, BigDecimal> expenseMap = categoryExpenses.stream()
        .collect(
            Collectors.toMap(
                TransactionRepository.CategorySumProjection::getCategory,
                TransactionRepository.CategorySumProjection::getTotalAmount));

    List<BudgetProgressResponse> progressList = new ArrayList<>();
    for (Budget budget : budgets) {
      BigDecimal actualSpent = expenseMap.getOrDefault(budget.getCategory(), BigDecimal.ZERO);
      BigDecimal remaining = budget.getMonthlyLimit().subtract(actualSpent);

      double percentageSpent = 0.0;
      if (budget.getMonthlyLimit().compareTo(BigDecimal.ZERO) > 0) {
        percentageSpent = actualSpent
            .divide(budget.getMonthlyLimit(), 4, RoundingMode.HALF_UP)
            .multiply(BigDecimal.valueOf(100))
            .doubleValue();
      }

      String status = BudgetStatus.SAFE.name();
      if (percentageSpent >= 100.0) {
        status = BudgetStatus.EXCEEDED.name();
      } else if (percentageSpent >= 80.0) {
        status = BudgetStatus.WARNING_80.name();
      }

      progressList.add(
          BudgetProgressResponse.builder()
              .id(budget.getId())
              .category(budget.getCategory())
              .monthlyLimit(budget.getMonthlyLimit())
              .actualSpent(actualSpent)
              .remaining(remaining)
              .percentageSpent(percentageSpent)
              .status(status)
              .build());
    }

    return progressList;
  }

  @Override
  @Transactional
  public void deleteBudget(UserPrincipal principal, UUID id) {
    User user = authService.getUserEntity(principal);
    Budget budget = budgetRepository
        .findByIdAndUser(id, user)
        .orElseThrow(() -> new BudgetNotFoundException("Budget not found or access denied"));
    budgetRepository.delete(budget);
  }

  private BudgetResponse mapToResponse(Budget budget) {
    return BudgetResponse.builder()
        .id(budget.getId())
        .category(budget.getCategory())
        .monthlyLimit(budget.getMonthlyLimit())
        .month(budget.getMonth())
        .year(budget.getYear())
        .build();
  }
}
