import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleController extends ChangeNotifier {
  LocaleController() {
    _loadPreferredLocale();
  }

  static const String _prefsKey = 'preferred_locale_code';
  Locale? _locale;

  Locale? get locale => _locale;

  Future<void> _loadPreferredLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString(_prefsKey);
    if (savedCode != null && savedCode.isNotEmpty) {
      _locale = Locale(savedCode);
    } else {
      _locale = null; // default handled by resolver (English)
    }
    notifyListeners();
  }

  Future<void> updateLocale(Locale? locale) async {
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(_prefsKey);
    } else {
      await prefs.setString(_prefsKey, locale.languageCode);
    }
    _locale = locale;
    notifyListeners();
  }

  Locale localeResolutionCallback(Locale? locale, Iterable<Locale> supported) {
    if (_locale != null) {
      return _locale!;
    }

    // Prefer the locale passed by Flutter (device/app locale). If that's
    // null, fall back to the framework window locale. Try to find the best
    // matching supported locale (exact match, then language-only), otherwise
    // return the first supported locale as a last resort.
    final preferred =
        locale ?? WidgetsBinding.instance.platformDispatcher.locale;

    // Exact match (language + country)
    for (final s in supported) {
      if (s.languageCode == preferred.languageCode &&
          (s.countryCode ?? '') == (preferred.countryCode ?? '')) {
        return s;
      }
    }
    // Match by language only
    for (final s in supported) {
      if (s.languageCode == preferred.languageCode) {
        return s;
      }
    }

    return supported.first;
  }
}
