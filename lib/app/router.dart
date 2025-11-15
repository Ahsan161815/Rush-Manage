import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:myapp/screens/dashboard_screen.dart';
import 'package:myapp/screens/vehicles_screen.dart';
import 'package:myapp/screens/finance_screen.dart';
import 'package:myapp/screens/profile_screen.dart';
import 'package:myapp/screens/calendar_screen.dart';
import 'package:myapp/screens/create_project_screen.dart';
import 'package:myapp/screens/project_detail_screen.dart';
import 'package:myapp/screens/main_screen.dart';
import 'package:myapp/screens/welcome_screen.dart';
import 'package:myapp/screens/login_screen.dart';
import 'package:myapp/screens/registration_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/welcome',
  routes: [
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegistrationScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainScreen(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/dashboard',
              builder: (context, state) => const DashboardScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/vehicles',
              builder: (context, state) => const VehiclesScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/calendar',
              builder: (context, state) => const CalendarScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/finance',
              builder: (context, state) => const FinanceScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/create_project',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const CreateProjectScreen(),
    ),
    GoRoute(
      path: '/projects',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/projects/create',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const CreateProjectScreen(),
    ),
    GoRoute(
      path: '/projects/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return ProjectDetailScreen(projectId: id);
      },
    ),
  ],
);
