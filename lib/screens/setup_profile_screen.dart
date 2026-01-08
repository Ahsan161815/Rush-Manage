import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:myapp/common/localization/l10n_extensions.dart';
import 'package:myapp/widgets/profile_details_form.dart';

class SetupProfileScreen extends StatelessWidget {
  const SetupProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = context.l10n;
    return ProfileDetailsForm(
      title: loc.setupTitle,
      headline: loc.setupHeadline,
      subtitle: loc.setupSubtitle,
      primaryButtonLabel: loc.setupFinish,
      showIndustrySection: true,
      skipButtonLabel: loc.commonSkip,
      onSkip: () => context.goNamed('home'),
      onSubmitSuccess: (ctx) async {
        ctx.goNamed('home');
      },
    );
  }
}
