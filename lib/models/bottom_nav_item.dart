import 'package:flutter/material.dart';

class BottomNavItem {
  final String routeName;
  final String label;
  final IconData? icon;
  final String? asset;
  final String? activeAsset;
  final bool isMuted;

  const BottomNavItem({
    required this.routeName,
    required this.label,
    this.icon,
    this.asset,
    this.activeAsset,
    this.isMuted = false,
  }) : assert(
         icon != null || asset != null || activeAsset != null,
         'Bottom navigation items require at least one visual representation.',
       );
}
