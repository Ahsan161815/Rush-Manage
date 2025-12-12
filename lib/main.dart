import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'package:myapp/app/app_theme.dart';
import 'package:myapp/app/router.dart';
import 'package:myapp/controllers/dashboard_controller.dart';
import 'package:myapp/controllers/project_controller.dart';
import 'package:myapp/controllers/finance_controller.dart';
import 'package:myapp/controllers/locale_controller.dart';
import 'package:myapp/l10n/app_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => DashboardController()),
        ChangeNotifierProvider(create: (context) => ProjectController()),
        ChangeNotifierProvider(create: (context) => FinanceController()),
        ChangeNotifierProvider(create: (context) => LocaleController()),
      ],
      child: const MyApp(),
    ),
  );
}

class ThemeProvider with ChangeNotifier {
  ThemeMode get themeMode => ThemeMode.light;

  void toggleTheme() {}
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeController = Provider.of<LocaleController>(context);
    return MaterialApp.router(
      title: 'Project Management App',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeProvider.themeMode,
      locale: localeController.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) =>
          localeController.localeResolutionCallback(locale, supportedLocales),
      routerConfig: router,
    );
  }
}
