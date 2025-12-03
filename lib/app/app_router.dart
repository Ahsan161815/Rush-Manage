import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/screens/login_screen.dart';
import 'package:myapp/screens/registration_screen.dart';
import 'package:myapp/screens/welcome_screen.dart';
import 'package:myapp/screens/forgot_password_screen.dart';
import 'package:myapp/screens/verify_email_screen.dart';
import 'package:myapp/screens/reset_new_password_screen.dart';
import 'package:myapp/screens/management_screen.dart';
import 'package:myapp/screens/create_project_screen.dart';
import 'package:myapp/screens/project_detail_screen.dart';

final GoRouter router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const WelcomeScreen();
      },
    ),
    GoRoute(
      path: '/login',
      builder: (BuildContext context, GoRouterState state) {
        return const LoginScreen();
      },
    ),
    GoRoute(
      path: '/register',
      builder: (BuildContext context, GoRouterState state) {
        return const RegistrationScreen();
      },
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (BuildContext context, GoRouterState state) {
        return const ForgotPasswordScreen();
      },
    ),
    GoRoute(
      path: '/verify-email',
      builder: (BuildContext context, GoRouterState state) {
        return const VerifyEmailScreen();
      },
    ),
    GoRoute(
      path: '/reset-new-password',
      builder: (BuildContext context, GoRouterState state) {
        return const ResetNewPasswordScreen();
      },
    ),
    GoRoute(
      path: '/projects',
      builder: (BuildContext context, GoRouterState state) {
        return const ManagementScreen();
      },
    ),
    GoRoute(
      path: '/projects/create',
      builder: (BuildContext context, GoRouterState state) {
        return const CreateProjectScreen();
      },
    ),
    GoRoute(
      path: '/projects/:id',
      builder: (BuildContext context, GoRouterState state) {
        final id = state.pathParameters['id'] ?? '';
        return ProjectDetailScreen(projectId: id);
      },
    ),
  ],
);
