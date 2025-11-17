import 'package:flutter/material.dart';
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
    const gradient = LinearGradient(
      colors: [AppColors.secondary, AppColors.primary],
      begin: AlignmentDirectional(1.0, 0.34),
      end: AlignmentDirectional(-1.0, -0.34),
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Container(
          margin: const EdgeInsets.all(1.5),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: AppColors.secondaryBackground,
            borderRadius: BorderRadius.circular(26),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A181BF2),
                blurRadius: 18,
                offset: Offset(0, 10),
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
                          project.name,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(color: AppColors.secondaryText),
                        ),
                        const SizedBox(height: 6),
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
                    icon: Icons.calendar_today_outlined,
                    label: 'Start',
                    value: _formatDate(project.startDate),
                  ),
                  const SizedBox(width: 12),
                  _InfoPill(
                    icon: Icons.flag_outlined,
                    label: 'Due',
                    value: _formatDate(project.endDate),
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
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

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
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
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
