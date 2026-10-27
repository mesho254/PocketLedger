import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/budget_provider.dart';
import '../../widgets/budget_progress_card.dart';
import 'set_budget_dialog.dart';

class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(budgetProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: RefreshIndicator(
        onRefresh: () => ref.read(budgetProvider.notifier).loadBudgets(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Monthly Budgets',
                    style: TextStyle(
                      color: AppColors.textPrimaryDark,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => const SetBudgetDialog(),
                      );
                    },
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Set Budget'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (state.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                )
              else if (state.budgets.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCardDark,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderDark),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.pie_chart_outline_rounded, size: 48, color: AppColors.textSecondaryDark),
                      const SizedBox(height: 12),
                      const Text(
                        'No category budgets configured',
                        style: TextStyle(color: AppColors.textPrimaryDark, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Set monthly spending limits for categories like Food, Housing, or Entertainment.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 13),
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
                    onDelete: () => ref.read(budgetProvider.notifier).deleteBudget(budget.id),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
