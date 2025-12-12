import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:go_router/go_router.dart';

import 'package:myapp/app/app_theme.dart';
import 'package:myapp/common/localization/l10n_extensions.dart';
import 'package:myapp/models/bottom_nav_item.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomNavBar extends StatelessWidget {
  const CustomNavBar({super.key, required this.currentRouteName});

  final String currentRouteName;

  static const double height = 110;
  static const double bottomInset = 0;

  static double get totalHeight => height + bottomInset;

  bool _isSelected(String routeName) => currentRouteName == routeName;

  void _onItemTap(BuildContext context, BottomNavItem item) {
    if (item.routeName == 'checkout') {
      return;
    }
    if (_isSelected(item.routeName)) {
      return;
    }
    context.goNamed(item.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final items = _navItems(context);
    final splitIndex = (items.length / 2).ceil();
    final leadingItems = items.take(splitIndex).toList(growable: false);
    final trailingItems = items.skip(splitIndex).toList(growable: false);

    return SafeArea(
      top: false,
      child: SizedBox(
        height: totalHeight,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            _NavBackground(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 18, 12, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (final item in leadingItems)
                      Expanded(
                        child: _NavItemButton(
                          item: item,
                          isSelected: _isSelected(item.routeName),
                          onTap: item.routeName == 'checkout'
                              ? null
                              : () => _onItemTap(context, item),
                        ),
                      ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width < 360 ? 40 : 54,
                    ),
                    for (final item in trailingItems)
                      Expanded(
                        child: _NavItemButton(
                          item: item,
                          isSelected: _isSelected(item.routeName),
                          onTap: item.routeName == 'checkout'
                              ? null
                              : () => _onItemTap(context, item),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 48,
              child: _ManagementActionButton(
                onTap: () => context.goNamed('management'),
                isSelected: _isSelected('management'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

List<BottomNavItem> _navItems(BuildContext context) {
  final loc = context.l10n;
  return [
    BottomNavItem(
      routeName: 'home',
      label: loc.navHome,
      asset: 'assets/images/home.svg',
      activeAsset: 'assets/images/home.svg',
      icon: FeatherIcons.home,
    ),
    BottomNavItem(
      routeName: 'finance',
      label: loc.navFinance,
      asset: 'assets/images/financial.svg',
      activeAsset: 'assets/images/financial.svg',
      icon: FeatherIcons.creditCard,
    ),
    BottomNavItem(
      routeName: 'crm',
      label: loc.navCrm,
      asset: 'assets/images/CRM.svg',
      activeAsset: 'assets/images/CRM.svg',
      icon: FeatherIcons.mail,
    ),
    BottomNavItem(
      routeName: 'checkout',
      label: loc.navCheckout,
      asset: 'assets/images/checkout.svg',
      activeAsset: 'assets/images/checkout.svg',
      isMuted: true,
    ),
  ];
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
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final bool enableHighlight = !item.isMuted && onTap != null;
    final bool highlight = enableHighlight && isSelected;
    final Color labelColor = item.isMuted
        ? AppColors.hintTextfiled
        : (highlight ? AppColors.black : AppColors.black.withValues(alpha: 1));
    final FontWeight labelWeight = highlight
        ? FontWeight.w800
        : FontWeight.w600;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        splashColor: enableHighlight
            ? AppColors.primary.withValues(alpha: 0.16)
            : Colors.transparent,
        highlightColor: enableHighlight
            ? AppColors.primary.withValues(alpha: 0.08)
            : Colors.transparent,
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            MediaQuery.of(context).size.width < 360 ? 4 : 6,
            MediaQuery.of(context).size.width < 360 ? 4 : 6,
            MediaQuery.of(context).size.width < 360 ? 4 : 6,
            MediaQuery.of(context).size.width < 360 ? 4 : 6,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [_NavIcon(item: item, isSelected: isSelected)],
              ),
              const SizedBox(height: 6),
              Flexible(
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      (textTheme.bodySmall ??
                              textTheme.bodyMedium ??
                              const TextStyle(fontSize: 11))
                          .copyWith(
                            fontSize: 12,
                            color: labelColor,
                            fontWeight: labelWeight,
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

class _NavIcon extends StatelessWidget {
  const _NavIcon({required this.item, required this.isSelected});

  final BottomNavItem item;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    String? assetPath;
    if (isSelected && item.activeAsset != null) {
      assetPath = item.activeAsset;
    } else if (item.asset != null) {
      assetPath = item.asset;
    } else if (item.activeAsset != null) {
      assetPath = item.activeAsset;
    }

    final double size = item.isMuted ? 24 : (isSelected ? 26 : 24);
    final Color iconColor = item.isMuted
        ? AppColors.hintTextfiled
        : AppColors.secondary;
    final double scale = item.isMuted ? 1 : (isSelected ? 1.12 : 0.96);

    if (assetPath != null) {
      final bool isCheckoutIcon = item.routeName == 'checkout';
      Widget svg = SvgPicture.asset(
        assetPath,
        width: size,
        colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
      );

      if (isCheckoutIcon) {
        svg = Transform.scale(scale: 1.25, child: svg);
      }

      return AnimatedScale(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        scale: scale,
        child: svg,
      );
    }

    return AnimatedScale(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      scale: scale,
      child: Icon(item.icon, size: size, color: iconColor),
    );
  }
}

class _ManagementActionButton extends StatelessWidget {
  const _ManagementActionButton({
    required this.onTap,
    required this.isSelected,
  });

  final VoidCallback onTap;
  final bool isSelected;

  static const LinearGradient _buttonGradient = LinearGradient(
    colors: [AppColors.secondary, AppColors.primary],
    begin: AlignmentDirectional(-1.0, -0.87),
    end: AlignmentDirectional(1.0, 0.87),
  );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        padding: const EdgeInsets.all(2),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: _buttonGradient,
        ),
        child: Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected ? AppColors.secondaryBackground : null,
            gradient: isSelected ? null : _buttonGradient,
          ),
          alignment: Alignment.center,
          child: SvgPicture.asset(
            'assets/images/management_icon.svg',
            width: 26,
            height: 26,
            colorFilter: ColorFilter.mode(
              isSelected ? AppColors.primary : AppColors.primaryText,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }
}
