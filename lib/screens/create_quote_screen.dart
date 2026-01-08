import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:myapp/app/app_theme.dart';
import 'package:myapp/app/widgets/custom_nav_bar.dart';
import 'package:myapp/app/widgets/gradient_button.dart';
import 'package:myapp/common/localization/l10n_extensions.dart';
import 'package:myapp/common/models/plan_package.dart';
import 'package:myapp/controllers/finance_controller.dart';
import 'package:myapp/controllers/user_controller.dart';
import 'package:myapp/widgets/plan_upgrade_sheet.dart';

enum _PaymentTerm { dueOnReceipt, due15Days, due30Days }

class CreateQuoteScreen extends StatefulWidget {
  const CreateQuoteScreen({super.key});

  @override
  State<CreateQuoteScreen> createState() => _CreateQuoteScreenState();
}

class _CreateQuoteScreenState extends State<CreateQuoteScreen> {
  final TextEditingController _projectController = TextEditingController();
  final TextEditingController _serviceController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String _selectedCurrency = 'EUR';
  _PaymentTerm _selectedPaymentTerm = _PaymentTerm.due15Days;
  bool _isSubmitting = false;

  static const List<String> _currencies = ['EUR', 'USD', 'GBP'];
  static const List<_PaymentTerm> _paymentTerms = [
    _PaymentTerm.dueOnReceipt,
    _PaymentTerm.due15Days,
    _PaymentTerm.due30Days,
  ];

  @override
  void dispose() {
    _projectController.dispose();
    _serviceController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            FeatherIcons.chevronLeft,
            color: AppColors.secondaryText,
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          loc.financeCreateQuoteTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            color: AppColors.secondaryText,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  24,
                  16,
                  24,
                  CustomNavBar.totalHeight + 48,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionCard(
                      title: loc.financeCreateQuoteSectionProject,
                      child: Column(
                        children: [
                          _LabeledField(
                            label: loc.financeCreateQuoteFieldProjectNameLabel,
                            child: TextField(
                              controller: _projectController,
                              decoration: _inputDecoration(
                                loc.financeCreateQuoteFieldProjectNameHint,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _LabeledField(
                            label: loc.financeCreateQuoteFieldScopeLabel,
                            child: TextField(
                              controller: _serviceController,
                              maxLines: 3,
                              decoration: _inputDecoration(
                                loc.financeCreateQuoteFieldScopeHint,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _SectionCard(
                      title: loc.financeCreateQuoteSectionPricing,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _LabeledField(
                                  label: loc.financeCreateQuoteFieldAmountLabel,
                                  child: TextField(
                                    controller: _amountController,
                                    keyboardType: TextInputType.number,
                                    decoration: _inputDecoration(
                                      loc.financeCreateQuoteFieldAmountHint,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _LabeledField(
                                  label:
                                      loc.financeCreateQuoteFieldCurrencyLabel,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.textfieldBackground,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: AppColors.textfieldBorder,
                                      ),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: _selectedCurrency,
                                        items: _currencies
                                            .map(
                                              (currency) => DropdownMenuItem(
                                                value: currency,
                                                child: Text(
                                                  currency,
                                                  style: theme
                                                      .textTheme
                                                      .labelLarge
                                                      ?.copyWith(
                                                        color: AppColors
                                                            .secondaryText,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                ),
                                              ),
                                            )
                                            .toList(),
                                        onChanged: (value) {
                                          if (value == null) return;
                                          setState(
                                            () => _selectedCurrency = value,
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _LabeledField(
                            label: loc.financeCreateQuoteFieldPaymentTermsLabel,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.textfieldBackground,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppColors.textfieldBorder,
                                ),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<_PaymentTerm>(
                                  value: _selectedPaymentTerm,
                                  items: _paymentTerms
                                      .map(
                                        (
                                          term,
                                        ) => DropdownMenuItem<_PaymentTerm>(
                                          value: term,
                                          child: Text(
                                            _paymentTermLabel(context, term),
                                            style: theme.textTheme.labelLarge
                                                ?.copyWith(
                                                  color:
                                                      AppColors.secondaryText,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (value) {
                                    if (value == null) return;
                                    setState(
                                      () => _selectedPaymentTerm = value,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _SectionCard(
                      title: loc.financeCreateQuoteSectionDeliverables,
                      child: Column(
                        children: [
                          _DeliverableTile(
                            title: loc.financeCreateQuoteDeliverablePhotosTitle,
                            subtitle: loc
                                .financeCreateQuoteDeliverablePhotosDescription,
                          ),
                          const SizedBox(height: 12),
                          _DeliverableTile(
                            title:
                                loc.financeCreateQuoteDeliverableSelectsTitle,
                            subtitle: loc
                                .financeCreateQuoteDeliverableSelectsDescription,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _SectionCard(
                      title: loc.financeCreateQuoteSectionNotes,
                      child: TextField(
                        controller: _notesController,
                        maxLines: 4,
                        decoration: _inputDecoration(
                          loc.financeCreateQuoteNotesHint,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    GradientButton(
                      onPressed: _submitQuote,
                      text: loc.financeCreateQuotePrimaryCta,
                      width: double.infinity,
                      height: 52,
                      isLoading: _isSubmitting,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomNavBar(currentRouteName: 'finance'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitQuote() async {
    if (_isSubmitting) return;
    FocusScope.of(context).unfocus();
    final amount = _parseAmount(_amountController.text);
    if (amount == null || amount <= 0) {
      const snackBar = SnackBar(
        content: Text('Enter a valid amount to continue.'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }
    final finance = context.read<FinanceController>();
    final userController = context.read<UserController?>();
    final docCount = finance.quotes.length + finance.invoices.length;
    if (userController != null && !userController.canCreateDocument(docCount)) {
      final unlocked = await showPlanUpgradeSheet(
        context,
        quotaType: PlanQuotaType.documents,
      );
      if (!mounted || !unlocked) {
        return;
      }
      if (!userController.canCreateDocument(docCount)) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.planUpgradeTrialActivated)),
      );
    }
    setState(() => _isSubmitting = true);
    final clientName = _projectController.text.trim().isEmpty
        ? context.l10n.financeQuoteFallbackClient
        : _projectController.text.trim();
    try {
      final quote = await finance.createDraftQuote(
        clientName: clientName,
        description: _buildQuoteDescription(context),
        subtotal: amount,
      );
      if (!mounted) return;
      context.push('/finance/quote/${quote.id}/preview');
    } catch (_) {
      if (!mounted) return;
      const snackBar = SnackBar(
        content: Text('Unable to create quote. Try again.'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  double? _parseAmount(String raw) {
    final sanitized = raw.replaceAll(RegExp(r'[^0-9.,]'), '');
    if (sanitized.isEmpty) {
      return null;
    }
    final normalized = sanitized.replaceAll(',', '.');
    final segments = normalized.split('.');
    if (segments.length <= 2) {
      return double.tryParse(normalized);
    }
    final decimalPart = segments.removeLast();
    final integerPart = segments.join();
    return double.tryParse('$integerPart.$decimalPart');
  }

  String _buildQuoteDescription(BuildContext context) {
    final loc = context.l10n;
    final scope = _serviceController.text.trim();
    final notes = _notesController.text.trim();
    final parts = <String>[
      scope.isEmpty ? loc.financeQuoteFallbackDescription : scope,
      '${_selectedCurrency.toUpperCase()} • '
          '${_paymentTermLabel(context, _selectedPaymentTerm)}',
    ];
    if (notes.isNotEmpty) {
      parts.add(notes);
    }
    return parts.join(' • ');
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      filled: true,
      fillColor: AppColors.textfieldBackground,
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: AppColors.textfieldBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: AppColors.textfieldBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: AppColors.secondary, width: 1.4),
      ),
    );
  }

  String _paymentTermLabel(BuildContext context, _PaymentTerm term) {
    final loc = context.l10n;
    switch (term) {
      case _PaymentTerm.dueOnReceipt:
        return loc.financeCreateQuotePaymentDueReceipt;
      case _PaymentTerm.due15Days:
        return loc.financeCreateQuotePaymentDue15;
      case _PaymentTerm.due30Days:
        return loc.financeCreateQuotePaymentDue30;
    }
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.secondaryText,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: AppColors.hintTextfiled,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _DeliverableTile extends StatelessWidget {
  const _DeliverableTile({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.textfieldBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.textfieldBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.secondary, AppColors.primary],
                begin: AlignmentDirectional(1.0, 0.34),
                end: AlignmentDirectional(-1.0, -0.34),
              ),
            ),
            alignment: Alignment.center,
            child: const Icon(
              FeatherIcons.check,
              size: 16,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: AppColors.secondaryText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.hintTextfiled,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
