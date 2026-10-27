import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/budget_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';

class SetBudgetDialog extends ConsumerStatefulWidget {
  const SetBudgetDialog({super.key});

  @override
  ConsumerState<SetBudgetDialog> createState() => _SetBudgetDialogState();
}

class _SetBudgetDialogState extends ConsumerState<SetBudgetDialog> {
  final _formKey = GlobalKey<FormState>();
  final _limitController = TextEditingController();
  String _selectedCategory = 'FOOD';
  bool _isLoading = false;

  final List<String> _categories = [
    'FOOD',
    'HOUSING',
    'TRANSPORTATION',
    'UTILITIES',
    'ENTERTAINMENT',
    'HEALTHCARE',
    'SHOPPING',
    'OTHER',
  ];

  @override
  void dispose() {
    _limitController.dispose();
    super.dispose();
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    final limit = double.tryParse(_limitController.text);
    if (limit == null || limit <= 0) return;

    setState(() => _isLoading = true);

    final success = await ref.read(budgetProvider.notifier).setBudget(
          category: _selectedCategory,
          monthlyLimit: limit,
        );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surfaceCardDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Set Monthly Budget Limit',
                style: TextStyle(
                  color: AppColors.textPrimaryDark,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Category Picker
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Category',
                    style: TextStyle(
                      color: AppColors.textSecondaryDark,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    dropdownColor: AppColors.surfaceDark,
                    style: const TextStyle(color: AppColors.textPrimaryDark, fontSize: 15),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.category_rounded, color: AppColors.textSecondaryDark),
                    ),
                    items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedCategory = val);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Monthly Limit
              CustomTextField(
                controller: _limitController,
                label: 'Monthly Limit (\$)',
                hint: '500.00',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                prefixIcon: Icons.attach_money_rounded,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Please enter an amount';
                  final numVal = double.tryParse(val);
                  if (numVal == null || numVal <= 0) return 'Must be a positive number';
                  return null;
                },
              ),
              const SizedBox(height: 24),

              PrimaryButton(
                text: 'Save Budget Limit',
                isLoading: _isLoading,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
