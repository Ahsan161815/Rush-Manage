import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:myapp/app/app_theme.dart';
import 'package:myapp/app/widgets/gradient_button.dart';
import 'package:myapp/common/localization/l10n_extensions.dart';
import 'package:myapp/services/auth_service.dart';
import 'package:myapp/widgets/custom_text_field.dart';

class ResetNewPasswordScreen extends StatefulWidget {
  const ResetNewPasswordScreen({super.key});

  @override
  State<ResetNewPasswordScreen> createState() => _ResetNewPasswordScreenState();
}

class _ResetNewPasswordScreenState extends State<ResetNewPasswordScreen> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _submit() async {
    final loc = context.l10n;
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (newPassword.length < 6) {
      _showMessage(loc.resetPasswordLengthError);
      return;
    }
    if (newPassword != confirmPassword) {
      _showMessage(loc.resetPasswordMismatch);
      return;
    }

    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      _showMessage(loc.resetNoRecoverySession);
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);

    try {
      await context.read<AuthService>().updatePassword(
        newPassword: newPassword,
      );
      if (!mounted) {
        return;
      }
      await context.read<AuthService>().signOut();
      if (!mounted) {
        return;
      }
      _showMessage(loc.resetSuccess);
      context.goNamed('login');
    } on AuthException catch (error) {
      if (!mounted) {
        return;
      }
      final errorMessage = error.message.isNotEmpty
          ? error.message
          : loc.resetGenericError;
      _showMessage(errorMessage);
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showMessage(loc.resetGenericError);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.l10n;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.secondaryText),
          onPressed: () => context.pop(),
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
                  Text(
                    loc.resetTitle,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: AppColors.secondaryText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    loc.resetSubtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.secondaryText,
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height < 700 ? 60 : 80,
                  ),
                  CustomTextField(
                    controller: _newPasswordController,
                    hintText: loc.commonNewPassword,
                    iconPath: 'assets/images/Password.svg',
                    isPassword: true,
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: _confirmPasswordController,
                    hintText: loc.commonConfirmPassword,
                    iconPath: 'assets/images/Password.svg',
                    isPassword: true,
                  ),
                  const SizedBox(height: 48),
                  GradientButton(
                    onPressed: _submit,
                    text: loc.resetButton,
                    isLoading: _isSubmitting,
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
