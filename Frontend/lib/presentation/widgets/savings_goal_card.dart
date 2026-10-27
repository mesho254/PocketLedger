import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/savings_goal_model.dart';

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

  @override
  Widget build(BuildContext context) {
    final currencyFmt = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    final progress = (goal.percentageCompleted / 100.0).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceCardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: goal.isCompleted
              ? AppColors.primary.withOpacity(0.5)
              : AppColors.borderDark,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  goal.title,
                  style: const TextStyle(
                    color: AppColors.textPrimaryDark,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (goal.isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'COMPLETED 🎉',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else
                Text(
                  '${goal.percentageCompleted.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    color: AppColors.accentCyan,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.surfaceDark,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentCyan),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Saved: ${currencyFmt.format(goal.currentAmount)}',
                    style: const TextStyle(
                      color: AppColors.textPrimaryDark,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'Target: ${currencyFmt.format(goal.targetAmount)}',
                    style: const TextStyle(
                      color: AppColors.textSecondaryDark,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              if (!goal.isCompleted)
                ElevatedButton.icon(
                  onPressed: onContribute,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Deposit'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.surfaceDark,
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary, width: 1),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
