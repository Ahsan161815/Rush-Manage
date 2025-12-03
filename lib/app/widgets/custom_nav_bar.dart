import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:myapp/controllers/project_controller.dart';

import 'package:myapp/app/app_theme.dart';
import 'package:myapp/models/bottom_nav_item.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myapp/common/models/message.dart';

class CustomNavBar extends StatelessWidget {
  const CustomNavBar({
    super.key,
    required this.currentRouteName,
    this.unreadChatsCount,
  });

  final String currentRouteName;
  final int? unreadChatsCount;

  static const double height = 110;
  static const double bottomInset = 0;
  static const List<BottomNavItem> _items = [
    BottomNavItem(
      routeName: 'home',
      label: 'Home',
      asset: 'assets/images/home.svg',
      activeAsset: 'assets/images/home.svg',
      icon: FeatherIcons.home,
    ),
    BottomNavItem(
      routeName: 'chats',
      label: 'CRM',
      asset: 'assets/images/chat-round-line-svgrepo-com.svg',
      activeAsset: 'assets/images/chat-round-line-svgrepo-com.svg',
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
      routeName: 'checkout',
      label: 'Checkout',
      asset: 'assets/images/checkout.svg',
      activeAsset: 'assets/images/checkout.svg',
      isMuted: true,
    ),
  ];

  static double get totalHeight => height + bottomInset;

  bool _isSelected(String routeName) => currentRouteName == routeName;

  void _onItemTap(BuildContext context, BottomNavItem item) {
    if (item.routeName == 'checkout') {
      _showCheckoutPreview(context);
      return;
    }
    if (_isSelected(item.routeName)) {
      return;
    }
    context.goNamed(item.routeName);
  }

  @override
  Widget build(BuildContext context) {
    // Compute unread chats globally if not provided
    final int globalUnread =
        unreadChatsCount ??
        (() {
          final pc = context.read<ProjectController>();
          int count = 0;
          for (final p in pc.projects) {
            final msgs = pc.messagesFor(p.id);
            for (final m in msgs) {
              final me = m.receipts['me'];
              if (me != MessageReceiptStatus.read) count++;
            }
          }
          return count;
        })();
    final splitIndex = (_items.length / 2).ceil();
    final leadingItems = _items.take(splitIndex).toList(growable: false);
    final trailingItems = _items.skip(splitIndex).toList(growable: false);

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
                          onTap: () => _onItemTap(context, item),
                          unreadBadge: item.routeName == 'chats'
                              ? globalUnread
                              : 0,
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
                          onTap: () => _onItemTap(context, item),
                          unreadBadge: item.routeName == 'chats'
                              ? globalUnread
                              : 0,
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

  Future<void> _showCheckoutPreview(BuildContext context) {
    final theme = Theme.of(context);
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 520),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.secondaryBackground,
                borderRadius: BorderRadius.circular(28),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 24,
                    offset: Offset(0, 18),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: AppColors.borderColor,
                        borderRadius: BorderRadius.circular(40),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          color: AppColors.primary.withValues(alpha: 0.1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              FeatherIcons.clock,
                              size: 14,
                              color: AppColors.secondaryText,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Coming soon',
                              style: TextStyle(
                                color: AppColors.secondaryText,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(FeatherIcons.x, size: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Container(
                  //   width: 7,
                  //   height: 72,
                  //   decoration: BoxDecoration(
                  //     color: AppColors.primary.withValues(alpha: 0.06),
                  //     borderRadius: BorderRadius.circular(24),
                  //   ),
                  //   child: SvgPicture.asset(
                  //     'assets/images/checkout.svg',
                  //     width: 36,
                  //     height: 36,
                  //     fit: BoxFit.contain,
                  //     colorFilter: const ColorFilter.mode(
                  //       AppColors.secondaryText,
                  //       BlendMode.srcIn,
                  //     ),
                  //   ),
                  // ),
                  // const SizedBox(height: 18),
                  Text(
                    'Checkout coming soon',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: AppColors.black,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'We’re putting the final polish on Rush Checkout so every tap, scan, or link feels seamless. Stay tuned.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.secondaryText,
                      fontWeight: FontWeight.w600,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        side: BorderSide(
                          color: AppColors.primary.withValues(alpha: 0.4),
                        ),
                        foregroundColor: AppColors.secondaryText,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        'Back to Rush',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
    this.unreadBadge = 0,
  });

  final BottomNavItem item;
  final bool isSelected;
  final VoidCallback onTap;
  final int unreadBadge;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final bool enableHighlight = !item.isMuted;
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
                children: [
                  _NavIcon(item: item, isSelected: isSelected),
                  if (unreadBadge > 0)
                    Positioned(
                      right: -8,
                      top: -8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.secondary, AppColors.primary],
                            begin: AlignmentDirectional(1.0, 0.34),
                            end: AlignmentDirectional(-1.0, -0.34),
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x33000000),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          unreadBadge > 99 ? '99+' : '$unreadBadge',
                          style: const TextStyle(
                            color: AppColors.primaryText,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                ],
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
            isSelected
                ? 'assets/images/rush_manage_selected.svg'
                : 'assets/images/rush_manage_unselected.svg',
            width: 60,
            height: 60,
          ),
        ),
      ),
    );
  }
}
