import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
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
    final p = context.palette;
    final currency = ref.watch(currencyFormatterProvider);

    return Dialog(
      backgroundColor: p.cardSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: BorderSide(color: p.borderSubtle),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Set Monthly Budget Limit',
                style: TextStyle(
                  color: p.textPrimary,
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 18),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Category',
                    style: TextStyle(
                      color: p.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    dropdownColor: p.cardSurface,
                    style: TextStyle(
                      color: p.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      fillColor: p.nestedSurface,
                      prefixIcon: Icon(Icons.category_outlined, color: p.textSecondary, size: 20),
                    ),
                    items: _categories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedCategory = val);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _limitController,
                label: 'Monthly Limit (${currency.symbol})',
                hint: '500.00',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                prefixIcon: Icons.payments_outlined,
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
