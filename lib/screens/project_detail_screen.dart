import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:myapp/app/app_theme.dart';
import 'package:myapp/app/widgets/custom_nav_bar.dart';
import 'package:myapp/app/widgets/app_form_fields.dart';
import 'package:myapp/app/widgets/avatar_stack.dart';
import 'package:myapp/app/widgets/gradient_button.dart';
import 'package:myapp/app/widgets/gradient_progress_bar.dart';
import 'package:myapp/common/models/shared_file_record.dart';
import 'package:myapp/common/utils/shared_file_builder.dart';
import 'package:myapp/controllers/finance_controller.dart';
import 'package:myapp/controllers/project_controller.dart';
import 'package:myapp/controllers/user_controller.dart';
import 'package:myapp/common/models/message.dart';
import 'package:myapp/common/localization/formatters.dart';
import 'package:myapp/common/localization/l10n_extensions.dart';
import 'package:myapp/common/utils/project_ui.dart';
import 'package:myapp/models/finance.dart';
import 'package:myapp/models/industry.dart';
import 'package:myapp/models/project.dart';
import 'package:myapp/l10n/app_localizations.dart';
import 'package:myapp/services/chat_attachment_service.dart';

String _filenameFromUrl(String url) {
  try {
    final uri = Uri.parse(url);
    final segs = uri.pathSegments;
    if (segs.isNotEmpty) return segs.last;
    return url;
  } catch (_) {
    return url;
  }
}

class ProjectDetailScreen extends StatelessWidget {
  final String projectId;

  const ProjectDetailScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ProjectController>();
    final financeController = context.watch<FinanceController>();
    final project = controller.getById(projectId);
    final loc = context.l10n;

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
                  loc.projectNotFoundTitle,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.secondaryText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                GradientButton(
                  onPressed: () => context.goNamed('management'),
                  text: loc.projectDetailBackToProjects,
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
    final industryExtension = controller.industryExtensionFor(project.id);
    final financeSnapshot = _ProjectFinanceSnapshot.fromControllers(
      project: project,
      finance: financeController,
    );
    final projectFiles = SharedFileAggregator(
      controller: controller,
      loc: loc,
    ).build(projectId: project.id);
    final projectFilePreview = projectFiles.take(3).toList(growable: false);

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
                  CustomNavBar.totalHeight + 32,
                ),
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
                                router.goNamed('management');
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
                                    ? loc.projectDetailClientPlaceholder
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
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'projectChat',
                              child: Text(loc.projectDetailMenuProjectChat),
                            ),
                            PopupMenuItem(
                              value: 'sharedFiles',
                              child: Text(loc.sharedFilesTitle),
                            ),
                            PopupMenuItem(
                              value: 'inviteCollaborator',
                              child: Text(
                                loc.projectDetailMenuInviteCollaborator,
                              ),
                            ),
                            PopupMenuItem(
                              value: 'rolesPermissions',
                              child: Text(
                                loc.projectDetailMenuRolesPermissions,
                              ),
                            ),
                            const PopupMenuDivider(),
                            PopupMenuItem(
                              value: 'archive',
                              child: Text(loc.projectDetailMenuArchive),
                            ),
                            PopupMenuItem(
                              value: 'duplicate',
                              child: Text(loc.projectDetailMenuDuplicate),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text(loc.projectDetailMenuDelete),
                            ),
                          ],
                          onSelected: (value) {
                            switch (value) {
                              case 'projectChat':
                                context.pushNamed(
                                  'projectChat',
                                  pathParameters: {'id': project.id},
                                );
                                break;
                              case 'sharedFiles':
                                context.pushNamed('sharedFiles');
                                break;
                              case 'inviteCollaborator':
                                context.pushNamed('inviteCollaborator');
                                break;
                              case 'rolesPermissions':
                                context.pushNamed('rolesPermissions');
                                break;
                              case 'delete':
                                controller.removeProject(project.id);
                                final router = GoRouter.of(context);
                                if (router.canPop()) {
                                  router.pop();
                                } else {
                                  router.goNamed('management');
                                }
                                break;
                              case 'archive':
                              case 'duplicate':
                              default:
                                break;
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
                          controller.updateProject(
                            project.copyWith(status: value),
                          );
                        }
                      },
                    ),
                    if (industryExtension != null) ...[
                      const SizedBox(height: 18),
                      _IndustryInsightsCard(
                        extension: industryExtension,
                        loc: loc,
                      ),
                    ],
                    const SizedBox(height: 18),
                    _SectionCard(
                      title: loc.projectDetailScheduleTitle,
                      child: GradientButton(
                        onPressed: () => context.pushNamed(
                          'projectSchedule',
                          pathParameters: {'id': project.id},
                        ),
                        text: loc.projectDetailScheduleCta,
                        width: double.infinity,
                        height: 48,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _SectionCard(
                      title: loc.projectDetailTeamTitle,
                      trailing: Text(
                        loc.projectDetailTeamCount(project.members.length),
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
                                loc.projectDetailTeamEmpty,
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
                      title: loc.projectDetailTasksTitle,
                      trailing: GradientButton(
                        onPressed: () =>
                            _showAddTaskDialog(context, controller, project),
                        text: loc.projectDetailTasksAddCta,
                        width: 140,
                        height: 44,
                      ),
                      child: Column(
                        children: project.tasks.isEmpty
                            ? [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 24.0,
                                  ),
                                  child: Text(
                                    loc.projectDetailTasksEmpty,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
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
                                  onToggle: () => controller.toggleTask(
                                    project.id,
                                    task.id,
                                  ),
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
                      title: loc.projectDetailDiscussionTitle,
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
                      title: loc.homeFinanceOverviewTitle,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final isCompact = constraints.maxWidth < 520;
                              final tiles = <Widget>[
                                _FinanceTile(
                                  label: loc.projectDetailFinanceBilled,
                                  value: formatCurrency(
                                    context,
                                    financeSnapshot.totalBilled,
                                  ),
                                ),
                                _FinanceTile(
                                  label: loc.projectDetailFinancePaid,
                                  value: formatCurrency(
                                    context,
                                    financeSnapshot.totalPaid,
                                  ),
                                ),
                                _FinanceTile(
                                  label: loc.projectDetailFinanceRemaining,
                                  value: formatCurrency(
                                    context,
                                    financeSnapshot.totalOutstanding,
                                  ),
                                ),
                              ];
                              if (isCompact) {
                                return Column(
                                  children: [
                                    for (int i = 0; i < tiles.length; i++) ...[
                                      tiles[i],
                                      if (i != tiles.length - 1)
                                        const SizedBox(height: 12),
                                    ],
                                  ],
                                );
                              }
                              return Row(
                                children: [
                                  for (int i = 0; i < tiles.length; i++) ...[
                                    Expanded(child: tiles[i]),
                                    if (i != tiles.length - 1)
                                      const SizedBox(width: 14),
                                  ],
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          if (financeSnapshot.hasData) ...[
                            Text(
                              loc.financeUpcomingTitle,
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(
                                    color: AppColors.hintTextfiled,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            if (financeSnapshot.upcomingInvoices.isEmpty)
                              Text(
                                loc.financeUpcomingEmpty,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: AppColors.hintTextfiled,
                                      fontWeight: FontWeight.w600,
                                    ),
                              )
                            else
                              ...financeSnapshot.upcomingInvoices
                                  .take(2)
                                  .map(
                                    (invoice) =>
                                        _UpcomingInvoiceRow(invoice: invoice),
                                  ),
                            const SizedBox(height: 12),
                          ] else ...[
                            Text(
                              loc.financeReportingChartPlaceholder,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: AppColors.hintTextfiled,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 12),
                          ],
                          GradientButton(
                            onPressed: () => context.pushNamed('createQuote'),
                            text: loc.projectDetailFinanceCreateQuote,
                            width: double.infinity,
                            height: 48,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    _SectionCard(
                      title: loc.projectDetailFilesTitle,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (projectFilePreview.isEmpty)
                            Text(
                              loc.sharedFilesUploadCta,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: AppColors.hintTextfiled,
                                    fontWeight: FontWeight.w600,
                                  ),
                            )
                          else ...[
                            for (
                              int i = 0;
                              i < projectFilePreview.length;
                              i++
                            ) ...[
                              _ProjectFileRow(file: projectFilePreview[i]),
                              if (i != projectFilePreview.length - 1)
                                const Divider(
                                  height: 16,
                                  color: AppColors.textfieldBorder,
                                ),
                            ],
                            if (projectFiles.length > projectFilePreview.length)
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 10,
                                  bottom: 6,
                                ),
                                child: Text(
                                  '${loc.sharedFilesTitle} (${projectFiles.length})',
                                  style: Theme.of(context).textTheme.labelMedium
                                      ?.copyWith(
                                        color: AppColors.hintTextfiled,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                          ],
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: GradientButton(
                                  onPressed: () => _handleProjectFileUpload(
                                    context,
                                    controller,
                                    project.id,
                                  ),
                                  text: loc.projectDetailFilesAdd,
                                  width: double.infinity,
                                  height: 48,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () =>
                                      context.pushNamed('sharedFiles'),
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size.fromHeight(48),
                                    side: const BorderSide(
                                      color: AppColors.textfieldBorder,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: Text(
                                    loc.sharedFilesTitle,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          color: AppColors.secondaryText,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomNavBar(currentRouteName: 'management'),
          ),
        ],
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
          status: draft.status,
          startDate: draft.startDate,
          endDate: draft.endDate,
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
        onCycleStatus: () {
          controller.toggleTask(project.id, task.id);
        },
        onStatusSelected: (status) {
          controller.updateTaskStatus(project.id, task.id, status);
        },
      ),
    );
  }
}

class _TaskDraft {
  const _TaskDraft({
    required this.title,
    this.assigneeId,
    this.status = TaskStatus.planned,
    this.startDate,
    this.endDate,
    this.description,
    this.attachments = const [],
  });

  final String title;
  final String? assigneeId;
  final TaskStatus status;
  final DateTime? startDate;
  final DateTime? endDate;
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
  DateTime? _startDate;
  DateTime? _endDate;
  TaskStatus _status = TaskStatus.planned;
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
        _endDate = normalizedSuggested;
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

  Future<void> _pickStartDate() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 2);
    final baseLastDate = _endDate ?? DateTime(now.year + 5);
    final lastDate = baseLastDate.isAfter(firstDate)
        ? baseLastDate
        : firstDate.add(const Duration(days: 365));
    final currentSelection = _startDate ?? now;
    final clampedInitial = currentSelection.isBefore(firstDate)
        ? firstDate
        : currentSelection.isAfter(lastDate)
        ? lastDate
        : currentSelection;

    final picked = await showDatePicker(
      context: context,
      initialDate: clampedInitial,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null) {
      final normalized = DateTime(picked.year, picked.month, picked.day);
      setState(() {
        _startDate = normalized;
        if (_endDate != null && normalized.isAfter(_endDate!)) {
          _endDate = normalized;
        }
      });
    }
  }

  Future<void> _pickEndDate() async {
    final now = DateTime.now();
    final baseFirst = _startDate ?? DateTime(now.year - 2);
    final firstDate = baseFirst;
    final baseLastDate = widget.suggestedDueDate ?? DateTime(now.year + 5);
    final lastDate = baseLastDate.isAfter(firstDate)
        ? baseLastDate
        : firstDate.add(const Duration(days: 365));
    final currentSelection = _endDate ?? _startDate ?? now;
    final clampedInitial = currentSelection.isBefore(firstDate)
        ? firstDate
        : currentSelection.isAfter(lastDate)
        ? lastDate
        : currentSelection;

    final picked = await showDatePicker(
      context: context,
      initialDate: clampedInitial,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null) {
      final normalized = DateTime(picked.year, picked.month, picked.day);
      setState(() {
        _endDate = normalized;
        if (_startDate != null && normalized.isBefore(_startDate!)) {
          _startDate = normalized;
        }
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

  String _formatDate(DateTime? date, {required String placeholder}) {
    if (date == null) return placeholder;
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
        status: _status,
        startDate: _startDate,
        endDate: _endDate,
        description: description.isEmpty ? null : description,
        attachments: List<String>.unmodifiable(_attachments),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final loc = context.l10n;

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
                          loc.projectDetailTaskCreateTitle,
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
                    hintText: loc.projectDetailTaskTitleHint,
                    textInputAction: TextInputAction.next,
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                        ? loc.projectDetailTaskTitleError
                        : null,
                  ),
                  const SizedBox(height: 16),
                  _SheetFieldGroup(
                    label: loc.projectDetailTaskStatusLabel,
                    child: AppDropdownField<TaskStatus>(
                      items: TaskStatus.values,
                      value: _status,
                      hintText: loc.projectDetailTaskStatusHint,
                      labelBuilder: (status) => taskStatusMeta(status).label,
                      onChanged: (status) {
                        if (status == null) return;
                        setState(() => _status = status);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SheetFieldGroup(
                    label: loc.projectDetailTaskScheduleLabel,
                    child: Row(
                      children: [
                        Expanded(
                          child: AppDateField(
                            label: _formatDate(
                              _startDate,
                              placeholder: loc.projectDetailTaskStartDate,
                            ),
                            hasValue: _startDate != null,
                            onTap: _pickStartDate,
                            leading: const Icon(
                              FeatherIcons.play,
                              size: 20,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppDateField(
                            label: _formatDate(
                              _endDate,
                              placeholder: loc.projectDetailTaskDueDate,
                            ),
                            hasValue: _endDate != null,
                            onTap: _pickEndDate,
                            leading: const Icon(
                              FeatherIcons.flag,
                              size: 20,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (widget.members.isNotEmpty)
                    _SheetFieldGroup(
                      label: loc.projectDetailTaskAssigneeLabel,
                      child: AppDropdownField<Member>(
                        items: widget.members,
                        value: _selectedMember,
                        hintText: loc.projectDetailTaskAssigneeHint,
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
                        loc.projectDetailTaskAssigneeEmpty,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.hintTextfiled,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  _SheetFieldGroup(
                    label: loc.projectDetailTaskDetailsLabel,
                    child: AppFormTextField(
                      controller: _descriptionController,
                      hintText: loc.projectDetailTaskDetailsHint,
                      maxLines: 3,
                      textInputAction: TextInputAction.newline,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SheetFieldGroup(
                    label: loc.projectDetailTaskAttachmentsLabel,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppFormTextField(
                          controller: _attachmentController,
                          hintText: loc.projectDetailTaskAttachmentHint,
                          textInputAction: TextInputAction.done,
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: GradientButton(
                            onPressed: _addAttachment,
                            text: loc.projectDetailTaskAddAttachment,
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
                    text: loc.projectDetailTaskCreateTitle,
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

class _ScheduleBadge extends StatelessWidget {
  const _ScheduleBadge({required this.status, this.startDate, this.endDate});

  final TaskStatus status;
  final DateTime? startDate;
  final DateTime? endDate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final meta = taskStatusMeta(status);
    final start = startDate;
    final end = endDate;
    final loc = context.l10n;

    if (start == null && end == null) {
      return const SizedBox.shrink();
    }

    Color color = meta.color;
    String label;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final hasRange = start != null && end != null;
    final normalizedEnd = end != null
        ? DateTime(end.year, end.month, end.day)
        : null;

    late final String rangeLabel;
    if (hasRange) {
      rangeLabel = '${_formatFullDate(start)} – ${_formatFullDate(end)}';
    } else if (end != null) {
      rangeLabel = _formatFullDate(end);
    } else if (start != null) {
      rangeLabel = _formatFullDate(start);
    } else {
      return const SizedBox.shrink();
    }

    if (status == TaskStatus.completed) {
      color = meta.color;
      label = loc.projectDetailBadgeCompleted(rangeLabel);
    } else if (status == TaskStatus.deferred) {
      color = meta.color;
      label = loc.projectDetailBadgeDeferred(rangeLabel);
    } else if (normalizedEnd != null) {
      final diff = normalizedEnd.difference(today).inDays;
      final dueLabel = loc.projectDetailBadgeDueOn(
        _formatFullDate(normalizedEnd),
      );

      if (diff < 0) {
        color = AppColors.error;
        label = loc.projectDetailBadgeOverdue(rangeLabel);
      } else if (diff == 0) {
        color = AppColors.error;
        label = hasRange
            ? loc.projectDetailBadgeDueTodayRange(rangeLabel)
            : loc.projectDetailBadgeDueToday;
      } else if (diff <= 2) {
        color = AppColors.orange;
        label = hasRange
            ? loc.projectDetailBadgeUpcoming(rangeLabel)
            : dueLabel;
      } else {
        color = meta.color;
        label = hasRange
            ? loc.projectDetailBadgeTimeline(rangeLabel)
            : dueLabel;
      }
    } else if (start != null) {
      color = meta.color;
      label = loc.projectDetailBadgeStarts(_formatFullDate(start));
    } else {
      return const SizedBox.shrink();
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

class _IndustryInsightsCard extends StatelessWidget {
  const _IndustryInsightsCard({required this.extension, required this.loc});

  final ProjectIndustryExtension extension;
  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    if (extension is! CatererProjectExtension) {
      return const SizedBox.shrink();
    }
    final caterer = extension as CatererProjectExtension;
    final rows = <_IndustryInsightRow>[];
    if (caterer.guestCount != null) {
      rows.add(
        _IndustryInsightRow(
          label: loc.projectDetailIndustryGuests,
          value: loc.projectDetailIndustryGuestsValue(caterer.guestCount!),
        ),
      );
    }
    if (caterer.menuStyle != null && caterer.menuStyle!.isNotEmpty) {
      rows.add(
        _IndustryInsightRow(
          label: loc.projectDetailIndustryMenu,
          value: caterer.menuStyle!,
        ),
      );
    }
    if (caterer.allergyNotes != null && caterer.allergyNotes!.isNotEmpty) {
      rows.add(
        _IndustryInsightRow(
          label: loc.projectDetailIndustryAllergies,
          value: caterer.allergyNotes!,
        ),
      );
    }
    if (caterer.serviceStyle != null && caterer.serviceStyle!.isNotEmpty) {
      rows.add(
        _IndustryInsightRow(
          label: loc.projectDetailIndustryService,
          value: caterer.serviceStyle!,
        ),
      );
    }
    if (caterer.requiresTasting) {
      final tastingValue = caterer.tastingDate != null
          ? loc.projectDetailIndustryTastingScheduled(
              DateFormat.yMMMd().format(caterer.tastingDate!),
            )
          : loc.projectDetailIndustryTastingPending;
      rows.add(
        _IndustryInsightRow(
          label: loc.projectDetailIndustryTasting,
          value: tastingValue,
        ),
      );
    }
    rows.add(
      _IndustryInsightRow(
        label: loc.projectDetailIndustryKitchen,
        value: caterer.requiresOnsiteKitchen
            ? loc.projectDetailIndustryKitchenRequired
            : loc.projectDetailIndustryKitchenOptional,
      ),
    );
    if (caterer.kitchenNotes != null && caterer.kitchenNotes!.isNotEmpty) {
      rows.add(
        _IndustryInsightRow(
          label: loc.projectDetailIndustryKitchenNotes,
          value: caterer.kitchenNotes!,
        ),
      );
    }

    if (rows.isEmpty) {
      rows.add(
        _IndustryInsightRow(
          label: loc.projectDetailIndustryEmptyLabel,
          value: loc.projectDetailIndustryEmptyValue,
          emphasized: true,
        ),
      );
    }

    return _SectionCard(
      title: loc.projectDetailIndustryTitle,
      child: Column(
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            rows[i],
            if (i != rows.length - 1) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _IndustryInsightRow extends StatelessWidget {
  const _IndustryInsightRow({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: AppColors.hintTextfiled,
      fontWeight: FontWeight.w600,
    );
    final valueStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: emphasized ? AppColors.secondary : AppColors.secondaryText,
      fontWeight: emphasized ? FontWeight.bold : FontWeight.w600,
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(label, style: labelStyle)),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Text(value, textAlign: TextAlign.right, style: valueStyle),
        ),
      ],
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
    final completed = project.tasks
        .where((task) => task.status == TaskStatus.completed)
        .length;
    final total = project.tasks.length;
    final remaining = (total - completed).clamp(0, total);
    final loc = context.l10n;

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
                        loc.projectDetailProgressTitle,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: AppColors.secondaryText,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        total == 0
                            ? loc.projectDetailProgressEmpty
                            : loc.projectDetailProgressSummary(
                                completed,
                                total,
                              ),
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
                  label: loc.projectDetailProgressMetricInProgress,
                  value: '${project.progress}%',
                  accent: statusMeta.color,
                ),
                const SizedBox(width: 12),
                _ProgressMetric(
                  label: loc.projectDetailProgressMetricCompleted,
                  value: total == 0 ? '0' : '$completed',
                ),
                const SizedBox(width: 12),
                _ProgressMetric(
                  label: loc.projectDetailProgressMetricRemaining,
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
    final loc = context.l10n;
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
              loc.projectDetailDiscussionEmpty,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.hintTextfiled,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 18),
          GradientButton(
            onPressed: onOpenChat,
            text: loc.projectDetailDiscussionSend,
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
          text: loc.projectDetailDiscussionSend,
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
    final loc = context.l10n;
    final authorName = message.authorId == 'me'
        ? loc.homeAuthorYou
        : (author?.name ?? loc.homeCollaboratorFallback);

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
                      _relativeTimeLabel(context, message.sentAt),
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
    required this.onCycleStatus,
    required this.onStatusSelected,
  });

  final Task task;
  final Member assignee;
  final VoidCallback onCycleStatus;
  final ValueChanged<TaskStatus> onStatusSelected;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final status = task.status;
    final statusMeta = taskStatusMeta(status);
    final scheduleSummary = _taskScheduleSummary(
      context,
      task.startDate,
      task.endDate,
    );
    final loc = context.l10n;

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
                      label: loc.projectDetailTaskAssigneeLabel,
                      value: assignee.name.isEmpty
                          ? loc.projectDetailTaskAssigneeUnassigned
                          : assignee.name,
                    ),
                    const SizedBox(width: 12),
                    _DetailsBadge(
                      icon: FeatherIcons.calendar,
                      label: loc.projectDetailTaskScheduleLabel,
                      value: scheduleSummary,
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
                      _TaskStatusIndicator(status: status, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              loc.projectDetailTaskStatusLabel,
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: AppColors.hintTextfiled,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              statusMeta.label,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: statusMeta.color,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<TaskStatus>(
                        tooltip: '',
                        offset: const Offset(0, 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        color: AppColors.secondaryBackground,
                        initialValue: status,
                        onSelected: onStatusSelected,
                        itemBuilder: (context) {
                          return TaskStatus.values
                              .map((option) {
                                return PopupMenuItem<TaskStatus>(
                                  value: option,
                                  child: Text(
                                    taskStatusMeta(option).label,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: AppColors.secondaryText,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                );
                              })
                              .toList(growable: false);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryBackground,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.textfieldBorder,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                loc.projectDetailTaskStatusChange,
                                style: Theme.of(context).textTheme.labelMedium
                                    ?.copyWith(
                                      color: AppColors.secondaryText,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                FeatherIcons.chevronDown,
                                size: 16,
                                color: AppColors.hintTextfiled,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if ((task.description ?? '').isNotEmpty) ...[
                  const SizedBox(height: 18),
                  Text(
                    loc.projectDetailTaskDetailsLabel,
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
                    loc.projectDetailTaskAttachmentsLabel,
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
                    onCycleStatus();
                    Navigator.of(context).pop();
                  },
                  text: _statusActionLabel(context, status),
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

String _relativeTimeLabel(BuildContext context, DateTime timestamp) {
  final difference = DateTime.now().difference(timestamp);

  if (difference.inDays >= 7) {
    return _formatFullDate(timestamp);
  }

  return formatRelativeTime(context, timestamp);
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

String _taskScheduleSummary(
  BuildContext context,
  DateTime? start,
  DateTime? end,
) {
  final loc = context.l10n;
  if (start != null && end != null) {
    return '${_formatFullDate(start)} → ${_formatFullDate(end)}';
  }
  if (start != null) {
    return loc.projectDetailBadgeStarts(_formatFullDate(start));
  }
  if (end != null) {
    return loc.projectDetailBadgeDueOn(_formatFullDate(end));
  }
  return loc.projectDetailTaskScheduleEmpty;
}

String _statusActionLabel(BuildContext context, TaskStatus status) {
  final loc = context.l10n;
  switch (status) {
    case TaskStatus.planned:
      return loc.projectDetailStatusActionPlanned;
    case TaskStatus.inProgress:
      return loc.projectDetailStatusActionInProgress;
    case TaskStatus.completed:
      return loc.projectDetailStatusActionCompleted;
    case TaskStatus.deferred:
      return loc.projectDetailStatusActionDeferred;
  }
}

class _TaskStatusIndicator extends StatelessWidget {
  const _TaskStatusIndicator({required this.status, this.size = 26});

  final TaskStatus status;
  final double size;

  @override
  Widget build(BuildContext context) {
    final meta = taskStatusMeta(status);
    final color = meta.color;
    final icon = status == TaskStatus.planned ? null : meta.icon;
    final gradient = status == TaskStatus.completed
        ? const LinearGradient(
            colors: [AppColors.secondary, AppColors.primary],
            begin: AlignmentDirectional(1.0, 0.34),
            end: AlignmentDirectional(-1.0, -0.34),
          )
        : null;

    final fillColor = status == TaskStatus.completed
        ? null
        : status == TaskStatus.planned
        ? Colors.transparent
        : meta.softFill;

    final borderColor = status == TaskStatus.completed
        ? Colors.transparent
        : status == TaskStatus.planned
        ? AppColors.textfieldBorder
        : meta.border;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: gradient,
        color: fillColor,
        border: gradient != null
            ? null
            : Border.all(color: borderColor, width: 2),
      ),
      child: icon != null
          ? Icon(
              icon,
              size: size * 0.55,
              color: status == TaskStatus.completed
                  ? AppColors.primaryText
                  : color,
            )
          : null,
    );
  }
}

class _TaskStatusChip extends StatelessWidget {
  const _TaskStatusChip({required this.status});

  final TaskStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final meta = taskStatusMeta(status);
    final color = meta.color;
    final background = status == TaskStatus.planned
        ? Colors.transparent
        : meta.background;
    final textStyle =
        theme.textTheme.labelSmall ??
        theme.textTheme.bodySmall ??
        const TextStyle(fontSize: 12);

    final textColor = status == TaskStatus.planned
        ? AppColors.secondaryText
        : color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: status == TaskStatus.planned
              ? AppColors.textfieldBorder
              : meta.border,
        ),
      ),
      child: Text(
        meta.label,
        style: textStyle.copyWith(
          color: textColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
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
    final status = task.status;
    final startDate = task.startDate;
    final endDate = task.endDate;
    final loc = context.l10n;
    final assigneeName = assignee.name.isEmpty
        ? loc.projectDetailTaskAssigneeUnassigned
        : assignee.name;

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
            child: _TaskStatusIndicator(status: status),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: GestureDetector(
              onTap: onViewDetails,
              behavior: HitTestBehavior.opaque,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          task.title,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: AppColors.secondaryText,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _TaskStatusChip(status: status),
                    ],
                  ),
                  if (startDate != null || endDate != null) ...[
                    const SizedBox(height: 4),
                    _ScheduleBadge(
                      status: status,
                      startDate: startDate,
                      endDate: endDate,
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    loc.projectDetailTaskAssignedTo(assigneeName),
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
                            (file) => _AttachmentPill(
                              label: _filenameFromUrl(file),
                              removable: false,
                            ),
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
    return Container(
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
    );
  }
}

class _ProjectFileRow extends StatelessWidget {
  const _ProjectFileRow({required this.file});

  final SharedFileSummary file;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = context.l10n;
    final iconData = switch (file.category) {
      SharedFileCategory.pdf => FeatherIcons.fileText,
      SharedFileCategory.image => FeatherIcons.image,
      SharedFileCategory.spreadsheet => FeatherIcons.file,
    };
    final originLabel = switch (file.origin) {
      SharedFileOrigin.task => loc.projectDetailTasksTitle,
      SharedFileOrigin.chat => loc.projectDetailDiscussionTitle,
      SharedFileOrigin.library => loc.sharedFilesOriginLibrary,
    };

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.textfieldBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Icon(iconData, size: 18, color: AppColors.secondary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                file.name,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.secondaryText,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                loc.sharedFilesFileMeta(
                  file.category.label(loc),
                  file.sizeLabel,
                ),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.hintTextfiled,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${file.projectName} • $originLabel',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.hintTextfiled,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                loc.sharedFilesUploadedMeta(file.uploader, file.timestampLabel),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.hintTextfiled,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _UpcomingInvoiceRow extends StatelessWidget {
  const _UpcomingInvoiceRow({required this.invoice});

  final Invoice invoice;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = context.l10n;
    final amountLabel = formatCurrency(context, invoice.amount);
    final clientLabel = invoice.clientName.isEmpty
        ? loc.financeInvoiceUnknownClient
        : invoice.clientName;
    final dueDate = invoice.dueDate;
    final dueLabel = dueDate == null
        ? loc.financeUpcomingNoDueDate
        : DateFormat.yMMMd(loc.localeName).format(dueDate);
    final dueDelta = dueDate?.difference(
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
    );
    final daysDiff = dueDelta?.inDays;
    final badgeLabel = _invoiceBadgeLabel(loc, daysDiff);
    final badgeColor = (daysDiff != null && daysDiff < 0)
        ? AppColors.error
        : AppColors.secondary;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.financeInvoiceTitle(_invoiceNumber(invoice.id)),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: AppColors.secondaryText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  clientLabel,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.hintTextfiled,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  dueLabel,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.hintTextfiled,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badgeLabel,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: badgeColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                amountLabel,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.secondaryText,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProjectFinanceSnapshot {
  const _ProjectFinanceSnapshot({
    required this.totalBilled,
    required this.totalPaid,
    required this.totalOutstanding,
    required this.upcomingInvoices,
    required this.linkedInvoiceCount,
  });

  final double totalBilled;
  final double totalPaid;
  final double totalOutstanding;
  final List<Invoice> upcomingInvoices;
  final int linkedInvoiceCount;

  bool get hasData => linkedInvoiceCount > 0;

  factory _ProjectFinanceSnapshot.fromControllers({
    required Project project,
    required FinanceController finance,
  }) {
    // Prefer invoices that explicitly reference this project's ID. For
    // backward-compatibility, if no invoice has a `projectId` for this
    // project, fall back to the legacy client-name fuzzy match.
    final byProjectId = finance.invoices
        .where(
          (invoice) =>
              invoice.projectId != null && invoice.projectId == project.id,
        )
        .toList(growable: false);
    final invoices = byProjectId.isNotEmpty
        ? byProjectId
        : () {
            final key = _financeMatchKey(project);
            if (key == null) return <Invoice>[];
            return finance.invoices
                .where(
                  (invoice) => invoice.clientName.trim().toLowerCase() == key,
                )
                .toList(growable: false);
          }();
    final totalBilled = invoices.fold<double>(
      0,
      (sum, invoice) => sum + invoice.amount,
    );
    final totalPaid = invoices
        .where((invoice) => invoice.status == InvoiceStatus.paid)
        .fold<double>(0, (sum, invoice) => sum + invoice.amount);
    final totalOutstanding = invoices
        .where((invoice) => invoice.status == InvoiceStatus.unpaid)
        .fold<double>(0, (sum, invoice) => sum + invoice.amount);
    final upcoming =
        invoices
            .where(
              (invoice) =>
                  invoice.status == InvoiceStatus.unpaid &&
                  invoice.dueDate != null,
            )
            .toList(growable: false)
          ..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));

    return _ProjectFinanceSnapshot(
      totalBilled: totalBilled,
      totalPaid: totalPaid,
      totalOutstanding: totalOutstanding,
      upcomingInvoices: upcoming,
      linkedInvoiceCount: invoices.length,
    );
  }

  static String? _financeMatchKey(Project project) {
    final candidate =
        (project.client.isNotEmpty ? project.client : project.name)
            .trim()
            .toLowerCase();
    if (candidate.isEmpty) {
      return null;
    }
    return candidate;
  }
}

String _invoiceBadgeLabel(AppLocalizations loc, int? daysDiff) {
  if (daysDiff == null) {
    return loc.financeUpcomingNoDueDate;
  }
  if (daysDiff < 0) {
    return loc.financeUpcomingBadgeOverdue(daysDiff.abs());
  }
  if (daysDiff == 0) {
    return loc.financeUpcomingBadgeDueToday;
  }
  if (daysDiff <= 3) {
    return loc.financeUpcomingBadgeDueSoon;
  }
  return loc.financeUpcomingBadgeDueIn(daysDiff);
}

String _invoiceNumber(String id) {
  final match = RegExp(r'(\d+)').firstMatch(id);
  if (match != null) {
    return match.group(0)!;
  }
  return id;
}

Future<ChatAttachmentSource?> _pickAttachmentSourceFor(
  BuildContext context,
) async {
  return showModalBottomSheet<ChatAttachmentSource>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      final loc = sheetContext.l10n;
      final bottomPadding = MediaQuery.of(sheetContext).viewPadding.bottom;
      final theme = Theme.of(sheetContext);
      return SafeArea(
        top: false,
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.secondaryBackground,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(24, 20, 24, 16 + bottomPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    loc.sharedFilesPickerTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.secondaryText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.textfieldBackground,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Icon(FeatherIcons.image, color: AppColors.secondary),
                  ),
                  title: Text(
                    loc.collaborationChatAttachPhoto,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: AppColors.secondaryText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () => Navigator.of(
                    sheetContext,
                  ).pop(ChatAttachmentSource.photoLibrary),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.textfieldBackground,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      FeatherIcons.fileText,
                      color: AppColors.secondary,
                    ),
                  ),
                  title: Text(
                    loc.collaborationChatAttachDocument,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: AppColors.secondaryText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () => Navigator.of(
                    sheetContext,
                  ).pop(ChatAttachmentSource.document),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.textfieldBackground,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Icon(FeatherIcons.file, color: AppColors.secondary),
                  ),
                  title: Text(
                    loc.collaborationChatAttachPdf,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: AppColors.secondaryText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () =>
                      Navigator.of(sheetContext).pop(ChatAttachmentSource.pdf),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.textfieldBackground,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      FeatherIcons.camera,
                      color: AppColors.secondary,
                    ),
                  ),
                  title: Text(
                    loc.collaborationChatAttachCamera,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: AppColors.secondaryText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () => Navigator.of(
                    sheetContext,
                  ).pop(ChatAttachmentSource.camera),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Future<void> _handleProjectFileUpload(
  BuildContext context,
  ProjectController controller,
  String projectId,
) async {
  final loc = context.l10n;
  final userController = context.read<UserController>();
  final scaffold = ScaffoldMessenger.of(context);
  final attachmentService = ChatAttachmentService();

  final source = await _pickAttachmentSourceFor(context);
  if (source == null) return;

  try {
    final uploaded = await attachmentService.pickAndUpload(source);
    if (uploaded == null) return;

    final uploaderId =
        controller.currentUserId ?? controller.currentUserEmail ?? 'anonymous';
    final uploaderName =
        userController.profile?.displayName ??
        controller.currentUserEmail ??
        uploaderId;
    final draft = SharedFileDraft(
      fileUrl: uploaded.url,
      fileName: uploaded.name,
      contentType: uploaded.contentType,
      sizeBytes: uploaded.sizeBytes,
      origin: SharedFileOrigin.library,
      uploaderId: uploaderId,
      uploaderName: uploaderName,
      projectId: projectId,
    );
    await controller.saveSharedFile(draft);
    scaffold
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(loc.sharedFilesUploadSuccess)));
  } catch (_) {
    scaffold
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(loc.sharedFilesUploadFailure)));
  }
}
