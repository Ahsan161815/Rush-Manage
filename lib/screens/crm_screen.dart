import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:myapp/app/app_theme.dart';
import 'package:myapp/app/widgets/custom_nav_bar.dart';
import 'package:myapp/common/localization/l10n_extensions.dart';
import 'package:myapp/common/models/contact_detail_args.dart';
import 'package:myapp/common/models/contact_form_models.dart';
import 'package:myapp/common/utils/contact_form_launcher.dart';
import 'package:myapp/controllers/crm_controller.dart';
import 'package:myapp/l10n/app_localizations.dart';
import 'package:myapp/models/crm_contact.dart';
import 'package:myapp/widgets/custom_text_field.dart';
import 'package:myapp/widgets/gradiant_button_widget.dart';
import 'package:myapp/widgets/section_hero_header.dart';

class CRMScreen extends StatefulWidget {
  const CRMScreen({super.key});

  @override
  State<CRMScreen> createState() => _CRMScreenState();
}

class _CRMScreenState extends State<CRMScreen> {
  final TextEditingController _searchController = TextEditingController();
  _ContactFilter _selectedFilter = _ContactFilter.all;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      context.read<CrmController>().initialize();
    });
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    super.dispose();
  }

  void _onSearchChanged() => setState(() {});

  void _handleFilterChanged(_ContactFilter filter) {
    if (_selectedFilter == filter) {
      return;
    }
    setState(() => _selectedFilter = filter);
  }

  Future<void> _showContactInsights(CrmContact contact) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: _ContactInsightsSheet(contact: contact),
        );
      },
    );
  }

  Future<void> _openContactForm({CrmContact? contact}) async {
    final controller = context.read<CrmController>();
    final formData = contact == null
        ? const ContactFormData()
        : controller.formDataFor(contact);
    final submission = await ContactFormLauncher.show(
      context,
      mode: contact == null ? ContactFormMode.create : ContactFormMode.edit,
      data: formData,
      contactId: contact?.id,
    );
    if (submission == null) {
      return;
    }
    try {
      if (submission.mode == ContactFormMode.create) {
        await controller.createContact(submission.data);
      } else if (submission.contactId != null) {
        await controller.updateContact(submission.contactId!, submission.data);
      }
      if (!mounted) return;
      const snackBar = SnackBar(content: Text('Contact saved'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } catch (error) {
      if (!mounted) return;
      const snackBar = SnackBar(content: Text('Unable to save contact'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  List<CrmContact> _filterContacts(List<CrmContact> source) {
    final query = _searchController.text.trim().toLowerCase();
    return source
        .where((contact) {
          final matchesFilter = switch (_selectedFilter) {
            _ContactFilter.all => true,
            _ContactFilter.clients => contact.isClient,
            _ContactFilter.collaborators => contact.isCollaborator,
            _ContactFilter.suppliers => contact.isSupplier,
          };
          if (!matchesFilter) {
            return false;
          }
          if (query.isEmpty) {
            return true;
          }
          return contact.searchableText.contains(query);
        })
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CrmController>();
    final loc = context.l10n;
    final theme = Theme.of(context);
    final visibleContacts = _filterContacts(controller.contacts);
    final isInitialLoading =
        controller.isLoading && controller.contacts.isEmpty;

    final listContent = RefreshIndicator(
      onRefresh: controller.refresh,
      child: ListView(
        padding: EdgeInsets.only(
          top: 16,
          bottom: CustomNavBar.totalHeight + 32,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SectionHeroHeader(
              title: loc.contactsTitle,
              subtitle: loc.contactsSubtitle,
              subtitleStyle: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.primaryText.withValues(alpha: 0.7),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              actionTooltip: loc.contactsAdd,
              onActionTap: () => _openContactForm(),
            ),
          ),
          const SizedBox(height: 16),
          _ContactsListHeader(
            searchController: _searchController,
            selectedFilter: _selectedFilter,
            onFilterChanged: _handleFilterChanged,
          ),
          if (controller.errorMessage != null && controller.contacts.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: _ErrorPlaceholder(
                message: controller.errorMessage!,
                onRetry: controller.refresh,
              ),
            )
          else if (!controller.isLoading && visibleContacts.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: _EmptyPlaceholder(message: loc.contactsEmptyMessage),
            )
          else
            ...visibleContacts.map(
              (contact) => Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: _ContactCard(
                  contact: contact,
                  onTap: () => context.pushNamed(
                    'contactDetail',
                    extra: contact.toDetailArgs(loc),
                  ),
                  onShowInsights: () => _showContactInsights(contact),
                  onEditContact: () => _openContactForm(contact: contact),
                ),
              ),
            ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: SafeArea(
              bottom: false,
              child: isInitialLoading
                  ? const Center(child: CircularProgressIndicator())
                  : listContent,
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

class _ContactsListHeader extends StatelessWidget {
  const _ContactsListHeader({
    required this.searchController,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  final TextEditingController searchController;
  final _ContactFilter selectedFilter;
  final ValueChanged<_ContactFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final loc = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: CustomTextField(
            controller: searchController,
            hintText: loc.commonSearchContacts,
            iconPath: 'assets/images/search-svgrepo-com.svg',
            widthFactor: 1,
          ),
        ),
        const SizedBox(height: 12),
        _ContactFilterRow(selected: selectedFilter, onChanged: onFilterChanged),
      ],
    );
  }
}

class _EmptyPlaceholder extends StatelessWidget {
  const _EmptyPlaceholder({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.textfieldBorder.withValues(alpha: 0.4),
        ),
      ),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppColors.hintTextfiled,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ErrorPlaceholder extends StatelessWidget {
  const _ErrorPlaceholder({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _EmptyPlaceholder(message: message),
        const SizedBox(height: 12),
        FilledButton.tonal(
          onPressed: () => onRetry(),
          child: const Text('Retry'),
        ),
      ],
    );
  }
}

class _ContactFilterRow extends StatelessWidget {
  const _ContactFilterRow({required this.selected, required this.onChanged});

  final _ContactFilter selected;
  final ValueChanged<_ContactFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    final loc = context.l10n;
    final filters = [
      (label: loc.commonAllFilter, filter: _ContactFilter.all),
      (label: loc.commonClientsFilter, filter: _ContactFilter.clients),
      (
        label: loc.commonCollaboratorsFilter,
        filter: _ContactFilter.collaborators,
      ),
      (label: loc.commonSuppliersFilter, filter: _ContactFilter.suppliers),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          for (var i = 0; i < filters.length; i++) ...[
            _FilterChip(
              label: filters[i].label,
              selected: filters[i].filter == selected,
              onTap: () => onChanged(filters[i].filter),
            ),
            if (i != filters.length - 1) const SizedBox(width: 12),
          ],
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: selected
              ? const LinearGradient(
                  colors: [AppColors.secondary, AppColors.primary],
                  begin: AlignmentDirectional(1.0, 0.34),
                  end: AlignmentDirectional(-1.0, -0.34),
                )
              : null,
          color: selected ? null : AppColors.secondaryBackground,
          border: Border.all(
            color: selected
                ? Colors.transparent
                : AppColors.textfieldBorder.withValues(alpha: 0.7),
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: selected ? AppColors.primaryText : AppColors.secondaryText,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.contact,
    required this.onTap,
    required this.onShowInsights,
    required this.onEditContact,
  });

  final CrmContact contact;
  final VoidCallback onTap;
  final VoidCallback onShowInsights;
  final VoidCallback onEditContact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = context.l10n;
    final CrmStat? primaryStat = contact.primaryStat;
    final typeLabel = contact.localizedTypeLabel(loc);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.secondaryBackground,
          borderRadius: BorderRadius.circular(26),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 24,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _AvatarBadge(label: contact.initials),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contact.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppColors.secondaryText,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _TypeChip(label: typeLabel),
                    ],
                  ),
                ),
                const Icon(
                  FeatherIcons.chevronRight,
                  size: 18,
                  color: AppColors.hintTextfiled,
                ),
              ],
            ),
            if (contact.relationshipLabel != null) ...[
              const SizedBox(height: 10),
              Text(
                contact.relationshipLabel!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.hintTextfiled,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            if (contact.primaryProjectLabel != null) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  const Icon(
                    FeatherIcons.briefcase,
                    size: 16,
                    color: AppColors.hintTextfiled,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      contact.primaryProjectLabel!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.secondaryText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (contact.email != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    FeatherIcons.mail,
                    size: 16,
                    color: AppColors.hintTextfiled,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      contact.email!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.hintTextfiled,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (primaryStat != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    FeatherIcons.barChart2,
                    size: 16,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${primaryStat.label}: ${primaryStat.value}'
                      '${primaryStat.trend != null ? ' - ${primaryStat.trend}' : ''}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.secondaryText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (contact.notes != null) ...[
              const SizedBox(height: 12),
              Text(
                contact.notes!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.secondaryText.withValues(alpha: 0.9),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                _CRMActionButton(
                  icon: FeatherIcons.info,
                  label: loc.crmRowInsights,
                  onTap: onShowInsights,
                ),
                const SizedBox(width: 12),
                _CRMActionButton(
                  icon: FeatherIcons.edit3,
                  label: loc.crmRowEditContact,
                  onTap: onEditContact,
                ),
              ],
            ),
          ],
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
    return Container(
      width: 56,
      height: 56,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [AppColors.secondary, AppColors.primary],
          begin: AlignmentDirectional(1.0, 0.2),
          end: AlignmentDirectional(-1.0, -0.2),
        ),
      ),
      alignment: Alignment.center,
      child: Container(
        width: 50,
        height: 50,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.secondaryBackground,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: AppColors.secondaryText,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: AppColors.secondary.withValues(alpha: 0.12),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.secondary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

enum _ContactFilter { all, clients, collaborators, suppliers }

extension _CrmContactLocalization on CrmContact {
  String localizedTypeLabel(AppLocalizations loc) {
    return switch (type) {
      CrmContactType.client => loc.crmContactTypeClient,
      CrmContactType.supplier => loc.crmContactTypeSupplier,
      CrmContactType.collaborator => loc.crmContactTypeCollaborator,
    };
  }

  ContactDetailArgs toDetailArgs(AppLocalizations loc) {
    return ContactDetailArgs(
      contactId: id,
      name: name,
      title: localizedTypeLabel(loc),
      category: switch (type) {
        CrmContactType.client => ContactCategory.client,
        CrmContactType.supplier => ContactCategory.supplier,
        CrmContactType.collaborator => ContactCategory.collaborator,
      },
      email: email,
      phone: phone,
      location: address,
      note: notes,
      projects: projects,
    );
  }
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
  const _ContactInsightsSheet({required this.contact});

  final CrmContact contact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = context.l10n;
    final typeLabel = contact.localizedTypeLabel(loc);

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
                _AvatarBadge(label: contact.initials),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contact.name,
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
                          _TypeChip(label: typeLabel),
                          if (contact.primaryProjectLabel != null)
                            _TypeChip(label: contact.primaryProjectLabel!),
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
            if (contact.address != null) ...[
              const SizedBox(height: 12),
              _ContactDetailRow(
                icon: FeatherIcons.mapPin,
                label: contact.address!,
              ),
            ],
            if (contact.email != null) ...[
              const SizedBox(height: 8),
              _ContactDetailRow(icon: FeatherIcons.mail, label: contact.email!),
            ],
            if (contact.phone != null) ...[
              const SizedBox(height: 8),
              _ContactDetailRow(
                icon: FeatherIcons.phone,
                label: contact.phone!,
              ),
            ],
            if (contact.relationshipLabel != null || contact.notes != null)
              const SizedBox(height: 16),
            if (contact.relationshipLabel != null)
              Text(
                contact.relationshipLabel!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.secondaryText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            if (contact.notes != null) ...[
              const SizedBox(height: 8),
              Text(
                contact.notes!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.hintTextfiled,
                ),
              ),
            ],
            if (contact.stats.isNotEmpty) ...[
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final stat in contact.stats) _CRMStatCard(stat: stat),
                ],
              ),
            ],
            if (contact.linkedProjects.isNotEmpty) ...[
              const SizedBox(height: 20),
              _CRMSection(
                title: loc.crmSectionLinkedProjects,
                items: contact.linkedProjects,
                icon: FeatherIcons.briefcase,
              ),
            ],
            if (contact.financeHighlights.isNotEmpty) ...[
              const SizedBox(height: 16),
              _CRMSection(
                title: loc.crmSectionFinanceHistory,
                items: contact.financeHighlights,
                icon: FeatherIcons.creditCard,
              ),
            ],
            if (contact.documentLinks.isNotEmpty) ...[
              const SizedBox(height: 16),
              _CRMSection(
                title: loc.crmSectionDocuments,
                items: contact.documentLinks,
                icon: FeatherIcons.folder,
              ),
            ],
            if (contact.isClient) ...[
              const SizedBox(height: 20),
              GradiantButtonWidget(
                buttonText: loc.crmActionCreateProject,
                widthFactor: 1,
                onPressed: () => _openProjectCreation(context),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _CRMActionButton(
                    icon: FeatherIcons.fileText,
                    label: loc.crmActionSendQuote,
                    onTap: () => _openQuoteCreation(context),
                  ),
                  const SizedBox(width: 12),
                  _CRMActionButton(
                    icon: FeatherIcons.creditCard,
                    label: loc.crmActionCreateInvoice,
                    onTap: () => _openInvoiceCreation(context),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            GradiantButtonWidget(
              buttonText: loc.crmActionOpenDetail,
              widthFactor: 1,
              onPressed: () {
                final router = GoRouter.of(context);
                Navigator.of(context).pop();
                router.pushNamed(
                  'contactDetail',
                  extra: contact.toDetailArgs(loc),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _openProjectCreation(BuildContext context) {
    GoRouter.of(context).pushNamed(
      'projectsCreate',
      extra: ContactProjectSeed(
        contactId: contact.id,
        clientName: contact.name,
        clientEmail: contact.email,
      ),
    );
  }

  void _openQuoteCreation(BuildContext context) {
    GoRouter.of(context).pushNamed(
      'financeCreateQuote',
      queryParameters: {
        'clientName': contact.name,
        if (contact.email != null && contact.email!.trim().isNotEmpty)
          'clientEmail': contact.email!.trim(),
        'contactId': contact.id,
      },
    );
  }

  void _openInvoiceCreation(BuildContext context) {
    final params = <String, String>{};
    if (contact.projects.isNotEmpty && contact.projects.first.id.isNotEmpty) {
      params['projectId'] = contact.projects.first.id;
    } else if (contact.linkedProjects.isNotEmpty) {
      params['projectId'] = contact.linkedProjects.first;
    }
    params['clientName'] = contact.name;
    if (contact.email != null && contact.email!.trim().isNotEmpty) {
      params['clientEmail'] = contact.email!.trim();
    }
    params['contactId'] = contact.id;
    GoRouter.of(context).pushNamed(
      'financeCreateInvoiceForm',
      queryParameters: params.cast<String, dynamic>(),
    );
  }
}

class _CRMStatCard extends StatelessWidget {
  const _CRMStatCard({required this.stat});

  final CrmStat stat;

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

class _ContactDetailRow extends StatelessWidget {
  const _ContactDetailRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.hintTextfiled),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.secondaryText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
