
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

import 'package:myapp/app/app_theme.dart';
import 'package:myapp/models/bottom_nav_item.dart';

class CustomNavBar extends StatelessWidget {
  const CustomNavBar({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  static final List<BottomNavItem> bottomNavItems = [
    BottomNavItem(
      icon: Icons.dashboard,
      label: 'Dashboard',
      route: '/',
    ),
    BottomNavItem(
      icon: Icons.directions_car,
      label: 'Vehicles',
      route: '/vehicles',
    ),
    BottomNavItem(
      icon: Icons.calendar_today,
      label: 'Calendar',
      route: '/calendar',
      isCenter: true,
    ),
    BottomNavItem(
      icon: Icons.attach_money,
      label: 'Finance',
      route: '/finance',
    ),
    BottomNavItem(
      icon: Icons.person,
      label: 'Profile',
      route: '/profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        height: 100,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            BottomAppBar(
              color: Colors.transparent,
              elevation: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: bottomNavItems.map((item) {
                  final isSelected =
                      navigationShell.currentIndex ==
                          bottomNavItems.indexOf(item);
                  return item.isCenter
                      ? const SizedBox(width: 60) // Placeholder for center button
                      : _buildNavItem(context, item, isSelected);
                }).toList(),
              ),
            ),
            Positioned(
              top: 0,
              child: _buildCenterButton(context, bottomNavItems[2]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, BottomNavItem item, bool isSelected) {
    return InkWell(
      onTap: () {
        navigationShell.goBranch(bottomNavItems.indexOf(item));
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            item.icon,
            color: isSelected ? AppColors.secondary : AppColors.primaryText,
          ),
          const SizedBox(height: 4),
          if (isSelected)
            GradientText(
              item.label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              colors: const [
                AppColors.secondary,
                Color.fromARGB(255, 13, 71, 161),
              ],
            )
          else
            Text(
              item.label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.primaryText,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCenterButton(BuildContext context, BottomNavItem item) {
    final isSelected =
        navigationShell.currentIndex == bottomNavItems.indexOf(item);
    return GestureDetector(
      onTap: () {
        navigationShell.goBranch(bottomNavItems.indexOf(item));
      },
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [AppColors.secondary, AppColors.primary],
          ),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 3,
          ),
        ),
        child: Icon(
          item.icon,
          color: AppColors.primaryText,
          size: 35,
        ),
      ),
    );
  }
}
