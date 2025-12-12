import 'package:flutter/material.dart';
import 'package:myapp/app/app_theme.dart';
import 'package:myapp/app/widgets/gradient_button.dart';
import 'package:myapp/common/localization/l10n_extensions.dart';

class FinanceReportingScreen extends StatelessWidget {
  const FinanceReportingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = context.l10n;
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;

    final cards = [
      _ReportCard(title: loc.financeReportingCardRevenue),
      _ReportCard(title: loc.financeReportingCardOutstanding),
      _ReportCard(title: loc.financeReportingCardConversion),
      _ReportCard(title: loc.financeReportingCardTopClients),
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
          isMobile ? 16 : 24,
          24,
          isMobile ? 16 : 24,
          32,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _FilterBar(),
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
              onPressed: () {},
              text: loc.financeReportingExportCta,
              height: 56,
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({required this.title});

  final String title;

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
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.secondaryText,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.textfieldBorder.withValues(alpha: 0.3),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                loc.financeReportingChartPlaceholder,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.hintTextfiled,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _ReportRange { last7Days, last30Days, quarterToDate, yearToDate }

enum _ReportGranularity { daily, weekly, monthly }

class _FilterBar extends StatefulWidget {
  const _FilterBar();

  @override
  State<_FilterBar> createState() => _FilterBarState();
}

class _FilterBarState extends State<_FilterBar> {
  _ReportRange range = _ReportRange.last30Days;
  _ReportGranularity granularity = _ReportGranularity.monthly;

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
                onChanged: (value) => setState(() => range = value),
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
                onChanged: (value) => setState(() => granularity = value),
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
