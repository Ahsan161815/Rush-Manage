import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

import 'package:myapp/app/app_theme.dart';

class SectionHeroHeader extends StatelessWidget {
  const SectionHeroHeader({
    super.key,
    required this.title,
    required this.onActionTap,
    required this.actionTooltip,
    this.subtitle,
    this.subtitleStyle,
    this.actionIcon = FeatherIcons.plus,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
  });

  final String title;
  final String? subtitle;
  final TextStyle? subtitleStyle;
  final VoidCallback onActionTap;
  final String actionTooltip;
  final IconData actionIcon;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitleTextStyle =
        subtitleStyle ??
        theme.textTheme.bodySmall?.copyWith(
          color: AppColors.primaryText.withValues(alpha: 0.72),
          fontWeight: FontWeight.w600,
        );

    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.secondary, AppColors.primary],
          begin: AlignmentDirectional(-1.0, -0.2),
          end: AlignmentDirectional(1.0, 0.4),
        ),
        borderRadius: BorderRadius.circular(34),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A8A3B52),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: SizedBox(
        height: subtitle == null ? 72 : 94,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 72),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: AppColors.primaryText,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      subtitle!,
                      textAlign: TextAlign.center,
                      style: subtitleTextStyle,
                    ),
                  ],
                ],
              ),
            ),
            Positioned(
              right: 0,
              child: Tooltip(
                message: actionTooltip,
                child: _HeaderActionButton(
                  icon: actionIcon,
                  onTap: onActionTap,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderActionButton extends StatelessWidget {
  const _HeaderActionButton({required this.onTap, required this.icon});

  final VoidCallback onTap;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(26),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.primaryText,
          borderRadius: BorderRadius.circular(26),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 18,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Icon(icon, color: AppColors.secondary, size: 20),
      ),
    );
  }
}
