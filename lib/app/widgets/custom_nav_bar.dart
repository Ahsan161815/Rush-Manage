import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

import 'package:myapp/app/app_theme.dart';
import 'package:myapp/models/bottom_nav_item.dart';

class CustomNavBar extends StatelessWidget {
  const CustomNavBar({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const List<BottomNavItem> bottomNavItems = [
    BottomNavItem(
      inactiveIcon: FeatherIcons.grid,
      activeAsset: 'assets/images/rentals_active.svg',
      label: 'Dashboard',
      route: '/dashboard',
    ),
    BottomNavItem(
      inactiveIcon: FeatherIcons.mail,
      inactiveAsset: 'assets/images/user_email.svg',
      activeAsset: 'assets/images/user_email.svg',
      label: 'Chats',
      route: '/chats',
    ),
    BottomNavItem(
      inactiveIcon: FeatherIcons.calendar,
      activeAsset: 'assets/images/calendar_2.svg',
      label: 'Calendar',
      route: '/calendar',
    ),
    BottomNavItem(
      inactiveIcon: FeatherIcons.creditCard,
      inactiveAsset: 'assets/images/financial.svg',
      activeAsset: 'assets/images/financial.svg',
      label: 'Finance',
      route: '/finance',
    ),
    BottomNavItem(
      inactiveIcon: FeatherIcons.user,
      inactiveAsset: 'assets/images/profile_active.svg',
      activeAsset: 'assets/images/profile_active.svg',
      label: 'Profile',
      route: '/profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: SizedBox(
        height: 118,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            _NavBackground(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 22, 24, 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(
                    bottomNavItems.length,
                    (index) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: _NavItemButton(
                          item: bottomNavItems[index],
                          index: index,
                          navigationShell: navigationShell,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 44,
              child: _AddProjectButton(
                onTap: () => context.pushNamed('projectsCreate'),
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
      height: 100,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: Image.asset(
              'assets/images/nav_image.png',
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
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
    required this.index,
    required this.navigationShell,
  });

  final BottomNavItem item;
  final int index;
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final isSelected = navigationShell.currentIndex == index;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () => navigationShell.goBranch(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _NavIcon(item: item, isSelected: isSelected),
          const SizedBox(height: 10),
          if (isSelected)
            GradientText(
              item.label,
              colors: const [AppColors.primary, AppColors.secondary],
              style:
                  (textTheme.bodySmall ??
                          textTheme.bodyMedium ??
                          const TextStyle(fontSize: 10))
                      .copyWith(fontSize: 10, fontWeight: FontWeight.bold),
            )
          else
            Opacity(
              opacity: 0.6,
              child: Text(
                item.label,
                style:
                    (textTheme.bodySmall ??
                            textTheme.bodyMedium ??
                            const TextStyle(fontSize: 10))
                        .copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryText,
                        ),
              ),
            ),
          const SizedBox(height: 3),
        ],
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
    if (isSelected) {
      if (item.activeAsset != null) {
        return SvgPicture.asset(item.activeAsset!, width: 20, height: 20);
      }
      if (item.inactiveAsset != null) {
        return SvgPicture.asset(item.inactiveAsset!, width: 20, height: 20);
      }
      return Icon(item.inactiveIcon, size: 20, color: AppColors.primaryText);
    }

    if (item.inactiveAsset != null) {
      return Opacity(
        opacity: 0.65,
        child: SvgPicture.asset(item.inactiveAsset!, width: 20, height: 20),
      );
    }

    return Icon(
      item.inactiveIcon,
      size: 20,
      color: AppColors.primaryText.withOpacity(0.6),
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
          child: SvgPicture.asset(
            'assets/images/ug4be_+.svg',
            width: 24,
            height: 24,
          ),
        ),
      ),
    );
  }
}
