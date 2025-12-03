import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:myapp/app/app_theme.dart';
import 'package:myapp/app/widgets/custom_nav_bar.dart';
import 'package:myapp/app/widgets/gradient_button.dart';
import 'package:myapp/common/models/invitation.dart';
import 'package:myapp/controllers/project_controller.dart';

class InvitationNotificationsScreen extends StatefulWidget {
  const InvitationNotificationsScreen({super.key});

  @override
  State<InvitationNotificationsScreen> createState() =>
      _InvitationNotificationsScreenState();
}

class _InvitationNotificationsScreenState
    extends State<InvitationNotificationsScreen> {
  _InvitationStatusFilter _filter = _InvitationStatusFilter.pending;

  void _setFilter(_InvitationStatusFilter filter) {
    setState(() => _filter = filter);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = context.watch<ProjectController>();
    final invitations = controller.invitations
        .where((invitation) {
          switch (_filter) {
            case _InvitationStatusFilter.all:
              return true;
            case _InvitationStatusFilter.pending:
              return invitation.status == InvitationStatus.pending;
            case _InvitationStatusFilter.responded:
              return invitation.status == InvitationStatus.accepted ||
                  invitation.status == InvitationStatus.declined;
          }
        })
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
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Invitations',
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
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _FilterChips(
                      current: _filter,
                      onChanged: _setFilter,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: invitations.isEmpty
                        ? _EmptyState(filter: _filter)
                        : ListView.separated(
                            padding: EdgeInsets.fromLTRB(
                              24,
                              0,
                              24,
                              CustomNavBar.totalHeight + 32,
                            ),
                            itemBuilder: (context, index) {
                              final invitation = invitations[index];
                              return _InvitationCard(invitation: invitation);
                            },
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 18),
                            itemCount: invitations.length,
                          ),
                  ),
                ],
              ),
            ),
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomNavBar(currentRouteName: 'invitationNotifications'),
          ),
        ],
      ),
    );
  }
}

class _InvitationCard extends StatelessWidget {
  const _InvitationCard({required this.invitation});

  final Invitation invitation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = context.read<ProjectController>();

    final statusChip = _statusChipFor(invitation.status);

    String timeLabel;
    final updatedAt = invitation.updatedAt ?? invitation.sentAt;
    final difference = DateTime.now().difference(updatedAt);
    if (difference.inDays >= 1) {
      timeLabel = '${difference.inDays}d ago';
    } else if (difference.inHours >= 1) {
      timeLabel = '${difference.inHours}h ago';
    } else if (difference.inMinutes >= 1) {
      timeLabel = '${difference.inMinutes}m ago';
    } else {
      timeLabel = 'Just now';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      invitation.inviteeName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppColors.secondaryText,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      invitation.inviteeEmail,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.hintTextfiled,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusChip.backgroundColor,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      statusChip.icon,
                      size: 16,
                      color: statusChip.foregroundColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      statusChip.label,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: statusChip.foregroundColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.textfieldBackground,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      FeatherIcons.briefcase,
                      size: 16,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        invitation.projectName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.secondaryText,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      FeatherIcons.shield,
                      size: 16,
                      color: AppColors.hintTextfiled,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Role: ${invitation.role}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.hintTextfiled,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                if (invitation.message != null &&
                    invitation.message!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        FeatherIcons.messageCircle,
                        size: 16,
                        color: AppColors.hintTextfiled,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          invitation.message!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.secondaryText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                timeLabel,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.hintTextfiled,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (!invitation.readByInvitee)
                TextButton(
                  onPressed: () => controller.markInvitationRead(invitation.id),
                  child: const Text('Mark read'),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _buildAction(invitation),
        ],
      ),
    );
  }
}

Widget _buildAction(Invitation invitation) {
  switch (invitation.status) {
    case InvitationStatus.pending:
      return _PendingActions(invitation: invitation);
    case InvitationStatus.accepted:
      return _AcceptedActions(invitation: invitation);
    case InvitationStatus.declined:
      return _DeclinedActions(invitation: invitation);
  }
}

_StatusChipStyle _statusChipFor(InvitationStatus status) {
  switch (status) {
    case InvitationStatus.pending:
      return const _StatusChipStyle(
        label: 'Awaiting response',
        icon: FeatherIcons.clock,
        backgroundColor: Color(0x3323A6FF),
        foregroundColor: AppColors.secondary,
      );
    case InvitationStatus.accepted:
      return const _StatusChipStyle(
        label: 'Accepted',
        icon: FeatherIcons.checkCircle,
        backgroundColor: Color(0x3342C97B), // brighter green tint
        foregroundColor: Color(0xFF2FBF71),
      );
    case InvitationStatus.declined:
      return const _StatusChipStyle(
        label: 'Declined',
        icon: FeatherIcons.xCircle,
        backgroundColor: Color(0x33F17D7D), // brighter red tint
        foregroundColor: Color(0xFFE55454),
      );
  }
}

class _StatusChipStyle {
  const _StatusChipStyle({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
}

class _PendingActions extends StatelessWidget {
  const _PendingActions({required this.invitation});

  final Invitation invitation;

  @override
  Widget build(BuildContext context) {
    final controller = context.read<ProjectController>();

    void decline() => controller.declineInvitation(invitation.id);

    return Row(
      children: [
        Expanded(
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.secondary, AppColors.primary],
                begin: AlignmentDirectional(1.0, 0.34),
                end: AlignmentDirectional(-1.0, -0.34),
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            alignment: Alignment.center,
            child: Text(
              'Accept Request',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.primaryText,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            onPressed: decline,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(
                color: AppColors.textfieldBorder,
                width: 2,
              ),
              minimumSize: const Size.fromHeight(52),
              padding: const EdgeInsets.symmetric(vertical: 18),
              foregroundColor: AppColors.secondaryText,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              textStyle: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            child: const Text('Decline'),
          ),
        ),
      ],
    );
  }
}

class _AcceptedActions extends StatelessWidget {
  const _AcceptedActions({required this.invitation});

  final Invitation invitation;

  @override
  Widget build(BuildContext context) {
    return GradientButton(
      onPressed: () => context.goNamed(
        'projectDetail',
        pathParameters: {'id': invitation.projectId},
      ),
      text: 'View project',
      height: 48,
    );
  }
}

class _DeclinedActions extends StatelessWidget {
  const _DeclinedActions({required this.invitation});

  final Invitation invitation;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.textfieldBorder, width: 2),
        minimumSize: const Size.fromHeight(52),
        padding: const EdgeInsets.symmetric(vertical: 18),
        foregroundColor: AppColors.secondaryText,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        textStyle: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
      child: const Text('Invite again later'),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.current, required this.onChanged});
  final _InvitationStatusFilter current;
  final ValueChanged<_InvitationStatusFilter> onChanged;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isNarrow = MediaQuery.of(context).size.width < 420;
    final chips = _InvitationStatusFilter.values
        .map((filter) {
          final selected = current == filter;
          return GestureDetector(
            onTap: () => onChanged(filter),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: selected
                    ? const LinearGradient(
                        colors: [AppColors.secondary, AppColors.primary],
                        begin: AlignmentDirectional(1.0, 0.34),
                        end: AlignmentDirectional(-1.0, -0.34),
                      )
                    : null,
                color: selected ? null : AppColors.secondaryBackground,
                border: Border.all(
                  color: selected
                      ? Colors.transparent
                      : AppColors.textfieldBorder.withValues(alpha: 0.6),
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    filter.label,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: selected
                          ? AppColors.primaryText
                          : AppColors.secondaryText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (selected) ...[
                    const SizedBox(width: 8),
                    const Icon(
                      FeatherIcons.check,
                      size: 16,
                      color: AppColors.primaryText,
                    ),
                  ],
                ],
              ),
            ),
          );
        })
        .toList(growable: false);

    if (isNarrow) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: chips),
      );
    }
    return Wrap(spacing: 4, runSpacing: 4, children: chips);
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.filter});

  final _InvitationStatusFilter filter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final message = switch (filter) {
      _InvitationStatusFilter.all => 'No invitations to show right now.',
      _InvitationStatusFilter.pending =>
        'No pending invitations. You\'re caught up!',
      _InvitationStatusFilter.responded =>
        'No recent responses yet. Check back soon.',
    };
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          FeatherIcons.inbox,
          size: 48,
          color: AppColors.hintTextfiled,
        ),
        const SizedBox(height: 16),
        Text(
          message,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.hintTextfiled,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

enum _InvitationStatusFilter { all, pending, responded }

extension on _InvitationStatusFilter {
  String get label {
    return switch (this) {
      _InvitationStatusFilter.all => 'All',
      _InvitationStatusFilter.pending => 'Pending',
      _InvitationStatusFilter.responded => 'Responded',
    };
  }
}
