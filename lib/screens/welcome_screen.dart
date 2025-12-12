import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

import 'package:myapp/app/app_theme.dart';
import 'package:myapp/common/localization/l10n_extensions.dart';
import 'package:myapp/l10n/app_localizations.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final loc = context.l10n;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),
            Image.asset(
              'assets/images/App_icon.png',
              width: 200,
              // height: 70,
              fit: BoxFit.contain,
            ),
            const Spacer(),
            Image.asset(
              'assets/images/welcome_1.png',
              width: screenWidth * 0.8,
              fit: BoxFit.contain,
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  Text(
                    loc.appTitle.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: AppColors.primaryText,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    loc.welcomeSubtitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.primaryText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(flex: 2),
            Padding(
              padding: EdgeInsets.only(
                bottom: screenHeight > 700 ? 50.0 : 30.0,
                left: 20,
                right: 20,
              ),
              child: Column(
                children: [
                  _buildCreateAccountButton(context, screenWidth, loc),
                  const SizedBox(height: 14),
                  _buildLoginButton(context, screenWidth, loc),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateAccountButton(
    BuildContext context,
    double screenWidth,
    AppLocalizations loc,
  ) {
    return InkWell(
      onTap: () => context.goNamed('register'),
      child: Container(
        width: screenWidth * 0.82,
        height: 48.0,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(40.0),
        ),
        alignment: Alignment.center,
        child: GradientText(
          loc.welcomeCreateAccount,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          colors: const [AppColors.primary, AppColors.secondary],
        ),
      ),
    );
  }

  Widget _buildLoginButton(
    BuildContext context,
    double screenWidth,
    AppLocalizations loc,
  ) {
    return InkWell(
      onTap: () => context.goNamed('login'),
      child: Container(
        width: screenWidth * 0.82,
        height: 48.0,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(40.0),
          border: Border.all(color: AppColors.primaryText, width: 1.5),
        ),
        alignment: Alignment.center,
        child: Text(
          loc.welcomeLogin,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.primaryText,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
