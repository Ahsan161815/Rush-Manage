import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/app/app_theme.dart';
import 'package:myapp/controllers/finance_controller.dart';
import 'package:myapp/app/widgets/gradient_button.dart';
import 'package:myapp/common/localization/l10n_extensions.dart';
import 'package:myapp/models/finance.dart';

class FinanceSignatureTrackingScreen extends StatelessWidget {
  final String quoteId;
  const FinanceSignatureTrackingScreen({super.key, required this.quoteId});

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceController>();
    final quote = finance.getQuote(quoteId);
    final theme = Theme.of(context);
    final loc = context.l10n;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          loc.financeSignatureTrackingTitle,
          style: (theme.textTheme.titleLarge ?? const TextStyle()).copyWith(
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
            _TrackingHeader(quote: quote),
            const SizedBox(height: 24),
            _TrackingSteps(status: quote.status),
            const SizedBox(height: 32),
            GradientButton(
              onPressed: () async {
                final controller = context.read<FinanceController>();
                try {
                  switch (quote.status) {
                    case QuoteStatus.draft:
                      await controller.updateQuoteStatus(
                        quote.id,
                        QuoteStatus.pendingSignature,
                      );
                      break;
                    case QuoteStatus.pendingSignature:
                      await controller.updateQuoteStatus(
                        quote.id,
                        QuoteStatus.signed,
                      );
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(loc.financeSignatureSignedSnack),
                        ),
                      );
                      break;
                    case QuoteStatus.signed:
                      await controller.updateQuoteStatus(
                        quote.id,
                        QuoteStatus.declined,
                      );
                      break;
                    case QuoteStatus.declined:
                      await controller.updateQuoteStatus(
                        quote.id,
                        QuoteStatus.signed,
                      );
                      break;
                  }
                } catch (_) {
                  if (!context.mounted) return;
                  const snackBar = SnackBar(
                    content: Text('Unable to update quote status.'),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }
              },
              text: loc.financeSignatureAdvanceButton,
              height: 56,
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }
}

class _TrackingHeader extends StatelessWidget {
  final Quote quote;
  const _TrackingHeader({required this.quote});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = context.l10n;
    final quoteNumber = quote.id.substring(1);
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
            loc.financeSignatureTrackingQuoteLabel(quoteNumber),
            style: (theme.textTheme.titleMedium ?? const TextStyle()).copyWith(
              color: AppColors.secondaryText,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            quote.clientName.isNotEmpty
                ? quote.clientName
                : loc.financeInvoiceUnknownClient,
            style: (theme.textTheme.bodySmall ?? const TextStyle()).copyWith(
              color: AppColors.hintTextfiled,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrackingSteps extends StatelessWidget {
  final QuoteStatus status;
  const _TrackingSteps({required this.status});
  @override
  Widget build(BuildContext context) {
    final loc = context.l10n;
    final steps = [
      {
        'label': loc.financeSignatureStepWaiting,
        'complete':
            status != QuoteStatus.draft && status != QuoteStatus.declined,
      },
      {
        'label': loc.financeSignatureStepOpened,
        'complete':
            status == QuoteStatus.pendingSignature ||
            status == QuoteStatus.signed ||
            status == QuoteStatus.declined,
      },
      {
        'label': loc.financeSignatureStepSigned,
        'complete': status == QuoteStatus.signed,
      },
      {
        'label': loc.financeSignatureStepDeclined,
        'complete': status == QuoteStatus.declined,
      },
    ];
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
          for (int i = 0; i < steps.length; i++) ...[
            _StepRow(
              label: steps[i]['label'] as String,
              complete: steps[i]['complete'] as bool,
            ),
            if (i != steps.length - 1)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Container(
                  height: 2,
                  width: double.infinity,
                  color: AppColors.textfieldBorder.withValues(alpha: 0.4),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  final String label;
  final bool complete;
  const _StepRow({required this.label, required this.complete});
  @override
  Widget build(BuildContext context) {
    final color = complete
        ? AppColors.secondary
        : AppColors.textfieldBorder.withValues(alpha: 0.6);
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: complete
              ? AppColors.secondary
              : AppColors.secondaryBackground,
          child: Icon(
            complete ? Icons.check : Icons.hourglass_bottom,
            color: complete ? AppColors.primaryText : AppColors.hintTextfiled,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
