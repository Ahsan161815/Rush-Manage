import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

import 'package:myapp/app/app_theme.dart';
import 'package:myapp/app/widgets/custom_nav_bar.dart';
import 'package:myapp/common/localization/l10n_extensions.dart';
import 'package:myapp/l10n/app_localizations.dart';

class RolesPermissionsScreen extends StatefulWidget {
  const RolesPermissionsScreen({super.key});

  @override
  State<RolesPermissionsScreen> createState() => _RolesPermissionsScreenState();
}

class _RolesPermissionsScreenState extends State<RolesPermissionsScreen> {
  static const List<String> _roles = ['Admin', 'Collaborator', 'Viewer'];

  final List<_MemberRole> _members = [
    _MemberRole(name: 'Alex Carter', email: 'alex@rush.manage', role: 'Admin'),
    _MemberRole(
      name: 'Sarah Collins',
      email: 'sarah@studio.co',
      role: 'Collaborator',
    ),
    _MemberRole(
      name: 'Karim Haddad',
      email: 'karim@chef.fr',
      role: 'Collaborator',
    ),
    _MemberRole(
      name: 'Laura Design',
      email: 'laura@designlab.com',
      role: 'Viewer',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = context.l10n;

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
              child: ListView.separated(
                padding: EdgeInsets.fromLTRB(
                  24,
                  16,
                  24,
                  CustomNavBar.totalHeight + 32,
                ),
                itemBuilder: (context, index) {
                  final member = _members[index];
                  return _MemberTile(
                    member: member,
                    roles: _roles,
                    onRoleChanged: (value) {
                      if (value == null) return;
                      setState(() => member.role = value);
                    },
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemCount: _members.length,
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
                Text(
                  member.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.secondaryText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  member.email,
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
            onChanged: onRoleChanged,
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
  final ValueChanged<String?> onChanged;

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
  _MemberRole({required this.name, required this.email, required this.role});

  final String name;
  final String email;
  String role;
}
