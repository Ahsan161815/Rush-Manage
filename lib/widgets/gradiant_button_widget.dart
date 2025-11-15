import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:myapp/app/app_theme.dart';

class GradiantButtonWidget extends StatelessWidget {
  const GradiantButtonWidget({
    super.key,
    required this.buttonText,
    this.isLoading = false,
    this.onPressed,
    this.widthFactor = 0.85,
    this.height = 52.0,
  });

  final String buttonText;
  final bool isLoading;
  final VoidCallback? onPressed;
  final double widthFactor;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isLoading ? 1.0 : 0.98,
      child: Container(
        width: MediaQuery.of(context).size.width * widthFactor,
        height: height,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.secondary, AppColors.primary],
            begin: AlignmentDirectional(1.0, 0.34),
            end: AlignmentDirectional(-1.0, -0.34),
          ),
          borderRadius: BorderRadius.circular(34.0),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(34.0),
            onTap: isLoading ? null : onPressed,
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primaryText,
                        ),
                        strokeWidth: 2.0,
                      ),
                    )
                  : Text(
                      buttonText,
                      style: GoogleFonts.lato(
                        color: AppColors.secondaryBackground,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
