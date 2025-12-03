import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:myapp/app/app_theme.dart';

/// Wraps an SVG asset with a linear gradient fill based on the app palette.
class GradientSvgIcon extends StatelessWidget {
  const GradientSvgIcon({
    super.key,
    required this.assetName,
    this.width,
    this.height,
    this.gradient,
    this.alignment = Alignment.center,
    this.fit = BoxFit.contain,
    this.semanticsLabel,
    this.package,
  });

  final String assetName;
  final double? width;
  final double? height;
  final Gradient? gradient;
  final AlignmentGeometry alignment;
  final BoxFit fit;
  final String? semanticsLabel;
  final String? package;

  static const Gradient _defaultGradient = LinearGradient(
    colors: [AppColors.secondary, AppColors.primary],
    begin: AlignmentDirectional(1.0, 0.34),
    end: AlignmentDirectional(-1.0, -0.34),
  );

  @override
  Widget build(BuildContext context) {
    final gradient = this.gradient ?? _defaultGradient;

    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (Rect bounds) => gradient.createShader(bounds),
      child: SvgPicture.asset(
        assetName,
        width: width,
        height: height,
        fit: fit,
        alignment: alignment,
        semanticsLabel: semanticsLabel,
        package: package,
        // Paint the SVG in a neutral tone so the shader provides the color.
        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
      ),
    );
  }
}
