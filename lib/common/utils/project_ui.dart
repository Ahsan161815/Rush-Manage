import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

import 'package:myapp/app/app_theme.dart';
import 'package:myapp/models/project.dart';

class ProjectStatusMeta {
  const ProjectStatusMeta({required this.label, required this.color});

  final String label;
  final Color color;

  Color get background => color.withValues(alpha: 0.12);
  Color get border => color.withValues(alpha: 0.3);
}

ProjectStatusMeta projectStatusMeta(ProjectStatus status) {
  switch (status) {
    case ProjectStatus.inPreparation:
      return ProjectStatusMeta(
        label: 'Planning',
        color: const Color(0xFF6C63FF),
      );
    case ProjectStatus.ongoing:
      return ProjectStatusMeta(
        label: 'In Progress',
        color: AppColors.secondary,
      );
    case ProjectStatus.completed:
      return ProjectStatusMeta(
        label: 'Completed',
        color: const Color(0xFF34C759),
      );
    case ProjectStatus.archived:
      return ProjectStatusMeta(
        label: 'Archived',
        color: AppColors.hintTextfiled,
      );
  }
}

class TaskStatusMeta {
  const TaskStatusMeta({required this.label, required this.color, this.icon});

  final String label;
  final Color color;
  final IconData? icon;

  Color get background => color.withValues(alpha: 0.12);
  Color get border => color.withValues(alpha: 0.35);
  Color get softFill => color.withValues(alpha: 0.15);
  Color get subtleText => color.withValues(alpha: 0.7);
}

TaskStatusMeta taskStatusMeta(TaskStatus status) {
  switch (status) {
    case TaskStatus.planned:
      return TaskStatusMeta(
        label: 'Planned',
        color: AppColors.hintTextfiled,
        icon: FeatherIcons.calendar,
      );
    case TaskStatus.inProgress:
      return TaskStatusMeta(
        label: 'In progress',
        color: AppColors.secondary,
        icon: FeatherIcons.play,
      );
    case TaskStatus.completed:
      return TaskStatusMeta(
        label: 'Completed',
        color: AppColors.success,
        icon: FeatherIcons.check,
      );
    case TaskStatus.deferred:
      return TaskStatusMeta(
        label: 'Deferred',
        color: AppColors.orange,
        icon: FeatherIcons.pause,
      );
  }
}
