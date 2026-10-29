class ApiConstants {
  // Production Render Backend URL
  static const String productionBaseUrl = 'https://pocketledger-backend.onrender.com/api/v1';

  // Optional compile-time override: flutter run --dart-define=API_BASE_URL=...
  static const String _envBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');

  static String get baseUrl {
    if (_envBaseUrl.isNotEmpty) {
      return _envBaseUrl;
    }
    return productionBaseUrl;
  }

  // Health check endpoint (wakes up Render Free Tier instance)
  static const String health = '/health';

  // Auth endpoints
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String me = '/auth/me';
  static const String changePassword = '/auth/change-password';

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
