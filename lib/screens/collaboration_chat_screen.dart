import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:myapp/app/app_theme.dart';
import 'package:myapp/app/widgets/custom_nav_bar.dart';
import 'package:myapp/app/widgets/emoji_reaction_picker.dart';
import 'package:myapp/app/widgets/message_reply_widgets.dart';
import 'package:myapp/common/localization/l10n_extensions.dart';
import 'package:myapp/common/models/message.dart';
import 'package:myapp/common/models/shared_file_record.dart';
import 'package:myapp/common/utils/attachment_utils.dart';
import 'package:myapp/controllers/project_controller.dart';
import 'package:myapp/controllers/user_controller.dart';
import 'package:myapp/l10n/app_localizations.dart';
import 'package:myapp/models/project.dart';
import 'package:myapp/services/chat_attachment_service.dart';

class CollaborationChatScreen extends StatefulWidget {
  const CollaborationChatScreen({super.key, this.initialContactId});

  final String? initialContactId;

  @override
  State<CollaborationChatScreen> createState() =>
      _CollaborationChatScreenState();
}

class _CollaborationChatScreenState extends State<CollaborationChatScreen> {
  String? _selectedProjectId;
  bool _didInit = false;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatAttachmentService _attachmentService = ChatAttachmentService();
  final List<UploadedAttachment> _pendingAttachments = [];
  final Map<String, GlobalKey> _messageRowKeys = <String, GlobalKey>{};
  bool _isUploadingAttachment = false;
  MessageReplyPreview? _replyingTo;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInit) return;
    _didInit = true;
    final contactId = widget.initialContactId;
    if (contactId == null) return;
    final controller = context.read<ProjectController>();
    for (final proj in controller.projects) {
      final hasMember = proj.members.any(
        (m) => m.id == contactId || m.contactId == contactId,
      );
      if (hasMember) {
        setState(() => _selectedProjectId = proj.id);
        return;
      }
    }
  }

  void _handleSend(Project project) {
    final pendingAttachments = List<UploadedAttachment>.from(
      _pendingAttachments,
    );
    final typedText = _messageController.text.trim();
    final attachments = pendingAttachments
        .map((attachment) => attachment.url)
        .where((url) => url.isNotEmpty)
        .toList(growable: false);
    if (typedText.isEmpty && attachments.isEmpty) return;

    FocusScope.of(context).unfocus();
    final controller = context.read<ProjectController>();
    final authorId = _viewerId(controller);
    final replyPrefix = _replyPrefixText();
    final body = replyPrefix == null
        ? typedText
        : typedText.isEmpty
        ? replyPrefix.trimRight()
        : '$replyPrefix$typedText';
    final mentions = _extractMentions(body);
    final receipts = <String, MessageReceiptStatus>{
      for (final member in project.members)
        member.id: MessageReceiptStatus.sent,
    };
    receipts[authorId] = MessageReceiptStatus.read;

    controller.addMessage(
      project.id,
      Message(
        id: 'workspace-${DateTime.now().millisecondsSinceEpoch}',
        authorId: authorId,
        body: body,
        sentAt: DateTime.now(),
        attachments: attachments,
        mentions: mentions,
        receipts: receipts,
        replyToMessageId: _replyingTo?.messageId,
        replyPreview: _replyingTo,
      ),
    );

    _messageController.clear();
    _clearReply();
    if (_pendingAttachments.isNotEmpty) {
      setState(() => _pendingAttachments.clear());
    }
    _recordSharedFileUploads(project: project, attachments: pendingAttachments);
    _scrollToBottom();
  }

  String _tagTokenFromName(String name) {
    final cleaned = name.trim().replaceAll(RegExp(r'\s+'), '_');
    final buffer = StringBuffer();
    for (final rune in cleaned.runes) {
      final ch = String.fromCharCode(rune);
      if (RegExp(r'[A-Za-z0-9_]').hasMatch(ch)) {
        buffer.write(ch);
      }
    }
    final token = buffer.toString();
    return token.isEmpty ? 'user' : token;
  }

  String? _replyPrefixText() {
    final preview = _replyingTo;
    if (preview == null) {
      return null;
    }
    final token = _tagTokenFromName(preview.authorName);
    return '@$token ';
  }

  void _startReply(MessageReplyPreview preview) {
    setState(() => _replyingTo = preview);
  }

  void _clearReply() {
    if (_replyingTo == null) {
      return;
    }
    setState(() => _replyingTo = null);
  }

  void _handleReaction(String projectId, String messageId, String emoji) {
    final controller = context.read<ProjectController>();
    controller.addReaction(projectId, messageId, emoji);
  }

  Future<void> _handleAttachmentSelected(ChatAttachmentSource source) async {
    if (_isUploadingAttachment) {
      return;
    }
    setState(() => _isUploadingAttachment = true);
    try {
      final uploaded = await _attachmentService.pickAndUpload(source);
      if (!mounted || uploaded == null) {
        return;
      }
      setState(() => _pendingAttachments.add(uploaded));
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showAttachmentError();
    } finally {
      if (mounted) {
        setState(() => _isUploadingAttachment = false);
      }
    }
  }

  void _removePendingAttachment(UploadedAttachment attachment) {
    setState(() {
      _pendingAttachments.removeWhere((item) => item.url == attachment.url);
    });
  }

  void _showAttachmentError() {
    if (!mounted) {
      return;
    }
    final loc = context.l10n;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(loc.chatAttachmentUploadError)));
  }

  void _recordSharedFileUploads({
    required Project project,
    required List<UploadedAttachment> attachments,
    SharedFileOrigin origin = SharedFileOrigin.chat,
  }) {
    if (attachments.isEmpty) {
      return;
    }
    final controller = context.read<ProjectController>();
    final userController = context.read<UserController>();
    final loc = context.l10n;
    final uploaderId =
        controller.currentUserId ?? controller.currentUserEmail ?? 'workspace';
    final uploaderName =
        userController.profile?.displayName ??
        controller.currentUserEmail ??
        loc.homeCollaboratorFallback;
    final drafts = attachments
        .where((attachment) => attachment.url.isNotEmpty)
        .map(
          (attachment) => SharedFileDraft(
            fileUrl: attachment.url,
            fileName: attachment.name,
            contentType: attachment.contentType,
            sizeBytes: attachment.sizeBytes,
            origin: origin,
            uploaderId: uploaderId,
            uploaderName: uploaderName,
            projectId: project.id,
            projectName: project.name,
          ),
        )
        .toList(growable: false);
    for (final draft in drafts) {
      unawaited(controller.saveSharedFile(draft));
    }
  }

  List<String> _extractMentions(String text) {
    final matches = RegExp(r'@[A-Za-z0-9_]+').allMatches(text);
    return {
      for (final match in matches) match.group(0)!,
    }.toList(growable: false);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _jumpToMessage(String messageId, List<Message> ordered) async {
    if (!mounted) return;
    final loc = context.l10n;
    final messenger = ScaffoldMessenger.of(context);

    final key = _messageRowKeys[messageId];
    final ctx = key?.currentContext;
    if (ctx != null) {
      if (!ctx.mounted) return;
      unawaited(
        Scrollable.ensureVisible(
          ctx,
          alignment: 0.2,
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOut,
        ),
      );
      return;
    }

    final targetIndex = ordered.indexWhere((m) => m.id == messageId);
    if (targetIndex == -1 || !_scrollController.hasClients) {
      if (!mounted) return;
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(loc.chatMessageNotAvailable)));
      return;
    }

    final denom = ordered.length <= 1 ? 1 : ordered.length - 1;
    final fraction = targetIndex / denom;
    final estimatedOffset =
        _scrollController.position.maxScrollExtent * fraction;

    await _scrollController.animateTo(
      estimatedOffset,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );

    if (!mounted) return;

    for (var attempt = 0; attempt < 6; attempt++) {
      await Future<void>.delayed(const Duration(milliseconds: 40));
      if (!mounted) return;
      final afterCtx = _messageRowKeys[messageId]?.currentContext;
      if (afterCtx != null) {
        if (!afterCtx.mounted) {
          continue;
        }
        unawaited(
          Scrollable.ensureVisible(
            afterCtx,
            alignment: 0.2,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
          ),
        );
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = context.l10n;
    final controller = context.watch<ProjectController>();
    final projects = controller.projects;
    final viewerId = _viewerId(controller);
    final project = _activeProject(projects);

    if (project == null) {
      return _EmptyWorkspaceState(
        icon: Icons.chat_outlined,
        message: loc.chatsEmptyTitle,
      );
    }

    String? targetContactName;
    if (widget.initialContactId != null) {
      final controllerForName = context.read<ProjectController>();
      final contact = controllerForName.contactById(widget.initialContactId!);
      if (contact != null) {
        targetContactName = contact.name;
      } else {
        // try to find a member with this id
        for (final proj in controllerForName.projects) {
          final member = proj.members.firstWhere(
            (m) =>
                m.id == widget.initialContactId ||
                m.contactId == widget.initialContactId,
            orElse: () => Member(id: '', name: ''),
          );
          if (member.id.isNotEmpty) {
            targetContactName = member.name;
            break;
          }
        }
      }
    }

    final rawMessages = List<Message>.from(controller.messagesFor(project.id))
      ..sort((a, b) => a.sentAt.compareTo(b.sentAt));
    final messagesById = {
      for (final message in rawMessages) message.id: message,
    };
    final members = {for (final member in project.members) member.id: member};
    final workspaceMessages = rawMessages
        .map((message) {
          final member = members[message.authorId];
          final isMine = message.authorId == viewerId;
          final authorName = isMine
              ? loc.homeAuthorYou
              : _resolveAuthorName(
                  authorId: message.authorId,
                  member: member,
                  controller: controller,
                  loc: loc,
                );
          return _WorkspaceMessage(
            projectId: project.id,
            messageId: message.id,
            authorId: message.authorId,
            authorName: authorName,
            body: message.body,
            isMine: isMine,
            sentAt: message.sentAt,
            attachments: message.attachments,
            mentions: message.mentions,
            reactions: message.reactions,
            replyToMessageId: message.replyToMessageId,
            replyPreview: message.replyPreview,
            member: member,
          );
        })
        .toList(growable: false);

    final unread = rawMessages
        .where(
          (message) =>
              message.authorId != viewerId &&
              message.receipts[viewerId] != MessageReceiptStatus.read,
        )
        .toList(growable: false);

    if (unread.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        for (final message in unread) {
          controller.markReceipt(
            projectId: project.id,
            messageId: message.id,
            memberId: viewerId,
            status: MessageReceiptStatus.read,
          );
        }
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

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
        title: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => context.pushNamed(
              'projectChat',
              pathParameters: {'id': project.id},
            ),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    project.name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: AppColors.secondaryText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    project.client.isEmpty
                        ? loc.projectDetailClientPlaceholder
                        : project.client,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppColors.hintTextfiled,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          if (projects.length > 1)
            PopupMenuButton<String>(
              tooltip: loc.projectDetailMenuProjectChat,
              icon: const Icon(
                FeatherIcons.layers,
                color: AppColors.secondaryText,
              ),
              onSelected: (value) {
                setState(() => _selectedProjectId = value);
              },
              itemBuilder: (context) => projects
                  .map(
                    (proj) => PopupMenuItem<String>(
                      value: proj.id,
                      child: Text(proj.name),
                    ),
                  )
                  .toList(growable: false),
            ),
          IconButton(
            tooltip: loc.collaborationChatSharedFilesTooltip,
            icon: const Icon(
              FeatherIcons.folder,
              color: AppColors.secondaryText,
            ),
            onPressed: () => context.pushNamed('sharedFiles'),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  if (targetContactName != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryBackground,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              FeatherIcons.messageCircle,
                              color: AppColors.secondary,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '${loc.collaborationChatTitleFallback}: $targetContactName',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: AppColors.secondaryText,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Expanded(
                    child: ListView.separated(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                      itemBuilder: (context, index) {
                        final message = workspaceMessages[index];
                        final rowKey = _messageRowKeys.putIfAbsent(
                          message.messageId,
                          () => GlobalKey(),
                        );
                        final replyAuthorName =
                            message.member?.name ?? message.authorName;
                        final replyPreview = MessageReplyPreview(
                          messageId: message.messageId,
                          authorId: message.authorId,
                          authorName: replyAuthorName,
                          authorAvatarUrl: message.member?.avatarUrl,
                          sentAt: message.sentAt,
                          body: message.body,
                          attachments: message.attachments,
                        );

                        final bubble = _MessageBubble(
                          message: message,
                          authorName: message.authorName,
                          viewerId: viewerId,
                          membersById: members,
                          messagesById: messagesById,
                          onReply: () => _startReply(replyPreview),
                          onJumpToMessage: (id) =>
                              _jumpToMessage(id, rawMessages),
                          onAuthorTap: () => _openAuthor(
                            project: project,
                            member: message.member,
                            authorId: message.authorId,
                            authorName: message.authorName,
                          ),
                          onReact: (emoji) => _handleReaction(
                            message.projectId,
                            message.messageId,
                            emoji,
                          ),
                        );

                        return KeyedSubtree(
                          key: rowKey,
                          child: Dismissible(
                            key: ValueKey(
                              'reply-${message.projectId}-${message.messageId}',
                            ),
                            direction: DismissDirection.horizontal,
                            dismissThresholds: const {
                              DismissDirection.startToEnd: 0.2,
                              DismissDirection.endToStart: 0.2,
                            },
                            background: const _SwipeReplyBackground(
                              alignment: AlignmentDirectional.centerStart,
                            ),
                            secondaryBackground: const _SwipeReplyBackground(
                              alignment: AlignmentDirectional.centerEnd,
                            ),
                            confirmDismiss: (_) async {
                              _startReply(replyPreview);
                              return false;
                            },
                            child: bubble,
                          ),
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemCount: workspaceMessages.length,
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.textfieldBorder),
                  _MessageComposer(
                    controller: _messageController,
                    onSend: () => _handleSend(project),
                    replyingTo: _replyingTo,
                    replyPrefixText: _replyPrefixText(),
                    onCancelReply: _clearReply,
                    attachments: List<UploadedAttachment>.unmodifiable(
                      _pendingAttachments,
                    ),
                    onAttachmentSelected: (source) =>
                        _handleAttachmentSelected(source),
                    onAttachmentRemoved: _removePendingAttachment,
                    isUploadingAttachment: _isUploadingAttachment,
                    bottomPadding: CustomNavBar.totalHeight + 24,
                  ),
                ],
              ),
            ),
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomNavBar(currentRouteName: 'crm'),
          ),
        ],
      ),
    );
  }

  Project? _activeProject(List<Project> projects) {
    if (projects.isEmpty) {
      return null;
    }
    for (final project in projects) {
      if (project.id == _selectedProjectId) {
        return project;
      }
    }
    final fallback = projects.first;
    if (_selectedProjectId != fallback.id) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() => _selectedProjectId = fallback.id);
      });
    }
    return fallback;
  }

  void _openAuthor({
    required Project project,
    Member? member,
    required String authorId,
    required String authorName,
  }) {
    if (!mounted) return;
    final controller = context.read<ProjectController>();
    final viewerId = _viewerId(controller);
    if (authorId == viewerId) {
      context.pushNamed('profile');
      return;
    }
    final detailArgs = controller.buildContactDetailArgs(
      member: member ?? Member(id: authorId, name: authorName),
      currentProject: project,
    );
    context.pushNamed('contactDetail', extra: detailArgs);
  }

  String _viewerId(ProjectController controller) {
    final id = controller.currentUserId;
    if (id == null || id.isEmpty) {
      return 'me';
    }
    return id;
  }

  String _resolveAuthorName({
    required String authorId,
    Member? member,
    required ProjectController controller,
    required AppLocalizations loc,
  }) {
    if (member != null) {
      final contact = controller.contactForMember(member);
      if (contact != null && contact.name.isNotEmpty) {
        return contact.name;
      }
      if (member.name.isNotEmpty) {
        return member.name;
      }
    }
    final contact = controller.contactById(authorId);
    if (contact != null && contact.name.isNotEmpty) {
      return contact.name;
    }
    return loc.homeCollaboratorFallback;
  }
}

class _SwipeReplyBackground extends StatelessWidget {
  const _SwipeReplyBackground({required this.alignment});

  final AlignmentDirectional alignment;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
        ),
        child: const Icon(
          Icons.reply_outlined,
          color: AppColors.primary,
          size: 20,
        ),
      ),
    );
  }
}

class _MessageComposer extends StatelessWidget {
  const _MessageComposer({
    required this.controller,
    required this.onSend,
    this.replyingTo,
    this.replyPrefixText,
    this.onCancelReply,
    required this.attachments,
    required this.onAttachmentSelected,
    required this.onAttachmentRemoved,
    required this.isUploadingAttachment,
    this.bottomPadding = 20,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final MessageReplyPreview? replyingTo;
  final String? replyPrefixText;
  final VoidCallback? onCancelReply;
  final List<UploadedAttachment> attachments;
  final ValueChanged<ChatAttachmentSource> onAttachmentSelected;
  final ValueChanged<UploadedAttachment> onAttachmentRemoved;
  final bool isUploadingAttachment;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = context.l10n;

    return SafeArea(
      top: false,
      minimum: EdgeInsets.fromLTRB(16, 12, 16, bottomPadding),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.secondaryBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 16,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
          child: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) {
              final hasText = value.text.trim().isNotEmpty;
              final hasAttachments = attachments.isNotEmpty;
              final canSend = hasText || hasAttachments;

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isUploadingAttachment)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: LinearProgressIndicator(minHeight: 3),
                    ),
                  if (isUploadingAttachment) const SizedBox(height: 12),
                  if (replyingTo != null) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: MessageReplyBanner(
                        preview: replyingTo!,
                        onCancel: onCancelReply ?? () {},
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (hasAttachments)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: attachments
                          .map(
                            (attachment) => _AttachmentChip(
                              attachment: attachment,
                              onRemoved: onAttachmentRemoved,
                            ),
                          )
                          .toList(growable: false),
                    ),
                  if (hasAttachments) const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _ComposerActionIcon(
                        icon: FeatherIcons.paperclip,
                        tooltip: loc.collaborationChatAddAttachment,
                        onTap: isUploadingAttachment
                            ? null
                            : () => _showAttachmentOptions(
                                context,
                                onSelected: onAttachmentSelected,
                              ),
                        enabled: !isUploadingAttachment,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: controller,
                          minLines: 1,
                          maxLines: 6,
                          decoration: InputDecoration(
                            hintText: loc.collaborationChatComposerHint,
                            hintStyle: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.hintTextfiled,
                              fontWeight: FontWeight.w600,
                            ),
                            prefixText: replyPrefixText,
                            prefixStyle: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                            filled: true,
                            fillColor: AppColors.textfieldBackground,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 18,
                            ),
                          ),
                          textInputAction: TextInputAction.newline,
                          onSubmitted: (_) {
                            if (canSend) onSend();
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      _ComposerActionIcon(
                        icon: FeatherIcons.send,
                        tooltip: loc.collaborationChatSendMessage,
                        onTap: canSend ? onSend : null,
                        enabled: canSend,
                        variant: _ComposerButtonVariant.primary,
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

enum _ComposerButtonVariant { primary, secondary }

class _ComposerActionIcon extends StatelessWidget {
  const _ComposerActionIcon({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.enabled = true,
    this.variant = _ComposerButtonVariant.secondary,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  final bool enabled;
  final _ComposerButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final isPrimary = variant == _ComposerButtonVariant.primary;
    final isEnabled = enabled && onTap != null;
    final gradient = isPrimary && isEnabled
        ? const LinearGradient(
            colors: [AppColors.secondary, AppColors.primary],
            begin: AlignmentDirectional(1.0, 0.34),
            end: AlignmentDirectional(-1.0, -0.34),
          )
        : null;

    final Color backgroundColor;
    final Color borderColor;
    final Color iconColor;

    if (isPrimary) {
      backgroundColor = isEnabled
          ? Colors.transparent
          : AppColors.textfieldBackground;
      borderColor = isEnabled
          ? Colors.transparent
          : AppColors.textfieldBorder.withValues(alpha: 0.6);
      iconColor = isEnabled ? AppColors.primaryText : AppColors.hintTextfiled;
    } else {
      backgroundColor = AppColors.textfieldBackground;
      borderColor = AppColors.textfieldBorder.withValues(alpha: 0.6);
      iconColor = AppColors.secondary;
    }

    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: isEnabled ? onTap : null,
          child: Ink(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: gradient,
              color: gradient == null ? backgroundColor : null,
              border: Border.all(color: borderColor),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
        ),
      ),
    );
  }
}

class _EmptyWorkspaceState extends StatelessWidget {
  const _EmptyWorkspaceState({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: SafeArea(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 58, color: AppColors.hintTextfiled),
                    const SizedBox(height: 16),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppColors.secondaryText,
                        fontWeight: FontWeight.bold,
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
            child: CustomNavBar(currentRouteName: 'crm'),
          ),
        ],
      ),
    );
  }
}

void _showAttachmentOptions(
  BuildContext context, {
  required ValueChanged<ChatAttachmentSource> onSelected,
}) {
  final loc = context.l10n;
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      final theme = Theme.of(sheetContext);
      final bottomPadding = MediaQuery.of(sheetContext).viewPadding.bottom;
      return SafeArea(
        top: false,
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.secondaryBackground,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 24,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(24, 20, 24, 16 + bottomPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    loc.collaborationChatAttachTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.secondaryText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _AttachmentOption(
                  icon: FeatherIcons.image,
                  label: loc.collaborationChatAttachPhoto,
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    onSelected(ChatAttachmentSource.photoLibrary);
                  },
                ),
                _AttachmentOption(
                  icon: FeatherIcons.fileText,
                  label: loc.collaborationChatAttachDocument,
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    onSelected(ChatAttachmentSource.document);
                  },
                ),
                _AttachmentOption(
                  icon: FeatherIcons.file,
                  label: loc.collaborationChatAttachPdf,
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    onSelected(ChatAttachmentSource.pdf);
                  },
                ),
                _AttachmentOption(
                  icon: FeatherIcons.camera,
                  label: loc.collaborationChatAttachCamera,
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    onSelected(ChatAttachmentSource.camera);
                  },
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _AttachmentOption extends StatelessWidget {
  const _AttachmentOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(icon, color: AppColors.secondary, size: 22),
      title: Text(
        label,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: AppColors.secondaryText,
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      dense: true,
    );
  }
}

class _AttachmentChip extends StatelessWidget {
  const _AttachmentChip({required this.attachment, required this.onRemoved});

  final UploadedAttachment attachment;
  final ValueChanged<UploadedAttachment> onRemoved;

  @override
  Widget build(BuildContext context) {
    return InputChip(
      label: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 160),
        child: Text(
          attachment.name,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: AppColors.secondaryText,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      onDeleted: () => onRemoved(attachment),
      deleteIcon: const Icon(Icons.close, size: 16),
      deleteIconColor: AppColors.hintTextfiled,
      backgroundColor: AppColors.textfieldBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: AppColors.textfieldBorder.withValues(alpha: 0.6),
        ),
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.onReact,
    required this.onReply,
    required this.onJumpToMessage,
    required this.authorName,
    required this.onAuthorTap,
    required this.viewerId,
    required this.membersById,
    required this.messagesById,
  });

  final _WorkspaceMessage message;
  final ValueChanged<String> onReact;
  final VoidCallback onReply;
  final ValueChanged<String> onJumpToMessage;
  final String authorName;
  final VoidCallback onAuthorTap;

  final String viewerId;
  final Map<String, Member> membersById;
  final Map<String, Message> messagesById;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final alignment = message.isMine
        ? MainAxisAlignment.end
        : MainAxisAlignment.start;

    final baseStyle = theme.textTheme.bodyMedium?.copyWith(
      color: AppColors.secondaryText,
      fontWeight: FontWeight.w600,
    );
    final mentionStyle = baseStyle?.copyWith(
      color: AppColors.primary,
      fontWeight: FontWeight.bold,
    );

    final bubbleDecoration = BoxDecoration(
      color: message.isMine
          ? AppColors.primary.withValues(alpha: 0.1)
          : AppColors.textfieldBackground,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(message.isMine ? 20 : 8),
        topRight: Radius.circular(message.isMine ? 8 : 20),
        bottomLeft: const Radius.circular(20),
        bottomRight: const Radius.circular(20),
      ),
      border: Border.all(
        color: message.isMine
            ? AppColors.primary.withValues(alpha: 0.2)
            : AppColors.textfieldBorder.withValues(alpha: 0.6),
      ),
    );

    final timeStyle = theme.textTheme.labelSmall?.copyWith(
      color: AppColors.hintTextfiled,
      fontWeight: FontWeight.w600,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment: alignment,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isMine) ...[
            _MessageAvatar(label: authorName, onTap: onAuthorTap),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: message.isMine
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding: EdgeInsetsDirectional.fromSTEB(18, 16, 54, 16),
                      decoration: bubbleDecoration,
                      child: Column(
                        crossAxisAlignment: message.isMine
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          Builder(
                            builder: (context) {
                              final preview = _resolveReplyPreview(context);
                              if (preview == null) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: QuotedReplyBlock(
                                  preview: preview,
                                  isMine: message.isMine,
                                  onTap: () {
                                    final targetId =
                                        message.replyToMessageId ??
                                        preview.messageId;
                                    if (targetId.trim().isEmpty) return;
                                    onJumpToMessage(targetId);
                                  },
                                ),
                              );
                            },
                          ),
                          if (baseStyle != null)
                            RichText(
                              text: TextSpan(
                                style: baseStyle,
                                children: _buildBodySpans(
                                  message.body,
                                  message.mentions,
                                  baseStyle,
                                  mentionStyle ?? baseStyle,
                                ),
                              ),
                            )
                          else
                            Text(message.body),
                          if (message.attachments.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            _AttachmentStrip(
                              attachments: message.attachments,
                              highlight: message.isMine,
                            ),
                          ],
                          if (message.reactions.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            _ReactionBar(reactions: message.reactions),
                          ],
                        ],
                      ),
                    ),
                    PositionedDirectional(
                      top: 4,
                      end: 4,
                      child: _BubbleActionButton(
                        highlight: message.isMine,
                        onTap: () => showEmojiReactionPicker(
                          context: context,
                          onSelected: onReact,
                          onReply: onReply,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: message.isMine
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: onAuthorTap,
                      child: Text(
                        authorName,
                        style: timeStyle?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondaryText,
                          decoration: TextDecoration.underline,
                          decorationStyle: TextDecorationStyle.dotted,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(message.timeLabel, style: timeStyle),
                  ],
                ),
              ],
            ),
          ),
          if (message.isMine) ...[
            const SizedBox(width: 12),
            _MessageAvatar(label: authorName, onTap: onAuthorTap),
          ],
        ],
      ),
    );
  }

  List<InlineSpan> _buildBodySpans(
    String body,
    List<String> mentions,
    TextStyle base,
    TextStyle mentionStyle,
  ) {
    final spans = <InlineSpan>[];
    final mentionSet = mentions.toSet();
    final regex = RegExp(r'@[A-Za-z0-9_]+');
    var cursor = 0;

    for (final match in regex.allMatches(body)) {
      var start = match.start;
      var end = match.end;
      final mentionToken = match.group(0)!;

      if (start > cursor) {
        spans.add(TextSpan(text: body.substring(cursor, start), style: base));
      }

      final displayToken = body.substring(start, end);
      final style = mentionSet.isEmpty || mentionSet.contains(mentionToken)
          ? mentionStyle
          : base;
      spans.add(TextSpan(text: displayToken, style: style));
      cursor = end;
    }

    if (cursor < body.length) {
      spans.add(TextSpan(text: body.substring(cursor), style: base));
    }

    return spans;
  }

  MessageReplyPreview? _resolveReplyPreview(BuildContext context) {
    final direct = message.replyPreview;
    if (direct != null && direct.messageId.isNotEmpty) {
      return direct;
    }

    final replyToId = message.replyToMessageId;
    if (replyToId == null || replyToId.trim().isEmpty) {
      return null;
    }

    final original = messagesById[replyToId];
    final loc = context.l10n;

    if (original == null) {
      return MessageReplyPreview(
        messageId: replyToId,
        authorId: '',
        authorName: loc.homeCollaboratorFallback,
        sentAt: DateTime.now(),
        body: loc.chatMessageNotAvailable,
        attachments: const [],
      );
    }

    final member = membersById[original.authorId];
    final resolvedAuthorName = member?.name ?? loc.homeCollaboratorFallback;

    return MessageReplyPreview(
      messageId: original.id,
      authorId: original.authorId,
      authorName: resolvedAuthorName,
      authorAvatarUrl: member?.avatarUrl,
      sentAt: original.sentAt,
      body: original.body,
      attachments: original.attachments,
    );
  }
}

class _AttachmentStrip extends StatelessWidget {
  const _AttachmentStrip({required this.attachments, required this.highlight});

  final List<String> attachments;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: attachments
          .map(
            (attachment) =>
                _AttachmentTile(filename: attachment, highlight: highlight),
          )
          .toList(growable: false),
    );
  }
}

class _BubbleActionButton extends StatelessWidget {
  const _BubbleActionButton({required this.onTap, required this.highlight});

  final VoidCallback onTap;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final iconColor = highlight ? AppColors.secondary : AppColors.hintTextfiled;
    final hoverColor = AppColors.primary.withValues(alpha: 0.08);
    final splashColor = AppColors.primary.withValues(alpha: 0.12);

    return Tooltip(
      message: context.l10n.collaborationChatReactTooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          hoverColor: hoverColor,
          splashColor: splashColor,
          highlightColor: splashColor,
          onTap: onTap,
          child: SizedBox(
            width: 36,
            height: 36,
            child: Icon(FeatherIcons.moreVertical, size: 20, color: iconColor),
          ),
        ),
      ),
    );
  }
}

class _AttachmentTile extends StatelessWidget {
  const _AttachmentTile({required this.filename, required this.highlight});

  final String filename;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final normalized = AttachmentUtils.normalizedName(filename);
    final displayName = AttachmentUtils.displayName(filename);
    IconData icon;
    Color iconColor;

    if (_isImage(normalized)) {
      icon = Icons.image_outlined;
      iconColor = AppColors.secondary;
    } else if (normalized.endsWith('.pdf')) {
      icon = Icons.picture_as_pdf_outlined;
      iconColor = Colors.redAccent;
    } else if (normalized.endsWith('.doc') || normalized.endsWith('.docx')) {
      icon = Icons.description_outlined;
      iconColor = AppColors.secondary;
    } else if (normalized.endsWith('.xlsx') || normalized.endsWith('.csv')) {
      icon = Icons.table_chart_outlined;
      iconColor = Colors.teal;
    } else {
      icon = Icons.insert_drive_file_outlined;
      iconColor = AppColors.hintTextfiled;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: highlight
            ? AppColors.primary.withValues(alpha: 0.08)
            : AppColors.secondaryBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: highlight
              ? AppColors.primary.withValues(alpha: 0.2)
              : AppColors.textfieldBorder.withValues(alpha: 0.7),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 10),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 160),
            child: Text(
              displayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.secondaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isImage(String lower) {
    return lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.gif');
  }
}

class _ReactionBar extends StatelessWidget {
  const _ReactionBar({required this.reactions});

  final Map<String, int> reactions;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: reactions.entries
          .map((entry) => _ReactionPill(emoji: entry.key, count: entry.value))
          .toList(growable: false),
    );
  }
}

class _ReactionPill extends StatelessWidget {
  const _ReactionPill({required this.emoji, required this.count});

  final String emoji;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.textfieldBorder.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: theme.textTheme.labelLarge),
          const SizedBox(width: 6),
          Text(
            '$count',
            style: theme.textTheme.labelMedium?.copyWith(
              color: AppColors.secondaryText,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkspaceMessage {
  const _WorkspaceMessage({
    required this.projectId,
    required this.messageId,
    required this.authorId,
    required this.authorName,
    required this.body,
    required this.sentAt,
    required this.isMine,
    required this.attachments,
    required this.mentions,
    required this.reactions,
    this.replyToMessageId,
    this.replyPreview,
    this.member,
  });

  final String projectId;
  final String messageId;
  final String authorId;
  final String authorName;
  final String body;
  final DateTime sentAt;
  final bool isMine;
  final List<String> attachments;
  final List<String> mentions;
  final Map<String, int> reactions;
  final String? replyToMessageId;
  final MessageReplyPreview? replyPreview;
  final Member? member;

  String get timeLabel => DateFormat.Hm().format(sentAt);
}

class _MessageAvatar extends StatelessWidget {
  const _MessageAvatar({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final avatar = Container(
      width: 38,
      height: 38,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [AppColors.secondary, AppColors.primary],
          begin: AlignmentDirectional(1.0, 0.34),
          end: AlignmentDirectional(-1.0, -0.34),
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        label.isEmpty ? '?' : label[0].toUpperCase(),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: AppColors.primaryText,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: avatar,
      ),
    );
  }
}
