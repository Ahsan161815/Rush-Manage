import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:myapp/app/app_theme.dart';
import 'package:myapp/app/widgets/app_form_fields.dart';
import 'package:myapp/app/widgets/custom_nav_bar.dart';
import 'package:myapp/common/models/invitation.dart';
import 'package:myapp/common/models/message.dart';
import 'package:myapp/controllers/finance_controller.dart';
import 'package:myapp/controllers/project_controller.dart';
import 'package:myapp/models/project.dart';
import 'package:myapp/common/utils/project_ui.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

enum _HomeFocus { overview, finance, team }

class _HomeScreenState extends State<HomeScreen> {
  static const _greetingName = 'Dream';
  _HomeFocus _focus = _HomeFocus.overview;

  @override
  Widget build(BuildContext context) {
    final projectController = context.watch<ProjectController>();
    final financeController = context.watch<FinanceController>();
    final stats = _statsForFocus(projectController, financeController);
    final prioritizedProjects = _prioritizedProjects(
      projectController.projects,
    );
    final latestDocs = financeController.latestDocuments;
    final invitations = projectController.invitations;
    final unreadMessages = _unreadCount(projectController);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  20,
                  16,
                  20,
                  CustomNavBar.totalHeight + 48,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HomeHeader(
                      userName: _greetingName,
                      onNotificationsTap: () =>
                          context.pushNamed('invitationNotifications'),
                      onProfileTap: () => context.goNamed('profile'),
                    ),
                    const SizedBox(height: 18),
                    _FocusAndFilterBar(
                      focus: _focus,
                      onFocusChanged: (value) => setState(() => _focus = value),
                      controller: financeController,
                    ),
                    const SizedBox(height: 18),
                    _QuickStatsGrid(stats: stats),
                    const SizedBox(height: 20),
                    _QuickActions(
                      onCreateProject: () => context.goNamed('projectsCreate'),
                      onAddExpense: () => _showExpenseSheet(context),
                    ),
                    const SizedBox(height: 24),
                    _SectionHeader(
                      title: 'Recent projects',
                      actionLabel: 'View all',
                      onActionTap: () => context.goNamed('management'),
                    ),
                    const SizedBox(height: 12),
                    _ProjectSpotlightList(
                      projects: prioritizedProjects,
                      onProjectTap: (project) => context.goNamed(
                        'projectDetail',
                        pathParameters: {'id': project.id},
                      ),
                    ),
                    const SizedBox(height: 12),
                    _SectionHeader(
                      title: 'Latest finance activity',
                      actionLabel: 'Open finance',
                      onActionTap: () => context.goNamed('finance'),
                    ),
                    const SizedBox(height: 8),
                    _DocumentsList(documents: latestDocs),
                    const SizedBox(height: 18),
                    _SectionHeader(
                      title: 'Pending invitations',
                      actionLabel: 'Manage',
                      onActionTap: () =>
                          context.goNamed('invitationNotifications'),
                    ),
                    const SizedBox(height: 8),
                    _InvitesList(invitations: invitations),
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
              currentRouteName: 'home',
              unreadChatsCount: unreadMessages,
            ),
          ),
        ],
      ),
    );
  }

  List<Project> _prioritizedProjects(List<Project> projects) {
    final cloned = List<Project>.from(projects);
    cloned.sort((a, b) {
      final aDate = a.startDate ?? a.endDate ?? DateTime.now();
      final bDate = b.startDate ?? b.endDate ?? DateTime.now();
      return aDate.compareTo(bDate);
    });
    return cloned.take(2).toList(growable: false);
  }

  List<_QuickStatData> _statsForFocus(
    ProjectController projectController,
    FinanceController financeController,
  ) {
    final ongoing = projectController.projects
        .where((p) => p.status == ProjectStatus.ongoing)
        .length;
    final preparing = projectController.projects
        .where((p) => p.status == ProjectStatus.inPreparation)
        .length;
    final completed = projectController.projects
        .where((p) => p.status == ProjectStatus.completed)
        .length;
    final expenses = financeController.currentMonthExpensesTotal;
    final unpaid = financeController.unpaidTotal;
    final pendingQuotes = financeController.pendingQuotesCount;
    final balance = financeController.globalBalance;
    final variation = financeController.monthVariationPercent;

    switch (_focus) {
      case _HomeFocus.finance:
        return [
          _QuickStatData(
            title: 'Global balance',
            value: _formatCurrency(balance),
            change: '${variation.toStringAsFixed(0)}% vs last month',
            positive: variation >= 0,
            icon: Icons.account_balance_wallet_outlined,
            accent: AppColors.secondary,
          ),
          _QuickStatData(
            title: 'Unpaid invoices',
            value: _formatCurrency(unpaid),
            change: '${financeController.unpaidCount} open invoices',
            positive: unpaid == 0,
            icon: Icons.assignment_late_outlined,
            accent: AppColors.warning,
          ),
          _QuickStatData(
            title: 'Pending quotes',
            value: '$pendingQuotes awaiting',
            change: _focus == _HomeFocus.finance
                ? 'Keep signatures moving'
                : 'Review signatures',
            positive: pendingQuotes <= 1,
            icon: Icons.fact_check_outlined,
            accent: AppColors.orange,
          ),
          _QuickStatData(
            title: 'This month expenses',
            value: _formatCurrency(expenses),
            change: expenses <= balance
                ? 'Tracked inside budget'
                : 'Above budget',
            positive: expenses <= balance,
            icon: Icons.receipt_long,
            accent: AppColors.primary,
          ),
        ];
      case _HomeFocus.team:
        return [
          _QuickStatData(
            title: 'Running projects',
            value: '$ongoing active',
            change: 'Ensure owners have support',
            positive: true,
            icon: Icons.work_outline,
            accent: AppColors.secondary,
          ),
          _QuickStatData(
            title: 'In preparation',
            value: '$preparing starting soon',
            change: 'Check contracts & staffing',
            positive: preparing <= ongoing,
            icon: Icons.flag_outlined,
            accent: AppColors.orange,
          ),
          _QuickStatData(
            title: 'Completed this month',
            value: '$completed delivered',
            change: 'Celebrate small wins',
            positive: true,
            icon: Icons.emoji_events_outlined,
            accent: AppColors.success,
          ),
          _QuickStatData(
            title: 'Upcoming kickoff',
            value: _nextKickoffLabel(projectController.projects),
            change: 'Prep briefs before the date',
            positive: true,
            icon: Icons.calendar_today_outlined,
            accent: AppColors.primary,
          ),
        ];
      case _HomeFocus.overview:
        return [
          _QuickStatData(
            title: 'Global balance',
            value: _formatCurrency(balance),
            change: '${variation.toStringAsFixed(0)}% vs last month',
            positive: variation >= 0,
            icon: Icons.account_balance_wallet_outlined,
            accent: AppColors.secondary,
          ),
          _QuickStatData(
            title: 'Running projects',
            value: '$ongoing active',
            change: '$preparing queued next',
            positive: ongoing >= preparing,
            icon: Icons.timeline_outlined,
            accent: AppColors.primary,
          ),
          _QuickStatData(
            title: 'Pending quotes',
            value: '$pendingQuotes awaiting',
            change: 'Push follow-ups',
            positive: pendingQuotes <= 2,
            icon: Icons.fact_check_outlined,
            accent: AppColors.orange,
          ),
        ];
    }
  }

  int _unreadCount(ProjectController controller) {
    int count = 0;
    for (final project in controller.projects) {
      final msgs = controller.messagesFor(project.id);
      for (final msg in msgs) {
        final receipt = msg.receipts['me'];
        if (receipt != MessageReceiptStatus.read) count++;
      }
    }
    return count;
  }

  void _showExpenseSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add an expense',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.secondaryText,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Jump into Finance to log the spend and attach receipts.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.hintTextfiled,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: AppColors.primaryText,
                    backgroundColor: AppColors.secondary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.goNamed('finance');
                  },
                  child: const Text(
                    'Open Finance',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _nextKickoffLabel(List<Project> projects) {
    final now = DateTime.now();
    DateTime? nextStart;
    for (final project in projects) {
      final start = project.startDate;
      if (start == null || !start.isAfter(now)) continue;
      if (nextStart == null || start.isBefore(nextStart)) {
        nextStart = start;
      }
    }
    if (nextStart == null) return 'No upcoming';
    const monthLabels = [
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
    final month = monthLabels[nextStart.month - 1];
    return '$month ${nextStart.day}';
  }

  String _formatCurrency(double value) {
    return '€${value.toStringAsFixed(0)}';
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.userName,
    required this.onNotificationsTap,
    required this.onProfileTap,
  });

  final String userName;
  final VoidCallback onNotificationsTap;
  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(30)),
        gradient: LinearGradient(
          colors: [AppColors.secondary, AppColors.primary],
          begin: AlignmentDirectional(1.0, -0.4),
          end: AlignmentDirectional(-1.0, 0.6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.0),
                    width: 0,
                  ),
                  color: Colors.white.withValues(alpha: 0.0),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  'assets/images/app_launcher_icon.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, _, __) => Container(
                    color: AppColors.secondary,
                    alignment: Alignment.center,
                    child: Text(
                      'R',
                      style: textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hey, $userName',
                      style: textTheme.headlineSmall?.copyWith(
                        color: AppColors.primaryText,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Here is your workspace pulse for today.',
                      style: textTheme.labelLarge?.copyWith(
                        color: AppColors.primaryText.withValues(alpha: 0.85),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _HeaderIconButton(
                      icon: Icons.notifications_none,
                      onTap: onNotificationsTap,
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: onProfileTap,
                      child: const CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.primaryText,
                        child: Icon(
                          Icons.person,
                          size: 18,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Keep projects, finances, and team signals aligned.',
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.primaryText.withValues(alpha: 0.9),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, color: AppColors.primaryText, size: 20),
      ),
    );
  }
}

class _FocusAndFilterBar extends StatelessWidget {
  const _FocusAndFilterBar({
    required this.focus,
    required this.onFocusChanged,
    required this.controller,
  });

  final _HomeFocus focus;
  final ValueChanged<_HomeFocus> onFocusChanged;
  final FinanceController controller;

  @override
  Widget build(BuildContext context) {
    final chips = _HomeFocus.values.map((value) {
      final label = switch (value) {
        _HomeFocus.overview => 'Overview',
        _HomeFocus.finance => 'Finance',
        _HomeFocus.team => 'Team',
      };
      final icon = switch (value) {
        _HomeFocus.overview => Icons.dashboard_customize_outlined,
        _HomeFocus.finance => Icons.pie_chart_outline,
        _HomeFocus.team => Icons.groups_outlined,
      };
      return _FocusChip(
        label: label,
        icon: icon,
        selected: focus == value,
        onTap: () => onFocusChanged(value),
      );
    }).toList();

    final currentFilterLabel = _filterLabel(controller.timeFilter);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 46,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: chips.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) => chips[index],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
          decoration: BoxDecoration(
            color: AppColors.secondaryBackground,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.textfieldBorder, width: 1),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Finance window',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.secondaryText,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Showing $currentFilterLabel metrics',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.hintTextfiled,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 150,
                child: AppDropdownField<TimeFilter>(
                  items: const [
                    TimeFilter.week,
                    TimeFilter.month,
                    TimeFilter.year,
                  ],
                  value: controller.timeFilter,
                  hintText: 'Period',
                  compact: true,
                  labelBuilder: _filterLabel,
                  onChanged: (filter) {
                    if (filter != null) {
                      controller.setTimeFilter(filter);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _filterLabel(TimeFilter filter) {
    switch (filter) {
      case TimeFilter.week:
        return 'Week';
      case TimeFilter.month:
        return 'Month';
      case TimeFilter.year:
        return 'Year';
    }
  }
}

class _FocusChip extends StatelessWidget {
  const _FocusChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
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
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? Colors.transparent : AppColors.textfieldBorder,
            width: 1.2,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.secondary.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 10),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? AppColors.primaryText : AppColors.secondaryText,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: selected
                    ? AppColors.primaryText
                    : AppColors.secondaryText,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickStatsGrid extends StatelessWidget {
  const _QuickStatsGrid({required this.stats});

  final List<_QuickStatData> stats;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final isWide = maxWidth >= 700;
        final itemWidth = isWide ? (maxWidth - 16) / 2 : maxWidth;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: stats.map((stat) {
            return SizedBox(
              width: itemWidth,
              child: _QuickStatCard(data: stat),
            );
          }).toList(),
        );
      },
    );
  }
}

class _QuickStatData {
  const _QuickStatData({
    required this.title,
    required this.value,
    required this.change,
    required this.positive,
    required this.icon,
    required this.accent,
  });

  final String title;
  final String value;
  final String change;
  final bool positive;
  final IconData icon;
  final Color accent;
}

class _QuickStatCard extends StatelessWidget {
  const _QuickStatCard({required this.data});

  final _QuickStatData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: data.accent.withValues(alpha: 0.35),
          width: 1.1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 12,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: data.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(data.icon, color: data.accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  data.title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.hintTextfiled,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            data.value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.secondaryText,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            data.change,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: data.positive ? data.accent : AppColors.warning,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.onCreateProject,
    required this.onAddExpense,
  });

  final VoidCallback onCreateProject;
  final VoidCallback onAddExpense;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final isWide = maxWidth >= 700;
        final itemWidth = isWide ? (maxWidth - 16) / 2 : maxWidth;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            SizedBox(
              width: itemWidth,
              child: _ActionCard(
                title: 'Create project',
                description: 'Spin up a scoped workspace in seconds.',
                icon: Icons.bolt,
                onTap: onCreateProject,
                accent: AppColors.primary,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: _ActionCard(
                title: 'Add expense',
                description: 'Log spend and attach receipts.',
                icon: Icons.receipt_long,
                onTap: onAddExpense,
                accent: AppColors.secondary,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
    required this.accent,
  });

  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.secondaryBackground,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: accent.withValues(alpha: 0.35), width: 1.2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 12,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: accent),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.secondaryText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.hintTextfiled,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.hintTextfiled),
          ],
        ),
      ),
    );
  }
}

class _ProjectSpotlightList extends StatelessWidget {
  const _ProjectSpotlightList({
    required this.projects,
    required this.onProjectTap,
  });

  final List<Project> projects;
  final ValueChanged<Project> onProjectTap;

  @override
  Widget build(BuildContext context) {
    if (projects.isEmpty) {
      return const _EmptyProjectsState();
    }

    return Column(
      children: projects
          .map(
            (project) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ProjectSpotlightCard(
                project: project,
                onTap: () => onProjectTap(project),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _ProjectSpotlightCard extends StatelessWidget {
  const _ProjectSpotlightCard({required this.project, required this.onTap});

  final Project project;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final meta = projectStatusMeta(project.status);
    final textTheme = Theme.of(context).textTheme;
    final timeline = _timelineLabel(project.startDate, project.endDate);
    final clientLabel = project.client.isEmpty
        ? 'Internal project'
        : project.client;
    final progressValue = (project.progress.clamp(0, 100)) / 100;

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.secondaryBackground,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: meta.border, width: 1.2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 18,
              offset: Offset(0, 8),
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
                  child: Text(
                    project.name,
                    style: textTheme.titleMedium?.copyWith(
                      color: AppColors.secondaryText,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: meta.background,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    meta.label,
                    style: textTheme.labelSmall?.copyWith(
                      color: meta.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              clientLabel,
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.hintTextfiled,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progressValue.toDouble(),
                minHeight: 7,
                backgroundColor: AppColors.textfieldBorder.withValues(
                  alpha: 0.3,
                ),
                valueColor: AlwaysStoppedAnimation<Color>(meta.color),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: AppColors.hintTextfiled,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    timeline,
                    style: textTheme.labelMedium?.copyWith(
                      color: AppColors.secondaryText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.hintTextfiled),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _timelineLabel(DateTime? start, DateTime? end) {
    if (start == null && end == null) return 'Timeline to be defined';
    String format(DateTime date) {
      final day = date.day.toString().padLeft(2, '0');
      return '$day ${_monthLabel(date.month)}';
    }

    if (start != null && end != null) {
      return '${format(start)} → ${format(end)}';
    }
    if (start != null) {
      return 'Kickoff ${format(start)}';
    }
    return 'Due ${format(end!)}';
  }

  String _monthLabel(int month) {
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
    return months[month - 1];
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onActionTap,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onActionTap;

  @override
  Widget build(BuildContext context) {
    return Row(
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
        TextButton(onPressed: onActionTap, child: Text(actionLabel)),
      ],
    );
  }
}

class _DocumentsList extends StatelessWidget {
  const _DocumentsList({required this.documents});

  final List<String> documents;

  @override
  Widget build(BuildContext context) {
    if (documents.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.secondaryBackground,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.textfieldBorder, width: 1),
        ),
        child: Text(
          'No recent documents in this window.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.hintTextfiled,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    final entries = documents.take(4).toList().asMap().entries;

    return Column(
      children: entries.map((entry) {
        final index = entry.key + 1;
        final doc = entry.value;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.secondaryBackground,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.textfieldBorder, width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Text(
                  '#$index',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doc,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.secondaryText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Finance workspace',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.hintTextfiled,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.hintTextfiled),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _InvitesList extends StatelessWidget {
  const _InvitesList({required this.invitations});

  final List<Invitation> invitations;

  @override
  Widget build(BuildContext context) {
    if (invitations.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.secondaryBackground,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.textfieldBorder, width: 1),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 12,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Text(
          'No pending invitations right now.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.hintTextfiled,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return Column(
      children: invitations.take(3).map((invitation) {
        final statusColor = _statusColor(invitation.status);
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.secondaryBackground,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.textfieldBorder, width: 1),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F000000),
                blurRadius: 12,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.textfieldBackground,
                ),
                alignment: Alignment.center,
                child: Text(
                  invitation.inviteeName[0],
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.secondaryText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      invitation.inviteeName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.secondaryText,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      invitation.projectName,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.hintTextfiled,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      invitation.status.label,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tap to review',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.hintTextfiled,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: AppColors.hintTextfiled),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _statusColor(InvitationStatus status) {
    switch (status) {
      case InvitationStatus.pending:
        return AppColors.secondary;
      case InvitationStatus.accepted:
        return AppColors.success;
      case InvitationStatus.declined:
        return AppColors.warning;
    }
  }
}

extension on InvitationStatus {
  String get label {
    switch (this) {
      case InvitationStatus.pending:
        return 'Pending';
      case InvitationStatus.accepted:
        return 'Accepted';
      case InvitationStatus.declined:
        return 'Declined';
    }
  }
}

class _EmptyProjectsState extends StatelessWidget {
  const _EmptyProjectsState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 30),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.textfieldBorder, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.textfieldBackground,
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.folder_open,
              size: 30,
              color: AppColors.hintTextfiled,
            ),
          ),
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
            'Create a project to start tracking progress here.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.hintTextfiled,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
