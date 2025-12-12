import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:myapp/app/app_theme.dart';
import 'package:myapp/app/widgets/custom_nav_bar.dart';
import 'package:myapp/app/widgets/gradient_button.dart';
import 'package:myapp/controllers/finance_controller.dart';
import 'package:myapp/common/localization/l10n_extensions.dart';
import 'package:myapp/widgets/section_hero_header.dart';

class FinanceScreen extends StatelessWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceController>();
    final isMobile = MediaQuery.of(context).size.width < 600;
    final loc = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.background,
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
                    SectionHeroHeader(
                      title: loc.navFinance,
                      actionTooltip: loc.financeNewQuoteTooltip,
                      onActionTap: () => context.push('/finance/create-quote'),
                    ),
                    const SizedBox(height: 24),
                    _BalanceCard(
                      balance: finance.globalBalance,
                      variation: finance.monthVariationPercent,
                      isMobile: isMobile,
                      trend: finance.trendValues,
                    ),
                    const SizedBox(height: 18),
                    _UnpaidInvoicesCard(
                      unpaidCount: finance.unpaidCount,
                      unpaidTotal: finance.unpaidTotal,
                    ),
                    const SizedBox(height: 24),
                    _MetricsGrid(
                      quotes: finance.quotes,
                      invoices: finance.invoices,
                    ),
                    const SizedBox(height: 24),
                    _LatestDocumentsList(docs: finance.latestDocuments),
                    const SizedBox(height: 32),
                    _UpcomingDueInvoicesCard(invoices: finance.invoices),
                    const SizedBox(height: 32),
                    _RecentActivityCard(
                      quotes: finance.quotes,
                      invoices: finance.invoices,
                    ),
                    const SizedBox(height: 32),
                    Center(
                      child: GradientButton(
                        onPressed: () => context.push('/finance/create-quote'),
                        text: loc.financePrimaryCta,
                        height: 56,
                        width: double.infinity,
                      ),
                    ),
                    const SizedBox(height: 32),
                    _QuickAccessCard(),
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
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({
    required this.balance,
    required this.variation,
    required this.isMobile,
    required this.trend,
  });
  final double balance;
  final double variation;
  final bool isMobile;
  final List<double> trend;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = context.l10n;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: AppColors.textfieldBorder.withValues(alpha: 0.5),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 22,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.financeBalanceTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppColors.secondaryText,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '€${balance.toStringAsFixed(2)}',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: AppColors.secondaryText,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              _VariationBadge(variation: variation),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 80,
            child: CustomPaint(
              painter: _TrendPainter(values: trend),
              child: Container(),
            ),
          ),
        ],
      ),
    );
  }
}

class _VariationBadge extends StatelessWidget {
  const _VariationBadge({required this.variation});
  final double variation;
  @override
  Widget build(BuildContext context) {
    final positive = variation >= 0;
    final color = positive ? Color(0xFF2FBF71) : Color(0xFFE55454);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            positive ? FeatherIcons.trendingUp : FeatherIcons.trendingDown,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            '${positive ? '+' : ''}${variation.toStringAsFixed(1)}%',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendPainter extends CustomPainter {
  const _TrendPainter({required this.values});
  final List<double> values;
  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final maxVal = values.reduce((a, b) => a > b ? a : b);
    final minVal = values.reduce((a, b) => a < b ? a : b);
    final range = (maxVal - minVal).clamp(1, double.infinity);
    final path = Path();
    final stepX = size.width / (values.length - 1);
    for (int i = 0; i < values.length; i++) {
      final normY = (values[i] - minVal) / range;
      final y = size.height - (normY * size.height);
      final x = i * stepX;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeJoin = StrokeJoin.round
      ..color = AppColors.secondary;
    canvas.drawPath(path, paint);
    final dotPaint = Paint()..color = AppColors.secondary;
    for (int i = 0; i < values.length; i++) {
      final normY = (values[i] - minVal) / range;
      final y = size.height - (normY * size.height);
      final x = i * stepX;
      canvas.drawCircle(Offset(x, y), 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _TrendPainter old) => old.values != values;
}

class _UnpaidInvoicesCard extends StatelessWidget {
  const _UnpaidInvoicesCard({
    required this.unpaidCount,
    required this.unpaidTotal,
  });
  final int unpaidCount;
  final double unpaidTotal;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = context.l10n;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: AppColors.textfieldBorder.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.financeUnpaidTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.secondaryText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  loc.financeUnpaidMeta(
                    unpaidCount,
                    '€${unpaidTotal.toStringAsFixed(2)}',
                  ),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.hintTextfiled,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.secondary, width: 2),
              minimumSize: const Size(140, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: Text(
              loc.financeUnpaidReminderCta,
              style: theme.textTheme.labelLarge?.copyWith(
                color: AppColors.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LatestDocumentsList extends StatelessWidget {
  const _LatestDocumentsList({required this.docs});
  final List<String> docs;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = context.l10n;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
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
            loc.financeLatestDocumentsTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.secondaryText,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          ...docs.map(
            (d) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  const Icon(
                    FeatherIcons.fileText,
                    size: 16,
                    color: AppColors.hintTextfiled,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      d,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.secondaryText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAccessCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = context.l10n;
    return Container(
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
            loc.financeQuickAccessTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.secondaryText,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _QuickLinkButton(
                label: loc.financeQuickAccessCreateQuote,
                route: '/finance/create-quote',
              ),
              _QuickLinkButton(
                label: loc.financeQuickAccessReporting,
                route: '/finance/reporting',
              ),
              _QuickLinkButton(
                label: loc.financeQuickAccessPreview,
                route: '/finance/quote/temp/preview',
              ),
              _QuickLinkButton(
                label: loc.financeQuickAccessSignature,
                route: '/finance/quote/temp/signature',
              ),
              _QuickLinkButton(
                label: loc.financeQuickAccessInvoice,
                route: '/finance/invoice/temp',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  final List<dynamic>
  quotes; // dynamic to avoid import duplication; cast where needed
  final List<dynamic> invoices;
  const _MetricsGrid({required this.quotes, required this.invoices});
  @override
  Widget build(BuildContext context) {
    final loc = context.l10n;
    // Compute counts
    int drafts = quotes
        .where((q) => q.status.toString().contains('draft'))
        .length;
    int pending = quotes
        .where((q) => q.status.toString().contains('pendingSignature'))
        .length;
    int signed = quotes
        .where((q) => q.status.toString().contains('signed'))
        .length;
    int declined = quotes
        .where((q) => q.status.toString().contains('declined'))
        .length;
    int unpaid = invoices
        .where((i) => i.status.toString().contains('unpaid'))
        .length;
    int paid = invoices
        .where((i) => i.status.toString().contains('paid'))
        .length;
    final theme = Theme.of(context);
    final List<Map<String, Object>> items = [
      {
        'label': loc.financeMetricDraftQuotes,
        'value': drafts,
        'color': AppColors.hintTextfiled,
      },
      {
        'label': loc.financeMetricPendingSignatures,
        'value': pending,
        'color': const Color(0xFF2FBF71),
      },
      {
        'label': loc.financeMetricSignedQuotes,
        'value': signed,
        'color': AppColors.secondary,
      },
      {
        'label': loc.financeMetricDeclinedQuotes,
        'value': declined,
        'color': const Color(0xFFE55454),
      },
      {
        'label': loc.financeMetricUnpaidInvoices,
        'value': unpaid,
        'color': const Color(0xFFE55454),
      },
      {
        'label': loc.financeMetricPaidInvoices,
        'value': paid,
        'color': AppColors.secondary,
      },
    ];
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
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
            loc.financePipelineTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.secondaryText,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              for (final item in items)
                _MetricTile(
                  label: item['label'] as String,
                  value: item['value'] as int,
                  color: item['color'] as Color,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _MetricTile({
    required this.label,
    required this.value,
    required this.color,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 150,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.textfieldBorder.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.hintTextfiled,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '$value',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.secondaryText,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UpcomingDueInvoicesCard extends StatelessWidget {
  final List<dynamic> invoices;
  const _UpcomingDueInvoicesCard({required this.invoices});
  @override
  Widget build(BuildContext context) {
    final loc = context.l10n;
    final upcoming =
        invoices
            .where(
              (i) =>
                  i.dueDate != null && i.status.toString().contains('unpaid'),
            )
            .toList()
          ..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));
    final sliced = upcoming.take(4).toList();
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
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
            loc.financeUpcomingTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.secondaryText,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (sliced.isEmpty)
            Text(
              loc.financeUpcomingEmpty,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.hintTextfiled,
                fontWeight: FontWeight.w600,
              ),
            )
          else
            ...sliced.map((inv) {
              final daysDiff = DateTime.now().difference(inv.dueDate!).inDays;
              final overdue = daysDiff > 0;
              final dueSoon = !overdue && daysDiff < 0 && daysDiff >= -3;
              final isDueToday = daysDiff == 0;
              final badgeColor = overdue
                  ? const Color(0xFFE55454)
                  : (isDueToday
                        ? const Color(0xFFE55454)
                        : (dueSoon
                              ? const Color(0xFFFFA331)
                              : const Color(0xFF2FBF71)));
              final label = overdue
                  ? loc.financeUpcomingBadgeOverdue(daysDiff)
                  : (isDueToday
                        ? loc.financeUpcomingBadgeDueToday
                        : (dueSoon
                              ? loc.financeUpcomingBadgeDueSoon
                              : loc.financeUpcomingBadgeDueIn(-daysDiff)));
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        loc.financeUpcomingInvoiceLabel(
                          inv.id.substring(3),
                          '€${inv.amount.toStringAsFixed(2)}',
                        ),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.secondaryText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    _StatusBadge(label: label, color: badgeColor),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusBadge({required this.label, required this.color});
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

class _RecentActivityCard extends StatelessWidget {
  final List<dynamic> quotes;
  final List<dynamic> invoices;
  const _RecentActivityCard({required this.quotes, required this.invoices});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = context.l10n;
    final items = <String>[];
    items.addAll(
      quotes
          .take(3)
          .map(
            (q) => loc.financeRecentQuote(
              q.id,
              q.status.toString().split('.').last,
            ),
          ),
    );
    items.addAll(
      invoices
          .take(3)
          .map(
            (i) => loc.financeRecentInvoice(
              i.id,
              i.status.toString().split('.').last,
            ),
          ),
    );
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
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
            loc.financeRecentTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.secondaryText,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          ...items.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  const Icon(
                    FeatherIcons.activity,
                    size: 16,
                    color: AppColors.hintTextfiled,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      e,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.secondaryText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (items.isEmpty)
            Text(
              loc.financeRecentEmpty,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.hintTextfiled,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}

class _QuickLinkButton extends StatelessWidget {
  final String label;
  final String route;
  const _QuickLinkButton({required this.label, required this.route});
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () => context.push(route),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.secondary, width: 2),
        minimumSize: const Size(140, 44),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: AppColors.secondary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
