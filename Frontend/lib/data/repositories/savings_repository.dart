import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/savings_goal_model.dart';

class SavingsRepository {
  final ApiClient apiClient;

  SavingsRepository({required this.apiClient});

  Future<List<SavingsGoalModel>> getGoals() async {
    final response = await apiClient.get(ApiConstants.savingsGoals);
    final list = response.data as List? ?? [];
    return list.map((e) => SavingsGoalModel.fromJson(e)).toList();
  }

  Future<SavingsGoalModel> createGoal({
    required String title,
    required double targetAmount,
    DateTime? targetDate,
  }) async {
    final response = await apiClient.post(
      ApiConstants.savingsGoals,
      data: {
        'title': title,
        'targetAmount': targetAmount,
        if (targetDate != null)
          'targetDate':
              "${targetDate.year.toString().padLeft(4, '0')}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.day.toString().padLeft(2, '0')}",
      },
    );
    return SavingsGoalModel.fromJson(response.data);
  }

  Future<SavingsGoalModel> addContribution({
    required String goalId,
    required double amount,
    String? note,
    DateTime? contributionDate,
  }) async {
    final response = await apiClient.post(
      ApiConstants.savingsContributions(goalId),
      data: {
        'amount': amount,
        if (note != null) 'note': note,
        if (contributionDate != null)
          'contributionDate':
              "${contributionDate.year.toString().padLeft(4, '0')}-${contributionDate.month.toString().padLeft(2, '0')}-${contributionDate.day.toString().padLeft(2, '0')}",
      },
    );
    return SavingsGoalModel.fromJson(response.data);
  }

  Future<void> deleteGoal(String goalId) async {
    await apiClient.delete('${ApiConstants.savingsGoals}/$goalId');
  }
}
