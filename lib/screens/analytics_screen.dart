import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:provider/provider.dart';

import 'package:myapp/app/app_theme.dart';
import 'package:myapp/common/localization/l10n_extensions.dart';
import 'package:myapp/controllers/project_controller.dart';
import 'package:myapp/l10n/app_localizations.dart';
import 'package:myapp/models/project.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = context.l10n;
    final projects = context.watch<ProjectController>().projects;
    final now = DateTime.now();

    final completedThisMonth = projects.where((p) {
      if (p.status != ProjectStatus.completed || p.endDate == null) {
        return false;
      }
      final d = p.endDate!;
      return d.year == now.year && d.month == now.month;
    }).length;

    final durations = projects
        .where((p) => p.startDate != null && p.endDate != null)
        .map((p) => p.endDate!.difference(p.startDate!).inDays)
        .where((d) => d >= 0)
        .toList(growable: false);
    final avgDurationDays = durations.isEmpty
        ? null
        : (durations.reduce((a, b) => a + b) / durations.length);

    // On-time delivery rate: requires target due dates and actual completion timestamps.
    // Not available in current model, so display N/A with hint.
    final onTimeRate = null;

    // Revenue: depends on Finance module integration (placeholder shown below).

    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          loc.analyticsTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            color: AppColors.secondaryText,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : 24,
            vertical: isMobile ? 12 : 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _UpdatedBadge(date: now, loc: loc),
              const SizedBox(height: 16),
              _MetricGrid(
                isMobile: isMobile,
                children: [
                  _MetricCard(
                    icon: FeatherIcons.checkCircle,
                    label: loc.analyticsMetricCompleted,
                    value: completedThisMonth.toString(),
                    accent: AppColors.primary,
                  ),
                  _MetricCard(
                    icon: FeatherIcons.activity,
                    label: loc.analyticsMetricAvgDuration,
                    value: avgDurationDays == null
                        ? '—'
                        : loc.analyticsAvgDurationValue(
                            avgDurationDays.toStringAsFixed(1),
                          ),
                    accent: AppColors.secondary,
                    sublabel: durations.isEmpty
                        ? loc.analyticsAvgDurationEmpty
                        : null,
                  ),
                  _MetricCard(
                    icon: FeatherIcons.trendingUp,
                    label: loc.analyticsMetricOnTime,
                    value: onTimeRate == null
                        ? loc.analyticsValueNotAvailable
                        : loc.analyticsPercentValue(
                            onTimeRate.toStringAsFixed(0),
                          ),
                    accent: const Color(0xFF5C7CFA),
                    sublabel: loc.analyticsOnTimeHint,
                  ),
                  _MetricCard(
                    icon: FeatherIcons.dollarSign,
                    label: loc.analyticsMetricRevenue,
                    value: '—',
                    accent: const Color(0xFF2FBF71),
                    sublabel: loc.analyticsRevenueHint,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _InsightsSection(projects: projects, loc: loc),
            ],
          ),
        ),
      ),
    );
  }
}

class _UpdatedBadge extends StatelessWidget {
  const _UpdatedBadge({required this.date, required this.loc});
  final DateTime date;
  final AppLocalizations loc;
  @override
  Widget build(BuildContext context) {
    final text =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return Row(
      children: [
        const Icon(
          FeatherIcons.clock,
          size: 16,
          color: AppColors.hintTextfiled,
        ),
        const SizedBox(width: 8),
        Text(
          loc.analyticsUpdatedLabel(text),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.hintTextfiled,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.children, required this.isMobile});
  final List<Widget> children;
  final bool isMobile;
  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return Column(
        children: children
            .map(
              (c) =>
                  Padding(padding: const EdgeInsets.only(bottom: 12), child: c),
            )
            .toList(growable: false),
      );
    }
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: children
          .map((c) => SizedBox(width: 320, child: c))
          .toList(growable: false),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
    this.sublabel,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color accent;
  final String? sublabel;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.textfieldBorder.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 20, color: accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.hintTextfiled,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: AppColors.secondaryText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (sublabel != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    sublabel!,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.hintTextfiled,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightsSection extends StatelessWidget {
  const _InsightsSection({required this.projects, required this.loc});
  final List<Project> projects;
  final AppLocalizations loc;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = projects.length;
    final completed = projects
        .where((p) => p.status == ProjectStatus.completed)
        .length;
    final inProgress = projects
        .where((p) => p.status == ProjectStatus.ongoing)
        .length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.textfieldBorder.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.analyticsInsightsTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.secondaryText,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _InsightRow(
            icon: FeatherIcons.folder,
            label: loc.analyticsInsightTotalProjects,
            value: '$total',
          ),
          _InsightRow(
            icon: FeatherIcons.check,
            label: loc.analyticsInsightCompletedProjects,
            value: '$completed',
          ),
          _InsightRow(
            icon: FeatherIcons.playCircle,
            label: loc.analyticsInsightInProgress,
            value: '$inProgress',
          ),
        ],
      ),
    );
  }
}

class _InsightRow extends StatelessWidget {
  const _InsightRow({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.secondaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.secondaryText,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
