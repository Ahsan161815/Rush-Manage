import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:myapp/common/localization/l10n_extensions.dart';

String formatCurrency(BuildContext context, double value, {String? currency}) {
  final locale = Localizations.localeOf(context).toString();
  final formatter = NumberFormat.simpleCurrency(locale: locale, name: currency);
  return formatter.format(value);
}

String formatRelativeTime(BuildContext context, DateTime dateTime) {
  final diff = DateTime.now().difference(dateTime);
  if (diff.inMinutes < 1) {
    return context.l10n.relativeTimeJustNow;
  }
  if (diff.inHours < 1) {
    return context.l10n.relativeTimeMinutes(diff.inMinutes);
  }
  if (diff.inDays < 1) {
    return context.l10n.relativeTimeHours(diff.inHours);
  }
  return context.l10n.relativeTimeDays(diff.inDays);
}
