import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:myapp/app/app_theme.dart';
import 'package:myapp/app/widgets/avatar_stack.dart';
import 'package:myapp/app/widgets/gradient_progress_bar.dart';
import 'package:myapp/common/utils/project_ui.dart';
import 'package:myapp/models/project.dart';

class ProjectCard extends StatelessWidget {
  const ProjectCard({super.key, required this.project, this.onTap});

  final Project project;
  final VoidCallback? onTap;

  String _formatDate(DateTime? date) {
    if (date == null) return '--';
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(28)),
            gradient: LinearGradient(
              colors: [AppColors.secondary, AppColors.primary],
              begin: AlignmentDirectional(1.0, 0.34),
              end: AlignmentDirectional(-1.0, -0.34),
            ),
          ),
          padding: const EdgeInsets.all(1.8),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.textfieldBackground,
              borderRadius: BorderRadius.circular(26),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
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
                            project.name,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(color: AppColors.secondaryText),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            project.client.isEmpty
                                ? 'Client TBD'
                                : project.client,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: AppColors.hintTextfiled,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    ),
                    _StatusBadge(status: project.status),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    _InfoPill(
                      icon: FeatherIcons.calendar,
                      label: 'Start',
                      value: _formatDate(project.startDate),
                      accent: AppColors.secondary,
                    ),
                    const SizedBox(width: 12),
                    _InfoPill(
                      icon: FeatherIcons.flag,
                      label: 'Due',
                      value: _formatDate(project.endDate),
                      accent: AppColors.orange,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: GradientProgressBar(
                        progress: project.progress,
                        height: 10,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${project.progress}%',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.secondaryText,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                AvatarStack(members: project.members),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.textfieldBackground,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accent.withValues(alpha: 0.12),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 18, color: accent),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.hintTextfiled,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.secondaryText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final ProjectStatus status;

  @override
  Widget build(BuildContext context) {
    final meta = projectStatusMeta(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: meta.background,
        border: Border.all(color: meta.border, width: 1.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: meta.color,
              shape: BoxShape.circle,
            ),
          ),
          Text(
            meta.label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: meta.color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
