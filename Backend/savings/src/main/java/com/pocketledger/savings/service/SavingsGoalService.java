package com.pocketledger.savings.service;

import com.pocketledger.auth.security.UserPrincipal;
import com.pocketledger.savings.dto.SavingsContributionRequest;
import com.pocketledger.savings.dto.SavingsContributionResponse;
import com.pocketledger.savings.dto.SavingsGoalRequest;
import com.pocketledger.savings.dto.SavingsGoalResponse;
import java.util.List;
import java.util.UUID;

public interface SavingsGoalService {

  SavingsGoalResponse createGoal(UserPrincipal principal, SavingsGoalRequest request);

  List<SavingsGoalResponse> getGoals(UserPrincipal principal);

  SavingsGoalResponse getGoalById(UserPrincipal principal, UUID goalId);

  SavingsGoalResponse addContribution(
      UserPrincipal principal, UUID goalId, SavingsContributionRequest request);

  List<SavingsContributionResponse> getContributions(UserPrincipal principal, UUID goalId);

  void deleteGoal(UserPrincipal principal, UUID goalId);
}
