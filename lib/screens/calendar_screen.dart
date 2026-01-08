import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:myapp/app/app_theme.dart';
import 'package:myapp/app/widgets/custom_nav_bar.dart';
import 'package:myapp/common/localization/l10n_extensions.dart';
import 'package:myapp/common/utils/schedule_items.dart';
import 'package:myapp/controllers/project_controller.dart';
import 'package:myapp/models/project.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  _CalendarRange _range = _CalendarRange.week;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ProjectController>();
    final loc = context.l10n;
    final theme = Theme.of(context);
    final events = _buildEvents(
      controller.projects,
      _range,
      loc.projectDetailClientPlaceholder,
    );
    final buckets = _groupByDay(events);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          loc.projectDetailScheduleTitle,
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
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  24,
                  16,
                  24,
                  CustomNavBar.totalHeight + 32,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CalendarSummaryStrip(
                      scheduledCount: events.length,
                      projectCount: controller.projects.length,
                      range: _range,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: _CalendarRange.values
                          .map(
                            (range) => Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: ChoiceChip(
                                label: Text(range.label),
                                selected: _range == range,
                                onSelected: (_) =>
                                    setState(() => _range = range),
                                selectedColor: AppColors.secondary,
                                labelStyle: theme.textTheme.labelLarge
                                    ?.copyWith(
                                      color: _range == range
                                          ? AppColors.primaryText
                                          : AppColors.secondaryText,
                                      fontWeight: FontWeight.bold,
                                    ),
                                side: BorderSide(
                                  color: AppColors.secondary.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                                backgroundColor: AppColors.secondaryBackground,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 20),
                    if (buckets.isEmpty)
                      _CalendarEmptyState(
                        message: loc.projectDetailTaskScheduleEmpty,
                      )
                    else
                      Expanded(
                        child: ListView.separated(
                          itemCount: buckets.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 18),
                          itemBuilder: (context, index) {
                            final bucket = buckets[index];
                            return _CalendarDaySection(bucket: bucket);
                          },
                        ),
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
            child: CustomNavBar(currentRouteName: 'calendar'),
          ),
        ],
      ),
    );
  }

  List<_CalendarEventView> _buildEvents(
    List<Project> projects,
    _CalendarRange range,
    String clientFallback,
  ) {
    final now = DateTime.now();
    final startWindow = DateTime(now.year, now.month, now.day);
    final endWindow = startWindow.add(range.windowLength);
    final events = <_CalendarEventView>[];

    for (final project in projects) {
      final adapter = ProjectScheduleAdapter(
        project: project,
        members: project.members,
      );
      for (final entry in adapter.buildCalendarEntries()) {
        if (entry.end.isBefore(startWindow) || entry.start.isAfter(endWindow)) {
          continue;
        }
        events.add(
          _CalendarEventView(
            projectId: project.id,
            projectName: project.name,
            clientName: project.client.isEmpty
                ? clientFallback
                : project.client,
            entry: entry,
          ),
        );
      }
    }

    events.sort((a, b) => a.entry.start.compareTo(b.entry.start));
    return events;
  }

  List<_CalendarDayBucket> _groupByDay(List<_CalendarEventView> events) {
    if (events.isEmpty) {
      return const [];
    }

    final buckets = <_CalendarDayBucket>[];
    DateTime? currentDay;
    List<_CalendarEventView> currentItems = [];

    for (final event in events) {
      final dayKey = DateTime(
        event.entry.start.year,
        event.entry.start.month,
        event.entry.start.day,
      );
      if (currentDay == null || dayKey != currentDay) {
        if (currentDay != null) {
          buckets.add(
            _CalendarDayBucket(date: currentDay, events: currentItems),
          );
        }
        currentDay = dayKey;
        currentItems = [event];
      } else {
        currentItems.add(event);
      }
    }

    if (currentDay != null) {
      buckets.add(_CalendarDayBucket(date: currentDay, events: currentItems));
    }

    return buckets;
  }
}

class _CalendarSummaryStrip extends StatelessWidget {
  const _CalendarSummaryStrip({
    required this.scheduledCount,
    required this.projectCount,
    required this.range,
  });

  final int scheduledCount;
  final int projectCount;
  final _CalendarRange range;

  @override
  Widget build(BuildContext context) {
    final loc = context.l10n;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground,
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          _SummaryMetric(
            label: loc.projectDetailScheduleTitle,
            value: '$scheduledCount',
            subtitle: '${range.label} • tasks',
          ),
          const SizedBox(width: 16),
          _SummaryMetric(
            label: 'Active projects',
            value: '$projectCount',
            subtitle: '${loc.invitationNotificationsFilterAll} projects',
          ),
        ],
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.label,
    required this.value,
    required this.subtitle,
  });

  final String label;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: AppColors.hintTextfiled,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: AppColors.secondaryText,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
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

class _CalendarEmptyState extends StatelessWidget {
  const _CalendarEmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              FeatherIcons.calendar,
              size: 52,
              color: AppColors.hintTextfiled,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColors.secondaryText,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CalendarDaySection extends StatelessWidget {
  const _CalendarDaySection({required this.bucket});

  final _CalendarDayBucket bucket;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateLabel = DateFormat('EEE, MMM d').format(bucket.date);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          dateLabel,
          style: theme.textTheme.titleMedium?.copyWith(
            color: AppColors.secondaryText,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...bucket.events.map((event) => _CalendarEventCard(event: event)),
      ],
    );
  }
}

class _CalendarEventCard extends StatelessWidget {
  const _CalendarEventCard({required this.event});

  final _CalendarEventView event;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeLabel = event.entry.isAllDay
        ? 'All day'
        : '${DateFormat.Hm().format(event.entry.start)} – '
              '${DateFormat.Hm().format(event.entry.end)}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.textfieldBorder.withValues(alpha: 0.6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: event.entry.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  event.entry.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: AppColors.secondaryText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                timeLabel,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppColors.hintTextfiled,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${event.projectName} • ${event.clientName}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.hintTextfiled,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (event.entry.assigneeName != null) ...[
            const SizedBox(height: 6),
            Text(
              '@${event.entry.assigneeName}',
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
          if (event.entry.description != null &&
              event.entry.description!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              event.entry.description!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.secondaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CalendarEventView {
  const _CalendarEventView({
    required this.projectId,
    required this.projectName,
    required this.clientName,
    required this.entry,
  });

  final String projectId;
  final String projectName;
  final String clientName;
  final CalendarTaskEntry entry;
}

class _CalendarDayBucket {
  const _CalendarDayBucket({required this.date, required this.events});

  final DateTime date;
  final List<_CalendarEventView> events;
}

enum _CalendarRange { week, month }

extension on _CalendarRange {
  Duration get windowLength => this == _CalendarRange.week
      ? const Duration(days: 7)
      : const Duration(days: 30);

  String get label => this == _CalendarRange.week ? '7d' : '30d';
}
