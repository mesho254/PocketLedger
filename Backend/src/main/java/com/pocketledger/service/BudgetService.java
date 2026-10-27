package com.pocketledger.service;

import com.pocketledger.dto.BudgetProgressResponse;
import com.pocketledger.dto.BudgetRequest;
import com.pocketledger.dto.BudgetResponse;
import com.pocketledger.exception.ResourceNotFoundException;
import com.pocketledger.model.Budget;
import com.pocketledger.model.TransactionType;
import com.pocketledger.model.User;
import com.pocketledger.repository.BudgetRepository;
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
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class BudgetService {

    private final BudgetRepository budgetRepository;
    private final TransactionRepository transactionRepository;
    private final AuthService authService;

    @Transactional
    public BudgetResponse setBudget(UserPrincipal principal, BudgetRequest request) {
        User user = authService.getUserEntity(principal);
        String category = request.getCategory().toUpperCase().trim();

        Budget budget = budgetRepository.findByUserAndYearAndMonthAndCategory(
            user, request.getYear(), request.getMonth(), category
        ).orElseGet(() -> Budget.builder()
            .user(user)
            .category(category)
            .year(request.getYear())
            .month(request.getMonth())
            .build());

        budget.setMonthlyLimit(request.getMonthlyLimit());
        Budget saved = budgetRepository.save(budget);

        return mapToResponse(saved);
    }

    @Transactional(readOnly = true)
    public List<BudgetResponse> getBudgets(UserPrincipal principal, int year, int month) {
        User user = authService.getUserEntity(principal);
        return budgetRepository.findByUserAndYearAndMonth(user, year, month)
            .stream()
            .map(this::mapToResponse)
            .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<BudgetProgressResponse> getBudgetProgress(UserPrincipal principal, int year, int month) {
        User user = authService.getUserEntity(principal);
        List<Budget> budgets = budgetRepository.findByUserAndYearAndMonth(user, year, month);

        LocalDate startDate = LocalDate.of(year, month, 1);
        LocalDate endDate = startDate.with(TemporalAdjusters.lastDayOfMonth());

        List<TransactionRepository.CategorySumProjection> categoryExpenses =
            transactionRepository.sumAmountByCategory(user, TransactionType.EXPENSE, startDate, endDate);

        Map<String, BigDecimal> expenseMap = categoryExpenses.stream()
            .collect(Collectors.toMap(
                TransactionRepository.CategorySumProjection::getCategory,
                TransactionRepository.CategorySumProjection::getTotalAmount
            ));

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

            String status = "SAFE";
            if (percentageSpent >= 100.0) {
                status = "EXCEEDED";
            } else if (percentageSpent >= 80.0) {
                status = "WARNING_80";
            }

            progressList.add(BudgetProgressResponse.builder()
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

    @Transactional
    public void deleteBudget(UserPrincipal principal, UUID id) {
        User user = authService.getUserEntity(principal);
        Budget budget = budgetRepository.findByIdAndUser(id, user)
            .orElseThrow(() -> new ResourceNotFoundException("Budget not found or access denied"));
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
