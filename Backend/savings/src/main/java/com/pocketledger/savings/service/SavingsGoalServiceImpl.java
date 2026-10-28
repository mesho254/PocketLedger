package com.pocketledger.savings.service;

import com.pocketledger.auth.model.User;
import com.pocketledger.auth.security.UserPrincipal;
import com.pocketledger.auth.service.AuthService;
import com.pocketledger.savings.dto.SavingsContributionRequest;
import com.pocketledger.savings.dto.SavingsContributionResponse;
import com.pocketledger.savings.dto.SavingsGoalRequest;
import com.pocketledger.savings.dto.SavingsGoalResponse;
import com.pocketledger.savings.entity.SavingsContribution;
import com.pocketledger.savings.entity.SavingsGoal;
import com.pocketledger.savings.enums.SavingsGoalStatus;
import com.pocketledger.savings.event.SavingsContributionRecordedEvent;
import com.pocketledger.savings.exception.SavingsGoalNotFoundException;
import com.pocketledger.savings.repository.SavingsContributionRepository;
import com.pocketledger.savings.repository.SavingsGoalRepository;
import com.pocketledger.savings.validation.SavingsGoalValidator;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class SavingsGoalServiceImpl implements SavingsGoalService {

  private final SavingsGoalRepository savingsGoalRepository;
  private final SavingsContributionRepository contributionRepository;
  private final AuthService authService;
  private final SavingsGoalValidator savingsGoalValidator;
  private final ApplicationEventPublisher eventPublisher;

  @Autowired
  public SavingsGoalServiceImpl(
      SavingsGoalRepository savingsGoalRepository,
      SavingsContributionRepository contributionRepository,
      AuthService authService,
      SavingsGoalValidator savingsGoalValidator,
      ApplicationEventPublisher eventPublisher) {
    this.savingsGoalRepository = savingsGoalRepository;
    this.contributionRepository = contributionRepository;
    this.authService = authService;
    this.savingsGoalValidator = savingsGoalValidator;
    this.eventPublisher = eventPublisher;
  }

  public SavingsGoalServiceImpl(
      SavingsGoalRepository savingsGoalRepository,
      SavingsContributionRepository contributionRepository,
      AuthService authService) {
    this(
        savingsGoalRepository,
        contributionRepository,
        authService,
        new SavingsGoalValidator(),
        null);
  }

  @Override
  @Transactional
  public SavingsGoalResponse createGoal(UserPrincipal principal, SavingsGoalRequest request) {
    if (savingsGoalValidator != null) {
      savingsGoalValidator.validateGoalForCreate(request);
    }
    User user = authService.getUserEntity(principal);

    SavingsGoal goal = SavingsGoal.builder()
        .user(user)
        .title(request.getTitle().trim())
        .targetAmount(request.getTargetAmount())
        .currentAmount(BigDecimal.ZERO)
        .targetDate(request.getTargetDate())
        .status(SavingsGoalStatus.IN_PROGRESS.name())
        .build();

    SavingsGoal saved = savingsGoalRepository.save(goal);
    return mapToResponse(saved);
  }

  @Override
  @Transactional(readOnly = true)
  public List<SavingsGoalResponse> getGoals(UserPrincipal principal) {
    User user = authService.getUserEntity(principal);
    return savingsGoalRepository.findByUserOrderByCreatedAtDesc(user).stream()
        .map(this::mapToResponse)
        .collect(Collectors.toList());
  }

  @Override
  @Transactional(readOnly = true)
  public SavingsGoalResponse getGoalById(UserPrincipal principal, UUID goalId) {
    User user = authService.getUserEntity(principal);
    SavingsGoal goal = savingsGoalRepository
        .findByIdAndUser(goalId, user)
        .orElseThrow(() -> new SavingsGoalNotFoundException("Savings goal not found"));
    return mapToResponse(goal);
  }

  @Override
  @Transactional
  public SavingsGoalResponse addContribution(
      UserPrincipal principal, UUID goalId, SavingsContributionRequest request) {
    if (savingsGoalValidator != null) {
      savingsGoalValidator.validateContribution(request);
    }
    User user = authService.getUserEntity(principal);
    SavingsGoal goal = savingsGoalRepository
        .findByIdAndUser(goalId, user)
        .orElseThrow(() -> new SavingsGoalNotFoundException("Savings goal not found"));

    SavingsContribution contribution = SavingsContribution.builder()
        .savingsGoal(goal)
        .amount(request.getAmount())
        .contributionDate(
            request.getContributionDate() != null
                ? request.getContributionDate()
                : LocalDate.now())
        .note(request.getNote())
        .build();

    contributionRepository.save(contribution);

    BigDecimal updatedAmount = goal.getCurrentAmount().add(request.getAmount());
    goal.setCurrentAmount(updatedAmount);

    if (updatedAmount.compareTo(goal.getTargetAmount()) >= 0) {
      goal.setStatus(SavingsGoalStatus.COMPLETED.name());
    }

    SavingsGoal savedGoal = savingsGoalRepository.save(goal);
    if (eventPublisher != null && user != null) {
      eventPublisher.publishEvent(
          new SavingsContributionRecordedEvent(
              this,
              user.getId(),
              savedGoal.getId(),
              request.getAmount(),
              savedGoal.getCurrentAmount(),
              savedGoal.getStatus()));
    }
    return mapToResponse(savedGoal);
  }

  @Override
  @Transactional(readOnly = true)
  public List<SavingsContributionResponse> getContributions(UserPrincipal principal, UUID goalId) {
    User user = authService.getUserEntity(principal);
    SavingsGoal goal = savingsGoalRepository
        .findByIdAndUser(goalId, user)
        .orElseThrow(() -> new SavingsGoalNotFoundException("Savings goal not found"));

    return contributionRepository
        .findBySavingsGoalOrderByContributionDateDescCreatedAtDesc(goal)
        .stream()
        .map(
            c -> SavingsContributionResponse.builder()
                .id(c.getId())
                .amount(c.getAmount())
                .contributionDate(c.getContributionDate())
                .note(c.getNote())
                .createdAt(c.getCreatedAt())
                .build())
        .collect(Collectors.toList());
  }

  @Override
  @Transactional
  public void deleteGoal(UserPrincipal principal, UUID goalId) {
    User user = authService.getUserEntity(principal);
    SavingsGoal goal = savingsGoalRepository
        .findByIdAndUser(goalId, user)
        .orElseThrow(() -> new SavingsGoalNotFoundException("Savings goal not found"));
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
