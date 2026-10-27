import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/transaction_model.dart';

class TransactionRepository {
  final ApiClient apiClient;

  TransactionRepository({required this.apiClient});

  Future<List<TransactionModel>> getTransactions({
    DateTime? startDate,
    DateTime? endDate,
    String? type,
    String? category,
    int page = 0,
    int size = 30,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'size': size,
    };

    if (startDate != null) {
      query['startDate'] =
          "${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}";
    }
    if (endDate != null) {
      query['endDate'] =
          "${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}";
    }
    if (type != null && type.isNotEmpty && type != 'ALL') {
      query['type'] = type;
    }
    if (category != null && category.isNotEmpty && category != 'ALL') {
      query['category'] = category;
    }

    final response = await apiClient.get(
      ApiConstants.transactions,
      queryParameters: query,
    );

    final content = response.data['content'] as List? ?? [];
    return content.map((e) => TransactionModel.fromJson(e)).toList();
  }

  Future<TransactionModel> createTransaction(TransactionModel tx) async {
    final response = await apiClient.post(
      ApiConstants.transactions,
      data: tx.toJson(),
    );
    return TransactionModel.fromJson(response.data);
  }

  Future<TransactionModel> updateTransaction(String id, TransactionModel tx) async {
    final response = await apiClient.put(
      '${ApiConstants.transactions}/$id',
      data: tx.toJson(),
    );
    return TransactionModel.fromJson(response.data);
  }

  Future<void> deleteTransaction(String id) async {
    await apiClient.delete('${ApiConstants.transactions}/$id');
  }
}
