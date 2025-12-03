import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:myapp/app/app_theme.dart';
import 'package:myapp/app/widgets/custom_nav_bar.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  static const _featureDetails = [
    _UpcomingFeature(
      title: 'Tap to Pay',
      description: 'Instant contactless payments from any Rush device.',
      icon: FeatherIcons.smartphone,
    ),
    _UpcomingFeature(
      title: 'Card payments',
      description: 'Accept major debit & credit cards with adaptive fees.',
      icon: FeatherIcons.creditCard,
    ),
    _UpcomingFeature(
      title: 'QR payments',
      description: 'Share payable QR codes in-person or on screen.',
      icon: FeatherIcons.layers,
    ),
    _UpcomingFeature(
      title: 'Payment links',
      description: 'Send branded links that confirm payment automatically.',
      icon: FeatherIcons.link,
    ),
    _UpcomingFeature(
      title: 'Quick catalog',
      description: 'Create saved services and bundles for fast checkout.',
      icon: FeatherIcons.grid,
    ),
    _UpcomingFeature(
      title: 'Automatic receipt',
      description: 'Email or text confirmations without leaving the screen.',
      icon: FeatherIcons.mail,
    ),
  ];

  static const _roadmap = [
    _RoadmapMilestone(
      quarter: 'Step 1',
      title: 'Unified checkout shell',
      description: 'Centralize quotes, invoices, and payment orchestration.',
    ),
    _RoadmapMilestone(
      quarter: 'Step 2',
      title: 'Payment method rollout',
      description: 'Launch Tap to Pay, QR, and payment links sequentially.',
    ),
    _RoadmapMilestone(
      quarter: 'Step 3',
      title: 'Automation & insights',
      description: 'Activate receipts, reminders, and live settlement reports.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: Stack(
        children: [
          Positioned.fill(
            child: SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  24,
                  24,
                  24,
                  CustomNavBar.totalHeight + 32,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CheckoutHeroBanner(theme: theme),
                    const SizedBox(height: 24),
                    _FeatureGrid(features: _featureDetails),
                    const SizedBox(height: 28),
                    _RoadmapTimeline(milestones: _roadmap),
                    const SizedBox(height: 24),
                    const _StayInformedCard(),
                  ],
                ),
              ),
            ),
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomNavBar(currentRouteName: 'checkout'),
          ),
        ],
      ),
    );
  }
}

class _CheckoutHeroBanner extends StatelessWidget {
  const _CheckoutHeroBanner({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [AppColors.secondary, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x2E4B1D2A),
            blurRadius: 24,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(FeatherIcons.activity, size: 16, color: Colors.white),
                SizedBox(width: 6),
                Text(
                  'Checkout is brewing',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Payments without the patchwork.',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Tap, scan, or share a link. Checkout unifies every payment action inside Rush.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: SvgPicture.asset(
                    'assets/images/checkout.svg',
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                    width: 40,
                    height: 40,
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Now building',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          letterSpacing: 0.4,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Seamless checkout journeys for Rush teams and clients.',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
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

class _FeatureGrid extends StatelessWidget {
  const _FeatureGrid({required this.features});

  final List<_UpcomingFeature> features;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 540 ? 2 : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: features.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: crossAxisCount > 1 ? 1.9 : 2.4,
          ),
          itemBuilder: (context, index) {
            final feature = features[index];
            return _FeatureCard(feature: feature);
          },
        );
      },
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.feature});

  final _UpcomingFeature feature;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderColor.withValues(alpha: 0.6)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(feature.icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(height: 16),
          Text(
            feature.title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.secondaryText,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            feature.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.hintTextfiled,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoadmapTimeline extends StatelessWidget {
  const _RoadmapTimeline({required this.milestones});

  final List<_RoadmapMilestone> milestones;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.borderColor.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(FeatherIcons.map, color: AppColors.primary, size: 20),
              const SizedBox(width: 10),
              Text(
                'Rollout timeline',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.secondaryText,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          for (int i = 0; i < milestones.length; i++)
            _RoadmapTile(
              milestone: milestones[i],
              isLast: i == milestones.length - 1,
            ),
        ],
      ),
    );
  }
}

class _RoadmapTile extends StatelessWidget {
  const _RoadmapTile({required this.milestone, required this.isLast});

  final _RoadmapMilestone milestone;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppColors.secondary, AppColors.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 46,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.7),
                        AppColors.secondary.withValues(alpha: 0.2),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  milestone.quarter,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: AppColors.hintTextfiled,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  milestone.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.secondaryText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  milestone.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.hintTextfiled,
                    height: 1.5,
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

class _StayInformedCard extends StatelessWidget {
  const _StayInformedCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: AppColors.primary.withValues(alpha: 0.04),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Want early access?',
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.secondaryText,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We will invite a small crew to pilot Checkout features before the public launch.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.hintTextfiled,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.secondaryBackground,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.borderColor.withValues(alpha: 0.6),
              ),
            ),
            child: Row(
              children: const [
                Icon(FeatherIcons.mail, size: 18, color: AppColors.primary),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Reach out to your Rush partner manager to reserve a slot.',
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontWeight: FontWeight.w600,
                    ),
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

class _UpcomingFeature {
  const _UpcomingFeature({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;
}

class _RoadmapMilestone {
  const _RoadmapMilestone({
    required this.quarter,
    required this.title,
    required this.description,
  });

  final String quarter;
  final String title;
  final String description;
}
