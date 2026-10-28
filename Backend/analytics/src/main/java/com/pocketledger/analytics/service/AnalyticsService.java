package com.pocketledger.analytics.service;

import com.pocketledger.analytics.dto.MonthlySummaryResponse;
import com.pocketledger.auth.security.UserPrincipal;

public interface AnalyticsService {

  MonthlySummaryResponse getMonthlySummary(UserPrincipal principal, int year, int month);
}
