import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:myapp/app/app_theme.dart';
import 'package:myapp/common/localization/formatters.dart';
import 'package:myapp/common/localization/l10n_extensions.dart';
import 'package:myapp/common/models/message.dart';
import 'package:myapp/common/utils/project_ui.dart';
import 'package:myapp/controllers/project_controller.dart';
import 'package:myapp/l10n/app_localizations.dart';
import 'package:myapp/models/project.dart';
import 'package:myapp/widgets/custom_text_field.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  final TextEditingController _searchController = TextEditingController();
  _ChatFilter _selectedFilter = _ChatFilter.all;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_handleSearchChanged);
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_handleSearchChanged)
      ..dispose();
    super.dispose();
  }

  void _handleSearchChanged() => setState(() {});

  void _handleFilterChanged(_ChatFilter filter) {
    if (_selectedFilter == filter) {
      return;
    }
    setState(() => _selectedFilter = filter);
  }

  List<_ChatPreview> _filterThreads(List<_ChatPreview> threads) {
    final query = _searchController.text.trim().toLowerCase();
    return threads
        .where((thread) {
          final matchesFilter = switch (_selectedFilter) {
            _ChatFilter.all => true,
            _ChatFilter.projects => thread.isProject,
            _ChatFilter.contacts => !thread.isProject,
          };
          if (!matchesFilter) {
            return false;
          }
          if (query.isEmpty) {
            return true;
          }
          return thread.searchableText.contains(query);
        })
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ProjectController>();
    final loc = context.l10n;
    final threads = _buildThreads(controller: controller, loc: loc);
    final hasContactThreads = threads.any((thread) => !thread.isProject);
    if (!hasContactThreads && _selectedFilter == _ChatFilter.contacts) {
      // Revert to supported filters until DM threads exist for this user.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _selectedFilter != _ChatFilter.contacts) {
          return;
        }
        setState(() => _selectedFilter = _ChatFilter.all);
      });
    }
    final visibleThreads = _filterThreads(threads);
    final hasVisibleThreads = visibleThreads.isNotEmpty;
    final placeholderConfig = hasVisibleThreads
        ? null
        : _resolvePlaceholderConfig(
            controller: controller,
            loc: loc,
            hasAnyThreads: threads.isNotEmpty,
            hasContactsFilter: hasContactThreads,
          );
    final listItemCount = hasVisibleThreads ? visibleThreads.length + 1 : 2;
    final isInitialLoading = controller.isLoading && threads.isEmpty;

    final listView = RefreshIndicator(
      onRefresh: controller.refresh,
      color: AppColors.secondary,
      child: ListView.separated(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        itemCount: listItemCount,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _ChatsListHeader(
              searchController: _searchController,
              selectedFilter: _selectedFilter,
              onFilterChanged: _handleFilterChanged,
              showContactsFilter: hasContactThreads,
            );
          }
          if (!hasVisibleThreads) {
            return Padding(
              padding: const EdgeInsets.only(top: 48),
              child: _EmptyThreadsState(config: placeholderConfig!),
            );
          }
          final thread = visibleThreads[index - 1];
          return _ChatTile(
            chat: thread,
            onTap: () => context.pushNamed(
              'projectChat',
              pathParameters: {'id': thread.projectId},
            ),
          );
        },
        separatorBuilder: (_, index) => index == 0
            ? const SizedBox(height: 20)
            : const SizedBox(height: 16),
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(FeatherIcons.chevronLeft),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).maybePop();
            } else {
              context.goNamed('home');
            }
          },
        ),
        title: Text(
          loc.chatsTitle,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.secondaryText,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: isInitialLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.secondary,
                  ),
                ),
              )
            : listView,
      ),
    );
  }

  List<_ChatPreview> _buildThreads({
    required ProjectController controller,
    required AppLocalizations loc,
  }) {
    final threads = controller.projects
        .map((project) {
          final messages = controller.messagesFor(project.id);
          final lastMessage = messages.isNotEmpty ? messages.last : null;
          final title = project.name.trim().isEmpty
              ? loc.chatsUnnamedProject
              : project.name.trim();
          final lastActivity =
              lastMessage?.sentAt ??
              project.endDate ??
              project.startDate ??
              DateTime.now();
          return _ChatPreview(
            title: title,
            lastMessage: _lastMessageLabel(
              message: lastMessage,
              project: project,
              controller: controller,
              loc: loc,
            ),
            projectId: project.id,
            contextDetail: _contextDetail(project, loc),
            lastActivity: lastActivity,
            isProject: true,
            unreadCount: _unreadCount(
              messages: messages,
              controller: controller,
            ),
          );
        })
        .toList(growable: false);

    threads.sort((a, b) => b.lastActivity.compareTo(a.lastActivity));
    return threads;
  }

  String _contextDetail(Project project, AppLocalizations loc) {
    final clientLabel = project.client.trim().isEmpty
        ? loc.projectDetailClientPlaceholder
        : project.client.trim();
    final statusLabel = projectStatusMeta(project.status).label;
    return '$clientLabel · $statusLabel';
  }

  String _lastMessageLabel({
    required Message? message,
    required Project project,
    required ProjectController controller,
    required AppLocalizations loc,
  }) {
    if (message == null) {
      return loc.chatsNoMessagesYet;
    }
    final authorLabel = _resolveAuthorLabel(
      message: message,
      project: project,
      controller: controller,
      loc: loc,
    );
    final body = message.body.trim().isEmpty
        ? loc.projectDetailDiscussionEmpty
        : _truncate(message.body.trim(), 140);
    return '$authorLabel • $body';
  }

  String _resolveAuthorLabel({
    required Message message,
    required Project project,
    required ProjectController controller,
    required AppLocalizations loc,
  }) {
    final userId = controller.currentUserId;
    if (message.authorId == 'me' ||
        (userId != null && userId.isNotEmpty && message.authorId == userId)) {
      return loc.homeAuthorYou;
    }
    for (final member in project.members) {
      if (member.id == message.authorId) {
        return member.name;
      }
    }
    return loc.homeCollaboratorFallback;
  }

  String _truncate(String value, int maxLength) {
    if (value.length <= maxLength) {
      return value;
    }
    return '${value.substring(0, maxLength)}...';
  }

  int _unreadCount({
    required List<Message> messages,
    required ProjectController controller,
  }) {
    if (messages.isEmpty) {
      return 0;
    }
    final keys = <String>[];
    final userId = controller.currentUserId;
    if (userId != null && userId.isNotEmpty) {
      keys.add(userId);
    }
    if (!keys.contains('me')) {
      keys.add('me');
    }
    final authoredKeys = <String>{
      if (userId != null && userId.isNotEmpty) userId,
      'me',
    };
    var unread = 0;
    for (final message in messages) {
      if (authoredKeys.contains(message.authorId)) {
        continue;
      }
      final receipt = _receiptFor(message, keys);
      if (receipt == null || receipt != MessageReceiptStatus.read) {
        unread++;
      }
    }
    return unread;
  }

  MessageReceiptStatus? _receiptFor(
    Message message,
    List<String> candidateKeys,
  ) {
    for (final key in candidateKeys) {
      final receipt = message.receipts[key];
      if (receipt != null) {
        return receipt;
      }
    }
    return null;
  }

  _PlaceholderConfig _resolvePlaceholderConfig({
    required ProjectController controller,
    required AppLocalizations loc,
    required bool hasAnyThreads,
    required bool hasContactsFilter,
  }) {
    final hasError = controller.errorMessage != null;
    final hasQuery = _hasActiveQuery;
    final hasCustomFilter = _selectedFilter != _ChatFilter.all;
    if (hasError && !hasAnyThreads) {
      return _PlaceholderConfig(
        title: controller.errorMessage!,
        subtitle: loc.commonTryAgain,
        icon: FeatherIcons.alertTriangle,
        onRetry: () => controller.refresh(),
      );
    }
    if (!hasAnyThreads) {
      return _PlaceholderConfig(
        title: loc.chatsEmptyTitle,
        subtitle: loc.chatsEmptySubtitle,
        icon: FeatherIcons.messageSquare,
      );
    }
    if (_selectedFilter == _ChatFilter.contacts && hasContactsFilter) {
      return _PlaceholderConfig(
        title: loc.contactsEmptyMessage,
        subtitle: '',
        icon: FeatherIcons.users,
      );
    }
    if (hasQuery || hasCustomFilter) {
      return _PlaceholderConfig(
        title: loc.chatsSearchEmpty,
        subtitle: loc.commonSearchThreads,
        icon: FeatherIcons.search,
      );
    }
    return _PlaceholderConfig(
      title: loc.chatsNoMessagesYet,
      subtitle: loc.chatsEmptySubtitle,
      icon: FeatherIcons.messageSquare,
    );
  }

  bool get _hasActiveQuery => _searchController.text.trim().isNotEmpty;
}

class _PlaceholderConfig {
  const _PlaceholderConfig({
    required this.title,
    required this.icon,
    this.subtitle,
    this.onRetry,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback? onRetry;
}

class _EmptyThreadsState extends StatelessWidget {
  const _EmptyThreadsState({required this.config});

  final _PlaceholderConfig config;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config.icon, size: 48, color: AppColors.hintTextfiled),
          const SizedBox(height: 16),
          Text(
            config.title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleSmall?.copyWith(
              color: AppColors.secondaryText,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (config.subtitle != null && config.subtitle!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              config.subtitle!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.hintTextfiled,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if (config.onRetry != null) ...[
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: config.onRetry,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.secondary,
                side: const BorderSide(color: AppColors.secondary),
              ),
              child: Text(context.l10n.commonTryAgain),
            ),
          ],
        ],
      ),
    );
  }
}

class _ChatTile extends StatelessWidget {
  const _ChatTile({required this.chat, required this.onTap});

  final _ChatPreview chat;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = context.l10n;
    final badgeLabel = chat.isProject
        ? loc.chatsBadgeProject
        : loc.chatsBadgeContact;
    final timestampLabel = formatRelativeTime(context, chat.lastActivity);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
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
                        timestampLabel,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.hintTextfiled,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _ContextChip(label: badgeLabel),
                      Text(
                        chat.contextDetail,
                        style: theme.textTheme.labelMedium?.copyWith(
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
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
              )
            else
              const Icon(
                FeatherIcons.chevronRight,
                size: 18,
                color: AppColors.hintTextfiled,
              ),
          ],
        ),
      ),
    );
  }
}

class _ChatsListHeader extends StatelessWidget {
  const _ChatsListHeader({
    required this.searchController,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.showContactsFilter,
  });

  final TextEditingController searchController;
  final _ChatFilter selectedFilter;
  final ValueChanged<_ChatFilter> onFilterChanged;
  final bool showContactsFilter;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ChatsSearchField(controller: searchController),
        const SizedBox(height: 12),
        _FilterRow(
          selected: selectedFilter,
          onChanged: onFilterChanged,
          showContactsFilter: showContactsFilter,
        ),
      ],
    );
  }
}

class _ChatsSearchField extends StatelessWidget {
  const _ChatsSearchField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      hintText: context.l10n.commonSearchThreads,
      iconPath: 'assets/images/search-svgrepo-com.svg',
      widthFactor: 1,
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({
    required this.selected,
    required this.onChanged,
    required this.showContactsFilter,
  });

  final _ChatFilter selected;
  final ValueChanged<_ChatFilter> onChanged;
  final bool showContactsFilter;

  @override
  Widget build(BuildContext context) {
    final filters = <_ChatFilter>[_ChatFilter.all, _ChatFilter.projects];
    if (showContactsFilter) {
      filters.add(_ChatFilter.contacts);
    }
    final loc = context.l10n;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < filters.length; i++) ...[
            _GradientChoiceChip(
              label: filters[i].label(loc),
              selected: filters[i] == selected,
              onTap: () => onChanged(filters[i]),
            ),
            if (i != filters.length - 1) const SizedBox(width: 12),
          ],
        ],
      ),
    );
  }
}

class _GradientChoiceChip extends StatelessWidget {
  const _GradientChoiceChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
          color: selected ? null : AppColors.secondaryBackground,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected
                ? Colors.transparent
                : AppColors.textfieldBorder.withValues(alpha: 0.7),
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.secondary.withValues(alpha: 0.2),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [
                  BoxShadow(
                    color: AppColors.secondary.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: selected ? AppColors.primaryText : AppColors.secondaryText,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _ContextChip extends StatelessWidget {
  const _ContextChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: AppColors.secondary.withValues(alpha: 0.12),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: AppColors.secondary,
          fontWeight: FontWeight.bold,
        ),
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

enum _ChatFilter { all, projects, contacts }

extension _ChatFilterX on _ChatFilter {
  String label(AppLocalizations loc) {
    switch (this) {
      case _ChatFilter.all:
        return loc.commonAllFilter;
      case _ChatFilter.projects:
        return loc.commonProjectsFilter;
      case _ChatFilter.contacts:
        return loc.commonContactsFilter;
    }
  }
}

class _ChatPreview {
  const _ChatPreview({
    required this.title,
    required this.lastMessage,
    required this.projectId,
    required this.contextDetail,
    required this.lastActivity,
    required this.isProject,
    this.unreadCount = 0,
  });

  final String title;
  final String lastMessage;
  final String projectId;
  final String contextDetail;
  final DateTime lastActivity;
  final bool isProject;
  final int unreadCount;

  String get avatarLabel {
    final parts = title
        .split(RegExp(r'\s+'))
        .where((segment) => segment.isNotEmpty)
        .toList(growable: false);
    if (parts.isEmpty) {
      return '?';
    }
    if (parts.length == 1) {
      return parts.first[0].toUpperCase();
    }
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  String get searchableText {
    final buffer = StringBuffer()
      ..write(title)
      ..write(' ')
      ..write(lastMessage)
      ..write(' ')
      ..write(contextDetail);
    return buffer.toString().toLowerCase();
  }
}
