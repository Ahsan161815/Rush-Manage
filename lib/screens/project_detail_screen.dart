import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:myapp/app/app_theme.dart';
import 'package:myapp/app/widgets/gradient_button.dart';
import 'package:myapp/controllers/project_controller.dart';
import 'package:myapp/models/project.dart';

class ProjectDetailScreen extends StatelessWidget {
  final String projectId;

  const ProjectDetailScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ProjectController>();
    final project = controller.getById(projectId);

    if (project == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 64, color: AppColors.error),
                const SizedBox(height: 16),
                Text(
                  'Project not found',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.secondaryText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                GradientButton(
                  onPressed: () => context.go('/projects'),
                  text: 'Back to Projects',
                  width: 200,
                  height: 46,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.textfieldBackground,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.chevron_left,
                        color: AppColors.secondaryText,
                      ),
                      onPressed: () {
                        final router = GoRouter.of(context);
                        if (router.canPop()) {
                          router.pop();
                        } else {
                          router.go('/projects');
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.name,
                          style: Theme.of(context).textTheme.displaySmall
                              ?.copyWith(
                                color: AppColors.secondaryText,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          project.client.isEmpty
                              ? 'Client TBD'
                              : project.client,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: AppColors.hintTextfiled,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: 'archive',
                        child: Text('Archive project'),
                      ),
                      PopupMenuItem(
                        value: 'duplicate',
                        child: Text('Duplicate'),
                      ),
                      PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                    onSelected: (value) {
                      if (value == 'delete') {
                        controller.removeProject(project.id);
                        final router = GoRouter.of(context);
                        if (router.canPop()) {
                          router.pop();
                        } else {
                          router.go('/projects');
                        }
                      }
                    },
                    icon: const Icon(
                      Icons.more_horiz,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.secondary, AppColors.primary],
                    begin: AlignmentDirectional(1.0, 0.34),
                    end: AlignmentDirectional(-1.0, -0.34),
                  ),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Progress overview',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: AppColors.primaryText,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${project.tasks.where((t) => t.completed).length} of ${project.tasks.length} tasks completed',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AppColors.primaryText.withOpacity(
                                    0.85,
                                  ),
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 20),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: LinearProgressIndicator(
                              value: project.progress / 100,
                              minHeight: 10,
                              backgroundColor: AppColors.primaryText
                                  .withOpacity(0.2),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.primaryText,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Column(
                      children: [
                        Text(
                          '${project.progress}%',
                          style: Theme.of(context).textTheme.displaySmall
                              ?.copyWith(
                                color: AppColors.primaryText,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 12),
                        _StatusDropdown(
                          status: project.status,
                          onChanged: (value) {
                            if (value != null) {
                              controller.updateProject(
                                project.copyWith(status: value),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _SectionCard(
                title: 'Team',
                trailing: Text(
                  '${project.members.length} members',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.hintTextfiled,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: project.members.isEmpty
                      ? [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.textfieldBackground,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'No members assigned',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: AppColors.hintTextfiled,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        ]
                      : project.members
                            .map(
                              (member) => Chip(
                                backgroundColor: AppColors.textfieldBackground,
                                label: Text(
                                  member.name,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: AppColors.secondaryText,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                            )
                            .toList(),
                ),
              ),
              const SizedBox(height: 18),
              _SectionCard(
                title: 'Tasks',
                trailing: GradientButton(
                  onPressed: () =>
                      _showAddTaskDialog(context, controller, project.id),
                  text: '+ Add Task',
                  width: 140,
                  height: 44,
                ),
                child: Column(
                  children: project.tasks.isEmpty
                      ? [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24.0),
                            child: Text(
                              'No tasks yet. Create the first milestone.',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: AppColors.hintTextfiled,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        ]
                      : project.tasks
                            .map(
                              (task) => _TaskTile(
                                task: task,
                                assignee: project.members.firstWhere(
                                  (m) => m.id == task.assigneeId,
                                  orElse: () =>
                                      const Member(id: '', name: 'Unassigned'),
                                ),
                                onToggle: () =>
                                    controller.toggleTask(project.id, task.id),
                              ),
                            )
                            .toList(),
                ),
              ),
              const SizedBox(height: 18),
              _SectionCard(
                title: 'Discussion',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ActivityBubble(
                      author: 'Sarah D.',
                      content: 'added a new task "Photo shoot"',
                      timestamp: '2h ago',
                    ),
                    const SizedBox(height: 12),
                    _ActivityBubble(
                      author: 'Alex P.',
                      content: 'uploaded "venue-contract.pdf"',
                      timestamp: '5h ago',
                    ),
                    const SizedBox(height: 16),
                    GradientButton(
                      onPressed: () {},
                      text: 'Send Message',
                      width: double.infinity,
                      height: 48,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _SectionCard(
                title: 'Finance overview',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        _FinanceTile(label: 'Billed', value: '€850'),
                        SizedBox(width: 16),
                        _FinanceTile(label: 'Paid', value: '€0'),
                        SizedBox(width: 16),
                        _FinanceTile(label: 'Remaining', value: '€850'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    GradientButton(
                      onPressed: () {},
                      text: 'Create quote for this project',
                      width: double.infinity,
                      height: 48,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _SectionCard(
                title: 'Files',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FileTile(fileName: 'contracts.pdf', onTap: () {}),
                    const SizedBox(height: 12),
                    GradientButton(
                      onPressed: () {},
                      text: '+ Add a file',
                      width: double.infinity,
                      height: 48,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showAddTaskDialog(
    BuildContext context,
    ProjectController controller,
    String projectId,
  ) async {
    final titleController = TextEditingController();
    final result = await showDialog<String?>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add Task'),
          content: TextField(
            controller: titleController,
            decoration: const InputDecoration(hintText: 'Task title'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, titleController.text.trim()),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    if ((result ?? '').isNotEmpty) {
      controller.addTask(
        projectId,
        Task(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: result!,
        ),
      );
    }
  }
}

class _StatusDropdown extends StatelessWidget {
  const _StatusDropdown({required this.status, required this.onChanged});

  final ProjectStatus status;
  final ValueChanged<ProjectStatus?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.primaryText.withOpacity(0.15),
        borderRadius: BorderRadius.circular(18),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ProjectStatus>(
          dropdownColor: AppColors.secondaryBackground,
          value: status,
          icon: const Icon(Icons.expand_more, color: AppColors.primaryText),
          items: ProjectStatus.values
              .map(
                (value) => DropdownMenuItem(
                  value: value,
                  child: Text(
                    value.toString().split('.').last,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.secondaryText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, this.child, this.trailing});

  final String title;
  final Widget? child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground,
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F181BF2),
            blurRadius: 20,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.secondaryText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          if (child != null) ...[const SizedBox(height: 18), child!],
        ],
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  const _TaskTile({
    required this.task,
    required this.assignee,
    required this.onToggle,
  });

  final Task task;
  final Member assignee;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.textfieldBackground,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onToggle,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: task.completed
                    ? const LinearGradient(
                        colors: [AppColors.secondary, AppColors.primary],
                        begin: AlignmentDirectional(1.0, 0.34),
                        end: AlignmentDirectional(-1.0, -0.34),
                      )
                    : null,
                border: Border.all(
                  color: task.completed
                      ? Colors.transparent
                      : AppColors.textfieldBorder,
                  width: 2,
                ),
              ),
              child: task.completed
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: AppColors.primaryText,
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.secondaryText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Assigned to ${assignee.name.isEmpty ? 'Unassigned' : assignee.name}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.hintTextfiled,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityBubble extends StatelessWidget {
  const _ActivityBubble({
    required this.author,
    required this.content,
    required this.timestamp,
  });

  final String author;
  final String content;
  final String timestamp;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.textfieldBackground,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            author,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.secondaryText,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.secondaryText,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            timestamp,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.hintTextfiled,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _FinanceTile extends StatelessWidget {
  const _FinanceTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.textfieldBackground,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.hintTextfiled,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
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

class _FileTile extends StatelessWidget {
  const _FileTile({required this.fileName, required this.onTap});

  final String fileName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.textfieldBackground,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.insert_drive_file_outlined,
              color: AppColors.secondaryText,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                fileName,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.secondaryText,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.hintTextfiled),
          ],
        ),
      ),
    );
  }
}
