import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/budget_model.dart';

class BudgetRepository {
  final ApiClient apiClient;

  BudgetRepository({required this.apiClient});

  Future<List<BudgetProgressModel>> getBudgetProgress({
    required int year,
    required int month,
  }) async {
    final response = await apiClient.get(
      ApiConstants.budgetProgress,
      queryParameters: {
        'year': year,
        'month': month,
      },
    );
    final list = response.data as List? ?? [];
    return list.map((e) => BudgetProgressModel.fromJson(e)).toList();
  }

  Future<void> setBudget({
    required String category,
    required double monthlyLimit,
    required int month,
    required int year,
  }) async {
    await apiClient.post(
      ApiConstants.budgets,
      data: {
        'category': category,
        'monthlyLimit': monthlyLimit,
        'month': month,
        'year': year,
      },
    );
  }

  Future<void> deleteBudget(String id) async {
    await apiClient.delete('${ApiConstants.budgets}/$id');
  }
}
