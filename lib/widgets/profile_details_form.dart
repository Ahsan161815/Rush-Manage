import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:myapp/app/app_theme.dart';
import 'package:myapp/app/widgets/gradient_button.dart';
import 'package:myapp/common/localization/l10n_extensions.dart';
import 'package:myapp/controllers/user_controller.dart';
import 'package:myapp/common/models/user.dart';
import 'package:myapp/l10n/app_localizations.dart';
import 'package:myapp/models/industry.dart';
import 'package:myapp/services/auth_service.dart';
import 'package:myapp/widgets/custom_text_field.dart';

class ProfileDetailsForm extends StatefulWidget {
  const ProfileDetailsForm({
    super.key,
    required this.title,
    required this.headline,
    required this.subtitle,
    required this.primaryButtonLabel,
    required this.onSubmitSuccess,
    this.skipButtonLabel,
    this.onSkip,
    this.showIndustrySection = true,
  });

  final String title;
  final String headline;
  final String subtitle;
  final String primaryButtonLabel;
  final Future<void> Function(BuildContext context) onSubmitSuccess;
  final String? skipButtonLabel;
  final VoidCallback? onSkip;
  final bool showIndustrySection;

  @override
  State<ProfileDetailsForm> createState() => _ProfileDetailsFormState();
}

class _ProfileDetailsFormState extends State<ProfileDetailsForm> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  XFile? _avatarFile;
  Uint8List? _avatarPreview;
  String? _avatarUrl;
  _FocusArea? _selectedFocusArea;
  IndustryKey? _selectedIndustry;
  _CountryDialCode _selectedCountry = _defaultCountryDialCode;
  bool _isSaving = false;
  bool _didHydrateProfile = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _roleController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _hydrateFromProfile(UserProfile? profile) {
    if (profile == null || _didHydrateProfile) {
      return;
    }
    _fullNameController.text = profile.fullName;
    _roleController.text = profile.roleTitle ?? '';
    _locationController.text = profile.location ?? '';
    _hydratePhone(profile.phone);
    _selectedFocusArea = _focusAreaFromKey(profile.focusArea);
    _avatarUrl = profile.avatarUrl;
    _didHydrateProfile = true;
  }

  _FocusArea? _focusAreaFromKey(String? key) {
    if (key == null || key.isEmpty) {
      return null;
    }
    for (final area in _FocusArea.values) {
      if (area.name == key) {
        return area;
      }
    }
    return null;
  }

  void _hydratePhone(String? phone) {
    final trimmed = phone?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      _phoneController.clear();
      return;
    }
    final match = _matchCountryByDialCode(trimmed);
    if (match != null) {
      _selectedCountry = match;
      final remainder = trimmed.substring(match.dialCode.length).trimLeft();
      _phoneController.text = remainder;
      return;
    }
    _phoneController.text = trimmed;
  }

  _CountryDialCode? _matchCountryByDialCode(String phone) {
    _CountryDialCode? match;
    for (final entry in _countryDialCodes) {
      if (phone.startsWith(entry.dialCode)) {
        if (match == null || entry.dialCode.length > match.dialCode.length) {
          match = entry;
        }
      }
    }
    return match;
  }

  Future<void> _pickImage() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null) {
      return;
    }
    final bytes = await picked.readAsBytes();
    setState(() {
      _avatarFile = picked;
      _avatarPreview = bytes;
    });
  }

  Future<void> _submitProfile() async {
    final loc = context.l10n;
    final errorMessage = _validateFields(loc);
    if (errorMessage != null) {
      _showMessage(errorMessage);
      return;
    }

    final authService = context.read<AuthService>();
    final userController = context.read<UserController>();

    FocusScope.of(context).unfocus();
    setState(() => _isSaving = true);

    try {
      final avatarUrl = await _ensureAvatarUrl();
      final existingPhone = userController.profile?.phone;
      final composedPhone = _composePhoneNumber(existingPhone);
      await authService.completeProfile(
        fullName: _fullNameController.text.trim(),
        avatarUrl: avatarUrl,
        roleTitle: _roleController.text.trim(),
        location: _locationController.text.trim(),
        focusArea: _selectedFocusArea!.name,
        industry: widget.showIndustrySection ? _selectedIndustry! : null,
        phone: composedPhone,
      );
      await userController.loadProfile();
      if (!mounted) {
        return;
      }
      await widget.onSubmitSuccess(context);
    } on AuthException catch (error) {
      _showMessage(error.message);
    } catch (_) {
      _showMessage(loc.profileErrorGeneric);
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  String? _validateFields(AppLocalizations loc) {
    if (_fullNameController.text.trim().isEmpty) {
      return loc.profileErrorFullName;
    }
    if (_roleController.text.trim().isEmpty) {
      return loc.profileErrorRole;
    }
    if (_locationController.text.trim().isEmpty) {
      return loc.profileErrorLocation;
    }
    if (_selectedFocusArea == null) {
      return loc.profileErrorFocus;
    }
    if (widget.showIndustrySection && _selectedIndustry == null) {
      return loc.profileErrorIndustry;
    }
    if ((_avatarFile == null) && (_avatarUrl == null || _avatarUrl!.isEmpty)) {
      return loc.profileErrorAvatar;
    }
    return null;
  }

  String? _composePhoneNumber(String? existingPhone) {
    final trimmedInput = _phoneController.text.trim();
    if (trimmedInput.isEmpty) {
      final normalizedExisting = existingPhone?.trim() ?? '';
      return normalizedExisting.isEmpty ? null : '';
    }
    return '${_selectedCountry.dialCode} $trimmedInput';
  }

  Future<String> _ensureAvatarUrl() async {
    if (_avatarFile == null) {
      if (_avatarUrl != null && _avatarUrl!.isNotEmpty) {
        return _avatarUrl!;
      }
      throw const AuthException('Please add a profile photo.');
    }

    final client = Supabase.instance.client;
    if (client.auth.currentUser == null) {
      throw const AuthException('User not authenticated');
    }

    const bucketName = 'avatars';
    const folderPrefix = 'avatars';
    final bytes = await _avatarFile!.readAsBytes();
    final extension = _extensionForFile(_avatarFile!);
    final objectPath =
        '$folderPrefix/profile_${DateTime.now().millisecondsSinceEpoch}$extension';
    final mimeType =
        lookupMimeType(_avatarFile!.name, headerBytes: bytes) ?? 'image/jpeg';

    final storageBucket = client.storage.from(bucketName);
    try {
      await storageBucket.uploadBinary(
        objectPath,
        bytes,
        fileOptions: FileOptions(upsert: true, contentType: mimeType),
      );
    } on StorageException catch (error, stackTrace) {
      debugPrint('Avatar upload failed: ${error.message}\n$stackTrace');
      throw AuthException(error.message);
    }
    final publicUrl = storageBucket.getPublicUrl(objectPath);
    _avatarUrl = publicUrl;
    return publicUrl;
  }

  String _extensionForFile(XFile file) {
    final name = file.name;
    final dotIndex = name.lastIndexOf('.');
    if (dotIndex == -1) {
      return '.jpg';
    }
    return name.substring(dotIndex);
  }

  void _showMessage(String message) {
    if (!mounted || message.isEmpty) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.l10n;
    final profile = context.watch<UserController>().profile;
    _hydrateFromProfile(profile);
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
          widget.title,
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
                widget.headline,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.secondaryText,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.subtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.hintTextfiled,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 32),
              _AvatarPicker(
                onTap: _pickImage,
                label: loc.commonUploadPhoto,
                previewBytes: _avatarPreview,
                imageUrl: _avatarUrl,
              ),
              const SizedBox(height: 32),
              CustomTextField(
                hintText: loc.commonFullName,
                iconPath: 'assets/images/fullname.svg',
                controller: _fullNameController,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                hintText: loc.commonRoleTitle,
                iconPath: 'assets/images/user_profile.svg',
                controller: _roleController,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                hintText: loc.commonLocation,
                iconPath: 'assets/images/calendar_2.svg',
                controller: _locationController,
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  loc.profilePhoneLabel,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.secondaryText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  const double gap = 12.0;
                  const double dropdownBoost = 32.0;
                  const double minDropdownWidth = 140.0;
                  final double available = constraints.maxWidth - gap;
                  if (available <= 0) {
                    return const SizedBox.shrink();
                  }

                  final double dropdownBase = available * 4 / 13;
                  final double phoneBase = available - dropdownBase;
                  double phoneWidth = phoneBase - dropdownBoost;
                  if (phoneWidth < 0) {
                    phoneWidth = 0;
                  }
                  double dropdownWidth = available - phoneWidth;
                  if (dropdownWidth < minDropdownWidth) {
                    dropdownWidth = minDropdownWidth;
                    phoneWidth = available - dropdownWidth;
                    if (phoneWidth < 0) {
                      phoneWidth = 0;
                    }
                  }

                  return Row(
                    children: [
                      SizedBox(
                        width: dropdownWidth,
                        child: _CountryDialCodeDropdown(
                          selected: _selectedCountry,
                          onChanged: (value) {
                            setState(() => _selectedCountry = value);
                          },
                        ),
                      ),
                      const SizedBox(width: gap),
                      SizedBox(
                        width: phoneWidth,
                        child: CustomTextField(
                          widthFactor: 1,
                          hintText: loc.profilePhoneLabel,
                          iconPath: 'assets/images/phone_call.svg',
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 28),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  loc.commonFocusAreas,
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
                children: _FocusArea.values
                    .map(
                      (area) => _FocusChip(
                        label: _focusAreaLabel(loc, area),
                        selected: _selectedFocusArea == area,
                        onSelected: () => setState(() {
                          _selectedFocusArea = _selectedFocusArea == area
                              ? null
                              : area;
                        }),
                      ),
                    )
                    .toList(),
              ),
              if (widget.showIndustrySection) ...[
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    loc.setupIndustrySectionTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.secondaryText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  loc.setupIndustrySectionSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.hintTextfiled,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: IndustryKey.values
                      .map(
                        (industry) => _IndustryChip(
                          label: _industryLabel(loc, industry),
                          selected: _selectedIndustry == industry,
                          onSelected: () => setState(() {
                            _selectedIndustry = _selectedIndustry == industry
                                ? null
                                : industry;
                          }),
                        ),
                      )
                      .toList(),
                ),
              ],
              const SizedBox(height: 36),
              GradientButton(
                onPressed: () {
                  if (_isSaving) {
                    return;
                  }
                  _submitProfile();
                },
                text: widget.primaryButtonLabel,
                width: double.infinity,
                height: 52,
                isLoading: _isSaving,
              ),
              if (widget.skipButtonLabel != null && widget.onSkip != null) ...[
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _isSaving ? null : () => widget.onSkip?.call(),
                  child: Text(
                    widget.skipButtonLabel!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.hintTextfiled,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _focusAreaLabel(AppLocalizations loc, _FocusArea area) {
    return switch (area) {
      _FocusArea.planning => loc.commonFocusPlanning,
      _FocusArea.engineering => loc.commonFocusEngineering,
      _FocusArea.finance => loc.commonFocusFinance,
      _FocusArea.logistics => loc.commonFocusLogistics,
    };
  }

  String _industryLabel(AppLocalizations loc, IndustryKey industry) {
    return switch (industry) {
      IndustryKey.core => loc.setupIndustryOptionCore,
      IndustryKey.caterer => loc.setupIndustryOptionCaterer,
    };
  }
}

class _AvatarPicker extends StatelessWidget {
  const _AvatarPicker({
    required this.onTap,
    required this.label,
    this.previewBytes,
    this.imageUrl,
  });

  final VoidCallback onTap;
  final String label;
  final Uint8List? previewBytes;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    Widget avatar;
    if (previewBytes != null) {
      avatar = ClipOval(
        child: Image.memory(
          previewBytes!,
          fit: BoxFit.cover,
          width: 112,
          height: 112,
        ),
      );
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      avatar = ClipOval(
        child: Image.network(
          imageUrl!,
          fit: BoxFit.cover,
          width: 112,
          height: 112,
          errorBuilder: (_, __, ___) => _fallback(label),
        ),
      );
    } else {
      avatar = _fallback(label);
    }

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
          child: Center(child: avatar),
        ),
      ),
    );
  }

  Widget _fallback(String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.camera_alt_outlined,
          color: AppColors.hintTextfiled,
          size: 28,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.hintTextfiled,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

enum _FocusArea { planning, engineering, finance, logistics }

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

class _IndustryChip extends StatelessWidget {
  const _IndustryChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelected,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.secondary.withValues(alpha: 0.12)
              : AppColors.textfieldBackground,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? AppColors.secondary : AppColors.textfieldBorder,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: selected ? AppColors.secondary : AppColors.secondaryText,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _CountryDialCodeDropdown extends StatefulWidget {
  const _CountryDialCodeDropdown({
    required this.selected,
    required this.onChanged,
  });

  final _CountryDialCode selected;
  final ValueChanged<_CountryDialCode> onChanged;

  @override
  State<_CountryDialCodeDropdown> createState() =>
      _CountryDialCodeDropdownState();
}

class _CountryDialCodeDropdownState extends State<_CountryDialCodeDropdown> {
  Future<void> _openPicker() async {
    final selected = await showModalBottomSheet<_CountryDialCode>(
      context: context,
      constraints: const BoxConstraints(maxHeight: 400),
      builder: (context) =>
          _CountryPickerSheet(initialSelection: widget.selected),
    );
    if (selected != null) {
      widget.onChanged(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(40),
        onTap: _openPicker,
        child: Container(
          height: 52,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.textfieldBackground,
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: AppColors.textfieldBorder, width: 1.5),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _FlagBadge(country: widget.selected),
              const SizedBox(width: 8),
              Text(
                widget.selected.dialCode,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.secondaryText,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.hintTextfiled,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CountryPickerSheet extends StatefulWidget {
  const _CountryPickerSheet({required this.initialSelection});

  final _CountryDialCode initialSelection;

  @override
  State<_CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<_CountryPickerSheet> {
  late TextEditingController _searchController;
  late List<_CountryDialCode> _filteredCountries;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredCountries = List<_CountryDialCode>.from(_countryDialCodes);
    _searchController.addListener(_handleSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_handleSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredCountries = List<_CountryDialCode>.from(_countryDialCodes);
        return;
      }
      _filteredCountries = _countryDialCodes.where((country) {
        final name = country.countryName.toLowerCase();
        final iso = country.isoCode.toLowerCase();
        return name.contains(query) ||
            iso.contains(query) ||
            country.dialCode.contains(query);
      }).toList();
    });
  }

  void _selectCountry(_CountryDialCode country) {
    Navigator.of(context).pop(country);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SafeArea(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 400),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search country or dial code',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: AppColors.textfieldBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppColors.textfieldBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.secondary),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 0,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Scrollbar(
                  child: ListView.builder(
                    itemCount: _filteredCountries.length,
                    itemBuilder: (context, index) {
                      final country = _filteredCountries[index];
                      final isSelected =
                          country.isoCode == widget.initialSelection.isoCode &&
                          country.dialCode == widget.initialSelection.dialCode;
                      return _CountryPickerTile(
                        country: country,
                        isSelected: isSelected,
                        textTheme: textTheme,
                        onTap: () => _selectCountry(country),
                      );
                    },
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

class _CountryPickerTile extends StatelessWidget {
  const _CountryPickerTile({
    required this.country,
    required this.isSelected,
    required this.textTheme,
    required this.onTap,
  });

  final _CountryDialCode country;
  final bool isSelected;
  final TextTheme textTheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            _FlagBadge(country: country),
            const SizedBox(width: 12),
            Text(
              country.dialCode,
              style: textTheme.titleMedium?.copyWith(
                color: AppColors.secondaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              country.isoCode,
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.hintTextfiled,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check, color: AppColors.secondary, size: 20),
          ],
        ),
      ),
    );
  }
}

class _FlagBadge extends StatelessWidget {
  const _FlagBadge({required this.country});

  final _CountryDialCode country;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.textfieldBackground,
        border: Border.all(
          color: AppColors.textfieldBorder.withValues(alpha: 0.5),
        ),
      ),
      alignment: Alignment.center,
      child: Text(country.flagEmoji, style: const TextStyle(fontSize: 18)),
    );
  }
}

class _CountryDialCode {
  const _CountryDialCode({
    required this.countryName,
    required this.isoCode,
    required this.dialCode,
  });

  final String countryName;
  final String isoCode;
  final String dialCode;

  String get flagEmoji => _flagEmojiFromIso(isoCode);
}

const List<_CountryDialCode> _countryDialCodes = [
  _CountryDialCode(countryName: 'Canada', isoCode: 'CA', dialCode: '+1'),
  _CountryDialCode(countryName: 'United States', isoCode: 'US', dialCode: '+1'),
  _CountryDialCode(countryName: 'Kazakhstan', isoCode: 'KZ', dialCode: '+7'),
  _CountryDialCode(countryName: 'Russia', isoCode: 'RU', dialCode: '+7'),
  _CountryDialCode(countryName: 'Egypt', isoCode: 'EG', dialCode: '+20'),
  _CountryDialCode(countryName: 'South Africa', isoCode: 'ZA', dialCode: '+27'),
  _CountryDialCode(countryName: 'Greece', isoCode: 'GR', dialCode: '+30'),
  _CountryDialCode(countryName: 'Netherlands', isoCode: 'NL', dialCode: '+31'),
  _CountryDialCode(countryName: 'Belgium', isoCode: 'BE', dialCode: '+32'),
  _CountryDialCode(countryName: 'France', isoCode: 'FR', dialCode: '+33'),
  _CountryDialCode(countryName: 'Spain', isoCode: 'ES', dialCode: '+34'),
  _CountryDialCode(countryName: 'Hungary', isoCode: 'HU', dialCode: '+36'),
  _CountryDialCode(countryName: 'Italy', isoCode: 'IT', dialCode: '+39'),
  _CountryDialCode(countryName: 'Vatican City', isoCode: 'VA', dialCode: '+39'),
  _CountryDialCode(countryName: 'Romania', isoCode: 'RO', dialCode: '+40'),
  _CountryDialCode(countryName: 'Switzerland', isoCode: 'CH', dialCode: '+41'),
  _CountryDialCode(countryName: 'Austria', isoCode: 'AT', dialCode: '+43'),
  _CountryDialCode(
    countryName: 'United Kingdom',
    isoCode: 'GB',
    dialCode: '+44',
  ),
  _CountryDialCode(countryName: 'Denmark', isoCode: 'DK', dialCode: '+45'),
  _CountryDialCode(countryName: 'Sweden', isoCode: 'SE', dialCode: '+46'),
  _CountryDialCode(countryName: 'Norway', isoCode: 'NO', dialCode: '+47'),
  _CountryDialCode(countryName: 'Poland', isoCode: 'PL', dialCode: '+48'),
  _CountryDialCode(countryName: 'Germany', isoCode: 'DE', dialCode: '+49'),
  _CountryDialCode(countryName: 'Peru', isoCode: 'PE', dialCode: '+51'),
  _CountryDialCode(countryName: 'Mexico', isoCode: 'MX', dialCode: '+52'),
  _CountryDialCode(countryName: 'Cuba', isoCode: 'CU', dialCode: '+53'),
  _CountryDialCode(countryName: 'Argentina', isoCode: 'AR', dialCode: '+54'),
  _CountryDialCode(countryName: 'Brazil', isoCode: 'BR', dialCode: '+55'),
  _CountryDialCode(countryName: 'Chile', isoCode: 'CL', dialCode: '+56'),
  _CountryDialCode(countryName: 'Colombia', isoCode: 'CO', dialCode: '+57'),
  _CountryDialCode(countryName: 'Venezuela', isoCode: 'VE', dialCode: '+58'),
  _CountryDialCode(countryName: 'Malaysia', isoCode: 'MY', dialCode: '+60'),
  _CountryDialCode(countryName: 'Australia', isoCode: 'AU', dialCode: '+61'),
  _CountryDialCode(countryName: 'Indonesia', isoCode: 'ID', dialCode: '+62'),
  _CountryDialCode(countryName: 'Philippines', isoCode: 'PH', dialCode: '+63'),
  _CountryDialCode(countryName: 'New Zealand', isoCode: 'NZ', dialCode: '+64'),
  _CountryDialCode(countryName: 'Singapore', isoCode: 'SG', dialCode: '+65'),
  _CountryDialCode(countryName: 'Thailand', isoCode: 'TH', dialCode: '+66'),
  _CountryDialCode(countryName: 'Japan', isoCode: 'JP', dialCode: '+81'),
  _CountryDialCode(countryName: 'South Korea', isoCode: 'KR', dialCode: '+82'),
  _CountryDialCode(countryName: 'Vietnam', isoCode: 'VN', dialCode: '+84'),
  _CountryDialCode(countryName: 'China', isoCode: 'CN', dialCode: '+86'),
  _CountryDialCode(countryName: 'Turkey', isoCode: 'TR', dialCode: '+90'),
  _CountryDialCode(countryName: 'India', isoCode: 'IN', dialCode: '+91'),
  _CountryDialCode(countryName: 'Pakistan', isoCode: 'PK', dialCode: '+92'),
  _CountryDialCode(countryName: 'Afghanistan', isoCode: 'AF', dialCode: '+93'),
  _CountryDialCode(countryName: 'Sri Lanka', isoCode: 'LK', dialCode: '+94'),
  _CountryDialCode(countryName: 'Myanmar', isoCode: 'MM', dialCode: '+95'),
  _CountryDialCode(countryName: 'Iran', isoCode: 'IR', dialCode: '+98'),
  _CountryDialCode(countryName: 'South Sudan', isoCode: 'SS', dialCode: '+211'),
  _CountryDialCode(countryName: 'Morocco', isoCode: 'MA', dialCode: '+212'),
  _CountryDialCode(countryName: 'Algeria', isoCode: 'DZ', dialCode: '+213'),
  _CountryDialCode(countryName: 'Tunisia', isoCode: 'TN', dialCode: '+216'),
  _CountryDialCode(countryName: 'Libya', isoCode: 'LY', dialCode: '+218'),
  _CountryDialCode(countryName: 'Gambia', isoCode: 'GM', dialCode: '+220'),
  _CountryDialCode(countryName: 'Senegal', isoCode: 'SN', dialCode: '+221'),
  _CountryDialCode(countryName: 'Mauritania', isoCode: 'MR', dialCode: '+222'),
  _CountryDialCode(countryName: 'Mali', isoCode: 'ML', dialCode: '+223'),
  _CountryDialCode(countryName: 'Guinea', isoCode: 'GN', dialCode: '+224'),
  _CountryDialCode(
    countryName: 'Cote d\'Ivoire',
    isoCode: 'CI',
    dialCode: '+225',
  ),
  _CountryDialCode(
    countryName: 'Burkina Faso',
    isoCode: 'BF',
    dialCode: '+226',
  ),
  _CountryDialCode(countryName: 'Niger', isoCode: 'NE', dialCode: '+227'),
  _CountryDialCode(countryName: 'Togo', isoCode: 'TG', dialCode: '+228'),
  _CountryDialCode(countryName: 'Benin', isoCode: 'BJ', dialCode: '+229'),
  _CountryDialCode(countryName: 'Mauritius', isoCode: 'MU', dialCode: '+230'),
  _CountryDialCode(countryName: 'Liberia', isoCode: 'LR', dialCode: '+231'),
  _CountryDialCode(
    countryName: 'Sierra Leone',
    isoCode: 'SL',
    dialCode: '+232',
  ),
  _CountryDialCode(countryName: 'Ghana', isoCode: 'GH', dialCode: '+233'),
  _CountryDialCode(countryName: 'Nigeria', isoCode: 'NG', dialCode: '+234'),
  _CountryDialCode(countryName: 'Chad', isoCode: 'TD', dialCode: '+235'),
  _CountryDialCode(
    countryName: 'Central African Republic',
    isoCode: 'CF',
    dialCode: '+236',
  ),
  _CountryDialCode(countryName: 'Cameroon', isoCode: 'CM', dialCode: '+237'),
  _CountryDialCode(countryName: 'Cape Verde', isoCode: 'CV', dialCode: '+238'),
  _CountryDialCode(
    countryName: 'Sao Tome and Principe',
    isoCode: 'ST',
    dialCode: '+239',
  ),
  _CountryDialCode(
    countryName: 'Equatorial Guinea',
    isoCode: 'GQ',
    dialCode: '+240',
  ),
  _CountryDialCode(countryName: 'Gabon', isoCode: 'GA', dialCode: '+241'),
  _CountryDialCode(countryName: 'Congo', isoCode: 'CG', dialCode: '+242'),
  _CountryDialCode(countryName: 'Congo (DRC)', isoCode: 'CD', dialCode: '+243'),
  _CountryDialCode(countryName: 'Angola', isoCode: 'AO', dialCode: '+244'),
  _CountryDialCode(
    countryName: 'Guinea-Bissau',
    isoCode: 'GW',
    dialCode: '+245',
  ),
  _CountryDialCode(countryName: 'Seychelles', isoCode: 'SC', dialCode: '+248'),
  _CountryDialCode(countryName: 'Sudan', isoCode: 'SD', dialCode: '+249'),
  _CountryDialCode(countryName: 'Rwanda', isoCode: 'RW', dialCode: '+250'),
  _CountryDialCode(countryName: 'Ethiopia', isoCode: 'ET', dialCode: '+251'),
  _CountryDialCode(countryName: 'Somalia', isoCode: 'SO', dialCode: '+252'),
  _CountryDialCode(countryName: 'Djibouti', isoCode: 'DJ', dialCode: '+253'),
  _CountryDialCode(countryName: 'Kenya', isoCode: 'KE', dialCode: '+254'),
  _CountryDialCode(countryName: 'Tanzania', isoCode: 'TZ', dialCode: '+255'),
  _CountryDialCode(countryName: 'Uganda', isoCode: 'UG', dialCode: '+256'),
  _CountryDialCode(countryName: 'Burundi', isoCode: 'BI', dialCode: '+257'),
  _CountryDialCode(countryName: 'Mozambique', isoCode: 'MZ', dialCode: '+258'),
  _CountryDialCode(countryName: 'Zambia', isoCode: 'ZM', dialCode: '+260'),
  _CountryDialCode(countryName: 'Madagascar', isoCode: 'MG', dialCode: '+261'),
  _CountryDialCode(countryName: 'Zimbabwe', isoCode: 'ZW', dialCode: '+263'),
  _CountryDialCode(countryName: 'Namibia', isoCode: 'NA', dialCode: '+264'),
  _CountryDialCode(countryName: 'Malawi', isoCode: 'MW', dialCode: '+265'),
  _CountryDialCode(countryName: 'Lesotho', isoCode: 'LS', dialCode: '+266'),
  _CountryDialCode(countryName: 'Botswana', isoCode: 'BW', dialCode: '+267'),
  _CountryDialCode(countryName: 'Eswatini', isoCode: 'SZ', dialCode: '+268'),
  _CountryDialCode(countryName: 'Comoros', isoCode: 'KM', dialCode: '+269'),
  _CountryDialCode(countryName: 'Eritrea', isoCode: 'ER', dialCode: '+291'),
  _CountryDialCode(countryName: 'Aruba', isoCode: 'AW', dialCode: '+297'),
  _CountryDialCode(countryName: 'Portugal', isoCode: 'PT', dialCode: '+351'),
  _CountryDialCode(countryName: 'Luxembourg', isoCode: 'LU', dialCode: '+352'),
  _CountryDialCode(countryName: 'Ireland', isoCode: 'IE', dialCode: '+353'),
  _CountryDialCode(countryName: 'Iceland', isoCode: 'IS', dialCode: '+354'),
  _CountryDialCode(countryName: 'Albania', isoCode: 'AL', dialCode: '+355'),
  _CountryDialCode(countryName: 'Malta', isoCode: 'MT', dialCode: '+356'),
  _CountryDialCode(countryName: 'Cyprus', isoCode: 'CY', dialCode: '+357'),
  _CountryDialCode(countryName: 'Finland', isoCode: 'FI', dialCode: '+358'),
  _CountryDialCode(countryName: 'Bulgaria', isoCode: 'BG', dialCode: '+359'),
  _CountryDialCode(countryName: 'Lithuania', isoCode: 'LT', dialCode: '+370'),
  _CountryDialCode(countryName: 'Latvia', isoCode: 'LV', dialCode: '+371'),
  _CountryDialCode(countryName: 'Estonia', isoCode: 'EE', dialCode: '+372'),
  _CountryDialCode(countryName: 'Moldova', isoCode: 'MD', dialCode: '+373'),
  _CountryDialCode(countryName: 'Armenia', isoCode: 'AM', dialCode: '+374'),
  _CountryDialCode(countryName: 'Belarus', isoCode: 'BY', dialCode: '+375'),
  _CountryDialCode(countryName: 'Andorra', isoCode: 'AD', dialCode: '+376'),
  _CountryDialCode(countryName: 'Monaco', isoCode: 'MC', dialCode: '+377'),
  _CountryDialCode(countryName: 'San Marino', isoCode: 'SM', dialCode: '+378'),
  _CountryDialCode(countryName: 'Ukraine', isoCode: 'UA', dialCode: '+380'),
  _CountryDialCode(countryName: 'Serbia', isoCode: 'RS', dialCode: '+381'),
  _CountryDialCode(countryName: 'Montenegro', isoCode: 'ME', dialCode: '+382'),
  _CountryDialCode(countryName: 'Croatia', isoCode: 'HR', dialCode: '+385'),
  _CountryDialCode(countryName: 'Slovenia', isoCode: 'SI', dialCode: '+386'),
  _CountryDialCode(
    countryName: 'Bosnia and Herzegovina',
    isoCode: 'BA',
    dialCode: '+387',
  ),
  _CountryDialCode(
    countryName: 'North Macedonia',
    isoCode: 'MK',
    dialCode: '+389',
  ),
  _CountryDialCode(countryName: 'Czechia', isoCode: 'CZ', dialCode: '+420'),
  _CountryDialCode(countryName: 'Slovakia', isoCode: 'SK', dialCode: '+421'),
  _CountryDialCode(
    countryName: 'Liechtenstein',
    isoCode: 'LI',
    dialCode: '+423',
  ),
  _CountryDialCode(countryName: 'Belize', isoCode: 'BZ', dialCode: '+501'),
  _CountryDialCode(countryName: 'Guatemala', isoCode: 'GT', dialCode: '+502'),
  _CountryDialCode(countryName: 'El Salvador', isoCode: 'SV', dialCode: '+503'),
  _CountryDialCode(countryName: 'Honduras', isoCode: 'HN', dialCode: '+504'),
  _CountryDialCode(countryName: 'Nicaragua', isoCode: 'NI', dialCode: '+505'),
  _CountryDialCode(countryName: 'Costa Rica', isoCode: 'CR', dialCode: '+506'),
  _CountryDialCode(countryName: 'Panama', isoCode: 'PA', dialCode: '+507'),
  _CountryDialCode(countryName: 'Haiti', isoCode: 'HT', dialCode: '+509'),
  _CountryDialCode(countryName: 'Bolivia', isoCode: 'BO', dialCode: '+591'),
  _CountryDialCode(countryName: 'Guyana', isoCode: 'GY', dialCode: '+592'),
  _CountryDialCode(countryName: 'Ecuador', isoCode: 'EC', dialCode: '+593'),
  _CountryDialCode(countryName: 'Paraguay', isoCode: 'PY', dialCode: '+595'),
  _CountryDialCode(countryName: 'Suriname', isoCode: 'SR', dialCode: '+597'),
  _CountryDialCode(countryName: 'Uruguay', isoCode: 'UY', dialCode: '+598'),
  _CountryDialCode(countryName: 'Timor-Leste', isoCode: 'TL', dialCode: '+670'),
  _CountryDialCode(countryName: 'Brunei', isoCode: 'BN', dialCode: '+673'),
  _CountryDialCode(countryName: 'Nauru', isoCode: 'NR', dialCode: '+674'),
  _CountryDialCode(
    countryName: 'Papua New Guinea',
    isoCode: 'PG',
    dialCode: '+675',
  ),
  _CountryDialCode(countryName: 'Tonga', isoCode: 'TO', dialCode: '+676'),
  _CountryDialCode(
    countryName: 'Solomon Islands',
    isoCode: 'SB',
    dialCode: '+677',
  ),
  _CountryDialCode(countryName: 'Vanuatu', isoCode: 'VU', dialCode: '+678'),
  _CountryDialCode(countryName: 'Fiji', isoCode: 'FJ', dialCode: '+679'),
  _CountryDialCode(countryName: 'Palau', isoCode: 'PW', dialCode: '+680'),
  _CountryDialCode(countryName: 'Samoa', isoCode: 'WS', dialCode: '+685'),
  _CountryDialCode(countryName: 'Kiribati', isoCode: 'KI', dialCode: '+686'),
  _CountryDialCode(countryName: 'Tuvalu', isoCode: 'TV', dialCode: '+688'),
  _CountryDialCode(countryName: 'Micronesia', isoCode: 'FM', dialCode: '+691'),
  _CountryDialCode(
    countryName: 'Marshall Islands',
    isoCode: 'MH',
    dialCode: '+692',
  ),
  _CountryDialCode(countryName: 'North Korea', isoCode: 'KP', dialCode: '+850'),
  _CountryDialCode(countryName: 'Cambodia', isoCode: 'KH', dialCode: '+855'),
  _CountryDialCode(countryName: 'Laos', isoCode: 'LA', dialCode: '+856'),
  _CountryDialCode(countryName: 'Bangladesh', isoCode: 'BD', dialCode: '+880'),
  _CountryDialCode(countryName: 'Taiwan', isoCode: 'TW', dialCode: '+886'),
  _CountryDialCode(countryName: 'Maldives', isoCode: 'MV', dialCode: '+960'),
  _CountryDialCode(countryName: 'Lebanon', isoCode: 'LB', dialCode: '+961'),
  _CountryDialCode(countryName: 'Jordan', isoCode: 'JO', dialCode: '+962'),
  _CountryDialCode(countryName: 'Syria', isoCode: 'SY', dialCode: '+963'),
  _CountryDialCode(countryName: 'Iraq', isoCode: 'IQ', dialCode: '+964'),
  _CountryDialCode(countryName: 'Kuwait', isoCode: 'KW', dialCode: '+965'),
  _CountryDialCode(
    countryName: 'Saudi Arabia',
    isoCode: 'SA',
    dialCode: '+966',
  ),
  _CountryDialCode(countryName: 'Yemen', isoCode: 'YE', dialCode: '+967'),
  _CountryDialCode(countryName: 'Oman', isoCode: 'OM', dialCode: '+968'),
  _CountryDialCode(
    countryName: 'United Arab Emirates',
    isoCode: 'AE',
    dialCode: '+971',
  ),
  _CountryDialCode(countryName: 'Israel', isoCode: 'IL', dialCode: '+972'),
  _CountryDialCode(countryName: 'Bahrain', isoCode: 'BH', dialCode: '+973'),
  _CountryDialCode(countryName: 'Qatar', isoCode: 'QA', dialCode: '+974'),
  _CountryDialCode(countryName: 'Bhutan', isoCode: 'BT', dialCode: '+975'),
  _CountryDialCode(countryName: 'Mongolia', isoCode: 'MN', dialCode: '+976'),
  _CountryDialCode(countryName: 'Nepal', isoCode: 'NP', dialCode: '+977'),
  _CountryDialCode(countryName: 'Tajikistan', isoCode: 'TJ', dialCode: '+992'),
  _CountryDialCode(
    countryName: 'Turkmenistan',
    isoCode: 'TM',
    dialCode: '+993',
  ),
  _CountryDialCode(countryName: 'Azerbaijan', isoCode: 'AZ', dialCode: '+994'),
  _CountryDialCode(countryName: 'Georgia', isoCode: 'GE', dialCode: '+995'),
  _CountryDialCode(countryName: 'Kyrgyzstan', isoCode: 'KG', dialCode: '+996'),
  _CountryDialCode(countryName: 'Uzbekistan', isoCode: 'UZ', dialCode: '+998'),
  _CountryDialCode(countryName: 'Bahamas', isoCode: 'BS', dialCode: '+1242'),
  _CountryDialCode(countryName: 'Barbados', isoCode: 'BB', dialCode: '+1246'),
  _CountryDialCode(countryName: 'Anguilla', isoCode: 'AI', dialCode: '+1264'),
  _CountryDialCode(
    countryName: 'Antigua and Barbuda',
    isoCode: 'AG',
    dialCode: '+1268',
  ),
  _CountryDialCode(countryName: 'Grenada', isoCode: 'GD', dialCode: '+1473'),
  _CountryDialCode(
    countryName: 'American Samoa',
    isoCode: 'AS',
    dialCode: '+1684',
  ),
  _CountryDialCode(
    countryName: 'Saint Lucia',
    isoCode: 'LC',
    dialCode: '+1758',
  ),
  _CountryDialCode(countryName: 'Dominica', isoCode: 'DM', dialCode: '+1767'),
  _CountryDialCode(
    countryName: 'Saint Vincent and the Grenadines',
    isoCode: 'VC',
    dialCode: '+1784',
  ),
  _CountryDialCode(
    countryName: 'Dominican Republic',
    isoCode: 'DO',
    dialCode: '+1809',
  ),
  _CountryDialCode(
    countryName: 'Trinidad and Tobago',
    isoCode: 'TT',
    dialCode: '+1868',
  ),
  _CountryDialCode(
    countryName: 'Saint Kitts and Nevis',
    isoCode: 'KN',
    dialCode: '+1869',
  ),
  _CountryDialCode(countryName: 'Jamaica', isoCode: 'JM', dialCode: '+1876'),
];

final _CountryDialCode _defaultCountryDialCode = _countryDialCodes.firstWhere(
  (country) => country.isoCode == 'US',
);

String _flagEmojiFromIso(String isoCode) {
  final normalized = isoCode.toUpperCase();
  if (normalized.length != 2) {
    return '\u{1F3F3}\u{FE0F}';
  }
  const int base = 0x1F1E6;
  final int first = base + normalized.codeUnitAt(0) - 65;
  final int second = base + normalized.codeUnitAt(1) - 65;
  return String.fromCharCodes([first, second]);
}
