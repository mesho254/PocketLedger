package com.pocketledger.controller;

import com.pocketledger.dto.MonthlySummaryResponse;
import com.pocketledger.security.UserPrincipal;
import com.pocketledger.service.AnalyticsService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDate;

@RestController
@RequestMapping("/api/v1/analytics")
@RequiredArgsConstructor
@Tag(name = "Analytics", description = "Endpoints for financial summaries, trends, and category breakdowns")
public class AnalyticsController {

    private final AnalyticsService analyticsService;

    @GetMapping("/monthly-summary")
    @Operation(summary = "Get monthly financial summary (income, expense, net savings, category breakdown)")
    public ResponseEntity<MonthlySummaryResponse> getMonthlySummary(
        @AuthenticationPrincipal UserPrincipal principal,
        @RequestParam(required = false) Integer year,
        @RequestParam(required = false) Integer month
    ) {
        LocalDate now = LocalDate.now();
        int targetYear = (year != null) ? year : now.getYear();
        int targetMonth = (month != null) ? month : now.getMonthValue();

        MonthlySummaryResponse response = analyticsService.getMonthlySummary(principal, targetYear, targetMonth);
        return ResponseEntity.ok(response);
    }
}
