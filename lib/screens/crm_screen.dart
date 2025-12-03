import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:go_router/go_router.dart';

import 'package:myapp/app/app_theme.dart';
import 'package:myapp/app/widgets/custom_nav_bar.dart';
import 'package:myapp/widgets/contact_request_sheet.dart';
import 'package:myapp/widgets/custom_text_field.dart';
import 'package:myapp/widgets/gradiant_button_widget.dart';

class CRMScreen extends StatefulWidget {
  const CRMScreen({super.key});

  @override
  State<CRMScreen> createState() => _CRMScreenState();
}

class _CRMScreenState extends State<CRMScreen> {
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

  List<_ChatPreview> get _visibleChats {
    final query = _searchController.text.trim().toLowerCase();
    return _chats
        .where((chat) {
          final matchesFilter = switch (_selectedFilter) {
            _ChatFilter.all => true,
            _ChatFilter.projects => chat.isProject,
            _ChatFilter.contacts => !chat.isProject,
            _ChatFilter.clients => chat.crmCategory == _CRMCategory.client,
            _ChatFilter.collaborators =>
              chat.crmCategory == _CRMCategory.collaborator,
          };
          if (!matchesFilter) {
            return false;
          }
          if (query.isEmpty) {
            return true;
          }
          return chat.searchableText.contains(query);
        })
        .toList(growable: false);
  }

  static const List<_ChatPreview> _chats = [
    _ChatPreview(
      title: 'Apollo Station Build',
      lastMessage: 'Sarai • Uploaded the updated permits. ',
      timestampLabel: '2m ago',
      unreadCount: 3,
      projectId: 'p1',
      badgeLabel: 'Project',
      contextDetail: 'Dupont Wedding · Coordination',
      relationshipLabel: 'Team lead: Sarai Collins',
    ),
    _ChatPreview(
      title: 'Fleet Maintenance',
      lastMessage: 'You • Let me know when the vans are back.',
      timestampLabel: '45m ago',
      projectId: 'p2',
      badgeLabel: 'Contact',
      contextDetail: 'Karim Haddad · Logistic partner',
      relationshipLabel: 'Last project: Corporate Dinner',
      crmCategory: _CRMCategory.collaborator,
      crmStats: [
        _CRMStat(label: 'Last touchpoint', value: '3d ago'),
        _CRMStat(label: 'Quotes won', value: '4', trend: '+1 vs Aug'),
      ],
      linkedProjects: ['Apollo Station Build', 'Metro Fleet Refresh'],
      financeHighlights: [
        'Open invoice · USD 18.2K · Due Oct 12',
        'Avg. service cost · USD 4.4K/mo',
      ],
      documentLinks: ['Maintenance SLA.pdf', 'Insurance Certificate FY24.pdf'],
    ),
    _ChatPreview(
      title: 'Finance Squad',
      lastMessage: 'Robin • Budget review call moved to 3pm.',
      timestampLabel: '1h ago',
      unreadCount: 1,
      projectId: 'p3',
      badgeLabel: 'Project',
      contextDetail: 'Cobalt Logistics · Budgeting',
    ),
    _ChatPreview(
      title: 'Cobalt Logistics',
      lastMessage: 'Hassan • Thanks for sharing the manifest!',
      timestampLabel: 'Yesterday',
      projectId: 'p1',
      badgeLabel: 'Contact',
      contextDetail: 'Vendor · Freight forwarding',
      relationshipLabel: 'Worked on: Apollo Station Build',
      crmCategory: _CRMCategory.collaborator,
      crmStats: [
        _CRMStat(label: 'Active shipments', value: '6', trend: '2 delayed'),
        _CRMStat(label: 'Spend YTD', value: 'USD 312K'),
      ],
      linkedProjects: ['Apollo Station Build', 'Evening Gala Logistics'],
      financeHighlights: [
        'Credit terms · Net 45',
        'Next payout · USD 48K on Oct 5',
      ],
      documentLinks: ['2024 Freight Agreement.pdf'],
    ),
    _ChatPreview(
      title: 'Marina Flores',
      lastMessage: 'Marina • Draft proposal ready for review.',
      timestampLabel: 'Mon',
      projectId: 'p4',
      badgeLabel: 'Contact',
      contextDetail: 'Client · Hospitality group',
      relationshipLabel: 'Priority tier: Strategic',
      crmCategory: _CRMCategory.client,
      crmStats: [
        _CRMStat(label: 'Open deals', value: '3'),
        _CRMStat(label: 'Last meeting', value: '7d ago'),
      ],
      linkedProjects: ['Lumen Rooftop Launch', 'Harbor Lights Dinner'],
      financeHighlights: ['Pipeline · USD 420K', 'Closed this year · USD 190K'],
      documentLinks: ['Hospitality Playbook.pdf', 'Preferred Vendors.xlsx'],
    ),
  ];

  static Future<void> _openAddContactSheet(BuildContext context) async {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final messageController = TextEditingController();

    try {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (sheetContext) {
          final bottomInset = MediaQuery.of(sheetContext).viewInsets.bottom;
          return SafeArea(
            top: false,
            child: ContactRequestSheet(
              nameController: nameController,
              emailController: emailController,
              messageController: messageController,
              bottomInset: bottomInset,
            ),
          );
        },
      );
    } finally {
      nameController.dispose();
      emailController.dispose();
      messageController.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visibleChats = _visibleChats;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 112,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Message Center',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: AppColors.secondaryText,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Keep up with project threads and partners',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: AppColors.hintTextfiled,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              _HeaderIconButton(
                icon: FeatherIcons.plus,
                tooltip: 'Add to contacts',
                onTap: () => _openAddContactSheet(context),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: SafeArea(
              bottom: false,
              child: ListView.separated(
                padding: EdgeInsets.only(
                  top: 16,
                  bottom: CustomNavBar.totalHeight + 32,
                ),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _ChatsListHeader(
                      searchController: _searchController,
                      selectedFilter: _selectedFilter,
                      onFilterChanged: _handleFilterChanged,
                    );
                  }
                  final chat = visibleChats[index - 1];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _ChatTile(
                      chat: chat,
                      onTap: () => context.pushNamed(
                        'projectChat',
                        pathParameters: {'id': chat.projectId},
                      ),
                    ),
                  );
                },
                separatorBuilder: (_, index) => index == 0
                    ? const SizedBox(height: 20)
                    : const SizedBox(height: 16),
                itemCount: visibleChats.length + 1,
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

class _ChatTile extends StatelessWidget {
  const _ChatTile({required this.chat, required this.onTap});

  final _ChatPreview chat;
  final VoidCallback onTap;

  Future<void> _showContactInsights(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return SafeArea(top: false, child: _ContactInsightsSheet(chat: chat));
      },
    );
  }

  void _logTouchpoint(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Touchpoint logged for ${chat.title}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final _CRMStat? primaryStat = chat.crmStats.isNotEmpty
        ? chat.crmStats.first
        : null;

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
                        chat.timestampLabel,
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
                      _ContextChip(label: chat.badgeLabel),
                      Text(
                        chat.contextDetail,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: AppColors.hintTextfiled,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  if (chat.relationshipLabel != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      chat.relationshipLabel!,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.hintTextfiled.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
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
                  if (chat.isContact && primaryStat != null) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          FeatherIcons.barChart2,
                          size: 16,
                          color: AppColors.secondary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "${primaryStat.label}: ${primaryStat.value}${primaryStat.trend != null ? ' · ${primaryStat.trend}' : ''}",
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: AppColors.secondaryText,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (chat.isContact) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _CRMActionButton(
                          icon: FeatherIcons.info,
                          label: 'Insights',
                          onTap: () => _showContactInsights(context),
                        ),
                        const SizedBox(width: 12),
                        _CRMActionButton(
                          icon: FeatherIcons.edit3,
                          label: 'Log touchpoint',
                          onTap: () => _logTouchpoint(context),
                        ),
                      ],
                    ),
                  ],
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

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Ink(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.secondary, AppColors.primary],
                begin: AlignmentDirectional(1.0, 0.34),
                end: AlignmentDirectional(-1.0, -0.34),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondaryBackground,
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 16,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(icon, color: AppColors.secondary, size: 20),
              ),
            ),
          ),
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
  });

  final TextEditingController searchController;
  final _ChatFilter selectedFilter;
  final ValueChanged<_ChatFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _ChatsSearchField(controller: searchController),
        ),
        const SizedBox(height: 12),
        _FilterRow(selected: selectedFilter, onChanged: onFilterChanged),
      ],
    );
  }
}

class _ChatsSearchField extends StatelessWidget {
  const _ChatsSearchField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CustomTextField(
        controller: controller,
        hintText: 'Search projects or contacts',
        iconPath: 'assets/images/search-svgrepo-com.svg',
        widthFactor: 0.91,
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({required this.selected, required this.onChanged});

  final _ChatFilter selected;
  final ValueChanged<_ChatFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    final filters = [
      (label: 'All', filter: _ChatFilter.all),
      (label: 'Projects', filter: _ChatFilter.projects),
      (label: 'Contacts', filter: _ChatFilter.contacts),
      (label: 'Clients', filter: _ChatFilter.clients),
      (label: 'Collaborators', filter: _ChatFilter.collaborators),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
        child: Row(
          children: [
            for (var i = 0; i < filters.length; i++) ...[
              _GradientChoiceChip(
                label: filters[i].label,
                selected: filters[i].filter == selected,
                onTap: () => onChanged(filters[i].filter),
              ),
              if (i != filters.length - 1) const SizedBox(width: 12),
            ],
          ],
        ),
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

enum _ChatFilter { all, projects, contacts, clients, collaborators }

enum _CRMCategory { client, collaborator }

class _ChatPreview {
  const _ChatPreview({
    required this.title,
    required this.lastMessage,
    required this.timestampLabel,
    required this.projectId,
    required this.badgeLabel,
    required this.contextDetail,
    this.relationshipLabel,
    this.unreadCount = 0,
    this.crmCategory,
    this.crmStats = const [],
    this.linkedProjects = const [],
    this.financeHighlights = const [],
    this.documentLinks = const [],
  });

  final String title;
  final String lastMessage;
  final String timestampLabel;
  final String projectId;
  final String badgeLabel;
  final String contextDetail;
  final String? relationshipLabel;
  final int unreadCount;
  final _CRMCategory? crmCategory;
  final List<_CRMStat> crmStats;
  final List<String> linkedProjects;
  final List<String> financeHighlights;
  final List<String> documentLinks;

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

  bool get isProject => badgeLabel.toLowerCase() == 'project';
  bool get isContact => !isProject;

  String get searchableText {
    final buffer = StringBuffer()
      ..write(title)
      ..write(' ')
      ..write(lastMessage)
      ..write(' ')
      ..write(contextDetail)
      ..write(' ')
      ..write(relationshipLabel ?? '');
    return buffer.toString().toLowerCase();
  }
}

class _CRMStat {
  const _CRMStat({required this.label, required this.value, this.trend});

  final String label;
  final String value;
  final String? trend;
}

class _CRMActionButton extends StatelessWidget {
  const _CRMActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          side: const BorderSide(color: AppColors.borderColor),
          foregroundColor: AppColors.secondaryText,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
        onPressed: onTap,
        icon: Icon(icon, size: 16),
        label: Text(label),
      ),
    );
  }
}

class _ContactInsightsSheet extends StatelessWidget {
  const _ContactInsightsSheet({required this.chat});

  final _ChatPreview chat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 30,
            offset: Offset(0, 20),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 50,
                height: 4,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: AppColors.borderColor,
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _AvatarBadge(label: chat.avatarLabel),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chat.title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: AppColors.secondaryText,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 10,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _ContextChip(label: chat.badgeLabel),
                          if (chat.crmCategory != null)
                            _ContextChip(
                              label: switch (chat.crmCategory!) {
                                _CRMCategory.client => 'Client',
                                _CRMCategory.collaborator => 'Collaborator',
                              },
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(FeatherIcons.x),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              chat.contextDetail,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.secondaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (chat.relationshipLabel != null) ...[
              const SizedBox(height: 4),
              Text(
                chat.relationshipLabel!,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppColors.hintTextfiled,
                ),
              ),
            ],
            if (chat.crmStats.isNotEmpty) ...[
              const SizedBox(height: 18),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final stat in chat.crmStats) _CRMStatCard(stat: stat),
                ],
              ),
            ],
            if (chat.linkedProjects.isNotEmpty) ...[
              const SizedBox(height: 20),
              _CRMSection(
                title: 'Linked projects',
                items: chat.linkedProjects,
                icon: FeatherIcons.briefcase,
              ),
            ],
            if (chat.financeHighlights.isNotEmpty) ...[
              const SizedBox(height: 16),
              _CRMSection(
                title: 'Finance history',
                items: chat.financeHighlights,
                icon: FeatherIcons.creditCard,
              ),
            ],
            if (chat.documentLinks.isNotEmpty) ...[
              const SizedBox(height: 16),
              _CRMSection(
                title: 'Documents',
                items: chat.documentLinks,
                icon: FeatherIcons.folder,
              ),
            ],
            const SizedBox(height: 28),
            GradiantButtonWidget(
              buttonText: 'Jump to chat',
              widthFactor: 1,
              onPressed: () {
                final router = GoRouter.of(context);
                Navigator.of(context).pop();
                router.pushNamed(
                  'projectChat',
                  pathParameters: {'id': chat.projectId},
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CRMStatCard extends StatelessWidget {
  const _CRMStatCard({required this.stat});

  final _CRMStat stat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderColor.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            stat.label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.hintTextfiled,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            stat.value,
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.secondaryText,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (stat.trend != null) ...[
            const SizedBox(height: 4),
            Text(
              stat.trend!,
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CRMSection extends StatelessWidget {
  const _CRMSection({
    required this.title,
    required this.items,
    required this.icon,
  });

  final String title;
  final List<String> items;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                color: AppColors.secondaryText,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        for (final item in items)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              '• $item',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.secondaryText,
              ),
            ),
          ),
      ],
    );
  }
}
