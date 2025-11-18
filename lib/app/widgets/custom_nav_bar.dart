import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:myapp/app/app_theme.dart';
import 'package:myapp/models/bottom_nav_item.dart';

class CustomNavBar extends StatelessWidget {
  const CustomNavBar({super.key, required this.currentRouteName});

  final String currentRouteName;

  static const double height = 110;
  static const double bottomInset = 0;
  static const List<BottomNavItem> _items = [
    BottomNavItem(
      routeName: 'dashboard',
      label: 'Dashboard',
      asset: 'assets/images/rentals_active.svg',
      activeAsset: 'assets/images/rentals_active.svg',
      icon: FeatherIcons.grid,
    ),
    BottomNavItem(
      routeName: 'chats',
      label: 'Chats',
      asset: 'assets/images/email.svg',
      activeAsset: 'assets/images/email.svg',
      icon: FeatherIcons.mail,
    ),
    BottomNavItem(
      routeName: 'finance',
      label: 'Finance',
      asset: 'assets/images/financial.svg',
      activeAsset: 'assets/images/financial.svg',
      icon: FeatherIcons.creditCard,
    ),
    BottomNavItem(
      routeName: 'profile',
      label: 'Profile',
      asset: 'assets/images/profile_active.svg',
      activeAsset: 'assets/images/profile_active.svg',
      icon: FeatherIcons.user,
    ),
  ];

  static double get totalHeight => height + bottomInset;

  bool _isSelected(String routeName) => currentRouteName == routeName;

  void _onItemTap(BuildContext context, BottomNavItem item) {
    if (_isSelected(item.routeName)) {
      return;
    }
    context.goNamed(item.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final leadingItems = _items.take(2).toList(growable: false);
    final trailingItems = _items.skip(2).toList(growable: false);

    return SafeArea(
      top: false,
      child: SizedBox(
        height: totalHeight,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            _NavBackground(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (final item in leadingItems)
                      Expanded(
                        child: _NavItemButton(
                          item: item,
                          isSelected: _isSelected(item.routeName),
                          onTap: () => _onItemTap(context, item),
                        ),
                      ),
                    const SizedBox(width: 80),
                    for (final item in trailingItems)
                      Expanded(
                        child: _NavItemButton(
                          item: item,
                          isSelected: _isSelected(item.routeName),
                          onTap: () => _onItemTap(context, item),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 48,
              child: _AddProjectButton(
                onTap: () => context.goNamed('projectsCreate'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavBackground extends StatelessWidget {
  const _NavBackground({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: CustomNavBar.height,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          // topLeft: Radius.circular(20),
          // topRight: Radius.circular(20),
        ),
      ),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              // topLeft: Radius.circular(20),
              // topRight: Radius.circular(20),
            ),
            child: Image.asset(
              'assets/images/nav_image.png',
              width: double.infinity,
              // height: 200,
              fit: BoxFit.fill,
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _NavItemButton extends StatelessWidget {
  const _NavItemButton({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final BottomNavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        splashColor: AppColors.primary.withValues(alpha: 0.18),
        highlightColor: AppColors.primary.withValues(alpha: 0.08),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _NavIcon(item: item, isSelected: isSelected),
              const SizedBox(height: 6),
              Text(
                item.label,
                style:
                    (textTheme.bodySmall ??
                            textTheme.bodyMedium ??
                            const TextStyle(fontSize: 11))
                        .copyWith(
                          fontSize: 12,
                          color: isSelected
                              ? AppColors.secondaryText
                              : AppColors.secondaryText.withValues(alpha: 1),
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({required this.item, required this.isSelected});

  final BottomNavItem item;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final double opacity = isSelected ? 1 : 0.9;

    if (item.activeAsset != null) {
      final assetPath = isSelected
          ? item.activeAsset!
          : (item.asset ?? item.activeAsset!);
      return Opacity(
        opacity: opacity,
        child: SvgPicture.asset(assetPath, height: 24, width: 24),
      );
    }

    if (item.asset != null) {
      return Opacity(
        opacity: opacity,
        child: SvgPicture.asset(item.asset!, height: 24, width: 24),
      );
    }

    return Icon(
      item.icon,
      size: 22,
      color: AppColors.secondaryText.withValues(alpha: opacity),
    );
  }
}

class _AddProjectButton extends StatelessWidget {
  const _AddProjectButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 62,
        height: 62,
        padding: const EdgeInsets.all(2),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
            begin: AlignmentDirectional(-1.0, -0.87),
            end: AlignmentDirectional(1.0, 0.87),
          ),
        ),
        child: Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.secondaryBackground,
          ),
          alignment: Alignment.center,
          child: SvgPicture.asset('assets/images/ug4be_+.svg', width: 24),
        ),
      ),
    );
  }
}
