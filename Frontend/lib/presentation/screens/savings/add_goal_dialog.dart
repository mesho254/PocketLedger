import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
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
    final p = context.palette;
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 90)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: p.primaryBrand,
                  onPrimary: Colors.white,
                  surface: p.cardSurface,
                  onSurface: p.textPrimary,
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
                'Create Savings Goal',
                style: TextStyle(
                  color: p.textPrimary,
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 18),

              CustomTextField(
                controller: _titleController,
                label: 'Goal Title',
                hint: 'e.g. Emergency Fund, New Laptop',
                prefixIcon: Icons.flag_outlined,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Enter a goal title';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _targetAmountController,
                label: 'Target Amount (${currency.symbol})',
                hint: '1000.00',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                prefixIcon: Icons.payments_outlined,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Enter a target amount';
                  final numVal = double.tryParse(val);
                  if (numVal == null || numVal <= 0) return 'Must be greater than zero';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Target Date (Optional)',
                    style: TextStyle(
                      color: p.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                      decoration: BoxDecoration(
                        color: p.nestedSurface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: p.borderSubtle),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today_outlined, size: 18, color: p.textSecondary),
                          const SizedBox(width: 10),
                          Text(
                            _targetDate != null
                                ? DateFormat('MMMM dd, yyyy').format(_targetDate!)
                                : 'Select target completion date',
                            style: TextStyle(
                              color: _targetDate != null ? p.textPrimary : p.textMuted,
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
                backgroundColor: p.primaryBrand,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
