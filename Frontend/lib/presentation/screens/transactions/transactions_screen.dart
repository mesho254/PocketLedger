import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/transaction_tile.dart';
import 'add_edit_transaction_sheet.dart';

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(transactionProvider);
    final currentTypeFilter = state.filter.type ?? 'ALL';

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Column(
        children: [
          // Filter Chips Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            color: AppColors.surfaceDark.withOpacity(0.5),
            child: Row(
              children: [
                _buildFilterChip(
                  context,
                  ref,
                  label: 'All',
                  typeValue: 'ALL',
                  isSelected: currentTypeFilter == 'ALL',
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  context,
                  ref,
                  label: 'Expenses',
                  typeValue: 'EXPENSE',
                  isSelected: currentTypeFilter == 'EXPENSE',
                  color: AppColors.expense,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  context,
                  ref,
                  label: 'Income',
                  typeValue: 'INCOME',
                  isSelected: currentTypeFilter == 'INCOME',
                  color: AppColors.income,
                ),
              ],
            ),
          ),

          // Transaction List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.read(transactionProvider.notifier).loadTransactions(),
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : state.transactions.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.receipt_long_rounded, size: 56, color: AppColors.textSecondaryDark),
                              SizedBox(height: 12),
                              Text(
                                'No transactions found',
                                style: TextStyle(
                                  color: AppColors.textPrimaryDark,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Try changing filters or add a new transaction.',
                                style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 13),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          itemCount: state.transactions.length,
                          itemBuilder: (context, index) {
                            final tx = state.transactions[index];
                            return TransactionTile(
                              transaction: tx,
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (_) => AddEditTransactionSheet(existingTransaction: tx),
                                );
                              },
                              onDelete: () => ref.read(transactionProvider.notifier).deleteTransaction(tx.id),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    WidgetRef ref, {
    required String label,
    required String typeValue,
    required bool isSelected,
    Color? color,
  }) {
    final activeColor = color ?? AppColors.primary;

    return GestureDetector(
      onTap: () {
        ref.read(transactionProvider.notifier).setFilter(type: typeValue);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withOpacity(0.2) : AppColors.surfaceCardDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? activeColor : AppColors.borderDark,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? activeColor : AppColors.textSecondaryDark,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
