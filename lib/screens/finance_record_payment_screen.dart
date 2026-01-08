import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:myapp/app/app_theme.dart';
import 'package:myapp/common/localization/l10n_extensions.dart';
import 'package:myapp/controllers/finance_controller.dart';
import 'package:myapp/models/finance.dart';

class FinanceRecordPaymentScreen extends StatefulWidget {
  const FinanceRecordPaymentScreen({super.key});

  @override
  State<FinanceRecordPaymentScreen> createState() =>
      _FinanceRecordPaymentScreenState();
}

class _FinanceRecordPaymentScreenState
    extends State<FinanceRecordPaymentScreen> {
  String? _selectedInvoiceId;

  Future<void> _submit(BuildContext context) async {
    final loc = context.l10n;
    if (_selectedInvoiceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.financeRecordPaymentValidationError)),
      );
      return;
    }
    try {
      await context.read<FinanceController>().markInvoicePaid(
        _selectedInvoiceId!,
      );
      if (!context.mounted) return;
      setState(() => _selectedInvoiceId = null);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(loc.financeRecordPaymentSuccess)));
    } catch (_) {
      if (!context.mounted) return;
      const snackBar = SnackBar(
        content: Text('Unable to record payment right now.'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceController>();
    final loc = context.l10n;
    final unpaid = finance.unpaidInvoices;
    final formatter = DateFormat('MMM d');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.secondaryText,
        elevation: 0,
        title: Text(loc.financeRecordPaymentTitle),
      ),
      body: SafeArea(
        child: unpaid.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    loc.financeRecordPaymentNoInvoices,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.hintTextfiled,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: _selectedInvoiceId,
                      decoration: InputDecoration(
                        labelText: loc.financeRecordPaymentInvoiceLabel,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      items: unpaid
                          .map(
                            (invoice) => DropdownMenuItem(
                              value: invoice.id,
                              child: Text(
                                '${invoice.id.toUpperCase()} · €${invoice.amount.toStringAsFixed(2)}',
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _selectedInvoiceId = value),
                    ),
                    const SizedBox(height: 24),
                    if (_selectedInvoiceId != null)
                      _PaymentSummary(
                        invoice: unpaid.firstWhere(
                          (inv) => inv.id == _selectedInvoiceId,
                        ),
                        formatter: formatter,
                      ),
                    const Spacer(),
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
                          loc.financeRecordPaymentSubmit,
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: AppColors.primaryText,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _PaymentSummary extends StatelessWidget {
  const _PaymentSummary({required this.invoice, required this.formatter});

  final Invoice invoice;
  final DateFormat formatter;

  @override
  Widget build(BuildContext context) {
    final loc = context.l10n;
    final dueLabel = invoice.dueDate == null
        ? loc.financeUpcomingNoDueDate
        : formatter.format(invoice.dueDate!);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.textfieldBorder.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.financeInvoiceTitle(invoice.id.substring(3)),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.secondaryText,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            invoice.clientName,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.secondaryText,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '€${invoice.amount.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.secondaryText,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            dueLabel,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.hintTextfiled,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
