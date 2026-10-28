package com.pocketledger.analytics.validation;

import com.pocketledger.analytics.exception.AnalyticsValidationException;
import org.springframework.stereotype.Component;

@Component
public class AnalyticsValidator {

  public void validateYearAndMonth(int year, int month) {
    if (month < 1 || month > 12) {
      throw new AnalyticsValidationException("month must be between 1 and 12");
    }
    if (year < 2000 || year > 2100) {
      throw new AnalyticsValidationException("year must be between 2000 and 2100");
    }
  }
}
