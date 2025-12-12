import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:myapp/app/app_theme.dart';
import 'package:myapp/app/widgets/custom_nav_bar.dart';
import 'package:myapp/app/widgets/emoji_reaction_picker.dart';
import 'package:myapp/common/localization/l10n_extensions.dart';
import 'package:myapp/common/models/collaborator_contact.dart';
import 'package:myapp/controllers/project_controller.dart';
import 'package:myapp/models/project.dart';

class CollaborationChatScreen extends StatefulWidget {
  const CollaborationChatScreen({super.key});

  @override
  State<CollaborationChatScreen> createState() =>
      _CollaborationChatScreenState();
}

class _CollaborationChatScreenState extends State<CollaborationChatScreen> {
  static const String _threadContactId = 'c1';
  static const List<_ChatMessage> _seedMessages = [
    _ChatMessage(
      authorId: _threadContactId,
      sender: 'Sarah Collins',
      message: 'Morning! I have the shot list ready for the Dupont reception.',
      timeLabel: '09:12',
      isMine: false,
      attachments: ['shot_list.pdf'],
      reactions: {'👍': 2},
    ),
    _ChatMessage(
      authorId: 'me',
      sender: 'You',
      message:
          'Perfect, can you also capture a few wide shots of the venue setup? @Sarah',
      timeLabel: '09:14',
      isMine: true,
      mentions: ['@Sarah'],
    ),
    _ChatMessage(
      authorId: _threadContactId,
      sender: 'Sarah Collins',
      message:
          'Absolutely. I will share selects in the shared files folder tonight.',
      timeLabel: '09:15',
      isMine: false,
      attachments: ['reception_preview.jpeg'],
      reactions: {'❤️': 1, '✅': 1},
    ),
    _ChatMessage(
      authorId: 'me',
      sender: 'You',
      message: 'Thanks! I will upload the final timeline there as well.',
      timeLabel: '09:18',
      isMine: true,
      attachments: ['timeline_v3.pdf'],
    ),
  ];

  final List<_ChatMessage> _messages = List<_ChatMessage>.of(_seedMessages);
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(
        _ChatMessage(
          authorId: 'me',
          sender: 'You',
          message: text,
          timeLabel: 'Just now',
          isMine: true,
          mentions: _extractMentions(text),
        ),
      );
    });

    _messageController.clear();
    _scrollToBottom();
  }

  void _handleReaction(int index, String emoji) {
    setState(() {
      final current = _messages[index];
      final updatedReactions = Map<String, int>.from(current.reactions)
        ..update(emoji, (count) => count + 1, ifAbsent: () => 1);

      _messages[index] = current.copyWith(reactions: updatedReactions);
    });
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = context.l10n;
    final controller = context.watch<ProjectController>();
    final threadContact = _resolveThreadContact(controller);
    final threadName =
        threadContact?.name ?? loc.collaborationChatTitleFallback;
    final threadSubtitle =
        threadContact?.profession ?? loc.collaborationChatSubtitleFallback;

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
            onTap: () => _openDirectContact(threadContact, threadName),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    threadName,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: AppColors.secondaryText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    threadSubtitle,
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
                  Expanded(
                    child: ListView.separated(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        final authorName = message.isMine
                            ? loc.homeAuthorYou
                            : threadContact?.name ?? message.sender;
                        return _MessageBubble(
                          message: message,
                          authorName: authorName,
                          onAuthorTap: () => _openDirectAuthor(
                            contact: threadContact,
                            authorId: message.authorId,
                            authorName: authorName,
                          ),
                          onReact: (emoji) => _handleReaction(index, emoji),
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemCount: _messages.length,
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.textfieldBorder),
                  _MessageComposer(
                    controller: _messageController,
                    onSend: _handleSend,
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

  CollaboratorContact? _resolveThreadContact(ProjectController controller) {
    final directMatch = controller.contactById(_threadContactId);
    if (directMatch != null) {
      return directMatch;
    }
    return controller.contacts.isNotEmpty ? controller.contacts.first : null;
  }

  void _openDirectContact(CollaboratorContact? contact, String fallbackName) {
    if (!mounted) {
      return;
    }

    final controller = context.read<ProjectController>();
    final detailArgs = controller.buildContactDetailArgs(
      contact: contact,
      member: contact == null
          ? Member(id: _threadContactId, name: fallbackName)
          : null,
    );
    context.pushNamed('contactDetail', extra: detailArgs);
  }

  void _openDirectAuthor({
    CollaboratorContact? contact,
    required String authorId,
    required String authorName,
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
      contact: contact,
      member: Member(id: authorId, name: authorName),
    );
    context.pushNamed('contactDetail', extra: detailArgs);
  }
}

class _MessageComposer extends StatelessWidget {
  const _MessageComposer({
    required this.controller,
    required this.onSend,
    this.bottomPadding = 20,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
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
              final canSend = value.text.trim().isNotEmpty;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _ComposerActionIcon(
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
                        hintText: loc.collaborationChatComposerHint,
                        hintStyle: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.hintTextfiled,
                          fontWeight: FontWeight.w600,
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

void _showAttachmentOptions(BuildContext context) {
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

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.onReact,
    required this.authorName,
    required this.onAuthorTap,
  });

  final _ChatMessage message;
  final ValueChanged<String> onReact;
  final String authorName;
  final VoidCallback onAuthorTap;

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
      color: AppColors.secondary,
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
                          if (baseStyle != null)
                            RichText(
                              text: TextSpan(
                                style: baseStyle,
                                children: _buildBodySpans(
                                  message.message,
                                  message.mentions,
                                  baseStyle,
                                  mentionStyle ?? baseStyle,
                                ),
                              ),
                            )
                          else
                            Text(message.message),
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
      if (match.start > cursor) {
        spans.add(
          TextSpan(text: body.substring(cursor, match.start), style: base),
        );
      }
      final token = match.group(0)!;
      final style = mentionSet.isEmpty || mentionSet.contains(token)
          ? mentionStyle
          : base;
      spans.add(TextSpan(text: token, style: style));
      cursor = match.end;
    }

    if (cursor < body.length) {
      spans.add(TextSpan(text: body.substring(cursor), style: base));
    }

    return spans;
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
    final background = highlight
        ? AppColors.primary.withValues(alpha: 0.18)
        : AppColors.secondaryBackground;
    final borderColor = highlight
        ? AppColors.primary.withValues(alpha: 0.3)
        : AppColors.textfieldBorder.withValues(alpha: 0.55);
    final iconColor = highlight ? AppColors.secondary : AppColors.hintTextfiled;

    return Tooltip(
      message: context.l10n.collaborationChatReactTooltip,
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
              FeatherIcons.moreHorizontal,
              size: 18,
              color: iconColor,
            ),
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
    final lower = filename.toLowerCase();
    IconData icon;
    Color iconColor;

    if (_isImage(lower)) {
      icon = Icons.image_outlined;
      iconColor = AppColors.secondary;
    } else if (lower.endsWith('.pdf')) {
      icon = Icons.picture_as_pdf_outlined;
      iconColor = Colors.redAccent;
    } else if (lower.endsWith('.doc') || lower.endsWith('.docx')) {
      icon = Icons.description_outlined;
      iconColor = AppColors.secondary;
    } else if (lower.endsWith('.xlsx') || lower.endsWith('.csv')) {
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

class _ChatMessage {
  const _ChatMessage({
    required this.authorId,
    required this.sender,
    required this.message,
    required this.timeLabel,
    required this.isMine,
    this.attachments = const [],
    this.mentions = const [],
    this.reactions = const {},
  });

  final String authorId;
  final String sender;
  final String message;
  final String timeLabel;
  final bool isMine;
  final List<String> attachments;
  final List<String> mentions;
  final Map<String, int> reactions;

  _ChatMessage copyWith({
    String? authorId,
    String? sender,
    String? message,
    String? timeLabel,
    bool? isMine,
    List<String>? attachments,
    List<String>? mentions,
    Map<String, int>? reactions,
  }) {
    return _ChatMessage(
      sender: sender ?? this.sender,
      message: message ?? this.message,
      timeLabel: timeLabel ?? this.timeLabel,
      isMine: isMine ?? this.isMine,
      attachments: attachments ?? this.attachments,
      mentions: mentions ?? this.mentions,
      reactions: reactions ?? this.reactions,
      authorId: authorId ?? this.authorId,
    );
  }
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
