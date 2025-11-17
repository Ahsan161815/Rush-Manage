import 'package:flutter/material.dart';

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
