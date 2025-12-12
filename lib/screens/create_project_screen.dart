import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:myapp/app/app_theme.dart';
import 'package:myapp/app/widgets/custom_nav_bar.dart';
import 'package:myapp/app/widgets/gradient_button.dart';
import 'package:myapp/app/widgets/app_form_fields.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myapp/common/models/contact_detail_args.dart';
import 'package:myapp/common/localization/l10n_extensions.dart';
import 'package:myapp/controllers/project_controller.dart';
import 'package:myapp/models/project.dart';

class CreateProjectScreen extends StatefulWidget {
  const CreateProjectScreen({super.key, this.seed});

  final ContactProjectSeed? seed;

  @override
  State<CreateProjectScreen> createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends State<CreateProjectScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _clientController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _inviteController = TextEditingController();
  final List<_Invitee> _invitees = [];
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedCategory;
  static const String _categoryEventManagement = 'eventManagement';
  static const String _categoryPhotography = 'photography';
  static const String _categoryMarketing = 'marketing';
  static const String _categoryLogistics = 'logistics';
  static const String _categoryOther = 'other';
  static const List<String> _categories = [
    _categoryEventManagement,
    _categoryPhotography,
    _categoryMarketing,
    _categoryLogistics,
    _categoryOther,
  ];

  static const String _roleOwnerKey = 'owner';
  static const String _roleEditorKey = 'editor';
  static const String _roleViewerKey = 'viewer';
  static const List<String> _rolePresets = [
    _roleOwnerKey,
    _roleEditorKey,
    _roleViewerKey,
  ];
  final List<String> _customRoles = [];
  String _selectedRole = _rolePresets.first;
  final TextEditingController _customRoleController = TextEditingController();
  bool _inviteExternal = false;
  bool _isLoading = false;

  List<String> get _availableRoles => [..._rolePresets, ..._customRoles];

  Future<void> _pickDate({required bool isStart}) async {
    final initialDate = isStart
        ? (_startDate ?? DateTime.now())
        : (_endDate ?? _startDate ?? DateTime.now());
    final newDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (newDate != null) {
      setState(() {
        if (isStart) {
          _startDate = newDate;
          if (_endDate != null && _endDate!.isBefore(newDate)) {
            _endDate = newDate;
          }
        } else {
          _endDate = newDate;
        }
      });
    }
  }

  String _formatDate(BuildContext context, DateTime? date) {
    if (date == null) return context.l10n.createProjectSelectDate;
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  String _categoryLabel(BuildContext context, String category) {
    final loc = context.l10n;
    switch (category) {
      case _categoryEventManagement:
        return loc.createProjectCategoryEventManagement;
      case _categoryPhotography:
        return loc.createProjectCategoryPhotography;
      case _categoryMarketing:
        return loc.createProjectCategoryMarketing;
      case _categoryLogistics:
        return loc.createProjectCategoryLogistics;
      case _categoryOther:
        return loc.createProjectCategoryOther;
      default:
        return category;
    }
  }

  String _roleLabel(BuildContext context, String role) {
    final loc = context.l10n;
    switch (role) {
      case _roleOwnerKey:
        return loc.createProjectRoleOwner;
      case _roleEditorKey:
        return loc.createProjectRoleEditor;
      case _roleViewerKey:
        return loc.createProjectRoleViewer;
      default:
        return role;
    }
  }

  void _addInvitee() {
    final email = _inviteController.text.trim();
    if (email.isEmpty) return;
    setState(() {
      _invitees.add(_Invitee(email: email, role: _selectedRole));
      _inviteController.clear();
    });
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

  Future<void> _submit(ProjectController controller) async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (_startDate != null &&
        _endDate != null &&
        _endDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.createProjectDateError),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 800));

    final seedMembers = widget.seed;
    final members = _inviteesAsMembers();
    if (seedMembers != null) {
      final alreadyIncluded = members.any(
        (member) => member.id == seedMembers.contactId,
      );
      if (!alreadyIncluded) {
        members.insert(
          0,
          Member(id: seedMembers.contactId, name: seedMembers.clientName),
        );
      }
    }

    final id = DateTime.now().millisecondsSinceEpoch.toString();
    controller.addProject(
      Project(
        id: id,
        name: _nameController.text.trim(),
        client: _clientController.text.trim(),
        description: _descriptionController.text.trim(),
        status: ProjectStatus.inPreparation,
        startDate: _startDate,
        endDate: _endDate,
        members: members,
      ),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);
    context.goNamed('projectDetail', pathParameters: {'id': id});
  }

  List<Member> _inviteesAsMembers() {
    return _invitees
        .map(
          (invite) =>
              Member(id: invite.email, name: invite.email.split('@').first),
        )
        .toList();
  }

  @override
  void initState() {
    super.initState();
    final seed = widget.seed;
    if (seed != null) {
      _clientController.text = seed.clientName;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ProjectController>();
    final loc = context.l10n;
    final previewLink =
        'https://rush.manage/invite/${DateTime.now().millisecondsSinceEpoch}';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  24,
                  20,
                  24,
                  CustomNavBar.totalHeight + 40,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.textfieldBackground,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.chevron_left,
                                color: AppColors.secondaryText,
                              ),
                              onPressed: () {
                                final router = GoRouter.of(context);
                                if (router.canPop()) {
                                  router.pop();
                                } else {
                                  router.goNamed('management');
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  loc.createProjectTitle,
                                  style: Theme.of(context)
                                      .textTheme
                                      .displaySmall
                                      ?.copyWith(
                                        color: AppColors.secondaryText,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  loc.createProjectSubtitle,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: AppColors.hintTextfiled,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      _LabeledField(
                        label: loc.createProjectFieldNameLabel,
                        child: AppFormTextField(
                          controller: _nameController,
                          hintText: loc.createProjectFieldNameHint,
                          validator: (value) =>
                              (value == null || value.trim().isEmpty)
                              ? loc.createProjectFieldNameRequired
                              : null,
                        ),
                      ),
                      const SizedBox(height: 18),
                      _LabeledField(
                        label: loc.createProjectFieldClientLabel,
                        child: AppFormTextField(
                          controller: _clientController,
                          hintText: loc.createProjectFieldClientHint,
                        ),
                      ),
                      const SizedBox(height: 18),
                      _LabeledField(
                        label: loc.createProjectFieldCategoryLabel,
                        child: AppDropdownField<String>(
                          value: _selectedCategory,
                          items: _categories,
                          hintText: loc.createProjectFieldCategoryHint,
                          labelBuilder: (value) =>
                              _categoryLabel(context, value),
                          onChanged: (value) =>
                              setState(() => _selectedCategory = value),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: _LabeledField(
                              label: loc.createProjectFieldStartDate,
                              child: AppDateField(
                                label: _formatDate(context, _startDate),
                                hasValue: _startDate != null,
                                onTap: () => _pickDate(isStart: true),
                                leading: SvgPicture.asset(
                                  'assets/images/calendar_2.svg',
                                  width: 22,
                                  height: 22,
                                  colorFilter: const ColorFilter.mode(
                                    AppColors.secondary,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _LabeledField(
                              label: loc.createProjectFieldEndDate,
                              child: AppDateField(
                                label: _formatDate(context, _endDate),
                                hasValue: _endDate != null,
                                onTap: () => _pickDate(isStart: false),
                                leading: SvgPicture.asset(
                                  'assets/images/calendar_2.svg',
                                  width: 22,
                                  height: 22,
                                  colorFilter: const ColorFilter.mode(
                                    AppColors.secondary,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _LabeledField(
                        label: loc.createProjectFieldDescriptionLabel,
                        child: AppFormTextField(
                          controller: _descriptionController,
                          hintText: loc.createProjectFieldDescriptionHint,
                          maxLines: 4,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _SectionHeader(
                        title: loc.createProjectInviteTitle,
                        description: loc.createProjectInviteDescription,
                      ),
                      const SizedBox(height: 14),
                      AppFormTextField(
                        controller: _inviteController,
                        hintText: loc.commonEmailAddress,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: _availableRoles
                            .map(
                              (role) => _RoleChip(
                                label: _roleLabel(context, role),
                                selected: _selectedRole == role,
                                onTap: () =>
                                    setState(() => _selectedRole = role),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: AppFormTextField(
                              controller: _customRoleController,
                              hintText: loc.createProjectCustomRolePlaceholder,
                              textInputAction: TextInputAction.done,
                            ),
                          ),
                          const SizedBox(width: 12),
                          GradientButton(
                            onPressed: _addCustomRole,
                            text: loc.createProjectAddRole,
                            width: 140,
                            height: 48,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Align(
                        alignment: Alignment.centerRight,
                        child: GradientButton(
                          onPressed: _addInvitee,
                          text: loc.createProjectAddMember,
                          width: 160,
                          height: 48,
                        ),
                      ),
                      if (_invitees.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: _invitees
                              .map(
                                (invite) => Chip(
                                  backgroundColor:
                                      AppColors.textfieldBackground,
                                  label: Text(
                                    '${invite.email} • ${_roleLabel(context, invite.role)}',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: AppColors.secondaryText,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  deleteIcon: const Icon(Icons.close, size: 18),
                                  onDeleted: () =>
                                      setState(() => _invitees.remove(invite)),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                      const SizedBox(height: 24),
                      Material(
                        color: Colors.transparent,
                        child: Ink(
                          decoration: BoxDecoration(
                            color: AppColors.textfieldBackground,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: AppColors.textfieldBorder,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.secondary.withValues(
                                  alpha: 0.08,
                                ),
                                blurRadius: 18,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(24),
                            onTap: () => setState(
                              () => _inviteExternal = !_inviteExternal,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 18,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          loc.createProjectInviteExternalTitle,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.copyWith(
                                                color: AppColors.secondaryText,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          loc.createProjectInviteExternalDescription,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: AppColors.hintTextfiled,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Theme(
                                    data: Theme.of(context).copyWith(
                                      switchTheme: SwitchThemeData(
                                        thumbColor:
                                            WidgetStateProperty.resolveWith((
                                              states,
                                            ) {
                                              if (states.contains(
                                                WidgetState.selected,
                                              )) {
                                                return AppColors.primary;
                                              }
                                              if (states.contains(
                                                WidgetState.disabled,
                                              )) {
                                                return AppColors.hintTextfiled;
                                              }
                                              return AppColors.secondaryText
                                                  .withValues(alpha: 0.5);
                                            }),
                                        trackColor:
                                            WidgetStateProperty.resolveWith((
                                              states,
                                            ) {
                                              if (states.contains(
                                                WidgetState.selected,
                                              )) {
                                                return AppColors.primary
                                                    .withValues(alpha: 0.28);
                                              }
                                              if (states.contains(
                                                WidgetState.disabled,
                                              )) {
                                                return AppColors.textfieldBorder
                                                    .withValues(alpha: 0.3);
                                              }
                                              return AppColors.textfieldBorder
                                                  .withValues(alpha: 0.6);
                                            }),
                                        trackOutlineColor:
                                            WidgetStateProperty.resolveWith(
                                              (states) => Colors.transparent,
                                            ),
                                      ),
                                    ),
                                    child: Switch(
                                      value: _inviteExternal,
                                      onChanged: (value) => setState(
                                        () => _inviteExternal = value,
                                      ),
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (_inviteExternal)
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(top: 14),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryBackground,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: AppColors.textfieldBorder.withValues(
                                alpha: 0.7,
                              ),
                            ),
                          ),
                          child: Text(
                            loc.createProjectPreviewLink(previewLink),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AppColors.secondaryText,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      const SizedBox(height: 32),
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 420),
                          child: GradientButton(
                            onPressed: () {
                              if (_isLoading) return;
                              _submit(controller);
                            },
                            text: loc.createProjectPrimaryCta,
                            isLoading: _isLoading,
                            width: double.infinity,
                          ),
                        ),
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
            child: CustomNavBar(currentRouteName: 'projectsCreate'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _clientController.dispose();
    _descriptionController.dispose();
    _inviteController.dispose();
    _customRoleController.dispose();
    super.dispose();
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.secondaryText,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.secondaryText,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          description,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.hintTextfiled,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _Invitee {
  const _Invitee({required this.email, required this.role});

  final String email;
  final String role;
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({
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
            color: selected ? Colors.transparent : AppColors.textfieldBorder,
            width: 1.2,
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
                    color: AppColors.secondary.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
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
