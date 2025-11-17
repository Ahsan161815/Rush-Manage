import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

import 'package:myapp/app/app_theme.dart';
import 'package:myapp/widgets/custom_text_field.dart';
import 'package:myapp/app/widgets/gradient_button.dart';

class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
                    'Create Your Account',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: AppColors.secondaryText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Please fill in your details to create an account',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 60),
                  const CustomTextField(
                    hintText: 'Name',
                    iconPath: 'assets/images/fullname.svg',
                  ),
                  const SizedBox(height: 14),
                  const CustomTextField(
                    hintText: 'Email Address',
                    iconPath: 'assets/images/emailAdress.svg',
                  ),
                  const SizedBox(height: 14),
                  const CustomTextField(
                    hintText: 'Set Password',
                    iconPath: 'assets/images/Password.svg',
                    isPassword: true,
                  ),
                  const SizedBox(height: 60),
                  GradientButton(
                    onPressed: () => context.pushNamed('setupProfile'),
                    text: 'Save & Next',
                    isLoading: false,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Expanded(
                        child: Divider(
                          color: AppColors.hintTextfiled,
                          thickness: 0.5,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          'OR',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.hintTextfiled),
                        ),
                      ),
                      const Expanded(
                        child: Divider(
                          color: AppColors.hintTextfiled,
                          thickness: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildSocialButton(
                    context,
                    'assets/images/Clip_path_group.svg',
                    'Continue with Google',
                    AppColors.lightGrey,
                    AppColors.black,
                  ),
                  const SizedBox(height: 20),
                  _buildSocialButton(
                    context,
                    'assets/images/AppleWhite.svg',
                    'Continue with Apple',
                    AppColors.black,
                    AppColors.white,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already a Subscriber? ',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.secondaryText,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      InkWell(
                        onTap: () => context.goNamed('login'),
                        child: Opacity(
                          opacity: 0.5,
                          child: GradientText(
                            'Login Now',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            ),
                            colors: const [
                              AppColors.primary,
                              AppColors.secondary,
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton(
    BuildContext context,
    String iconPath,
    String text,
    Color backgroundColor,
    Color textColor,
  ) {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: SvgPicture.asset(iconPath, width: 25, height: 25),
      label: Text(
        text,
        style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        minimumSize: Size(MediaQuery.of(context).size.width * 0.79, 58),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      ),
    );
  }
}
