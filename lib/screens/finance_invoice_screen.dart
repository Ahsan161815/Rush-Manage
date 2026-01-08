import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/app/app_theme.dart';
import 'package:myapp/app/widgets/gradient_button.dart';
import 'package:myapp/common/localization/l10n_extensions.dart';
import 'package:myapp/controllers/finance_controller.dart';
import 'package:myapp/models/finance.dart';

class FinanceInvoiceScreen extends StatefulWidget {
  final String invoiceId;
  const FinanceInvoiceScreen({super.key, required this.invoiceId});

  @override
  State<FinanceInvoiceScreen> createState() => _FinanceInvoiceScreenState();
}

class _FinanceInvoiceScreenState extends State<FinanceInvoiceScreen> {
  DateTime? _issueDate;
  DateTime? _dueDate;
  PaymentMethod _method = PaymentMethod.bankTransfer;
  bool _initialized = false;

  Future<void> _pickDate(bool issue) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() {
        if (issue) {
          _issueDate = picked;
        } else {
          _dueDate = picked;
        }
      });
      // Persist change to backend — ensure we're still mounted
      if (!mounted) return;
      try {
        final finance = context.read<FinanceController>();
        if (issue) {
          await finance.updateInvoiceMetadata(
            widget.invoiceId,
            issuedAt: picked,
          );
        } else {
          await finance.updateInvoiceMetadata(
            widget.invoiceId,
            dueDate: picked,
          );
        }
      } catch (e) {
        // ignore errors for now; controller logs them
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    final finance = context.read<FinanceController>();
    final invoice = finance.getInvoice(widget.invoiceId);
    if (invoice.id == 'missing') return;
    setState(() {
      _issueDate = invoice.issuedAt;
      _dueDate = invoice.dueDate;
      _method = invoice.paymentMethod ?? PaymentMethod.bankTransfer;
      _initialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceController>();
    final invoice = finance.getInvoice(widget.invoiceId);
    final theme = Theme.of(context);
    final loc = context.l10n;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          loc.financeInvoiceTitle(
            invoice.id == 'missing' ? '—' : invoice.id.substring(3),
          ),
          style: theme.textTheme.titleLarge?.copyWith(
            color: AppColors.secondaryText,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InvoiceSummaryCard(invoice: invoice),
            const SizedBox(height: 24),
            _InvoiceFieldsCard(
              issueDate: _issueDate,
              dueDate: _dueDate,
              method: _method,
              onPickIssue: () => _pickDate(true),
              onPickDue: () => _pickDate(false),
              onMethodChanged: (m) async {
                setState(() => _method = m);
                try {
                  final finance = context.read<FinanceController>();
                  await finance.updateInvoiceMetadata(
                    widget.invoiceId,
                    paymentMethod: m,
                  );
                } catch (e) {
                  // ignore; controller handles logging and revert on failure
                }
              },
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: invoice.id == 'missing'
                        ? null
                        : () => finance.markInvoicePaid(invoice.id),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: AppColors.secondary,
                        width: 2,
                      ),
                      minimumSize: const Size(140, 54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Text(
                      invoice.status == InvoiceStatus.paid
                          ? loc.financeInvoiceButtonAlreadyPaid
                          : loc.financeInvoiceButtonMarkPaid,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GradientButton(
                    onPressed: invoice.id == 'missing'
                        ? () {}
                        : () {
                            final messenger = ScaffoldMessenger.of(context);
                            finance
                                .sendInvoiceReminder(invoice.id)
                                .then((_) {
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        loc.financeReminderSentSnack,
                                      ),
                                    ),
                                  );
                                })
                                .catchError((_) {
                                  messenger.showSnackBar(
                                    const SnackBar(
                                      content: Text('Failed to send reminder'),
                                    ),
                                  );
                                });
                          },
                    text: loc.financeInvoiceButtonSendReminder,
                    height: 54,
                    width: double.infinity,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InvoiceSummaryCard extends StatelessWidget {
  final Invoice? invoice;
  const _InvoiceSummaryCard({required this.invoice});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = context.l10n;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
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
            invoice?.clientName ?? loc.financeInvoiceUnknownClient,
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.secondaryText,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            loc.financeInvoiceAmountLabel(
              '€${invoice?.amount.toStringAsFixed(2) ?? '0.00'}',
            ),
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.hintTextfiled,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          _InvoiceStatusBadge(status: invoice?.status ?? InvoiceStatus.draft),
        ],
      ),
    );
  }
}

class _InvoiceStatusBadge extends StatelessWidget {
  final InvoiceStatus status;
  const _InvoiceStatusBadge({required this.status});
  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      InvoiceStatus.draft => AppColors.hintTextfiled,
      InvoiceStatus.unpaid => const Color(0xFFE55454),
      InvoiceStatus.paid => AppColors.secondary,
    };
    final loc = context.l10n;
    final label = switch (status) {
      InvoiceStatus.draft => loc.financeInvoiceStatusDraft,
      InvoiceStatus.unpaid => loc.financeInvoiceStatusUnpaid,
      InvoiceStatus.paid => loc.financeInvoiceStatusPaid,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color, width: 2),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _InvoiceFieldsCard extends StatelessWidget {
  final DateTime? issueDate;
  final DateTime? dueDate;
  final PaymentMethod method;
  final VoidCallback onPickIssue;
  final VoidCallback onPickDue;
  final ValueChanged<PaymentMethod> onMethodChanged;
  const _InvoiceFieldsCard({
    required this.issueDate,
    required this.dueDate,
    required this.method,
    required this.onPickIssue,
    required this.onPickDue,
    required this.onMethodChanged,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = context.l10n;
    String format(DateTime? d) {
      if (d == null) return loc.financeInvoiceDatePlaceholder;
      return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    }

    String labelFor(PaymentMethod m) => switch (m) {
      PaymentMethod.bankTransfer => loc.financeInvoiceMethodBankTransfer,
      PaymentMethod.card => loc.financeInvoiceMethodCard,
      PaymentMethod.applePay => loc.financeInvoiceMethodApplePay,
    };

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
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
            loc.financeInvoiceFieldsTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.secondaryText,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _DateButton(
                  label: loc.financeInvoiceIssueLabel,
                  value: format(issueDate),
                  onTap: onPickIssue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DateButton(
                  label: loc.financeInvoiceDueLabel,
                  value: format(dueDate),
                  onTap: onPickDue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            loc.financeInvoiceMethodLabel,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.hintTextfiled,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final m in PaymentMethod.values)
                _MethodChip(
                  label: labelFor(m),
                  selected: m == method,
                  onTap: () => onMethodChanged(m),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DateButton extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  const _DateButton({
    required this.label,
    required this.value,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.secondary, width: 2),
        minimumSize: const Size.fromHeight(54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: AppColors.secondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.secondaryText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MethodChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _MethodChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(
                  colors: [AppColors.secondary, AppColors.primary],
                  begin: AlignmentDirectional(1.0, 0.34),
                  end: AlignmentDirectional(-1.0, -0.34),
                )
              : null,
          color: selected ? null : AppColors.secondaryBackground,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected ? Colors.transparent : AppColors.textfieldBorder,
            width: 1.2,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.secondary.withValues(alpha: 0.2),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [
                  BoxShadow(
                    color: AppColors.secondary.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: selected ? AppColors.primaryText : AppColors.secondaryText,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
