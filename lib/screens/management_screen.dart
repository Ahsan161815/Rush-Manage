import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:myapp/app/app_theme.dart';
import 'package:myapp/app/widgets/custom_nav_bar.dart';
import 'package:myapp/app/widgets/project_card.dart';
import 'package:myapp/controllers/project_controller.dart';
import 'package:myapp/models/project.dart';
import 'package:myapp/common/models/message.dart';

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
    int unreadMessages = 0; // used for bottom nav badge later
    for (final p in projectController.projects) {
      final msgs = projectController.messagesFor(p.id);
      for (final m in msgs) {
        final me = m.receipts['me'];
        if (me != MessageReceiptStatus.read) unreadMessages++;
      }
    }

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
              Icon(Icons.folder_open, size: 80, color: AppColors.hintTextfiled),
              const SizedBox(height: 12),
              Text(
                'No projects yet',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.secondaryText,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Create your first project to see progress.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Management',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                color: AppColors.secondaryText,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Projects, staffing, and blockers in one view',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: AppColors.hintTextfiled,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
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
                            label: 'All',
                            selected: _selectedStatus == null,
                            onTap: () => setState(() => _selectedStatus = null),
                          ),
                          const SizedBox(width: 10),
                          _StatusChip(
                            label: 'Ongoing',
                            selected: _selectedStatus == ProjectStatus.ongoing,
                            onTap: () => setState(
                              () => _selectedStatus = ProjectStatus.ongoing,
                            ),
                          ),
                          const SizedBox(width: 10),
                          _StatusChip(
                            label: 'Upcoming',
                            selected:
                                _selectedStatus == ProjectStatus.inPreparation,
                            onTap: () => setState(
                              () =>
                                  _selectedStatus = ProjectStatus.inPreparation,
                            ),
                          ),
                          const SizedBox(width: 10),
                          _StatusChip(
                            label: 'Completed',
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
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Projects (${projects.length})',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: AppColors.secondaryText,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => context.goNamed('projectsCreate'),
                          icon: const Icon(
                            Icons.add_circle_outline,
                            color: AppColors.secondary,
                          ),
                          tooltip: 'Create project',
                        ),
                      ],
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
            child: CustomNavBar(
              currentRouteName: 'management',
              unreadChatsCount: unreadMessages,
            ),
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
