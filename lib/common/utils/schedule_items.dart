import 'package:flutter/material.dart';

import 'package:myapp/models/project.dart';
import 'package:myapp/common/utils/project_ui.dart';

/// Normalized calendar entry for month/week/day views.
class CalendarTaskEntry {
  CalendarTaskEntry({
    required this.taskId,
    required this.title,
    required this.start,
    required this.end,
    required this.color,
    required this.status,
    this.isAllDay = false,
    this.assigneeName,
    this.description,
  });

  final String taskId;
  final String title;
  final DateTime start;
  final DateTime end;
  final Color color;
  final TaskStatus status;
  final bool isAllDay;
  final String? assigneeName;
  final String? description;

  Duration get duration => end.difference(start);
}

/// Normalized Gantt entry (bar on timeline).
class GanttTaskEntry {
  GanttTaskEntry({
    required this.taskId,
    required this.title,
    required this.start,
    required this.end,
    required this.status,
    required this.color,
    this.assigneeId,
    this.assigneeName,
    this.description,
  });

  final String taskId;
  final String title;
  final DateTime start;
  final DateTime end;
  final TaskStatus status;
  final Color color;
  final String? assigneeId;
  final String? assigneeName;
  final String? description;

  Duration get duration => end.difference(start);
}

/// Adapter that converts project tasks into calendar & gantt entries.
class ProjectScheduleAdapter {
  ProjectScheduleAdapter({required this.project, required this.members});

  final Project project;
  final List<Member> members;

  late final Map<String, Member> _memberLookup = {
    for (final m in members) m.id: m,
  };

  /// Returns tasks with valid time ranges; fills missing start/end and rounds to hour.
  List<CalendarTaskEntry> buildCalendarEntries() {
    final List<CalendarTaskEntry> entries = [];
    for (final task in project.tasks) {
      DateTime? start = task.startDate;
      DateTime? end = task.endDate;
      if (start == null && end == null) {
        continue; // unscheduled
      }
      if (start == null && end != null) {
        start = end.subtract(const Duration(hours: 2));
      }
      if (end == null && start != null) {
        end = start.add(const Duration(hours: 2));
      }
      if (start == null || end == null) {
        continue;
      }
      if (!end.isAfter(start)) {
        end = start.add(const Duration(hours: 1));
      }

      // Hour rounding for consistency.
      start = DateTime(start.year, start.month, start.day, start.hour);
      end = DateTime(end.year, end.month, end.day, end.hour);

      final meta = taskStatusMeta(task.status);
      final memberName = task.assigneeId != null
          ? _memberLookup[task.assigneeId]?.name
          : null;
      final isAllDay = _computeIsAllDay(start, end);

      entries.add(
        CalendarTaskEntry(
          taskId: task.id,
          title: task.title,
          start: start,
          end: end,
          color: meta.color,
          status: task.status,
          isAllDay: isAllDay,
          assigneeName: memberName,
          description: task.description,
        ),
      );
    }
    return entries;
  }

  List<GanttTaskEntry> buildGanttEntries() {
    final List<GanttTaskEntry> entries = [];
    for (final task in project.tasks) {
      DateTime? start = task.startDate;
      DateTime? end = task.endDate;
      if (start == null && end == null) {
        continue;
      }
      if (start == null && end != null) {
        start = end.subtract(const Duration(hours: 2));
      }
      if (end == null && start != null) {
        end = start.add(const Duration(hours: 2));
      }
      if (start == null || end == null) {
        continue;
      }
      if (!end.isAfter(start)) {
        end = start.add(const Duration(hours: 1));
      }

      start = DateTime(start.year, start.month, start.day, start.hour);
      end = DateTime(end.year, end.month, end.day, end.hour);

      final meta = taskStatusMeta(task.status);
      final member = task.assigneeId != null
          ? _memberLookup[task.assigneeId]
          : null;

      entries.add(
        GanttTaskEntry(
          taskId: task.id,
          title: task.title,
          start: start,
          end: end,
          status: task.status,
          color: meta.color,
          assigneeId: task.assigneeId,
          assigneeName: member?.name,
          description: task.description,
        ),
      );
    }
    return entries;
  }

  bool _computeIsAllDay(DateTime start, DateTime end) {
    // Treat tasks spanning >= 8 hours OR crossing midnight as all-day style.
    final crossesMidnight =
        start.day != end.day ||
        start.month != end.month ||
        start.year != end.year;
    return crossesMidnight || end.difference(start) >= const Duration(hours: 8);
  }
}
