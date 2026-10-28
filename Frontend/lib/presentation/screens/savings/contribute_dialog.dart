import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/savings_goal_model.dart';
import '../../providers/savings_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';

class ContributeDialog extends ConsumerStatefulWidget {
  final SavingsGoalModel goal;

  const ContributeDialog({super.key, required this.goal});

  @override
  ConsumerState<ContributeDialog> createState() => _ContributeDialogState();
}

class _ContributeDialogState extends ConsumerState<ContributeDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) return;

    setState(() => _isLoading = true);

    final success = await ref.read(savingsProvider.notifier).addContribution(
          goalId: widget.goal.id,
          amount: amount,
          note: _noteController.text.trim().isNotEmpty ? _noteController.text.trim() : null,
        );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) Navigator.pop(context);
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
                'Deposit to "${widget.goal.title}"',
                style: TextStyle(
                  color: p.textPrimary,
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 18),

              CustomTextField(
                controller: _amountController,
                label: 'Contribution Amount (${currency.symbol})',
                hint: '100.00',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                prefixIcon: Icons.payments_outlined,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Enter an amount';
                  final numVal = double.tryParse(val);
                  if (numVal == null || numVal <= 0) return 'Must be a positive number';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _noteController,
                label: 'Note (Optional)',
                hint: 'e.g. Month-end bonus deposit',
                prefixIcon: Icons.notes_rounded,
              ),
              const SizedBox(height: 24),

              PrimaryButton(
                text: 'Record Deposit',
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
