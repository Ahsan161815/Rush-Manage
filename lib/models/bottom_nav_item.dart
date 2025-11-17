import 'package:flutter/material.dart';

class BottomNavItem {
  final IconData? inactiveIcon;
  final String? inactiveAsset;
  final String label;
  final String route;
  final bool isCenter;
  final String? activeAsset;

  const BottomNavItem({
    this.inactiveIcon,
    this.inactiveAsset,
    required this.label,
    required this.route,
    this.isCenter = false,
    this.activeAsset,
  }) : assert(
         inactiveIcon != null || inactiveAsset != null || isCenter,
         'A bottom navigation item needs an icon or asset unless it is the center action.',
       );
}
