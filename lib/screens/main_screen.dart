
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:myapp/app/widgets/custom_nav_bar.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return CustomNavBar(
      navigationShell: navigationShell,
    );
  }
}
