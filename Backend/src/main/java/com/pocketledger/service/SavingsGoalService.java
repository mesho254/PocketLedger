package com.pocketledger.service;

import com.pocketledger.dto.SavingsContributionRequest;
import com.pocketledger.dto.SavingsContributionResponse;
import com.pocketledger.dto.SavingsGoalRequest;
import com.pocketledger.dto.SavingsGoalResponse;
import com.pocketledger.exception.ResourceNotFoundException;
import com.pocketledger.model.SavingsContribution;
import com.pocketledger.model.SavingsGoal;
import com.pocketledger.model.User;
import com.pocketledger.repository.SavingsContributionRepository;
import com.pocketledger.repository.SavingsGoalRepository;
import com.pocketledger.security.UserPrincipal;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class SavingsGoalService {

    private final SavingsGoalRepository savingsGoalRepository;
    private final SavingsContributionRepository contributionRepository;
    private final AuthService authService;

    @Transactional
    public SavingsGoalResponse createGoal(UserPrincipal principal, SavingsGoalRequest request) {
        User user = authService.getUserEntity(principal);

        SavingsGoal goal = SavingsGoal.builder()
            .user(user)
            .title(request.getTitle().trim())
            .targetAmount(request.getTargetAmount())
            .currentAmount(BigDecimal.ZERO)
            .targetDate(request.getTargetDate())
            .status("IN_PROGRESS")
            .build();

        SavingsGoal saved = savingsGoalRepository.save(goal);
        return mapToResponse(saved);
    }

    @Transactional(readOnly = true)
    public List<SavingsGoalResponse> getGoals(UserPrincipal principal) {
        User user = authService.getUserEntity(principal);
        return savingsGoalRepository.findByUserOrderByCreatedAtDesc(user)
            .stream()
            .map(this::mapToResponse)
            .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public SavingsGoalResponse getGoalById(UserPrincipal principal, UUID goalId) {
        User user = authService.getUserEntity(principal);
        SavingsGoal goal = savingsGoalRepository.findByIdAndUser(goalId, user)
            .orElseThrow(() -> new ResourceNotFoundException("Savings goal not found"));
        return mapToResponse(goal);
    }

    @Transactional
    public SavingsGoalResponse addContribution(
        UserPrincipal principal,
        UUID goalId,
        SavingsContributionRequest request
    ) {
        User user = authService.getUserEntity(principal);
        SavingsGoal goal = savingsGoalRepository.findByIdAndUser(goalId, user)
            .orElseThrow(() -> new ResourceNotFoundException("Savings goal not found"));

        SavingsContribution contribution = SavingsContribution.builder()
            .savingsGoal(goal)
            .amount(request.getAmount())
            .contributionDate(request.getContributionDate() != null ? request.getContributionDate() : LocalDate.now())
            .note(request.getNote())
            .build();

        contributionRepository.save(contribution);

        BigDecimal updatedAmount = goal.getCurrentAmount().add(request.getAmount());
        goal.setCurrentAmount(updatedAmount);

        if (updatedAmount.compareTo(goal.getTargetAmount()) >= 0) {
            goal.setStatus("COMPLETED");
        }

        SavingsGoal savedGoal = savingsGoalRepository.save(goal);
        return mapToResponse(savedGoal);
    }

    @Transactional(readOnly = true)
    public List<SavingsContributionResponse> getContributions(UserPrincipal principal, UUID goalId) {
        User user = authService.getUserEntity(principal);
        SavingsGoal goal = savingsGoalRepository.findByIdAndUser(goalId, user)
            .orElseThrow(() -> new ResourceNotFoundException("Savings goal not found"));

        return contributionRepository.findBySavingsGoalOrderByContributionDateDescCreatedAtDesc(goal)
            .stream()
            .map(c -> SavingsContributionResponse.builder()
                .id(c.getId())
                .amount(c.getAmount())
                .contributionDate(c.getContributionDate())
                .note(c.getNote())
                .createdAt(c.getCreatedAt())
                .build())
            .collect(Collectors.toList());
    }

    @Transactional
    public void deleteGoal(UserPrincipal principal, UUID goalId) {
        User user = authService.getUserEntity(principal);
        SavingsGoal goal = savingsGoalRepository.findByIdAndUser(goalId, user)
            .orElseThrow(() -> new ResourceNotFoundException("Savings goal not found"));
        savingsGoalRepository.delete(goal);
    }

    private SavingsGoalResponse mapToResponse(SavingsGoal goal) {
        double percentage = 0.0;
        if (goal.getTargetAmount().compareTo(BigDecimal.ZERO) > 0) {
            percentage = goal.getCurrentAmount()
                .divide(goal.getTargetAmount(), 4, RoundingMode.HALF_UP)
                .multiply(BigDecimal.valueOf(100))
                .doubleValue();
        }

        return SavingsGoalResponse.builder()
            .id(goal.getId())
            .title(goal.getTitle())
            .targetAmount(goal.getTargetAmount())
            .currentAmount(goal.getCurrentAmount())
            .targetDate(goal.getTargetDate())
            .status(goal.getStatus())
            .percentageCompleted(percentage)
            .createdAt(goal.getCreatedAt())
            .build();
    }
}
