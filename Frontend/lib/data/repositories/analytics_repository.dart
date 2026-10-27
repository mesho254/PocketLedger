import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/monthly_summary_model.dart';

class AnalyticsRepository {
  final ApiClient apiClient;

  AnalyticsRepository({required this.apiClient});

  Future<MonthlySummaryModel> getMonthlySummary({
    required int year,
    required int month,
  }) async {
    final response = await apiClient.get(
      ApiConstants.monthlySummary,
      queryParameters: {
        'year': year,
        'month': month,
      },
    );
    return MonthlySummaryModel.fromJson(response.data);
  }
}
