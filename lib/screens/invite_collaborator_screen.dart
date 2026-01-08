import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:myapp/app/app_theme.dart';
import 'package:myapp/app/widgets/custom_nav_bar.dart';
import 'package:myapp/app/widgets/gradient_button.dart';
import 'package:myapp/common/localization/l10n_extensions.dart';
import 'package:myapp/common/models/collaborator_contact.dart';
import 'package:myapp/controllers/project_controller.dart';
import 'package:myapp/models/project.dart';
import 'package:myapp/l10n/app_localizations.dart';

class InviteCollaboratorScreen extends StatefulWidget {
  const InviteCollaboratorScreen({super.key, this.initialProjectId});

  final String? initialProjectId;

  @override
  State<InviteCollaboratorScreen> createState() =>
      _InviteCollaboratorScreenState();
}

class _InviteCollaboratorScreenState extends State<InviteCollaboratorScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _customRoleController = TextEditingController();
  static const List<String> _rolePresets = ['Owner', 'Editor', 'Viewer'];
  final List<String> _customRoles = [];

  String _selectedRole = _rolePresets.first;
  bool _shareLink = false;
  String? _selectedProjectId;

  List<String> get _availableRoles => [..._rolePresets, ..._customRoles];

  @override
  void initState() {
    super.initState();
    _selectedProjectId = widget.initialProjectId;
  }

  void _addCustomRole() {
    final raw = _customRoleController.text.trim();
    if (raw.isEmpty) {
      return;
    }

    final normalized = raw.toLowerCase();
    final existing = _availableRoles.firstWhere(
      (role) => role.toLowerCase() == normalized,
      orElse: () => '',
    );

    if (existing.isNotEmpty) {
      setState(() => _selectedRole = existing);
      _customRoleController.clear();
      return;
    }

    setState(() {
      _customRoles.add(raw);
      _selectedRole = raw;
      _customRoleController.clear();
    });
    FocusScope.of(context).unfocus();
  }

  Project? _resolveSelectedProject(ProjectController controller) {
    final projectId = _selectedProjectId;
    if (projectId == null) {
      return null;
    }
    for (final project in controller.projects) {
      if (project.id == projectId) {
        return project;
      }
    }
    return null;
  }

  Future<void> _sendDirectInvite(ProjectController controller) async {
    final loc = context.l10n;
    final project = _resolveSelectedProject(controller);
    if (project == null) {
      _showMessage(loc.inviteCollaboratorSnackbarSelectProject);
      return;
    }

    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showMessage(loc.inviteCollaboratorSnackbarEmailRequired);
      return;
    }

    final note = _messageController.text.trim();
    final existingContact = controller.contacts.firstWhere(
      (contact) => contact.email.toLowerCase() == email.toLowerCase(),
      orElse: () => const CollaboratorContact(
        id: 'temp',
        name: '',
        profession: '',
        availability: CollaboratorAvailability.offline,
        location: '',
        email: '',
      ),
    );

    final hasContact = existingContact.email.isNotEmpty;
    final inviteeName = hasContact
        ? existingContact.name
        : _deriveNameFromEmail(email);
    final alreadyRegistered = await controller.emailHasRegisteredUser(email);
    final requiresOnboarding =
        (!hasContact && !alreadyRegistered) || !_shareLink;

    try {
      await controller.addInvitation(
        projectId: project.id,
        projectName: project.name,
        inviteeName: inviteeName,
        inviteeEmail: email,
        role: _selectedRole,
        message: note.isEmpty ? null : note,
        requiresOnboarding: requiresOnboarding,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      _showMessage('Failed to send invitation. Please try again.');
      return;
    }

    if (!mounted) {
      return;
    }
    _emailController.clear();
    _messageController.clear();
    FocusScope.of(context).unfocus();
    _showMessage(loc.inviteCollaboratorSnackbarSent(inviteeName));
    context.goNamed('projectDetail', pathParameters: {'id': project.id});
  }

  Future<void> _openContactsPicker(ProjectController controller) async {
    final loc = context.l10n;
    final project = _resolveSelectedProject(controller);
    if (project == null) {
      _showMessage(loc.inviteCollaboratorSnackbarSelectProjectContacts);
      return;
    }

    final result = await showModalBottomSheet<_ContactSelectionResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ContactsPickerSheet(
        contacts: controller.contacts,
        initialRole: _selectedRole,
        availableRoles: _availableRoles,
      ),
    );

    if (result == null || result.contacts.isEmpty) {
      return;
    }

    for (final contact in result.contacts) {
      await controller.addInvitation(
        projectId: project.id,
        projectName: project.name,
        inviteeName: contact.name,
        inviteeEmail: contact.email,
        role: result.role,
        message: result.note.isEmpty ? null : result.note,
        requiresOnboarding: false,
      );
    }

    if (!mounted) {
      return;
    }

    setState(() => _selectedRole = result.role);
    _showMessage(
      loc.inviteCollaboratorSnackbarContactsQueued(result.contacts.length),
    );
    context.goNamed('projectDetail', pathParameters: {'id': project.id});
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  String _deriveNameFromEmail(String email) {
    final loc = context.l10n;
    final localPart = email.split('@').first;
    final tokens = localPart
        .replaceAll(RegExp(r'[^a-zA-Z0-9\s]'), ' ')
        .split(RegExp(r'[._\s]+'))
        .where((segment) => segment.isNotEmpty)
        .map(
          (segment) =>
              segment[0].toUpperCase() + segment.substring(1).toLowerCase(),
        );
    final fallback = tokens.join(' ');
    return fallback.isEmpty ? loc.inviteCollaboratorFallbackName : fallback;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _messageController.dispose();
    _customRoleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = context.watch<ProjectController>();
    final projects = controller.projects;
    final loc = context.l10n;
    final dropdownDecoration = InputDecorationTheme(
      filled: true,
      fillColor: AppColors.textfieldBackground,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      hintStyle: const TextStyle(
        color: AppColors.hintTextfiled,
        fontWeight: FontWeight.w600,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: AppColors.textfieldBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: AppColors.textfieldBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: AppColors.secondary),
      ),
    );

    _selectedProjectId ??=
        widget.initialProjectId ??
        (projects.isNotEmpty ? projects.first.id : null);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          loc.inviteCollaboratorTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            color: AppColors.secondaryText,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            FeatherIcons.chevronLeft,
            color: AppColors.secondaryText,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  24,
                  16,
                  24,
                  CustomNavBar.totalHeight + 36,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionLabel(loc.inviteCollaboratorSelectProject),
                    const SizedBox(height: 10),
                    Theme(
                      data: Theme.of(
                        context,
                      ).copyWith(inputDecorationTheme: dropdownDecoration),
                      child: DropdownMenu<String>(
                        initialSelection: _selectedProjectId,
                        onSelected: (value) =>
                            setState(() => _selectedProjectId = value),
                        hintText: loc.inviteCollaboratorChooseProject,
                        dropdownMenuEntries: projects
                            .map(
                              (project) => DropdownMenuEntry<String>(
                                value: project.id,
                                label: project.name,
                              ),
                            )
                            .toList(growable: false),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      loc.inviteCollaboratorInfoText,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.hintTextfiled,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _SectionLabel(loc.inviteCollaboratorEmailSection),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _emailController,
                      decoration: _inputDecoration(
                        loc.inviteCollaboratorEmailHint,
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 14),
                    Align(
                      alignment: Alignment.centerRight,
                      child: OutlinedButton.icon(
                        onPressed: () => _openContactsPicker(controller),
                        icon: const Icon(FeatherIcons.users, size: 18),
                        label: Text(loc.inviteCollaboratorFromContacts),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.secondary,
                          side: const BorderSide(
                            color: AppColors.secondary,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    _SectionLabel(loc.inviteCollaboratorRoleSection),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _availableRoles
                          .map(
                            (role) => GestureDetector(
                              onTap: () => setState(() => _selectedRole = role),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  gradient: _selectedRole == role
                                      ? const LinearGradient(
                                          colors: [
                                            AppColors.secondary,
                                            AppColors.primary,
                                          ],
                                          begin: AlignmentDirectional(
                                            1.0,
                                            0.34,
                                          ),
                                          end: AlignmentDirectional(
                                            -1.0,
                                            -0.34,
                                          ),
                                        )
                                      : null,
                                  color: _selectedRole == role
                                      ? null
                                      : AppColors.secondaryBackground,
                                  border: Border.all(
                                    color: _selectedRole == role
                                        ? Colors.transparent
                                        : AppColors.textfieldBorder,
                                  ),
                                ),
                                child: Text(
                                  _localizedRoleLabel(loc, role),
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: _selectedRole == role
                                        ? AppColors.primaryText
                                        : AppColors.secondaryText,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _customRoleController,
                            decoration: _inputDecoration(
                              loc.inviteCollaboratorCustomRoleHint,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        GradientButton(
                          onPressed: _addCustomRole,
                          text: loc.inviteCollaboratorAddRole,
                          height: 48,
                          width: 140,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _SectionLabel(loc.inviteCollaboratorMessageSection),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _messageController,
                      maxLines: 5,
                      decoration: _inputDecoration(
                        loc.inviteCollaboratorMessageHint,
                      ),
                    ),
                    const SizedBox(height: 28),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      value: _shareLink,
                      onChanged: (value) => setState(() => _shareLink = value),
                      inactiveThumbColor: AppColors.hintTextfiled,
                      activeThumbColor: AppColors.secondary,
                      activeTrackColor: AppColors.secondary.withValues(
                        alpha: 0.32,
                      ),
                      title: Text(
                        loc.inviteCollaboratorShareLinkTitle,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: AppColors.secondaryText,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        loc.inviteCollaboratorShareLinkSubtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.hintTextfiled,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    AnimatedCrossFade(
                      crossFadeState: _shareLink
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 200),
                      firstChild: const SizedBox.shrink(),
                      secondChild: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(top: 16),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.textfieldBackground,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.textfieldBorder),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              FeatherIcons.link,
                              color: AppColors.secondary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'https://rush.manage/invite/dupont-wedding-token',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.secondaryText,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: Text(loc.inviteCollaboratorCopyLink),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    GradientButton(
                      onPressed: () => _sendDirectInvite(controller),
                      text: loc.inviteCollaboratorPrimaryCta,
                      width: double.infinity,
                      height: 52,
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
            child: CustomNavBar(currentRouteName: 'inviteCollaborator'),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        color: AppColors.hintTextfiled,
        fontWeight: FontWeight.w600,
      ),
      filled: true,
      fillColor: AppColors.textfieldBackground,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: AppColors.textfieldBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: AppColors.textfieldBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: AppColors.secondary),
      ),
    );
  }
}

String _localizedRoleLabel(AppLocalizations loc, String role) {
  switch (role.toLowerCase()) {
    case 'owner':
      return loc.inviteCollaboratorRoleOwner;
    case 'editor':
      return loc.inviteCollaboratorRoleEditor;
    case 'viewer':
      return loc.inviteCollaboratorRoleViewer;
    default:
      return role;
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      label,
      style: theme.textTheme.titleSmall?.copyWith(
        color: AppColors.secondaryText,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _ContactsPickerSheet extends StatefulWidget {
  const _ContactsPickerSheet({
    required this.contacts,
    required this.initialRole,
    required this.availableRoles,
  });

  final List<CollaboratorContact> contacts;
  final String initialRole;
  final List<String> availableRoles;

  @override
  State<_ContactsPickerSheet> createState() => _ContactsPickerSheetState();
}

class _ContactsPickerSheetState extends State<_ContactsPickerSheet> {
  final TextEditingController _noteController = TextEditingController();
  final Set<String> _selectedIds = <String>{};
  late String _role;

  @override
  void initState() {
    super.initState();
    _role = widget.initialRole;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = context.l10n;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: 24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.textfieldBorder,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            loc.inviteCollaboratorInviteSheetTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.secondaryText,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Theme(
            data: Theme.of(context).copyWith(
              inputDecorationTheme: const InputDecorationTheme(
                border: OutlineInputBorder(),
              ),
            ),
            child: DropdownMenu<String>(
              initialSelection: _role,
              onSelected: (value) => setState(() => _role = value ?? _role),
              label: Text(loc.inviteCollaboratorInviteSheetRoleLabel),
              dropdownMenuEntries: widget.availableRoles
                  .map(
                    (role) => DropdownMenuEntry<String>(
                      value: role,
                      label: _localizedRoleLabel(loc, role),
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 280,
            child: ListView.builder(
              itemCount: widget.contacts.length,
              itemBuilder: (context, index) {
                final contact = widget.contacts[index];
                final selected = _selectedIds.contains(contact.id);
                return _ContactListTile(
                  contact: contact,
                  selected: selected,
                  onChanged: () => _toggleSelection(contact.id),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _noteController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: loc.inviteCollaboratorInviteSheetNoteLabel,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          GradientButton(
            onPressed: () {
              if (_selectedIds.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      loc.inviteCollaboratorInviteSheetSelectContactError,
                    ),
                  ),
                );
                return;
              }
              final selectedContacts = widget.contacts
                  .where((contact) => _selectedIds.contains(contact.id))
                  .toList(growable: false);
              Navigator.of(context).pop(
                _ContactSelectionResult(
                  contacts: selectedContacts,
                  role: _role,
                  note: _noteController.text.trim(),
                ),
              );
            },
            text: loc.inviteCollaboratorInviteSheetPrimaryCta,
            height: 52,
            width: double.infinity,
          ),
        ],
      ),
    );
  }
}

class _ContactListTile extends StatelessWidget {
  const _ContactListTile({
    required this.contact,
    required this.selected,
    required this.onChanged,
  });

  final CollaboratorContact contact;
  final bool selected;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = context.l10n;
    final (label, color) = switch (contact.availability) {
      CollaboratorAvailability.available => (
        loc.inviteCollaboratorAvailabilityAvailable,
        AppColors.available,
      ),
      CollaboratorAvailability.busy => (
        loc.inviteCollaboratorAvailabilityBusy,
        AppColors.reserved,
      ),
      CollaboratorAvailability.offline => (
        loc.inviteCollaboratorAvailabilityOffline,
        AppColors.hintTextfiled,
      ),
    };

    return Card(
      color: selected ? AppColors.secondaryBackground : AppColors.background,
      elevation: selected ? 4 : 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ListTile(
        onTap: onChanged,
        leading: CircleAvatar(
          backgroundColor: AppColors.secondary.withValues(alpha: 0.1),
          child: Text(
            contact.name.isEmpty
                ? '?'
                : contact.name
                      .split(' ')
                      .where((segment) => segment.isNotEmpty)
                      .map((segment) => segment[0].toUpperCase())
                      .take(2)
                      .join(),
            style: theme.textTheme.labelLarge?.copyWith(
              color: AppColors.secondaryText,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          contact.name,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: AppColors.secondaryText,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              contact.profession,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.hintTextfiled,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.circle, size: 10, color: color),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Checkbox(
          value: selected,
          onChanged: (_) => onChanged(),
          activeColor: AppColors.secondary,
        ),
      ),
    );
  }
}

class _ContactSelectionResult {
  const _ContactSelectionResult({
    required this.contacts,
    required this.role,
    required this.note,
  });

  final List<CollaboratorContact> contacts;
  final String role;
  final String note;
}
