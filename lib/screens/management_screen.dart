import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:myapp/app/app_theme.dart';
import 'package:myapp/app/widgets/custom_nav_bar.dart';
import 'package:myapp/app/widgets/project_card.dart';
import 'package:myapp/controllers/project_controller.dart';
import 'package:myapp/models/project.dart';
import 'package:myapp/common/localization/l10n_extensions.dart';
import 'package:myapp/widgets/section_hero_header.dart';

class ManagementScreen extends StatefulWidget {
  const ManagementScreen({super.key});

  @override
  State<ManagementScreen> createState() => _ManagementScreenState();
}

class _ManagementScreenState extends State<ManagementScreen> {
  ProjectStatus? _selectedStatus;

  List<Project> _filterProjects(List<Project> projects) {
    if (_selectedStatus == null) return projects;
    return projects.where((project) {
      if (_selectedStatus == ProjectStatus.inPreparation) {
        return project.status == ProjectStatus.inPreparation;
      }
      return project.status == _selectedStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final projectController = context.watch<ProjectController>();
    final projects = _filterProjects(projectController.projects);
    final theme = Theme.of(context);
    final loc = context.l10n;

    final projectCards = projects
        .map(
          (project) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ProjectCard(
              project: project,
              onTap: () => context.goNamed(
                'projectDetail',
                pathParameters: {'id': project.id},
              ),
            ),
          ),
        )
        .toList();

    final projectsSection = projects.isEmpty
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                FeatherIcons.folder,
                size: 80,
                color: AppColors.hintTextfiled,
              ),
              const SizedBox(height: 12),
              Text(
                loc.managementEmptyTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.secondaryText,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                loc.managementEmptySubtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.hintTextfiled,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          )
        : Column(children: projectCards);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeroHeader(
                      title: loc.managementTitle,
                      subtitle: loc.managementSubtitle,
                      actionTooltip: loc.managementCreateProjectTooltip,
                      onActionTap: () => context.goNamed('projectsCreate'),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 26,
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      height: 48,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.zero,
                        children: [
                          _StatusChip(
                            label: loc.commonAllFilter,
                            selected: _selectedStatus == null,
                            onTap: () => setState(() => _selectedStatus = null),
                          ),
                          const SizedBox(width: 10),
                          _StatusChip(
                            label: loc.managementFilterOngoing,
                            selected: _selectedStatus == ProjectStatus.ongoing,
                            onTap: () => setState(
                              () => _selectedStatus = ProjectStatus.ongoing,
                            ),
                          ),
                          const SizedBox(width: 10),
                          _StatusChip(
                            label: loc.managementFilterUpcoming,
                            selected:
                                _selectedStatus == ProjectStatus.inPreparation,
                            onTap: () => setState(
                              () =>
                                  _selectedStatus = ProjectStatus.inPreparation,
                            ),
                          ),
                          const SizedBox(width: 10),
                          _StatusChip(
                            label: loc.managementFilterCompleted,
                            selected:
                                _selectedStatus == ProjectStatus.completed,
                            onTap: () => setState(
                              () => _selectedStatus = ProjectStatus.completed,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      loc.managementProjectsHeading(projects.length),
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: AppColors.secondaryText,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    projectsSection,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomNavBar(currentRouteName: 'management'),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
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
          color: selected ? null : AppColors.textfieldBackground,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected ? Colors.transparent : AppColors.textfieldBorder,
            width: 1.2,
          ),
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
