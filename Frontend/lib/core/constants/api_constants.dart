import 'package:flutter/foundation.dart';

class ApiConstants {
  // Use 10.0.2.2 for Android Emulator, localhost for iOS simulator/Web/Desktop
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8080/api/v1';
    }
    // Default emulator loopback or local LAN
    return defaultTargetPlatform == TargetPlatform.android
        ? 'http://10.0.2.2:8080/api/v1'
        : 'http://localhost:8080/api/v1';
  }

  // Auth endpoints
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String me = '/auth/me';

  // Transactions
  static const String transactions = '/transactions';

  // Analytics
  static const String monthlySummary = '/analytics/monthly-summary';

  // Budgets
  static const String budgets = '/budgets';
  static const String budgetProgress = '/budgets/progress';

  // Savings Goals
  static const String savingsGoals = '/savings-goals';
  static String savingsContributions(String goalId) => '/savings-goals/$goalId/contributions';
}
