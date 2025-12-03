import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:go_router/go_router.dart';

import 'package:myapp/app/app_theme.dart';
import 'package:myapp/app/widgets/custom_nav_bar.dart';
import 'package:myapp/app/widgets/gradient_button.dart';

class CollaboratorProfileScreen extends StatelessWidget {
  const CollaboratorProfileScreen({super.key, required this.collaboratorId});

  final String collaboratorId;

  static final _CollaboratorProfile _sampleProfile = _CollaboratorProfile(
    name: 'Sarah Collins',
    profession: 'Photographer',
    location: 'Paris, France',
    rating: 4.8,
    reviewCount: 32,
    bio:
        'Documentary-style photographer capturing candid moments for weddings and live events.',
    skills: ['Photography', 'Editing', 'Lighting'],
    collaborationHistory: [
      'Dupont Wedding (with @Alex Carter)',
      'Corporate Dinner (with @Karim Haddad)',
      'Art Expo Launch (with @Laura Design)',
    ],
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profile = _sampleProfile; // Mocked; replace with real lookup later.

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            FeatherIcons.chevronLeft,
            color: AppColors.secondaryText,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          profile.name,
          style: theme.textTheme.titleLarge?.copyWith(
            color: AppColors.secondaryText,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Invite to project',
            icon: const Icon(
              FeatherIcons.userPlus,
              color: AppColors.secondaryText,
            ),
            onPressed: () => context.pushNamed('inviteCollaborator'),
          ),
          IconButton(
            tooltip: 'Start chat',
            icon: const Icon(
              FeatherIcons.messageCircle,
              color: AppColors.secondaryText,
            ),
            onPressed: () => context.pushNamed('collaborationChat'),
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
                  12,
                  24,
                  CustomNavBar.totalHeight + 40,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ProfileHeader(profile: profile),
                    const SizedBox(height: 20),
                    _SectionCard(
                      title: 'Key Skills',
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: profile.skills
                            .map(
                              (skill) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(22),
                                  gradient: const LinearGradient(
                                    colors: [
                                      AppColors.secondary,
                                      AppColors.primary,
                                    ],
                                    begin: AlignmentDirectional(1.0, 0.34),
                                    end: AlignmentDirectional(-1.0, -0.34),
                                  ),
                                ),
                                child: Text(
                                  skill,
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: AppColors.primaryText,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _SectionCard(
                      title: 'About',
                      child: Text(
                        profile.bio,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.secondaryText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _SectionCard(
                      title: 'Collaboration History',
                      child: Column(
                        children: profile.collaborationHistory
                            .map(
                              (item) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      FeatherIcons.checkCircle,
                                      size: 18,
                                      color: AppColors.secondary,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        item,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color: AppColors.secondaryText,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    GradientButton(
                      onPressed: () => context.pushNamed('inviteCollaborator'),
                      text: 'Invite to Project',
                      width: double.infinity,
                      height: 52,
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => context.pushNamed('collaborationChat'),
                      icon: const Icon(
                        FeatherIcons.messageCircle,
                        color: AppColors.secondary,
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: AppColors.secondary,
                          width: 2,
                        ),
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      label: Text(
                        'Send Message',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
            child: CustomNavBar(currentRouteName: 'management'),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.profile});

  final _CollaboratorProfile profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 28,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondaryBackground,
              ),
              alignment: Alignment.center,
              child: Text(
                profile.initials,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: AppColors.secondaryText,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.profession,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.hintTextfiled,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      FeatherIcons.mapPin,
                      size: 16,
                      color: AppColors.hintTextfiled,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      profile.location,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: AppColors.hintTextfiled,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Icon(
                      FeatherIcons.star,
                      size: 18,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${profile.rating} • ${profile.reviewCount} reviews',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: AppColors.secondaryText,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _CollaboratorProfile {
  const _CollaboratorProfile({
    required this.name,
    required this.profession,
    required this.location,
    required this.rating,
    required this.reviewCount,
    required this.bio,
    required this.skills,
    required this.collaborationHistory,
  });

  final String name;
  final String profession;
  final String location;
  final double rating;
  final int reviewCount;
  final String bio;
  final List<String> skills;
  final List<String> collaborationHistory;

  String get initials {
    final parts = name
        .trim()
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
}
