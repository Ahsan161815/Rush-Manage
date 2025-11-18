import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import 'package:myapp/app/app_theme.dart';
import 'package:myapp/app/widgets/custom_nav_bar.dart';
import 'package:myapp/app/widgets/gradient_button.dart';
import 'package:myapp/app/widgets/app_form_fields.dart';
import 'package:myapp/controllers/project_controller.dart';
import 'package:myapp/models/project.dart';

class CreateProjectScreen extends StatefulWidget {
  const CreateProjectScreen({super.key});

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
  String _selectedRole = 'Collaborator';
  bool _inviteExternal = false;
  bool _isLoading = false;

  final List<String> _categories = const [
    'Event Management',
    'Photography',
    'Marketing',
    'Logistics',
    'Other',
  ];

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

  String _formatDate(DateTime? date) {
    if (date == null) return 'Select date';
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  void _addInvitee() {
    final email = _inviteController.text.trim();
    if (email.isEmpty) return;
    setState(() {
      _invitees.add(_Invitee(email: email, role: _selectedRole));
      _inviteController.clear();
    });
  }

  Future<void> _submit(ProjectController controller) async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (_startDate != null &&
        _endDate != null &&
        _endDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('End date cannot be before start date'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 800));

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
        members: _invitees
            .map(
              (invite) =>
                  Member(id: invite.email, name: invite.email.split('@').first),
            )
            .toList(),
      ),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);
    context.goNamed('projectDetail', pathParameters: {'id': id});
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ProjectController>();

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
                                  router.goNamed('dashboard');
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
                                  'New Project',
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
                                  'Set up the essentials in a few quick steps.',
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
                        label: 'Project name',
                        child: AppFormTextField(
                          controller: _nameController,
                          hintText: 'e.g. Dupont Wedding',
                          validator: (value) =>
                              (value == null || value.trim().isEmpty)
                              ? 'Project name is required'
                              : null,
                        ),
                      ),
                      const SizedBox(height: 18),
                      _LabeledField(
                        label: 'Client',
                        child: AppFormTextField(
                          controller: _clientController,
                          hintText: 'Client or company name',
                        ),
                      ),
                      const SizedBox(height: 18),
                      _LabeledField(
                        label: 'Category',
                        child: AppDropdownField<String>(
                          value: _selectedCategory,
                          items: _categories,
                          hintText: 'Select category',
                          onChanged: (value) =>
                              setState(() => _selectedCategory = value),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: _LabeledField(
                              label: 'Start date',
                              child: AppDateField(
                                label: _formatDate(_startDate),
                                hasValue: _startDate != null,
                                onTap: () => _pickDate(isStart: true),
                                leading: SvgPicture.asset(
                                  'assets/images/calendar_2.svg',
                                  width: 22,
                                  height: 22,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _LabeledField(
                              label: 'End date',
                              child: AppDateField(
                                label: _formatDate(_endDate),
                                hasValue: _endDate != null,
                                onTap: () => _pickDate(isStart: false),
                                leading: SvgPicture.asset(
                                  'assets/images/calendar_2.svg',
                                  width: 22,
                                  height: 22,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _LabeledField(
                        label: 'Description (optional)',
                        child: AppFormTextField(
                          controller: _descriptionController,
                          hintText: 'Add a short brief for your team...',
                          maxLines: 4,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _SectionHeader(
                        title: 'Invite team members',
                        description: 'Assign roles to control access.',
                      ),
                      const SizedBox(height: 14),
                      AppFormTextField(
                        controller: _inviteController,
                        hintText: 'Email address',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: ['Admin', 'Collaborator', 'Viewer']
                            .map(
                              (role) => _RoleChip(
                                label: role,
                                selected: _selectedRole == role,
                                onTap: () =>
                                    setState(() => _selectedRole = role),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 14),
                      Align(
                        alignment: Alignment.centerRight,
                        child: GradientButton(
                          onPressed: _addInvitee,
                          text: 'Add member',
                          width: 160,
                          height: 40,
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
                                    '${invite.email} • ${invite.role}',
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
                                          'Invite external collaborator',
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
                                          'Send a secure link via email or WhatsApp for limited access.',
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
                            'Preview link: https://rush.manage/invite/${DateTime.now().millisecondsSinceEpoch}',
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
                            text: 'Create project',
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
