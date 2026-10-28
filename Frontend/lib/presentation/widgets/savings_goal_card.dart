import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/models/savings_goal_model.dart';
import '../providers/theme_provider.dart';

class SavingsGoalCard extends StatelessWidget {
  final SavingsGoalModel goal;
  final VoidCallback onContribute;
  final VoidCallback? onDelete;

  const SavingsGoalCard({
    super.key,
    required this.goal,
    required this.onContribute,
    this.onDelete,
  });

  String _daysLeftLabel() {
    if (goal.isCompleted) return 'Goal achieved 🎉';
    if (goal.targetDate == null) return 'Flexible timeline';
    final diff = goal.targetDate!.difference(DateTime.now()).inDays;
    if (diff < 0) return 'Target date passed';
    if (diff == 0) return 'Due today';
    return '$diff days left';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final p = context.palette;
        final currency = ref.watch(currencyFormatterProvider);
        final isMasked = ref.watch(balancePrivacyProvider);
        final progress = (goal.percentageCompleted / 100.0).clamp(0.0, 1.0);
        final fillColor = goal.isCompleted ? p.incomeGreen : p.primaryBrand;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: p.cardSurface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: goal.isCompleted ? p.incomeGreen.withOpacity(0.45) : p.borderSubtle,
          width: 1,
        ),
        boxShadow: p.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: Goal title & Percentage (matching Novbank "Financial goals" row)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  goal.title,
                  style: TextStyle(
                    color: p.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              Text(
                '${goal.percentageCompleted.toStringAsFixed(0)}%',
                style: TextStyle(
                  color: p.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),

          // Second row: "$70,500 of $100,000" on left, "57 days left" on right
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isMasked
                    ? '${currency.masked('••••')} of ${currency.masked('••••')}'
                    : '${currency.format(goal.currentAmount, decimalDigits: 0)} of ${currency.format(goal.targetAmount, decimalDigits: 0)}',
                style: TextStyle(
                  color: p.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                _daysLeftLabel(),
                style: TextStyle(
                  color: p.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Slim 6px deep-teal progress bar on soft track (matching Novbank)
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: p.progressTrack,
              valueColor: AlwaysStoppedAnimation<Color>(fillColor),
            ),
          ),
          const SizedBox(height: 12),

          // Action footer: Deposit pill button + optional Delete
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (onDelete != null)
                TextButton.icon(
                  onPressed: onDelete,
                  icon: Icon(Icons.delete_outline_rounded, size: 16, color: p.textMuted),
                  label: Text(
                    'Delete',
                    style: TextStyle(color: p.textMuted, fontSize: 12),
                  ),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              const Spacer(),
              if (!goal.isCompleted)
                InkWell(
                  onTap: onContribute,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: p.badgeBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: p.primaryBrand.withOpacity(0.25)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_rounded, size: 16, color: p.badgeText),
                        const SizedBox(width: 4),
                        Text(
                          'Deposit',
                          style: TextStyle(
                            color: p.badgeText,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: p.incomeGreen.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Completed',
                    style: TextStyle(
                      color: p.incomeGreen,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
      },
    );
  }
}
