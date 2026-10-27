import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/transaction_model.dart';
import '../../data/repositories/transaction_repository.dart';
import 'app_providers.dart';

class TransactionFilterState {
  final String? type; // ALL, INCOME, EXPENSE
  final String? category;
  final DateTime? startDate;
  final DateTime? endDate;

  const TransactionFilterState({
    this.type,
    this.category,
    this.startDate,
    this.endDate,
  });

  TransactionFilterState copyWith({
    String? type,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return TransactionFilterState(
      type: type ?? this.type,
      category: category ?? this.category,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}

class TransactionState {
  final List<TransactionModel> transactions;
  final bool isLoading;
  final String? errorMessage;
  final TransactionFilterState filter;

  const TransactionState({
    required this.transactions,
    required this.isLoading,
    this.errorMessage,
    required this.filter,
  });

  factory TransactionState.initial() => const TransactionState(
        transactions: [],
        isLoading: false,
        filter: TransactionFilterState(),
      );

  TransactionState copyWith({
    List<TransactionModel>? transactions,
    bool? isLoading,
    String? errorMessage,
    TransactionFilterState? filter,
  }) {
    return TransactionState(
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      filter: filter ?? this.filter,
    );
  }
}

class TransactionNotifier extends StateNotifier<TransactionState> {
  final TransactionRepository _repository;

  TransactionNotifier(this._repository) : super(TransactionState.initial()) {
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final list = await _repository.getTransactions(
        type: state.filter.type,
        category: state.filter.category,
        startDate: state.filter.startDate,
        endDate: state.filter.endDate,
      );
      state = state.copyWith(transactions: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void setFilter({
    String? type,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    state = state.copyWith(
      filter: state.filter.copyWith(
        type: type,
        category: category,
        startDate: startDate,
        endDate: endDate,
      ),
    );
    loadTransactions();
  }

  Future<bool> addTransaction(TransactionModel tx) async {
    try {
      final created = await _repository.createTransaction(tx);
      state = state.copyWith(
        transactions: [created, ...state.transactions],
      );
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> updateTransaction(String id, TransactionModel tx) async {
    try {
      final updated = await _repository.updateTransaction(id, tx);
      state = state.copyWith(
        transactions: state.transactions.map((t) => t.id == id ? updated : t).toList(),
      );
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> deleteTransaction(String id) async {
    try {
      await _repository.deleteTransaction(id);
      state = state.copyWith(
        transactions: state.transactions.where((t) => t.id != id).toList(),
      );
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }
}

final transactionProvider = StateNotifierProvider<TransactionNotifier, TransactionState>((ref) {
  return TransactionNotifier(ref.watch(transactionRepositoryProvider));
});
