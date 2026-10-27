package com.pocketledger.controller;

import com.pocketledger.dto.BudgetProgressResponse;
import com.pocketledger.dto.BudgetRequest;
import com.pocketledger.dto.BudgetResponse;
import com.pocketledger.security.UserPrincipal;
import com.pocketledger.service.BudgetService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/budgets")
@RequiredArgsConstructor
@Tag(name = "Budgets", description = "Endpoints for monthly category budgets and progress tracking")
public class BudgetController {

    private final BudgetService budgetService;

    @PostMapping
    @Operation(summary = "Set or update a budget limit for a category in a specific month")
    public ResponseEntity<BudgetResponse> setBudget(
        @AuthenticationPrincipal UserPrincipal principal,
        @Valid @RequestBody BudgetRequest request
    ) {
        BudgetResponse response = budgetService.setBudget(principal, request);
        return new ResponseEntity<>(response, HttpStatus.CREATED);
    }

    @GetMapping
    @Operation(summary = "Get all configured budgets for a specific month")
    public ResponseEntity<List<BudgetResponse>> getBudgets(
        @AuthenticationPrincipal UserPrincipal principal,
        @RequestParam(required = false) Integer year,
        @RequestParam(required = false) Integer month
    ) {
        LocalDate now = LocalDate.now();
        int targetYear = (year != null) ? year : now.getYear();
        int targetMonth = (month != null) ? month : now.getMonthValue();

        List<BudgetResponse> response = budgetService.getBudgets(principal, targetYear, targetMonth);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/progress")
    @Operation(summary = "Get budget progress (actual spent vs limit, warning thresholds) for a specific month")
    public ResponseEntity<List<BudgetProgressResponse>> getBudgetProgress(
        @AuthenticationPrincipal UserPrincipal principal,
        @RequestParam(required = false) Integer year,
        @RequestParam(required = false) Integer month
    ) {
        LocalDate now = LocalDate.now();
        int targetYear = (year != null) ? year : now.getYear();
        int targetMonth = (month != null) ? month : now.getMonthValue();

        List<BudgetProgressResponse> response = budgetService.getBudgetProgress(principal, targetYear, targetMonth);
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Delete a budget limit")
    public ResponseEntity<Void> deleteBudget(
        @AuthenticationPrincipal UserPrincipal principal,
        @PathVariable UUID id
    ) {
        budgetService.deleteBudget(principal, id);
        return ResponseEntity.noContent().build();
    }
}
