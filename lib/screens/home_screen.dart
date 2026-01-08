import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:myapp/app/app_theme.dart';
import 'package:myapp/app/widgets/custom_nav_bar.dart';
import 'package:myapp/common/localization/formatters.dart';
import 'package:myapp/common/localization/l10n_extensions.dart';
import 'package:myapp/common/models/message.dart';
import 'package:myapp/controllers/finance_controller.dart';
import 'package:myapp/controllers/project_controller.dart';
import 'package:myapp/controllers/user_controller.dart';
import 'package:myapp/l10n/app_localizations.dart';
import 'package:myapp/models/project.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final projectController = context.watch<ProjectController>();
    final financeController = context.watch<FinanceController>();
    final userController = context.watch<UserController>();
    final loc = context.l10n;
    final userName =
        userController.profile?.firstName ??
        userController.profile?.displayName ??
        'Crew';
    final avatarUrl = userController.profile?.avatarUrl;
    final userInitials = _initialsFromName(userName);
    final unreadMessages = _unreadCount(projectController);
    final financeSnapshot = _FinanceSnapshot(
      collectedTotal: financeController.globalBalance,
      unpaidTotal: financeController.unpaidTotal,
      unpaidCount: financeController.unpaidCount,
      variationPercent: financeController.monthVariationPercent,
    );
    final projectSnapshot = _ProjectSnapshot.fromProjects(
      projectController.projects,
    );
    final activities = _latestMessageActivities(projectController, loc);

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
                      userName: userName,
                      avatarUrl: avatarUrl,
                      initials: userInitials,
                      loc: loc,
                      onNotificationsTap: () =>
                          context.pushNamed('invitationNotifications'),
                      onProfileTap: () => context.goNamed('profile'),
                    ),
                    const SizedBox(height: 18),
                    _FinanceOverviewCard(
                      snapshot: financeSnapshot,
                      loc: loc,
                      onCreateInvoice: () =>
                          context.pushNamed('financeCreateInvoiceForm'),
                      onOpenFinance: () => context.goNamed('finance'),
                    ),
                    const SizedBox(height: 18),
                    _ProjectsHealthCard(
                      stats: projectSnapshot,
                      loc: loc,
                      onCreateProject: () => context.goNamed('projectsCreate'),
                      onOpenProjects: () => context.goNamed('management'),
                    ),
                    const SizedBox(height: 18),
                    _MessagesActivityCard(
                      unreadCount: unreadMessages,
                      activities: activities,
                      loc: loc,
                      onOpenMessages: () => context.goNamed('chats'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomNavBar(currentRouteName: 'home'),
          ),
        ],
      ),
    );
  }

  String _initialsFromName(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((segment) => segment.isNotEmpty)
        .toList(growable: false);

    if (parts.isEmpty) {
      return 'RM';
    }
    if (parts.length == 1) {
      return parts.first[0].toUpperCase();
    }
    final first = parts.first[0].toUpperCase();
    final last = parts.last[0].toUpperCase();
    return '$first$last';
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

  List<_MessageActivity> _latestMessageActivities(
    ProjectController controller,
    AppLocalizations loc,
  ) {
    final entries = <_MessageActivity>[];
    for (final project in controller.projects) {
      final messages = controller.messagesFor(project.id);
      for (final message in messages) {
        entries.add(
          _MessageActivity(
            projectName: project.name,
            author: _resolveAuthorLabel(controller, message.authorId, loc),
            preview: message.body,
            sentAt: message.sentAt,
          ),
        );
      }
    }
    entries.sort((a, b) => b.sentAt.compareTo(a.sentAt));
    return entries.take(2).toList(growable: false);
  }

  String _resolveAuthorLabel(
    ProjectController controller,
    String authorId,
    AppLocalizations loc,
  ) {
    if (authorId == 'me') return loc.homeAuthorYou;
    for (final project in controller.projects) {
      for (final member in project.members) {
        if (member.id == authorId) {
          final contact = controller.contactForMember(member);
          return contact?.name ?? member.name;
        }
      }
    }
    return loc.homeCollaboratorFallback;
  }
}

String _truncatePreview(String text, [int maxLength = 85]) {
  if (text.length <= maxLength) return text;
  return '${text.substring(0, maxLength).trim()}...';
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.userName,
    required this.avatarUrl,
    required this.initials,
    required this.loc,
    required this.onNotificationsTap,
    required this.onProfileTap,
  });

  final String userName;
  final String? avatarUrl;
  final String initials;
  final AppLocalizations loc;
  final VoidCallback onNotificationsTap;
  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final hasAvatar = avatarUrl != null && avatarUrl!.isNotEmpty;

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
                      loc.homeGreeting(userName),
                      style: textTheme.headlineSmall?.copyWith(
                        color: AppColors.primaryText,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      loc.homePulseSubtitle,
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
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.primaryText,
                        child: hasAvatar
                            ? ClipOval(
                                child: Image.network(
                                  avatarUrl!,
                                  fit: BoxFit.cover,
                                  width: 32,
                                  height: 32,
                                  errorBuilder: (_, __, ___) =>
                                      _InitialsBadge(initials: initials),
                                ),
                              )
                            : _InitialsBadge(initials: initials),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            loc.homePulseDescription,
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

class _InitialsBadge extends StatelessWidget {
  const _InitialsBadge({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    final labelStyle =
        Theme.of(context).textTheme.labelLarge ??
        Theme.of(context).textTheme.bodyMedium ??
        const TextStyle();

    return Text(
      initials,
      style: labelStyle.copyWith(
        color: AppColors.primary,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _FinanceOverviewCard extends StatelessWidget {
  const _FinanceOverviewCard({
    required this.snapshot,
    required this.loc,
    required this.onCreateInvoice,
    required this.onOpenFinance,
  });

  final _FinanceSnapshot snapshot;
  final AppLocalizations loc;
  final VoidCallback onCreateInvoice;
  final VoidCallback onOpenFinance;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final collectedLabel = formatCurrency(context, snapshot.collectedTotal);
    final unpaidLabel = formatCurrency(context, snapshot.unpaidTotal);
    final variationValue =
        '${snapshot.variationPercent >= 0 ? '+' : ''}${snapshot.variationPercent.toStringAsFixed(0)}';
    final variationLabel = loc.homeVariationLabel(variationValue);
    final unpaidCountLabel = loc.homeUnpaidWaiting(snapshot.unpaidCount);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(30)),
        gradient: LinearGradient(
          colors: [AppColors.secondary, AppColors.primary],
          begin: AlignmentDirectional(1.0, -0.2),
          end: AlignmentDirectional(-1.0, 0.9),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.homeFinanceOverviewTitle,
            style: textTheme.titleLarge?.copyWith(
              color: AppColors.primaryText,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            loc.homeFinanceCollected,
            style: textTheme.labelLarge?.copyWith(
              color: AppColors.primaryText.withValues(alpha: 0.85),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            collectedLabel,
            style: textTheme.displaySmall?.copyWith(
              color: AppColors.primaryText,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _HighlightPill(
            icon: Icons.trending_up,
            label: variationLabel,
            background: Colors.white.withValues(alpha: 0.15),
            foreground: AppColors.primaryText,
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.homeFinanceUnpaid,
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.primaryText,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        unpaidLabel,
                        style: textTheme.titleLarge?.copyWith(
                          color: AppColors.primaryText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        unpaidCountLabel,
                        style: textTheme.labelSmall?.copyWith(
                          color: AppColors.primaryText.withValues(alpha: 0.75),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.assignment_turned_in_outlined,
                  color: AppColors.primaryText,
                  size: 32,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: AppColors.primary,
                backgroundColor: AppColors.primaryText,
                minimumSize: const Size.fromHeight(54),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              onPressed: onCreateInvoice,
              child: Text(
                loc.homeFinanceCreateInvoice,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          TextButton(
            onPressed: onOpenFinance,
            style: TextButton.styleFrom(foregroundColor: AppColors.primaryText),
            child: Text(loc.homeFinanceOpenWorkspace),
          ),
        ],
      ),
    );
  }
}

class _ProjectsHealthCard extends StatelessWidget {
  const _ProjectsHealthCard({
    required this.stats,
    required this.loc,
    required this.onCreateProject,
    required this.onOpenProjects,
  });

  final _ProjectSnapshot stats;
  final AppLocalizations loc;
  final VoidCallback onCreateProject;
  final VoidCallback onOpenProjects;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.textfieldBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.palette_outlined, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                loc.homeProjectsHealth,
                style: textTheme.titleLarge?.copyWith(
                  color: AppColors.secondaryText,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              const spacing = 12.0;
              final availableWidth =
                  constraints.maxWidth.isFinite && constraints.maxWidth > 0
                  ? constraints.maxWidth
                  : MediaQuery.of(context).size.width;
              final int columns;
              if (availableWidth >= 720) {
                columns = 3;
              } else if (availableWidth >= 480) {
                columns = 2;
              } else {
                columns = 1;
              }
              final tileWidth =
                  (availableWidth - spacing * (columns - 1)) /
                  columns.clamp(1, 3);

              Widget buildStat({
                required String label,
                required String value,
                required String subtitle,
                required Color accentColor,
              }) {
                return SizedBox(
                  width: tileWidth,
                  child: _ProjectKpiStat(
                    label: label,
                    value: value,
                    subtitle: subtitle,
                    accent: accentColor,
                  ),
                );
              }

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  buildStat(
                    label: loc.homeProjectsActiveLabel,
                    value: stats.activeProjects.toString(),
                    subtitle: loc.homeProjectsActiveSubtitle,
                    accentColor: AppColors.primary,
                  ),
                  buildStat(
                    label: loc.homeProjectsLateLabel,
                    value: stats.lateProjects.toString(),
                    subtitle: loc.homeProjectsLateSubtitle,
                    accentColor: AppColors.warning,
                  ),
                  buildStat(
                    label: loc.homeProjectsCompletedLabel,
                    value: stats.completedThisMonth.toString(),
                    subtitle: loc.homeProjectsCompletedSubtitle,
                    accentColor: AppColors.success,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.primaryText,
                minimumSize: const Size.fromHeight(54),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              onPressed: onCreateProject,
              child: Text(
                loc.homeCreateProject,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          TextButton(
            onPressed: onOpenProjects,
            child: Text(loc.homeOpenProjects),
          ),
        ],
      ),
    );
  }
}

class _ProjectKpiStat extends StatelessWidget {
  const _ProjectKpiStat({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.accent,
  });

  final String label;
  final String value;
  final String subtitle;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 136),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.textfieldBorder, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: textTheme.labelLarge?.copyWith(
                color: AppColors.hintTextfiled,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: textTheme.headlineMedium?.copyWith(
                color: accent,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: textTheme.labelSmall?.copyWith(
                color: AppColors.secondaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessagesActivityCard extends StatelessWidget {
  const _MessagesActivityCard({
    required this.unreadCount,
    required this.activities,
    required this.loc,
    required this.onOpenMessages,
  });

  final int unreadCount;
  final List<_MessageActivity> activities;
  final AppLocalizations loc;
  final VoidCallback onOpenMessages;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.textfieldBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                loc.homeMessagesTitle,
                style: textTheme.titleLarge?.copyWith(
                  color: AppColors.secondaryText,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              _HighlightPill(
                icon: Icons.mark_unread_chat_alt_outlined,
                label: loc.homeUnreadCount(unreadCount),
                background: AppColors.warning.withValues(alpha: 0.15),
                foreground: AppColors.warning,
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (activities.isEmpty)
            Text(
              loc.homeMessagesEmpty,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.hintTextfiled,
                fontWeight: FontWeight.w600,
              ),
            )
          else ...[
            for (final activity in activities)
              _MessageActivityTile(activity: activity),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.secondary,
                side: const BorderSide(color: AppColors.secondary, width: 1.2),
                minimumSize: const Size.fromHeight(54),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              onPressed: onOpenMessages,
              child: Text(
                loc.homeOpenMessages,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageActivityTile extends StatelessWidget {
  const _MessageActivityTile({required this.activity});

  final _MessageActivity activity;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.textfieldBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  activity.projectName,
                  style: textTheme.titleMedium?.copyWith(
                    color: AppColors.secondaryText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                formatRelativeTime(context, activity.sentAt),
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.hintTextfiled,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${activity.author} · ${_truncatePreview(activity.preview)}',
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.secondaryText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _HighlightPill extends StatelessWidget {
  const _HighlightPill({
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
  });

  final IconData icon;
  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: foreground),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _FinanceSnapshot {
  const _FinanceSnapshot({
    required this.collectedTotal,
    required this.unpaidTotal,
    required this.unpaidCount,
    required this.variationPercent,
  });

  final double collectedTotal;
  final double unpaidTotal;
  final int unpaidCount;
  final double variationPercent;
}

class _ProjectSnapshot {
  const _ProjectSnapshot({
    required this.activeProjects,
    required this.lateProjects,
    required this.completedThisMonth,
  });

  final int activeProjects;
  final int lateProjects;
  final int completedThisMonth;

  factory _ProjectSnapshot.fromProjects(List<Project> projects) {
    final now = DateTime.now();
    var active = 0;
    var late = 0;
    var completed = 0;

    for (final project in projects) {
      final status = project.status;
      if (status == ProjectStatus.inPreparation ||
          status == ProjectStatus.ongoing) {
        active++;
      }

      final end = project.endDate;
      final isClosed =
          status == ProjectStatus.completed || status == ProjectStatus.archived;
      if (end != null && end.isBefore(now) && !isClosed) {
        late++;
      }

      if (status == ProjectStatus.completed &&
          end != null &&
          end.year == now.year &&
          end.month == now.month) {
        completed++;
      }
    }

    return _ProjectSnapshot(
      activeProjects: active,
      lateProjects: late,
      completedThisMonth: completed,
    );
  }
}

class _MessageActivity {
  const _MessageActivity({
    required this.projectName,
    required this.author,
    required this.preview,
    required this.sentAt,
  });

  final String projectName;
  final String author;
  final String preview;
  final DateTime sentAt;
}
