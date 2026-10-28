import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/models/budget_model.dart';
import '../providers/theme_provider.dart';

class BudgetProgressCard extends StatelessWidget {
  final BudgetProgressModel budget;
  final VoidCallback? onDelete;

  const BudgetProgressCard({
    super.key,
    required this.budget,
    this.onDelete,
  });

  Color _getStatusColor(AppPalette p) {
    if (budget.isExceeded) return p.expenseRose;
    if (budget.isWarning) return p.warningAmber;
    return p.primaryBrand;
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toUpperCase()) {
      case 'FOOD':
        return Icons.restaurant_outlined;
      case 'HOUSING':
        return Icons.home_work_outlined;
      case 'TRANSPORTATION':
        return Icons.directions_car_outlined;
      case 'ENTERTAINMENT':
        return Icons.confirmation_number_outlined;
      case 'UTILITIES':
        return Icons.receipt_long_outlined;
      case 'SHOPPING':
        return Icons.shopping_bag_outlined;
      case 'HEALTHCARE':
        return Icons.medical_services_outlined;
      default:
        return Icons.pie_chart_outline_rounded;
    }
  }

  String _formatCategory(String raw) {
    if (raw.isEmpty) return 'General';
    final lower = raw.toLowerCase();
    return lower[0].toUpperCase() + lower.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final p = context.palette;
        final currency = ref.watch(currencyFormatterProvider);
        final isMasked = ref.watch(balancePrivacyProvider);
        final statusColor = _getStatusColor(p);
        final progress = (budget.percentageSpent / 100.0).clamp(0.0, 1.0);

    final statusSubtitle = isMasked
        ? '${currency.masked('••••')} remaining'
        : (budget.isExceeded
            ? 'Exceeded by ${currency.format(budget.actualSpent - budget.monthlyLimit)}'
            : '${currency.format(budget.remaining)} left this month');

    return Container(
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: p.nestedSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: budget.isExceeded ? p.expenseRose.withOpacity(0.45) : p.borderSubtle,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // White/Elevated Rounded-Square Icon Box (matching Novbank "Upcoming" rows)
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: p.iconBoxSurface,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(p.isDark ? 0.18 : 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  _getCategoryIcon(budget.category),
                  color: statusColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatCategory(budget.category),
                      style: TextStyle(
                        color: p.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      statusSubtitle,
                      style: TextStyle(
                        color: budget.isExceeded ? p.expenseRose : p.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    isMasked ? currency.masked('••••') : currency.format(budget.actualSpent),
                    style: TextStyle(
                      color: p.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    isMasked
                        ? 'of ${currency.masked('••••')} (${budget.percentageSpent.toStringAsFixed(0)}%)'
                        : 'of ${currency.format(budget.monthlyLimit)} (${budget.percentageSpent.toStringAsFixed(0)}%)',
                    style: TextStyle(
                      color: p.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              if (onDelete != null) ...[
                const SizedBox(width: 4),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: Icon(Icons.close_rounded, size: 17, color: p.textMuted),
                  tooltip: 'Remove budget',
                  onPressed: onDelete,
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: p.progressTrack,
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
          ),
        ],
      ),
    );
      },
    );
  }
}
