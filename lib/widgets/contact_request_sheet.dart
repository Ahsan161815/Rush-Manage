import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

import 'package:myapp/app/app_theme.dart';
import 'package:myapp/app/widgets/gradient_button.dart';
import 'package:myapp/app/widgets/app_form_fields.dart';
import 'package:myapp/common/models/contact_form_models.dart';

class ContactRequestSheet extends StatefulWidget {
  const ContactRequestSheet({
    super.key,
    this.contactId,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.addressController,
    required this.typeController,
    required this.notesController,
    this.mode = ContactFormMode.create,
    this.bottomInset = 0,
  });

  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController addressController;
  final TextEditingController typeController;
  final TextEditingController notesController;
  final ContactFormMode mode;
  final double bottomInset;
  final String? contactId;

  @override
  State<ContactRequestSheet> createState() => _ContactRequestSheetState();
}

class _ContactRequestSheetState extends State<ContactRequestSheet> {
  static const List<String> _contactTypeOptions = [
    'client',
    'collaborator',
    'supplier',
  ];

  String? _selectedTypeValue;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final initialType = widget.typeController.text.trim();
    _selectedTypeValue = _normalizeType(initialType);
    if (_selectedTypeValue != null) {
      widget.typeController.text = _selectedTypeValue!;
    }
  }

  void _onSubmit() {
    if (_isSubmitting) {
      return;
    }
    setState(() => _isSubmitting = true);
    FocusScope.of(context).unfocus();
    final data = ContactFormData(
      name: widget.nameController.text.trim().isEmpty
          ? null
          : widget.nameController.text.trim(),
      email: widget.emailController.text.trim().isEmpty
          ? null
          : widget.emailController.text.trim(),
      phone: widget.phoneController.text.trim().isEmpty
          ? null
          : widget.phoneController.text.trim(),
      address: widget.addressController.text.trim().isEmpty
          ? null
          : widget.addressController.text.trim(),
      type: _selectedTypeValue,
      notes: widget.notesController.text.trim().isEmpty
          ? null
          : widget.notesController.text.trim(),
    );
    if (!Navigator.of(context).canPop()) {
      setState(() => _isSubmitting = false);
      return;
    }
    Navigator.of(context).pop(
      ContactFormSubmission(
        mode: widget.mode,
        data: data,
        contactId: widget.contactId,
      ),
    );
  }

  void _handleTypeChanged(String? value) {
    setState(() {
      _selectedTypeValue = value;
      widget.typeController.text = value ?? '';
    });
  }

  String? _normalizeType(String value) {
    final normalized = value.toLowerCase();
    return switch (normalized) {
      'client' => 'client',
      'collaborator' => 'collaborator',
      'supplier' => 'supplier',
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEdit = widget.mode == ContactFormMode.edit;
    final titleText = isEdit ? 'Edit contact' : 'Add contact';
    final buttonLabel = isEdit ? 'Save changes' : 'Save contact';

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.secondaryBackground,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 28,
              offset: Offset(0, 16),
            ),
          ],
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(24, 28, 24, 24 + widget.bottomInset),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      titleText,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: AppColors.secondaryText,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      }
                    },
                    icon: const Icon(
                      FeatherIcons.x,
                      color: AppColors.hintTextfiled,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Log context so future teammates know who this person is and how to reach them.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.hintTextfiled,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 22),
              _ContactSheetField(
                label: 'Full name',
                hintText: 'e.g. Sarah Collins',
                controller: widget.nameController,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 18),
              _ContactSheetField(
                label: 'Work email',
                hintText: 'name@company.com',
                controller: widget.emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 18),
              _ContactSheetField(
                label: 'Phone number',
                hintText: '+1 (555) 123-9800',
                controller: widget.phoneController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 18),
              _ContactSheetField(
                label: 'Address / Region',
                hintText: 'City, state or country',
                controller: widget.addressController,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 18),
              Text(
                'Contact type',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: AppColors.secondaryText,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              AppDropdownField<String>(
                items: _contactTypeOptions,
                value: _selectedTypeValue,
                hintText: 'Select type',
                labelBuilder: (value) => switch (value) {
                  'client' => 'Client',
                  'supplier' => 'Supplier',
                  _ => 'Collaborator',
                },
                onChanged: _handleTypeChanged,
              ),
              const SizedBox(height: 22),
              _ContactSheetField(
                label: 'Notes',
                hintText: 'Reminders, relationship details, availability…',
                controller: widget.notesController,
                maxLines: 4,
              ),
              const SizedBox(height: 28),
              GradientButton(
                onPressed: _onSubmit,
                text: buttonLabel,
                height: 52,
                width: double.infinity,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactSheetField extends StatelessWidget {
  const _ContactSheetField({
    required this.label,
    required this.hintText,
    required this.controller,
    this.keyboardType,
    this.maxLines = 1,
    this.textCapitalization = TextCapitalization.none,
  });

  final String label;
  final String hintText;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final int maxLines;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            color: AppColors.secondaryText,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          textCapitalization: textCapitalization,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              color: AppColors.hintTextfiled,
              fontWeight: FontWeight.w600,
            ),
            filled: true,
            fillColor: AppColors.textfieldBackground,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
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
          ),
        ),
      ],
    );
  }
}
