import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:myapp/screens/calendar_screen.dart';
import 'package:myapp/screens/chats_screen.dart';
import 'package:myapp/screens/create_project_screen.dart';
import 'package:myapp/screens/dashboard_screen.dart';
import 'package:myapp/screens/finance_screen.dart';
import 'package:myapp/screens/forgot_password_screen.dart';
import 'package:myapp/screens/login_screen.dart';
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
    GoRoute(
      path: '/dashboard',
      name: 'dashboard',
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: DashboardScreen()),
    ),
    GoRoute(
      path: '/chats',
      name: 'chats',
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: ChatsScreen()),
    ),
    GoRoute(
      path: '/calendar',
      name: 'calendar',
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: CalendarScreen()),
    ),
    GoRoute(
      path: '/finance',
      name: 'finance',
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: FinanceScreen()),
    ),
    GoRoute(
      path: '/profile',
      name: 'profile',
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: ProfileScreen()),
    ),
    GoRoute(
      path: '/projects/create',
      name: 'projectsCreate',
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: CreateProjectScreen()),
    ),
    GoRoute(
      path: '/projects/:id',
      name: 'projectDetail',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return ProjectDetailScreen(projectId: id);
      },
    ),
    GoRoute(
      path: '/projects/:id/chat',
      name: 'projectChat',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return ProjectChatScreen(projectId: id);
      },
    ),
  ],
);
