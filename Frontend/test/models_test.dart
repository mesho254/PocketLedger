import 'package:flutter_test/flutter_test.dart';
import 'package:pocketledger/data/models/auth_model.dart';
import 'package:pocketledger/data/models/budget_model.dart';
import 'package:pocketledger/data/models/monthly_summary_model.dart';
import 'package:pocketledger/data/models/savings_goal_model.dart';
import 'package:pocketledger/data/models/transaction_model.dart';

void main() {
  group('PocketLedger Models Test Suite', () {
    test('TransactionModel should correctly serialize and deserialize', () {
      final json = {
        'id': 'tx-123',
        'amount': 45.50,
        'type': 'EXPENSE',
        'category': 'FOOD',
        'transactionDate': '2026-10-27',
        'description': 'Supermarket',
      };

      final model = TransactionModel.fromJson(json);
      expect(model.id, 'tx-123');
      expect(model.amount, 45.50);
      expect(model.isExpense, true);
      expect(model.isIncome, false);
      expect(model.category, 'FOOD');

      final serialized = model.toJson();
      expect(serialized['amount'], 45.50);
      expect(serialized['type'], 'EXPENSE');
      expect(serialized['category'], 'FOOD');
      expect(serialized['transactionDate'], '2026-10-27');
    });

    test('MonthlySummaryModel should correctly parse financial aggregates', () {
      final json = {
        'year': 2026,
        'month': 10,
        'totalIncome': 5000.0,
        'totalExpense': 2000.0,
        'netSavings': 3000.0,
        'savingsRatePercentage': 60.0,
        'categoryBreakdown': [
          {'category': 'HOUSING', 'amount': 1500.0, 'percentage': 75.0},
          {'category': 'FOOD', 'amount': 500.0, 'percentage': 25.0},
        ],
      };

      final summary = MonthlySummaryModel.fromJson(json);
      expect(summary.totalIncome, 5000.0);
      expect(summary.totalExpense, 2000.0);
      expect(summary.netSavings, 3000.0);
      expect(summary.savingsRatePercentage, 60.0);
      expect(summary.categoryBreakdown.length, 2);
      expect(summary.categoryBreakdown.first.category, 'HOUSING');
    });

    test('BudgetProgressModel should correctly flag status thresholds', () {
      final safeBudget = BudgetProgressModel.fromJson({
        'id': 'b-1',
        'category': 'FOOD',
        'monthlyLimit': 500.0,
        'actualSpent': 250.0,
        'remaining': 250.0,
        'percentageSpent': 50.0,
        'status': 'SAFE',
      });
      expect(safeBudget.isExceeded, false);
      expect(safeBudget.isWarning, false);

      final exceededBudget = BudgetProgressModel.fromJson({
        'id': 'b-2',
        'category': 'ENTERTAINMENT',
        'monthlyLimit': 100.0,
        'actualSpent': 150.0,
        'remaining': -50.0,
        'percentageSpent': 150.0,
        'status': 'EXCEEDED',
      });
      expect(exceededBudget.isExceeded, true);
    });

    test('SavingsGoalModel should parse completion progress', () {
      final goal = SavingsGoalModel.fromJson({
        'id': 'g-1',
        'title': 'Emergency Fund',
        'targetAmount': 10000.0,
        'currentAmount': 10000.0,
        'status': 'COMPLETED',
        'percentageCompleted': 100.0,
      });

      expect(goal.isCompleted, true);
      expect(goal.percentageCompleted, 100.0);
    });

    test('UserModel and AuthResponseModel should parse user claims', () {
      final json = {
        'token': 'jwt.sample.token',
        'tokenType': 'Bearer',
        'userId': 'usr-456',
        'email': 'alex@example.com',
        'fullName': 'Alex Doe',
        'currency': 'USD',
      };

      final authResponse = AuthResponseModel.fromJson(json);
      expect(authResponse.token, 'jwt.sample.token');
      expect(authResponse.user.email, 'alex@example.com');
      expect(authResponse.user.fullName, 'Alex Doe');
    });
  });
}
