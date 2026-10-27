import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/savings_goal_model.dart';
import '../../data/repositories/savings_repository.dart';
import 'app_providers.dart';

class SavingsState {
  final List<SavingsGoalModel> goals;
  final bool isLoading;
  final String? errorMessage;

  const SavingsState({
    required this.goals,
    required this.isLoading,
    this.errorMessage,
  });

  factory SavingsState.initial() => const SavingsState(
        goals: [],
        isLoading: false,
      );

  SavingsState copyWith({
    List<SavingsGoalModel>? goals,
    bool? isLoading,
    String? errorMessage,
  }) {
    return SavingsState(
      goals: goals ?? this.goals,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class SavingsNotifier extends StateNotifier<SavingsState> {
  final SavingsRepository _repository;

  SavingsNotifier(this._repository) : super(SavingsState.initial()) {
    loadGoals();
  }

  Future<void> loadGoals() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final list = await _repository.getGoals();
      state = state.copyWith(goals: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<bool> createGoal({
    required String title,
    required double targetAmount,
    DateTime? targetDate,
  }) async {
    try {
      final goal = await _repository.createGoal(
        title: title,
        targetAmount: targetAmount,
        targetDate: targetDate,
      );
      state = state.copyWith(goals: [goal, ...state.goals]);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> addContribution({
    required String goalId,
    required double amount,
    String? note,
  }) async {
    try {
      final updated = await _repository.addContribution(
        goalId: goalId,
        amount: amount,
        note: note,
      );
      state = state.copyWith(
        goals: state.goals.map((g) => g.id == goalId ? updated : g).toList(),
      );
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> deleteGoal(String goalId) async {
    try {
      await _repository.deleteGoal(goalId);
      state = state.copyWith(
        goals: state.goals.where((g) => g.id != goalId).toList(),
      );
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }
}

final savingsProvider = StateNotifierProvider<SavingsNotifier, SavingsState>((ref) {
  return SavingsNotifier(ref.watch(savingsRepositoryProvider));
});
