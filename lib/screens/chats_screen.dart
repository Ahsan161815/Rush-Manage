import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

import 'package:myapp/app/app_theme.dart';

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});

  static const List<_ChatPreview> _chats = [
    _ChatPreview(
      title: 'Apollo Station Build',
      lastMessage: 'Sarai • Uploaded the updated permits. ',
      timestampLabel: '2m ago',
      unreadCount: 3,
    ),
    _ChatPreview(
      title: 'Fleet Maintenance',
      lastMessage: 'You • Let me know when the vans are back.',
      timestampLabel: '45m ago',
    ),
    _ChatPreview(
      title: 'Finance Squad',
      lastMessage: 'Robin • Budget review call moved to 3pm.',
      timestampLabel: '1h ago',
      unreadCount: 1,
    ),
    _ChatPreview(
      title: 'Cobalt Logistics',
      lastMessage: 'Hassan • Thanks for sharing the manifest!',
      timestampLabel: 'Yesterday',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Chats',
          style: theme.textTheme.titleLarge?.copyWith(
            color: AppColors.secondaryText,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          itemBuilder: (context, index) {
            final chat = _chats[index];
            return _ChatTile(chat: chat);
          },
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemCount: _chats.length,
        ),
      ),
    );
  }
}

class _ChatTile extends StatelessWidget {
  const _ChatTile({required this.chat});

  final _ChatPreview chat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          _AvatarBadge(label: chat.avatarLabel),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        chat.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppColors.secondaryText,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      chat.timestampLabel,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.hintTextfiled,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  chat.lastMessage,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.secondaryText.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          if (chat.unreadCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                  begin: AlignmentDirectional(1.0, 0.34),
                  end: AlignmentDirectional(-1.0, -0.34),
                ),
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
              child: Text(
                '${chat.unreadCount}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.primaryText,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          if (chat.unreadCount == 0)
            const Icon(
              FeatherIcons.chevronRight,
              size: 18,
              color: AppColors.hintTextfiled,
            ),
        ],
      ),
    );
  }
}

class _AvatarBadge extends StatelessWidget {
  const _AvatarBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 50,
      height: 50,
      padding: const EdgeInsets.all(3),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [AppColors.secondary, AppColors.primary],
          begin: AlignmentDirectional(1.0, 0.34),
          end: AlignmentDirectional(-1.0, -0.34),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.textfieldBackground,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            color: AppColors.secondaryText,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _ChatPreview {
  const _ChatPreview({
    required this.title,
    required this.lastMessage,
    required this.timestampLabel,
    this.unreadCount = 0,
  });

  final String title;
  final String lastMessage;
  final String timestampLabel;
  final int unreadCount;

  String get avatarLabel {
    final parts = title
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
