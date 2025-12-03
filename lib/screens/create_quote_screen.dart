import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

import 'package:myapp/app/app_theme.dart';
import 'package:myapp/app/widgets/custom_nav_bar.dart';
import 'package:myapp/app/widgets/gradient_button.dart';

class CreateQuoteScreen extends StatefulWidget {
  const CreateQuoteScreen({super.key});

  @override
  State<CreateQuoteScreen> createState() => _CreateQuoteScreenState();
}

class _CreateQuoteScreenState extends State<CreateQuoteScreen> {
  final TextEditingController _projectController = TextEditingController(
    text: 'Dupont Wedding',
  );
  final TextEditingController _serviceController = TextEditingController(
    text: 'Event photography and same-day selects',
  );
  final TextEditingController _amountController = TextEditingController(
    text: '2 850',
  );
  final TextEditingController _notesController = TextEditingController(
    text: 'Includes 8 hours coverage, assistant, and equipment rental fees.',
  );

  String _selectedCurrency = 'EUR';
  String _selectedPaymentTerm = 'Due within 15 days';

  static const List<String> _currencies = ['EUR', 'USD', 'GBP'];
  static const List<String> _paymentTerms = [
    'Due on receipt',
    'Due within 15 days',
    'Due within 30 days',
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
          'Create quote',
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
                      title: 'Project details',
                      child: Column(
                        children: [
                          _LabeledField(
                            label: 'Project name',
                            child: TextField(
                              controller: _projectController,
                              decoration: _inputDecoration('Add project name'),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _LabeledField(
                            label: 'Scope of work',
                            child: TextField(
                              controller: _serviceController,
                              maxLines: 3,
                              decoration: _inputDecoration(
                                'Describe the services provided',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _SectionCard(
                      title: 'Pricing',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _LabeledField(
                                  label: 'Amount',
                                  child: TextField(
                                    controller: _amountController,
                                    keyboardType: TextInputType.number,
                                    decoration: _inputDecoration('0.00'),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _LabeledField(
                                  label: 'Currency',
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
                            label: 'Payment terms',
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
                                  value: _selectedPaymentTerm,
                                  items: _paymentTerms
                                      .map(
                                        (term) => DropdownMenuItem(
                                          value: term,
                                          child: Text(
                                            term,
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
                      title: 'Deliverables',
                      child: Column(
                        children: const [
                          _DeliverableTile(
                            title: 'High-resolution photos',
                            subtitle:
                                'Delivery via shared folder within 48 hours',
                          ),
                          SizedBox(height: 12),
                          _DeliverableTile(
                            title: 'Same-day selects',
                            subtitle: '15 edits for social media use',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _SectionCard(
                      title: 'Additional notes',
                      child: TextField(
                        controller: _notesController,
                        maxLines: 4,
                        decoration: _inputDecoration(
                          'Any special considerations or add-ons',
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    GradientButton(
                      onPressed: () {},
                      text: 'Send quote',
                      width: double.infinity,
                      height: 52,
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
