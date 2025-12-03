import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:myapp/app/app_theme.dart';
import 'package:myapp/app/widgets/gradient_button.dart';
import 'package:myapp/common/models/invitation.dart';
import 'package:myapp/controllers/project_controller.dart';

class InvitationOnboardingScreen extends StatefulWidget {
  const InvitationOnboardingScreen({super.key, required this.invitationId});

  final String invitationId;

  @override
  State<InvitationOnboardingScreen> createState() =>
      _InvitationOnboardingScreenState();
}

class _InvitationOnboardingScreenState
    extends State<InvitationOnboardingScreen> {
  final _accountFormKey = GlobalKey<FormState>();
  final _profileFormKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _roleController = TextEditingController();
  final _locationController = TextEditingController();
  bool _acceptedTerms = false;
  bool _submitting = false;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final controller = context.read<ProjectController>();
      controller.markInvitationRead(widget.invitationId);
      final invitation = controller.invitationById(widget.invitationId);
      if (invitation != null) {
        _fullNameController.text = invitation.inviteeName;
        _roleController.text = invitation.role;
      }
    });
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    _roleController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _goBack() {
    if (_currentStep == 0) {
      context.pop();
      return;
    }
    setState(() => _currentStep -= 1);
  }

  void _goForward(Invitation invitation) {
    if (_currentStep == 0) {
      if (_accountFormKey.currentState?.validate() != true) {
        return;
      }
      if (!_acceptedTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please accept the terms to continue.')),
        );
        return;
      }
      setState(() => _currentStep += 1);
      return;
    }
    if (_currentStep == 1) {
      if (_profileFormKey.currentState?.validate() != true) {
        return;
      }
      setState(() => _currentStep += 1);
    }
  }

  Future<void> _complete(
    Invitation invitation,
    ProjectController controller,
  ) async {
    if (_submitting) return;
    setState(() => _submitting = true);
    controller.acceptInvitation(invitation.id);
    setState(() => _submitting = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Welcome aboard, ${invitation.inviteeName}!')),
    );
    context.goNamed(
      'projectDetail',
      pathParameters: {'id': invitation.projectId},
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ProjectController>();
    final invitation = controller.invitationById(widget.invitationId);

    if (invitation == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              FeatherIcons.chevronLeft,
              color: AppColors.secondaryText,
            ),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(
          child: Text(
            'Invitation not found or expired.',
            style: TextStyle(
              color: AppColors.hintTextfiled,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    if (invitation.status == InvitationStatus.accepted) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              FeatherIcons.chevronLeft,
              color: AppColors.secondaryText,
            ),
            onPressed: () => context.pop(),
          ),
          title: const Text(
            'Invitation complete',
            style: TextStyle(
              color: AppColors.secondaryText,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Center(
          child: GradientButton(
            onPressed: () => context.goNamed(
              'projectDetail',
              pathParameters: {'id': invitation.projectId},
            ),
            text: 'View project',
            height: 52,
            width: 220,
          ),
        ),
      );
    }

    final stepTitle = <String>[
      'Create your account',
      'Complete your profile',
      'Review & join project',
    ][_currentStep];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            FeatherIcons.chevronLeft,
            color: AppColors.secondaryText,
          ),
          onPressed: _goBack,
        ),
        title: Text(
          stepTitle,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.secondaryText,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              _ProgressDots(currentStep: _currentStep, totalSteps: 3),
              const SizedBox(height: 24),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: switch (_currentStep) {
                    0 => _AccountStep(
                      formKey: _accountFormKey,
                      passwordController: _passwordController,
                      confirmPasswordController: _confirmPasswordController,
                      acceptedTerms: _acceptedTerms,
                      onTermsChanged: (value) =>
                          setState(() => _acceptedTerms = value),
                      email: invitation.inviteeEmail,
                    ),
                    1 => _ProfileStep(
                      formKey: _profileFormKey,
                      fullNameController: _fullNameController,
                      roleController: _roleController,
                      locationController: _locationController,
                    ),
                    _ => _ReviewStep(invitation: invitation),
                  },
                ),
              ),
              const SizedBox(height: 24),
              if (_currentStep < 2)
                GradientButton(
                  onPressed: () => _goForward(invitation),
                  text: 'Continue',
                  height: 52,
                  width: double.infinity,
                )
              else
                GradientButton(
                  onPressed: () {
                    if (_submitting) {
                      return;
                    }
                    _complete(invitation, controller);
                  },
                  text: 'Join project',
                  isLoading: _submitting,
                  height: 52,
                  width: double.infinity,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountStep extends StatelessWidget {
  const _AccountStep({
    required this.formKey,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.acceptedTerms,
    required this.onTermsChanged,
    required this.email,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool acceptedTerms;
  final ValueChanged<bool> onTermsChanged;
  final String email;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome! Create a password to activate access.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.secondaryText,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          TextFormField(
            initialValue: email,
            readOnly: true,
            decoration: const InputDecoration(
              labelText: 'Work email',
              filled: true,
              fillColor: AppColors.textfieldBackground,
            ),
          ),
          const SizedBox(height: 18),
          TextFormField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Create password'),
            validator: (value) {
              if (value == null || value.length < 8) {
                return 'Use at least 8 characters.';
              }
              return null;
            },
          ),
          const SizedBox(height: 18),
          TextFormField(
            controller: confirmPasswordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Confirm password'),
            validator: (value) {
              if (value != passwordController.text) {
                return 'Passwords do not match.';
              }
              return null;
            },
          ),
          const SizedBox(height: 18),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: acceptedTerms,
            onChanged: (value) => onTermsChanged(value ?? false),
            title: Text(
              'I agree to the Rush Manage collaboration terms.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.secondaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileStep extends StatelessWidget {
  const _ProfileStep({
    required this.formKey,
    required this.fullNameController,
    required this.roleController,
    required this.locationController,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController fullNameController;
  final TextEditingController roleController;
  final TextEditingController locationController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tell everyone how to reach you and what you do.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.secondaryText,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: fullNameController,
            decoration: const InputDecoration(labelText: 'Full name'),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Enter your full name.';
              }
              return null;
            },
          ),
          const SizedBox(height: 18),
          TextFormField(
            controller: roleController,
            decoration: const InputDecoration(labelText: 'Role / Title'),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Enter your role for this project.';
              }
              return null;
            },
          ),
          const SizedBox(height: 18),
          TextFormField(
            controller: locationController,
            decoration: const InputDecoration(labelText: 'Location (optional)'),
          ),
        ],
      ),
    );
  }
}

class _ReviewStep extends StatelessWidget {
  const _ReviewStep({required this.invitation});

  final Invitation invitation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'You\'re almost set! Review the project details before joining.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.secondaryText,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.secondaryBackground,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    FeatherIcons.briefcase,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      invitation.projectName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppColors.secondaryText,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    FeatherIcons.shield,
                    color: AppColors.hintTextfiled,
                    size: 16,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'You will join as ${invitation.role}.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.hintTextfiled,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              if (invitation.message != null &&
                  invitation.message!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      FeatherIcons.messageCircle,
                      color: AppColors.hintTextfiled,
                      size: 16,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        invitation.message!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.secondaryText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ProgressDots extends StatelessWidget {
  const _ProgressDots({required this.currentStep, required this.totalSteps});

  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (index) {
        final isActive = index <= currentStep;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 6),
          width: isActive ? 22 : 12,
          height: 12,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: isActive
                ? const LinearGradient(
                    colors: [AppColors.secondary, AppColors.primary],
                    begin: AlignmentDirectional(1.0, 0.34),
                    end: AlignmentDirectional(-1.0, -0.34),
                  )
                : null,
            color: isActive ? null : AppColors.textfieldBackground,
            border: Border.all(
              color: isActive
                  ? Colors.transparent
                  : AppColors.textfieldBorder.withValues(alpha: 0.6),
            ),
          ),
        );
      }),
    );
  }
}
