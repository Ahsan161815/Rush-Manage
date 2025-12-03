import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import 'package:myapp/app/app_theme.dart';
import 'package:myapp/common/utils/project_ui.dart';
import 'package:myapp/controllers/project_controller.dart';
import 'package:myapp/models/project.dart';

enum _ScheduleMode { calendar, timeline }

class ProjectScheduleScreen extends StatefulWidget {
  const ProjectScheduleScreen({super.key, required this.projectId});

  final String projectId;

  @override
  State<ProjectScheduleScreen> createState() => _ProjectScheduleScreenState();
}

class _ProjectScheduleScreenState extends State<ProjectScheduleScreen> {
  late final CalendarController _controller;
  _ScheduleMode _mode = _ScheduleMode.timeline;
  DateTime _displayDate = DateTime.now();
  bool _showUnscheduled = false; // collapsible unscheduled section state

  @override
  void initState() {
    super.initState();
    _controller = CalendarController()..view = CalendarView.timelineWeek;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setMode(_ScheduleMode mode) {
    if (_mode == mode) return;
    setState(() {
      _mode = mode;
      // Preserve displayDate when switching modes.
      if (mode == _ScheduleMode.calendar) {
        _controller.view = CalendarView.week; // default calendar view
      } else {
        _controller.view = CalendarView.timelineWeek; // default timeline view
      }
      _controller.displayDate = _displayDate;
    });
  }

  void _navigateInterval(int direction) {
    final view = _controller.view;
    final base = _displayDate;
    DateTime next;
    switch (view) {
      case CalendarView.day:
      case CalendarView.timelineDay:
        next = base.add(Duration(days: direction));
        break;
      case CalendarView.week:
      case CalendarView.workWeek:
      case CalendarView.timelineWeek:
      case CalendarView.timelineWorkWeek:
        next = base.add(Duration(days: 7 * direction));
        break;
      case CalendarView.month:
      case CalendarView.timelineMonth:
        next = DateTime(base.year, base.month + direction, 1);
        break;
      default:
        next = base;
    }
    setState(() {
      _displayDate = next;
      _controller.displayDate = _displayDate;
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ProjectController>();
    final project = controller.getById(widget.projectId);
    final media = MediaQuery.of(context);
    final isMobile = media.size.width < 600; // simple breakpoint

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

    final memberLookup = {for (final m in project.members) m.id: m};
    final appointments = _buildAppointments(project, memberLookup);
    final unscheduled = project.tasks
        .where((t) => t.startDate == null && t.endDate == null)
        .toList();
    final dataSource = _TaskDataSource(appointments);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : 24,
            vertical: isMobile ? 12 : 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(
                project: project,
                mode: _mode,
                controller: _controller,
                onModeChanged: _setMode,
                onPrev: () => _navigateInterval(-1),
                onNext: () => _navigateInterval(1),
                isMobile: isMobile,
              ),
              SizedBox(height: isMobile ? 12 : 20),
              _StatusLegend(horizontalScroll: isMobile),
              SizedBox(height: isMobile ? 12 : 16),
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
                    controller: _controller,
                    view: _controller.view ?? CalendarView.week,
                    allowedViews: const [
                      CalendarView.day,
                      CalendarView.week,
                      CalendarView.workWeek,
                      CalendarView.month,
                      CalendarView.timelineDay,
                      CalendarView.timelineWeek,
                      CalendarView.timelineWorkWeek,
                      CalendarView.timelineMonth,
                    ],
                    dataSource: dataSource,
                    headerHeight: 48,
                    showDatePickerButton: true,
                    viewNavigationMode: ViewNavigationMode.snap,
                    allowDragAndDrop: true,
                    allowAppointmentResize: true,
                    onDragEnd: (d) => _handleDragEnd(d, project, controller),
                    onAppointmentResizeEnd: (d) =>
                        _handleResize(d, project, controller),
                    minDate: DateTime.now().subtract(const Duration(days: 365)),
                    maxDate: DateTime.now().add(const Duration(days: 365)),
                    timeSlotViewSettings: TimeSlotViewSettings(
                      timeIntervalHeight: isMobile ? 52 : 60,
                      timelineAppointmentHeight: isMobile ? 56 : 70,
                      timeInterval: const Duration(hours: 1),
                      timeIntervalWidth: isMobile ? 72 : 120,
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
                SizedBox(height: isMobile ? 12 : 24),
                GestureDetector(
                  onTap: () =>
                      setState(() => _showUnscheduled = !_showUnscheduled),
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Needs scheduling (${unscheduled.length})',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: AppColors.secondaryText,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      AnimatedRotation(
                        turns: _showUnscheduled ? 0.5 : 0,
                        duration: const Duration(milliseconds: 180),
                        child: const Icon(
                          FeatherIcons.chevronDown,
                          color: AppColors.hintTextfiled,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Padding(
                    padding: EdgeInsets.only(top: isMobile ? 8 : 12),
                    child: _UnscheduledTasks(
                      tasks: unscheduled,
                      memberLookup: memberLookup,
                      compact: isMobile,
                    ),
                  ),
                  crossFadeState: _showUnscheduled
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 200),
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
    final List<_TaskAppointment> list = [];
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
      // Round boundaries to hour for visual consistency.
      start = DateTime(start.year, start.month, start.day, start.hour);
      end = DateTime(end.year, end.month, end.day, end.hour);
      final assigneeName = task.assigneeId != null
          ? memberLookup[task.assigneeId]?.name
          : null;
      final meta = taskStatusMeta(task.status);
      list.add(
        _TaskAppointment(
          task: task,
          startTime: start,
          endTime: end,
          color: meta.color,
          assigneeName: assigneeName,
        ),
      );
    }
    return list;
  }

  void _handleDragEnd(
    AppointmentDragEndDetails details,
    Project project,
    ProjectController controller,
  ) {
    final a = details.appointment as Appointment;
    final taskId = _resolveTaskId(a);
    if (taskId == null) return;
    final task = _findTask(project, taskId);
    if (task == null) return;
    final originalStart = a.startTime;
    final originalEnd = a.endTime;
    final drop = details.droppingTime ?? originalStart;
    final roundedStart = DateTime(drop.year, drop.month, drop.day, drop.hour);
    final originalDuration = originalEnd.difference(originalStart);
    int hours = (originalDuration.inMinutes / 60).round();
    if (hours < 1) hours = 1;
    final newEnd = roundedStart.add(Duration(hours: hours));
    controller.updateTaskSchedule(
      project.id,
      task.id,
      start: roundedStart,
      end: newEnd,
    );
  }

  void _handleResize(
    AppointmentResizeEndDetails details,
    Project project,
    ProjectController controller,
  ) {
    final a = details.appointment as Appointment;
    final taskId = _resolveTaskId(a);
    if (taskId == null) return;
    final task = _findTask(project, taskId);
    if (task == null) return;
    final start = (details.startTime ?? a.startTime);
    final end = (details.endTime ?? a.endTime);
    final rs = DateTime(start.year, start.month, start.day, start.hour);
    final re = DateTime(end.year, end.month, end.day, end.hour);
    if (!re.isAfter(rs)) return;
    controller.updateTaskSchedule(project.id, task.id, start: rs, end: re);
  }

  Widget _buildAppointment(
    BuildContext context,
    CalendarAppointmentDetails details,
    Project project,
  ) {
    final appt = details.appointments.first;
    if (appt is! _TaskAppointment) return const SizedBox.shrink();
    final task = appt.task;
    final meta = taskStatusMeta(task.status);
    final theme = Theme.of(context);
    final start = appt.startTime;
    final end = appt.endTime;
    final timeLabel = '${_formatCompact(start)} – ${_formatCompact(end)}';
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
          if (appt.assigneeName != null && appt.assigneeName!.isNotEmpty) ...[
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
                    appt.assigneeName!,
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

  String? _resolveTaskId(Appointment a) {
    if (a is _TaskAppointment) return a.task.id;
    return a.id is String ? a.id as String : null;
  }

  Task? _findTask(Project project, String id) {
    for (final t in project.tasks) {
      if (t.id == id) return t;
    }
    return null;
  }

  String _formatCompact(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $s';
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.project,
    required this.mode,
    required this.controller,
    required this.onModeChanged,
    required this.onPrev,
    required this.onNext,
    this.isMobile = false,
  });

  final Project project;
  final _ScheduleMode mode;
  final CalendarController controller;
  final ValueChanged<_ScheduleMode> onModeChanged;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    final view = controller.view;
    final date = controller.displayDate ?? DateTime.now();
    String rangeLabel;
    if (view == CalendarView.month || view == CalendarView.timelineMonth) {
      rangeLabel = '${_monthName(date.month)} ${date.year}';
    } else if (view == CalendarView.week ||
        view == CalendarView.workWeek ||
        view == CalendarView.timelineWeek ||
        view == CalendarView.timelineWorkWeek) {
      final startOfWeek = date.subtract(Duration(days: date.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 6));
      rangeLabel =
          '${startOfWeek.day} ${_monthName(startOfWeek.month)} – ${endOfWeek.day} ${_monthName(endOfWeek.month)}';
    } else {
      rangeLabel = '${date.day} ${_monthName(date.month)} ${date.year}';
    }

    if (!isMobile) {
      return Row(
        children: [
          _BackButton(project: project),
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
                  'Drag tasks to reschedule · Resize to adjust duration',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.hintTextfiled,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _ViewModeToggle(mode: mode, onChanged: onModeChanged),
          const SizedBox(width: 12),
          _Pager(onPrev: onPrev, onNext: onNext, label: rangeLabel),
        ],
      );
    }

    // Mobile layout: stacked with wrapping to avoid overflow.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _BackButton(project: project),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                project.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.secondaryText,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            _ViewModeToggle(mode: mode, onChanged: onModeChanged),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(
                'Drag · Resize tasks',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.hintTextfiled,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            _Pager(onPrev: onPrev, onNext: onNext, label: rangeLabel),
          ],
        ),
      ],
    );
  }

  String _monthName(int m) {
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
    return months[m - 1];
  }
}

class _ViewModeToggle extends StatelessWidget {
  const _ViewModeToggle({required this.mode, required this.onChanged});
  final _ScheduleMode mode;
  final ValueChanged<_ScheduleMode> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget buildButton(String label, _ScheduleMode value) {
      final selected = mode == value;
      return GestureDetector(
        onTap: () => onChanged(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: selected
                ? const LinearGradient(
                    colors: [AppColors.secondary, AppColors.primary],
                    begin: AlignmentDirectional(1.0, 0.34),
                    end: AlignmentDirectional(-1.0, -0.34),
                  )
                : null,
            color: selected ? null : AppColors.textfieldBackground,
            border: Border.all(
              color: selected ? Colors.transparent : AppColors.textfieldBorder,
            ),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: selected ? AppColors.primaryText : AppColors.secondaryText,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        buildButton('Cal', _ScheduleMode.calendar),
        const SizedBox(width: 6),
        buildButton('Time', _ScheduleMode.timeline),
      ],
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.project});
  final Project project;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.textfieldBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.textfieldBorder.withValues(alpha: 0.5),
        ),
      ),
      child: IconButton(
        visualDensity: VisualDensity.compact,
        icon: const Icon(
          FeatherIcons.arrowLeft,
          size: 18,
          color: AppColors.secondaryText,
        ),
        onPressed: () {
          final router = GoRouter.of(context);
          if (router.canPop()) {
            router.pop();
          } else {
            router.goNamed('projectDetail', pathParameters: {'id': project.id});
          }
        },
      ),
    );
  }
}

class _Pager extends StatelessWidget {
  const _Pager({
    required this.onPrev,
    required this.onNext,
    required this.label,
  });
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final String label;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.textfieldBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.textfieldBorder.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Icon(
              FeatherIcons.chevronLeft,
              size: 18,
              color: AppColors.secondaryText,
            ),
            onPressed: onPrev,
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.secondaryText,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Icon(
              FeatherIcons.chevronRight,
              size: 18,
              color: AppColors.secondaryText,
            ),
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
}

class _StatusLegend extends StatelessWidget {
  const _StatusLegend({this.horizontalScroll = false});
  final bool horizontalScroll;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = TaskStatus.values
        .map((s) {
          final meta = taskStatusMeta(s);
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            margin: EdgeInsets.only(
              right: horizontalScroll ? 12 : 0,
              bottom: horizontalScroll ? 0 : 12,
            ),
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
        .toList(growable: false);
    if (horizontalScroll) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: items),
      );
    }
    return Wrap(spacing: 12, runSpacing: 12, children: items);
  }
}

class _UnscheduledTasks extends StatelessWidget {
  const _UnscheduledTasks({
    required this.tasks,
    required this.memberLookup,
    this.compact = false,
  });
  final List<Task> tasks;
  final Map<String, Member> memberLookup;
  final bool compact;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!compact) ...[
          Text(
            'Needs scheduling',
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.secondaryText,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
        ],
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
                  margin: EdgeInsets.only(bottom: compact ? 8 : 12),
                  padding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: compact ? 10 : 14,
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

class _TaskDataSource extends CalendarDataSource {
  _TaskDataSource(List<_TaskAppointment> src) {
    appointments = src;
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
