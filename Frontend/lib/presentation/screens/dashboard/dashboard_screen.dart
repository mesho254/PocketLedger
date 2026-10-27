import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/analytics_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/transaction_tile.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  List<Color> get _chartColors => [
        AppColors.accentRose,
        AppColors.accentCyan,
        AppColors.accentAmber,
        AppColors.accentIndigo,
        AppColors.primary,
        Colors.purpleAccent,
        Colors.tealAccent,
      ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analytics = ref.watch(analyticsProvider);
    final transactions = ref.watch(transactionProvider);

    final summary = analytics.summary;
    final currencyFmt = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    final monthName = DateFormat('MMMM yyyy').format(
      DateTime(analytics.selectedYear, analytics.selectedMonth),
    );

    return RefreshIndicator(
      onRefresh: () async {
        ref.read(analyticsProvider.notifier).loadSummary();
        ref.read(transactionProvider.notifier).loadTransactions();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Month Selector Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceCardDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderDark),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left_rounded, color: AppColors.textPrimaryDark),
                    onPressed: () => ref.read(analyticsProvider.notifier).previousMonth(),
                  ),
                  Text(
                    monthName,
                    style: const TextStyle(
                      color: AppColors.textPrimaryDark,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right_rounded, color: AppColors.textPrimaryDark),
                    onPressed: () => ref.read(analyticsProvider.notifier).nextMonth(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Hero Net Savings / Balance Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF065F46), Color(0xFF047857)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Net Monthly Savings',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (summary != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Savings Rate: ${summary.savingsRatePercentage.toStringAsFixed(1)}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    summary != null ? currencyFmt.format(summary.netSavings) : '\$0.00',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Income & Expense Stat Cards
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Total Income',
                    amount: summary != null ? currencyFmt.format(summary.totalIncome) : '\$0.00',
                    icon: Icons.arrow_downward_rounded,
                    iconColor: AppColors.income,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    title: 'Total Expenses',
                    amount: summary != null ? currencyFmt.format(summary.totalExpense) : '\$0.00',
                    icon: Icons.arrow_upward_rounded,
                    iconColor: AppColors.expense,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Spending by Category Chart
            if (summary != null && summary.categoryBreakdown.isNotEmpty) ...[
              const Text(
                'Expense Breakdown',
                style: TextStyle(
                  color: AppColors.textPrimaryDark,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCardDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderDark),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: 180,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 3,
                          centerSpaceRadius: 45,
                          sections: summary.categoryBreakdown.asMap().entries.map((entry) {
                            final idx = entry.key;
                            final item = entry.value;
                            final color = _chartColors[idx % _chartColors.length];
                            return PieChartSectionData(
                              color: color,
                              value: item.amount,
                              title: '${item.percentage.toStringAsFixed(0)}%',
                              radius: 35,
                              titleStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Legend
                    Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      children: summary.categoryBreakdown.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final item = entry.value;
                        final color = _chartColors[idx % _chartColors.length];
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${item.category} (${currencyFmt.format(item.amount)})',
                              style: const TextStyle(
                                color: AppColors.textSecondaryDark,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Recent Transactions Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Transactions',
                  style: TextStyle(
                    color: AppColors.textPrimaryDark,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${transactions.transactions.length} items',
                  style: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (transactions.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              )
            else if (transactions.transactions.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCardDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderDark),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.receipt_long_outlined, size: 48, color: AppColors.textSecondaryDark),
                    SizedBox(height: 12),
                    Text(
                      'No transactions yet',
                      style: TextStyle(color: AppColors.textPrimaryDark, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Tap the + button below to log your first income or expense.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 13),
                    ),
                  ],
                ),
              )
            else
              ...transactions.transactions.take(5).map(
                    (tx) => TransactionTile(
                      transaction: tx,
                      onDelete: () => ref.read(transactionProvider.notifier).deleteTransaction(tx.id),
                    ),
                  ),
            const SizedBox(height: 80), // spacing for bottom bar
          ],
        ),
      ),
    );
  }
}
