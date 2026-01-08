import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:myapp/app/app_theme.dart';
import 'package:myapp/app/widgets/gradient_button.dart';
import 'package:myapp/common/localization/l10n_extensions.dart';
import 'package:myapp/controllers/project_controller.dart';
import 'package:myapp/services/auth_service.dart';
import 'package:myapp/widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeResumePendingSession();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_isLoading) return;
    final loc = context.l10n;
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      _showError(loc.loginMissingFields);
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);
    try {
      final authService = context.read<AuthService>();
      final result = await authService.signIn(email: email, password: password);
      if (!mounted) return;
      await _processSignInResult(result, fallbackEmail: email);
    } on AuthException catch (error) {
      _showError(error.message);
    } catch (_) {
      _showError(loc.loginGenericError);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    if (_isGoogleLoading || _isLoading) {
      return;
    }
    final loc = context.l10n;
    FocusScope.of(context).unfocus();
    setState(() => _isGoogleLoading = true);
    try {
      final authService = context.read<AuthService>();
      final result = await authService.signInWithGoogle();
      if (!mounted || result == null) {
        return;
      }
      await _processSignInResult(result);
    } on AuthException catch (error) {
      _showError(error.message);
    } catch (_) {
      _showError(loc.loginGenericError);
    } finally {
      if (mounted) {
        setState(() => _isGoogleLoading = false);
      }
    }
  }

  Future<void> _maybeResumePendingSession() async {
    final authService = context.read<AuthService>();
    final pending = await authService.resolveExistingSession();
    if (!mounted || pending == null) {
      return;
    }
    await _processSignInResult(pending);
  }

  Future<void> _processSignInResult(
    SignInResult result, {
    String? fallbackEmail,
  }) async {
    final emailForVerification = result.emailForVerification ?? fallbackEmail;
    if (!result.isVerified) {
      final verificationMessage =
          (emailForVerification == null || emailForVerification.isEmpty)
          ? 'Check your inbox for the verification email we already sent and enter the code to continue.'
          : 'Check your inbox for the verification email we already sent to $emailForVerification and enter the code to continue.';
      _showNotice(verificationMessage);
      context.goNamed(
        'verifyEmail',
        queryParameters:
            (emailForVerification == null || emailForVerification.isEmpty)
            ? const {}
            : {'email': emailForVerification},
      );
      return;
    }

    if (result.needsProfileSetup) {
      _showNotice('Complete your profile to unlock the dashboard.');
      context.goNamed('setupProfile');
      return;
    }
    final redirected = await _maybeLaunchInvitationInbox(
      fallbackEmail: fallbackEmail,
    );
    if (redirected || !mounted) {
      return;
    }
    context.goNamed('home');
  }

  Future<bool> _maybeLaunchInvitationInbox({String? fallbackEmail}) async {
    if (!mounted) {
      return false;
    }
    final controller = context.read<ProjectController>();
    final email = controller.currentUserEmail ?? fallbackEmail;
    if (email == null || email.isEmpty) {
      return false;
    }
    final hasInvites = await controller.loadInvitationsForEmail(email);
    if (!hasInvites || !mounted) {
      return false;
    }
    context.goNamed('invitationNotifications');
    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showNotice(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
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
                  const SizedBox(height: 50),
                  Text(
                    loc.loginTitle,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: AppColors.secondaryText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    loc.loginSubtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 69),
                  CustomTextField(
                    controller: _emailController,
                    hintText: loc.commonEmailAddress,
                    iconPath: 'assets/images/emailAdress.svg',
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: _passwordController,
                    hintText: loc.commonEnterPassword,
                    iconPath: 'assets/images/Password.svg',
                    isPassword: true,
                  ),
                  const SizedBox(height: 11),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Row(
                        children: [
                          Text(
                            '${loc.loginForgotPrompt} ',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.secondaryText,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          InkWell(
                            onTap: () => context.pushNamed('forgotPassword'),
                            child: GradientText(
                              loc.loginResetLink,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                              ),
                              colors: const [
                                AppColors.primary,
                                AppColors.secondary,
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  GradientButton(
                    onPressed: _handleLogin,
                    text: loc.loginButton,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Expanded(
                        child: Divider(
                          color: AppColors.secondaryText,
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          loc.commonOr,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.secondaryText),
                        ),
                      ),
                      const Expanded(
                        child: Divider(
                          color: AppColors.secondaryText,
                          thickness: 1,
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
                    _handleGoogleSignIn,
                    isLoading: _isGoogleLoading,
                  ),
                  const SizedBox(height: 15),
                  _buildSocialButton(
                    context,
                    'assets/images/AppleWhite.svg',
                    loc.loginSocialApple,
                    AppColors.black,
                    AppColors.white,
                    () => _showNotice(loc.loginAppleUnavailable),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${loc.loginNoAccountPrompt} ',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.secondaryText,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      InkWell(
                        onTap: () => context.goNamed('register'),
                        child: GradientText(
                          loc.loginCreateNow,
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
                    ],
                  ),
                  const SizedBox(height: 60),
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
    VoidCallback? onPressed, {
    bool isLoading = false,
  }) {
    final buttonWidth = MediaQuery.of(context).size.width * 0.79;
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        minimumSize: Size(buttonWidth, 58),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      ),
      child: SizedBox(
        width: buttonWidth,
        child: Center(
          child: isLoading
              ? SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(textColor),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(iconPath, width: 25, height: 25),
                    const SizedBox(width: 12),
                    Text(
                      text,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
