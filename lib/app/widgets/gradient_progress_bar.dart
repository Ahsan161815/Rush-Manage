import 'package:flutter/material.dart';

import 'package:myapp/app/app_theme.dart';

class GradientProgressBar extends StatelessWidget {
  const GradientProgressBar({
    super.key,
    required this.progress,
    this.height = 10,
    this.duration = const Duration(milliseconds: 300),
  }) : assert(
         progress >= 0 && progress <= 100,
         'Progress must be within 0 and 100 inclusive.',
       );

  final int progress;
  final double height;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final clampedWidth = constraints.maxWidth;
        final fillWidth = clampedWidth * (progress / 100);
        final barColor = _colorForProgress(progress);
        final gradient = LinearGradient(
          colors: [_lighten(barColor, amount: 0.15), barColor],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        );

        return ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: Container(
            height: height,
            decoration: BoxDecoration(
              color: AppColors.textfieldBackground,
              borderRadius: BorderRadius.circular(height / 2),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: AnimatedContainer(
                duration: duration,
                width: fillWidth,
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(height / 2),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _colorForProgress(int value) {
    const stops = [
      _ProgressStop(0, Color(0xFFFF4D4F)),
      _ProgressStop(40, Color(0xFFFFA940)),
      _ProgressStop(70, Color(0xFFFFC53D)),
      _ProgressStop(100, Color(0xFF52C41A)),
    ];

    if (value <= stops.first.percent) {
      return stops.first.color;
    }
    if (value >= stops.last.percent) {
      return stops.last.color;
    }

    for (var i = 0; i < stops.length - 1; i++) {
      final current = stops[i];
      final next = stops[i + 1];
      if (value >= current.percent && value <= next.percent) {
        final range = next.percent - current.percent;
        final t = (value - current.percent) / range;
        return Color.lerp(current.color, next.color, t) ?? next.color;
      }
    }

    return stops.last.color;
  }

  Color _lighten(Color color, {double amount = 0.1}) {
    final hsl = HSLColor.fromColor(color);
    final lightened = hsl.withLightness(
      (hsl.lightness + amount).clamp(0.0, 1.0),
    );
    return lightened.toColor();
  }
}

class _ProgressStop {
  const _ProgressStop(this.percent, this.color);

  final int percent;
  final Color color;
}
