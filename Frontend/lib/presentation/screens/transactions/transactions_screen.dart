import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/transaction_model.dart';
import '../../providers/theme_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/transaction_tile.dart';
import 'add_edit_transaction_sheet.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _dateGroupLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = today.difference(target).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return DateFormat('MMM dd, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final state = ref.watch(transactionProvider);
    final isMasked = ref.watch(balancePrivacyProvider);
    final query = ref.watch(transactionSearchQueryProvider).trim().toLowerCase();
    final currentTypeFilter = state.filter.type ?? 'ALL';

    final filtered = state.transactions.where((tx) {
      if (query.isEmpty) return true;
      final desc = (tx.description ?? '').toLowerCase();
      final cat = tx.category.toLowerCase();
      return desc.contains(query) || cat.contains(query);
    }).toList();

    // Group transactions by date header (inspired by Pinterest Pins #3 & #4)
    final Map<String, List<TransactionModel>> grouped = {};
    for (final tx in filtered) {
      final key = _dateGroupLabel(tx.transactionDate);
      grouped.putIfAbsent(key, () => []).add(tx);
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Search Bar & Segmented Pill Filter Row
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Column(
              children: [
                // Novbank-style Pill Search Input
                Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: p.cardSurface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: p.borderSubtle, width: 1),
                    boxShadow: p.cardShadow,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search_rounded, color: p.textSecondary, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) =>
                              ref.read(transactionSearchQueryProvider.notifier).state = val,
                          style: TextStyle(color: p.textPrimary, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Search transactions or categories...',
                            hintStyle: TextStyle(color: p.textMuted, fontSize: 13.5),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            filled: false,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      if (query.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            ref.read(transactionSearchQueryProvider.notifier).state = '';
                          },
                          child: Icon(Icons.close_rounded, color: p.textMuted, size: 18),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Segmented Pill Filter Tabs (All / Expenses / Income - Pinterest Pin #4)
                Row(
                  children: [
                    _buildFilterPill(
                      context,
                      ref,
                      label: 'All',
                      typeValue: 'ALL',
                      isSelected: currentTypeFilter == 'ALL',
                    ),
                    const SizedBox(width: 8),
                    _buildFilterPill(
                      context,
                      ref,
                      label: 'Income',
                      typeValue: 'INCOME',
                      isSelected: currentTypeFilter == 'INCOME',
                    ),
                    const SizedBox(width: 8),
                    _buildFilterPill(
                      context,
                      ref,
                      label: 'Expenses',
                      typeValue: 'EXPENSE',
                      isSelected: currentTypeFilter == 'EXPENSE',
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Date-Grouped Transaction Feed inside Bento Card
          Expanded(
            child: RefreshIndicator(
              color: p.primaryBrand,
              onRefresh: () => ref.read(transactionProvider.notifier).loadTransactions(),
              child: state.isLoading
                  ? Center(child: CircularProgressIndicator(color: p.primaryBrand))
                  : filtered.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
                          children: [
                            Container(
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                color: p.cardSurface,
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(color: p.borderSubtle),
                                boxShadow: p.cardShadow,
                              ),
                              child: Column(
                                children: [
                                  Icon(Icons.receipt_long_rounded, size: 52, color: p.textMuted),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No transactions found',
                                    style: TextStyle(
                                      color: p.textPrimary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Try adjusting your search filter or tap + below to record a transaction.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: p.textSecondary, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 110),
                          itemCount: grouped.keys.length,
                          itemBuilder: (context, groupIdx) {
                            final dateLabel = grouped.keys.elementAt(groupIdx);
                            final items = grouped[dateLabel]!;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: p.cardSurface,
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(color: p.borderSubtle, width: 1),
                                boxShadow: p.cardShadow,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 4, bottom: 8),
                                    child: Text(
                                      dateLabel,
                                      style: TextStyle(
                                        color: p.textSecondary,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: -0.1,
                                      ),
                                    ),
                                  ),
                                  ...items.map(
                                    (tx) => TransactionTile(
                                      transaction: tx,
                                      isMasked: isMasked,
                                      onTap: () {
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          backgroundColor: Colors.transparent,
                                          builder: (_) =>
                                              AddEditTransactionSheet(existingTransaction: tx),
                                        );
                                      },
                                      onDelete: () => ref
                                          .read(transactionProvider.notifier)
                                          .deleteTransaction(tx.id),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPill(
    BuildContext context,
    WidgetRef ref, {
    required String label,
    required String typeValue,
    required bool isSelected,
  }) {
    final p = context.palette;

    return GestureDetector(
      onTap: () {
        ref.read(transactionProvider.notifier).setFilter(type: typeValue);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? p.primaryBrand : p.cardSurface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected ? p.primaryBrand : p.borderSubtle,
            width: 1,
          ),
          boxShadow: isSelected ? [] : p.cardShadow,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : p.textSecondary,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
