import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/models/transaction_model.dart';

class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool isMasked;

  const TransactionTile({
    super.key,
    required this.transaction,
    this.onTap,
    this.onDelete,
    this.isMasked = false,
  });

  IconData _getCategoryIcon(String category) {
    switch (category.toUpperCase()) {
      case 'FOOD':
        return Icons.restaurant_outlined;
      case 'HOUSING':
        return Icons.receipt_long_outlined;
      case 'TRANSPORTATION':
        return Icons.directions_car_outlined;
      case 'ENTERTAINMENT':
        return Icons.confirmation_number_outlined;
      case 'UTILITIES':
        return Icons.bolt_outlined;
      case 'SALARY':
        return Icons.account_balance_wallet_outlined;
      case 'FREELANCE':
        return Icons.work_outline_rounded;
      case 'INVESTMENT':
        return Icons.trending_up_rounded;
      case 'HEALTHCARE':
        return Icons.medical_services_outlined;
      case 'SHOPPING':
        return Icons.shopping_bag_outlined;
      default:
        return Icons.receipt_outlined;
    }
  }

  Color _getCategoryColor(String category, AppPalette p, bool isIncome) {
    if (isIncome) return p.incomeGreen;
    switch (category.toUpperCase()) {
      case 'FOOD':
        return p.warningAmber;
      case 'HOUSING':
      case 'TRANSPORTATION':
        return p.secondaryTeal;
      case 'ENTERTAINMENT':
      case 'SHOPPING':
        return p.expenseRose;
      case 'UTILITIES':
        return const Color(0xFF6366F1);
      default:
        return p.primaryBrand;
    }
  }

  String _formatCategoryLabel(String category) {
    if (category.isEmpty) return 'General';
    final lower = category.toLowerCase();
    return lower[0].toUpperCase() + lower.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final p = context.palette;
        final currency = ref.watch(currencyFormatterProvider);
        final isIncome = transaction.isIncome;
        final formattedDate = DateFormat('yyyy-MM-dd').format(transaction.transactionDate);
        final rawAmount = currency.format(transaction.amount);
        final formattedAmount =
            isMasked ? currency.masked('••••') : '${isIncome ? '+' : '-'}$rawAmount';
        final accentColor = _getCategoryColor(transaction.category, p, isIncome);

    return Dismissible(
      key: Key(transaction.id),
      direction: onDelete != null ? DismissDirection.endToStart : DismissDirection.none,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        margin: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: p.expenseRose.withOpacity(0.9),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      onDismissed: (_) => onDelete?.call(),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          margin: const EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            color: p.nestedSurface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: p.borderSubtle.withOpacity(p.isDark ? 0.6 : 0.45),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Novbank nested card white/elevated rounded-square icon box
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
                  _getCategoryIcon(transaction.category),
                  color: accentColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.description?.isNotEmpty == true
                          ? transaction.description!
                          : _formatCategoryLabel(transaction.category),
                      style: TextStyle(
                        color: p.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _formatCategoryLabel(transaction.category),
                      style: TextStyle(
                        color: p.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formattedAmount,
                    style: TextStyle(
                      color: isIncome ? p.incomeGreen : p.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    formattedDate,
                    style: TextStyle(
                      color: p.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
      },
    );
  }
}
