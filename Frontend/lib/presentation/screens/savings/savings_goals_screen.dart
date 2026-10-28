import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../providers/savings_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/savings_goal_card.dart';
import '../../widgets/sparkline_chart.dart';
import 'add_goal_dialog.dart';
import 'contribute_dialog.dart';

class SavingsGoalsScreen extends ConsumerWidget {
  const SavingsGoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final state = ref.watch(savingsProvider);
    final isMasked = ref.watch(balancePrivacyProvider);
    final currency = ref.watch(currencyFormatterProvider);

    final totalSaved = state.goals.fold<double>(0.0, (sum, g) => sum + g.currentAmount);
    final totalTarget = state.goals.fold<double>(0.0, (sum, g) => sum + g.targetAmount);
    final overallPct = totalTarget > 0 ? ((totalSaved / totalTarget) * 100.0).clamp(0.0, 100.0) : 0.0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        color: p.primaryBrand,
        onRefresh: () => ref.read(savingsProvider.notifier).loadGoals(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ===============================================================
              // 1. HERO "FINANCIAL GOALS" BENTO SUMMARY (Novbank Left Screen)
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Financial goals',
                          style: TextStyle(
                            color: p.textPrimary,
                            fontSize: 21,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.4,
                          ),
                        ),
                        Row(
                          children: [
                            CircularArcGauge(
                              percentage: overallPct,
                              activeColor: p.warningAmber,
                              trackColor: p.progressTrack,
                              textColor: p.textPrimary,
                              size: 46,
                            ),
                            const SizedBox(width: 10),
                            InkWell(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => const AddGoalDialog(),
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
                      ],
                    ),
                    const SizedBox(height: 14),
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
                                  : (totalSaved >= 10000
                                      ? currency.formatCompact(totalSaved)
                                      : currency.format(totalSaved, decimalDigits: 0)),
                              style: TextStyle(
                                color: p.textPrimary,
                                fontSize: 36,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -1.0,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          overallPct >= 50 ? 'Almost\nthere' : 'Saved toward\nyour goals',
                          style: TextStyle(
                            color: p.textSecondary,
                            fontSize: 12.5,
                            height: 1.25,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              if (state.isLoading)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(color: p.primaryBrand),
                  ),
                )
              else if (state.goals.isEmpty)
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
                      Icon(Icons.savings_outlined, size: 48, color: p.primaryBrand),
                      const SizedBox(height: 12),
                      Text(
                        'No savings goals set',
                        style: TextStyle(
                          color: p.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Track milestones like Emergency Funds, Vacations, or Major Investments.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: p.textSecondary, fontSize: 13),
                      ),
                      const SizedBox(height: 18),
                      ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => const AddGoalDialog(),
                          );
                        },
                        child: const Text('Create Your First Goal'),
                      ),
                    ],
                  ),
                )
              else
                ...state.goals.map(
                  (goal) => SavingsGoalCard(
                    goal: goal,
                    onContribute: () {
                      showDialog(
                        context: context,
                        builder: (_) => ContributeDialog(goal: goal),
                      );
                    },
                    onDelete: () => ref.read(savingsProvider.notifier).deleteGoal(goal.id),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
