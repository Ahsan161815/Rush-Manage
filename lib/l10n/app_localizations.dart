import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Rush Manage'**
  String get appTitle;

  /// No description provided for @contactsTitle.
  ///
  /// In en, this message translates to:
  /// **'Contacts'**
  String get contactsTitle;

  /// No description provided for @contactsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Centralize clients and collaborators in one place.'**
  String get contactsSubtitle;

  /// No description provided for @contactsAdd.
  ///
  /// In en, this message translates to:
  /// **'Add contact'**
  String get contactsAdd;

  /// No description provided for @collaboratorsTitle.
  ///
  /// In en, this message translates to:
  /// **'My Collaborators'**
  String get collaboratorsTitle;

  /// No description provided for @collaboratorsInvitationsButton.
  ///
  /// In en, this message translates to:
  /// **'Invitations'**
  String get collaboratorsInvitationsButton;

  /// No description provided for @collaboratorsInviteCta.
  ///
  /// In en, this message translates to:
  /// **'+ Invite'**
  String get collaboratorsInviteCta;

  /// No description provided for @collaboratorsNoHistory.
  ///
  /// In en, this message translates to:
  /// **'No previous collaboration recorded'**
  String get collaboratorsNoHistory;

  /// No description provided for @collaboratorsLastProject.
  ///
  /// In en, this message translates to:
  /// **'Last collaborated on {project}'**
  String collaboratorsLastProject(Object project);

  /// No description provided for @collaboratorsActionViewProfile.
  ///
  /// In en, this message translates to:
  /// **'View Profile'**
  String get collaboratorsActionViewProfile;

  /// No description provided for @collaboratorsActionConversation.
  ///
  /// In en, this message translates to:
  /// **'Start Conversation'**
  String get collaboratorsActionConversation;

  /// No description provided for @collaboratorsActionInvite.
  ///
  /// In en, this message translates to:
  /// **'Invite to Project'**
  String get collaboratorsActionInvite;

  /// No description provided for @collaboratorsActionSendQuote.
  ///
  /// In en, this message translates to:
  /// **'Send Quote'**
  String get collaboratorsActionSendQuote;

  /// No description provided for @collaboratorsActionManagePermissions.
  ///
  /// In en, this message translates to:
  /// **'Manage Permissions'**
  String get collaboratorsActionManagePermissions;

  /// No description provided for @collaboratorsActionViewFiles.
  ///
  /// In en, this message translates to:
  /// **'View Shared Files'**
  String get collaboratorsActionViewFiles;

  /// No description provided for @collaboratorsStatusOnline.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get collaboratorsStatusOnline;

  /// No description provided for @collaboratorsStatusBusy.
  ///
  /// In en, this message translates to:
  /// **'Busy'**
  String get collaboratorsStatusBusy;

  /// No description provided for @collaboratorsStatusOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get collaboratorsStatusOffline;

  /// No description provided for @collaboratorInviteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Invite to project'**
  String get collaboratorInviteTooltip;

  /// No description provided for @collaboratorStartChatTooltip.
  ///
  /// In en, this message translates to:
  /// **'Start chat'**
  String get collaboratorStartChatTooltip;

  /// No description provided for @collaboratorSectionSkills.
  ///
  /// In en, this message translates to:
  /// **'Key Skills'**
  String get collaboratorSectionSkills;

  /// No description provided for @collaboratorSectionAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get collaboratorSectionAbout;

  /// No description provided for @collaboratorSectionHistory.
  ///
  /// In en, this message translates to:
  /// **'Collaboration History'**
  String get collaboratorSectionHistory;

  /// No description provided for @collaboratorSendMessage.
  ///
  /// In en, this message translates to:
  /// **'Send Message'**
  String get collaboratorSendMessage;

  /// No description provided for @collaboratorReviewsMeta.
  ///
  /// In en, this message translates to:
  /// **'{rating} • {count} reviews'**
  String collaboratorReviewsMeta(Object rating, int count);

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// No description provided for @languageDescription.
  ///
  /// In en, this message translates to:
  /// **'Automatically follows your country unless you choose a language below.'**
  String get languageDescription;

  /// No description provided for @languageSystemDefault.
  ///
  /// In en, this message translates to:
  /// **'Use device language'**
  String get languageSystemDefault;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageFrench.
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get languageFrench;

  /// No description provided for @languageDropdownHint.
  ///
  /// In en, this message translates to:
  /// **'Select a language'**
  String get languageDropdownHint;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileEditTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get profileEditTooltip;

  /// No description provided for @profileEditButton.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get profileEditButton;

  /// No description provided for @profileViewAnalytics.
  ///
  /// In en, this message translates to:
  /// **'View Analytics'**
  String get profileViewAnalytics;

  /// No description provided for @profileInvitationNotifications.
  ///
  /// In en, this message translates to:
  /// **'Invitation Notifications'**
  String get profileInvitationNotifications;

  /// No description provided for @profileContactSection.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get profileContactSection;

  /// No description provided for @profileFocusAreaSection.
  ///
  /// In en, this message translates to:
  /// **'Focus Area'**
  String get profileFocusAreaSection;

  /// No description provided for @profileEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get profileEmailLabel;

  /// No description provided for @profilePhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get profilePhoneLabel;

  /// No description provided for @profileLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get profileLocationLabel;

  /// No description provided for @commonOr.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get commonOr;

  /// No description provided for @commonEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get commonEmailAddress;

  /// No description provided for @commonPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get commonPassword;

  /// No description provided for @commonEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter Password'**
  String get commonEnterPassword;

  /// No description provided for @commonNewPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get commonNewPassword;

  /// No description provided for @commonConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get commonConfirmPassword;

  /// No description provided for @commonName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get commonName;

  /// No description provided for @commonFullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get commonFullName;

  /// No description provided for @commonRoleTitle.
  ///
  /// In en, this message translates to:
  /// **'Role / Title'**
  String get commonRoleTitle;

  /// No description provided for @commonLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get commonLocation;

  /// No description provided for @commonFocusAreas.
  ///
  /// In en, this message translates to:
  /// **'Focus areas'**
  String get commonFocusAreas;

  /// No description provided for @commonUploadPhoto.
  ///
  /// In en, this message translates to:
  /// **'Upload photo'**
  String get commonUploadPhoto;

  /// No description provided for @commonSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get commonSkip;

  /// No description provided for @commonSearchContacts.
  ///
  /// In en, this message translates to:
  /// **'Search contacts by name or project'**
  String get commonSearchContacts;

  /// No description provided for @commonSearchThreads.
  ///
  /// In en, this message translates to:
  /// **'Search threads or contacts'**
  String get commonSearchThreads;

  /// No description provided for @commonAllFilter.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get commonAllFilter;

  /// No description provided for @commonClientsFilter.
  ///
  /// In en, this message translates to:
  /// **'Clients'**
  String get commonClientsFilter;

  /// No description provided for @commonCollaboratorsFilter.
  ///
  /// In en, this message translates to:
  /// **'Collaborators'**
  String get commonCollaboratorsFilter;

  /// No description provided for @commonProjectsFilter.
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get commonProjectsFilter;

  /// No description provided for @commonContactsFilter.
  ///
  /// In en, this message translates to:
  /// **'Contacts'**
  String get commonContactsFilter;

  /// No description provided for @commonAddContact.
  ///
  /// In en, this message translates to:
  /// **'Add contact'**
  String get commonAddContact;

  /// No description provided for @commonComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Image picker coming soon.'**
  String get commonComingSoon;

  /// No description provided for @commonFocusPlanning.
  ///
  /// In en, this message translates to:
  /// **'Planning'**
  String get commonFocusPlanning;

  /// No description provided for @commonFocusEngineering.
  ///
  /// In en, this message translates to:
  /// **'Engineering'**
  String get commonFocusEngineering;

  /// No description provided for @commonFocusFinance.
  ///
  /// In en, this message translates to:
  /// **'Finance'**
  String get commonFocusFinance;

  /// No description provided for @commonFocusLogistics.
  ///
  /// In en, this message translates to:
  /// **'Logistics'**
  String get commonFocusLogistics;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The best way to manage your projects.'**
  String get welcomeSubtitle;

  /// No description provided for @welcomeCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create New Account'**
  String get welcomeCreateAccount;

  /// No description provided for @welcomeLogin.
  ///
  /// In en, this message translates to:
  /// **'Login Now'**
  String get welcomeLogin;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Login Now'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and password to login'**
  String get loginSubtitle;

  /// No description provided for @loginForgotPrompt.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get loginForgotPrompt;

  /// No description provided for @loginResetLink.
  ///
  /// In en, this message translates to:
  /// **'Reset now'**
  String get loginResetLink;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get loginButton;

  /// No description provided for @loginSocialGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get loginSocialGoogle;

  /// No description provided for @loginSocialApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get loginSocialApple;

  /// No description provided for @loginNoAccountPrompt.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get loginNoAccountPrompt;

  /// No description provided for @loginCreateNow.
  ///
  /// In en, this message translates to:
  /// **'Create Now'**
  String get loginCreateNow;

  /// No description provided for @registrationTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Your Account'**
  String get registrationTitle;

  /// No description provided for @registrationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Please fill in your details to create an account'**
  String get registrationSubtitle;

  /// No description provided for @registrationButton.
  ///
  /// In en, this message translates to:
  /// **'Save & Next'**
  String get registrationButton;

  /// No description provided for @registrationAlreadyPrompt.
  ///
  /// In en, this message translates to:
  /// **'Already a Subscriber?'**
  String get registrationAlreadyPrompt;

  /// No description provided for @registrationLoginNow.
  ///
  /// In en, this message translates to:
  /// **'Login Now'**
  String get registrationLoginNow;

  /// No description provided for @forgotTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get forgotTitle;

  /// No description provided for @forgotSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email below to reset your password'**
  String get forgotSubtitle;

  /// No description provided for @forgotButton.
  ///
  /// In en, this message translates to:
  /// **'Request OTP Verify'**
  String get forgotButton;

  /// No description provided for @verifyTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify Email by OTP'**
  String get verifyTitle;

  /// No description provided for @verifySubtitle.
  ///
  /// In en, this message translates to:
  /// **'A verification code sent on your email address'**
  String get verifySubtitle;

  /// No description provided for @verifyConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get verifyConfirm;

  /// No description provided for @verifyNoCode.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive a code?'**
  String get verifyNoCode;

  /// No description provided for @verifyResendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend in {time}'**
  String verifyResendIn(Object time);

  /// No description provided for @verifyResendNow.
  ///
  /// In en, this message translates to:
  /// **'Resend Now'**
  String get verifyResendNow;

  /// No description provided for @resetTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter New Password'**
  String get resetTitle;

  /// No description provided for @resetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your new password that you would like to use'**
  String get resetSubtitle;

  /// No description provided for @resetButton.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get resetButton;

  /// No description provided for @setupTitle.
  ///
  /// In en, this message translates to:
  /// **'Set up profile'**
  String get setupTitle;

  /// No description provided for @setupHeadline.
  ///
  /// In en, this message translates to:
  /// **'Personalise your workspace'**
  String get setupHeadline;

  /// No description provided for @setupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add a face, role, and focus areas so teammates know who you are.'**
  String get setupSubtitle;

  /// No description provided for @setupFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish Setup'**
  String get setupFinish;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navFinance.
  ///
  /// In en, this message translates to:
  /// **'Finance'**
  String get navFinance;

  /// No description provided for @navCrm.
  ///
  /// In en, this message translates to:
  /// **'CRM'**
  String get navCrm;

  /// No description provided for @navCheckout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get navCheckout;

  /// No description provided for @navManagement.
  ///
  /// In en, this message translates to:
  /// **'Management'**
  String get navManagement;

  /// No description provided for @chatsTitle.
  ///
  /// In en, this message translates to:
  /// **'Project threads'**
  String get chatsTitle;

  /// No description provided for @chatsBadgeProject.
  ///
  /// In en, this message translates to:
  /// **'Project'**
  String get chatsBadgeProject;

  /// No description provided for @chatsBadgeContact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get chatsBadgeContact;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hey, {name}'**
  String homeGreeting(Object name);

  /// No description provided for @homePulseSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Here is your workspace pulse for today.'**
  String get homePulseSubtitle;

  /// No description provided for @homePulseDescription.
  ///
  /// In en, this message translates to:
  /// **'Keep projects, finances, and team signals aligned.'**
  String get homePulseDescription;

  /// No description provided for @homeFinanceOverviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Finance overview'**
  String get homeFinanceOverviewTitle;

  /// No description provided for @homeFinanceCollected.
  ///
  /// In en, this message translates to:
  /// **'Collected this period'**
  String get homeFinanceCollected;

  /// No description provided for @homeFinanceUnpaid.
  ///
  /// In en, this message translates to:
  /// **'Unpaid invoices'**
  String get homeFinanceUnpaid;

  /// No description provided for @homeFinanceCreateInvoice.
  ///
  /// In en, this message translates to:
  /// **'Create invoice'**
  String get homeFinanceCreateInvoice;

  /// No description provided for @homeFinanceOpenWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Open Finance workspace'**
  String get homeFinanceOpenWorkspace;

  /// No description provided for @homeProjectsHealth.
  ///
  /// In en, this message translates to:
  /// **'Projects health'**
  String get homeProjectsHealth;

  /// No description provided for @homeProjectsActiveLabel.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get homeProjectsActiveLabel;

  /// No description provided for @homeProjectsActiveSubtitle.
  ///
  /// In en, this message translates to:
  /// **'in motion'**
  String get homeProjectsActiveSubtitle;

  /// No description provided for @homeProjectsLateLabel.
  ///
  /// In en, this message translates to:
  /// **'Late'**
  String get homeProjectsLateLabel;

  /// No description provided for @homeProjectsLateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'needs attention'**
  String get homeProjectsLateSubtitle;

  /// No description provided for @homeProjectsCompletedLabel.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get homeProjectsCompletedLabel;

  /// No description provided for @homeProjectsCompletedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'this month'**
  String get homeProjectsCompletedSubtitle;

  /// No description provided for @homeCreateProject.
  ///
  /// In en, this message translates to:
  /// **'Create project'**
  String get homeCreateProject;

  /// No description provided for @homeOpenProjects.
  ///
  /// In en, this message translates to:
  /// **'Open Projects dashboard'**
  String get homeOpenProjects;

  /// No description provided for @homeMessagesTitle.
  ///
  /// In en, this message translates to:
  /// **'Messages & activity'**
  String get homeMessagesTitle;

  /// No description provided for @homeMessagesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No recent activity. New replies will surface here.'**
  String get homeMessagesEmpty;

  /// No description provided for @homeOpenMessages.
  ///
  /// In en, this message translates to:
  /// **'Open Messages'**
  String get homeOpenMessages;

  /// No description provided for @homeVariationLabel.
  ///
  /// In en, this message translates to:
  /// **'{value}% vs last month'**
  String homeVariationLabel(Object value);

  /// No description provided for @homeUnpaidWaiting.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one {# invoice waiting} other {# invoices waiting}}'**
  String homeUnpaidWaiting(int count);

  /// No description provided for @homeUnreadCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one {# unread} other {# unread}}'**
  String homeUnreadCount(int count);

  /// No description provided for @homeAuthorYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get homeAuthorYou;

  /// No description provided for @homeCollaboratorFallback.
  ///
  /// In en, this message translates to:
  /// **'Collaborator'**
  String get homeCollaboratorFallback;

  /// No description provided for @relativeTimeJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get relativeTimeJustNow;

  /// No description provided for @relativeTimeMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes, plural, one {# min ago} other {# mins ago}}'**
  String relativeTimeMinutes(int minutes);

  /// No description provided for @relativeTimeHours.
  ///
  /// In en, this message translates to:
  /// **'{hours, plural, one {# hr ago} other {# hrs ago}}'**
  String relativeTimeHours(int hours);

  /// No description provided for @relativeTimeDays.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, one {# day ago} other {# days ago}}'**
  String relativeTimeDays(int days);

  /// No description provided for @crmTitle.
  ///
  /// In en, this message translates to:
  /// **'Contacts'**
  String get crmTitle;

  /// No description provided for @crmSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Centralize clients and collaborators in one place.'**
  String get crmSubtitle;

  /// No description provided for @calendarPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Calendar Screen'**
  String get calendarPlaceholder;

  /// No description provided for @vehiclesTitle.
  ///
  /// In en, this message translates to:
  /// **'Vehicles'**
  String get vehiclesTitle;

  /// No description provided for @vehiclesPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Vehicles Screen'**
  String get vehiclesPlaceholder;

  /// No description provided for @sharedFilesTitle.
  ///
  /// In en, this message translates to:
  /// **'Shared files'**
  String get sharedFilesTitle;

  /// No description provided for @sharedFilesFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get sharedFilesFilterAll;

  /// No description provided for @sharedFilesFilterPdf.
  ///
  /// In en, this message translates to:
  /// **'PDF'**
  String get sharedFilesFilterPdf;

  /// No description provided for @sharedFilesFilterImage.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get sharedFilesFilterImage;

  /// No description provided for @sharedFilesFilterSpreadsheet.
  ///
  /// In en, this message translates to:
  /// **'Spreadsheet'**
  String get sharedFilesFilterSpreadsheet;

  /// No description provided for @sharedFilesUploadCta.
  ///
  /// In en, this message translates to:
  /// **'+ Upload file'**
  String get sharedFilesUploadCta;

  /// No description provided for @sharedFilesFileMeta.
  ///
  /// In en, this message translates to:
  /// **'{type} • {size}'**
  String sharedFilesFileMeta(Object type, Object size);

  /// No description provided for @sharedFilesUploadedMeta.
  ///
  /// In en, this message translates to:
  /// **'Uploaded by {uploader} · {timestamp}'**
  String sharedFilesUploadedMeta(Object uploader, Object timestamp);

  /// No description provided for @analyticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analyticsTitle;

  /// No description provided for @analyticsUpdatedLabel.
  ///
  /// In en, this message translates to:
  /// **'Updated {date}'**
  String analyticsUpdatedLabel(Object date);

  /// No description provided for @analyticsMetricCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed this month'**
  String get analyticsMetricCompleted;

  /// No description provided for @analyticsMetricAvgDuration.
  ///
  /// In en, this message translates to:
  /// **'Avg duration per project'**
  String get analyticsMetricAvgDuration;

  /// No description provided for @analyticsAvgDurationValue.
  ///
  /// In en, this message translates to:
  /// **'{days} days'**
  String analyticsAvgDurationValue(Object days);

  /// No description provided for @analyticsAvgDurationEmpty.
  ///
  /// In en, this message translates to:
  /// **'No completed ranges yet'**
  String get analyticsAvgDurationEmpty;

  /// No description provided for @analyticsMetricOnTime.
  ///
  /// In en, this message translates to:
  /// **'On-time delivery rate'**
  String get analyticsMetricOnTime;

  /// No description provided for @analyticsValueNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get analyticsValueNotAvailable;

  /// No description provided for @analyticsPercentValue.
  ///
  /// In en, this message translates to:
  /// **'{percent}%'**
  String analyticsPercentValue(Object percent);

  /// No description provided for @analyticsOnTimeHint.
  ///
  /// In en, this message translates to:
  /// **'Needs deadlines + completion times'**
  String get analyticsOnTimeHint;

  /// No description provided for @analyticsMetricRevenue.
  ///
  /// In en, this message translates to:
  /// **'Total revenue'**
  String get analyticsMetricRevenue;

  /// No description provided for @analyticsRevenueHint.
  ///
  /// In en, this message translates to:
  /// **'Sync with Finance module'**
  String get analyticsRevenueHint;

  /// No description provided for @analyticsInsightsTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick insights'**
  String get analyticsInsightsTitle;

  /// No description provided for @analyticsInsightTotalProjects.
  ///
  /// In en, this message translates to:
  /// **'Total projects'**
  String get analyticsInsightTotalProjects;

  /// No description provided for @analyticsInsightCompletedProjects.
  ///
  /// In en, this message translates to:
  /// **'Completed projects'**
  String get analyticsInsightCompletedProjects;

  /// No description provided for @analyticsInsightInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get analyticsInsightInProgress;

  /// No description provided for @checkoutFeatureTapTitle.
  ///
  /// In en, this message translates to:
  /// **'Tap to Pay'**
  String get checkoutFeatureTapTitle;

  /// No description provided for @checkoutFeatureTapDescription.
  ///
  /// In en, this message translates to:
  /// **'Instant contactless payments from any Rush device.'**
  String get checkoutFeatureTapDescription;

  /// No description provided for @checkoutFeatureCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Card payments'**
  String get checkoutFeatureCardTitle;

  /// No description provided for @checkoutFeatureCardDescription.
  ///
  /// In en, this message translates to:
  /// **'Accept major debit & credit cards with adaptive fees.'**
  String get checkoutFeatureCardDescription;

  /// No description provided for @checkoutFeatureQrTitle.
  ///
  /// In en, this message translates to:
  /// **'QR payments'**
  String get checkoutFeatureQrTitle;

  /// No description provided for @checkoutFeatureQrDescription.
  ///
  /// In en, this message translates to:
  /// **'Share payable QR codes in-person or on screen.'**
  String get checkoutFeatureQrDescription;

  /// No description provided for @checkoutFeatureLinksTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment links'**
  String get checkoutFeatureLinksTitle;

  /// No description provided for @checkoutFeatureLinksDescription.
  ///
  /// In en, this message translates to:
  /// **'Send branded links that confirm payment automatically.'**
  String get checkoutFeatureLinksDescription;

  /// No description provided for @checkoutFeatureCatalogTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick catalog'**
  String get checkoutFeatureCatalogTitle;

  /// No description provided for @checkoutFeatureCatalogDescription.
  ///
  /// In en, this message translates to:
  /// **'Create saved services and bundles for fast checkout.'**
  String get checkoutFeatureCatalogDescription;

  /// No description provided for @checkoutFeatureReceiptTitle.
  ///
  /// In en, this message translates to:
  /// **'Automatic receipt'**
  String get checkoutFeatureReceiptTitle;

  /// No description provided for @checkoutFeatureReceiptDescription.
  ///
  /// In en, this message translates to:
  /// **'Email or text confirmations without leaving the screen.'**
  String get checkoutFeatureReceiptDescription;

  /// No description provided for @checkoutRoadmapStep1Label.
  ///
  /// In en, this message translates to:
  /// **'Step 1'**
  String get checkoutRoadmapStep1Label;

  /// No description provided for @checkoutRoadmapStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Unified checkout shell'**
  String get checkoutRoadmapStep1Title;

  /// No description provided for @checkoutRoadmapStep1Description.
  ///
  /// In en, this message translates to:
  /// **'Centralize quotes, invoices, and payment orchestration.'**
  String get checkoutRoadmapStep1Description;

  /// No description provided for @checkoutRoadmapStep2Label.
  ///
  /// In en, this message translates to:
  /// **'Step 2'**
  String get checkoutRoadmapStep2Label;

  /// No description provided for @checkoutRoadmapStep2Title.
  ///
  /// In en, this message translates to:
  /// **'Payment method rollout'**
  String get checkoutRoadmapStep2Title;

  /// No description provided for @checkoutRoadmapStep2Description.
  ///
  /// In en, this message translates to:
  /// **'Launch Tap to Pay, QR, and payment links sequentially.'**
  String get checkoutRoadmapStep2Description;

  /// No description provided for @checkoutRoadmapStep3Label.
  ///
  /// In en, this message translates to:
  /// **'Step 3'**
  String get checkoutRoadmapStep3Label;

  /// No description provided for @checkoutRoadmapStep3Title.
  ///
  /// In en, this message translates to:
  /// **'Automation & insights'**
  String get checkoutRoadmapStep3Title;

  /// No description provided for @checkoutRoadmapStep3Description.
  ///
  /// In en, this message translates to:
  /// **'Activate receipts, reminders, and live settlement reports.'**
  String get checkoutRoadmapStep3Description;

  /// No description provided for @checkoutHeroPill.
  ///
  /// In en, this message translates to:
  /// **'Checkout is brewing'**
  String get checkoutHeroPill;

  /// No description provided for @checkoutHeroHeadline.
  ///
  /// In en, this message translates to:
  /// **'Payments without the patchwork.'**
  String get checkoutHeroHeadline;

  /// No description provided for @checkoutHeroBody.
  ///
  /// In en, this message translates to:
  /// **'Tap, scan, or share a link. Checkout unifies every payment action inside Rush.'**
  String get checkoutHeroBody;

  /// No description provided for @checkoutHeroBadgeTitle.
  ///
  /// In en, this message translates to:
  /// **'Now building'**
  String get checkoutHeroBadgeTitle;

  /// No description provided for @checkoutHeroBadgeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Seamless checkout journeys for Rush teams and clients.'**
  String get checkoutHeroBadgeSubtitle;

  /// No description provided for @checkoutRoadmapTitle.
  ///
  /// In en, this message translates to:
  /// **'Rollout timeline'**
  String get checkoutRoadmapTitle;

  /// No description provided for @checkoutEarlyAccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Want early access?'**
  String get checkoutEarlyAccessTitle;

  /// No description provided for @checkoutEarlyAccessBody.
  ///
  /// In en, this message translates to:
  /// **'We will invite a small crew to pilot Checkout features before the public launch.'**
  String get checkoutEarlyAccessBody;

  /// No description provided for @checkoutEarlyAccessContact.
  ///
  /// In en, this message translates to:
  /// **'Reach out to your Rush partner manager to reserve a slot.'**
  String get checkoutEarlyAccessContact;

  /// No description provided for @collaborationChatTitleFallback.
  ///
  /// In en, this message translates to:
  /// **'Collaboration chat'**
  String get collaborationChatTitleFallback;

  /// No description provided for @collaborationChatSubtitleFallback.
  ///
  /// In en, this message translates to:
  /// **'Tap to view contact detail'**
  String get collaborationChatSubtitleFallback;

  /// No description provided for @collaborationChatSharedFilesTooltip.
  ///
  /// In en, this message translates to:
  /// **'Shared files'**
  String get collaborationChatSharedFilesTooltip;

  /// No description provided for @collaborationChatAddAttachment.
  ///
  /// In en, this message translates to:
  /// **'Add attachment'**
  String get collaborationChatAddAttachment;

  /// No description provided for @collaborationChatComposerHint.
  ///
  /// In en, this message translates to:
  /// **'Write a message…'**
  String get collaborationChatComposerHint;

  /// No description provided for @collaborationChatSendMessage.
  ///
  /// In en, this message translates to:
  /// **'Send message'**
  String get collaborationChatSendMessage;

  /// No description provided for @collaborationChatAttachTitle.
  ///
  /// In en, this message translates to:
  /// **'Attach from'**
  String get collaborationChatAttachTitle;

  /// No description provided for @collaborationChatAttachPhoto.
  ///
  /// In en, this message translates to:
  /// **'Photo or image'**
  String get collaborationChatAttachPhoto;

  /// No description provided for @collaborationChatAttachDocument.
  ///
  /// In en, this message translates to:
  /// **'Document'**
  String get collaborationChatAttachDocument;

  /// No description provided for @collaborationChatAttachPdf.
  ///
  /// In en, this message translates to:
  /// **'PDF'**
  String get collaborationChatAttachPdf;

  /// No description provided for @collaborationChatAttachCamera.
  ///
  /// In en, this message translates to:
  /// **'Capture from camera'**
  String get collaborationChatAttachCamera;

  /// No description provided for @collaborationChatReactTooltip.
  ///
  /// In en, this message translates to:
  /// **'React to message'**
  String get collaborationChatReactTooltip;

  /// No description provided for @contactDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact detail'**
  String get contactDetailTitle;

  /// No description provided for @contactDetailStartChat.
  ///
  /// In en, this message translates to:
  /// **'Start chat'**
  String get contactDetailStartChat;

  /// No description provided for @contactDetailSectionContact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contactDetailSectionContact;

  /// No description provided for @contactDetailSectionExpertise.
  ///
  /// In en, this message translates to:
  /// **'Expertise'**
  String get contactDetailSectionExpertise;

  /// No description provided for @contactDetailSectionProjects.
  ///
  /// In en, this message translates to:
  /// **'Projects together'**
  String get contactDetailSectionProjects;

  /// No description provided for @contactDetailSectionNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get contactDetailSectionNotes;

  /// No description provided for @contactDetailEditContact.
  ///
  /// In en, this message translates to:
  /// **'Edit contact'**
  String get contactDetailEditContact;

  /// No description provided for @contactDetailCreateProject.
  ///
  /// In en, this message translates to:
  /// **'Create project'**
  String get contactDetailCreateProject;

  /// No description provided for @contactDetailSendQuote.
  ///
  /// In en, this message translates to:
  /// **'Send quote'**
  String get contactDetailSendQuote;

  /// No description provided for @contactDetailCreateInvoice.
  ///
  /// In en, this message translates to:
  /// **'Create invoice'**
  String get contactDetailCreateInvoice;

  /// No description provided for @createProjectSelectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get createProjectSelectDate;

  /// No description provided for @createProjectCategoryEventManagement.
  ///
  /// In en, this message translates to:
  /// **'Event management'**
  String get createProjectCategoryEventManagement;

  /// No description provided for @createProjectCategoryPhotography.
  ///
  /// In en, this message translates to:
  /// **'Photography'**
  String get createProjectCategoryPhotography;

  /// No description provided for @createProjectCategoryMarketing.
  ///
  /// In en, this message translates to:
  /// **'Marketing'**
  String get createProjectCategoryMarketing;

  /// No description provided for @createProjectCategoryLogistics.
  ///
  /// In en, this message translates to:
  /// **'Logistics'**
  String get createProjectCategoryLogistics;

  /// No description provided for @createProjectCategoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get createProjectCategoryOther;

  /// No description provided for @createProjectRoleOwner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get createProjectRoleOwner;

  /// No description provided for @createProjectRoleEditor.
  ///
  /// In en, this message translates to:
  /// **'Editor'**
  String get createProjectRoleEditor;

  /// No description provided for @createProjectRoleViewer.
  ///
  /// In en, this message translates to:
  /// **'Viewer'**
  String get createProjectRoleViewer;

  /// No description provided for @createProjectDateError.
  ///
  /// In en, this message translates to:
  /// **'End date cannot be before start date'**
  String get createProjectDateError;

  /// No description provided for @createProjectTitle.
  ///
  /// In en, this message translates to:
  /// **'New Project'**
  String get createProjectTitle;

  /// No description provided for @createProjectSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set up the essentials in a few quick steps.'**
  String get createProjectSubtitle;

  /// No description provided for @createProjectFieldNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Project name'**
  String get createProjectFieldNameLabel;

  /// No description provided for @createProjectFieldNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Dupont Wedding'**
  String get createProjectFieldNameHint;

  /// No description provided for @createProjectFieldNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Project name is required'**
  String get createProjectFieldNameRequired;

  /// No description provided for @createProjectFieldClientLabel.
  ///
  /// In en, this message translates to:
  /// **'Client'**
  String get createProjectFieldClientLabel;

  /// No description provided for @createProjectFieldClientHint.
  ///
  /// In en, this message translates to:
  /// **'Client or company name'**
  String get createProjectFieldClientHint;

  /// No description provided for @createProjectFieldCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get createProjectFieldCategoryLabel;

  /// No description provided for @createProjectFieldCategoryHint.
  ///
  /// In en, this message translates to:
  /// **'Select category'**
  String get createProjectFieldCategoryHint;

  /// No description provided for @createProjectFieldStartDate.
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get createProjectFieldStartDate;

  /// No description provided for @createProjectFieldEndDate.
  ///
  /// In en, this message translates to:
  /// **'End date'**
  String get createProjectFieldEndDate;

  /// No description provided for @createProjectFieldDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get createProjectFieldDescriptionLabel;

  /// No description provided for @createProjectFieldDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Add a short brief for your team...'**
  String get createProjectFieldDescriptionHint;

  /// No description provided for @createProjectInviteTitle.
  ///
  /// In en, this message translates to:
  /// **'Invite team members'**
  String get createProjectInviteTitle;

  /// No description provided for @createProjectInviteDescription.
  ///
  /// In en, this message translates to:
  /// **'Assign roles to control access.'**
  String get createProjectInviteDescription;

  /// No description provided for @createProjectCustomRolePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Custom role (e.g. Coordinator)'**
  String get createProjectCustomRolePlaceholder;

  /// No description provided for @createProjectAddRole.
  ///
  /// In en, this message translates to:
  /// **'Add role'**
  String get createProjectAddRole;

  /// No description provided for @createProjectAddMember.
  ///
  /// In en, this message translates to:
  /// **'Add member'**
  String get createProjectAddMember;

  /// No description provided for @createProjectInviteExternalTitle.
  ///
  /// In en, this message translates to:
  /// **'Invite external collaborator'**
  String get createProjectInviteExternalTitle;

  /// No description provided for @createProjectInviteExternalDescription.
  ///
  /// In en, this message translates to:
  /// **'Send a secure link via email or WhatsApp for limited access.'**
  String get createProjectInviteExternalDescription;

  /// No description provided for @createProjectPreviewLink.
  ///
  /// In en, this message translates to:
  /// **'Preview link: {link}'**
  String createProjectPreviewLink(Object link);

  /// No description provided for @createProjectPrimaryCta.
  ///
  /// In en, this message translates to:
  /// **'Create project'**
  String get createProjectPrimaryCta;

  /// No description provided for @financeNewQuoteTooltip.
  ///
  /// In en, this message translates to:
  /// **'New quote'**
  String get financeNewQuoteTooltip;

  /// No description provided for @financePrimaryCta.
  ///
  /// In en, this message translates to:
  /// **'Create a quote / invoice'**
  String get financePrimaryCta;

  /// No description provided for @financeBalanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Global balance'**
  String get financeBalanceTitle;

  /// No description provided for @financeUnpaidTitle.
  ///
  /// In en, this message translates to:
  /// **'Unpaid invoices'**
  String get financeUnpaidTitle;

  /// No description provided for @financeUnpaidMeta.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one {# invoice} other {# invoices}} · {amount}'**
  String financeUnpaidMeta(int count, Object amount);

  /// No description provided for @financeUnpaidReminderCta.
  ///
  /// In en, this message translates to:
  /// **'Send reminder'**
  String get financeUnpaidReminderCta;

  /// No description provided for @financeLatestDocumentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Latest documents'**
  String get financeLatestDocumentsTitle;

  /// No description provided for @financeQuickAccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick access'**
  String get financeQuickAccessTitle;

  /// No description provided for @financeQuickAccessCreateQuote.
  ///
  /// In en, this message translates to:
  /// **'Create quote'**
  String get financeQuickAccessCreateQuote;

  /// No description provided for @financeQuickAccessReporting.
  ///
  /// In en, this message translates to:
  /// **'Reporting'**
  String get financeQuickAccessReporting;

  /// No description provided for @financeQuickAccessPreview.
  ///
  /// In en, this message translates to:
  /// **'Preview (temp)'**
  String get financeQuickAccessPreview;

  /// No description provided for @financeQuickAccessSignature.
  ///
  /// In en, this message translates to:
  /// **'Signature (temp)'**
  String get financeQuickAccessSignature;

  /// No description provided for @financeQuickAccessInvoice.
  ///
  /// In en, this message translates to:
  /// **'Invoice (temp)'**
  String get financeQuickAccessInvoice;

  /// No description provided for @financeMetricDraftQuotes.
  ///
  /// In en, this message translates to:
  /// **'Draft quotes'**
  String get financeMetricDraftQuotes;

  /// No description provided for @financeMetricPendingSignatures.
  ///
  /// In en, this message translates to:
  /// **'Pending signatures'**
  String get financeMetricPendingSignatures;

  /// No description provided for @financeMetricSignedQuotes.
  ///
  /// In en, this message translates to:
  /// **'Signed quotes'**
  String get financeMetricSignedQuotes;

  /// No description provided for @financeMetricDeclinedQuotes.
  ///
  /// In en, this message translates to:
  /// **'Declined quotes'**
  String get financeMetricDeclinedQuotes;

  /// No description provided for @financeMetricUnpaidInvoices.
  ///
  /// In en, this message translates to:
  /// **'Unpaid invoices'**
  String get financeMetricUnpaidInvoices;

  /// No description provided for @financeMetricPaidInvoices.
  ///
  /// In en, this message translates to:
  /// **'Paid invoices'**
  String get financeMetricPaidInvoices;

  /// No description provided for @financePipelineTitle.
  ///
  /// In en, this message translates to:
  /// **'Pipeline overview'**
  String get financePipelineTitle;

  /// No description provided for @financeUpcomingTitle.
  ///
  /// In en, this message translates to:
  /// **'Upcoming / overdue invoices'**
  String get financeUpcomingTitle;

  /// No description provided for @financeUpcomingEmpty.
  ///
  /// In en, this message translates to:
  /// **'No unpaid invoices with due dates'**
  String get financeUpcomingEmpty;

  /// No description provided for @financeUpcomingBadgeOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue {days}d'**
  String financeUpcomingBadgeOverdue(int days);

  /// No description provided for @financeUpcomingBadgeDueSoon.
  ///
  /// In en, this message translates to:
  /// **'Due soon'**
  String get financeUpcomingBadgeDueSoon;

  /// No description provided for @financeUpcomingBadgeDueIn.
  ///
  /// In en, this message translates to:
  /// **'Due in {days}d'**
  String financeUpcomingBadgeDueIn(int days);

  /// No description provided for @financeUpcomingBadgeDueToday.
  ///
  /// In en, this message translates to:
  /// **'Due today'**
  String get financeUpcomingBadgeDueToday;

  /// No description provided for @financeUpcomingInvoiceLabel.
  ///
  /// In en, this message translates to:
  /// **'Invoice #{id} · {amount}'**
  String financeUpcomingInvoiceLabel(Object id, Object amount);

  /// No description provided for @financeRecentTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent activity'**
  String get financeRecentTitle;

  /// No description provided for @financeRecentQuote.
  ///
  /// In en, this message translates to:
  /// **'Quote {id} → {status}'**
  String financeRecentQuote(Object id, Object status);

  /// No description provided for @financeRecentInvoice.
  ///
  /// In en, this message translates to:
  /// **'Invoice {id} → {status}'**
  String financeRecentInvoice(Object id, Object status);

  /// No description provided for @financeRecentEmpty.
  ///
  /// In en, this message translates to:
  /// **'No recent activity'**
  String get financeRecentEmpty;

  /// No description provided for @projectNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Project not found'**
  String get projectNotFoundTitle;

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// No description provided for @projectTimelineHeaderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Drag tasks on the timeline to reschedule'**
  String get projectTimelineHeaderSubtitle;

  /// No description provided for @projectTimelineUnscheduledTitle.
  ///
  /// In en, this message translates to:
  /// **'Needs scheduling'**
  String get projectTimelineUnscheduledTitle;

  /// No description provided for @projectTimelineUnscheduledHint.
  ///
  /// In en, this message translates to:
  /// **'Set start and due dates to place this task on the timeline.'**
  String get projectTimelineUnscheduledHint;

  /// No description provided for @taskStatusPlanned.
  ///
  /// In en, this message translates to:
  /// **'Planned'**
  String get taskStatusPlanned;

  /// No description provided for @taskStatusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get taskStatusInProgress;

  /// No description provided for @taskStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get taskStatusCompleted;

  /// No description provided for @taskStatusDeferred.
  ///
  /// In en, this message translates to:
  /// **'Deferred'**
  String get taskStatusDeferred;

  /// No description provided for @invitationOnboardingMissing.
  ///
  /// In en, this message translates to:
  /// **'Invitation not found or has expired.'**
  String get invitationOnboardingMissing;

  /// No description provided for @invitationOnboardingCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re in'**
  String get invitationOnboardingCompleteTitle;

  /// No description provided for @invitationNotificationsViewProject.
  ///
  /// In en, this message translates to:
  /// **'View project'**
  String get invitationNotificationsViewProject;

  /// No description provided for @invitationOnboardingStepAccount.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get invitationOnboardingStepAccount;

  /// No description provided for @invitationOnboardingStepProfile.
  ///
  /// In en, this message translates to:
  /// **'Complete your profile'**
  String get invitationOnboardingStepProfile;

  /// No description provided for @invitationOnboardingStepReview.
  ///
  /// In en, this message translates to:
  /// **'Review & join project'**
  String get invitationOnboardingStepReview;

  /// No description provided for @invitationOnboardingAcceptTermsError.
  ///
  /// In en, this message translates to:
  /// **'Please accept the terms to continue.'**
  String get invitationOnboardingAcceptTermsError;

  /// No description provided for @invitationOnboardingWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome aboard, {name}!'**
  String invitationOnboardingWelcome(Object name);

  /// No description provided for @invitationOnboardingContinueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get invitationOnboardingContinueButton;

  /// No description provided for @invitationOnboardingJoinButton.
  ///
  /// In en, this message translates to:
  /// **'Join project'**
  String get invitationOnboardingJoinButton;

  /// No description provided for @invitationOnboardingAccountIntro.
  ///
  /// In en, this message translates to:
  /// **'Welcome! Create a password to activate access.'**
  String get invitationOnboardingAccountIntro;

  /// No description provided for @invitationOnboardingWorkEmail.
  ///
  /// In en, this message translates to:
  /// **'Work email'**
  String get invitationOnboardingWorkEmail;

  /// No description provided for @invitationOnboardingCreatePassword.
  ///
  /// In en, this message translates to:
  /// **'Create password'**
  String get invitationOnboardingCreatePassword;

  /// No description provided for @invitationOnboardingPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Use at least 8 characters.'**
  String get invitationOnboardingPasswordHint;

  /// No description provided for @invitationOnboardingConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get invitationOnboardingConfirmPassword;

  /// No description provided for @invitationOnboardingPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get invitationOnboardingPasswordMismatch;

  /// No description provided for @invitationOnboardingTermsAgreement.
  ///
  /// In en, this message translates to:
  /// **'I agree to the Rush Manage collaboration terms.'**
  String get invitationOnboardingTermsAgreement;

  /// No description provided for @invitationOnboardingProfileIntro.
  ///
  /// In en, this message translates to:
  /// **'Tell everyone how to reach you and what you do.'**
  String get invitationOnboardingProfileIntro;

  /// No description provided for @invitationOnboardingFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get invitationOnboardingFullName;

  /// No description provided for @invitationOnboardingFullNameError.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name.'**
  String get invitationOnboardingFullNameError;

  /// No description provided for @invitationOnboardingRoleLabel.
  ///
  /// In en, this message translates to:
  /// **'Role / Title'**
  String get invitationOnboardingRoleLabel;

  /// No description provided for @invitationOnboardingRoleError.
  ///
  /// In en, this message translates to:
  /// **'Enter your role for this project.'**
  String get invitationOnboardingRoleError;

  /// No description provided for @invitationOnboardingLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location (optional)'**
  String get invitationOnboardingLocationLabel;

  /// No description provided for @invitationOnboardingReviewIntro.
  ///
  /// In en, this message translates to:
  /// **'You\'re almost set! Review the project details before joining.'**
  String get invitationOnboardingReviewIntro;

  /// No description provided for @invitationOnboardingReviewRole.
  ///
  /// In en, this message translates to:
  /// **'You will join as {role}.'**
  String invitationOnboardingReviewRole(Object role);

  /// No description provided for @financeCreateQuoteTitle.
  ///
  /// In en, this message translates to:
  /// **'Create quote'**
  String get financeCreateQuoteTitle;

  /// No description provided for @financeCreateQuoteSectionProject.
  ///
  /// In en, this message translates to:
  /// **'Project information'**
  String get financeCreateQuoteSectionProject;

  /// No description provided for @financeCreateQuoteFieldProjectNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Project name'**
  String get financeCreateQuoteFieldProjectNameLabel;

  /// No description provided for @financeCreateQuoteFieldProjectNameHint.
  ///
  /// In en, this message translates to:
  /// **'Name or reference for this quote'**
  String get financeCreateQuoteFieldProjectNameHint;

  /// No description provided for @financeCreateQuoteFieldScopeLabel.
  ///
  /// In en, this message translates to:
  /// **'Scope & services'**
  String get financeCreateQuoteFieldScopeLabel;

  /// No description provided for @financeCreateQuoteFieldScopeHint.
  ///
  /// In en, this message translates to:
  /// **'Describe the services, deliverables, or context'**
  String get financeCreateQuoteFieldScopeHint;

  /// No description provided for @financeCreateQuoteSectionPricing.
  ///
  /// In en, this message translates to:
  /// **'Pricing'**
  String get financeCreateQuoteSectionPricing;

  /// No description provided for @financeCreateQuoteFieldAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get financeCreateQuoteFieldAmountLabel;

  /// No description provided for @financeCreateQuoteFieldAmountHint.
  ///
  /// In en, this message translates to:
  /// **'Enter total amount'**
  String get financeCreateQuoteFieldAmountHint;

  /// No description provided for @financeCreateQuoteFieldCurrencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get financeCreateQuoteFieldCurrencyLabel;

  /// No description provided for @financeCreateQuoteFieldPaymentTermsLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment terms'**
  String get financeCreateQuoteFieldPaymentTermsLabel;

  /// No description provided for @financeCreateQuoteSectionDeliverables.
  ///
  /// In en, this message translates to:
  /// **'Deliverables'**
  String get financeCreateQuoteSectionDeliverables;

  /// No description provided for @financeCreateQuoteDeliverablePhotosTitle.
  ///
  /// In en, this message translates to:
  /// **'Edited photo gallery'**
  String get financeCreateQuoteDeliverablePhotosTitle;

  /// No description provided for @financeCreateQuoteDeliverablePhotosDescription.
  ///
  /// In en, this message translates to:
  /// **'Includes curated selects with base retouch.'**
  String get financeCreateQuoteDeliverablePhotosDescription;

  /// No description provided for @financeCreateQuoteDeliverableSelectsTitle.
  ///
  /// In en, this message translates to:
  /// **'Premium selects'**
  String get financeCreateQuoteDeliverableSelectsTitle;

  /// No description provided for @financeCreateQuoteDeliverableSelectsDescription.
  ///
  /// In en, this message translates to:
  /// **'Up to 20 hero edits with detailed retouching.'**
  String get financeCreateQuoteDeliverableSelectsDescription;

  /// No description provided for @financeCreateQuoteSectionNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes to client'**
  String get financeCreateQuoteSectionNotes;

  /// No description provided for @financeCreateQuoteNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Add revisions, delivery details, or payment notes'**
  String get financeCreateQuoteNotesHint;

  /// No description provided for @financeCreateQuotePrimaryCta.
  ///
  /// In en, this message translates to:
  /// **'Send quote'**
  String get financeCreateQuotePrimaryCta;

  /// No description provided for @financeCreateQuotePaymentDueReceipt.
  ///
  /// In en, this message translates to:
  /// **'Due on receipt'**
  String get financeCreateQuotePaymentDueReceipt;

  /// No description provided for @financeCreateQuotePaymentDue15.
  ///
  /// In en, this message translates to:
  /// **'Due in 15 days'**
  String get financeCreateQuotePaymentDue15;

  /// No description provided for @financeCreateQuotePaymentDue30.
  ///
  /// In en, this message translates to:
  /// **'Due in 30 days'**
  String get financeCreateQuotePaymentDue30;

  /// No description provided for @invitationNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Invitation notifications'**
  String get invitationNotificationsTitle;

  /// No description provided for @invitationNotificationsRole.
  ///
  /// In en, this message translates to:
  /// **'Invited as {role}'**
  String invitationNotificationsRole(Object role);

  /// No description provided for @invitationNotificationsMarkRead.
  ///
  /// In en, this message translates to:
  /// **'Mark as read'**
  String get invitationNotificationsMarkRead;

  /// No description provided for @invitationNotificationsStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get invitationNotificationsStatusPending;

  /// No description provided for @invitationNotificationsStatusAccepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get invitationNotificationsStatusAccepted;

  /// No description provided for @invitationNotificationsStatusDeclined.
  ///
  /// In en, this message translates to:
  /// **'Declined'**
  String get invitationNotificationsStatusDeclined;

  /// No description provided for @invitationNotificationsAcceptCta.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get invitationNotificationsAcceptCta;

  /// No description provided for @invitationNotificationsDeclineCta.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get invitationNotificationsDeclineCta;

  /// No description provided for @invitationNotificationsInviteAgain.
  ///
  /// In en, this message translates to:
  /// **'Invite again'**
  String get invitationNotificationsInviteAgain;

  /// No description provided for @invitationNotificationsEmptyAll.
  ///
  /// In en, this message translates to:
  /// **'No invitations to show.'**
  String get invitationNotificationsEmptyAll;

  /// No description provided for @invitationNotificationsEmptyPending.
  ///
  /// In en, this message translates to:
  /// **'You are caught up—no pending invitations.'**
  String get invitationNotificationsEmptyPending;

  /// No description provided for @invitationNotificationsEmptyResponded.
  ///
  /// In en, this message translates to:
  /// **'No invitations have been answered yet.'**
  String get invitationNotificationsEmptyResponded;

  /// No description provided for @invitationNotificationsFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get invitationNotificationsFilterAll;

  /// No description provided for @invitationNotificationsFilterPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get invitationNotificationsFilterPending;

  /// No description provided for @invitationNotificationsFilterResponded.
  ///
  /// In en, this message translates to:
  /// **'Responded'**
  String get invitationNotificationsFilterResponded;

  /// No description provided for @projectChatCollaboratorsTitle.
  ///
  /// In en, this message translates to:
  /// **'Project collaborators'**
  String get projectChatCollaboratorsTitle;

  /// No description provided for @projectChatCollaboratorsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No collaborators added yet.'**
  String get projectChatCollaboratorsEmpty;

  /// No description provided for @projectChatCollaboratorRoleFallback.
  ///
  /// In en, this message translates to:
  /// **'Collaborator'**
  String get projectChatCollaboratorRoleFallback;

  /// No description provided for @projectChatViewCollaboratorsHint.
  ///
  /// In en, this message translates to:
  /// **'Tap to view collaborators'**
  String get projectChatViewCollaboratorsHint;

  /// No description provided for @projectChatReceiptRead.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get projectChatReceiptRead;

  /// No description provided for @projectChatReceiptReceived.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get projectChatReceiptReceived;

  /// No description provided for @projectChatReceiptUnread.
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get projectChatReceiptUnread;

  /// No description provided for @projectChatReceiptSent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get projectChatReceiptSent;

  /// No description provided for @projectDetailBackToProjects.
  ///
  /// In en, this message translates to:
  /// **'Back to projects'**
  String get projectDetailBackToProjects;

  /// No description provided for @projectDetailClientPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Client not specified'**
  String get projectDetailClientPlaceholder;

  /// No description provided for @projectDetailMenuProjectChat.
  ///
  /// In en, this message translates to:
  /// **'Project chat'**
  String get projectDetailMenuProjectChat;

  /// No description provided for @projectDetailMenuInviteCollaborator.
  ///
  /// In en, this message translates to:
  /// **'Invite collaborator'**
  String get projectDetailMenuInviteCollaborator;

  /// No description provided for @projectDetailMenuRolesPermissions.
  ///
  /// In en, this message translates to:
  /// **'Roles & permissions'**
  String get projectDetailMenuRolesPermissions;

  /// No description provided for @projectDetailMenuArchive.
  ///
  /// In en, this message translates to:
  /// **'Archive project'**
  String get projectDetailMenuArchive;

  /// No description provided for @projectDetailMenuDuplicate.
  ///
  /// In en, this message translates to:
  /// **'Duplicate project'**
  String get projectDetailMenuDuplicate;

  /// No description provided for @projectDetailMenuDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete project'**
  String get projectDetailMenuDelete;

  /// No description provided for @projectDetailScheduleTitle.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get projectDetailScheduleTitle;

  /// No description provided for @projectDetailScheduleCta.
  ///
  /// In en, this message translates to:
  /// **'Open schedule'**
  String get projectDetailScheduleCta;

  /// No description provided for @projectDetailTeamTitle.
  ///
  /// In en, this message translates to:
  /// **'Team'**
  String get projectDetailTeamTitle;

  /// No description provided for @projectDetailTeamCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one {# member} other {# members}}'**
  String projectDetailTeamCount(int count);

  /// No description provided for @projectDetailTeamEmpty.
  ///
  /// In en, this message translates to:
  /// **'Invite collaborators to build your team.'**
  String get projectDetailTeamEmpty;

  /// No description provided for @projectDetailTasksTitle.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get projectDetailTasksTitle;

  /// No description provided for @projectDetailTasksAddCta.
  ///
  /// In en, this message translates to:
  /// **'Add task'**
  String get projectDetailTasksAddCta;

  /// No description provided for @projectDetailTasksEmpty.
  ///
  /// In en, this message translates to:
  /// **'No tasks yet.'**
  String get projectDetailTasksEmpty;

  /// No description provided for @projectDetailDiscussionTitle.
  ///
  /// In en, this message translates to:
  /// **'Discussion'**
  String get projectDetailDiscussionTitle;

  /// No description provided for @projectDetailFinanceBilled.
  ///
  /// In en, this message translates to:
  /// **'Billed'**
  String get projectDetailFinanceBilled;

  /// No description provided for @projectDetailFinancePaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get projectDetailFinancePaid;

  /// No description provided for @projectDetailFinanceRemaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get projectDetailFinanceRemaining;

  /// No description provided for @projectDetailFinanceCreateQuote.
  ///
  /// In en, this message translates to:
  /// **'Create quote'**
  String get projectDetailFinanceCreateQuote;

  /// No description provided for @projectDetailFilesTitle.
  ///
  /// In en, this message translates to:
  /// **'Files'**
  String get projectDetailFilesTitle;

  /// No description provided for @projectDetailFilesAdd.
  ///
  /// In en, this message translates to:
  /// **'Add file'**
  String get projectDetailFilesAdd;

  /// No description provided for @projectDetailTaskCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create task'**
  String get projectDetailTaskCreateTitle;

  /// No description provided for @projectDetailTaskTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Task title'**
  String get projectDetailTaskTitleHint;

  /// No description provided for @projectDetailTaskTitleError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a task title.'**
  String get projectDetailTaskTitleError;

  /// No description provided for @projectDetailTaskStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get projectDetailTaskStatusLabel;

  /// No description provided for @projectDetailTaskStatusHint.
  ///
  /// In en, this message translates to:
  /// **'Select status'**
  String get projectDetailTaskStatusHint;

  /// No description provided for @projectDetailTaskScheduleLabel.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get projectDetailTaskScheduleLabel;

  /// No description provided for @projectDetailTaskStartDate.
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get projectDetailTaskStartDate;

  /// No description provided for @projectDetailTaskDueDate.
  ///
  /// In en, this message translates to:
  /// **'Due date'**
  String get projectDetailTaskDueDate;

  /// No description provided for @projectDetailTaskAssigneeLabel.
  ///
  /// In en, this message translates to:
  /// **'Assignee'**
  String get projectDetailTaskAssigneeLabel;

  /// No description provided for @projectDetailTaskAssigneeHint.
  ///
  /// In en, this message translates to:
  /// **'Select assignee'**
  String get projectDetailTaskAssigneeHint;

  /// No description provided for @projectDetailTaskAssigneeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Invite collaborators to assign tasks.'**
  String get projectDetailTaskAssigneeEmpty;

  /// No description provided for @projectDetailTaskDetailsLabel.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get projectDetailTaskDetailsLabel;

  /// No description provided for @projectDetailTaskDetailsHint.
  ///
  /// In en, this message translates to:
  /// **'Add context or requirements'**
  String get projectDetailTaskDetailsHint;

  /// No description provided for @projectDetailTaskAttachmentsLabel.
  ///
  /// In en, this message translates to:
  /// **'Attachments'**
  String get projectDetailTaskAttachmentsLabel;

  /// No description provided for @projectDetailTaskAttachmentHint.
  ///
  /// In en, this message translates to:
  /// **'Paste a link or filename'**
  String get projectDetailTaskAttachmentHint;

  /// No description provided for @projectDetailTaskAddAttachment.
  ///
  /// In en, this message translates to:
  /// **'Attach file'**
  String get projectDetailTaskAddAttachment;

  /// No description provided for @projectDetailTaskStatusChange.
  ///
  /// In en, this message translates to:
  /// **'Change status'**
  String get projectDetailTaskStatusChange;

  /// No description provided for @projectDetailBadgeCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed {range}'**
  String projectDetailBadgeCompleted(Object range);

  /// No description provided for @projectDetailBadgeDeferred.
  ///
  /// In en, this message translates to:
  /// **'Deferred {range}'**
  String projectDetailBadgeDeferred(Object range);

  /// No description provided for @projectDetailBadgeDueOn.
  ///
  /// In en, this message translates to:
  /// **'Due on {date}'**
  String projectDetailBadgeDueOn(Object date);

  /// No description provided for @projectDetailBadgeOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue {range}'**
  String projectDetailBadgeOverdue(Object range);

  /// No description provided for @projectDetailBadgeDueTodayRange.
  ///
  /// In en, this message translates to:
  /// **'Due today • {range}'**
  String projectDetailBadgeDueTodayRange(Object range);

  /// No description provided for @projectDetailBadgeDueToday.
  ///
  /// In en, this message translates to:
  /// **'Due today'**
  String get projectDetailBadgeDueToday;

  /// No description provided for @projectDetailBadgeUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Coming up • {range}'**
  String projectDetailBadgeUpcoming(Object range);

  /// No description provided for @projectDetailBadgeTimeline.
  ///
  /// In en, this message translates to:
  /// **'Timeline • {range}'**
  String projectDetailBadgeTimeline(Object range);

  /// No description provided for @projectDetailBadgeStarts.
  ///
  /// In en, this message translates to:
  /// **'Starts {date}'**
  String projectDetailBadgeStarts(Object date);

  /// No description provided for @projectDetailProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Project progress'**
  String get projectDetailProgressTitle;

  /// No description provided for @projectDetailProgressEmpty.
  ///
  /// In en, this message translates to:
  /// **'No tasks tracked yet.'**
  String get projectDetailProgressEmpty;

  /// No description provided for @projectDetailProgressSummary.
  ///
  /// In en, this message translates to:
  /// **'{completed} of {total} tasks completed'**
  String projectDetailProgressSummary(int completed, int total);

  /// No description provided for @projectDetailProgressMetricInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get projectDetailProgressMetricInProgress;

  /// No description provided for @projectDetailProgressMetricCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get projectDetailProgressMetricCompleted;

  /// No description provided for @projectDetailProgressMetricRemaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get projectDetailProgressMetricRemaining;

  /// No description provided for @projectDetailDiscussionEmpty.
  ///
  /// In en, this message translates to:
  /// **'No messages yet.'**
  String get projectDetailDiscussionEmpty;

  /// No description provided for @projectDetailDiscussionSend.
  ///
  /// In en, this message translates to:
  /// **'Open chat'**
  String get projectDetailDiscussionSend;

  /// No description provided for @projectDetailTaskAssigneeUnassigned.
  ///
  /// In en, this message translates to:
  /// **'Unassigned'**
  String get projectDetailTaskAssigneeUnassigned;

  /// No description provided for @projectDetailTaskScheduleEmpty.
  ///
  /// In en, this message translates to:
  /// **'No schedule yet'**
  String get projectDetailTaskScheduleEmpty;

  /// No description provided for @projectDetailStatusActionPlanned.
  ///
  /// In en, this message translates to:
  /// **'Mark in progress'**
  String get projectDetailStatusActionPlanned;

  /// No description provided for @projectDetailStatusActionInProgress.
  ///
  /// In en, this message translates to:
  /// **'Mark completed'**
  String get projectDetailStatusActionInProgress;

  /// No description provided for @projectDetailStatusActionCompleted.
  ///
  /// In en, this message translates to:
  /// **'Reopen task'**
  String get projectDetailStatusActionCompleted;

  /// No description provided for @projectDetailStatusActionDeferred.
  ///
  /// In en, this message translates to:
  /// **'Resume task'**
  String get projectDetailStatusActionDeferred;

  /// No description provided for @projectDetailTaskAssignedTo.
  ///
  /// In en, this message translates to:
  /// **'Assigned to {name}'**
  String projectDetailTaskAssignedTo(Object name);

  /// No description provided for @inviteCollaboratorTitle.
  ///
  /// In en, this message translates to:
  /// **'Invite collaborator'**
  String get inviteCollaboratorTitle;

  /// No description provided for @inviteCollaboratorSelectProject.
  ///
  /// In en, this message translates to:
  /// **'Select project'**
  String get inviteCollaboratorSelectProject;

  /// No description provided for @inviteCollaboratorChooseProject.
  ///
  /// In en, this message translates to:
  /// **'Choose project'**
  String get inviteCollaboratorChooseProject;

  /// No description provided for @inviteCollaboratorInfoText.
  ///
  /// In en, this message translates to:
  /// **'Send a direct invitation via email or pull from your contact list.'**
  String get inviteCollaboratorInfoText;

  /// No description provided for @inviteCollaboratorEmailSection.
  ///
  /// In en, this message translates to:
  /// **'Invite via email'**
  String get inviteCollaboratorEmailSection;

  /// No description provided for @inviteCollaboratorEmailHint.
  ///
  /// In en, this message translates to:
  /// **'name@company.com'**
  String get inviteCollaboratorEmailHint;

  /// No description provided for @inviteCollaboratorFromContacts.
  ///
  /// In en, this message translates to:
  /// **'From my contacts'**
  String get inviteCollaboratorFromContacts;

  /// No description provided for @inviteCollaboratorRoleSection.
  ///
  /// In en, this message translates to:
  /// **'Role in project'**
  String get inviteCollaboratorRoleSection;

  /// No description provided for @inviteCollaboratorRoleOwner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get inviteCollaboratorRoleOwner;

  /// No description provided for @inviteCollaboratorRoleEditor.
  ///
  /// In en, this message translates to:
  /// **'Editor'**
  String get inviteCollaboratorRoleEditor;

  /// No description provided for @inviteCollaboratorRoleViewer.
  ///
  /// In en, this message translates to:
  /// **'Viewer'**
  String get inviteCollaboratorRoleViewer;

  /// No description provided for @inviteCollaboratorCustomRoleHint.
  ///
  /// In en, this message translates to:
  /// **'Add custom role'**
  String get inviteCollaboratorCustomRoleHint;

  /// No description provided for @inviteCollaboratorAddRole.
  ///
  /// In en, this message translates to:
  /// **'Add role'**
  String get inviteCollaboratorAddRole;

  /// No description provided for @inviteCollaboratorMessageSection.
  ///
  /// In en, this message translates to:
  /// **'Personal message'**
  String get inviteCollaboratorMessageSection;

  /// No description provided for @inviteCollaboratorMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Optional message to give context'**
  String get inviteCollaboratorMessageHint;

  /// No description provided for @inviteCollaboratorShareLinkTitle.
  ///
  /// In en, this message translates to:
  /// **'Generate shareable link'**
  String get inviteCollaboratorShareLinkTitle;

  /// No description provided for @inviteCollaboratorShareLinkSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Anyone with the link can request access with the role selected above.'**
  String get inviteCollaboratorShareLinkSubtitle;

  /// No description provided for @inviteCollaboratorCopyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get inviteCollaboratorCopyLink;

  /// No description provided for @inviteCollaboratorPrimaryCta.
  ///
  /// In en, this message translates to:
  /// **'Send invitation'**
  String get inviteCollaboratorPrimaryCta;

  /// No description provided for @inviteCollaboratorSnackbarSelectProject.
  ///
  /// In en, this message translates to:
  /// **'Choose a project before sending an invite.'**
  String get inviteCollaboratorSnackbarSelectProject;

  /// No description provided for @inviteCollaboratorSnackbarEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Add the collaborator\'s email first.'**
  String get inviteCollaboratorSnackbarEmailRequired;

  /// No description provided for @inviteCollaboratorSnackbarSent.
  ///
  /// In en, this message translates to:
  /// **'Invitation sent to {name}.'**
  String inviteCollaboratorSnackbarSent(Object name);

  /// No description provided for @inviteCollaboratorSnackbarSelectProjectContacts.
  ///
  /// In en, this message translates to:
  /// **'Choose a project first to invite existing contacts.'**
  String get inviteCollaboratorSnackbarSelectProjectContacts;

  /// No description provided for @inviteCollaboratorSnackbarContactsQueued.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one {# invitation queued.} other {# invitations queued.}}'**
  String inviteCollaboratorSnackbarContactsQueued(int count);

  /// No description provided for @inviteCollaboratorFallbackName.
  ///
  /// In en, this message translates to:
  /// **'New Collaborator'**
  String get inviteCollaboratorFallbackName;

  /// No description provided for @inviteCollaboratorInviteSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Invite from contacts'**
  String get inviteCollaboratorInviteSheetTitle;

  /// No description provided for @inviteCollaboratorInviteSheetRoleLabel.
  ///
  /// In en, this message translates to:
  /// **'Role applied to selection'**
  String get inviteCollaboratorInviteSheetRoleLabel;

  /// No description provided for @inviteCollaboratorInviteSheetNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Add a note (optional)'**
  String get inviteCollaboratorInviteSheetNoteLabel;

  /// No description provided for @inviteCollaboratorInviteSheetSelectContactError.
  ///
  /// In en, this message translates to:
  /// **'Select at least one contact.'**
  String get inviteCollaboratorInviteSheetSelectContactError;

  /// No description provided for @inviteCollaboratorInviteSheetPrimaryCta.
  ///
  /// In en, this message translates to:
  /// **'Invite selected'**
  String get inviteCollaboratorInviteSheetPrimaryCta;

  /// No description provided for @inviteCollaboratorAvailabilityAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get inviteCollaboratorAvailabilityAvailable;

  /// No description provided for @inviteCollaboratorAvailabilityBusy.
  ///
  /// In en, this message translates to:
  /// **'Busy'**
  String get inviteCollaboratorAvailabilityBusy;

  /// No description provided for @inviteCollaboratorAvailabilityOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get inviteCollaboratorAvailabilityOffline;

  /// No description provided for @rolesPermissionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Roles & permissions'**
  String get rolesPermissionsTitle;

  /// No description provided for @rolesPermissionsRoleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get rolesPermissionsRoleAdmin;

  /// No description provided for @rolesPermissionsRoleCollaborator.
  ///
  /// In en, this message translates to:
  /// **'Collaborator'**
  String get rolesPermissionsRoleCollaborator;

  /// No description provided for @rolesPermissionsRoleViewer.
  ///
  /// In en, this message translates to:
  /// **'Viewer'**
  String get rolesPermissionsRoleViewer;

  /// No description provided for @managementTitle.
  ///
  /// In en, this message translates to:
  /// **'Management'**
  String get managementTitle;

  /// No description provided for @managementSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Projects, staffing, and blockers in one view'**
  String get managementSubtitle;

  /// No description provided for @managementEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No projects yet'**
  String get managementEmptyTitle;

  /// No description provided for @managementEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create your first project to see progress.'**
  String get managementEmptySubtitle;

  /// No description provided for @managementFilterOngoing.
  ///
  /// In en, this message translates to:
  /// **'Ongoing'**
  String get managementFilterOngoing;

  /// No description provided for @managementFilterUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get managementFilterUpcoming;

  /// No description provided for @managementFilterCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get managementFilterCompleted;

  /// No description provided for @managementProjectsHeading.
  ///
  /// In en, this message translates to:
  /// **'Projects ({count})'**
  String managementProjectsHeading(int count);

  /// No description provided for @managementCreateProjectTooltip.
  ///
  /// In en, this message translates to:
  /// **'Create project'**
  String get managementCreateProjectTooltip;

  /// No description provided for @crmContactTypeClient.
  ///
  /// In en, this message translates to:
  /// **'Client'**
  String get crmContactTypeClient;

  /// No description provided for @crmContactTypeCollaborator.
  ///
  /// In en, this message translates to:
  /// **'Collaborator'**
  String get crmContactTypeCollaborator;

  /// No description provided for @crmRowInsights.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get crmRowInsights;

  /// No description provided for @crmRowEditContact.
  ///
  /// In en, this message translates to:
  /// **'Edit contact'**
  String get crmRowEditContact;

  /// No description provided for @crmSectionLinkedProjects.
  ///
  /// In en, this message translates to:
  /// **'Linked projects'**
  String get crmSectionLinkedProjects;

  /// No description provided for @crmSectionFinanceHistory.
  ///
  /// In en, this message translates to:
  /// **'Finance history'**
  String get crmSectionFinanceHistory;

  /// No description provided for @crmSectionDocuments.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get crmSectionDocuments;

  /// No description provided for @crmActionCreateProject.
  ///
  /// In en, this message translates to:
  /// **'Create project for client'**
  String get crmActionCreateProject;

  /// No description provided for @crmActionSendQuote.
  ///
  /// In en, this message translates to:
  /// **'Send quote'**
  String get crmActionSendQuote;

  /// No description provided for @crmActionCreateInvoice.
  ///
  /// In en, this message translates to:
  /// **'Create invoice'**
  String get crmActionCreateInvoice;

  /// No description provided for @crmActionOpenDetail.
  ///
  /// In en, this message translates to:
  /// **'Open contact detail'**
  String get crmActionOpenDetail;

  /// No description provided for @financeQuoteClientSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Client & project'**
  String get financeQuoteClientSectionTitle;

  /// No description provided for @financeQuoteClientNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Client name'**
  String get financeQuoteClientNameLabel;

  /// No description provided for @financeQuoteReferenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Project / Reference (optional)'**
  String get financeQuoteReferenceLabel;

  /// No description provided for @financeQuoteLineItemsTitle.
  ///
  /// In en, this message translates to:
  /// **'Line items'**
  String get financeQuoteLineItemsTitle;

  /// No description provided for @financeQuoteConditionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Conditions & validity'**
  String get financeQuoteConditionsTitle;

  /// No description provided for @financeQuoteConditionsHint.
  ///
  /// In en, this message translates to:
  /// **'Payment terms, delivery schedule, notes...'**
  String get financeQuoteConditionsHint;

  /// No description provided for @financeQuoteOptionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get financeQuoteOptionsTitle;

  /// No description provided for @financeQuoteRequireSignature.
  ///
  /// In en, this message translates to:
  /// **'Require e-signature'**
  String get financeQuoteRequireSignature;

  /// No description provided for @financeQuoteGenerateCta.
  ///
  /// In en, this message translates to:
  /// **'Generate quote'**
  String get financeQuoteGenerateCta;

  /// No description provided for @financeQuoteExistingCount.
  ///
  /// In en, this message translates to:
  /// **'Existing quotes: {count}'**
  String financeQuoteExistingCount(int count);

  /// No description provided for @financeQuoteAddLineItem.
  ///
  /// In en, this message translates to:
  /// **'Add line item'**
  String get financeQuoteAddLineItem;

  /// No description provided for @financeQuoteDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get financeQuoteDescriptionHint;

  /// No description provided for @financeQuoteQuantityHint.
  ///
  /// In en, this message translates to:
  /// **'Qty'**
  String get financeQuoteQuantityHint;

  /// No description provided for @financeQuoteUnitPriceHint.
  ///
  /// In en, this message translates to:
  /// **'Unit price'**
  String get financeQuoteUnitPriceHint;

  /// No description provided for @financeQuoteRemoveTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get financeQuoteRemoveTooltip;

  /// No description provided for @financeQuoteSubtotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Subtotal: {amount}'**
  String financeQuoteSubtotalLabel(Object amount);

  /// No description provided for @financeQuoteFallbackClient.
  ///
  /// In en, this message translates to:
  /// **'Unnamed client'**
  String get financeQuoteFallbackClient;

  /// No description provided for @financeQuoteFallbackDescription.
  ///
  /// In en, this message translates to:
  /// **'Quote draft'**
  String get financeQuoteFallbackDescription;

  /// No description provided for @financeInvoiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Invoice #{number}'**
  String financeInvoiceTitle(Object number);

  /// No description provided for @financeInvoiceUnknownClient.
  ///
  /// In en, this message translates to:
  /// **'Unknown client'**
  String get financeInvoiceUnknownClient;

  /// No description provided for @financeInvoiceAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount: {amount}'**
  String financeInvoiceAmountLabel(Object amount);

  /// No description provided for @financeInvoiceStatusDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get financeInvoiceStatusDraft;

  /// No description provided for @financeInvoiceStatusUnpaid.
  ///
  /// In en, this message translates to:
  /// **'Unpaid'**
  String get financeInvoiceStatusUnpaid;

  /// No description provided for @financeInvoiceStatusPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get financeInvoiceStatusPaid;

  /// No description provided for @financeInvoiceFieldsTitle.
  ///
  /// In en, this message translates to:
  /// **'Invoice fields'**
  String get financeInvoiceFieldsTitle;

  /// No description provided for @financeInvoiceIssueLabel.
  ///
  /// In en, this message translates to:
  /// **'Issue date'**
  String get financeInvoiceIssueLabel;

  /// No description provided for @financeInvoiceDueLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment due'**
  String get financeInvoiceDueLabel;

  /// No description provided for @financeInvoiceDatePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get financeInvoiceDatePlaceholder;

  /// No description provided for @financeInvoiceMethodLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get financeInvoiceMethodLabel;

  /// No description provided for @financeInvoiceMethodBankTransfer.
  ///
  /// In en, this message translates to:
  /// **'Bank transfer'**
  String get financeInvoiceMethodBankTransfer;

  /// No description provided for @financeInvoiceMethodCard.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get financeInvoiceMethodCard;

  /// No description provided for @financeInvoiceMethodApplePay.
  ///
  /// In en, this message translates to:
  /// **'Apple Pay'**
  String get financeInvoiceMethodApplePay;

  /// No description provided for @financeInvoiceButtonAlreadyPaid.
  ///
  /// In en, this message translates to:
  /// **'Already paid'**
  String get financeInvoiceButtonAlreadyPaid;

  /// No description provided for @financeInvoiceButtonMarkPaid.
  ///
  /// In en, this message translates to:
  /// **'Mark paid'**
  String get financeInvoiceButtonMarkPaid;

  /// No description provided for @financeInvoiceButtonSendReminder.
  ///
  /// In en, this message translates to:
  /// **'Send reminder'**
  String get financeInvoiceButtonSendReminder;

  /// No description provided for @financeQuotePreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Quote #{id} preview'**
  String financeQuotePreviewTitle(Object id);

  /// No description provided for @financeQuotePreviewSendTooltip.
  ///
  /// In en, this message translates to:
  /// **'Send quote'**
  String get financeQuotePreviewSendTooltip;

  /// No description provided for @financeQuotePreviewSendSnack.
  ///
  /// In en, this message translates to:
  /// **'Quote sent for signature'**
  String get financeQuotePreviewSendSnack;

  /// No description provided for @financeQuotePreviewTrackCta.
  ///
  /// In en, this message translates to:
  /// **'Track signature'**
  String get financeQuotePreviewTrackCta;

  /// No description provided for @financeQuotePreviewTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total (incl. VAT)'**
  String get financeQuotePreviewTotalLabel;

  /// No description provided for @financeQuoteStatusDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get financeQuoteStatusDraft;

  /// No description provided for @financeQuoteStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending signature'**
  String get financeQuoteStatusPending;

  /// No description provided for @financeQuoteStatusSigned.
  ///
  /// In en, this message translates to:
  /// **'Signed'**
  String get financeQuoteStatusSigned;

  /// No description provided for @financeQuoteStatusDeclined.
  ///
  /// In en, this message translates to:
  /// **'Declined'**
  String get financeQuoteStatusDeclined;

  /// No description provided for @financeQuotePreviewDocumentPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Quote PDF layout placeholder'**
  String get financeQuotePreviewDocumentPlaceholder;

  /// No description provided for @financeReportingTitle.
  ///
  /// In en, this message translates to:
  /// **'Financial reporting'**
  String get financeReportingTitle;

  /// No description provided for @financeReportingCardRevenue.
  ///
  /// In en, this message translates to:
  /// **'Revenue by month'**
  String get financeReportingCardRevenue;

  /// No description provided for @financeReportingCardOutstanding.
  ///
  /// In en, this message translates to:
  /// **'Outstanding invoices'**
  String get financeReportingCardOutstanding;

  /// No description provided for @financeReportingCardConversion.
  ///
  /// In en, this message translates to:
  /// **'Quote conversion rate'**
  String get financeReportingCardConversion;

  /// No description provided for @financeReportingCardTopClients.
  ///
  /// In en, this message translates to:
  /// **'Top clients'**
  String get financeReportingCardTopClients;

  /// No description provided for @financeReportingExportCta.
  ///
  /// In en, this message translates to:
  /// **'Export PDF summary'**
  String get financeReportingExportCta;

  /// No description provided for @financeReportingFiltersTitle.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get financeReportingFiltersTitle;

  /// No description provided for @financeReportingFilterRange.
  ///
  /// In en, this message translates to:
  /// **'Range'**
  String get financeReportingFilterRange;

  /// No description provided for @financeReportingFilterGranularity.
  ///
  /// In en, this message translates to:
  /// **'Granularity'**
  String get financeReportingFilterGranularity;

  /// No description provided for @financeReportingRange7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get financeReportingRange7Days;

  /// No description provided for @financeReportingRange30Days.
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get financeReportingRange30Days;

  /// No description provided for @financeReportingRangeQuarter.
  ///
  /// In en, this message translates to:
  /// **'Quarter to date'**
  String get financeReportingRangeQuarter;

  /// No description provided for @financeReportingRangeYear.
  ///
  /// In en, this message translates to:
  /// **'Year to date'**
  String get financeReportingRangeYear;

  /// No description provided for @financeReportingGranularityDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get financeReportingGranularityDaily;

  /// No description provided for @financeReportingGranularityWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get financeReportingGranularityWeekly;

  /// No description provided for @financeReportingGranularityMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get financeReportingGranularityMonthly;

  /// No description provided for @financeReportingChartPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Chart placeholder'**
  String get financeReportingChartPlaceholder;

  /// No description provided for @financeSignatureTrackingTitle.
  ///
  /// In en, this message translates to:
  /// **'Signature tracking'**
  String get financeSignatureTrackingTitle;

  /// No description provided for @financeSignatureTrackingQuoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Quote #{id}'**
  String financeSignatureTrackingQuoteLabel(Object id);

  /// No description provided for @financeSignatureStepWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting to be viewed'**
  String get financeSignatureStepWaiting;

  /// No description provided for @financeSignatureStepOpened.
  ///
  /// In en, this message translates to:
  /// **'Opened'**
  String get financeSignatureStepOpened;

  /// No description provided for @financeSignatureStepSigned.
  ///
  /// In en, this message translates to:
  /// **'Signed'**
  String get financeSignatureStepSigned;

  /// No description provided for @financeSignatureStepDeclined.
  ///
  /// In en, this message translates to:
  /// **'Declined'**
  String get financeSignatureStepDeclined;

  /// No description provided for @financeSignatureAdvanceButton.
  ///
  /// In en, this message translates to:
  /// **'Advance status'**
  String get financeSignatureAdvanceButton;

  /// No description provided for @financeSignatureSignedSnack.
  ///
  /// In en, this message translates to:
  /// **'Quote signed – invoice draft created'**
  String get financeSignatureSignedSnack;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
