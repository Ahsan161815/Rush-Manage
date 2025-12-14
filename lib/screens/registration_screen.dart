import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:myapp/app/app_theme.dart';
import 'package:myapp/app/widgets/gradient_button.dart';
import 'package:myapp/common/localization/l10n_extensions.dart';
import 'package:myapp/services/auth_service.dart';
import 'package:myapp/widgets/custom_text_field.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_isLoading) return;
    final loc = context.l10n;
    final fullName = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (fullName.isEmpty || email.isEmpty || password.length < 6) {
      final errorMessage = password.length < 6
          ? loc.registrationPasswordTooShort
          : loc.registrationMissingFields;
      _showError(errorMessage);
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);
    try {
      final authService = context.read<AuthService>();
      await authService.signUp(
        email: email,
        password: password,
        fullName: fullName,
      );
      if (!mounted) return;
      context.goNamed('setupProfile');
    } on AuthException catch (error) {
      _showError(error.message);
    } catch (_) {
      _showError(loc.registrationGenericError);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.l10n;
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
                    loc.registrationTitle,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: AppColors.secondaryText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    loc.registrationSubtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 60),
                  CustomTextField(
                    controller: _nameController,
                    hintText: loc.commonName,
                    iconPath: 'assets/images/fullname.svg',
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: _emailController,
                    hintText: loc.commonEmailAddress,
                    iconPath: 'assets/images/emailAdress.svg',
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: _passwordController,
                    hintText: loc.commonPassword,
                    iconPath: 'assets/images/Password.svg',
                    isPassword: true,
                  ),
                  const SizedBox(height: 60),
                  GradientButton(
                    onPressed: _handleRegister,
                    text: loc.registrationButton,
                    isLoading: _isLoading,
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
                          loc.commonOr,
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
                    loc.loginSocialGoogle,
                    AppColors.lightGrey,
                    AppColors.black,
                  ),
                  const SizedBox(height: 20),
                  _buildSocialButton(
                    context,
                    'assets/images/AppleWhite.svg',
                    loc.loginSocialApple,
                    AppColors.black,
                    AppColors.white,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${loc.registrationAlreadyPrompt} ',
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
                            loc.registrationLoginNow,
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
