import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:provider/provider.dart';

import 'package:myapp/app/app_theme.dart';
import 'package:myapp/app/widgets/custom_nav_bar.dart';
import 'package:myapp/common/localization/l10n_extensions.dart';
import 'package:myapp/controllers/project_controller.dart';
import 'package:myapp/l10n/app_localizations.dart';
import 'package:myapp/models/project.dart';

class RolesPermissionsScreen extends StatefulWidget {
  const RolesPermissionsScreen({super.key});

  @override
  State<RolesPermissionsScreen> createState() => _RolesPermissionsScreenState();
}

class _RolesPermissionsScreenState extends State<RolesPermissionsScreen> {
  static const List<String> _roles = ['Admin', 'Collaborator', 'Viewer'];

  final Map<String, String> _roleOverrides = {};
  final Set<String> _savingMemberIds = <String>{};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = context.l10n;
    final controller = context.watch<ProjectController>();
    final members = _buildMembers(controller, loc)
        .map(
          (member) =>
              member.copyWith(role: _roleOverrides[member.id] ?? member.role),
        )
        .toList(growable: false);

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
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          loc.rolesPermissionsTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            color: AppColors.secondaryText,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: SafeArea(
              bottom: false,
              child: members.isEmpty
                  ? _RolesEmptyState(loc: loc)
                  : ListView.separated(
                      padding: EdgeInsets.fromLTRB(
                        24,
                        16,
                        24,
                        CustomNavBar.totalHeight + 32,
                      ),
                      itemBuilder: (context, index) {
                        final member = members[index];
                        return _MemberTile(
                          member: member,
                          roles: _roles,
                          onRoleChanged: (value) {
                            if (value == null) return;
                            _updateRole(member, value);
                          },
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemCount: members.length,
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

  Future<void> _updateRole(_MemberRole member, String value) async {
    if (member.isOwner) {
      return;
    }
    if (_savingMemberIds.contains(member.id)) {
      return;
    }

    final previousRole = _roleOverrides[member.id] ?? member.role;
    setState(() {
      _savingMemberIds.add(member.id);
      _roleOverrides[member.id] = value;
    });

    final controller = context.read<ProjectController>();
    try {
      if (member.email.trim().isEmpty) {
        throw StateError('Missing collaborator email');
      }
      await controller.updateCollaboratorRole(
        inviteeEmail: member.email,
        role: value,
      );
      if (!mounted) return;
      setState(() {
        _savingMemberIds.remove(member.id);
        _roleOverrides.remove(member.id);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _savingMemberIds.remove(member.id);
        _roleOverrides[member.id] = previousRole;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to update role. Please try again.'),
        ),
      );
    }
  }

  List<_MemberRole> _buildMembers(
    ProjectController controller,
    AppLocalizations loc,
  ) {
    final roster = <String, _MemberRole>{};
    final assignedMembers = _assignedMemberIds(controller.projects);

    final owner = _buildOwner(controller, loc);
    if (owner != null) {
      roster[owner.id] = owner;
    }

    for (final contact in controller.contacts) {
      final key = _memberKey(
        email: contact.email,
        id: contact.id,
        fallback: contact.name,
      );
      roster.putIfAbsent(
        key,
        () => _MemberRole(
          id: key,
          name: contact.name,
          email: contact.email,
          role: _roles.last,
          projects: <String>{},
        ),
      );
    }

    for (final project in controller.projects) {
      final projectLabel = project.name.isNotEmpty
          ? project.name
          : loc.chatsUnnamedProject;
      for (final member in project.members) {
        final contact = controller.contactForMember(member);
        final key = _memberKey(
          email: contact?.email,
          id: member.id,
          fallback: member.name,
        );
        final entry = roster.putIfAbsent(
          key,
          () => _MemberRole(
            id: key,
            name: member.name,
            email: contact?.email ?? '',
            role: _roles.last,
            projects: <String>{},
          ),
        );
        entry.name = member.name;
        if (entry.email.isEmpty && (contact?.email ?? '').isNotEmpty) {
          entry.email = contact!.email;
        }
        entry.projects.add(projectLabel);
        final hasAssignment = assignedMembers.contains(member.id);
        entry.hasAssignments = entry.hasAssignments || hasAssignment;
        if (_roleWeight(entry.role) > _roleWeight(_roles[1]) && hasAssignment) {
          entry.role = _roles[1];
        }
      }
    }

    for (final invitation in controller.invitations) {
      final key = _memberKey(
        email: invitation.inviteeEmail,
        id: invitation.id,
        fallback: invitation.inviteeName,
      );
      final resolvedRole = _normalizeRole(invitation.role);
      final entry = roster.putIfAbsent(
        key,
        () => _MemberRole(
          id: key,
          name: invitation.inviteeName,
          email: invitation.inviteeEmail,
          role: resolvedRole,
          projects: <String>{invitation.projectName},
          isPending: invitation.isPending,
        ),
      );
      entry.name = invitation.inviteeName;
      if (invitation.inviteeEmail.isNotEmpty) {
        entry.email = invitation.inviteeEmail;
      }
      entry.isPending = invitation.isPending;
      entry.projects.add(invitation.projectName);
      if (_roleWeight(resolvedRole) < _roleWeight(entry.role)) {
        entry.role = resolvedRole;
      }
    }

    final members = roster.values.toList()
      ..sort((a, b) {
        final weightComparison = _roleWeight(
          a.role,
        ).compareTo(_roleWeight(b.role));
        if (weightComparison != 0) {
          return weightComparison;
        }
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
    return members;
  }

  Set<String> _assignedMemberIds(List<Project> projects) {
    final assigned = <String>{};
    for (final project in projects) {
      for (final task in project.tasks) {
        final assignee = task.assigneeId;
        if (assignee != null && assignee.isNotEmpty) {
          assigned.add(assignee);
        }
      }
    }
    return assigned;
  }

  _MemberRole? _buildOwner(ProjectController controller, AppLocalizations loc) {
    final ownerId = controller.currentUserId;
    if (ownerId == null) {
      return null;
    }
    final email =
        controller.currentUserEmail ?? loc.inviteCollaboratorEmailHint;
    final projects = controller.projects
        .map(
          (project) =>
              project.name.isNotEmpty ? project.name : loc.chatsUnnamedProject,
        )
        .toSet();
    return _MemberRole(
      id: 'owner-$ownerId',
      name: loc.homeAuthorYou,
      email: email,
      role: _roles.first,
      projects: projects,
      isOwner: true,
      hasAssignments: true,
    );
  }

  String _memberKey({String? email, String? id, required String fallback}) {
    if (email != null && email.trim().isNotEmpty) {
      return 'email-${email.trim().toLowerCase()}';
    }
    if (id != null && id.trim().isNotEmpty) {
      return 'id-${id.trim()}';
    }
    return 'name-${fallback.trim().toLowerCase()}';
  }

  String _normalizeRole(String role) {
    final normalized = role.trim().toLowerCase();
    if (normalized.startsWith('admin') || normalized.startsWith('owner')) {
      return _roles.first;
    }
    if (normalized.startsWith('view')) {
      return _roles.last;
    }
    return _roles[1];
  }

  int _roleWeight(String role) {
    final normalized = role.trim().toLowerCase();
    if (normalized.startsWith('admin') || normalized.startsWith('owner')) {
      return 0;
    }
    if (normalized.startsWith('collab')) {
      return 1;
    }
    return 2;
  }
}

class _MemberTile extends StatelessWidget {
  const _MemberTile({
    required this.member,
    required this.roles,
    required this.onRoleChanged,
  });

  final _MemberRole member;
  final List<String> roles;
  final ValueChanged<String?> onRoleChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = context.l10n;
    final emailLabel = member.email.isNotEmpty
        ? member.email
        : loc.inviteCollaboratorEmailHint;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          _AvatarBadge(name: member.name),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        member.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppColors.secondaryText,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (member.isOwner) ...[
                      const SizedBox(width: 8),
                      _StatusPill(label: loc.rolesPermissionsRoleAdmin),
                    ],
                    if (member.isPending) ...[
                      const SizedBox(width: 8),
                      _StatusPill(
                        label: loc.invitationNotificationsStatusPending,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  emailLabel,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.hintTextfiled,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          _RoleDropdown(
            value: member.role,
            roles: roles,
            onChanged: member.isOwner ? null : onRoleChanged,
          ),
        ],
      ),
    );
  }
}

class _RoleDropdown extends StatelessWidget {
  const _RoleDropdown({
    required this.value,
    required this.roles,
    required this.onChanged,
  });

  final String value;
  final List<String> roles;
  final ValueChanged<String?>? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = context.l10n;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.textfieldBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.textfieldBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          items: roles
              .map(
                (role) => DropdownMenuItem(
                  value: role,
                  child: Text(
                    _rolesPermissionsLabel(loc, role),
                    style: theme.textTheme.labelLarge?.copyWith(
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

String _rolesPermissionsLabel(AppLocalizations loc, String role) {
  switch (role.toLowerCase()) {
    case 'admin':
      return loc.rolesPermissionsRoleAdmin;
    case 'collaborator':
      return loc.rolesPermissionsRoleCollaborator;
    case 'viewer':
      return loc.rolesPermissionsRoleViewer;
    default:
      return role;
  }
}

class _AvatarBadge extends StatelessWidget {
  const _AvatarBadge({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final initials = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((segment) => segment.isNotEmpty)
        .map((segment) => segment[0].toUpperCase())
        .take(2)
        .join();

    return Container(
      width: 48,
      height: 48,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [AppColors.secondary, AppColors.primary],
          begin: AlignmentDirectional(1.0, 0.34),
          end: AlignmentDirectional(-1.0, -0.34),
        ),
      ),
      alignment: Alignment.center,
      child: Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.secondaryBackground,
        ),
        alignment: Alignment.center,
        child: Text(
          initials,
          style: theme.textTheme.labelLarge?.copyWith(
            color: AppColors.secondaryText,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _MemberRole {
  _MemberRole({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.projects,
    this.isPending = false,
    this.hasAssignments = false,
    this.isOwner = false,
  });

  final String id;
  String name;
  String email;
  String role;
  final Set<String> projects;
  bool isPending;
  bool hasAssignments;
  bool isOwner;

  _MemberRole copyWith({String? role}) => _MemberRole(
    id: id,
    name: name,
    email: email,
    role: role ?? this.role,
    projects: <String>{...projects},
    isPending: isPending,
    hasAssignments: hasAssignments,
    isOwner: isOwner,
  );
}

class _RolesEmptyState extends StatelessWidget {
  const _RolesEmptyState({required this.loc});

  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            FeatherIcons.users,
            size: 40,
            color: AppColors.hintTextfiled,
          ),
          const SizedBox(height: 16),
          Text(
            loc.rolesPermissionsTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.secondaryText,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            loc.projectDetailTeamEmpty,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.hintTextfiled,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.textfieldBackground,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.textfieldBorder),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.secondaryText,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
