import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../providers/analytics_provider.dart';
import '../../providers/savings_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/cashflow_spline_chart.dart';
import '../../widgets/sparkline_chart.dart';
import '../../widgets/transaction_tile.dart';
import '../transactions/add_edit_transaction_sheet.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  List<Color> _chartColors(AppPalette p) => [
        p.primaryBrand,
        p.secondaryTeal,
        p.incomeGreen,
        p.warningAmber,
        p.expenseRose,
        const Color(0xFF6366F1),
        const Color(0xFF8B5CF6),
      ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final analytics = ref.watch(analyticsProvider);
    final transactions = ref.watch(transactionProvider);
    final savingsState = ref.watch(savingsProvider);
    final isMasked = ref.watch(balancePrivacyProvider);
    final currency = ref.watch(currencyFormatterProvider);

    final summary = analytics.summary;

    final monthName = DateFormat('MMM yyyy').format(
      DateTime(analytics.selectedYear, analytics.selectedMonth),
    );

    final netBalance = summary?.netSavings ?? 0.0;
    final totalIncome = summary?.totalIncome ?? 0.0;
    final totalExpense = summary?.totalExpense ?? 0.0;
    final savingsRate = summary?.savingsRatePercentage ?? 0.0;

    // Build dynamic or fallback spline data points for the hero cashflow curve
    final txAmounts = transactions.transactions.take(6).map((e) => e.amount).toList().reversed.toList();
    final splineValues = txAmounts.length >= 4
        ? txAmounts
        : <double>[
            (totalIncome * 0.45).clamp(400.0, double.infinity),
            (totalIncome * 0.68).clamp(850.0, double.infinity),
            (totalIncome * 0.52).clamp(620.0, double.infinity),
            (totalIncome * 0.85).clamp(1100.0, double.infinity),
            (netBalance.abs() > 0 ? netBalance.abs() : 2450.0),
            (totalIncome > 0 ? totalIncome : 3200.0),
          ];

    // Calculate aggregate savings goals progress for the Novbank "Financial goals" Bento card
    final goals = savingsState.goals;
    final totalGoalSaved = goals.fold<double>(0.0, (sum, g) => sum + g.currentAmount);
    final totalGoalTarget = goals.fold<double>(0.0, (sum, g) => sum + g.targetAmount);
    final overallGoalPct = totalGoalTarget > 0
        ? ((totalGoalSaved / totalGoalTarget) * 100.0).clamp(0.0, 100.0)
        : 0.0;

    // Split balance into whole and cents for Novbank's crisp superscript currency display
    final formattedBalance = currency.formatNumberOnly(netBalance);

    return RefreshIndicator(
      color: p.primaryBrand,
      onRefresh: () async {
        ref.read(analyticsProvider.notifier).loadSummary();
        ref.read(transactionProvider.notifier).loadTransactions();
        ref.read(savingsProvider.notifier).loadGoals();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // =================================================================
            // 1. CENTERED HERO TOTAL BALANCE SECTION (Novbank Center Screen)
            // =================================================================
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Total balance',
                      style: TextStyle(
                        color: p.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () => ref.read(balancePrivacyProvider.notifier).state = !isMasked,
                      child: Icon(
                        isMasked ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        size: 17,
                        color: p.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 6, right: 4),
                        child: Text(
                          currency.symbol,
                          style: TextStyle(
                            color: p.textSecondary,
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        isMasked ? '••••••' : formattedBalance,
                        style: TextStyle(
                          color: p.textPrimary,
                          fontSize: 42,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -1.2,
                          height: 1.05,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Soft Teal Growth / Month Switcher Pill Badge ("+24% from the last 6 months")
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(
                    color: p.badgeBg,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () => ref.read(analyticsProvider.notifier).previousMonth(),
                        borderRadius: BorderRadius.circular(14),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Icon(Icons.chevron_left_rounded, size: 18, color: p.badgeText),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          '${savingsRate >= 0 ? '+' : ''}${savingsRate.toStringAsFixed(1)}% savings rate • $monthName',
                          style: TextStyle(
                            color: p.badgeText,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => ref.read(analyticsProvider.notifier).nextMonth(),
                        borderRadius: BorderRadius.circular(14),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Icon(Icons.chevron_right_rounded, size: 18, color: p.badgeText),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),

            // =================================================================
            // 2. SEARCH + FILTER + SPARKLE ACTION BAR (Novbank Center Screen)
            // =================================================================
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => ref.read(selectedNavTabProvider.notifier).state = 1,
                    child: Container(
                      height: 46,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: p.cardSurface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: p.borderSubtle, width: 1),
                        boxShadow: p.cardShadow,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Search transactions...',
                              style: TextStyle(
                                color: p.textMuted,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          Icon(Icons.search_rounded, color: p.textSecondary, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => ref.read(selectedNavTabProvider.notifier).state = 1,
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: p.cardSurface,
                      shape: BoxShape.circle,
                      border: Border.all(color: p.borderSubtle, width: 1),
                      boxShadow: p.cardShadow,
                    ),
                    child: Icon(Icons.tune_rounded, color: p.textPrimary, size: 20),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => const AddEditTransactionSheet(),
                    );
                  },
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: p.isDark ? p.primaryBrand : const Color(0xFF111827),
                      shape: BoxShape.circle,
                      boxShadow: p.cardShadow,
                    ),
                    child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 19),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // =================================================================
            // 3. INTERACTIVE CASHFLOW SPLINE AREA CHART (Novbank Center Screen)
            // =================================================================
            Container(
              padding: const EdgeInsets.only(top: 24, left: 12, right: 12, bottom: 12),
              decoration: BoxDecoration(
                color: p.cardSurface,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: p.borderSubtle, width: 1),
                boxShadow: p.cardShadow,
              ),
              child: CashflowSplineChart(
                values: splineValues,
                labels: const ['Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov'],
                subtitleDate: monthName,
                isMasked: isMasked,
              ),
            ),
            const SizedBox(height: 20),

            // =================================================================
            // 4. "OVERVIEW" BENTO CARD WITH INLINE SPARKLINES (Novbank Left Screen)
            // =================================================================
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: p.cardSurface,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: p.borderSubtle, width: 1),
                boxShadow: p.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Overview',
                        style: TextStyle(
                          color: p.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.4,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => ref.read(selectedNavTabProvider.notifier).state = 1,
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: p.borderSubtle, width: 1),
                          ),
                          child: Icon(
                            Icons.north_east_rounded,
                            size: 17,
                            color: p.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Row 1: Checking / Net Balance (Teal #0D8A9E + Upward Sparkline)
                  _OverviewSparklineRow(
                    label: 'Net Balance',
                    amount: isMasked ? currency.masked() : currency.format(netBalance),
                    icon: Icons.account_balance_wallet_outlined,
                    badgeColor: p.secondaryTeal,
                    sparklinePoints: const [12, 19, 18, 25, 24, 30],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Divider(height: 1, color: p.borderSubtle),
                  ),

                  // Row 2: Savings / Total Income (Vibrant Green #00C46A + Upward Sparkline)
                  _OverviewSparklineRow(
                    label: 'Total Income',
                    amount: isMasked ? currency.masked() : currency.format(totalIncome),
                    icon: Icons.savings_outlined,
                    badgeColor: p.incomeGreen,
                    sparklinePoints: const [10, 14, 13, 21, 26, 34],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Divider(height: 1, color: p.borderSubtle),
                  ),

                  // Row 3: Credit / Total Expenses (Warm Amber #F58A07 + Downward Sparkline)
                  _OverviewSparklineRow(
                    label: 'Total Expenses',
                    amount: isMasked ? currency.masked() : currency.format(totalExpense),
                    icon: Icons.credit_card_rounded,
                    badgeColor: p.warningAmber,
                    sparklinePoints: const [32, 26, 29, 19, 14, 11],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // =================================================================
            // 5. "FINANCIAL GOALS" BENTO CARD + ARC GAUGE (Novbank Left Screen)
            // =================================================================
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: p.cardSurface,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: p.borderSubtle, width: 1),
                boxShadow: p.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Financial goals',
                        style: TextStyle(
                          color: p.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.4,
                        ),
                      ),
                      CircularArcGauge(
                        percentage: overallGoalPct,
                        activeColor: p.warningAmber,
                        trackColor: p.progressTrack,
                        textColor: p.textPrimary,
                        size: 48,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            isMasked
                                ? currency.masked('••••')
                                : (totalGoalSaved >= 1000
                                    ? currency.formatCompact(totalGoalSaved)
                                    : currency.format(totalGoalSaved)),
                            style: TextStyle(
                              color: p.textPrimary,
                              fontSize: 34,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -1.0,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        overallGoalPct >= 50 ? 'Almost\nthere' : 'Building\nmomentum',
                        style: TextStyle(
                          color: p.textSecondary,
                          fontSize: 12.5,
                          height: 1.25,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  if (goals.isEmpty)
                    InkWell(
                      onTap: () => ref.read(selectedNavTabProvider.notifier).state = 3,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: p.nestedSurface,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.flag_outlined, color: p.primaryBrand, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Tap to create your first savings goal milestone',
                                style: TextStyle(color: p.textSecondary, fontSize: 13),
                              ),
                            ),
                            Icon(Icons.chevron_right_rounded, color: p.textMuted),
                          ],
                        ),
                      ),
                    )
                  else
                    ...goals.take(3).map((goal) {
                      final pct = goal.percentageCompleted.clamp(0.0, 100.0);
                      final daysLeft = goal.targetDate != null
                          ? '${goal.targetDate!.difference(DateTime.now()).inDays.clamp(0, 9999)} days left'
                          : 'Active goal';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  goal.title,
                                  style: TextStyle(
                                    color: p.textPrimary,
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '${pct.toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    color: p.textPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  isMasked
                                      ? '${currency.masked('••••')} of ${currency.masked('••••')}'
                                      : '${currency.format(goal.currentAmount)} of ${currency.format(goal.targetAmount)}',
                                  style: TextStyle(color: p.textSecondary, fontSize: 12),
                                ),
                                Text(
                                  daysLeft,
                                  style: TextStyle(color: p.textMuted, fontSize: 11.5),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: LinearProgressIndicator(
                                value: pct / 100.0,
                                minHeight: 5.5,
                                backgroundColor: p.progressTrack,
                                valueColor: AlwaysStoppedAnimation<Color>(p.primaryBrand),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // =================================================================
            // 6. DONUT EXPENSE BREAKDOWN WITH CENTER LABEL (Pinterest Pin #3 & #4)
            // =================================================================
            if (summary != null && summary.categoryBreakdown.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: p.cardSurface,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: p.borderSubtle, width: 1),
                  boxShadow: p.cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Spending Breakdown',
                      style: TextStyle(
                        color: p.textPrimary,
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      height: 190,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          PieChart(
                            PieChartData(
                              sectionsSpace: 3,
                              centerSpaceRadius: 56,
                              sections: summary.categoryBreakdown.asMap().entries.map((entry) {
                                final idx = entry.key;
                                final item = entry.value;
                                final colors = _chartColors(p);
                                final color = colors[idx % colors.length];
                                return PieChartSectionData(
                                  color: color,
                                  value: item.amount,
                                  title: '${item.percentage.toStringAsFixed(0)}%',
                                  radius: 32,
                                  titleStyle: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                isMasked
                                    ? currency.masked('••••')
                                    : currency.formatCompact(totalExpense),
                                style: TextStyle(
                                  color: p.textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'Total Spent',
                                style: TextStyle(
                                  color: p.textSecondary,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 14,
                      runSpacing: 8,
                      children: summary.categoryBreakdown.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final item = entry.value;
                        final colors = _chartColors(p);
                        final color = colors[idx % colors.length];
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
                              '${item.category} (${item.percentage.toStringAsFixed(0)}%)',
                              style: TextStyle(
                                color: p.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // =================================================================
            // 7. RECENT TRANSACTIONS BENTO CARD (Novbank Right Screen Style)
            // =================================================================
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: p.cardSurface,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: p.borderSubtle, width: 1),
                boxShadow: p.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Activity',
                        style: TextStyle(
                          color: p.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.4,
                        ),
                      ),
                      InkWell(
                        onTap: () => ref.read(selectedNavTabProvider.notifier).state = 1,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: p.borderSubtle, width: 1),
                          ),
                          child: Text(
                            'See All',
                            style: TextStyle(
                              color: p.textPrimary,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (transactions.isLoading)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(28.0),
                        child: CircularProgressIndicator(color: p.primaryBrand),
                      ),
                    )
                  else if (transactions.transactions.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Column(
                        children: [
                          Icon(Icons.receipt_long_outlined, size: 42, color: p.textMuted),
                          const SizedBox(height: 10),
                          Text(
                            'No transactions recorded yet',
                            style: TextStyle(
                              color: p.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tap the + button in the bottom dock to log your first entry.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: p.textSecondary, fontSize: 12.5),
                          ),
                        ],
                      ),
                    )
                  else
                    ...transactions.transactions.take(5).map(
                          (tx) => TransactionTile(
                            transaction: tx,
                            isMasked: isMasked,
                            onDelete: () =>
                                ref.read(transactionProvider.notifier).deleteTransaction(tx.id),
                          ),
                        ),
                ],
              ),
            ),

            const SizedBox(height: 105), // clearance for floating glass dock
          ],
        ),
      ),
    );
  }
}

class _OverviewSparklineRow extends StatelessWidget {
  final String label;
  final String amount;
  final IconData icon;
  final Color badgeColor;
  final List<double> sparklinePoints;

  const _OverviewSparklineRow({
    required this.label,
    required this.amount,
    required this.icon,
    required this.badgeColor,
    required this.sparklinePoints,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: badgeColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: p.textSecondary,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                amount,
                style: TextStyle(
                  color: p.textPrimary,
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                ),
              ),
            ],
          ),
        ),
        SparklineChart(
          points: sparklinePoints,
          color: badgeColor,
          width: 76,
          height: 30,
        ),
      ],
    );
  }
}
