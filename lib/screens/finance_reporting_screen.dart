import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:myapp/app/app_theme.dart';
import 'package:myapp/app/widgets/gradient_button.dart';
import 'package:myapp/common/localization/formatters.dart';
import 'package:myapp/common/localization/l10n_extensions.dart';
import 'package:myapp/controllers/finance_controller.dart';
import 'package:myapp/l10n/app_localizations.dart';
import 'package:myapp/models/finance.dart';

class FinanceReportingScreen extends StatefulWidget {
  const FinanceReportingScreen({super.key});

  @override
  State<FinanceReportingScreen> createState() => _FinanceReportingScreenState();
}

class _FinanceReportingScreenState extends State<FinanceReportingScreen> {
  _ReportRange _range = _ReportRange.last30Days;
  _ReportGranularity _granularity = _ReportGranularity.monthly;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = context.l10n;
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;
    final finance = context.watch<FinanceController>();

    final now = DateTime.now();
    final start = _rangeStart(_range);
    final invoicesInRange = _filterInvoices(finance.invoices, start, now);
    final paidInvoices = invoicesInRange
        .where((invoice) => invoice.status == InvoiceStatus.paid)
        .toList(growable: false);
    final unpaidInvoices = invoicesInRange
        .where((invoice) => invoice.status == InvoiceStatus.unpaid)
        .toList(growable: false);
    final upcomingInvoices = _sortUpcoming(unpaidInvoices);
    final revenueTotal = paidInvoices.fold<double>(
      0,
      (sum, invoice) => sum + invoice.amount,
    );
    final outstandingTotal = unpaidInvoices.fold<double>(
      0,
      (sum, invoice) => sum + invoice.amount,
    );
    final revenueBuckets = _buildRevenueBuckets(
      paidInvoices: paidInvoices,
      start: start,
      end: now,
      granularity: _granularity,
    );
    final quotesInRange = _filterQuotes(finance.quotes, start, now);
    final signedQuotes = quotesInRange
        .where((quote) => quote.status == QuoteStatus.signed)
        .length;
    final draftQuotes = quotesInRange
        .where((quote) => quote.status == QuoteStatus.draft)
        .length;
    final pendingQuotes = quotesInRange
        .where((quote) => quote.status == QuoteStatus.pendingSignature)
        .length;
    final declinedQuotes = quotesInRange
        .where((quote) => quote.status == QuoteStatus.declined)
        .length;
    final double conversionRate = quotesInRange.isEmpty
        ? 0.0
        : (signedQuotes / quotesInRange.length) * 100.0;
    final topClients = _buildTopClients(invoicesInRange, loc);

    final cards = [
      _ReportCard(
        title: loc.financeReportingCardRevenue,
        child: _RevenueCardContent(
          total: revenueTotal,
          buckets: revenueBuckets,
          granularity: _granularity,
          paidInvoiceCount: paidInvoices.length,
          loc: loc,
        ),
      ),
      _ReportCard(
        title: loc.financeReportingCardOutstanding,
        child: _OutstandingCardContent(
          totalOutstanding: outstandingTotal,
          unpaidInvoices: unpaidInvoices,
          upcomingInvoices: upcomingInvoices,
          loc: loc,
        ),
      ),
      _ReportCard(
        title: loc.financeReportingCardConversion,
        child: _ConversionCardContent(
          conversionRate: conversionRate,
          signedQuotes: signedQuotes,
          draftQuotes: draftQuotes,
          pendingQuotes: pendingQuotes,
          declinedQuotes: declinedQuotes,
          totalQuotes: quotesInRange.length,
          loc: loc,
        ),
      ),
      _ReportCard(
        title: loc.financeReportingCardTopClients,
        child: _TopClientsCardContent(topClients: topClients),
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          loc.financeReportingTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            color: AppColors.secondaryText,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(
          isMobile ? 16.0 : 24.0,
          24.0,
          isMobile ? 16.0 : 24.0,
          32.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FilterBar(
              range: _range,
              granularity: _granularity,
              onRangeChanged: (value) {
                if (value == _range) return;
                setState(() => _range = value);
              },
              onGranularityChanged: (value) {
                if (value == _granularity) return;
                setState(() => _granularity = value);
              },
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: width < 950 ? 1 : 2,
                crossAxisSpacing: 18,
                mainAxisSpacing: 18,
                childAspectRatio: 1.55,
                children: cards,
              ),
            ),
            const SizedBox(height: 24),
            GradientButton(
              onPressed: () => _handleExport(invoicesInRange),
              text: loc.financeReportingExportCta,
              height: 56,
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleExport(List<Invoice> invoices) async {
    try {
      final csv = _buildInvoicesCsv(invoices);
      await Clipboard.setData(ClipboardData(text: csv));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exported CSV copied to clipboard')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to export: $e')));
    }
  }

  String _buildInvoicesCsv(List<Invoice> invoices) {
    final sb = StringBuffer();
    final locale = Localizations.localeOf(context).toString();
    final df = DateFormat.yMMMd(locale);
    sb.writeln('ID,Client,Amount,Status,IssuedAt,DueDate');
    for (final inv in invoices) {
      final client = inv.clientName.replaceAll(',', ' ');
      final amount = inv.amount.toStringAsFixed(2);
      final status = inv.status.toString().split('.').last;
      final issued = df.format(inv.issuedAt);
      final due = inv.dueDate != null ? df.format(inv.dueDate!) : '';
      sb.writeln('${inv.id},$client,$amount,$status,$issued,$due');
    }
    return sb.toString();
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({required this.title, required this.child});

  final String title;
  final Widget child;

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
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.secondaryText,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

enum _ReportRange { last7Days, last30Days, quarterToDate, yearToDate }

enum _ReportGranularity { daily, weekly, monthly }

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.range,
    required this.granularity,
    required this.onRangeChanged,
    required this.onGranularityChanged,
  });

  final _ReportRange range;
  final _ReportGranularity granularity;
  final ValueChanged<_ReportRange> onRangeChanged;
  final ValueChanged<_ReportGranularity> onGranularityChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = context.l10n;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
            loc.financeReportingFiltersTitle,
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
              _ChipSelect<_ReportRange>(
                heading: loc.financeReportingFilterRange,
                value: range,
                options: const [
                  _ReportRange.last7Days,
                  _ReportRange.last30Days,
                  _ReportRange.quarterToDate,
                  _ReportRange.yearToDate,
                ],
                labelBuilder: (ctx, option) {
                  final l = ctx.l10n;
                  return switch (option) {
                    _ReportRange.last7Days => l.financeReportingRange7Days,
                    _ReportRange.last30Days => l.financeReportingRange30Days,
                    _ReportRange.quarterToDate =>
                      l.financeReportingRangeQuarter,
                    _ReportRange.yearToDate => l.financeReportingRangeYear,
                  };
                },
                onChanged: onRangeChanged,
              ),
              _ChipSelect<_ReportGranularity>(
                heading: loc.financeReportingFilterGranularity,
                value: granularity,
                options: const [
                  _ReportGranularity.daily,
                  _ReportGranularity.weekly,
                  _ReportGranularity.monthly,
                ],
                labelBuilder: (ctx, option) {
                  final l = ctx.l10n;
                  return switch (option) {
                    _ReportGranularity.daily =>
                      l.financeReportingGranularityDaily,
                    _ReportGranularity.weekly =>
                      l.financeReportingGranularityWeekly,
                    _ReportGranularity.monthly =>
                      l.financeReportingGranularityMonthly,
                  };
                },
                onChanged: onGranularityChanged,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChipSelect<T> extends StatelessWidget {
  const _ChipSelect({
    required this.heading,
    required this.value,
    required this.options,
    required this.onChanged,
    required this.labelBuilder,
  });

  final String heading;
  final T value;
  final List<T> options;
  final ValueChanged<T> onChanged;
  final String Function(BuildContext, T) labelBuilder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          heading,
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
            for (final option in options)
              _ReportChip(
                label: labelBuilder(context, option),
                selected: option == value,
                onTap: () => onChanged(option),
              ),
          ],
        ),
      ],
    );
  }
}

class _ReportChip extends StatelessWidget {
  const _ReportChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

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

class _RevenueCardContent extends StatelessWidget {
  const _RevenueCardContent({
    required this.total,
    required this.buckets,
    required this.granularity,
    required this.paidInvoiceCount,
    required this.loc,
  });

  final double total;
  final List<_RevenueBucket> buckets;
  final _ReportGranularity granularity;
  final int paidInvoiceCount;
  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final values = buckets.map((bucket) => bucket.value).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          formatCurrency(context, total),
          style: theme.textTheme.headlineSmall?.copyWith(
            color: AppColors.secondaryText,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        _MetricChip(
          label: loc.financeMetricPaidInvoices,
          value: '$paidInvoiceCount',
        ),
        const SizedBox(height: 12),
        Container(
          height: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.textfieldBorder.withValues(alpha: 0.3),
            ),
          ),
          alignment: Alignment.center,
          child: values.isEmpty
              ? Text(
                  loc.financeReportingChartPlaceholder,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.hintTextfiled,
                    fontWeight: FontWeight.w600,
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: _TrendChart(values: values),
                ),
        ),
        const SizedBox(height: 8),
        Text(
          '${values.length} ${_granularityLabel(loc, granularity)}',
          style: theme.textTheme.labelSmall?.copyWith(
            color: AppColors.hintTextfiled,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _OutstandingCardContent extends StatelessWidget {
  const _OutstandingCardContent({
    required this.totalOutstanding,
    required this.unpaidInvoices,
    required this.upcomingInvoices,
    required this.loc,
  });

  final double totalOutstanding;
  final List<Invoice> unpaidInvoices;
  final List<Invoice> upcomingInvoices;
  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          formatCurrency(context, totalOutstanding),
          style: theme.textTheme.headlineSmall?.copyWith(
            color: AppColors.secondaryText,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        _MetricChip(
          label: loc.financeMetricUnpaidInvoices,
          value: '${unpaidInvoices.length}',
        ),
        const SizedBox(height: 12),
        if (upcomingInvoices.isEmpty)
          Text(
            loc.financeUpcomingEmpty,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.hintTextfiled,
              fontWeight: FontWeight.w600,
            ),
          )
        else
          ...upcomingInvoices
              .take(3)
              .map((invoice) => _OutstandingInvoiceRow(invoice: invoice)),
      ],
    );
  }
}

class _ConversionCardContent extends StatelessWidget {
  const _ConversionCardContent({
    required this.conversionRate,
    required this.signedQuotes,
    required this.draftQuotes,
    required this.pendingQuotes,
    required this.declinedQuotes,
    required this.totalQuotes,
    required this.loc,
  });

  final double conversionRate;
  final int signedQuotes;
  final int draftQuotes;
  final int pendingQuotes;
  final int declinedQuotes;
  final int totalQuotes;
  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double normalized = conversionRate.clamp(0, 100).toDouble() / 100;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${conversionRate.toStringAsFixed(0)}%',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: AppColors.secondaryText,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${loc.financeReportingCardConversion} • $totalQuotes',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.hintTextfiled,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: normalized.isNaN ? 0 : normalized,
            minHeight: 8,
            backgroundColor: AppColors.textfieldBackground,
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppColors.secondary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _MetricChip(
              label: loc.financeMetricSignedQuotes,
              value: '$signedQuotes',
            ),
            _MetricChip(
              label: loc.financeMetricPendingSignatures,
              value: '$pendingQuotes',
            ),
            _MetricChip(
              label: loc.financeMetricDeclinedQuotes,
              value: '$declinedQuotes',
            ),
            _MetricChip(
              label: loc.financeMetricDraftQuotes,
              value: '$draftQuotes',
            ),
          ],
        ),
      ],
    );
  }
}

class _TopClientsCardContent extends StatelessWidget {
  const _TopClientsCardContent({required this.topClients});

  final List<_ClientRevenue> topClients;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (topClients.isEmpty) {
      return Text(
        context.l10n.financeReportingChartPlaceholder,
        style: theme.textTheme.bodySmall?.copyWith(
          color: AppColors.hintTextfiled,
          fontWeight: FontWeight.w600,
        ),
      );
    }
    return Column(
      children: topClients
          .take(4)
          .map((client) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: _ClientRevenueRow(client: client),
            );
          })
          .toList(growable: false),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.textfieldBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.hintTextfiled,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.secondaryText,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendChart extends StatelessWidget {
  const _TrendChart({required this.values});

  final List<double> values;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _TrendPainter(values: values),
      size: const Size(double.infinity, double.infinity),
    );
  }
}

class _TrendPainter extends CustomPainter {
  const _TrendPainter({required this.values});

  final List<double> values;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final double maxValue = values.reduce(math.max).clamp(1, double.infinity);
    final path = Path();
    for (int i = 0; i < values.length; i++) {
      final double x = values.length == 1
          ? size.width
          : (i / (values.length - 1)) * size.width;
      final double normalized = values[i] / maxValue;
      final double y = size.height - (normalized * size.height);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final stroke = Paint()
      ..color = AppColors.secondary
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, stroke);

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    final fill = Paint()
      ..shader = LinearGradient(
        colors: [
          AppColors.secondary.withValues(alpha: 0.18),
          AppColors.secondary.withValues(alpha: 0.02),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fillPath, fill);
  }

  @override
  bool shouldRepaint(covariant _TrendPainter oldDelegate) {
    return oldDelegate.values.length != values.length ||
        !listEquals(oldDelegate.values, values);
  }
}

class _OutstandingInvoiceRow extends StatelessWidget {
  const _OutstandingInvoiceRow({required this.invoice});

  final Invoice invoice;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = context.l10n;
    final due = invoice.dueDate;
    final dueLabel = due == null
        ? loc.financeUpcomingNoDueDate
        : DateFormat.yMMMd(loc.localeName).format(due);
    final dueDelta = due?.difference(
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
    );
    final daysDiff = dueDelta?.inDays;
    final badge = _invoiceBadgeLabel(loc, daysDiff);
    final badgeColor = (daysDiff != null && daysDiff < 0)
        ? AppColors.error
        : AppColors.orange;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.financeInvoiceTitle(_invoiceNumber(invoice.id)),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.secondaryText,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                dueLabel,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.hintTextfiled,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                badge,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: badgeColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              formatCurrency(context, invoice.amount),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.secondaryText,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ClientRevenueRow extends StatelessWidget {
  const _ClientRevenueRow({required this.client});

  final _ClientRevenue client;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            client.name,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.secondaryText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          formatCurrency(context, client.total),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.secondaryText,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _RevenueBucket {
  const _RevenueBucket({required this.start, required this.value});

  final DateTime start;
  final double value;
}

class _ClientRevenue {
  const _ClientRevenue({required this.name, required this.total});

  final String name;
  final double total;
}

List<Invoice> _filterInvoices(
  List<Invoice> invoices,
  DateTime start,
  DateTime end,
) {
  return invoices
      .where(
        (invoice) =>
            !invoice.issuedAt.isBefore(start) && !invoice.issuedAt.isAfter(end),
      )
      .toList(growable: false);
}

List<Quote> _filterQuotes(List<Quote> quotes, DateTime start, DateTime end) {
  return quotes
      .where(
        (quote) =>
            !quote.createdAt.isBefore(start) && !quote.createdAt.isAfter(end),
      )
      .toList(growable: false);
}

List<_RevenueBucket> _buildRevenueBuckets({
  required List<Invoice> paidInvoices,
  required DateTime start,
  required DateTime end,
  required _ReportGranularity granularity,
}) {
  final buckets = <_RevenueBucket>[];
  var bucketStart = _alignToGranularity(start, granularity);
  while (!bucketStart.isAfter(end)) {
    final bucketEnd = _advanceBucket(bucketStart, granularity);
    final value = paidInvoices
        .where(
          (invoice) =>
              !invoice.issuedAt.isBefore(bucketStart) &&
              invoice.issuedAt.isBefore(bucketEnd),
        )
        .fold<double>(0, (sum, invoice) => sum + invoice.amount);
    buckets.add(_RevenueBucket(start: bucketStart, value: value));
    bucketStart = bucketEnd;
  }
  return buckets;
}

DateTime _rangeStart(_ReportRange range) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  switch (range) {
    case _ReportRange.last7Days:
      return today.subtract(const Duration(days: 7));
    case _ReportRange.last30Days:
      return today.subtract(const Duration(days: 30));
    case _ReportRange.quarterToDate:
      final quarter = ((today.month - 1) ~/ 3) * 3 + 1;
      return DateTime(today.year, quarter, 1);
    case _ReportRange.yearToDate:
      return DateTime(today.year, 1, 1);
  }
}

DateTime _alignToGranularity(DateTime date, _ReportGranularity granularity) {
  switch (granularity) {
    case _ReportGranularity.daily:
      return DateTime(date.year, date.month, date.day);
    case _ReportGranularity.weekly:
      final normalized = DateTime(date.year, date.month, date.day);
      return normalized;
    case _ReportGranularity.monthly:
      return DateTime(date.year, date.month, 1);
  }
}

DateTime _advanceBucket(DateTime start, _ReportGranularity granularity) {
  switch (granularity) {
    case _ReportGranularity.daily:
      return start.add(const Duration(days: 1));
    case _ReportGranularity.weekly:
      return start.add(const Duration(days: 7));
    case _ReportGranularity.monthly:
      return DateTime(start.year, start.month + 1, 1);
  }
}

List<Invoice> _sortUpcoming(List<Invoice> invoices) {
  final withDueDate = invoices.where((inv) => inv.dueDate != null).toList();
  withDueDate.sort((a, b) => a.dueDate!.compareTo(b.dueDate!));
  return withDueDate;
}

List<_ClientRevenue> _buildTopClients(
  List<Invoice> invoices,
  AppLocalizations loc,
) {
  final totals = <String, double>{};
  for (final invoice in invoices) {
    final key = invoice.clientName.isEmpty
        ? loc.financeInvoiceUnknownClient
        : invoice.clientName;
    totals[key] = (totals[key] ?? 0) + invoice.amount;
  }
  final entries = totals.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  return entries
      .map((entry) => _ClientRevenue(name: entry.key, total: entry.value))
      .toList(growable: false);
}

String _granularityLabel(AppLocalizations loc, _ReportGranularity granularity) {
  return switch (granularity) {
    _ReportGranularity.daily => loc.financeReportingGranularityDaily,
    _ReportGranularity.weekly => loc.financeReportingGranularityWeekly,
    _ReportGranularity.monthly => loc.financeReportingGranularityMonthly,
  };
}

String _invoiceBadgeLabel(AppLocalizations loc, int? daysDiff) {
  if (daysDiff == null) {
    return loc.financeUpcomingNoDueDate;
  }
  if (daysDiff < 0) {
    return loc.financeUpcomingBadgeOverdue(daysDiff.abs());
  }
  if (daysDiff == 0) {
    return loc.financeUpcomingBadgeDueToday;
  }
  if (daysDiff <= 3) {
    return loc.financeUpcomingBadgeDueSoon;
  }
  return loc.financeUpcomingBadgeDueIn(daysDiff);
}

String _invoiceNumber(String id) {
  final match = RegExp(r'(\d+)').firstMatch(id);
  if (match != null) {
    return match.group(0)!;
  }
  return id;
}
