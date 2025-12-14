import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:myapp/app/app_theme.dart';
import 'package:myapp/app/widgets/gradient_button.dart';
import 'package:myapp/common/localization/l10n_extensions.dart';
import 'package:myapp/services/auth_service.dart';
import 'package:myapp/widgets/custom_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String value) =>
      value.contains('@') && value.contains('.') && value.length >= 5;

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _submit() async {
    final loc = context.l10n;
    final email = _emailController.text.trim();

    if (!_isValidEmail(email)) {
      _showMessage(loc.forgotInvalidEmail);
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);

    try {
      await context.read<AuthService>().sendPasswordResetEmail(email: email);
      if (!mounted) {
        return;
      }
      _showMessage(loc.forgotEmailSent);
    } on AuthException catch (error) {
      if (!mounted) {
        return;
      }
      final errorMessage = error.message.isNotEmpty
          ? error.message
          : loc.forgotGenericError;
      _showMessage(errorMessage);
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showMessage(loc.forgotGenericError);
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
                  SizedBox(
                    height: MediaQuery.of(context).size.height < 700 ? 50 : 70,
                  ),
                  Text(
                    loc.forgotTitle,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: AppColors.secondaryText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    loc.forgotSubtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 100),
                  CustomTextField(
                    controller: _emailController,
                    hintText: loc.commonEmailAddress,
                    iconPath: 'assets/images/emailAdress.svg',
                  ),
                  const SizedBox(height: 28),
                  GradientButton(
                    onPressed: _submit,
                    text: loc.forgotButton,
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
