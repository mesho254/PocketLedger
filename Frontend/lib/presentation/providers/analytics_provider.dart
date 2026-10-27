import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/monthly_summary_model.dart';
import '../../data/repositories/analytics_repository.dart';
import 'app_providers.dart';

class AnalyticsState {
  final MonthlySummaryModel? summary;
  final bool isLoading;
  final int selectedYear;
  final int selectedMonth;
  final String? errorMessage;

  const AnalyticsState({
    this.summary,
    required this.isLoading,
    required this.selectedYear,
    required this.selectedMonth,
    this.errorMessage,
  });

  factory AnalyticsState.initial() {
    final now = DateTime.now();
    return AnalyticsState(
      isLoading: false,
      selectedYear: now.year,
      selectedMonth: now.month,
    );
  }

  AnalyticsState copyWith({
    MonthlySummaryModel? summary,
    bool? isLoading,
    int? selectedYear,
    int? selectedMonth,
    String? errorMessage,
  }) {
    return AnalyticsState(
      summary: summary ?? this.summary,
      isLoading: isLoading ?? this.isLoading,
      selectedYear: selectedYear ?? this.selectedYear,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      errorMessage: errorMessage,
    );
  }
}

class AnalyticsNotifier extends StateNotifier<AnalyticsState> {
  final AnalyticsRepository _repository;

  AnalyticsNotifier(this._repository) : super(AnalyticsState.initial()) {
    loadSummary();
  }

  Future<void> loadSummary() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final summary = await _repository.getMonthlySummary(
        year: state.selectedYear,
        month: state.selectedMonth,
      );
      state = state.copyWith(summary: summary, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void previousMonth() {
    int year = state.selectedYear;
    int month = state.selectedMonth - 1;
    if (month < 1) {
      month = 12;
      year--;
    }
    state = state.copyWith(selectedYear: year, selectedMonth: month);
    loadSummary();
  }

  void nextMonth() {
    int year = state.selectedYear;
    int month = state.selectedMonth + 1;
    if (month > 12) {
      month = 1;
      year++;
    }
    state = state.copyWith(selectedYear: year, selectedMonth: month);
    loadSummary();
  }
}

final analyticsProvider = StateNotifierProvider<AnalyticsNotifier, AnalyticsState>((ref) {
  return AnalyticsNotifier(ref.watch(analyticsRepositoryProvider));
});
