import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/app/app_theme.dart';
import 'package:myapp/widgets/custom_text_field.dart';
import 'package:myapp/app/widgets/gradient_button.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.secondaryText),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height < 700 ? 50 : 70,
                  ),
                  Text(
                    'Reset Password',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: AppColors.secondaryText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Enter your email below to reset your password',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 100),
                  const CustomTextField(
                    hintText: 'Email Address',
                    iconPath: 'assets/images/emailAdress.svg',
                  ),
                  const SizedBox(height: 28),
                  GradientButton(
                    onPressed: () => context.go('/verify-email'),
                    text: 'Request OTP Verify',
                    isLoading: false,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
