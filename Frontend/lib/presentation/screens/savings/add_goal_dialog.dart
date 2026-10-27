import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/savings_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';

class AddGoalDialog extends ConsumerStatefulWidget {
  const AddGoalDialog({super.key});

  @override
  ConsumerState<AddGoalDialog> createState() => _AddGoalDialogState();
}

class _AddGoalDialogState extends ConsumerState<AddGoalDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _targetAmountController = TextEditingController();
  DateTime? _targetDate;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _targetAmountController.dispose();
    super.dispose();
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    final amount = double.tryParse(_targetAmountController.text);
    if (amount == null || amount <= 0) return;

    setState(() => _isLoading = true);

    final success = await ref.read(savingsProvider.notifier).createGoal(
          title: _titleController.text.trim(),
          targetAmount: amount,
          targetDate: _targetDate,
        );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) Navigator.pop(context);
    }
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 90)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.accentCyan,
              onPrimary: Colors.white,
              surface: AppColors.surfaceCardDark,
              onSurface: AppColors.textPrimaryDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _targetDate = picked);
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
                'Create Savings Goal',
                style: TextStyle(
                  color: AppColors.textPrimaryDark,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Title
              CustomTextField(
                controller: _titleController,
                label: 'Goal Title',
                hint: 'e.g. Emergency Fund, New Laptop',
                prefixIcon: Icons.flag_rounded,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Enter a goal title';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Target Amount
              CustomTextField(
                controller: _targetAmountController,
                label: 'Target Amount (\$)',
                hint: '1000.00',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                prefixIcon: Icons.attach_money_rounded,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Enter a target amount';
                  final numVal = double.tryParse(val);
                  if (numVal == null || numVal <= 0) return 'Must be greater than zero';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Target Date Picker
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Target Date (Optional)',
                    style: TextStyle(
                      color: AppColors.textSecondaryDark,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDark,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderDark),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.textSecondaryDark),
                          const SizedBox(width: 10),
                          Text(
                            _targetDate != null
                                ? DateFormat('MMMM dd, yyyy').format(_targetDate!)
                                : 'Select target completion date',
                            style: TextStyle(
                              color: _targetDate != null ? AppColors.textPrimaryDark : AppColors.textMutedDark,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              PrimaryButton(
                text: 'Create Goal',
                isLoading: _isLoading,
                backgroundColor: AppColors.accentCyan,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
