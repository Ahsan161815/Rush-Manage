import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:myapp/app/app_theme.dart';
import 'package:myapp/app/widgets/custom_nav_bar.dart';
import 'package:myapp/app/widgets/project_card.dart';
import 'package:myapp/controllers/project_controller.dart';
import 'package:myapp/models/project.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
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
    final controller = context.watch<ProjectController>();
    final projects = _filterProjects(controller.projects);

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
              Icon(
                Icons.folder_open,
                size: 110,
                color: AppColors.hintTextfiled,
              ),
              const SizedBox(height: 16),
              Text(
                'No projects in this view yet',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.secondaryText,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Create your first project to see progress here.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                padding: EdgeInsets.fromLTRB(
                  24,
                  20,
                  24,
                  CustomNavBar.totalHeight + 48,
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
                                'Projects',
                                style: Theme.of(context).textTheme.displaySmall
                                    ?.copyWith(
                                      color: AppColors.secondaryText,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Keep track of every event, task, and deliverable in one place.',
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(
                                      color: AppColors.hintTextfiled,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isCompact = constraints.maxWidth < 600;
                        final filterChips = Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            _StatusChip(
                              label: 'All',
                              selected: _selectedStatus == null,
                              onTap: () =>
                                  setState(() => _selectedStatus = null),
                            ),
                            _StatusChip(
                              label: 'Ongoing',
                              selected:
                                  _selectedStatus == ProjectStatus.ongoing,
                              onTap: () => setState(
                                () => _selectedStatus = ProjectStatus.ongoing,
                              ),
                            ),
                            _StatusChip(
                              label: 'Upcoming',
                              selected:
                                  _selectedStatus ==
                                  ProjectStatus.inPreparation,
                              onTap: () => setState(
                                () => _selectedStatus =
                                    ProjectStatus.inPreparation,
                              ),
                            ),
                            _StatusChip(
                              label: 'Completed',
                              selected:
                                  _selectedStatus == ProjectStatus.completed,
                              onTap: () => setState(
                                () => _selectedStatus = ProjectStatus.completed,
                              ),
                            ),
                          ],
                        );

                        if (isCompact) {
                          return filterChips;
                        }

                        return Align(
                          alignment: Alignment.centerLeft,
                          child: filterChips,
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    projectsSection,
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomNavBar(currentRouteName: 'dashboard'),
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
