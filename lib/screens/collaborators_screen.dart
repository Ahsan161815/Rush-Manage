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

class CollaboratorsScreen extends StatelessWidget {
  const CollaboratorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = context.l10n;
    final controller = context.watch<ProjectController>();
    final collaborators = controller.contacts;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Text(
                loc.collaboratorsTitle,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: AppColors.secondaryText,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: () => context.pushNamed('invitationNotifications'),
                icon: const Icon(FeatherIcons.bell, size: 18),
                label: Text(loc.collaboratorsInvitationsButton),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.secondary,
                  side: const BorderSide(color: AppColors.secondary, width: 2),
                ),
              ),
              const SizedBox(width: 12),
              GradientButton(
                onPressed: () => context.pushNamed('inviteCollaborator'),
                text: loc.collaboratorsInviteCta,
                height: 42,
                width: 120,
              ),
            ],
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
                  12,
                  24,
                  CustomNavBar.totalHeight + 32,
                ),
                itemBuilder: (context, index) {
                  final collaborator = collaborators[index];
                  return _CollaboratorCard(collaborator: collaborator);
                },
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemCount: collaborators.length,
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

class _CollaboratorCard extends StatelessWidget {
  const _CollaboratorCard({required this.collaborator});

  final CollaboratorContact collaborator;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = context.l10n;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground,
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _AvatarBadge(name: collaborator.name),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            collaborator.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: AppColors.secondaryText,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        _StatusBadge(status: collaborator.availability),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      collaborator.profession,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.hintTextfiled,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          FeatherIcons.mapPin,
                          size: 15,
                          color: AppColors.hintTextfiled,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          collaborator.location,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: AppColors.hintTextfiled,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.textfieldBackground,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(
                  FeatherIcons.briefcase,
                  size: 18,
                  color: AppColors.secondary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    collaborator.lastProject == null
                        ? loc.collaboratorsNoHistory
                        : loc.collaboratorsLastProject(
                            collaborator.lastProject!,
                          ),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.secondaryText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              GradientButton(
                onPressed: () => context.pushNamed(
                  'collaboratorProfile',
                  pathParameters: {'id': collaborator.id},
                ),
                text: loc.collaboratorsActionViewProfile,
                height: 44,
                width: 150,
              ),
              _OutlineChip(
                label: loc.collaboratorsActionConversation,
                icon: FeatherIcons.messageCircle,
                onTap: () => context.pushNamed('collaborationChat'),
              ),
              _OutlineChip(
                label: loc.collaboratorsActionInvite,
                icon: FeatherIcons.plusCircle,
                onTap: () => context.pushNamed('inviteCollaborator'),
              ),
              _OutlineChip(
                label: loc.collaboratorsActionSendQuote,
                icon: FeatherIcons.fileText,
                onTap: () => context.pushNamed('createQuote'),
              ),
              _OutlineChip(
                label: loc.collaboratorsActionManagePermissions,
                icon: FeatherIcons.shield,
                onTap: () => context.pushNamed('rolesPermissions'),
              ),
              _OutlineChip(
                label: loc.collaboratorsActionViewFiles,
                icon: FeatherIcons.folder,
                onTap: () => context.pushNamed('sharedFiles'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OutlineChip extends StatelessWidget {
  const _OutlineChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.secondary.withValues(alpha: 0.4)),
          color: AppColors.secondaryBackground,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.secondary),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: AppColors.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
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
      width: 56,
      height: 56,
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
        width: 52,
        height: 52,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.secondaryBackground,
        ),
        alignment: Alignment.center,
        child: Text(
          initials,
          style: theme.textTheme.titleMedium?.copyWith(
            color: AppColors.secondaryText,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final CollaboratorAvailability status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = context.l10n;
    final (label, color) = switch (status) {
      CollaboratorAvailability.available => (
        loc.collaboratorsStatusOnline,
        AppColors.available,
      ),
      CollaboratorAvailability.busy => (
        loc.collaboratorsStatusBusy,
        AppColors.reserved,
      ),
      CollaboratorAvailability.offline => (
        loc.collaboratorsStatusOffline,
        AppColors.hintTextfiled,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: color.withValues(alpha: 0.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
