import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:myapp/app/app_theme.dart';
import 'package:myapp/app/widgets/gradient_button.dart';
import 'package:myapp/common/localization/l10n_extensions.dart';
import 'package:myapp/services/auth_service.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key, this.initialEmail});

  final String? initialEmail;

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  static const _resendCooldownMs = 59000;

  final StopWatchTimer _stopWatchTimer = StopWatchTimer(
    mode: StopWatchMode.countDown,
  );
  late final TextEditingController _codeController;
  late String _email;
  bool _isVerifying = false;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController();
    _email = widget.initialEmail?.trim() ?? '';
    _startCooldown();
  }

  @override
  void dispose() {
    _codeController.dispose();
    _stopWatchTimer.dispose();
    super.dispose();
  }

  void _startCooldown() {
    _stopWatchTimer.onResetTimer();
    _stopWatchTimer.setPresetTime(mSec: _resendCooldownMs);
    _stopWatchTimer.onStartTimer();
  }

  void _showMessage(String message) {
    if (!mounted || message.isEmpty) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _handleBack() {
    final router = GoRouter.of(context);
    if (router.canPop()) {
      router.pop();
      return;
    }
    router.goNamed('login');
  }

  Future<void> _handleVerify() async {
    final loc = context.l10n;
    final token = _codeController.text.trim();
    if (_email.isEmpty) {
      _showMessage(loc.verifySubtitle);
      return;
    }
    if (token.length != 6) {
      _showMessage('Enter the 6-digit code we sent.');
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isVerifying = true);
    try {
      final authService = context.read<AuthService>();
      await authService.verifyEmailOtp(email: _email, token: token);
      if (!mounted) return;
      context.goNamed('setupProfile');
    } on AuthException catch (error) {
      _showMessage(error.message);
    } catch (_) {
      _showMessage('Verification failed, please try again.');
    } finally {
      if (mounted) {
        setState(() => _isVerifying = false);
      }
    }
  }

  Future<void> _handleResend() async {
    final loc = context.l10n;
    if (_email.isEmpty || _isResending) {
      return;
    }
    setState(() => _isResending = true);
    try {
      final authService = context.read<AuthService>();
      await authService.sendVerificationOtp(email: _email);
      _startCooldown();
      _showMessage('A new code has been sent to $_email');
    } on AuthException catch (error) {
      _showMessage(error.message);
    } catch (_) {
      _showMessage(loc.verifyNoCode);
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  void _handleVerifyTap() {
    if (_isVerifying) {
      return;
    }
    _handleVerify();
  }

  void _handleResendTap() {
    _handleResend();
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.l10n;
    final subtitle = _email.isEmpty
        ? loc.verifySubtitle
        : '${loc.verifySubtitle}\n$_email';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.secondaryText),
          onPressed: _handleBack,
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
                    loc.verifyTitle,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: AppColors.secondaryText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 123),
                  PinCodeTextField(
                    appContext: context,
                    length: 6,
                    controller: _codeController,
                    onCompleted: (_) => _handleVerify(),
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(10),
                      fieldHeight: 52,
                      fieldWidth: 52,
                      activeFillColor: Colors.transparent,
                      inactiveFillColor: AppColors.textfieldBackground,
                      selectedFillColor: AppColors.textfieldBackground,
                      activeColor: AppColors.textfieldFocusBorder,
                      inactiveColor: AppColors.textfieldBorder,
                      selectedColor: AppColors.primary,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 80),
                  GradientButton(
                    onPressed: _handleVerifyTap,
                    text: loc.verifyConfirm,
                    isLoading: _isVerifying,
                  ),
                  const SizedBox(height: 40),
                  Column(
                    children: [
                      Text(
                        loc.verifyNoCode,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.secondaryText,
                        ),
                      ),
                      const SizedBox(height: 10),
                      StreamBuilder<int>(
                        stream: _stopWatchTimer.rawTime,
                        initialData: _resendCooldownMs,
                        builder: (context, snap) {
                          final value = snap.data!;
                          final displayTime = StopWatchTimer.getDisplayTime(
                            value,
                            hours: false,
                            minute: false,
                            second: true,
                            milliSecond: false,
                          );
                          return value > 0
                              ? Text(
                                  loc.verifyResendIn(displayTime),
                                  style: const TextStyle(
                                    color: AppColors.secondaryText,
                                    fontSize: 14,
                                  ),
                                )
                              : TextButton(
                                  onPressed: _isResending
                                      ? null
                                      : _handleResendTap,
                                  child: _isResending
                                      ? const SizedBox(
                                          height: 16,
                                          width: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: AppColors.primary,
                                          ),
                                        )
                                      : Text(
                                          loc.verifyResendNow,
                                          style: const TextStyle(
                                            color: AppColors.primary,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                );
                        },
                      ),
                    ],
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
