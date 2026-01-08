import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:myapp/app/app_theme.dart';
import 'package:myapp/app/widgets/custom_nav_bar.dart';
import 'package:myapp/app/widgets/gradient_button.dart';
import 'package:myapp/common/localization/l10n_extensions.dart';
import 'package:myapp/common/models/collaborator_contact.dart';
import 'package:myapp/controllers/project_controller.dart';
import 'package:myapp/l10n/app_localizations.dart';
import 'package:myapp/models/project.dart';

class CollaboratorProfileScreen extends StatelessWidget {
  const CollaboratorProfileScreen({super.key, required this.collaboratorId});

  final String collaboratorId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = context.l10n;
    final controller = context.watch<ProjectController>();
    final profile = _buildProfile(controller, loc);

    if (profile == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              FeatherIcons.chevronLeft,
              color: AppColors.secondaryText,
            ),
            onPressed: () => context.pop(),
          ),
          title: Text(
            loc.collaboratorsActionViewProfile,
            style: theme.textTheme.titleLarge?.copyWith(
              color: AppColors.secondaryText,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    loc.contactsEmptyMessage,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.secondaryText,
                      fontWeight: FontWeight.w600,
                    ),
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

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            FeatherIcons.chevronLeft,
            color: AppColors.secondaryText,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          profile.name,
          style: theme.textTheme.titleLarge?.copyWith(
            color: AppColors.secondaryText,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: loc.collaboratorInviteTooltip,
            icon: const Icon(
              FeatherIcons.userPlus,
              color: AppColors.secondaryText,
            ),
            onPressed: () => context.pushNamed('inviteCollaborator'),
          ),
          IconButton(
            tooltip: loc.collaboratorStartChatTooltip,
            icon: const Icon(
              FeatherIcons.messageCircle,
              color: AppColors.secondaryText,
            ),
            onPressed: () => context.pushNamed(
              'collaborationChat',
              queryParameters: {'contactId': collaboratorId},
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  24,
                  12,
                  24,
                  CustomNavBar.totalHeight + 40,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ProfileHeader(profile: profile),
                    const SizedBox(height: 20),
                    _SectionCard(
                      title: loc.collaboratorSectionSkills,
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: profile.skills
                            .map(
                              (skill) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(22),
                                  gradient: const LinearGradient(
                                    colors: [
                                      AppColors.secondary,
                                      AppColors.primary,
                                    ],
                                    begin: AlignmentDirectional(1.0, 0.34),
                                    end: AlignmentDirectional(-1.0, -0.34),
                                  ),
                                ),
                                child: Text(
                                  skill,
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: AppColors.primaryText,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _SectionCard(
                      title: loc.collaboratorSectionAbout,
                      child: Text(
                        profile.bio,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.secondaryText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _SectionCard(
                      title: loc.collaboratorSectionHistory,
                      child: Column(
                        children: profile.collaborationHistory
                            .map(
                              (item) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      FeatherIcons.checkCircle,
                                      size: 18,
                                      color: AppColors.secondary,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        item,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color: AppColors.secondaryText,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    GradientButton(
                      onPressed: () => context.pushNamed('inviteCollaborator'),
                      text: loc.collaboratorsActionInvite,
                      width: double.infinity,
                      height: 52,
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => context.pushNamed(
                        'collaborationChat',
                        queryParameters: {'contactId': collaboratorId},
                      ),
                      icon: const Icon(
                        FeatherIcons.messageCircle,
                        color: AppColors.secondary,
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: AppColors.secondary,
                          width: 2,
                        ),
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      label: Text(
                        loc.collaboratorSendMessage,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.bold,
                        ),
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

  _CollaboratorProfile? _buildProfile(
    ProjectController controller,
    AppLocalizations loc,
  ) {
    final contact = controller.contactById(collaboratorId);
    if (contact == null) {
      return null;
    }

    final normalized = contact.name.trim().toLowerCase();
    final involvement = <String>[];
    final memberIdsByProject = <String, Set<String>>{};

    for (final project in controller.projects) {
      final matchingMembers = project.members.where(
        (member) => _matchesContact(member, contact, normalized),
      );
      if (matchingMembers.isEmpty) {
        continue;
      }
      involvement.add(
        project.name.isEmpty ? loc.chatsUnnamedProject : project.name,
      );
      memberIdsByProject[project.id] = matchingMembers
          .map((member) => member.id)
          .whereType<String>()
          .toSet();
    }

    final stats = _buildCollaboratorStats(
      projects: controller.projects,
      memberIdsByProject: memberIdsByProject,
    );

    final history = <String>{...involvement};
    if (contact.lastProject != null) {
      history.add(contact.lastProject!);
    }

    final bioBuffer = StringBuffer()
      ..write('${contact.profession} • ${contact.location}. ');
    if (contact.lastProject != null) {
      bioBuffer.write(loc.collaboratorsLastProject(contact.lastProject!));
    } else {
      bioBuffer.write(loc.collaboratorsNoHistory);
    }

    final skills = contact.tags.isEmpty
        ? <String>[contact.profession]
        : contact.tags;

    return _CollaboratorProfile(
      name: contact.name,
      profession: contact.profession,
      location: contact.location,
      stats: stats,
      bio: bioBuffer.toString(),
      skills: skills,
      collaborationHistory: history.take(6).toList(growable: false),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.profile});

  final _CollaboratorProfile profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = context.l10n;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 28,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 84,
            height: 84,
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.secondary, AppColors.primary],
                begin: AlignmentDirectional(1.0, 0.34),
                end: AlignmentDirectional(-1.0, -0.34),
              ),
            ),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondaryBackground,
              ),
              alignment: Alignment.center,
              child: Text(
                profile.initials,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: AppColors.secondaryText,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.profession,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.hintTextfiled,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      FeatherIcons.mapPin,
                      size: 16,
                      color: AppColors.hintTextfiled,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      profile.location,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: AppColors.hintTextfiled,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _StatPill(
                      value: '${profile.stats.projectCount}',
                      label: loc.collaboratorStatProjectsLabel,
                    ),
                    _StatPill(
                      value: '${profile.stats.completedTasks}',
                      label: loc.collaboratorStatCompletedTasksLabel,
                    ),
                    _StatPill(
                      value: '${profile.stats.activeTasks}',
                      label: loc.collaboratorStatActiveTasksLabel,
                    ),
                    if (profile.stats.overdueTasks > 0)
                      _StatPill(
                        value: '${profile.stats.overdueTasks}',
                        label: loc.collaboratorStatOverdueTasksLabel,
                        highlight: true,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.secondaryText,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _CollaboratorProfile {
  const _CollaboratorProfile({
    required this.name,
    required this.profession,
    required this.location,
    required this.stats,
    required this.bio,
    required this.skills,
    required this.collaborationHistory,
  });

  final String name;
  final String profession;
  final String location;
  final _CollaboratorStats stats;
  final String bio;
  final List<String> skills;
  final List<String> collaborationHistory;

  String get initials {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((segment) => segment.isNotEmpty)
        .toList(growable: false);
    if (parts.isEmpty) {
      return '';
    }
    if (parts.length == 1) {
      return parts.first[0].toUpperCase();
    }
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}

class _CollaboratorStats {
  const _CollaboratorStats({
    required this.projectCount,
    required this.completedTasks,
    required this.activeTasks,
    required this.overdueTasks,
  });

  final int projectCount;
  final int completedTasks;
  final int activeTasks;
  final int overdueTasks;
}

_CollaboratorStats _buildCollaboratorStats({
  required List<Project> projects,
  required Map<String, Set<String>> memberIdsByProject,
}) {
  var completedTasks = 0;
  var activeTasks = 0;
  var overdueTasks = 0;
  final now = DateTime.now();

  for (final project in projects) {
    final assigneeIds = memberIdsByProject[project.id];
    if (assigneeIds == null || assigneeIds.isEmpty) {
      continue;
    }
    for (final task in project.tasks) {
      final assigneeId = task.assigneeId;
      if (assigneeId == null || !assigneeIds.contains(assigneeId)) {
        continue;
      }
      if (task.status == TaskStatus.completed) {
        completedTasks += 1;
      } else {
        activeTasks += 1;
        final dueDate = task.endDate;
        if (dueDate != null && dueDate.isBefore(now)) {
          overdueTasks += 1;
        }
      }
    }
  }

  return _CollaboratorStats(
    projectCount: memberIdsByProject.length,
    completedTasks: completedTasks,
    activeTasks: activeTasks,
    overdueTasks: overdueTasks,
  );
}

bool _matchesContact(
  Member member,
  CollaboratorContact contact,
  String normalized,
) {
  if (member.contactId == contact.id) {
    return true;
  }
  final memberName = member.name.trim().toLowerCase();
  return memberName.isNotEmpty && memberName == normalized;
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.value,
    required this.label,
    this.highlight = false,
  });

  final String value;
  final String label;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = highlight ? AppColors.error : AppColors.secondaryText;
    final background = highlight
        ? AppColors.error.withValues(alpha: 0.08)
        : AppColors.textfieldBackground;
    final borderColor = highlight
        ? AppColors.error.withValues(alpha: 0.4)
        : AppColors.textfieldBorder.withValues(alpha: 0.5);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: highlight ? AppColors.error : AppColors.hintTextfiled,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
