import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:myapp/app/app_theme.dart';
import 'package:myapp/app/widgets/gradient_button.dart';
import 'package:myapp/controllers/finance_controller.dart';
import 'package:myapp/models/finance.dart';

class FinanceQuotePreviewScreen extends StatelessWidget {
  final String quoteId;
  const FinanceQuotePreviewScreen({super.key, required this.quoteId});

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceController>();
    final quote = finance.getQuote(quoteId);
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Quote #${quote?.id.substring(1) ?? '—'} Preview',
          style: theme.textTheme.titleLarge?.copyWith(
            color: AppColors.secondaryText,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (quote?.status == QuoteStatus.draft)
            IconButton(
              tooltip: 'Send Quote',
              onPressed: () {
                finance.updateQuoteStatus(
                  quote!.id,
                  QuoteStatus.pendingSignature,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Quote sent for signature')),
                );
              },
              icon: const Icon(Icons.send, color: AppColors.secondaryText),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (quote != null) _QuoteSummaryCard(quote: quote),
            const SizedBox(height: 24),
            _QuoteDocumentCard(),
            const SizedBox(height: 32),
            GradientButton(
              onPressed: () =>
                  context.push('/finance/quote/$quoteId/signature'),
              text: 'Track Signature',
              height: 56,
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuoteSummaryCard extends StatelessWidget {
  final Quote quote;
  const _QuoteSummaryCard({required this.quote});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
            quote.clientName,
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.secondaryText,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            quote.description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.hintTextfiled,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total (incl. VAT)',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.hintTextfiled,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '€${quote.total.toStringAsFixed(2)}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: AppColors.secondaryText,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              _QuoteStatusBadge(status: quote.status),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuoteStatusBadge extends StatelessWidget {
  final QuoteStatus status;
  const _QuoteStatusBadge({required this.status});
  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      QuoteStatus.draft => AppColors.hintTextfiled,
      QuoteStatus.pendingSignature => const Color(0xFF2FBF71),
      QuoteStatus.signed => AppColors.secondary,
      QuoteStatus.declined => const Color(0xFFE55454),
    };
    final label = switch (status) {
      QuoteStatus.draft => 'Draft',
      QuoteStatus.pendingSignature => 'Pending Signature',
      QuoteStatus.signed => 'Signed',
      QuoteStatus.declined => 'Declined',
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

class _QuoteDocumentCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 360,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: AppColors.textfieldBorder.withValues(alpha: 0.5),
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        'Quote PDF layout placeholder',
        style: theme.textTheme.bodySmall?.copyWith(
          color: AppColors.hintTextfiled,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
