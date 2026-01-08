import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:myapp/common/models/contact_detail_args.dart';
import 'package:myapp/screens/calendar_screen.dart';
import 'package:myapp/screens/crm_screen.dart';
import 'package:myapp/screens/chats_screen.dart';
import 'package:myapp/screens/collaboration_chat_screen.dart';
import 'package:myapp/screens/collaborator_profile_screen.dart';
import 'package:myapp/screens/collaborators_screen.dart';
import 'package:myapp/screens/create_project_screen.dart';
import 'package:myapp/screens/create_quote_screen.dart';
import 'package:myapp/screens/contact_detail_screen.dart';
import 'package:myapp/screens/management_screen.dart';
import 'package:myapp/screens/home_screen.dart';
import 'package:myapp/screens/finance_screen.dart';
import 'package:myapp/screens/finance_create_quote_screen.dart';
import 'package:myapp/screens/finance_quote_preview_screen.dart';
import 'package:myapp/screens/finance_signature_tracking_screen.dart';
import 'package:myapp/screens/finance_invoice_screen.dart';
import 'package:myapp/screens/finance_reporting_screen.dart';
import 'package:myapp/screens/finance_invoices_screen.dart';
import 'package:myapp/screens/finance_expenses_screen.dart';
import 'package:myapp/screens/finance_create_invoice_screen.dart';
import 'package:myapp/screens/finance_record_payment_screen.dart';
import 'package:myapp/screens/forgot_password_screen.dart';
import 'package:myapp/screens/login_screen.dart';
import 'package:myapp/screens/profile_screen.dart';
import 'package:myapp/screens/project_chat_screen.dart';
import 'package:myapp/screens/project_detail_screen.dart';
import 'package:myapp/screens/project_schedule_screen.dart';
import 'package:myapp/screens/registration_screen.dart';
import 'package:myapp/screens/edit_profile_screen.dart';
import 'package:myapp/screens/reset_new_password_screen.dart';
import 'package:myapp/screens/setup_profile_screen.dart';
import 'package:myapp/screens/invite_collaborator_screen.dart';
import 'package:myapp/screens/roles_permissions_screen.dart';
import 'package:myapp/screens/shared_files_screen.dart';
import 'package:myapp/screens/invitation_notifications_screen.dart';
import 'package:myapp/screens/invitation_onboarding_screen.dart';
import 'package:myapp/screens/verify_email_screen.dart';
import 'package:myapp/screens/welcome_screen.dart';
import 'package:myapp/screens/analytics_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final _authRefreshNotifier = _AuthRefreshNotifier();

class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier() {
    _sub = Supabase.instance.client.auth.onAuthStateChange.listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<AuthState> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

final _unauthAllowedPaths = <String>{
  '/welcome',
  '/login',
  '/register',
  '/forgot-password',
  '/verify-email',
  '/reset-password',
};

final _entryPaths = <String>{'/welcome', '/login', '/register'};

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/welcome',
  refreshListenable: _authRefreshNotifier,
  redirect: (context, state) {
    final path = state.uri.path;

    final auth = Supabase.instance.client.auth;
    final isLoggedIn = auth.currentUser != null && auth.currentSession != null;

    if (!isLoggedIn) {
      if (_unauthAllowedPaths.contains(path)) {
        return null;
      }
      return '/welcome';
    }

    // Logged in users should never land on entry screens.
    if (_entryPaths.contains(path)) {
      return '/home';
    }

    return null;
  },
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
      builder: (context, state) {
        final email = state.uri.queryParameters['email'];
        return VerifyEmailScreen(initialEmail: email);
      },
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
      path: '/home',
      name: 'home',
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: HomeScreen()),
    ),
    GoRoute(
      path: '/management',
      name: 'management',
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: ManagementScreen()),
    ),
    GoRoute(
      path: '/crm',
      name: 'crm',
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: CRMScreen()),
    ),
    GoRoute(
      path: '/chats',
      name: 'chats',
      builder: (context, state) => const ChatsScreen(),
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
      path: '/finance/create-quote',
      name: 'financeCreateQuote',
      builder: (context, state) {
        final clientName = state.uri.queryParameters['clientName'];
        final clientEmail = state.uri.queryParameters['clientEmail'];
        final contactId = state.uri.queryParameters['contactId'];
        return FinanceCreateQuoteScreen(
          initialClientName: clientName,
          initialClientEmail: clientEmail,
          contactId: contactId,
        );
      },
    ),
    GoRoute(
      path: '/finance/create-invoice',
      name: 'financeCreateInvoiceForm',
      builder: (context, state) {
        final projectId = state.uri.queryParameters['projectId'];
        final clientName = state.uri.queryParameters['clientName'];
        final clientEmail = state.uri.queryParameters['clientEmail'];
        final contactId = state.uri.queryParameters['contactId'];
        return FinanceCreateInvoiceScreen(
          projectId: projectId,
          initialClientName: clientName,
          initialClientEmail: clientEmail,
          contactId: contactId,
        );
      },
    ),
    GoRoute(
      path: '/finance/quote/:id/preview',
      name: 'financeQuotePreview',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return FinanceQuotePreviewScreen(quoteId: id);
      },
    ),
    GoRoute(
      path: '/finance/quote/:id/signature',
      name: 'financeQuoteSignature',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return FinanceSignatureTrackingScreen(quoteId: id);
      },
    ),
    GoRoute(
      path: '/finance/invoice/:id',
      name: 'financeInvoice',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return FinanceInvoiceScreen(invoiceId: id);
      },
    ),
    GoRoute(
      path: '/finance/invoices',
      name: 'financeInvoices',
      builder: (context, state) => const FinanceInvoicesScreen(),
    ),
    GoRoute(
      path: '/finance/expenses',
      name: 'financeExpensesList',
      builder: (context, state) => const FinanceExpensesScreen(),
    ),
    GoRoute(
      path: '/finance/add-payment',
      name: 'financeRecordPayment',
      builder: (context, state) => const FinanceRecordPaymentScreen(),
    ),
    GoRoute(
      path: '/finance/reporting',
      name: 'financeReporting',
      builder: (context, state) => const FinanceReportingScreen(),
    ),
    GoRoute(
      path: '/profile',
      name: 'profile',
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: ProfileScreen()),
    ),
    GoRoute(
      path: '/profile/edit',
      name: 'editProfile',
      builder: (context, state) => const EditProfileScreen(),
    ),
    GoRoute(
      path: '/analytics',
      name: 'analytics',
      builder: (context, state) => const AnalyticsScreen(),
    ),
    GoRoute(
      path: '/collaborators',
      name: 'collaborators',
      builder: (context, state) => const CollaboratorsScreen(),
    ),
    GoRoute(
      path: '/collaborators/invite',
      name: 'inviteCollaborator',
      builder: (context, state) {
        final projectId = state.uri.queryParameters['projectId'];
        return InviteCollaboratorScreen(initialProjectId: projectId);
      },
    ),
    GoRoute(
      path: '/contacts/detail',
      name: 'contactDetail',
      builder: (context, state) {
        final args = state.extra as ContactDetailArgs?;
        if (args == null) {
          return const ContactDetailScreen(
            args: ContactDetailArgs(
              contactId: 'contact-fallback',
              name: 'Unknown collaborator',
              title: 'Contributor',
              category: ContactCategory.collaborator,
            ),
          );
        }
        return ContactDetailScreen(args: args);
      },
    ),
    GoRoute(
      path: '/collaborators/:id',
      name: 'collaboratorProfile',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return CollaboratorProfileScreen(collaboratorId: id);
      },
    ),
    GoRoute(
      path: '/collaboration/chat',
      name: 'collaborationChat',
      builder: (context, state) {
        final contactId = state.uri.queryParameters['contactId'];
        return CollaborationChatScreen(initialContactId: contactId);
      },
    ),
    GoRoute(
      path: '/collaboration/quote',
      name: 'createQuote',
      builder: (context, state) => const CreateQuoteScreen(),
    ),
    GoRoute(
      path: '/shared-files',
      name: 'sharedFiles',
      builder: (context, state) => const SharedFilesScreen(),
    ),
    GoRoute(
      path: '/roles-permissions',
      name: 'rolesPermissions',
      builder: (context, state) => const RolesPermissionsScreen(),
    ),
    GoRoute(
      path: '/projects/create',
      name: 'projectsCreate',
      pageBuilder: (context, state) {
        final seed = state.extra as ContactProjectSeed?;
        return NoTransitionPage(child: CreateProjectScreen(seed: seed));
      },
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
    GoRoute(
      path: '/projects/:id/schedule',
      name: 'projectSchedule',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return ProjectScheduleScreen(projectId: id);
      },
    ),
    GoRoute(
      path: '/invitations',
      name: 'invitationNotifications',
      builder: (context, state) => const InvitationNotificationsScreen(),
    ),
    GoRoute(
      path: '/invitations/:id/onboarding',
      name: 'invitationOnboarding',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return InvitationOnboardingScreen(invitationId: id);
      },
    ),
  ],
);
