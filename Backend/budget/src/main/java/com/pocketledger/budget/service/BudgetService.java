package com.pocketledger.budget.service;

import com.pocketledger.auth.security.UserPrincipal;
import com.pocketledger.budget.dto.BudgetProgressResponse;
import com.pocketledger.budget.dto.BudgetRequest;
import com.pocketledger.budget.dto.BudgetResponse;
import java.util.List;
import java.util.UUID;

public interface BudgetService {

  BudgetResponse setBudget(UserPrincipal principal, BudgetRequest request);

  List<BudgetResponse> getBudgets(UserPrincipal principal, int year, int month);

  List<BudgetProgressResponse> getBudgetProgress(UserPrincipal principal, int year, int month);

  void deleteBudget(UserPrincipal principal, UUID id);
}
