import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/transaction_model.dart';

class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const TransactionTile({
    super.key,
    required this.transaction,
    this.onTap,
    this.onDelete,
  });

  IconData _getCategoryIcon(String category) {
    switch (category.toUpperCase()) {
      case 'FOOD':
        return Icons.restaurant_rounded;
      case 'HOUSING':
        return Icons.home_rounded;
      case 'TRANSPORTATION':
        return Icons.directions_car_rounded;
      case 'ENTERTAINMENT':
        return Icons.movie_rounded;
      case 'UTILITIES':
        return Icons.bolt_rounded;
      case 'SALARY':
        return Icons.account_balance_rounded;
      case 'INVESTMENT':
        return Icons.trending_up_rounded;
      case 'HEALTHCARE':
        return Icons.medical_services_rounded;
      case 'SHOPPING':
        return Icons.shopping_bag_rounded;
      default:
        return Icons.receipt_long_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.isIncome;
    final formattedDate = DateFormat('MMM dd, yyyy').format(transaction.transactionDate);
    final formattedAmount = NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(transaction.amount);

    return Dismissible(
      key: Key(transaction.id),
      direction: onDelete != null ? DismissDirection.endToStart : DismissDirection.none,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.expense.withOpacity(0.85),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      onDismissed: (_) => onDelete?.call(),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surfaceCardDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderDark, width: 0.8),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (isIncome ? AppColors.income : AppColors.expense).withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getCategoryIcon(transaction.category),
                  color: isIncome ? AppColors.income : AppColors.expense,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.description?.isNotEmpty == true
                          ? transaction.description!
                          : transaction.category,
                      style: const TextStyle(
                        color: AppColors.textPrimaryDark,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$formattedDate • ${transaction.category}',
                      style: const TextStyle(
                        color: AppColors.textSecondaryDark,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${isIncome ? '+' : '-'}$formattedAmount',
                style: TextStyle(
                  color: isIncome ? AppColors.income : AppColors.expense,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
