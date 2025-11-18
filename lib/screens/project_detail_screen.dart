import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:myapp/app/app_theme.dart';
import 'package:myapp/app/widgets/app_form_fields.dart';
import 'package:myapp/app/widgets/avatar_stack.dart';
import 'package:myapp/app/widgets/gradient_button.dart';
import 'package:myapp/app/widgets/gradient_progress_bar.dart';
import 'package:myapp/controllers/project_controller.dart';
import 'package:myapp/common/models/message.dart';
import 'package:myapp/common/utils/project_ui.dart';
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
                const Icon(
                  FeatherIcons.alertCircle,
                  size: 64,
                  color: AppColors.error,
                ),
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
                  onPressed: () => context.goNamed('dashboard'),
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

    final messages = controller.messagesFor(project.id);

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
                      border: Border.all(
                        color: AppColors.textfieldBorder.withValues(
                          alpha: 0.45,
                        ),
                      ),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        FeatherIcons.arrowLeft,
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
                      FeatherIcons.moreHorizontal,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _ProgressOverview(
                project: project,
                onStatusChanged: (value) {
                  if (value != null) {
                    controller.updateProject(project.copyWith(status: value));
                  }
                },
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
                child: project.members.isEmpty
                    ? Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.textfieldBackground,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Text(
                          'No members assigned yet.',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppColors.hintTextfiled,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AvatarStack(
                            members: project.members,
                            size: 42,
                            maxVisible: 5,
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 18),
              _SectionCard(
                title: 'Tasks',
                trailing: GradientButton(
                  onPressed: () =>
                      _showAddTaskDialog(context, controller, project),
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
                      : project.tasks.map((task) {
                          final assignee = project.members.firstWhere(
                            (m) => m.id == task.assigneeId,
                            orElse: () =>
                                const Member(id: '', name: 'Unassigned'),
                          );
                          return _TaskTile(
                            task: task,
                            assignee: assignee,
                            onToggle: () =>
                                controller.toggleTask(project.id, task.id),
                            onViewDetails: () => _showTaskDetails(
                              context,
                              controller,
                              project,
                              task,
                              assignee,
                            ),
                          );
                        }).toList(),
                ),
              ),
              const SizedBox(height: 18),
              _SectionCard(
                title: 'Discussion',
                child: _DiscussionPreview(
                  project: project,
                  messages: messages,
                  onOpenChat: () => context.pushNamed(
                    'projectChat',
                    pathParameters: {'id': project.id},
                  ),
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
    Project project,
  ) async {
    final draft = await showModalBottomSheet<_TaskDraft>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => _AddTaskSheet(
        members: project.members,
        suggestedDueDate: project.endDate,
      ),
    );

    if (draft != null) {
      controller.addTask(
        project.id,
        Task(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: draft.title,
          assigneeId: draft.assigneeId,
          dueDate: draft.dueDate,
          description: draft.description,
          attachments: List<String>.unmodifiable(draft.attachments),
        ),
      );
    }
  }

  Future<void> _showTaskDetails(
    BuildContext context,
    ProjectController controller,
    Project project,
    Task task,
    Member assignee,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => _TaskDetailsSheet(
        task: task,
        assignee: assignee,
        onToggle: () {
          controller.toggleTask(project.id, task.id);
        },
      ),
    );
  }
}

class _TaskDraft {
  const _TaskDraft({
    required this.title,
    this.assigneeId,
    this.dueDate,
    this.description,
    this.attachments = const [],
  });

  final String title;
  final String? assigneeId;
  final DateTime? dueDate;
  final String? description;
  final List<String> attachments;
}

class _AddTaskSheet extends StatefulWidget {
  const _AddTaskSheet({required this.members, this.suggestedDueDate});

  final List<Member> members;
  final DateTime? suggestedDueDate;

  @override
  State<_AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<_AddTaskSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _attachmentController;
  DateTime? _dueDate;
  Member? _selectedMember;
  final List<String> _attachments = [];
  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _attachmentController = TextEditingController();

    final suggested = widget.suggestedDueDate;
    if (suggested != null) {
      final today = DateTime.now();
      final normalizedSuggested = DateTime(
        suggested.year,
        suggested.month,
        suggested.day,
      );
      final normalizedToday = DateTime(today.year, today.month, today.day);
      if (normalizedSuggested.isAfter(normalizedToday)) {
        _dueDate = normalizedSuggested;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _attachmentController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 2);
    final rawLastDate = widget.suggestedDueDate != null
        ? widget.suggestedDueDate!
        : DateTime(now.year + 5);
    final lastDate = rawLastDate.isAfter(firstDate)
        ? rawLastDate
        : DateTime(now.year + 5);
    final currentSelection = _dueDate ?? now;
    final clampedInitial = currentSelection.isBefore(firstDate)
        ? firstDate
        : currentSelection.isAfter(lastDate)
        ? lastDate
        : currentSelection;

    final picked = await showDatePicker(
      context: context,
      initialDate: clampedInitial,
      firstDate: firstDate,
      lastDate: lastDate.add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _dueDate = DateTime(picked.year, picked.month, picked.day);
      });
    }
  }

  void _addAttachment() {
    final value = _attachmentController.text.trim();
    if (value.isEmpty) return;
    setState(() {
      _attachments.add(value);
    });
    _attachmentController.clear();
  }

  void _removeAttachment(String value) {
    setState(() {
      _attachments.remove(value);
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Select due date';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final description = _descriptionController.text.trim();
    Navigator.of(context).pop(
      _TaskDraft(
        title: _titleController.text.trim(),
        assigneeId: _selectedMember?.id,
        dueDate: _dueDate,
        description: description.isEmpty ? null : description,
        attachments: List<String>.unmodifiable(_attachments),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: mediaQuery.viewInsets.bottom),
      child: SafeArea(
        top: false,
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.secondaryBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [
              BoxShadow(
                color: Color(0x26000000),
                blurRadius: 26,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              24,
              28,
              24,
              24 + mediaQuery.padding.bottom,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Create task',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: AppColors.secondaryText,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          FeatherIcons.x,
                          color: AppColors.hintTextfiled,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  AppFormTextField(
                    controller: _titleController,
                    hintText: 'Task title',
                    textInputAction: TextInputAction.next,
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                        ? 'Please add a title'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  _SheetFieldGroup(
                    label: 'Due date',
                    child: AppDateField(
                      label: _formatDate(_dueDate),
                      hasValue: _dueDate != null,
                      onTap: _pickDueDate,
                      leading: const Icon(
                        FeatherIcons.calendar,
                        size: 20,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (widget.members.isNotEmpty)
                    _SheetFieldGroup(
                      label: 'Assignee',
                      child: AppDropdownField<Member>(
                        items: widget.members,
                        value: _selectedMember,
                        hintText: 'Assign a teammate',
                        labelBuilder: (member) => member.name,
                        onChanged: (member) =>
                            setState(() => _selectedMember = member),
                      ),
                    )
                  else
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.textfieldBackground,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.textfieldBorder),
                      ),
                      child: Text(
                        'Invite teammates to assign this task.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.hintTextfiled,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  _SheetFieldGroup(
                    label: 'Details',
                    child: AppFormTextField(
                      controller: _descriptionController,
                      hintText: 'Share context or checklist items',
                      maxLines: 3,
                      textInputAction: TextInputAction.newline,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SheetFieldGroup(
                    label: 'Attachments',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppFormTextField(
                          controller: _attachmentController,
                          hintText: 'Paste a link or filename',
                          textInputAction: TextInputAction.done,
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: GradientButton(
                            onPressed: _addAttachment,
                            text: 'Add attachment',
                            width: 230,
                            height: 42,
                          ),
                        ),
                        if (_attachments.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: _attachments
                                .map(
                                  (file) => _AttachmentPill(
                                    label: file,
                                    onRemove: () => _removeAttachment(file),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  GradientButton(
                    onPressed: _submit,
                    text: 'Create task',
                    width: double.infinity,
                    height: 50,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SheetFieldGroup extends StatelessWidget {
  const _SheetFieldGroup({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.secondaryText,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _DueDateBadge extends StatelessWidget {
  const _DueDateBadge({required this.dueDate, required this.completed});

  final DateTime dueDate;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDay = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final diff = dueDay.difference(today).inDays;

    Color color;
    String label;

    if (completed) {
      color = AppColors.success;
      label = 'Completed · ${_formatDate(dueDay)}';
    } else if (diff < 0) {
      color = AppColors.error;
      label = 'Overdue · ${_formatDate(dueDay)}';
    } else if (diff == 0) {
      color = AppColors.error;
      label = 'Due today';
    } else if (diff <= 2) {
      color = AppColors.orange;
      label = 'Due ${_formatDate(dueDay)}';
    } else {
      color = AppColors.success;
      label = 'Due ${_formatDate(dueDay)}';
    }

    final baseStyle =
        theme.textTheme.labelSmall ??
        theme.textTheme.bodySmall ??
        theme.textTheme.bodyMedium ??
        const TextStyle(fontSize: 11);

    return Text(
      label,
      style: baseStyle.copyWith(color: color, fontWeight: FontWeight.w700),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class _AttachmentPill extends StatelessWidget {
  const _AttachmentPill({
    required this.label,
    this.onRemove,
    this.removable = true,
  });

  final String label;
  final VoidCallback? onRemove;
  final bool removable;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 240),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.secondaryBackground,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.textfieldBorder, width: 1.1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              FeatherIcons.paperclip,
              color: AppColors.secondaryText,
              size: 16,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.secondaryText,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (removable && onRemove != null) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onRemove,
                child: const Icon(
                  FeatherIcons.x,
                  size: 16,
                  color: AppColors.hintTextfiled,
                ),
              ),
            ],
          ],
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

class _ProgressOverview extends StatelessWidget {
  const _ProgressOverview({
    required this.project,
    required this.onStatusChanged,
  });

  final Project project;
  final ValueChanged<ProjectStatus?> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    final statusMeta = projectStatusMeta(project.status);
    final completed = project.tasks.where((task) => task.completed).length;
    final total = project.tasks.length;
    final remaining = (total - completed).clamp(0, total);

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.secondary, AppColors.primary],
          begin: AlignmentDirectional(1.0, 0.34),
          end: AlignmentDirectional(-1.0, -0.34),
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: AppColors.secondaryBackground,
          borderRadius: BorderRadius.circular(26),
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
                        'Progress overview',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: AppColors.secondaryText,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        total == 0
                            ? 'No tasks added yet'
                            : '$completed of $total tasks completed',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.hintTextfiled,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                _StatusPicker(
                  status: project.status,
                  onChanged: onStatusChanged,
                ),
              ],
            ),
            const SizedBox(height: 24),
            GradientProgressBar(progress: project.progress, height: 12),
            const SizedBox(height: 18),
            Row(
              children: [
                _ProgressMetric(
                  label: 'In progress',
                  value: '${project.progress}%',
                  accent: statusMeta.color,
                ),
                const SizedBox(width: 12),
                _ProgressMetric(
                  label: 'Completed',
                  value: total == 0 ? '0' : '$completed',
                ),
                const SizedBox(width: 12),
                _ProgressMetric(
                  label: 'Remaining',
                  value: total == 0 ? '-' : '$remaining',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPicker extends StatelessWidget {
  const _StatusPicker({required this.status, required this.onChanged});

  final ProjectStatus status;
  final ValueChanged<ProjectStatus?> onChanged;

  static const double _buttonWidth = 188;

  @override
  Widget build(BuildContext context) {
    final meta = projectStatusMeta(status);

    return SizedBox(
      width: _buttonWidth,
      child: PopupMenuButton<ProjectStatus>(
        tooltip: '',
        offset: const Offset(0, 12),
        constraints: const BoxConstraints.tightFor(width: _buttonWidth),
        color: AppColors.secondaryBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        onSelected: onChanged,
        itemBuilder: (context) {
          return ProjectStatus.values.map((value) {
            final itemMeta = projectStatusMeta(value);
            final isSelected = value == status;
            return PopupMenuItem<ProjectStatus>(
              value: value,
              height: 44,
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: itemMeta.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      itemMeta.label,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isSelected
                            ? AppColors.secondaryText
                            : AppColors.hintTextfiled,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                  if (isSelected)
                    const Icon(
                      FeatherIcons.check,
                      size: 16,
                      color: AppColors.primary,
                    ),
                ],
              ),
            );
          }).toList();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: meta.background,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: meta.border, width: 1.1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: meta.color,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Text(
                  meta.label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.secondaryText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                FeatherIcons.chevronDown,
                size: 18,
                color: AppColors.secondaryText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressMetric extends StatelessWidget {
  const _ProgressMetric({
    required this.label,
    required this.value,
    this.accent,
  });

  final String label;
  final String value;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.textfieldBackground,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.textfieldBorder.withValues(alpha: 0.4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.hintTextfiled,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: accent ?? AppColors.secondaryText,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiscussionPreview extends StatelessWidget {
  const _DiscussionPreview({
    required this.project,
    required this.messages,
    required this.onOpenChat,
  });

  final Project project;
  final List<Message> messages;
  final VoidCallback onOpenChat;

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.textfieldBackground,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              'No messages yet. Start a conversation with your team.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.hintTextfiled,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 18),
          GradientButton(
            onPressed: onOpenChat,
            text: 'Send Message',
            width: double.infinity,
            height: 48,
          ),
        ],
      );
    }

    final sorted = [...messages]..sort((a, b) => b.sentAt.compareTo(a.sentAt));
    final preview = sorted.take(3).toList();
    final members = {for (final member in project.members) member.id: member};

    return Column(
      children: [
        for (var i = 0; i < preview.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: i == preview.length - 1 ? 16 : 14),
            child: _MessagePreviewTile(
              message: preview[i],
              author: members[preview[i].authorId],
            ),
          ),
        GradientButton(
          onPressed: onOpenChat,
          text: 'Send Message',
          width: double.infinity,
          height: 48,
        ),
      ],
    );
  }
}

class _MessagePreviewTile extends StatelessWidget {
  const _MessagePreviewTile({required this.message, this.author});

  final Message message;
  final Member? author;

  @override
  Widget build(BuildContext context) {
    final authorName = message.authorId == 'me'
        ? 'You'
        : (author?.name ?? 'Team member');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AvatarBadge(
          label: authorName.isNotEmpty ? authorName[0].toUpperCase() : '?',
          size: 38,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.textfieldBackground,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.textfieldBorder.withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        authorName,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.secondaryText,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      _relativeTimeLabel(message.sentAt),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.hintTextfiled,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  message.body,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.secondaryText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AvatarBadge extends StatelessWidget {
  const _AvatarBadge({required this.label, required this.size});

  final String label;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [AppColors.secondary, AppColors.primary],
          begin: AlignmentDirectional(1.0, 0.34),
          end: AlignmentDirectional(-1.0, -0.34),
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: AppColors.primaryText,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _TaskDetailsSheet extends StatelessWidget {
  const _TaskDetailsSheet({
    required this.task,
    required this.assignee,
    required this.onToggle,
  });

  final Task task;
  final Member assignee;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: SafeArea(
        top: false,
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.secondaryBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [
              BoxShadow(
                color: Color(0x26000000),
                blurRadius: 28,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(24, 28, 24, 24 + media.padding.bottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        task.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.secondaryText,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        FeatherIcons.x,
                        color: AppColors.hintTextfiled,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    _DetailsBadge(
                      icon: FeatherIcons.user,
                      label: 'Assignee',
                      value: assignee.name.isEmpty
                          ? 'Unassigned'
                          : assignee.name,
                    ),
                    const SizedBox(width: 12),
                    _DetailsBadge(
                      icon: FeatherIcons.calendar,
                      label: 'Due',
                      value: task.dueDate != null
                          ? _formatFullDate(task.dueDate!)
                          : 'No due date',
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.textfieldBackground,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: task.completed
                              ? const Color(0xFF34C759)
                              : AppColors.secondary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          task.completed ? 'Completed' : 'In progress',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: AppColors.secondaryText,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                if ((task.description ?? '').isNotEmpty) ...[
                  const SizedBox(height: 18),
                  Text(
                    'Details',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.secondaryText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    task.description!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.secondaryText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                if (task.attachments.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  Text(
                    'Attachments',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.secondaryText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: task.attachments
                        .map(
                          (file) =>
                              _AttachmentPill(label: file, removable: false),
                        )
                        .toList(),
                  ),
                ],
                const SizedBox(height: 26),
                GradientButton(
                  onPressed: () {
                    onToggle();
                    Navigator.of(context).pop();
                  },
                  text: task.completed
                      ? 'Mark as in progress'
                      : 'Mark as complete',
                  width: double.infinity,
                  height: 50,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailsBadge extends StatelessWidget {
  const _DetailsBadge({
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.textfieldBackground,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.textfieldBorder.withValues(alpha: 0.45),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.hintTextfiled,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.secondaryText,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _relativeTimeLabel(DateTime timestamp) {
  final now = DateTime.now();
  final difference = now.difference(timestamp);

  if (difference.inMinutes < 1) {
    return 'Just now';
  }
  if (difference.inMinutes < 60) {
    return '${difference.inMinutes}m ago';
  }
  if (difference.inHours < 24) {
    return '${difference.inHours}h ago';
  }
  if (difference.inDays < 7) {
    return '${difference.inDays}d ago';
  }

  return _formatFullDate(timestamp);
}

String _formatFullDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  final month = months[date.month - 1];
  final day = date.day.toString().padLeft(2, '0');
  return '$month $day, ${date.year}';
}

class _TaskTile extends StatelessWidget {
  const _TaskTile({
    required this.task,
    required this.assignee,
    required this.onToggle,
    required this.onViewDetails,
  });

  final Task task;
  final Member assignee;
  final VoidCallback onToggle;
  final VoidCallback onViewDetails;

  bool get _hasDescription => (task.description ?? '').trim().isNotEmpty;
  bool get _hasAttachments => task.attachments.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dueDate = task.dueDate;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.textfieldBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onToggle,
            child: Container(
              width: 26,
              height: 26,
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
                      FeatherIcons.check,
                      size: 16,
                      color: AppColors.primaryText,
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: GestureDetector(
              onTap: onViewDetails,
              behavior: HitTestBehavior.opaque,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: AppColors.secondaryText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (dueDate != null) ...[
                    const SizedBox(height: 4),
                    _DueDateBadge(dueDate: dueDate, completed: task.completed),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    'Assigned to ${assignee.name.isEmpty ? 'Unassigned' : assignee.name}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.hintTextfiled,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (_hasDescription) ...[
                    const SizedBox(height: 8),
                    Text(
                      task.description!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.secondaryText.withValues(alpha: 0.75),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  if (_hasAttachments) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: task.attachments
                          .map(
                            (file) =>
                                _AttachmentPill(label: file, removable: false),
                          )
                          .toList(),
                    ),
                  ],
                ],
              ),
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
            const Icon(FeatherIcons.fileText, color: AppColors.secondaryText),
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
            const Icon(
              FeatherIcons.chevronRight,
              color: AppColors.hintTextfiled,
            ),
          ],
        ),
      ),
    );
  }
}
