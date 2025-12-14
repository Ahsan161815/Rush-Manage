import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:myapp/app/app_theme.dart';
import 'package:myapp/common/localization/l10n_extensions.dart';
import 'package:myapp/controllers/finance_controller.dart';

class FinanceCreateInvoiceScreen extends StatefulWidget {
  const FinanceCreateInvoiceScreen({super.key});

  @override
  State<FinanceCreateInvoiceScreen> createState() =>
      _FinanceCreateInvoiceScreenState();
}

class _FinanceCreateInvoiceScreenState
    extends State<FinanceCreateInvoiceScreen> {
  final _clientController = TextEditingController();
  final _amountController = TextEditingController();
  final _referenceController = TextEditingController();
  DateTime? _dueDate;

  @override
  void dispose() {
    _clientController.dispose();
    _amountController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) {
      setState(() => _dueDate = picked);
    }
  }

  void _submit() {
    final loc = context.l10n;
    final clientName = _clientController.text.trim();
    final amount = double.tryParse(_amountController.text.replaceAll(',', '.'));
    if (clientName.isEmpty || amount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.financeCreateInvoiceValidationError)),
      );
      return;
    }

    context.read<FinanceController>().createInvoice(
      clientName: clientName,
      amount: amount,
      dueDate: _dueDate,
      referenceId: _referenceController.text.trim().isEmpty
          ? null
          : _referenceController.text.trim(),
    );

    _clientController.clear();
    _amountController.clear();
    _referenceController.clear();
    setState(() => _dueDate = null);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(loc.financeCreateInvoiceSuccess)));
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.l10n;
    final dateLabel = _dueDate == null
        ? loc.financeCreateInvoiceSelectDate
        : DateFormat('MMM d, yyyy').format(_dueDate!);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.secondaryText,
        elevation: 0,
        title: Text(loc.financeCreateInvoiceTitle),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextField(
              controller: _clientController,
              decoration: InputDecoration(
                labelText: loc.financeCreateInvoiceClientLabel,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: loc.financeCreateInvoiceAmountLabel,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _referenceController,
              decoration: InputDecoration(
                labelText: loc.financeCreateInvoiceReferenceLabel,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${loc.financeCreateInvoiceDueLabel}: $dateLabel',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.secondaryText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _pickDate,
                  child: Text(loc.financeCreateInvoiceSelectDate),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
                child: Text(
                  loc.financeCreateInvoiceSubmit,
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
    );
  }
}
