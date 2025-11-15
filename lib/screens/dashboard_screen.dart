import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:myapp/app/app_theme.dart';
import 'package:myapp/app/widgets/gradient_button.dart';
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

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
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
              const SizedBox(height: 28),
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
                        onTap: () => setState(() => _selectedStatus = null),
                      ),
                      _StatusChip(
                        label: 'Ongoing',
                        selected: _selectedStatus == ProjectStatus.ongoing,
                        onTap: () => setState(
                          () => _selectedStatus = ProjectStatus.ongoing,
                        ),
                      ),
                      _StatusChip(
                        label: 'Upcoming',
                        selected:
                            _selectedStatus == ProjectStatus.inPreparation,
                        onTap: () => setState(
                          () => _selectedStatus = ProjectStatus.inPreparation,
                        ),
                      ),
                      _StatusChip(
                        label: 'Completed',
                        selected: _selectedStatus == ProjectStatus.completed,
                        onTap: () => setState(
                          () => _selectedStatus = ProjectStatus.completed,
                        ),
                      ),
                    ],
                  );

                  final newProjectButton = GradientButton(
                    onPressed: () => context.go('/projects/create'),
                    text: '+ New Project',
                    width: isCompact ? double.infinity : 170,
                    height: 48,
                  );

                  if (isCompact) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        filterChips,
                        const SizedBox(height: 16),
                        newProjectButton,
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: filterChips),
                      const SizedBox(width: 16),
                      newProjectButton,
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              Expanded(
                child: projects.isEmpty
                    ? Center(
                        child: Column(
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
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: AppColors.secondaryText,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Create your first project to see progress here.',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: AppColors.hintTextfiled,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 24),
                        itemCount: projects.length,
                        itemBuilder: (context, index) {
                          final project = projects[index];
                          return ProjectCard(
                            project: project,
                            onTap: () => context.go('/projects/${project.id}'),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
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
