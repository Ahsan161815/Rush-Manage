import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

import 'package:myapp/app/app_theme.dart';
import 'package:myapp/app/widgets/custom_nav_bar.dart';
import 'package:myapp/app/widgets/gradient_button.dart';

class SharedFilesScreen extends StatefulWidget {
  const SharedFilesScreen({super.key});

  @override
  State<SharedFilesScreen> createState() => _SharedFilesScreenState();
}

class _SharedFilesScreenState extends State<SharedFilesScreen> {
  String _activeFilter = 'All';

  static final List<_SharedFile> _files = [
    const _SharedFile(
      name: 'Dupont-contract.pdf',
      type: 'PDF',
      size: '1.2 MB',
      uploader: 'Alex Carter',
      uploadedAt: 'Today • 10:12',
    ),
    const _SharedFile(
      name: 'Moodboard.png',
      type: 'Image',
      size: '800 KB',
      uploader: 'Sarah Collins',
      uploadedAt: 'Yesterday • 17:02',
    ),
    const _SharedFile(
      name: 'Budget-tracker.xlsx',
      type: 'Spreadsheet',
      size: '640 KB',
      uploader: 'Karim Haddad',
      uploadedAt: '14 Nov • 09:18',
    ),
  ];

  static const List<String> _filters = ['All', 'PDF', 'Image', 'Spreadsheet'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final files = _activeFilter == 'All'
        ? _files
        : _files
              .where((file) => file.type == _activeFilter)
              .toList(growable: false);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Shared files',
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
                          label: Text(filter),
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
                        return _FileTile(file: file);
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
                      text: '+ Upload file',
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
            child: CustomNavBar(currentRouteName: 'chats'),
          ),
        ],
      ),
    );
  }
}

class _FileTile extends StatelessWidget {
  const _FileTile({required this.file});

  final _SharedFile file;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final iconData = switch (file.type) {
      'PDF' => FeatherIcons.fileText,
      'Image' => FeatherIcons.image,
      'Spreadsheet' => FeatherIcons.file,
      _ => FeatherIcons.file,
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
                  '${file.type} • ${file.size}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.hintTextfiled,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Uploaded by ${file.uploader} · ${file.uploadedAt}',
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
    required this.type,
    required this.size,
    required this.uploader,
    required this.uploadedAt,
  });

  final String name;
  final String type;
  final String size;
  final String uploader;
  final String uploadedAt;
}
