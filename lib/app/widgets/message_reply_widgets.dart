import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:myapp/app/app_theme.dart';
import 'package:myapp/common/localization/l10n_extensions.dart';
import 'package:myapp/common/models/message.dart';

class MessageReplyBanner extends StatelessWidget {
  const MessageReplyBanner({
    super.key,
    required this.preview,
    required this.onCancel,
  });

  final MessageReplyPreview preview;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final titleStyle = theme.textTheme.labelLarge?.copyWith(
      color: AppColors.secondaryText,
      fontWeight: FontWeight.w800,
    );

    final metaStyle = theme.textTheme.labelMedium?.copyWith(
      color: AppColors.hintTextfiled,
      fontWeight: FontWeight.w700,
    );

    final bodyStyle = theme.textTheme.bodyMedium?.copyWith(
      color: AppColors.secondaryText,
      fontWeight: FontWeight.w600,
    );

    final borderColor = AppColors.textfieldBorder.withValues(alpha: 0.7);

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
      decoration: BoxDecoration(
        color: AppColors.textfieldBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 34),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 4,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 12),
                _ReplyAvatar(label: preview.authorName),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        context.l10n.chatReplyingTo(preview.authorName),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: titleStyle,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        DateFormat.Hm().format(preview.sentAt),
                        style: metaStyle,
                      ),
                      const SizedBox(height: 6),
                      if (preview.body.trim().isNotEmpty)
                        Text(
                          preview.body.trim(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: bodyStyle,
                        ),
                      if (preview.attachments.isNotEmpty) ...[
                        if (preview.body.trim().isNotEmpty)
                          const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.attach_file,
                              size: 16,
                              color: AppColors.hintTextfiled,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                context.l10n.chatAttachmentCount(
                                  preview.attachments.length,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: metaStyle,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          PositionedDirectional(
            top: -6,
            end: -6,
            child: IconButton(
              tooltip: context.l10n.chatCancelReplyTooltip,
              icon: const Icon(Icons.close, size: 18),
              color: AppColors.hintTextfiled,
              onPressed: onCancel,
            ),
          ),
        ],
      ),
    );
  }
}

class QuotedReplyBlock extends StatelessWidget {
  const QuotedReplyBlock({
    super.key,
    required this.preview,
    required this.isMine,
    this.onTap,
  });

  final MessageReplyPreview preview;
  final bool isMine;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final titleStyle = theme.textTheme.labelMedium?.copyWith(
      color: AppColors.secondaryText,
      fontWeight: FontWeight.w800,
    );

    final metaStyle = theme.textTheme.labelSmall?.copyWith(
      color: AppColors.hintTextfiled,
      fontWeight: FontWeight.w700,
    );

    final bodyStyle = theme.textTheme.labelLarge?.copyWith(
      color: AppColors.secondaryText,
      fontWeight: FontWeight.w600,
    );

    final background = isMine
        ? AppColors.primary.withValues(alpha: 0.06)
        : AppColors.secondaryBackground;

    final border = isMine
        ? AppColors.primary.withValues(alpha: 0.18)
        : AppColors.textfieldBorder.withValues(alpha: 0.6);

    final content = Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 3,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        preview.authorName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: titleStyle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      DateFormat.Hm().format(preview.sentAt),
                      style: metaStyle,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (preview.body.trim().isNotEmpty)
                  Text(
                    preview.body.trim(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: bodyStyle,
                  )
                else
                  Text(
                    context.l10n.chatQuotedFallbackMessage,
                    style: bodyStyle,
                  ),
                if (preview.attachments.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.attach_file,
                        size: 14,
                        color: AppColors.hintTextfiled,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          context.l10n.chatAttachmentCount(
                            preview.attachments.length,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: metaStyle,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );

    if (onTap == null) {
      return content;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: content,
      ),
    );
  }
}

class _ReplyAvatar extends StatelessWidget {
  const _ReplyAvatar({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final initial = label.trim().isEmpty ? '?' : label.trim()[0].toUpperCase();

    return Container(
      width: 36,
      height: 36,
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
        initial,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: AppColors.primaryText,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
