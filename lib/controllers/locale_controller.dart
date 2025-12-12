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
      final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
      if (_isSupported(systemLocale.languageCode)) {
        _locale = Locale(systemLocale.languageCode);
      }
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
    if (locale != null) {
      final match = supported.firstWhere(
        (supportedLocale) =>
            supportedLocale.languageCode == locale.languageCode,
        orElse: () => supported.first,
      );
      return match;
    }
    return supported.first;
  }

  bool _isSupported(String code) {
    return const ['en', 'fr'].contains(code);
  }
}
