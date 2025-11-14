
import 'package:flutter/material.dart';

class BottomNavItem {
  final IconData icon;
  final String label;
  final String route;
  final bool isCenter;

  BottomNavItem({
    required this.icon,
    required this.label,
    required this.route,
    this.isCenter = false,
  });
}
