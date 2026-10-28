import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../providers/budget_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/budget_progress_card.dart';
import '../../widgets/sparkline_chart.dart';
import 'set_budget_dialog.dart';

class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final state = ref.watch(budgetProvider);
    final isMasked = ref.watch(balancePrivacyProvider);
    final currency = ref.watch(currencyFormatterProvider);

    final totalLimit = state.budgets.fold<double>(0.0, (sum, b) => sum + b.monthlyLimit);
    final totalSpent = state.budgets.fold<double>(0.0, (sum, b) => sum + b.actualSpent);
    final overallPct = totalLimit > 0 ? ((totalSpent / totalLimit) * 100.0).clamp(0.0, 100.0) : 0.0;
    final exceededCount = state.budgets.where((b) => b.isExceeded).length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        color: p.primaryBrand,
        onRefresh: () => ref.read(budgetProvider.notifier).loadBudgets(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ===============================================================
              // 1. "MONTHLY BUDGETS" BENTO CARD (Modeled on Novbank "Upcoming")
              // ===============================================================
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
                    // Header with "New +" bordered pill button (Novbank Right Screen)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Monthly Budgets',
                          style: TextStyle(
                            color: p.textPrimary,
                            fontSize: 21,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.4,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (_) => const SetBudgetDialog(),
                            );
                          },
                          borderRadius: BorderRadius.circular(24),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: p.borderSubtle, width: 1.2),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'New',
                                  style: TextStyle(
                                    color: p.textPrimary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(Icons.add_rounded, size: 17, color: p.textPrimary),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Big Bold Summary Metric ("$12K In scheduled budgets") + Circular Arc Gauge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Flexible(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    isMasked
                                        ? currency.masked('••••')
                                        : (totalLimit >= 10000
                                            ? currency.formatCompact(totalLimit)
                                            : currency.format(totalLimit, decimalDigits: 0)),
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
                                'In monthly\nbudget limits',
                                style: TextStyle(
                                  color: p.textSecondary,
                                  fontSize: 12.5,
                                  height: 1.25,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        CircularArcGauge(
                          percentage: overallPct,
                          activeColor: overallPct >= 100
                              ? p.expenseRose
                              : (overallPct >= 80 ? p.warningAmber : p.primaryBrand),
                          trackColor: p.progressTrack,
                          textColor: p.textPrimary,
                          size: 48,
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    if (state.isLoading)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: CircularProgressIndicator(color: p.primaryBrand),
                        ),
                      )
                    else if (state.budgets.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Column(
                          children: [
                            Icon(Icons.pie_chart_outline_rounded, size: 46, color: p.textMuted),
                            const SizedBox(height: 12),
                            Text(
                              'No category budgets configured',
                              style: TextStyle(
                                color: p.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Set monthly spending limits for categories like Food, Housing, or Shopping.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: p.textSecondary, fontSize: 13),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => const SetBudgetDialog(),
                                );
                              },
                              child: const Text('Add Category Budget'),
                            ),
                          ],
                        ),
                      )
                    else
                      ...state.budgets.map(
                        (budget) => BudgetProgressCard(
                          budget: budget,
                          onDelete: () =>
                              ref.read(budgetProvider.notifier).deleteBudget(budget.id),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ===============================================================
              // 2. SMART FINANCIAL HEALTH / MONEY TIP CARD (Pinterest Pin #4)
              // ===============================================================
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: p.cardSurface,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: p.borderSubtle, width: 1),
                  boxShadow: p.cardShadow,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: p.badgeBg,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        exceededCount > 0
                            ? Icons.warning_amber_rounded
                            : Icons.lightbulb_outline_rounded,
                        color: exceededCount > 0 ? p.warningAmber : p.badgeText,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exceededCount > 0 ? 'Budget Alert' : 'Smart Budget Insight',
                            style: TextStyle(
                              color: p.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            state.budgets.isEmpty
                                ? 'Create category limits to track spending velocity and receive 80% threshold warnings.'
                                : (exceededCount > 0
                                    ? '$exceededCount category budget(s) exceeded this month. Review your recent expenses to stay on target.'
                                    : 'You are doing great! ${overallPct.toStringAsFixed(0)}% of your total monthly budget has been used so far.'),
                            style: TextStyle(
                              color: p.textSecondary,
                              fontSize: 12.5,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
