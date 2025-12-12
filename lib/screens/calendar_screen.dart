import 'package:flutter/material.dart';

import 'package:myapp/app/app_theme.dart';
import 'package:myapp/app/widgets/custom_nav_bar.dart';
import 'package:myapp/common/localization/l10n_extensions.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  24,
                  32,
                  24,
                  CustomNavBar.totalHeight + 48,
                ),
                child: Center(child: _CalendarPlaceholder()),
              ),
            ),
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomNavBar(currentRouteName: 'calendar'),
          ),
        ],
      ),
    );
  }
}

class _CalendarPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      context.l10n.calendarPlaceholder,
      style: const TextStyle(
        color: AppColors.secondaryText,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
