package com.pocketledger.savings.controller;

import com.pocketledger.auth.security.UserPrincipal;
import com.pocketledger.savings.dto.SavingsContributionRequest;
import com.pocketledger.savings.dto.SavingsContributionResponse;
import com.pocketledger.savings.dto.SavingsGoalRequest;
import com.pocketledger.savings.dto.SavingsGoalResponse;
import com.pocketledger.savings.service.SavingsGoalService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping({ "/api/v1/savings-goals", "/api/savings-goals" })
@RequiredArgsConstructor
@Tag(name = "Savings Goals", description = "Endpoints for managing target savings goals and contributions")
public class SavingsGoalController {

  private final SavingsGoalService savingsGoalService;

  @PostMapping
  @Operation(summary = "Create a new savings goal")
  public ResponseEntity<SavingsGoalResponse> createGoal(
      @AuthenticationPrincipal UserPrincipal principal,
      @Valid @RequestBody SavingsGoalRequest request) {
    SavingsGoalResponse response = savingsGoalService.createGoal(principal, request);
    return new ResponseEntity<>(response, HttpStatus.CREATED);
  }

  @GetMapping
  @Operation(summary = "List all savings goals for the user")
  public ResponseEntity<List<SavingsGoalResponse>> getGoals(
      @AuthenticationPrincipal UserPrincipal principal) {
    List<SavingsGoalResponse> response = savingsGoalService.getGoals(principal);
    return ResponseEntity.ok(response);
  }

  @GetMapping("/{id}")
  @Operation(summary = "Get a single savings goal by ID")
  public ResponseEntity<SavingsGoalResponse> getGoalById(
      @AuthenticationPrincipal UserPrincipal principal, @PathVariable UUID id) {
    SavingsGoalResponse response = savingsGoalService.getGoalById(principal, id);
    return ResponseEntity.ok(response);
  }

  @PostMapping("/{id}/contributions")
  @Operation(summary = "Add a deposit/contribution to a savings goal")
  public ResponseEntity<SavingsGoalResponse> addContribution(
      @AuthenticationPrincipal UserPrincipal principal,
      @PathVariable UUID id,
      @Valid @RequestBody SavingsContributionRequest request) {
    SavingsGoalResponse response = savingsGoalService.addContribution(principal, id, request);
    return ResponseEntity.ok(response);
  }

  @GetMapping("/{id}/contributions")
  @Operation(summary = "List contribution history for a savings goal")
  public ResponseEntity<List<SavingsContributionResponse>> getContributions(
      @AuthenticationPrincipal UserPrincipal principal, @PathVariable UUID id) {
    List<SavingsContributionResponse> response = savingsGoalService.getContributions(principal, id);
    return ResponseEntity.ok(response);
  }

  @DeleteMapping("/{id}")
  @Operation(summary = "Delete a savings goal")
  public ResponseEntity<Void> deleteGoal(
      @AuthenticationPrincipal UserPrincipal principal, @PathVariable UUID id) {
    savingsGoalService.deleteGoal(principal, id);
    return ResponseEntity.noContent().build();
  }
}
