import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:myapp/app/app_theme.dart';
import 'package:myapp/app/widgets/app_form_fields.dart';
import 'package:myapp/app/widgets/custom_nav_bar.dart';
import 'package:myapp/app/widgets/gradient_button.dart';
import 'package:myapp/controllers/locale_controller.dart';
import 'package:myapp/l10n/app_localizations.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const _profile = _ProfileSnapshot(
    name: 'Alex Carter',
    role: 'Operations Lead',
    email: 'alex.carter@example.com',
    phone: '+1 (555) 010-9988',
    location: 'San Francisco, CA',
    focusArea: 'Logistics',
    bio:
        'Coordinates cross-functional teams to keep every project milestone moving.',
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    final localeController = context.watch<LocaleController>();
    final languageOptions = _LanguageOption.fromLocalizations(loc);
    final selectedLanguage = _LanguageOption.resolveSelected(
      languageOptions,
      localeController.locale,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            FeatherIcons.chevronLeft,
            color: AppColors.secondaryText,
          ),
          onPressed: () {
            final router = GoRouter.of(context);
            if (router.canPop()) {
              router.pop();
            } else {
              router.goNamed('home');
            }
          },
        ),
        title: Text(
          loc.profileTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            color: AppColors.secondaryText,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: loc.profileEditTooltip,
            onPressed: () => context.pushNamed('setupProfile'),
            icon: const Icon(FeatherIcons.edit, color: AppColors.secondaryText),
          ),
        ],
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
                  CustomNavBar.totalHeight + 56,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ProfileHeader(snapshot: _profile),
                    const SizedBox(height: 20),
                    _InfoSection(
                      title: loc.profileContactSection,
                      children: [
                        _InfoRow(
                          icon: FeatherIcons.mail,
                          label: loc.profileEmailLabel,
                          value: _profile.email,
                        ),
                        _InfoRow(
                          icon: FeatherIcons.phone,
                          label: loc.profilePhoneLabel,
                          value: _profile.phone,
                        ),
                        _InfoRow(
                          icon: FeatherIcons.mapPin,
                          label: loc.profileLocationLabel,
                          value: _profile.location,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _LanguagePreferenceCard(
                      title: loc.languageLabel,
                      description: loc.languageDescription,
                      options: languageOptions,
                      selected: selectedLanguage,
                      hintText: loc.languageDropdownHint,
                      onChanged: (option) {
                        if (option == null) {
                          localeController.updateLocale(null);
                          return;
                        }
                        localeController.updateLocale(option.locale);
                      },
                    ),
                    const SizedBox(height: 20),
                    _InfoSection(
                      title: loc.profileFocusAreaSection,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [_FocusBadge(label: _profile.focusArea)],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    GradientButton(
                      onPressed: () => context.pushNamed('setupProfile'),
                      text: loc.profileEditButton,
                      width: double.infinity,
                      height: 52,
                    ),
                    const SizedBox(height: 12),
                    _SecondaryActionButton(
                      icon: FeatherIcons.barChart2,
                      label: loc.profileViewAnalytics,
                      onTap: () => context.pushNamed('analytics'),
                      accentColor: AppColors.secondary,
                    ),
                    const SizedBox(height: 12),
                    _SecondaryActionButton(
                      icon: FeatherIcons.bell,
                      label: loc.profileInvitationNotifications,
                      onTap: () => context.pushNamed('invitationNotifications'),
                      accentColor: AppColors.primary,
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
            child: CustomNavBar(currentRouteName: 'profile'),
          ),
        ],
      ),
    );
  }
}

class _LanguagePreferenceCard extends StatelessWidget {
  const _LanguagePreferenceCard({
    required this.title,
    required this.description,
    required this.options,
    required this.selected,
    required this.hintText,
    required this.onChanged,
  });

  final String title;
  final String description;
  final List<_LanguageOption> options;
  final _LanguageOption selected;
  final String hintText;
  final ValueChanged<_LanguageOption?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.secondaryText,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.hintTextfiled,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          AppDropdownField<_LanguageOption>(
            items: options,
            value: selected,
            hintText: hintText,
            labelBuilder: (option) => option.label,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _LanguageOption {
  const _LanguageOption({required this.locale, required this.label});

  final Locale? locale;
  final String label;

  static List<_LanguageOption> fromLocalizations(AppLocalizations loc) {
    return [
      _LanguageOption(locale: null, label: loc.languageSystemDefault),
      _LanguageOption(locale: const Locale('en'), label: loc.languageEnglish),
      _LanguageOption(locale: const Locale('fr'), label: loc.languageFrench),
    ];
  }

  static _LanguageOption resolveSelected(
    List<_LanguageOption> options,
    Locale? locale,
  ) {
    return options.firstWhere(
      (option) => option.locale?.languageCode == locale?.languageCode,
      orElse: () => options.first,
    );
  }
}

class _SecondaryActionButton extends StatelessWidget {
  const _SecondaryActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.accentColor,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? accentColor;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.secondaryBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: (accentColor ?? AppColors.textfieldBorder).withValues(
              alpha: 0.55,
            ),
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: accentColor ?? AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.secondaryText,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Icon(
              FeatherIcons.chevronRight,
              size: 18,
              color: (accentColor ?? AppColors.hintTextfiled).withValues(
                alpha: 0.9,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.snapshot});

  final _ProfileSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 84,
            height: 84,
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
              alignment: Alignment.center,
              child: Text(
                snapshot.initials,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: AppColors.secondaryText,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  snapshot.name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: AppColors.secondaryText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  snapshot.role,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.hintTextfiled,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.secondaryText,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.hintTextfiled,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.secondaryText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FocusBadge extends StatelessWidget {
  const _FocusBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.secondary, AppColors.primary],
          begin: AlignmentDirectional(1.0, 0.34),
          end: AlignmentDirectional(-1.0, -0.34),
        ),
        borderRadius: BorderRadius.all(Radius.circular(24)),
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
                      color: AppColors.primaryText,
                      fontWeight: FontWeight.bold,
                    ),
          ),
          const SizedBox(width: 8),
          const Icon(
            FeatherIcons.check,
            size: 16,
            color: AppColors.primaryText,
          ),
        ],
      ),
    );
  }
}

class _ProfileSnapshot {
  const _ProfileSnapshot({
    required this.name,
    required this.role,
    required this.email,
    required this.phone,
    required this.location,
    required this.focusArea,
    required this.bio,
  });

  final String name;
  final String role;
  final String email;
  final String phone;
  final String location;
  final String focusArea;
  final String bio;

  String get initials {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((segment) => segment.isNotEmpty)
        .toList(growable: false);

    if (parts.isEmpty) {
      return '';
    }

    final firstInitial = parts.first[0].toUpperCase();
    if (parts.length == 1) {
      return firstInitial;
    }

    final lastInitial = parts.last[0].toUpperCase();
    return '$firstInitial$lastInitial';
  }
}
