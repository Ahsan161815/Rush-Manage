import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:myapp/common/localization/l10n_extensions.dart';
import 'package:myapp/widgets/profile_details_form.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = context.l10n;
    return ProfileDetailsForm(
      title: loc.editProfileTitle,
      headline: loc.editProfileHeadline,
      subtitle: loc.editProfileSubtitle,
      primaryButtonLabel: loc.editProfileSave,
      showIndustrySection: false,
      onSubmitSuccess: (ctx) async {
        if (!ctx.mounted) {
          return;
        }
        ctx.pop();
        ScaffoldMessenger.of(ctx)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(loc.editProfileSuccess)));
      },
    );
  }
}
