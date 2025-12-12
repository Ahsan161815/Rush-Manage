import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

import 'package:myapp/app/app_theme.dart';
import 'package:myapp/app/widgets/custom_nav_bar.dart';
import 'package:myapp/app/widgets/gradient_button.dart';
import 'package:myapp/common/localization/l10n_extensions.dart';
import 'package:myapp/l10n/app_localizations.dart';

class SharedFilesScreen extends StatefulWidget {
  const SharedFilesScreen({super.key});

  @override
  State<SharedFilesScreen> createState() => _SharedFilesScreenState();
}

class _SharedFilesScreenState extends State<SharedFilesScreen> {
  _FileFilter _activeFilter = _FileFilter.all;

  static final List<_SharedFile> _files = [
    const _SharedFile(
      name: 'Dupont-contract.pdf',
      category: _FileCategory.pdf,
      size: '1.2 MB',
      uploader: 'Alex Carter',
      uploadedAt: 'Today • 10:12',
    ),
    const _SharedFile(
      name: 'Moodboard.png',
      category: _FileCategory.image,
      size: '800 KB',
      uploader: 'Sarah Collins',
      uploadedAt: 'Yesterday • 17:02',
    ),
    const _SharedFile(
      name: 'Budget-tracker.xlsx',
      category: _FileCategory.spreadsheet,
      size: '640 KB',
      uploader: 'Karim Haddad',
      uploadedAt: '14 Nov • 09:18',
    ),
  ];

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

    final files = _activeFilter == _FileFilter.all
        ? _files
        : _files.where(_activeFilter.appliesTo).toList(growable: false);

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
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                      itemBuilder: (context, index) {
                        final file = files[index];
                        return _FileTile(file: file, loc: loc);
                      },
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemCount: files.length,
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
                      onPressed: () {},
                      text: loc.sharedFilesUploadCta,
                      height: 54,
                      width: double.infinity,
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
}

class _FileTile extends StatelessWidget {
  const _FileTile({required this.file, required this.loc});

  final _SharedFile file;
  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final iconData = switch (file.category) {
      _FileCategory.pdf => FeatherIcons.fileText,
      _FileCategory.image => FeatherIcons.image,
      _FileCategory.spreadsheet => FeatherIcons.file,
    };
    final typeLabel = file.category.label(loc);

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
                  loc.sharedFilesFileMeta(typeLabel, file.size),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.hintTextfiled,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  loc.sharedFilesUploadedMeta(file.uploader, file.uploadedAt),
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
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(
              FeatherIcons.moreVertical,
              color: AppColors.secondaryText,
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class _SharedFile {
  const _SharedFile({
    required this.name,
    required this.category,
    required this.size,
    required this.uploader,
    required this.uploadedAt,
  });

  final String name;
  final _FileCategory category;
  final String size;
  final String uploader;
  final String uploadedAt;
}

enum _FileCategory { pdf, image, spreadsheet }

enum _FileFilter { all, pdf, image, spreadsheet }

extension _FileFilterX on _FileFilter {
  bool appliesTo(_SharedFile file) {
    if (this == _FileFilter.all) {
      return true;
    }
    return file.category.name == name;
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

extension _FileCategoryX on _FileCategory {
  String label(AppLocalizations loc) {
    switch (this) {
      case _FileCategory.pdf:
        return loc.sharedFilesFilterPdf;
      case _FileCategory.image:
        return loc.sharedFilesFilterImage;
      case _FileCategory.spreadsheet:
        return loc.sharedFilesFilterSpreadsheet;
    }
  }
}
