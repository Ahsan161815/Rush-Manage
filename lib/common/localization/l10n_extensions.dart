import 'package:flutter/widgets.dart';

import 'package:myapp/l10n/app_localizations.dart';

extension LocalizationX on BuildContext {
  AppLocalizations get l10n {
    final loc = AppLocalizations.of(this);
    assert(
      loc != null,
      'AppLocalizations not found in widget tree. Ensure delegates are registered.',
    );
    return loc!;
  }
}
