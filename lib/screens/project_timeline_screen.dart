import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import 'package:myapp/app/app_theme.dart';
import 'package:myapp/common/utils/project_ui.dart';
import 'package:myapp/controllers/project_controller.dart';
import 'package:myapp/models/project.dart';

class ProjectTimelineScreen extends StatefulWidget {
  const ProjectTimelineScreen({super.key, required this.projectId});

  final String projectId;

  @override
  State<ProjectTimelineScreen> createState() => _ProjectTimelineScreenState();
}

class _ProjectTimelineScreenState extends State<ProjectTimelineScreen> {
  late final CalendarController _calendarController;

  @override
  void initState() {
    super.initState();
    _calendarController = CalendarController()
      ..view = CalendarView.timelineWeek;
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ProjectController>();
    final project = controller.getById(widget.projectId);

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
                  size: 62,
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
                const SizedBox(height: 20),
                OutlinedButton(
                  onPressed: () {
                    final router = GoRouter.of(context);
                    if (router.canPop()) {
                      router.pop();
                    } else {
                      router.goNamed('management');
                    }
                  },
                  child: const Text('Back'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final memberLookup = {
      for (final member in project.members) member.id: member,
    };
    final appointments = _buildAppointments(project, memberLookup);
    final unscheduled = project.tasks
        .where((task) {
          return task.startDate == null && task.endDate == null;
        })
        .toList(growable: false);

    final dataSource = _TaskTimelineDataSource(appointments);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TimelineHeader(project: project),
              const SizedBox(height: 20),
              _StatusLegend(),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.secondaryBackground,
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(
                      color: AppColors.textfieldBorder.withValues(alpha: 0.5),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x12181BF2),
                        blurRadius: 18,
                        offset: Offset(0, 14),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(8),
                  child: SfCalendar(
                    controller: _calendarController,
                    view: CalendarView.timelineWeek,
                    allowedViews: const [
                      CalendarView.timelineDay,
                      CalendarView.timelineWeek,
                      CalendarView.timelineWorkWeek,
                      CalendarView.timelineMonth,
                    ],
                    headerHeight: 48,
                    viewNavigationMode: ViewNavigationMode.snap,
                    showDatePickerButton: true,
                    dataSource: dataSource,
                    allowDragAndDrop: true,
                    allowAppointmentResize: true,
                    onDragEnd: (details) =>
                        _handleDragEnd(details, project, controller),
                    onAppointmentResizeEnd: (details) =>
                        _handleResize(details, project, controller),
                    minDate: DateTime.now().subtract(const Duration(days: 365)),
                    maxDate: DateTime.now().add(const Duration(days: 365)),
                    timeSlotViewSettings: const TimeSlotViewSettings(
                      timeIntervalHeight: 60,
                      timelineAppointmentHeight: 70,
                      timeIntervalWidth: 120,
                    ),
                    appointmentBuilder: (context, details) =>
                        _buildAppointment(context, details, project),
                    todayHighlightColor: AppColors.primary,
                    selectionDecoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        width: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
              if (unscheduled.isNotEmpty) ...[
                const SizedBox(height: 24),
                _UnscheduledTasks(
                  tasks: unscheduled,
                  memberLookup: memberLookup,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<_TaskAppointment> _buildAppointments(
    Project project,
    Map<String, Member> memberLookup,
  ) {
    final List<_TaskAppointment> entries = [];

    for (final task in project.tasks) {
      DateTime? start = task.startDate;
      DateTime? end = task.endDate;

      if (start == null && end == null) {
        continue;
      }

      if (start == null && end != null) {
        start = end.subtract(const Duration(hours: 2));
      }

      if (end == null && start != null) {
        end = start.add(const Duration(hours: 2));
      }

      if (start == null || end == null) {
        continue;
      }

      if (!end.isAfter(start)) {
        end = start.add(const Duration(hours: 1));
      }

      final assigneeName = task.assigneeId != null
          ? memberLookup[task.assigneeId]?.name
          : null;
      final meta = taskStatusMeta(task.status);

      entries.add(
        _TaskAppointment(
          task: task,
          startTime: start,
          endTime: end,
          color: meta.color,
          assigneeName: assigneeName,
        ),
      );
    }

    return entries;
  }

  void _handleDragEnd(
    AppointmentDragEndDetails details,
    Project project,
    ProjectController controller,
  ) {
    final appointment = details.appointment as Appointment;
    final taskId = _resolveTaskId(appointment);
    if (taskId == null) {
      return;
    }

    final task = _findTask(project, taskId);
    if (task == null) {
      return;
    }

    final originalStart = appointment.startTime;
    final originalEnd = appointment.endTime;
    final dropTime = details.droppingTime ?? originalStart;
    final duration = originalEnd.difference(originalStart);
    final safeDuration = duration <= Duration.zero
        ? const Duration(hours: 1)
        : duration;
    final newEnd = dropTime.add(safeDuration);

    controller.updateTaskSchedule(
      project.id,
      task.id,
      start: dropTime,
      end: newEnd,
    );
  }

  void _handleResize(
    AppointmentResizeEndDetails details,
    Project project,
    ProjectController controller,
  ) {
    final appointment = details.appointment as Appointment;
    final taskId = _resolveTaskId(appointment);
    if (taskId == null) {
      return;
    }

    final task = _findTask(project, taskId);
    if (task == null) {
      return;
    }

    final start = details.startTime ?? appointment.startTime;
    final end = details.endTime ?? appointment.endTime;

    if (!end.isAfter(start)) {
      return;
    }

    controller.updateTaskSchedule(project.id, task.id, start: start, end: end);
  }

  Widget _buildAppointment(
    BuildContext context,
    CalendarAppointmentDetails details,
    Project project,
  ) {
    final appointment = details.appointments.first;
    if (appointment is! _TaskAppointment) {
      return const SizedBox.shrink();
    }

    final task = appointment.task;
    final meta = taskStatusMeta(task.status);
    final assigneeName = appointment.assigneeName;
    final theme = Theme.of(context);

    final start = appointment.startTime;
    final end = appointment.endTime;
    final timeLabel =
        '${_formatCompactTime(start)} – ${_formatCompactTime(end)}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: meta.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: meta.border, width: 1.1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: meta.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                meta.label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: meta.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                timeLabel,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.hintTextfiled,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            task.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: AppColors.secondaryText,
              fontWeight: FontWeight.bold,
            ),
          ),
          if ((task.description ?? '').isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              task.description!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.secondaryText.withValues(alpha: 0.6),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if (assigneeName != null && assigneeName.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  FeatherIcons.user,
                  size: 14,
                  color: AppColors.hintTextfiled,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    assigneeName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.hintTextfiled,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String? _resolveTaskId(Appointment appointment) {
    if (appointment is _TaskAppointment) {
      return appointment.task.id;
    }
    final rawId = appointment.id;
    return rawId is String ? rawId : null;
  }

  Task? _findTask(Project project, String id) {
    for (final task in project.tasks) {
      if (task.id == id) {
        return task;
      }
    }
    return null;
  }

  String _formatCompactTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final suffix = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $suffix';
  }
}

class _TimelineHeader extends StatelessWidget {
  const _TimelineHeader({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.textfieldBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.textfieldBorder.withValues(alpha: 0.5),
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
                router.goNamed(
                  'projectDetail',
                  pathParameters: {'id': project.id},
                );
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
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.secondaryText,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Drag tasks on the timeline to reschedule',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
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

class _StatusLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: TaskStatus.values
          .map((status) {
            final meta = taskStatusMeta(status);
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                    decoration: BoxDecoration(
                      color: meta.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    meta.label,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppColors.secondaryText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          })
          .toList(growable: false),
    );
  }
}

class _UnscheduledTasks extends StatelessWidget {
  const _UnscheduledTasks({required this.tasks, required this.memberLookup});

  final List<Task> tasks;
  final Map<String, Member> memberLookup;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Needs scheduling',
          style: theme.textTheme.titleMedium?.copyWith(
            color: AppColors.secondaryText,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Column(
          children: tasks
              .map((task) {
                final meta = taskStatusMeta(task.status);
                final assignee = task.assigneeId != null
                    ? memberLookup[task.assigneeId]?.name
                    : null;
                final description = task.description;

                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.textfieldBackground,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppColors.textfieldBorder.withValues(alpha: 0.6),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: meta.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
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
                          Text(
                            meta.label,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: AppColors.hintTextfiled,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      if (description != null && description.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          description,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.hintTextfiled,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            FeatherIcons.info,
                            size: 14,
                            color: AppColors.hintTextfiled,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Set start and due dates to place this task on the timeline.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.hintTextfiled,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (assignee != null && assignee.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              FeatherIcons.user,
                              size: 14,
                              color: AppColors.hintTextfiled,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                assignee,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: AppColors.hintTextfiled,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                );
              })
              .toList(growable: false),
        ),
      ],
    );
  }
}

class _TaskTimelineDataSource extends CalendarDataSource {
  _TaskTimelineDataSource(List<_TaskAppointment> source) {
    appointments = source;
  }
}

class _TaskAppointment extends Appointment {
  _TaskAppointment({
    required this.task,
    required super.startTime,
    required super.endTime,
    required super.color,
    this.assigneeName,
  }) : super(subject: task.title, id: task.id);

  final Task task;
  final String? assigneeName;
}
