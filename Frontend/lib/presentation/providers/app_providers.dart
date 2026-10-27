import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/secure_storage_service.dart';
import '../../data/repositories/analytics_repository.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/budget_repository.dart';
import '../../data/repositories/savings_repository.dart';
import '../../data/repositories/transaction_repository.dart';

final storageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return ApiClient(storageService: storage);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    apiClient: ref.watch(apiClientProvider),
    storageService: ref.watch(storageServiceProvider),
  );
});

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository(apiClient: ref.watch(apiClientProvider));
});

final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  return AnalyticsRepository(apiClient: ref.watch(apiClientProvider));
});

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return BudgetRepository(apiClient: ref.watch(apiClientProvider));
});

final savingsRepositoryProvider = Provider<SavingsRepository>((ref) {
  return SavingsRepository(apiClient: ref.watch(apiClientProvider));
});
