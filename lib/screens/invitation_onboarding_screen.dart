import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:myapp/app/app_theme.dart';
import 'package:myapp/app/widgets/gradient_button.dart';
import 'package:myapp/common/localization/l10n_extensions.dart';
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
    final loc = context.l10n;
    if (_currentStep == 0) {
      if (_accountFormKey.currentState?.validate() != true) {
        return;
      }
      if (!_acceptedTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.invitationOnboardingAcceptTermsError)),
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
    final loc = context.l10n;
    if (_submitting) return;
    setState(() => _submitting = true);
    controller.acceptInvitation(invitation.id);
    setState(() => _submitting = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(loc.invitationOnboardingWelcome(invitation.inviteeName)),
      ),
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
    final loc = context.l10n;

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
        body: Center(
          child: Text(
            loc.invitationOnboardingMissing,
            style: const TextStyle(
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
          title: Text(
            loc.invitationOnboardingCompleteTitle,
            style: const TextStyle(
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
            text: loc.invitationNotificationsViewProject,
            height: 52,
            width: 220,
          ),
        ),
      );
    }

    final stepTitle = <String>[
      loc.invitationOnboardingStepAccount,
      loc.invitationOnboardingStepProfile,
      loc.invitationOnboardingStepReview,
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
                  text: loc.invitationOnboardingContinueButton,
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
                  text: loc.invitationOnboardingJoinButton,
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
    final loc = context.l10n;
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.invitationOnboardingAccountIntro,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.secondaryText,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          TextFormField(
            initialValue: email,
            readOnly: true,
            decoration: InputDecoration(
              labelText: loc.invitationOnboardingWorkEmail,
              filled: true,
              fillColor: AppColors.textfieldBackground,
            ),
          ),
          const SizedBox(height: 18),
          TextFormField(
            controller: passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: loc.invitationOnboardingCreatePassword,
            ),
            validator: (value) {
              if (value == null || value.length < 8) {
                return loc.invitationOnboardingPasswordHint;
              }
              return null;
            },
          ),
          const SizedBox(height: 18),
          TextFormField(
            controller: confirmPasswordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: loc.invitationOnboardingConfirmPassword,
            ),
            validator: (value) {
              if (value != passwordController.text) {
                return loc.invitationOnboardingPasswordMismatch;
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
              loc.invitationOnboardingTermsAgreement,
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
    final loc = context.l10n;
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.invitationOnboardingProfileIntro,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.secondaryText,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: fullNameController,
            decoration: InputDecoration(
              labelText: loc.invitationOnboardingFullName,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return loc.invitationOnboardingFullNameError;
              }
              return null;
            },
          ),
          const SizedBox(height: 18),
          TextFormField(
            controller: roleController,
            decoration: InputDecoration(
              labelText: loc.invitationOnboardingRoleLabel,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return loc.invitationOnboardingRoleError;
              }
              return null;
            },
          ),
          const SizedBox(height: 18),
          TextFormField(
            controller: locationController,
            decoration: InputDecoration(
              labelText: loc.invitationOnboardingLocationLabel,
            ),
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
    final loc = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.invitationOnboardingReviewIntro,
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
                      loc.invitationOnboardingReviewRole(invitation.role),
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
