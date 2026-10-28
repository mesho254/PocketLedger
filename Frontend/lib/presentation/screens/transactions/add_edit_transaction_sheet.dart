import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/transaction_model.dart';
import '../../providers/analytics_provider.dart';
import '../../providers/budget_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';

class AddEditTransactionSheet extends ConsumerStatefulWidget {
  final TransactionModel? existingTransaction;

  const AddEditTransactionSheet({super.key, this.existingTransaction});

  @override
  ConsumerState<AddEditTransactionSheet> createState() => _AddEditTransactionSheetState();
}

class _AddEditTransactionSheetState extends ConsumerState<AddEditTransactionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  late String _type; // 'INCOME' or 'EXPENSE'
  late String _category;
  late DateTime _selectedDate;
  bool _isLoading = false;

  final List<String> _expenseCategories = [
    'FOOD',
    'HOUSING',
    'TRANSPORTATION',
    'UTILITIES',
    'ENTERTAINMENT',
    'HEALTHCARE',
    'SHOPPING',
    'OTHER',
  ];

  final List<String> _incomeCategories = [
    'SALARY',
    'FREELANCE',
    'INVESTMENT',
    'OTHER',
  ];

  @override
  void initState() {
    super.initState();
    final tx = widget.existingTransaction;
    if (tx != null) {
      _amountController.text = tx.amount.toString();
      _descriptionController.text = tx.description ?? '';
      _type = tx.type;
      _category = tx.category;
      _selectedDate = tx.transactionDate;
    } else {
      _type = 'EXPENSE';
      _category = 'FOOD';
      _selectedDate = DateTime.now();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) return;

    setState(() => _isLoading = true);

    final tx = TransactionModel(
      id: widget.existingTransaction?.id ?? '',
      amount: amount,
      type: _type,
      category: _category,
      transactionDate: _selectedDate,
      description: _descriptionController.text.trim(),
    );

    bool success;
    if (widget.existingTransaction != null) {
      success = await ref.read(transactionProvider.notifier).updateTransaction(
            widget.existingTransaction!.id,
            tx,
          );
    } else {
      success = await ref.read(transactionProvider.notifier).addTransaction(tx);
    }

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        ref.read(analyticsProvider.notifier).loadSummary();
        ref.read(budgetProvider.notifier).loadBudgets();
        Navigator.pop(context);
      }
    }
  }

  void _pickDate() async {
    final p = context.palette;
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
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
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final currency = ref.watch(currencyFormatterProvider);
    final categories = _type == 'INCOME' ? _incomeCategories : _expenseCategories;
    if (!categories.contains(_category)) {
      _category = categories.first;
    }

    return Container(
      padding: EdgeInsets.only(
        top: 18,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: p.cardSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: p.borderSubtle),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: p.borderSubtle,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.existingTransaction != null ? 'Edit Transaction' : 'Record Transaction',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: p.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 18),

              // Segmented Type Switcher (Expense vs Income)
              Container(
                decoration: BoxDecoration(
                  color: p.nestedSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: p.borderSubtle),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _type = 'EXPENSE'),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          decoration: BoxDecoration(
                            color: _type == 'EXPENSE' ? p.expenseRose : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              'Expense',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: _type == 'EXPENSE' ? Colors.white : p.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _type = 'INCOME'),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          decoration: BoxDecoration(
                            color: _type == 'INCOME' ? p.incomeGreen : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              'Income',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: _type == 'INCOME' ? Colors.white : p.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              CustomTextField(
                controller: _amountController,
                label: 'Amount (${currency.symbol})',
                hint: '0.00',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                prefixIcon: Icons.payments_outlined,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Enter an amount';
                  final numVal = double.tryParse(val);
                  if (numVal == null || numVal <= 0) return 'Enter a positive number';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Category',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: p.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _category,
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
                    items: categories.map((cat) {
                      return DropdownMenuItem(value: cat, child: Text(cat));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _category = val);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Date',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: p.textSecondary,
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
                          Icon(Icons.calendar_today_outlined, size: 19, color: p.textSecondary),
                          const SizedBox(width: 12),
                          Text(
                            DateFormat('MMMM dd, yyyy').format(_selectedDate),
                            style: TextStyle(
                              color: p.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          Icon(Icons.arrow_drop_down, color: p.textSecondary),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _descriptionController,
                label: 'Description (Optional)',
                hint: 'e.g. Weekly grocery restock',
                prefixIcon: Icons.notes_rounded,
              ),
              const SizedBox(height: 24),

              PrimaryButton(
                text: widget.existingTransaction != null ? 'Update Transaction' : 'Save Transaction',
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
