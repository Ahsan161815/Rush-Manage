import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:myapp/screens/calendar_screen.dart';
import 'package:myapp/screens/chats_screen.dart';
import 'package:myapp/screens/create_project_screen.dart';
import 'package:myapp/screens/dashboard_screen.dart';
import 'package:myapp/screens/finance_screen.dart';
import 'package:myapp/screens/forgot_password_screen.dart';
import 'package:myapp/screens/login_screen.dart';
import 'package:myapp/screens/main_screen.dart';
import 'package:myapp/screens/profile_screen.dart';
import 'package:myapp/screens/project_chat_screen.dart';
import 'package:myapp/screens/project_detail_screen.dart';
import 'package:myapp/screens/registration_screen.dart';
import 'package:myapp/screens/reset_new_password_screen.dart';
import 'package:myapp/screens/setup_profile_screen.dart';
import 'package:myapp/screens/verify_email_screen.dart';
import 'package:myapp/screens/welcome_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/welcome',
  routes: [
    GoRoute(
      path: '/welcome',
      name: 'welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) => const RegistrationScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      name: 'forgotPassword',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/verify-email',
      name: 'verifyEmail',
      builder: (context, state) => const VerifyEmailScreen(),
    ),
    GoRoute(
      path: '/reset-password',
      name: 'resetPassword',
      builder: (context, state) => const ResetNewPasswordScreen(),
    ),
    GoRoute(
      path: '/setup-profile',
      name: 'setupProfile',
      builder: (context, state) => const SetupProfileScreen(),
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
              name: 'dashboard',
              builder: (context, state) => const DashboardScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/chats',
              name: 'chats',
              builder: (context, state) => const ChatsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/calendar',
              name: 'calendar',
              builder: (context, state) => const CalendarScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/finance',
              name: 'finance',
              builder: (context, state) => const FinanceScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              name: 'profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/create_project',
      name: 'createProject',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const CreateProjectScreen(),
    ),
    GoRoute(
      path: '/projects',
      name: 'projects',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/projects/create',
      name: 'projectsCreate',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const CreateProjectScreen(),
    ),
    GoRoute(
      path: '/projects/:id',
      name: 'projectDetail',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return ProjectDetailScreen(projectId: id);
      },
    ),
    GoRoute(
      path: '/projects/:id/chat',
      name: 'projectChat',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return ProjectChatScreen(projectId: id);
      },
    ),
  ],
);
