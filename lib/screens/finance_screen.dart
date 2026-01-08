import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:myapp/app/app_theme.dart';
import 'package:myapp/app/widgets/custom_nav_bar.dart';
import 'package:myapp/common/localization/l10n_extensions.dart';
import 'package:myapp/controllers/finance_controller.dart';
import 'package:myapp/l10n/app_localizations.dart';
import 'package:myapp/models/finance.dart';
import 'package:myapp/widgets/section_hero_header.dart';

const _primaryActionGradient = LinearGradient(
  colors: [AppColors.secondary, AppColors.primary],
  begin: AlignmentDirectional(1.0, 0.34),
  end: AlignmentDirectional(-1.0, -0.34),
);

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  TimeFilter _balanceFilter = TimeFilter.month;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      context.read<FinanceController>().initialize();
    });
  }

  void _openQuickActionsSheet() {
    final loc = context.l10n;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.secondaryBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) => _QuickActionsSheet(
        title: loc.financeQuickActionsTitle,
        actions: [
          _QuickActionData(
            icon: FeatherIcons.filePlus,
            label: loc.financeQuickActionCreateQuote,
            action: _FinanceQuickAction.createQuote,
          ),
          _QuickActionData(
            icon: FeatherIcons.fileText,
            label: loc.financeQuickActionCreateInvoice,
            action: _FinanceQuickAction.createInvoice,
          ),
          _QuickActionData(
            icon: FeatherIcons.trendingDown,
            label: loc.financeQuickActionAddExpense,
            action: _FinanceQuickAction.addExpense,
          ),
          _QuickActionData(
            icon: FeatherIcons.trendingUp,
            label: loc.financeQuickActionAddPayment,
            action: _FinanceQuickAction.addPayment,
          ),
        ],
        onTap: (action) {
          Navigator.of(sheetContext).pop();
          _handleQuickAction(action);
        },
      ),
    );
  }

  void _handleQuickAction(_FinanceQuickAction action) {
    switch (action) {
      case _FinanceQuickAction.createQuote:
        context.push('/finance/create-quote');
        break;
      case _FinanceQuickAction.createInvoice:
        context.push('/finance/create-invoice');
        break;
      case _FinanceQuickAction.addExpense:
        context.push('/finance/expenses');
        break;
      case _FinanceQuickAction.addPayment:
        context.push('/finance/add-payment');
        break;
    }
  }

  void _openInvoicesList() => context.push('/finance/invoices');

  void _openExpensesList() => context.push('/finance/expenses');

  String _formatCurrency(double value) => '€${value.toStringAsFixed(2)}';

  String _formatRelativeTime(DateTime date, AppLocalizations loc) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return loc.relativeTimeJustNow;
    if (diff.inMinutes < 60) {
      return loc.relativeTimeMinutes(diff.inMinutes);
    }
    if (diff.inHours < 24) {
      return loc.relativeTimeHours(diff.inHours);
    }
    return loc.relativeTimeDays(diff.inDays);
  }

  String _quoteStatusLabel(AppLocalizations loc, QuoteStatus status) {
    switch (status) {
      case QuoteStatus.draft:
        return loc.financeQuoteStatusDraft;
      case QuoteStatus.pendingSignature:
        return loc.financeQuoteStatusPending;
      case QuoteStatus.signed:
        return loc.financeQuoteStatusSigned;
      case QuoteStatus.declined:
        return loc.financeQuoteStatusDeclined;
    }
  }

  String _invoiceStatusLabel(AppLocalizations loc, InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.draft:
        return loc.financeInvoiceStatusDraft;
      case InvoiceStatus.unpaid:
        return loc.financeInvoiceStatusUnpaid;
      case InvoiceStatus.paid:
        return loc.financeInvoiceStatusPaid;
    }
  }

  List<_RecentEvent> _buildRecentEvents(
    FinanceController finance,
    AppLocalizations loc,
  ) {
    final events = <_RecentEvent>[];

    for (final quote in finance.quotes) {
      events.add(
        _RecentEvent(
          type: _RecentEventType.quote,
          title: loc.financeRecentQuote(
            quote.id,
            _quoteStatusLabel(loc, quote.status),
          ),
          timestamp: quote.createdAt,
        ),
      );
    }

    for (final invoice in finance.invoices) {
      events.add(
        _RecentEvent(
          type: _RecentEventType.invoice,
          title: loc.financeRecentInvoice(
            invoice.id,
            _invoiceStatusLabel(loc, invoice.status),
          ),
          timestamp: invoice.issuedAt,
        ),
      );

      if (invoice.status == InvoiceStatus.paid) {
        events.add(
          _RecentEvent(
            type: _RecentEventType.payment,
            title: loc.financeRecentPayment(
              invoice.id,
              _formatCurrency(invoice.amount),
            ),
            timestamp: invoice.issuedAt,
          ),
        );
      }
    }

    for (final expense in finance.expenses) {
      events.add(
        _RecentEvent(
          type: _RecentEventType.expense,
          title: loc.financeRecentExpense(
            expense.description,
            _formatCurrency(expense.amount),
          ),
          timestamp: expense.date,
        ),
      );
    }

    events.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return events.take(4).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceController>();
    final loc = context.l10n;

    final balance = finance.collectedTotalFor(_balanceFilter);
    final variation = finance.variationPercentFor(_balanceFilter);
    final trend = finance.revenueTrendFor(_balanceFilter);
    final upcomingInvoices = finance.upcomingInvoices.take(4).toList();
    final recentEvents = _buildRecentEvents(finance, loc);
    final topExpense = finance.topExpenseThisMonth;

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
                      onActionTap: _openQuickActionsSheet,
                    ),
                    const SizedBox(height: 24),
                    _BalanceCard(
                      balance: balance,
                      variation: variation,
                      trend: trend,
                      selectedFilter: _balanceFilter,
                      onFilterChanged: (filter) => setState(() {
                        _balanceFilter = filter;
                      }),
                    ),
                    const SizedBox(height: 20),
                    _UnpaidInvoicesCard(
                      unpaidCount: finance.unpaidCount,
                      unpaidTotal: finance.unpaidTotal,
                      onSendReminder: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(loc.financeReminderSentSnack)),
                        );
                      },
                      onViewList: _openInvoicesList,
                    ),
                    const SizedBox(height: 20),
                    _UpcomingInvoicesCard(
                      invoices: upcomingInvoices,
                      onSeeAll: _openInvoicesList,
                    ),
                    const SizedBox(height: 20),
                    _ExpensesCard(
                      totalLabel: _formatCurrency(
                        finance.currentMonthExpensesTotal,
                      ),
                      topExpense: topExpense,
                      onViewExpenses: _openExpensesList,
                    ),
                    const SizedBox(height: 20),
                    _RecentActivityCard(
                      events: recentEvents,
                      relativeTimeBuilder: (date) =>
                          _formatRelativeTime(date, loc),
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
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({
    required this.balance,
    required this.variation,
    required this.trend,
    required this.selectedFilter,
    required this.onFilterChanged,
  });
  final double balance;
  final double variation;
  final List<double> trend;
  final TimeFilter selectedFilter;
  final ValueChanged<TimeFilter> onFilterChanged;
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
            crossAxisAlignment: CrossAxisAlignment.start,
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
                    const SizedBox(height: 6),
                    Text(
                      loc.financeBalanceVariationLabel(
                        variation.toStringAsFixed(1),
                        selectedFilter == TimeFilter.year
                            ? loc.financePeriodYear
                            : loc.financePeriodMonth,
                      ),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.hintTextfiled,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              _BalanceFilterToggle(
                selectedFilter: selectedFilter,
                onChanged: onFilterChanged,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _VariationBadge(variation: variation),
          const SizedBox(height: 18),
          SizedBox(
            height: 120,
            width: double.infinity,
            child: CustomPaint(painter: _TrendPainter(values: trend)),
          ),
        ],
      ),
    );
  }
}

class _BalanceFilterToggle extends StatelessWidget {
  const _BalanceFilterToggle({
    required this.selectedFilter,
    required this.onChanged,
  });

  final TimeFilter selectedFilter;
  final ValueChanged<TimeFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    final loc = context.l10n;
    final options = [
      _BalanceToggleOption(
        label: loc.financeBalanceToggleMonth,
        filter: TimeFilter.month,
      ),
      _BalanceToggleOption(
        label: loc.financeBalanceToggleYear,
        filter: TimeFilter.year,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.textfieldBorder.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: options.map((option) {
          final isSelected = option.filter == selectedFilter;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: GestureDetector(
              onTap: () => onChanged(option.filter),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.secondary : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  option.label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: isSelected
                        ? AppColors.primaryText
                        : AppColors.secondaryText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _BalanceToggleOption {
  const _BalanceToggleOption({required this.label, required this.filter});
  final String label;
  final TimeFilter filter;
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
    final stepX = values.length == 1 ? 0.0 : size.width / (values.length - 1);
    final points = <Offset>[];
    for (int i = 0; i < values.length; i++) {
      final normY = (values[i] - minVal) / range;
      final y = size.height - (normY * size.height);
      final x = values.length == 1 ? size.width / 2 : i * stepX;
      points.add(Offset(x, y));
    }

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..color = AppColors.secondary;

    if (points.length == 1) {
      final single = points.first;
      canvas.drawLine(
        Offset(0, single.dy),
        Offset(size.width, single.dy),
        paint,
      );
      return;
    }

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TrendPainter old) => old.values != values;
}

class _GradientActionButton extends StatelessWidget {
  const _GradientActionButton({
    required this.label,
    required this.onPressed,
    this.borderRadius = 26,
  });

  final String label;
  final VoidCallback onPressed;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
      color: AppColors.primaryText,
      fontWeight: FontWeight.bold,
    );
    return SizedBox(
      height: 48,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: _primaryActionGradient,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(borderRadius),
            onTap: onPressed,
            child: Center(child: Text(label, style: textStyle)),
          ),
        ),
      ),
    );
  }
}

class _UnpaidInvoicesCard extends StatelessWidget {
  const _UnpaidInvoicesCard({
    required this.unpaidCount,
    required this.unpaidTotal,
    required this.onSendReminder,
    required this.onViewList,
  });

  final int unpaidCount;
  final double unpaidTotal;
  final VoidCallback onSendReminder;
  final VoidCallback onViewList;

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
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _GradientActionButton(
                  label: loc.financeUnpaidReminderCta,
                  onPressed: onSendReminder,
                  borderRadius: 24,
                ),
              ),
              TextButton(
                onPressed: onViewList,
                child: Text(
                  loc.financeUnpaidViewList,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UpcomingInvoicesCard extends StatelessWidget {
  const _UpcomingInvoicesCard({required this.invoices, required this.onSeeAll});

  final List<Invoice> invoices;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    final loc = context.l10n;
    final theme = Theme.of(context);
    final formatter = DateFormat('MMM d');

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
          Row(
            children: [
              Expanded(
                child: Text(
                  loc.financeUpcomingTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.secondaryText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                onPressed: onSeeAll,
                child: Text(
                  loc.financeUpcomingSeeAll,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (invoices.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                loc.financeUpcomingEmpty,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.hintTextfiled,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            ...invoices.map((invoice) {
              final dueDate = invoice.dueDate;
              final dueLabel = dueDate != null
                  ? formatter.format(dueDate)
                  : loc.financeUpcomingNoDueDate;
              final badge = _UpcomingBadgeData.fromInvoice(context, invoice);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.financeUpcomingInvoiceLabel(
                              invoice.id.substring(3),
                              '€${invoice.amount.toStringAsFixed(2)}',
                            ),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.secondaryText,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dueLabel,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: AppColors.hintTextfiled,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _StatusBadge(label: badge.label, color: badge.color),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _UpcomingBadgeData {
  _UpcomingBadgeData({required this.label, required this.color});
  final String label;
  final Color color;

  static _UpcomingBadgeData fromInvoice(BuildContext context, Invoice invoice) {
    final loc = context.l10n;
    final dueDate = invoice.dueDate;
    if (dueDate == null) {
      return _UpcomingBadgeData(
        label: loc.financeUpcomingBadgeDueSoon,
        color: AppColors.secondary,
      );
    }
    final daysDiff = DateTime.now().difference(dueDate).inDays;
    final overdue = daysDiff > 0;
    final dueSoon = !overdue && daysDiff < 0 && daysDiff >= -3;
    final isDueToday = daysDiff == 0;

    final color = overdue
        ? const Color(0xFFE55454)
        : (isDueToday
              ? const Color(0xFFE55454)
              : (dueSoon ? const Color(0xFFFFA331) : const Color(0xFF2FBF71)));

    final label = overdue
        ? loc.financeUpcomingBadgeOverdue(daysDiff)
        : (isDueToday
              ? loc.financeUpcomingBadgeDueToday
              : (dueSoon
                    ? loc.financeUpcomingBadgeDueSoon
                    : loc.financeUpcomingBadgeDueIn(-daysDiff)));

    return _UpcomingBadgeData(label: label, color: color);
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

class _ExpensesCard extends StatelessWidget {
  const _ExpensesCard({
    required this.totalLabel,
    required this.topExpense,
    required this.onViewExpenses,
  });

  final String totalLabel;
  final Expense? topExpense;
  final VoidCallback onViewExpenses;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = context.l10n;
    final topExpenseLabel = topExpense == null
        ? loc.financeExpensesEmpty
        : loc.financeExpensesTopCategory(topExpense!.description);

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
          Row(
            children: [
              Expanded(
                child: Text(
                  loc.financeExpensesTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.secondaryText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                onPressed: onViewExpenses,
                child: Text(
                  loc.financeExpensesView,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            totalLabel,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: AppColors.secondaryText,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            topExpenseLabel,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.hintTextfiled,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentActivityCard extends StatelessWidget {
  const _RecentActivityCard({
    required this.events,
    required this.relativeTimeBuilder,
  });

  final List<_RecentEvent> events;
  final String Function(DateTime) relativeTimeBuilder;

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
            loc.financeRecentTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.secondaryText,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          if (events.isEmpty)
            Text(
              loc.financeRecentEmpty,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.hintTextfiled,
                fontWeight: FontWeight.w600,
              ),
            )
          else
            ...events.map((event) {
              final icon = event.icon;
              final color = event.color;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: color, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.title,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.secondaryText,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            relativeTimeBuilder(event.timestamp),
                            style: theme.textTheme.labelSmall?.copyWith(
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
            }),
        ],
      ),
    );
  }
}

class _RecentEvent {
  _RecentEvent({
    required this.type,
    required this.title,
    required this.timestamp,
  });

  final _RecentEventType type;
  final String title;
  final DateTime timestamp;

  IconData get icon {
    switch (type) {
      case _RecentEventType.quote:
        return FeatherIcons.edit3;
      case _RecentEventType.invoice:
        return FeatherIcons.fileText;
      case _RecentEventType.expense:
        return FeatherIcons.trendingDown;
      case _RecentEventType.payment:
        return FeatherIcons.checkCircle;
    }
  }

  Color get color {
    switch (type) {
      case _RecentEventType.quote:
        return AppColors.secondary;
      case _RecentEventType.invoice:
        return const Color(0xFF2FBF71);
      case _RecentEventType.expense:
        return const Color(0xFFE55454);
      case _RecentEventType.payment:
        return const Color(0xFF2FBF71);
    }
  }
}

enum _RecentEventType { quote, invoice, expense, payment }

class _QuickActionsSheet extends StatelessWidget {
  const _QuickActionsSheet({
    required this.title,
    required this.actions,
    required this.onTap,
  });

  final String title;
  final List<_QuickActionData> actions;
  final ValueChanged<_FinanceQuickAction> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.secondaryText,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 18),
          ...actions.map(
            (action) => Column(
              children: [
                ListTile(
                  onTap: () => onTap(action.action),
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: AppColors.secondary.withValues(
                      alpha: 0.12,
                    ),
                    child: Icon(action.icon, color: AppColors.secondary),
                  ),
                  title: Text(
                    action.label,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: AppColors.secondaryText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Divider(height: 1, color: AppColors.textfieldBorder),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionData {
  const _QuickActionData({
    required this.icon,
    required this.label,
    required this.action,
  });

  final IconData icon;
  final String label;
  final _FinanceQuickAction action;
}

enum _FinanceQuickAction { createQuote, createInvoice, addExpense, addPayment }
