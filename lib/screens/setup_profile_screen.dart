import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:go_router/go_router.dart';

import 'package:myapp/app/app_theme.dart';
import 'package:myapp/app/widgets/gradient_button.dart';
import 'package:myapp/widgets/custom_text_field.dart';

class SetupProfileScreen extends StatefulWidget {
  const SetupProfileScreen({super.key});

  @override
  State<SetupProfileScreen> createState() => _SetupProfileScreenState();
}

class _SetupProfileScreenState extends State<SetupProfileScreen> {
  late final TextEditingController _fullNameController;
  late final TextEditingController _roleController;
  late final TextEditingController _locationController;
  String? _selectedFocusArea;

  static const List<String> _focusAreaSuggestions = <String>[
    'Planning',
    'Engineering',
    'Finance',
    'Logistics',
  ];

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _roleController = TextEditingController();
    _locationController = TextEditingController();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _roleController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _selectFocusArea(String value) {
    setState(() {
      _selectedFocusArea = _selectedFocusArea == value ? null : value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.secondaryText),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Set up profile',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.secondaryText,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Personalise your workspace',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.secondaryText,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Add a face, role, and focus areas so teammates know who you are.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.hintTextfiled,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 32),
              _AvatarPicker(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Image picker coming soon.')),
                  );
                },
              ),
              const SizedBox(height: 32),
              CustomTextField(
                hintText: 'Full Name',
                iconPath: 'assets/images/fullname.svg',
                controller: _fullNameController,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                hintText: 'Role / Title',
                iconPath: 'assets/images/user_profile.svg',
                controller: _roleController,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                hintText: 'Location',
                iconPath: 'assets/images/calendar_2.svg',
                controller: _locationController,
              ),
              const SizedBox(height: 28),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Focus areas',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.secondaryText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _focusAreaSuggestions
                    .map(
                      (suggestion) => _FocusChip(
                        label: suggestion,
                        selected: _selectedFocusArea == suggestion,
                        onSelected: () => _selectFocusArea(suggestion),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 36),
              GradientButton(
                onPressed: () => context.goNamed('dashboard'),
                text: 'Finish Setup',
                width: double.infinity,
                height: 52,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.goNamed('dashboard'),
                child: Text(
                  'Skip for now',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.hintTextfiled,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvatarPicker extends StatelessWidget {
  const _AvatarPicker({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        height: 120,
        padding: const EdgeInsets.all(4),
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
            border: Border.all(
              color: AppColors.textfieldBorder.withValues(alpha: 0.4),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                Icons.camera_alt_outlined,
                color: AppColors.hintTextfiled,
                size: 28,
              ),
              SizedBox(height: 8),
              Text(
                'Upload photo',
                style: TextStyle(
                  color: AppColors.hintTextfiled,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FocusChip extends StatelessWidget {
  const _FocusChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onSelected,
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
          color: selected ? null : AppColors.textfieldBackground,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected
                ? Colors.transparent
                : AppColors.textfieldBorder.withValues(alpha: 0.45),
            width: 1.2,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.secondary.withValues(alpha: 0.18),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style:
                  (textTheme.bodyMedium ??
                          textTheme.bodySmall ??
                          const TextStyle())
                      .copyWith(
                        color: selected
                            ? AppColors.primaryText
                            : AppColors.secondaryText,
                        fontWeight: FontWeight.bold,
                      ),
            ),
            if (selected) ...[
              const SizedBox(width: 8),
              const Icon(
                FeatherIcons.check,
                size: 16,
                color: AppColors.primaryText,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
