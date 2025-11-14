import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primary = Color(0xFF181BF2);
  static const Color secondary = Color(0xFF0ABEFF);
  static const Color tertiary = Color(0xFF0C0C0C);
  static const Color alternate = Color(0xFFBDBFC2);
  static const Color primaryText = Color(0xFFFFFFFF);
  static const Color secondaryText = Color(0xFF000000);
  static const Color primaryBackground = Color(0xFFEEF1FF);
  static const Color secondaryBackground = Color(0xFFFFFFFF);
  static const Color accent1 = Color(0x4C4B39EF);
  static const Color accent2 = Color(0x4D39D2C0);
  static const Color accent3 = Color(0x4DEE8B60);
  static const Color accent4 = Color(0xFF858585);
  static const Color success = Color(0xFF026512);
  static const Color warning = Color(0xFFF9CF58);
  static const Color error = Color(0xFFFF0000);
  static const Color info = Color(0xFFFFFFFF);
  static const Color plate = Color(0xFFF2F4FB);
  static const Color available = Color(0xFFC0D9C4);
  static const Color outNow = Color(0xFFFFBFBF);
  static const Color reserved = Color(0xFFFFDDBF);
  static const Color orange = Color(0xFFF05D23);
  static const Color borderColor = Color(0x72BDBFC2);
  static const Color initialTextfield = Color(0xB3000000);
  static const Color hintTextfiled = Color(0xFFA4A4A4);
  static const Color textfieldBack = Color(0xFFF6F9FF);
  static const Color plateBack = Color(0xFF0522B7);
  static const Color rEDColor = Color(0xFFF44336);
  static const Color divider = Color(0xFFDDE1E8);
  static const Color dotColor = Color(0xFF0AB4FF);
  static const Color gradiantw = Color(0xFF87BFFD);
  static const Color fRPrimary = Color(0xFF004FFF);
  static const Color calendarBorder = Color(0xFFE8E8E8);
  static const Color textfieldFocusBorder = Color(0xFF8290DB);
  static const Color snackbars = Color(0xFF333333);

  static const Color background = Color(0xFFFFFFFF);
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color textfieldBackground = Color(0xFFF6F9FF);
  static const Color textfieldBorder = Color(0x72BDBFC2);
  static const Color hintText = Color(0xFFA4A4A4);
}

TextTheme appTextTheme(Color primaryText, Color secondaryText) => TextTheme(
      displayLarge: GoogleFonts.lato(
        color: primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 64.0,
      ),
      displayMedium: TextStyle(
        fontFamily: 'Code Bold',
        color: primaryText,
        fontWeight: FontWeight.bold,
        fontSize: 42.0,
      ),
      displaySmall: GoogleFonts.lato(
        color: secondaryText,
        fontWeight: FontWeight.w900,
        fontSize: 20.0,
      ),
      headlineLarge: GoogleFonts.lato(
        color: secondaryText,
        fontWeight: FontWeight.w800,
        fontSize: 32.0,
      ),
      headlineMedium: GoogleFonts.lato(
        color: primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 28.0,
      ),
      headlineSmall: GoogleFonts.lato(
        color: secondaryText,
        fontWeight: FontWeight.w800,
        fontSize: 26.0,
      ),
      titleLarge: GoogleFonts.lato(
        color: secondaryText,
        fontWeight: FontWeight.bold,
        fontSize: 20.0,
      ),
      titleMedium: GoogleFonts.lato(
        color: primaryText,
        fontWeight: FontWeight.bold,
        fontSize: 18.0,
      ),
      titleSmall: GoogleFonts.lato(
        color: secondaryText,
        fontWeight: FontWeight.w500,
        fontSize: 18.0,
      ),
      labelLarge: GoogleFonts.lato(
        color: primaryText,
        fontWeight: FontWeight.w500,
        fontSize: 15.0,
      ),
      labelMedium: GoogleFonts.lato(
        color: secondaryText,
        fontWeight: FontWeight.normal,
        fontSize: 14.0,
      ),
      labelSmall: GoogleFonts.lato(
        color: secondaryText,
        fontWeight: FontWeight.normal,
        fontSize: 12.0,
      ),
      bodyLarge: GoogleFonts.lato(
        color: secondaryText,
        fontWeight: FontWeight.bold,
        fontSize: 16.0,
      ),
      bodyMedium: GoogleFonts.lato(
        color: secondaryText,
        fontWeight: FontWeight.bold,
        fontSize: 14.0,
      ),
      bodySmall: GoogleFonts.dmSans(
        color: secondaryText,
        fontWeight: FontWeight.w500,
        fontSize: 10.0,
      ),
    );

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: AppColors.primary,
  scaffoldBackgroundColor: AppColors.primaryBackground,
  textTheme: appTextTheme(AppColors.primaryText, AppColors.secondaryText),
  colorScheme: const ColorScheme.light(
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    tertiary: AppColors.tertiary,
    error: AppColors.error,
    surface: AppColors.primaryBackground,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: AppColors.primaryText,
      backgroundColor: AppColors.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.textfieldBack,
    hintStyle: const TextStyle(color: AppColors.hintTextfiled),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.borderColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.textfieldFocusBorder),
    ),
  ),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: AppColors.primary,
  scaffoldBackgroundColor: AppColors.tertiary,
  textTheme: appTextTheme(AppColors.primaryText, AppColors.alternate),
  colorScheme: const ColorScheme.dark(
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    tertiary: AppColors.tertiary,
    error: AppColors.error,
    surface: AppColors.tertiary,
  ),
    elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: AppColors.primaryText,
      backgroundColor: AppColors.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.secondaryText,
    hintStyle: const TextStyle(color: AppColors.hintTextfiled),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.borderColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.textfieldFocusBorder),
    ),
  ),
);
