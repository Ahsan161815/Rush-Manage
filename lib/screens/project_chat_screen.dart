import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:myapp/app/app_theme.dart';
import 'package:myapp/app/widgets/custom_nav_bar.dart';
import 'package:myapp/app/widgets/emoji_reaction_picker.dart';
import 'package:myapp/common/models/message.dart';
import 'package:myapp/common/localization/formatters.dart';
import 'package:myapp/common/localization/l10n_extensions.dart';
import 'package:myapp/controllers/project_controller.dart';
import 'package:myapp/models/project.dart';

class ProjectChatScreen extends StatefulWidget {
  const ProjectChatScreen({super.key, required this.projectId});

  final String projectId;

  @override
  State<ProjectChatScreen> createState() => _ProjectChatScreenState();
}

class _ProjectChatScreenState extends State<ProjectChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleSend(Project project) {
    final text = _messageController.text.trim();
    if (text.isEmpty) {
      return;
    }

    FocusScope.of(context).unfocus();
    final mentionMatches = RegExp(r'@[A-Za-z0-9_]+').allMatches(text);
    final mentions = {
      for (final match in mentionMatches) match.group(0)!,
    }.toList(growable: false);
    final controller = context.read<ProjectController>();
    final receipts = <String, MessageReceiptStatus>{
      for (final member in project.members)
        member.id: MessageReceiptStatus.sent,
    };
    receipts['me'] = MessageReceiptStatus.read;
    controller.addMessage(
      project.id,
      Message(
        id: 'local-${DateTime.now().millisecondsSinceEpoch}',
        authorId: 'me',
        body: text,
        sentAt: DateTime.now(),
        mentions: mentions,
        receipts: receipts,
      ),
    );

    _messageController.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) {
      return;
    }

    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent + 56,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  void _handleAuthorTap({
    required Project project,
    Member? member,
    required String authorId,
    required String fallbackName,
  }) {
    if (!mounted) {
      return;
    }

    if (authorId == 'me') {
      context.pushNamed('profile');
      return;
    }

    final controller = context.read<ProjectController>();
    final detailArgs = controller.buildContactDetailArgs(
      member: member ?? Member(id: authorId, name: fallbackName),
      currentProject: project,
    );

    context.pushNamed('contactDetail', extra: detailArgs);
  }

  void _showProjectMembersSheet(Project project) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final controller = context.read<ProjectController>();
        final members = project.members;
        final loc = sheetContext.l10n;

        return SafeArea(
          top: false,
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.secondaryBackground,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 46,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.textfieldBorder.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    loc.projectChatCollaboratorsTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.secondaryText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (members.isEmpty)
                    Text(
                      loc.projectChatCollaboratorsEmpty,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.hintTextfiled,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  else
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 420),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: members.length,
                        separatorBuilder: (_, __) => const Divider(
                          color: AppColors.textfieldBorder,
                          height: 1,
                        ),
                        itemBuilder: (_, index) {
                          final member = members[index];
                          final contact = controller.contactForMember(member);
                          final subtitle =
                              contact?.profession ??
                              loc.projectChatCollaboratorRoleFallback;
                          return _MemberTile(
                            member: member,
                            subtitle: subtitle,
                            onTap: () {
                              Navigator.of(sheetContext).pop();
                              _handleAuthorTap(
                                project: project,
                                member: member,
                                authorId: member.id,
                                fallbackName: member.name,
                              );
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ProjectController>();
    final project = controller.getById(widget.projectId);
    final loc = context.l10n;

    if (project == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            Positioned.fill(
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    24,
                    0,
                    24,
                    CustomNavBar.totalHeight + 24,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          loc.projectNotFoundTitle,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: AppColors.secondaryText,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => context.goNamed('management'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.primaryText,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(loc.projectDetailBackToProjects),
                        ),
                      ],
                    ),
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

    final messages = List<Message>.from(controller.messagesFor(project.id))
      ..sort((a, b) => a.sentAt.compareTo(b.sentAt));
    final members = {for (final member in project.members) member.id: member};

    final unreadByMe = messages
        .where(
          (message) =>
              message.authorId != 'me' &&
              message.receipts['me'] != MessageReceiptStatus.read,
        )
        .toList(growable: false);

    if (unreadByMe.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        for (final message in unreadByMe) {
          controller.markReceipt(
            projectId: project.id,
            messageId: message.id,
            memberId: 'me',
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
          icon: const Icon(Icons.chevron_left, color: AppColors.secondaryText),
          onPressed: () => context.pop(),
        ),
        title: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showProjectMembersSheet(project),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    project.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.secondaryText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    loc.projectChatViewCollaboratorsHint,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.hintTextfiled,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isMine = message.authorId == 'me';
                      final author = members[message.authorId];
                      final authorName = isMine
                          ? loc.homeAuthorYou
                          : (author?.name ?? loc.homeCollaboratorFallback);
                      return _ChatBubble(
                        message: message,
                        author: author,
                        authorName: authorName,
                        isMine: isMine,
                        onReact: (emoji) => controller.addReaction(
                          project.id,
                          message.id,
                          emoji,
                        ),
                        members: project.members,
                        onAuthorTap: () => _handleAuthorTap(
                          project: project,
                          member: author,
                          authorId: message.authorId,
                          fallbackName: authorName,
                        ),
                      );
                    },
                  ),
                ),
                _ComposerBar(
                  controller: _messageController,
                  onSend: () => _handleSend(project),
                  bottomSpacing: CustomNavBar.totalHeight + 24,
                ),
              ],
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

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({
    required this.message,
    required this.author,
    required this.authorName,
    required this.isMine,
    required this.onReact,
    required this.members,
    required this.onAuthorTap,
  });

  final Message message;
  final Member? author;
  final String authorName;
  final bool isMine;
  final ValueChanged<String> onReact;
  final List<Member> members;
  final VoidCallback onAuthorTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = context.l10n;
    final statusIndicator = _statusIndicator(context, message, isMine);

    final baseTextStyle = theme.textTheme.bodyMedium?.copyWith(
      color: AppColors.secondaryText,
      fontWeight: FontWeight.w600,
    );
    final mentionStyle = baseTextStyle?.copyWith(
      color: AppColors.secondary,
      fontWeight: FontWeight.bold,
    );
    final metaStyle = theme.textTheme.labelSmall?.copyWith(
      color: AppColors.hintTextfiled,
      fontWeight: FontWeight.w600,
    );

    final bubbleDecoration = BoxDecoration(
      color: isMine
          ? AppColors.primary.withValues(alpha: 0.1)
          : AppColors.textfieldBackground,
      borderRadius: BorderRadius.only(
        topLeft: const Radius.circular(20),
        topRight: const Radius.circular(20),
        bottomLeft: Radius.circular(isMine ? 20 : 8),
        bottomRight: Radius.circular(isMine ? 8 : 20),
      ),
      border: Border.all(
        color: isMine
            ? AppColors.primary.withValues(alpha: 0.25)
            : AppColors.textfieldBorder.withValues(alpha: 0.6),
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: isMine
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isMine) ...[
            _ChatAvatar(label: authorName, onTap: onAuthorTap),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMine
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
                        crossAxisAlignment: isMine
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          if (baseTextStyle != null)
                            RichText(
                              text: TextSpan(
                                style: baseTextStyle,
                                children: _buildBodySpans(
                                  message.body,
                                  message.mentions,
                                  baseTextStyle,
                                  mentionStyle ?? baseTextStyle,
                                ),
                              ),
                            )
                          else
                            Text(message.body),
                          if (message.attachments.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            _AttachmentStrip(
                              attachments: message.attachments,
                              isMine: isMine,
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
                        isMine: isMine,
                        onTap: () => showEmojiReactionPicker(
                          context: context,
                          onSelected: onReact,
                        ),
                        tooltip: loc.collaborationChatReactTooltip,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: isMine
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: onAuthorTap,
                      child: Text(
                        authorName,
                        style: metaStyle?.copyWith(
                          decoration: TextDecoration.underline,
                          decorationStyle: TextDecorationStyle.dotted,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _relativeTimeLabel(context, message.sentAt),
                      style: metaStyle,
                    ),
                    const SizedBox(width: 8),
                    Tooltip(
                      message: statusIndicator.label,
                      child: Icon(
                        statusIndicator.icon,
                        size: 16,
                        color: statusIndicator.color,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isMine) ...[
            const SizedBox(width: 12),
            _ChatAvatar(label: authorName, onTap: onAuthorTap),
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
    var index = 0;

    for (final match in regex.allMatches(body)) {
      if (match.start > index) {
        spans.add(
          TextSpan(text: body.substring(index, match.start), style: base),
        );
      }
      final token = match.group(0)!;
      final style = mentionSet.isEmpty || mentionSet.contains(token)
          ? mentionStyle
          : base;
      spans.add(TextSpan(text: token, style: style));
      index = match.end;
    }

    if (index < body.length) {
      spans.add(TextSpan(text: body.substring(index), style: base));
    }

    return spans;
  }

  _StatusIndicator _statusIndicator(
    BuildContext context,
    Message message,
    bool isMine,
  ) {
    final receipts = message.receipts;
    final loc = context.l10n;

    if (isMine) {
      final recipientIds = members
          .map((member) => member.id)
          .where((id) => id != 'me' && id != message.authorId)
          .toList(growable: false);

      if (recipientIds.isEmpty) {
        final aggregated = _aggregateStatus(receipts.values);
        return _indicatorForOwn(context, aggregated);
      }

      var allRead = true;
      var anyReceived = false;

      for (final id in recipientIds) {
        final status = receipts[id] ?? MessageReceiptStatus.sent;
        if (status != MessageReceiptStatus.read) {
          allRead = false;
        }
        if (status == MessageReceiptStatus.received ||
            status == MessageReceiptStatus.read) {
          anyReceived = true;
        }
      }

      if (allRead) {
        return _indicatorForOwn(context, MessageReceiptStatus.read);
      }
      if (anyReceived) {
        return _indicatorForOwn(context, MessageReceiptStatus.received);
      }
      return _indicatorForOwn(context, MessageReceiptStatus.sent);
    }

    final myStatus = receipts['me'];
    switch (myStatus) {
      case MessageReceiptStatus.read:
        return _StatusIndicator(
          icon: Icons.check_circle,
          color: AppColors.secondary,
          label: loc.projectChatReceiptRead,
        );
      case MessageReceiptStatus.received:
        return _StatusIndicator(
          icon: Icons.check_circle_outline,
          color: AppColors.secondaryText,
          label: loc.projectChatReceiptReceived,
        );
      case MessageReceiptStatus.sent:
      case null:
        return _StatusIndicator(
          icon: Icons.radio_button_unchecked,
          color: AppColors.hintTextfiled,
          label: loc.projectChatReceiptUnread,
        );
    }
  }

  _StatusIndicator _indicatorForOwn(
    BuildContext context,
    MessageReceiptStatus status,
  ) {
    final loc = context.l10n;
    switch (status) {
      case MessageReceiptStatus.sent:
        return _StatusIndicator(
          icon: Icons.done,
          color: AppColors.hintTextfiled,
          label: loc.projectChatReceiptSent,
        );
      case MessageReceiptStatus.received:
        return _StatusIndicator(
          icon: Icons.done_all,
          color: AppColors.hintTextfiled,
          label: loc.projectChatReceiptReceived,
        );
      case MessageReceiptStatus.read:
        return _StatusIndicator(
          icon: Icons.done_all,
          color: AppColors.secondary,
          label: loc.projectChatReceiptRead,
        );
    }
  }

  MessageReceiptStatus _aggregateStatus(
    Iterable<MessageReceiptStatus> statuses,
  ) {
    var highest = MessageReceiptStatus.sent;
    for (final status in statuses) {
      if (status.index > highest.index) {
        highest = status;
      }
    }
    return highest;
  }
}

class _StatusIndicator {
  const _StatusIndicator({
    required this.icon,
    required this.color,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String label;
}

class _AttachmentStrip extends StatelessWidget {
  const _AttachmentStrip({required this.attachments, required this.isMine});

  final List<String> attachments;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: attachments
          .map(
            (attachment) =>
                _AttachmentTile(filename: attachment, isMine: isMine),
          )
          .toList(growable: false),
    );
  }
}

class _BubbleActionButton extends StatelessWidget {
  const _BubbleActionButton({
    required this.onTap,
    required this.isMine,
    required this.tooltip,
  });

  final VoidCallback onTap;
  final bool isMine;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final background = isMine
        ? AppColors.primary.withValues(alpha: 0.18)
        : AppColors.secondaryBackground;
    final borderColor = isMine
        ? AppColors.primary.withValues(alpha: 0.3)
        : AppColors.textfieldBorder.withValues(alpha: 0.55);
    final iconColor = isMine ? AppColors.secondary : AppColors.hintTextfiled;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Ink(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: background,
              border: Border.all(color: borderColor),
            ),
            child: Icon(
              Icons.emoji_emotions_outlined,
              size: 20,
              color: iconColor,
            ),
          ),
        ),
      ),
    );
  }
}

class _AttachmentTile extends StatelessWidget {
  const _AttachmentTile({required this.filename, required this.isMine});

  final String filename;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final lower = filename.toLowerCase();
    if (_isImage(lower)) {
      return _ImageAttachmentPreview(attachment: filename, isMine: isMine);
    }

    final theme = Theme.of(context);
    IconData icon;
    Color iconColor;

    if (lower.endsWith('.pdf')) {
      icon = Icons.picture_as_pdf_outlined;
      iconColor = Colors.redAccent;
    } else if (lower.endsWith('.doc') || lower.endsWith('.docx')) {
      icon = Icons.description_outlined;
      iconColor = AppColors.secondary;
    } else if (lower.endsWith('.xlsx') || lower.endsWith('.csv')) {
      icon = Icons.table_chart_outlined;
      iconColor = Colors.teal;
    } else if (lower.endsWith('.zip') || lower.endsWith('.rar')) {
      icon = Icons.folder_zip_outlined;
      iconColor = AppColors.secondary;
    } else {
      icon = Icons.insert_drive_file_outlined;
      iconColor = AppColors.hintTextfiled;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isMine
            ? AppColors.primary.withValues(alpha: 0.08)
            : AppColors.secondaryBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isMine
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
              filename,
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
        lower.endsWith('.gif') ||
        lower.endsWith('.webp');
  }
}

class _ImageAttachmentPreview extends StatelessWidget {
  const _ImageAttachmentPreview({
    required this.attachment,
    required this.isMine,
  });

  final String attachment;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(18);
    final borderColor = isMine
        ? AppColors.primary.withValues(alpha: 0.2)
        : AppColors.textfieldBorder.withValues(alpha: 0.7);

    return Container(
      width: 160,
      height: 120,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        border: Border.all(color: borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: _buildImageWidget(context),
    );
  }

  Widget _buildImageWidget(BuildContext context) {
    final image = attachment.trim();
    if (image.isEmpty) {
      return _ImageFallback(filename: attachment);
    }

    if (image.startsWith('http://') || image.startsWith('https://')) {
      return Image.network(
        image,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _ImageFallback(filename: attachment),
      );
    }

    if (image.startsWith('assets/')) {
      return Image.asset(
        image,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _ImageFallback(filename: attachment),
      );
    }

    return Image.asset(
      'assets/images/$image',
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _ImageFallback(filename: attachment),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback({required this.filename});

  final String filename;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: AppColors.textfieldBackground,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.broken_image_outlined,
            color: AppColors.hintTextfiled,
            size: 28,
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              filename,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.hintTextfiled,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReactionBar extends StatelessWidget {
  const _ReactionBar({required this.reactions});

  final Map<String, int> reactions;

  @override
  Widget build(BuildContext context) {
    if (reactions.isEmpty) {
      return const SizedBox.shrink();
    }

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

class _ChatAvatar extends StatelessWidget {
  const _ChatAvatar({required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final avatar = Container(
      width: 40,
      height: 40,
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

    if (onTap == null) {
      return avatar;
    }

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

class _MemberTile extends StatelessWidget {
  const _MemberTile({
    required this.member,
    required this.subtitle,
    required this.onTap,
  });

  final Member member;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: _ChatAvatar(label: member.name, onTap: onTap),
      title: Text(
        member.name,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: AppColors.secondaryText,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.labelMedium?.copyWith(
          color: AppColors.hintTextfiled,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppColors.hintTextfiled),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
    );
  }
}

class _ComposerBar extends StatelessWidget {
  const _ComposerBar({
    required this.controller,
    required this.onSend,
    this.bottomSpacing = 24,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final double bottomSpacing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = context.l10n;

    return SafeArea(
      top: false,
      minimum: EdgeInsets.fromLTRB(4, 12, 4, bottomSpacing),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.secondaryBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 16,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
          child: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) {
              final canSend = value.text.trim().isNotEmpty;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _ComposerActionButton(
                    icon: FeatherIcons.paperclip,
                    tooltip: loc.collaborationChatAddAttachment,
                    onTap: () => _showAttachmentOptions(context),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      minLines: 1,
                      maxLines: 6,
                      decoration: InputDecoration(
                        // contentPadding: const EdgeInsets.symmetric(
                        //   horizontal: 4,
                        //   vertical: 0,
                        // ),
                        isDense: false,
                        hintText: loc.collaborationChatComposerHint,
                        hintStyle: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.hintTextfiled,
                          fontWeight: FontWeight.w500,
                        ),
                        filled: true,
                        fillColor: AppColors.textfieldBackground,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      textInputAction: TextInputAction.newline,
                      onSubmitted: (_) {
                        if (canSend) onSend();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  _ComposerActionButton(
                    icon: FeatherIcons.send,
                    tooltip: loc.collaborationChatSendMessage,
                    onTap: canSend ? onSend : null,
                    enabled: canSend,
                    variant: _ComposerButtonVariant.primary,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _showAttachmentOptions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        final loc = sheetContext.l10n;
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
                    onTap: () => Navigator.of(sheetContext).pop(),
                  ),
                  _AttachmentOption(
                    icon: FeatherIcons.fileText,
                    label: loc.collaborationChatAttachDocument,
                    onTap: () => Navigator.of(sheetContext).pop(),
                  ),
                  _AttachmentOption(
                    icon: FeatherIcons.file,
                    label: loc.collaborationChatAttachPdf,
                    onTap: () => Navigator.of(sheetContext).pop(),
                  ),
                  _AttachmentOption(
                    icon: FeatherIcons.camera,
                    label: loc.collaborationChatAttachCamera,
                    onTap: () => Navigator.of(sheetContext).pop(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

enum _ComposerButtonVariant { primary, secondary }

class _ComposerActionButton extends StatelessWidget {
  const _ComposerActionButton({
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

String _relativeTimeLabel(BuildContext context, DateTime timestamp) {
  final difference = DateTime.now().difference(timestamp);
  if (difference.inDays >= 7) {
    final locale = Localizations.localeOf(context).toString();
    return DateFormat.yMMMd(locale).format(timestamp);
  }
  return formatRelativeTime(context, timestamp);
}
