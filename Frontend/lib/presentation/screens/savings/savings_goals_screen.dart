import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/savings_provider.dart';
import '../../widgets/savings_goal_card.dart';
import 'add_goal_dialog.dart';
import 'contribute_dialog.dart';

class SavingsGoalsScreen extends ConsumerWidget {
  const SavingsGoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(savingsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: RefreshIndicator(
        onRefresh: () => ref.read(savingsProvider.notifier).loadGoals(),
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
                    'Savings Goals',
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
                        builder: (_) => const AddGoalDialog(),
                      );
                    },
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('New Goal'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentCyan,
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
                    child: CircularProgressIndicator(color: AppColors.accentCyan),
                  ),
                )
              else if (state.goals.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCardDark,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderDark),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.savings_outlined, size: 48, color: AppColors.accentCyan),
                      const SizedBox(height: 12),
                      const Text(
                        'No savings goals set',
                        style: TextStyle(color: AppColors.textPrimaryDark, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Track milestones like Emergency Funds, Vacations, or Major Investments.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 13),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => const AddGoalDialog(),
                          );
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentCyan),
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
