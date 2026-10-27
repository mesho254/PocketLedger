import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/budget_model.dart';
import '../../data/repositories/budget_repository.dart';
import 'app_providers.dart';

class BudgetState {
  final List<BudgetProgressModel> budgets;
  final bool isLoading;
  final String? errorMessage;
  final int selectedYear;
  final int selectedMonth;

  const BudgetState({
    required this.budgets,
    required this.isLoading,
    this.errorMessage,
    required this.selectedYear,
    required this.selectedMonth,
  });

  factory BudgetState.initial() {
    final now = DateTime.now();
    return BudgetState(
      budgets: [],
      isLoading: false,
      selectedYear: now.year,
      selectedMonth: now.month,
    );
  }

  BudgetState copyWith({
    List<BudgetProgressModel>? budgets,
    bool? isLoading,
    String? errorMessage,
    int? selectedYear,
    int? selectedMonth,
  }) {
    return BudgetState(
      budgets: budgets ?? this.budgets,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      selectedYear: selectedYear ?? this.selectedYear,
      selectedMonth: selectedMonth ?? this.selectedMonth,
    );
  }
}

class BudgetNotifier extends StateNotifier<BudgetState> {
  final BudgetRepository _repository;

  BudgetNotifier(this._repository) : super(BudgetState.initial()) {
    loadBudgets();
  }

  Future<void> loadBudgets() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final list = await _repository.getBudgetProgress(
        year: state.selectedYear,
        month: state.selectedMonth,
      );
      state = state.copyWith(budgets: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<bool> setBudget({
    required String category,
    required double monthlyLimit,
  }) async {
    try {
      await _repository.setBudget(
        category: category,
        monthlyLimit: monthlyLimit,
        month: state.selectedMonth,
        year: state.selectedYear,
      );
      await loadBudgets();
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> deleteBudget(String id) async {
    try {
      await _repository.deleteBudget(id);
      state = state.copyWith(
        budgets: state.budgets.where((b) => b.id != id).toList(),
      );
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }
}

final budgetProvider = StateNotifierProvider<BudgetNotifier, BudgetState>((ref) {
  return BudgetNotifier(ref.watch(budgetRepositoryProvider));
});
