import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String amount;
  final IconData icon;
  final Color iconColor;
  final Color? backgroundColor;

  const StatCard({
    super.key,
    required this.title,
    required this.amount,
    required this.icon,
    required this.iconColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surfaceCardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDark, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textSecondaryDark,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            amount,
            style: const TextStyle(
              color: AppColors.textPrimaryDark,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
