
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/app/app_theme.dart';

class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.isLoading = false,
    this.width,
    this.height = 52.0,
  });

  final VoidCallback onPressed;
  final String text;
  final bool isLoading;
  final double? width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isLoading ? 0.8 : 1.0,
      child: Container(
        width: width ?? MediaQuery.sizeOf(context).width * 0.85,
        height: height,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              AppColors.secondary,
              AppColors.primary,
            ],
            stops: [0.0, 1.0],
            begin: AlignmentDirectional(1.0, 0.34),
            end: AlignmentDirectional(-1.0, -0.34),
          ),
          borderRadius: BorderRadius.circular(34.0),
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(34.0),
            ),
          ),
          onPressed: isLoading ? null : onPressed,
          child: isLoading
              ? const SizedBox(
                  width: 25,
                  height: 25,
                  child: CircularProgressIndicator(
                    color: AppColors.primaryText,
                    strokeWidth: 3,
                  ),
                )
              : Text(
                  text,
                  style: GoogleFonts.lato(
                    color: AppColors.primaryText,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
        ),
      ),
    );
  }
}
