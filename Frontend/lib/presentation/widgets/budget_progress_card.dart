import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/budget_model.dart';

class BudgetProgressCard extends StatelessWidget {
  final BudgetProgressModel budget;
  final VoidCallback? onDelete;

  const BudgetProgressCard({
    super.key,
    required this.budget,
    this.onDelete,
  });

  Color _getStatusColor() {
    if (budget.isExceeded) return AppColors.statusExceeded;
    if (budget.isWarning) return AppColors.statusWarning;
    return AppColors.statusSafe;
  }

  @override
  Widget build(BuildContext context) {
    final currencyFmt = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    final statusColor = _getStatusColor();
    final progress = (budget.percentageSpent / 100.0).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceCardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: budget.isExceeded
              ? AppColors.statusExceeded.withOpacity(0.5)
              : AppColors.borderDark,
          width: budget.isExceeded ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                budget.category,
                style: const TextStyle(
                  color: AppColors.textPrimaryDark,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${budget.percentageSpent.toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.surfaceDark,
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Spent: ${currencyFmt.format(budget.actualSpent)} / ${currencyFmt.format(budget.monthlyLimit)}',
                style: const TextStyle(
                  color: AppColors.textSecondaryDark,
                  fontSize: 13,
                ),
              ),
              Text(
                budget.isExceeded
                    ? 'Over: ${currencyFmt.format(budget.actualSpent - budget.monthlyLimit)}'
                    : 'Left: ${currencyFmt.format(budget.remaining)}',
                style: TextStyle(
                  color: statusColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
