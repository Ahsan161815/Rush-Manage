import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:myapp/app/app_theme.dart';
import 'package:myapp/app/router.dart';
import 'package:myapp/common/utils/password_recovery_redirect.dart';
import 'package:myapp/controllers/dashboard_controller.dart';
import 'package:myapp/controllers/project_controller.dart';
import 'package:myapp/controllers/finance_controller.dart';
import 'package:myapp/controllers/locale_controller.dart';
import 'package:myapp/l10n/app_localizations.dart';
import 'package:myapp/services/auth_service.dart';
import 'package:myapp/services/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final supabaseService = SupabaseService.instance;
  await supabaseService.init();
  final openResetOnLaunch = await handlePasswordRecoveryRedirect(
    supabaseService.client,
  );
  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: supabaseService),
        Provider(create: (_) => AuthService(supabaseService)),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => DashboardController()),
        ChangeNotifierProvider(create: (context) => ProjectController()),
        ChangeNotifierProvider(create: (context) => FinanceController()),
        ChangeNotifierProvider(create: (context) => LocaleController()),
      ],
      child: AuthStateListener(
        openResetOnLaunch: openResetOnLaunch,
        child: const MyApp(),
      ),
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

class AuthStateListener extends StatefulWidget {
  const AuthStateListener({
    super.key,
    required this.child,
    this.openResetOnLaunch = false,
  });

  final Widget child;
  final bool openResetOnLaunch;

  @override
  State<AuthStateListener> createState() => _AuthStateListenerState();
}

class _AuthStateListenerState extends State<AuthStateListener> {
  StreamSubscription<AuthState>? _subscription;

  @override
  void initState() {
    super.initState();
    final authService = context.read<AuthService>();
    _subscription = authService.authStateChanges.listen((authState) {
      if (authState.event == AuthChangeEvent.passwordRecovery) {
        router.goNamed('resetPassword');
      }
    });

    if (widget.openResetOnLaunch) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        router.goNamed('resetPassword');
      });
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
