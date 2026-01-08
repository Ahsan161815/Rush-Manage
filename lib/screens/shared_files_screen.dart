import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:myapp/app/app_theme.dart';
import 'package:myapp/app/widgets/custom_nav_bar.dart';
import 'package:myapp/app/widgets/gradient_button.dart';
import 'package:myapp/common/localization/l10n_extensions.dart';
import 'package:myapp/common/models/shared_file_record.dart';
import 'package:myapp/common/utils/shared_file_builder.dart';
import 'package:myapp/controllers/project_controller.dart';
import 'package:myapp/controllers/user_controller.dart';
import 'package:myapp/l10n/app_localizations.dart';
import 'package:myapp/models/project.dart';
import 'package:myapp/services/chat_attachment_service.dart';

class SharedFilesScreen extends StatefulWidget {
  const SharedFilesScreen({super.key});

  @override
  State<SharedFilesScreen> createState() => _SharedFilesScreenState();
}

class _SharedFilesScreenState extends State<SharedFilesScreen> {
  _FileFilter _activeFilter = _FileFilter.all;
  final ChatAttachmentService _attachmentService = ChatAttachmentService();
  bool _isUploading = false;
  String? _lastUploadProjectId;

  static const List<_FileFilter> _filters = [
    _FileFilter.all,
    _FileFilter.pdf,
    _FileFilter.image,
    _FileFilter.spreadsheet,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = context.l10n;
    final controller = context.watch<ProjectController>();

    final files = SharedFileAggregator(
      controller: controller,
      loc: loc,
    ).build();
    final filteredFiles = _activeFilter == _FileFilter.all
        ? files
        : files.where(_activeFilter.appliesTo).toList(growable: false);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          loc.sharedFilesTitle,
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
                  SizedBox(
                    height: 50,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        final filter = _filters[index];
                        final bool isActive = filter == _activeFilter;
                        return ChoiceChip(
                          selected: isActive,
                          label: Text(filter.label(loc)),
                          onSelected: (_) =>
                              setState(() => _activeFilter = filter),
                          selectedColor: AppColors.secondary,
                          labelStyle: theme.textTheme.labelLarge?.copyWith(
                            color: isActive
                                ? AppColors.primaryText
                                : AppColors.secondaryText,
                            fontWeight: FontWeight.bold,
                          ),
                          side: BorderSide(
                            color: AppColors.secondary.withValues(alpha: 0.4),
                          ),
                          backgroundColor: AppColors.secondaryBackground,
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemCount: _filters.length,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: filteredFiles.isEmpty
                        ? _EmptyFilesState(loc: loc)
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                            itemBuilder: (context, index) {
                              final file = filteredFiles[index];
                              return _FileTile(
                                file: file,
                                loc: loc,
                                onDownload: () => _handleDownload(file, loc),
                                onMore: () => _showFileActions(file, loc),
                              );
                            },
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 16),
                            itemCount: filteredFiles.length,
                          ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      24,
                      0,
                      24,
                      CustomNavBar.totalHeight + 32,
                    ),
                    child: GradientButton(
                      onPressed: () => _handleUpload(controller),
                      text: loc.sharedFilesUploadCta,
                      height: 54,
                      width: double.infinity,
                      isLoading: _isUploading,
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
            child: CustomNavBar(currentRouteName: 'crm'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleUpload(ProjectController controller) async {
    if (_isUploading) {
      return;
    }
    final destination = await _selectDestination(controller.projects);
    if (!mounted || destination == null) {
      return;
    }
    final source = await _pickAttachmentSource();
    if (!mounted || source == null) {
      return;
    }
    setState(() => _isUploading = true);
    try {
      final uploaded = await _attachmentService.pickAndUpload(source);
      if (!mounted || uploaded == null) {
        return;
      }
      final userController = context.read<UserController>();
      final loc = context.l10n;
      final uploaderId =
          controller.currentUserId ??
          controller.currentUserEmail ??
          'anonymous';
      final uploaderName =
          userController.profile?.displayName ??
          controller.currentUserEmail ??
          uploaderId;
      final draft = SharedFileDraft(
        fileUrl: uploaded.url,
        fileName: uploaded.name,
        contentType: uploaded.contentType,
        sizeBytes: uploaded.sizeBytes,
        origin: SharedFileOrigin.library,
        uploaderId: uploaderId,
        uploaderName: uploaderName,
        projectId: destination.project?.id,
        projectName: destination.project?.name,
      );
      await controller.saveSharedFile(draft);
      setState(() => _lastUploadProjectId = destination.project?.id);
      _showToast(loc.sharedFilesUploadSuccess);
    } catch (error) {
      if (mounted) {
        _showToast(context.l10n.sharedFilesUploadFailure);
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<_FileDestination?> _selectDestination(List<Project> projects) async {
    if (projects.isEmpty) {
      return const _FileDestination.workspace();
    }
    return showModalBottomSheet<_FileDestination>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final loc = sheetContext.l10n;
        final bottomPadding = MediaQuery.of(sheetContext).viewPadding.bottom;
        final destinations = <_FileDestination>[
          const _FileDestination.workspace(),
          ...projects.map(_FileDestination.project),
        ];
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
              padding: EdgeInsets.fromLTRB(24, 20, 24, 16 + bottomPadding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.textfieldBorder.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      loc.sharedFilesDestinationTitle,
                      style: Theme.of(sheetContext).textTheme.titleMedium
                          ?.copyWith(
                            color: AppColors.secondaryText,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 360),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: destinations.length,
                      separatorBuilder: (_, __) => const Divider(
                        color: AppColors.textfieldBorder,
                        height: 1,
                      ),
                      itemBuilder: (_, index) {
                        final destination = destinations[index];
                        final isWorkspace = destination.isWorkspace;
                        final project = destination.project;
                        final title = isWorkspace
                            ? loc.sharedFilesWorkspaceLibrary
                            : (project?.name ??
                                  loc.sharedFilesWorkspaceLibrary);
                        final subtitle = isWorkspace
                            ? loc.sharedFilesDestinationWorkspaceSubtitle
                            : (project != null && project.client.isNotEmpty
                                  ? project.client
                                  : loc.sharedFilesDestinationProjectSubtitle);
                        final isSelected = isWorkspace
                            ? _lastUploadProjectId == null
                            : project?.id == _lastUploadProjectId;
                        return ListTile(
                          leading: Icon(
                            isWorkspace
                                ? FeatherIcons.globe
                                : FeatherIcons.folder,
                            color: AppColors.secondary,
                          ),
                          title: Text(
                            title,
                            style: Theme.of(sheetContext).textTheme.bodyLarge
                                ?.copyWith(
                                  color: AppColors.secondaryText,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          subtitle: Text(
                            subtitle,
                            style: Theme.of(sheetContext).textTheme.bodySmall
                                ?.copyWith(
                                  color: AppColors.hintTextfiled,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          trailing: isSelected
                              ? const Icon(
                                  FeatherIcons.check,
                                  color: AppColors.secondary,
                                )
                              : null,
                          onTap: () =>
                              Navigator.of(sheetContext).pop(destination),
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

  Future<ChatAttachmentSource?> _pickAttachmentSource() async {
    return showModalBottomSheet<ChatAttachmentSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final loc = sheetContext.l10n;
        final bottomPadding = MediaQuery.of(sheetContext).viewPadding.bottom;
        final theme = Theme.of(sheetContext);
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
              padding: EdgeInsets.fromLTRB(24, 20, 24, 16 + bottomPadding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      loc.sharedFilesPickerTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppColors.secondaryText,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _AttachmentSheetOption(
                    icon: FeatherIcons.image,
                    label: loc.collaborationChatAttachPhoto,
                    onTap: () => Navigator.of(
                      sheetContext,
                    ).pop(ChatAttachmentSource.photoLibrary),
                  ),
                  _AttachmentSheetOption(
                    icon: FeatherIcons.fileText,
                    label: loc.collaborationChatAttachDocument,
                    onTap: () => Navigator.of(
                      sheetContext,
                    ).pop(ChatAttachmentSource.document),
                  ),
                  _AttachmentSheetOption(
                    icon: FeatherIcons.file,
                    label: loc.collaborationChatAttachPdf,
                    onTap: () => Navigator.of(
                      sheetContext,
                    ).pop(ChatAttachmentSource.pdf),
                  ),
                  _AttachmentSheetOption(
                    icon: FeatherIcons.camera,
                    label: loc.collaborationChatAttachCamera,
                    onTap: () => Navigator.of(
                      sheetContext,
                    ).pop(ChatAttachmentSource.camera),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleDownload(
    SharedFileSummary file,
    AppLocalizations loc,
  ) async {
    final uri = Uri.tryParse(file.url);
    if (uri == null) {
      _showToast(loc.sharedFilesDownloadError);
      return;
    }
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        _showToast(loc.sharedFilesDownloadError);
      }
    } catch (_) {
      _showToast(loc.sharedFilesDownloadError);
    }
  }

  void _showFileActions(SharedFileSummary file, AppLocalizations loc) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
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
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, 16, 24, bottomPadding + 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.textfieldBorder.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _ActionTile(
                    icon: FeatherIcons.copy,
                    label: loc.sharedFilesMenuCopyLink,
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      _copyLink(file.url, loc);
                    },
                  ),
                  _ActionTile(
                    icon: FeatherIcons.externalLink,
                    label: loc.sharedFilesMenuOpen,
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      _handleDownload(file, loc);
                    },
                  ),
                  _ActionTile(
                    icon: FeatherIcons.trash2,
                    label: loc.sharedFilesMenuRemove,
                    isDestructive: true,
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      _confirmRemove(file, loc);
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

  Future<void> _copyLink(String url, AppLocalizations loc) async {
    await Clipboard.setData(ClipboardData(text: url));
    _showToast(loc.sharedFilesCopySuccess);
  }

  Future<void> _confirmRemove(
    SharedFileSummary file,
    AppLocalizations loc,
  ) async {
    if (!mounted) {
      return;
    }
    final localizations = MaterialLocalizations.of(context);
    final shouldRemove = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(loc.sharedFilesMenuRemove),
        content: Text(loc.sharedFilesRemoveConfirm(file.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(localizations.cancelButtonLabel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(loc.sharedFilesMenuRemove),
          ),
        ],
      ),
    );
    if (!mounted || shouldRemove != true) {
      return;
    }
    final controller = context.read<ProjectController>();
    try {
      await controller.deleteSharedFile(file.id);
      _showToast(loc.sharedFilesRemoveSuccess);
    } catch (_) {
      _showToast(loc.sharedFilesRemoveFailure);
    }
  }

  void _showToast(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _FileTile extends StatelessWidget {
  const _FileTile({
    required this.file,
    required this.loc,
    required this.onDownload,
    required this.onMore,
  });

  final SharedFileSummary file;
  final AppLocalizations loc;
  final VoidCallback onDownload;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final iconData = switch (file.category) {
      SharedFileCategory.pdf => FeatherIcons.fileText,
      SharedFileCategory.image => FeatherIcons.image,
      SharedFileCategory.spreadsheet => FeatherIcons.file,
    };
    final typeLabel = file.category.label(loc);
    final originLabel = switch (file.origin) {
      SharedFileOrigin.task => loc.projectDetailTasksTitle,
      SharedFileOrigin.chat => loc.projectDetailDiscussionTitle,
      SharedFileOrigin.library => loc.sharedFilesOriginLibrary,
    };

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(iconData, size: 24, color: AppColors.secondary),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.secondaryText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  loc.sharedFilesFileMeta(typeLabel, file.sizeLabel),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.hintTextfiled,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  loc.sharedFilesUploadedMeta(
                    file.uploader,
                    file.timestampLabel,
                  ),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.hintTextfiled,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${file.projectName} • $originLabel',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.hintTextfiled,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(
              FeatherIcons.download,
              color: AppColors.secondaryText,
            ),
            onPressed: onDownload,
          ),
          IconButton(
            icon: const Icon(
              FeatherIcons.moreVertical,
              color: AppColors.secondaryText,
            ),
            onPressed: onMore,
          ),
        ],
      ),
    );
  }
}

class _AttachmentSheetOption extends StatelessWidget {
  const _AttachmentSheetOption({
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
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.textfieldBackground,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: AppColors.secondary),
      ),
      title: Text(
        label,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: AppColors.secondaryText,
          fontWeight: FontWeight.bold,
        ),
      ),
      onTap: onTap,
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isDestructive ? AppColors.error : AppColors.secondaryText;
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
      onTap: onTap,
    );
  }
}

class _FileDestination {
  const _FileDestination.workspace() : project = null;
  const _FileDestination.project(this.project);

  final Project? project;

  bool get isWorkspace => project == null;
}

class _EmptyFilesState extends StatelessWidget {
  const _EmptyFilesState({required this.loc});

  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.secondaryBackground,
              border: Border.all(color: AppColors.textfieldBorder),
            ),
            child: const Icon(
              FeatherIcons.folder,
              color: AppColors.secondary,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            loc.projectDetailFilesTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.secondaryText,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            loc.projectDetailFilesAdd,
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

enum _FileFilter { all, pdf, image, spreadsheet }

extension _FileFilterX on _FileFilter {
  bool appliesTo(SharedFileSummary file) {
    if (this == _FileFilter.all) {
      return true;
    }
    switch (this) {
      case _FileFilter.pdf:
        return file.category == SharedFileCategory.pdf;
      case _FileFilter.image:
        return file.category == SharedFileCategory.image;
      case _FileFilter.spreadsheet:
        return file.category == SharedFileCategory.spreadsheet;
      case _FileFilter.all:
        return true;
    }
  }

  String label(AppLocalizations loc) {
    switch (this) {
      case _FileFilter.all:
        return loc.sharedFilesFilterAll;
      case _FileFilter.pdf:
        return loc.sharedFilesFilterPdf;
      case _FileFilter.image:
        return loc.sharedFilesFilterImage;
      case _FileFilter.spreadsheet:
        return loc.sharedFilesFilterSpreadsheet;
    }
  }
}
