import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:myapp/app/app_theme.dart';
import 'package:myapp/common/localization/l10n_extensions.dart';
import 'package:myapp/controllers/finance_controller.dart';

class FinanceExpensesScreen extends StatefulWidget {
  const FinanceExpensesScreen({super.key});

  @override
  State<FinanceExpensesScreen> createState() => _FinanceExpensesScreenState();
}

class _FinanceExpensesScreenState extends State<FinanceExpensesScreen> {
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) {
      setState(() => _selectedDate = picked);
    }
  }

  void _submit(BuildContext context) {
    final loc = context.l10n;
    final description = _descriptionController.text.trim();
    final parsedAmount = double.tryParse(
      _amountController.text.replaceAll(',', '.'),
    );
    if (description.isEmpty || parsedAmount == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(loc.financeExpensesFormError)));
      return;
    }

    context.read<FinanceController>().addExpense(
      description: description,
      amount: parsedAmount,
      date: _selectedDate,
    );

    _descriptionController.clear();
    _amountController.clear();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(loc.financeExpensesAddSuccess)));
  }

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceController>();
    final loc = context.l10n;
    final expenses = [...finance.expenses]
      ..sort((a, b) => b.date.compareTo(a.date));
    final formatter = DateFormat('MMM d, yyyy');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.secondaryText,
        elevation: 0,
        title: Text(loc.financeExpensesScreenTitle),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.secondaryBackground,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(
                  color: AppColors.textfieldBorder.withValues(alpha: 0.5),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.financeExpensesFormTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.secondaryText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: loc.financeExpensesFormDescription,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: loc.financeExpensesFormAmount,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${loc.financeExpensesFormDate}: ${DateFormat('MMM d, yyyy').format(_selectedDate)}',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: AppColors.secondaryText,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => _pickDate(context),
                        child: Text(loc.financeExpensesSelectDate),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => _submit(context),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                      ),
                      child: Text(
                        loc.financeExpensesAddCta,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.primaryText,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (expenses.isEmpty)
              Text(
                loc.financeExpensesEmptyList,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.hintTextfiled,
                  fontWeight: FontWeight.w600,
                ),
              )
            else
              ...expenses.map(
                (expense) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryBackground,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: AppColors.textfieldBorder.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                expense.description,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: AppColors.secondaryText,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                formatter.format(expense.date),
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: AppColors.hintTextfiled,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '€${expense.amount.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: AppColors.secondaryText,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
