import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:myapp/app/app_theme.dart';
import 'package:myapp/common/localization/l10n_extensions.dart';
import 'package:myapp/controllers/finance_controller.dart';
import 'package:myapp/models/finance.dart';

class FinanceInvoicesScreen extends StatelessWidget {
  const FinanceInvoicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceController>();
    final loc = context.l10n;
    final invoices = [...finance.invoices]
      ..sort((a, b) => b.issuedAt.compareTo(a.issuedAt));
    final formatter = DateFormat('MMM d, yyyy');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.secondaryText,
        elevation: 0,
        title: Text(loc.financeInvoicesTitle),
      ),
      body: SafeArea(
        child: invoices.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    loc.financeInvoicesEmpty,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.hintTextfiled,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(24),
                itemCount: invoices.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final invoice = invoices[index];
                  final status = _InvoiceStatusChip.fromStatus(
                    context,
                    invoice.status,
                  );
                  final dueLabel = invoice.dueDate == null
                      ? loc.financeUpcomingNoDueDate
                      : formatter.format(invoice.dueDate!);
                  return Container(
                    padding: const EdgeInsets.all(18),
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
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                loc.financeInvoiceTitle(
                                  invoice.id.substring(3),
                                ),
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: AppColors.secondaryText,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ),
                            _StatusPill(
                              label: status.label,
                              color: status.color,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          invoice.clientName,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: AppColors.secondaryText,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '€${invoice.amount.toStringAsFixed(2)}',
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(
                                      color: AppColors.secondaryText,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                            Text(
                              dueLabel,
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(
                                    color: AppColors.hintTextfiled,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: () =>
                                context.push('/finance/invoice/${invoice.id}'),
                            child: Text(
                              loc.financeInvoicesOpenDetail,
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(
                                    color: AppColors.secondary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _InvoiceStatusChip {
  _InvoiceStatusChip({required this.label, required this.color});
  final String label;
  final Color color;

  static _InvoiceStatusChip fromStatus(
    BuildContext context,
    InvoiceStatus status,
  ) {
    final loc = context.l10n;
    switch (status) {
      case InvoiceStatus.draft:
        return _InvoiceStatusChip(
          label: loc.financeInvoiceStatusDraft,
          color: AppColors.hintTextfiled,
        );
      case InvoiceStatus.unpaid:
        return _InvoiceStatusChip(
          label: loc.financeInvoiceStatusUnpaid,
          color: const Color(0xFFE55454),
        );
      case InvoiceStatus.paid:
        return _InvoiceStatusChip(
          label: loc.financeInvoiceStatusPaid,
          color: const Color(0xFF2FBF71),
        );
    }
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 2),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
