// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Rush Manage';

  @override
  String get contactsTitle => 'Contacts';

  @override
  String get contactsSubtitle =>
      'Centralize clients and collaborators in one place.';

  @override
  String get contactsAdd => 'Add contact';

  @override
  String get collaboratorsTitle => 'My Collaborators';

  @override
  String get collaboratorsInvitationsButton => 'Invitations';

  @override
  String get collaboratorsInviteCta => '+ Invite';

  @override
  String get collaboratorsNoHistory => 'No previous collaboration recorded';

  @override
  String collaboratorsLastProject(Object project) {
    return 'Last collaborated on $project';
  }

  @override
  String get collaboratorsActionViewProfile => 'View Profile';

  @override
  String get collaboratorsActionConversation => 'Start Conversation';

  @override
  String get collaboratorsActionInvite => 'Invite to Project';

  @override
  String get collaboratorsActionSendQuote => 'Send Quote';

  @override
  String get collaboratorsActionManagePermissions => 'Manage Permissions';

  @override
  String get collaboratorsActionViewFiles => 'View Shared Files';

  @override
  String get collaboratorsStatusOnline => 'Online';

  @override
  String get collaboratorsStatusBusy => 'Busy';

  @override
  String get collaboratorsStatusOffline => 'Offline';

  @override
  String get collaboratorInviteTooltip => 'Invite to project';

  @override
  String get collaboratorStartChatTooltip => 'Start chat';

  @override
  String get collaboratorSectionSkills => 'Key Skills';

  @override
  String get collaboratorSectionAbout => 'About';

  @override
  String get collaboratorSectionHistory => 'Collaboration History';

  @override
  String get collaboratorSendMessage => 'Send Message';

  @override
  String collaboratorReviewsMeta(Object rating, int count) {
    return '$rating • $count reviews';
  }

  @override
  String get languageLabel => 'Language';

  @override
  String get languageDescription =>
      'Automatically follows your country unless you choose a language below.';

  @override
  String get languageSystemDefault => 'Use device language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageDropdownHint => 'Select a language';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileEditTooltip => 'Edit profile';

  @override
  String get profileEditButton => 'Edit Profile';

  @override
  String get profileViewAnalytics => 'View Analytics';

  @override
  String get profileInvitationNotifications => 'Invitation Notifications';

  @override
  String get profileContactSection => 'Contact';

  @override
  String get profileFocusAreaSection => 'Focus Area';

  @override
  String get profileEmailLabel => 'Email';

  @override
  String get profilePhoneLabel => 'Phone';

  @override
  String get profileLocationLabel => 'Location';

  @override
  String get commonOr => 'OR';

  @override
  String get commonEmailAddress => 'Email Address';

  @override
  String get commonPassword => 'Password';

  @override
  String get commonEnterPassword => 'Enter Password';

  @override
  String get commonNewPassword => 'New Password';

  @override
  String get commonConfirmPassword => 'Confirm Password';

  @override
  String get commonName => 'Name';

  @override
  String get commonFullName => 'Full Name';

  @override
  String get commonRoleTitle => 'Role / Title';

  @override
  String get commonLocation => 'Location';

  @override
  String get commonFocusAreas => 'Focus areas';

  @override
  String get commonUploadPhoto => 'Upload photo';

  @override
  String get commonSkip => 'Skip for now';

  @override
  String get commonSearchContacts => 'Search contacts by name or project';

  @override
  String get commonSearchThreads => 'Search threads or contacts';

  @override
  String get commonAllFilter => 'All';

  @override
  String get commonClientsFilter => 'Clients';

  @override
  String get commonCollaboratorsFilter => 'Collaborators';

  @override
  String get commonProjectsFilter => 'Projects';

  @override
  String get commonContactsFilter => 'Contacts';

  @override
  String get commonAddContact => 'Add contact';

  @override
  String get commonComingSoon => 'Image picker coming soon.';

  @override
  String get commonFocusPlanning => 'Planning';

  @override
  String get commonFocusEngineering => 'Engineering';

  @override
  String get commonFocusFinance => 'Finance';

  @override
  String get commonFocusLogistics => 'Logistics';

  @override
  String get welcomeSubtitle => 'The best way to manage your projects.';

  @override
  String get welcomeCreateAccount => 'Create New Account';

  @override
  String get welcomeLogin => 'Login Now';

  @override
  String get loginTitle => 'Login Now';

  @override
  String get loginSubtitle => 'Enter your email and password to login';

  @override
  String get loginForgotPrompt => 'Forgot Password?';

  @override
  String get loginResetLink => 'Reset now';

  @override
  String get loginButton => 'Log in';

  @override
  String get loginSocialGoogle => 'Continue with Google';

  @override
  String get loginSocialApple => 'Continue with Apple';

  @override
  String get loginNoAccountPrompt => 'Don\'t have an account?';

  @override
  String get loginCreateNow => 'Create Now';

  @override
  String get loginMissingFields => 'Please enter both email and password.';

  @override
  String get loginGenericError => 'We couldn\'t sign you in. Please try again.';

  @override
  String get registrationTitle => 'Create Your Account';

  @override
  String get registrationSubtitle =>
      'Please fill in your details to create an account';

  @override
  String get registrationButton => 'Save & Next';

  @override
  String get registrationAlreadyPrompt => 'Already a Subscriber?';

  @override
  String get registrationLoginNow => 'Login Now';

  @override
  String get registrationMissingFields =>
      'Please provide your name, email, and password.';

  @override
  String get registrationPasswordTooShort =>
      'Password must be at least 6 characters.';

  @override
  String get registrationGenericError =>
      'We couldn\'t create your account. Please try again.';

  @override
  String get forgotTitle => 'Reset Password';

  @override
  String get forgotSubtitle => 'Enter your email below to reset your password';

  @override
  String get forgotButton => 'Send reset link';

  @override
  String get forgotInvalidEmail => 'Please enter a valid email address.';

  @override
  String get forgotEmailSent => 'Check your email for the reset link.';

  @override
  String get forgotGenericError =>
      'We couldn\'t send the reset email. Please try again.';

  @override
  String get verifyTitle => 'Verify Email by OTP';

  @override
  String get verifySubtitle => 'A verification code sent on your email address';

  @override
  String get verifyConfirm => 'Confirm';

  @override
  String get verifyNoCode => 'Didn\'t receive a code?';

  @override
  String verifyResendIn(Object time) {
    return 'Resend in $time';
  }

  @override
  String get verifyResendNow => 'Resend Now';

  @override
  String get resetTitle => 'Enter New Password';

  @override
  String get resetSubtitle =>
      'Enter your new password that you would like to use';

  @override
  String get resetButton => 'Change Password';

  @override
  String get resetPasswordLengthError =>
      'Password must be at least 6 characters.';

  @override
  String get resetPasswordMismatch => 'Passwords do not match.';

  @override
  String get resetNoRecoverySession =>
      'Open the reset link from your email to continue.';

  @override
  String get resetGenericError =>
      'We couldn\'t reset your password. Please try again.';

  @override
  String get resetSuccess => 'Password updated. You can sign in again.';

  @override
  String get setupTitle => 'Set up profile';

  @override
  String get setupHeadline => 'Personalise your workspace';

  @override
  String get setupSubtitle =>
      'Add a face, role, and focus areas so teammates know who you are.';

  @override
  String get setupFinish => 'Finish Setup';

  @override
  String get navHome => 'Home';

  @override
  String get navFinance => 'Finance';

  @override
  String get navCrm => 'CRM';

  @override
  String get navCheckout => 'Checkout';

  @override
  String get navManagement => 'Management';

  @override
  String get chatsTitle => 'Project threads';

  @override
  String get chatsBadgeProject => 'Project';

  @override
  String get chatsBadgeContact => 'Contact';

  @override
  String homeGreeting(Object name) {
    return 'Hey, $name';
  }

  @override
  String get homePulseSubtitle => 'Here is your workspace pulse for today.';

  @override
  String get homePulseDescription =>
      'Keep projects, finances, and team signals aligned.';

  @override
  String get homeFinanceOverviewTitle => 'Finance overview';

  @override
  String get homeFinanceCollected => 'Collected this period';

  @override
  String get homeFinanceUnpaid => 'Unpaid invoices';

  @override
  String get homeFinanceCreateInvoice => 'Create invoice';

  @override
  String get homeFinanceOpenWorkspace => 'Open Finance workspace';

  @override
  String get homeProjectsHealth => 'Projects health';

  @override
  String get homeProjectsActiveLabel => 'Active';

  @override
  String get homeProjectsActiveSubtitle => 'in motion';

  @override
  String get homeProjectsLateLabel => 'Late';

  @override
  String get homeProjectsLateSubtitle => 'needs attention';

  @override
  String get homeProjectsCompletedLabel => 'Completed';

  @override
  String get homeProjectsCompletedSubtitle => 'this month';

  @override
  String get homeCreateProject => 'Create project';

  @override
  String get homeOpenProjects => 'Open Projects dashboard';

  @override
  String get homeMessagesTitle => 'Messages & activity';

  @override
  String get homeMessagesEmpty =>
      'No recent activity. New replies will surface here.';

  @override
  String get homeOpenMessages => 'Open Messages';

  @override
  String homeVariationLabel(Object value) {
    return '$value% vs last month';
  }

  @override
  String homeUnpaidWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# invoices waiting',
      one: '# invoice waiting',
    );
    return '$_temp0';
  }

  @override
  String homeUnreadCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# unread',
      one: '# unread',
    );
    return '$_temp0';
  }

  @override
  String get homeAuthorYou => 'You';

  @override
  String get homeCollaboratorFallback => 'Collaborator';

  @override
  String get relativeTimeJustNow => 'Just now';

  @override
  String relativeTimeMinutes(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '# mins ago',
      one: '# min ago',
    );
    return '$_temp0';
  }

  @override
  String relativeTimeHours(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: '# hrs ago',
      one: '# hr ago',
    );
    return '$_temp0';
  }

  @override
  String relativeTimeDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '# days ago',
      one: '# day ago',
    );
    return '$_temp0';
  }

  @override
  String get crmTitle => 'Contacts';

  @override
  String get crmSubtitle =>
      'Centralize clients and collaborators in one place.';

  @override
  String get calendarPlaceholder => 'Calendar Screen';

  @override
  String get vehiclesTitle => 'Vehicles';

  @override
  String get vehiclesPlaceholder => 'Vehicles Screen';

  @override
  String get sharedFilesTitle => 'Shared files';

  @override
  String get sharedFilesFilterAll => 'All';

  @override
  String get sharedFilesFilterPdf => 'PDF';

  @override
  String get sharedFilesFilterImage => 'Image';

  @override
  String get sharedFilesFilterSpreadsheet => 'Spreadsheet';

  @override
  String get sharedFilesUploadCta => '+ Upload file';

  @override
  String sharedFilesFileMeta(Object type, Object size) {
    return '$type • $size';
  }

  @override
  String sharedFilesUploadedMeta(Object uploader, Object timestamp) {
    return 'Uploaded by $uploader · $timestamp';
  }

  @override
  String get analyticsTitle => 'Analytics';

  @override
  String analyticsUpdatedLabel(Object date) {
    return 'Updated $date';
  }

  @override
  String get analyticsMetricCompleted => 'Completed this month';

  @override
  String get analyticsMetricAvgDuration => 'Avg duration per project';

  @override
  String analyticsAvgDurationValue(Object days) {
    return '$days days';
  }

  @override
  String get analyticsAvgDurationEmpty => 'No completed ranges yet';

  @override
  String get analyticsMetricOnTime => 'On-time delivery rate';

  @override
  String get analyticsValueNotAvailable => 'N/A';

  @override
  String analyticsPercentValue(Object percent) {
    return '$percent%';
  }

  @override
  String get analyticsOnTimeHint => 'Needs deadlines + completion times';

  @override
  String get analyticsMetricRevenue => 'Total revenue';

  @override
  String get analyticsRevenueHint => 'Sync with Finance module';

  @override
  String get analyticsInsightsTitle => 'Quick insights';

  @override
  String get analyticsInsightTotalProjects => 'Total projects';

  @override
  String get analyticsInsightCompletedProjects => 'Completed projects';

  @override
  String get analyticsInsightInProgress => 'In progress';

  @override
  String get checkoutFeatureTapTitle => 'Tap to Pay';

  @override
  String get checkoutFeatureTapDescription =>
      'Instant contactless payments from any Rush device.';

  @override
  String get checkoutFeatureCardTitle => 'Card payments';

  @override
  String get checkoutFeatureCardDescription =>
      'Accept major debit & credit cards with adaptive fees.';

  @override
  String get checkoutFeatureQrTitle => 'QR payments';

  @override
  String get checkoutFeatureQrDescription =>
      'Share payable QR codes in-person or on screen.';

  @override
  String get checkoutFeatureLinksTitle => 'Payment links';

  @override
  String get checkoutFeatureLinksDescription =>
      'Send branded links that confirm payment automatically.';

  @override
  String get checkoutFeatureCatalogTitle => 'Quick catalog';

  @override
  String get checkoutFeatureCatalogDescription =>
      'Create saved services and bundles for fast checkout.';

  @override
  String get checkoutFeatureReceiptTitle => 'Automatic receipt';

  @override
  String get checkoutFeatureReceiptDescription =>
      'Email or text confirmations without leaving the screen.';

  @override
  String get checkoutRoadmapStep1Label => 'Step 1';

  @override
  String get checkoutRoadmapStep1Title => 'Unified checkout shell';

  @override
  String get checkoutRoadmapStep1Description =>
      'Centralize quotes, invoices, and payment orchestration.';

  @override
  String get checkoutRoadmapStep2Label => 'Step 2';

  @override
  String get checkoutRoadmapStep2Title => 'Payment method rollout';

  @override
  String get checkoutRoadmapStep2Description =>
      'Launch Tap to Pay, QR, and payment links sequentially.';

  @override
  String get checkoutRoadmapStep3Label => 'Step 3';

  @override
  String get checkoutRoadmapStep3Title => 'Automation & insights';

  @override
  String get checkoutRoadmapStep3Description =>
      'Activate receipts, reminders, and live settlement reports.';

  @override
  String get checkoutHeroPill => 'Checkout is brewing';

  @override
  String get checkoutHeroHeadline => 'Payments without the patchwork.';

  @override
  String get checkoutHeroBody =>
      'Tap, scan, or share a link. Checkout unifies every payment action inside Rush.';

  @override
  String get checkoutHeroBadgeTitle => 'Now building';

  @override
  String get checkoutHeroBadgeSubtitle =>
      'Seamless checkout journeys for Rush teams and clients.';

  @override
  String get checkoutRoadmapTitle => 'Rollout timeline';

  @override
  String get checkoutEarlyAccessTitle => 'Want early access?';

  @override
  String get checkoutEarlyAccessBody =>
      'We will invite a small crew to pilot Checkout features before the public launch.';

  @override
  String get checkoutEarlyAccessContact =>
      'Reach out to your Rush partner manager to reserve a slot.';

  @override
  String get collaborationChatTitleFallback => 'Collaboration chat';

  @override
  String get collaborationChatSubtitleFallback => 'Tap to view contact detail';

  @override
  String get collaborationChatSharedFilesTooltip => 'Shared files';

  @override
  String get collaborationChatAddAttachment => 'Add attachment';

  @override
  String get collaborationChatComposerHint => 'Write a message…';

  @override
  String get collaborationChatSendMessage => 'Send message';

  @override
  String get collaborationChatAttachTitle => 'Attach from';

  @override
  String get collaborationChatAttachPhoto => 'Photo or image';

  @override
  String get collaborationChatAttachDocument => 'Document';

  @override
  String get collaborationChatAttachPdf => 'PDF';

  @override
  String get collaborationChatAttachCamera => 'Capture from camera';

  @override
  String get collaborationChatReactTooltip => 'React to message';

  @override
  String get contactDetailTitle => 'Contact detail';

  @override
  String get contactDetailStartChat => 'Start chat';

  @override
  String get contactDetailSectionContact => 'Contact';

  @override
  String get contactDetailSectionExpertise => 'Expertise';

  @override
  String get contactDetailSectionProjects => 'Projects together';

  @override
  String get contactDetailSectionNotes => 'Notes';

  @override
  String get contactDetailEditContact => 'Edit contact';

  @override
  String get contactDetailCreateProject => 'Create project';

  @override
  String get contactDetailSendQuote => 'Send quote';

  @override
  String get contactDetailCreateInvoice => 'Create invoice';

  @override
  String get createProjectSelectDate => 'Select date';

  @override
  String get createProjectCategoryEventManagement => 'Event management';

  @override
  String get createProjectCategoryPhotography => 'Photography';

  @override
  String get createProjectCategoryMarketing => 'Marketing';

  @override
  String get createProjectCategoryLogistics => 'Logistics';

  @override
  String get createProjectCategoryOther => 'Other';

  @override
  String get createProjectRoleOwner => 'Owner';

  @override
  String get createProjectRoleEditor => 'Editor';

  @override
  String get createProjectRoleViewer => 'Viewer';

  @override
  String get createProjectDateError => 'End date cannot be before start date';

  @override
  String get createProjectTitle => 'New Project';

  @override
  String get createProjectSubtitle =>
      'Set up the essentials in a few quick steps.';

  @override
  String get createProjectFieldNameLabel => 'Project name';

  @override
  String get createProjectFieldNameHint => 'e.g. Dupont Wedding';

  @override
  String get createProjectFieldNameRequired => 'Project name is required';

  @override
  String get createProjectFieldClientLabel => 'Client';

  @override
  String get createProjectFieldClientHint => 'Client or company name';

  @override
  String get createProjectFieldCategoryLabel => 'Category';

  @override
  String get createProjectFieldCategoryHint => 'Select category';

  @override
  String get createProjectFieldStartDate => 'Start date';

  @override
  String get createProjectFieldEndDate => 'End date';

  @override
  String get createProjectFieldDescriptionLabel => 'Description (optional)';

  @override
  String get createProjectFieldDescriptionHint =>
      'Add a short brief for your team...';

  @override
  String get createProjectInviteTitle => 'Invite team members';

  @override
  String get createProjectInviteDescription =>
      'Assign roles to control access.';

  @override
  String get createProjectCustomRolePlaceholder =>
      'Custom role (e.g. Coordinator)';

  @override
  String get createProjectAddRole => 'Add role';

  @override
  String get createProjectAddMember => 'Add member';

  @override
  String get createProjectInviteExternalTitle => 'Invite external collaborator';

  @override
  String get createProjectInviteExternalDescription =>
      'Send a secure link via email or WhatsApp for limited access.';

  @override
  String createProjectPreviewLink(Object link) {
    return 'Preview link: $link';
  }

  @override
  String get createProjectPrimaryCta => 'Create project';

  @override
  String get financeNewQuoteTooltip => 'New quote';

  @override
  String get financePrimaryCta => 'Create a quote / invoice';

  @override
  String get financeQuickActionsTitle => 'Quick actions';

  @override
  String get financeQuickActionCreateQuote => 'Create quote';

  @override
  String get financeQuickActionCreateInvoice => 'Create invoice';

  @override
  String get financeQuickActionAddExpense => 'Add expense';

  @override
  String get financeQuickActionAddPayment => 'Add payment received';

  @override
  String get financeBalanceTitle => 'Global balance';

  @override
  String financeBalanceVariationLabel(Object value, Object period) {
    return '$value% vs last $period';
  }

  @override
  String get financePeriodMonth => 'month';

  @override
  String get financePeriodYear => 'year';

  @override
  String get financeBalanceToggleMonth => 'Month';

  @override
  String get financeBalanceToggleYear => 'Year';

  @override
  String get financeUnpaidTitle => 'Unpaid invoices';

  @override
  String financeUnpaidMeta(int count, Object amount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# invoices',
      one: '# invoice',
    );
    return '$_temp0 · $amount';
  }

  @override
  String get financeUnpaidReminderCta => 'Send reminder';

  @override
  String get financeUnpaidViewList => 'View list';

  @override
  String get financeReminderSentSnack => 'Reminder scheduled';

  @override
  String get financeLatestDocumentsTitle => 'Latest documents';

  @override
  String get financeQuickAccessTitle => 'Quick access';

  @override
  String get financeQuickAccessCreateQuote => 'Create quote';

  @override
  String get financeQuickAccessReporting => 'Reporting';

  @override
  String get financeQuickAccessPreview => 'Preview (temp)';

  @override
  String get financeQuickAccessSignature => 'Signature (temp)';

  @override
  String get financeQuickAccessInvoice => 'Invoice (temp)';

  @override
  String get financeMetricDraftQuotes => 'Draft quotes';

  @override
  String get financeMetricPendingSignatures => 'Pending signatures';

  @override
  String get financeMetricSignedQuotes => 'Signed quotes';

  @override
  String get financeMetricDeclinedQuotes => 'Declined quotes';

  @override
  String get financeMetricUnpaidInvoices => 'Unpaid invoices';

  @override
  String get financeMetricPaidInvoices => 'Paid invoices';

  @override
  String get financePipelineTitle => 'Pipeline overview';

  @override
  String get financeUpcomingTitle => 'Upcoming / overdue invoices';

  @override
  String get financeUpcomingEmpty => 'No unpaid invoices with due dates';

  @override
  String get financeUpcomingSeeAll => 'See all invoices';

  @override
  String get financeUpcomingNoDueDate => 'No due date';

  @override
  String financeUpcomingBadgeOverdue(int days) {
    return 'Overdue ${days}d';
  }

  @override
  String get financeUpcomingBadgeDueSoon => 'Due soon';

  @override
  String financeUpcomingBadgeDueIn(int days) {
    return 'Due in ${days}d';
  }

  @override
  String get financeUpcomingBadgeDueToday => 'Due today';

  @override
  String financeUpcomingInvoiceLabel(Object id, Object amount) {
    return 'Invoice #$id · $amount';
  }

  @override
  String get financeExpensesTitle => 'Expenses (this month)';

  @override
  String get financeExpensesView => 'View expenses';

  @override
  String financeExpensesTopCategory(Object category) {
    return 'Top expense: $category';
  }

  @override
  String get financeExpensesEmpty => 'No expenses recorded this month';

  @override
  String get financeRecentTitle => 'Recent activity';

  @override
  String financeRecentQuote(Object id, Object status) {
    return 'Quote $id → $status';
  }

  @override
  String financeRecentInvoice(Object id, Object status) {
    return 'Invoice $id → $status';
  }

  @override
  String financeRecentExpense(Object label, Object amount) {
    return 'Expense $label → $amount';
  }

  @override
  String financeRecentPayment(Object id, Object amount) {
    return 'Payment received on #$id → $amount';
  }

  @override
  String get financeRecentEmpty => 'No recent activity';

  @override
  String get projectNotFoundTitle => 'Project not found';

  @override
  String get commonBack => 'Back';

  @override
  String get projectTimelineHeaderSubtitle =>
      'Drag tasks on the timeline to reschedule';

  @override
  String get projectTimelineUnscheduledTitle => 'Needs scheduling';

  @override
  String get projectTimelineUnscheduledHint =>
      'Set start and due dates to place this task on the timeline.';

  @override
  String get taskStatusPlanned => 'Planned';

  @override
  String get taskStatusInProgress => 'In progress';

  @override
  String get taskStatusCompleted => 'Completed';

  @override
  String get taskStatusDeferred => 'Deferred';

  @override
  String get invitationOnboardingMissing =>
      'Invitation not found or has expired.';

  @override
  String get invitationOnboardingCompleteTitle => 'You\'re in';

  @override
  String get invitationNotificationsViewProject => 'View project';

  @override
  String get invitationOnboardingStepAccount => 'Create your account';

  @override
  String get invitationOnboardingStepProfile => 'Complete your profile';

  @override
  String get invitationOnboardingStepReview => 'Review & join project';

  @override
  String get invitationOnboardingAcceptTermsError =>
      'Please accept the terms to continue.';

  @override
  String invitationOnboardingWelcome(Object name) {
    return 'Welcome aboard, $name!';
  }

  @override
  String get invitationOnboardingContinueButton => 'Continue';

  @override
  String get invitationOnboardingJoinButton => 'Join project';

  @override
  String get invitationOnboardingAccountIntro =>
      'Welcome! Create a password to activate access.';

  @override
  String get invitationOnboardingWorkEmail => 'Work email';

  @override
  String get invitationOnboardingCreatePassword => 'Create password';

  @override
  String get invitationOnboardingPasswordHint => 'Use at least 8 characters.';

  @override
  String get invitationOnboardingConfirmPassword => 'Confirm password';

  @override
  String get invitationOnboardingPasswordMismatch => 'Passwords do not match.';

  @override
  String get invitationOnboardingTermsAgreement =>
      'I agree to the Rush Manage collaboration terms.';

  @override
  String get invitationOnboardingProfileIntro =>
      'Tell everyone how to reach you and what you do.';

  @override
  String get invitationOnboardingFullName => 'Full name';

  @override
  String get invitationOnboardingFullNameError => 'Enter your full name.';

  @override
  String get invitationOnboardingRoleLabel => 'Role / Title';

  @override
  String get invitationOnboardingRoleError =>
      'Enter your role for this project.';

  @override
  String get invitationOnboardingLocationLabel => 'Location (optional)';

  @override
  String get invitationOnboardingReviewIntro =>
      'You\'re almost set! Review the project details before joining.';

  @override
  String invitationOnboardingReviewRole(Object role) {
    return 'You will join as $role.';
  }

  @override
  String get financeCreateQuoteTitle => 'Create quote';

  @override
  String get financeCreateQuoteSectionProject => 'Project information';

  @override
  String get financeCreateQuoteFieldProjectNameLabel => 'Project name';

  @override
  String get financeCreateQuoteFieldProjectNameHint =>
      'Name or reference for this quote';

  @override
  String get financeCreateQuoteFieldScopeLabel => 'Scope & services';

  @override
  String get financeCreateQuoteFieldScopeHint =>
      'Describe the services, deliverables, or context';

  @override
  String get financeCreateQuoteSectionPricing => 'Pricing';

  @override
  String get financeCreateQuoteFieldAmountLabel => 'Amount';

  @override
  String get financeCreateQuoteFieldAmountHint => 'Enter total amount';

  @override
  String get financeCreateQuoteFieldCurrencyLabel => 'Currency';

  @override
  String get financeCreateQuoteFieldPaymentTermsLabel => 'Payment terms';

  @override
  String get financeCreateQuoteSectionDeliverables => 'Deliverables';

  @override
  String get financeCreateQuoteDeliverablePhotosTitle => 'Edited photo gallery';

  @override
  String get financeCreateQuoteDeliverablePhotosDescription =>
      'Includes curated selects with base retouch.';

  @override
  String get financeCreateQuoteDeliverableSelectsTitle => 'Premium selects';

  @override
  String get financeCreateQuoteDeliverableSelectsDescription =>
      'Up to 20 hero edits with detailed retouching.';

  @override
  String get financeCreateQuoteSectionNotes => 'Notes to client';

  @override
  String get financeCreateQuoteNotesHint =>
      'Add revisions, delivery details, or payment notes';

  @override
  String get financeCreateQuotePrimaryCta => 'Send quote';

  @override
  String get financeCreateQuotePaymentDueReceipt => 'Due on receipt';

  @override
  String get financeCreateQuotePaymentDue15 => 'Due in 15 days';

  @override
  String get financeCreateQuotePaymentDue30 => 'Due in 30 days';

  @override
  String get invitationNotificationsTitle => 'Invitation notifications';

  @override
  String invitationNotificationsRole(Object role) {
    return 'Invited as $role';
  }

  @override
  String get invitationNotificationsMarkRead => 'Mark as read';

  @override
  String get invitationNotificationsStatusPending => 'Pending';

  @override
  String get invitationNotificationsStatusAccepted => 'Accepted';

  @override
  String get invitationNotificationsStatusDeclined => 'Declined';

  @override
  String get invitationNotificationsAcceptCta => 'Accept';

  @override
  String get invitationNotificationsDeclineCta => 'Decline';

  @override
  String get invitationNotificationsInviteAgain => 'Invite again';

  @override
  String get invitationNotificationsEmptyAll => 'No invitations to show.';

  @override
  String get invitationNotificationsEmptyPending =>
      'You are caught up—no pending invitations.';

  @override
  String get invitationNotificationsEmptyResponded =>
      'No invitations have been answered yet.';

  @override
  String get invitationNotificationsFilterAll => 'All';

  @override
  String get invitationNotificationsFilterPending => 'Pending';

  @override
  String get invitationNotificationsFilterResponded => 'Responded';

  @override
  String get projectChatCollaboratorsTitle => 'Project collaborators';

  @override
  String get projectChatCollaboratorsEmpty => 'No collaborators added yet.';

  @override
  String get projectChatCollaboratorRoleFallback => 'Collaborator';

  @override
  String get projectChatViewCollaboratorsHint => 'Tap to view collaborators';

  @override
  String get projectChatReceiptRead => 'Read';

  @override
  String get projectChatReceiptReceived => 'Received';

  @override
  String get projectChatReceiptUnread => 'Unread';

  @override
  String get projectChatReceiptSent => 'Sent';

  @override
  String get projectDetailBackToProjects => 'Back to projects';

  @override
  String get projectDetailClientPlaceholder => 'Client not specified';

  @override
  String get projectDetailMenuProjectChat => 'Project chat';

  @override
  String get projectDetailMenuInviteCollaborator => 'Invite collaborator';

  @override
  String get projectDetailMenuRolesPermissions => 'Roles & permissions';

  @override
  String get projectDetailMenuArchive => 'Archive project';

  @override
  String get projectDetailMenuDuplicate => 'Duplicate project';

  @override
  String get projectDetailMenuDelete => 'Delete project';

  @override
  String get projectDetailScheduleTitle => 'Schedule';

  @override
  String get projectDetailScheduleCta => 'Open schedule';

  @override
  String get projectDetailTeamTitle => 'Team';

  @override
  String projectDetailTeamCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# members',
      one: '# member',
    );
    return '$_temp0';
  }

  @override
  String get projectDetailTeamEmpty =>
      'Invite collaborators to build your team.';

  @override
  String get projectDetailTasksTitle => 'Tasks';

  @override
  String get projectDetailTasksAddCta => 'Add task';

  @override
  String get projectDetailTasksEmpty => 'No tasks yet.';

  @override
  String get projectDetailDiscussionTitle => 'Discussion';

  @override
  String get projectDetailFinanceBilled => 'Billed';

  @override
  String get projectDetailFinancePaid => 'Paid';

  @override
  String get projectDetailFinanceRemaining => 'Remaining';

  @override
  String get projectDetailFinanceCreateQuote => 'Create quote';

  @override
  String get projectDetailFilesTitle => 'Files';

  @override
  String get projectDetailFilesAdd => 'Add file';

  @override
  String get projectDetailTaskCreateTitle => 'Create task';

  @override
  String get projectDetailTaskTitleHint => 'Task title';

  @override
  String get projectDetailTaskTitleError => 'Please enter a task title.';

  @override
  String get projectDetailTaskStatusLabel => 'Status';

  @override
  String get projectDetailTaskStatusHint => 'Select status';

  @override
  String get projectDetailTaskScheduleLabel => 'Schedule';

  @override
  String get projectDetailTaskStartDate => 'Start date';

  @override
  String get projectDetailTaskDueDate => 'Due date';

  @override
  String get projectDetailTaskAssigneeLabel => 'Assignee';

  @override
  String get projectDetailTaskAssigneeHint => 'Select assignee';

  @override
  String get projectDetailTaskAssigneeEmpty =>
      'Invite collaborators to assign tasks.';

  @override
  String get projectDetailTaskDetailsLabel => 'Details';

  @override
  String get projectDetailTaskDetailsHint => 'Add context or requirements';

  @override
  String get projectDetailTaskAttachmentsLabel => 'Attachments';

  @override
  String get projectDetailTaskAttachmentHint => 'Paste a link or filename';

  @override
  String get projectDetailTaskAddAttachment => 'Attach file';

  @override
  String get projectDetailTaskStatusChange => 'Change status';

  @override
  String projectDetailBadgeCompleted(Object range) {
    return 'Completed $range';
  }

  @override
  String projectDetailBadgeDeferred(Object range) {
    return 'Deferred $range';
  }

  @override
  String projectDetailBadgeDueOn(Object date) {
    return 'Due on $date';
  }

  @override
  String projectDetailBadgeOverdue(Object range) {
    return 'Overdue $range';
  }

  @override
  String projectDetailBadgeDueTodayRange(Object range) {
    return 'Due today • $range';
  }

  @override
  String get projectDetailBadgeDueToday => 'Due today';

  @override
  String projectDetailBadgeUpcoming(Object range) {
    return 'Coming up • $range';
  }

  @override
  String projectDetailBadgeTimeline(Object range) {
    return 'Timeline • $range';
  }

  @override
  String projectDetailBadgeStarts(Object date) {
    return 'Starts $date';
  }

  @override
  String get projectDetailProgressTitle => 'Project progress';

  @override
  String get projectDetailProgressEmpty => 'No tasks tracked yet.';

  @override
  String projectDetailProgressSummary(int completed, int total) {
    return '$completed of $total tasks completed';
  }

  @override
  String get projectDetailProgressMetricInProgress => 'In progress';

  @override
  String get projectDetailProgressMetricCompleted => 'Completed';

  @override
  String get projectDetailProgressMetricRemaining => 'Remaining';

  @override
  String get projectDetailDiscussionEmpty => 'No messages yet.';

  @override
  String get projectDetailDiscussionSend => 'Open chat';

  @override
  String get projectDetailTaskAssigneeUnassigned => 'Unassigned';

  @override
  String get projectDetailTaskScheduleEmpty => 'No schedule yet';

  @override
  String get projectDetailStatusActionPlanned => 'Mark in progress';

  @override
  String get projectDetailStatusActionInProgress => 'Mark completed';

  @override
  String get projectDetailStatusActionCompleted => 'Reopen task';

  @override
  String get projectDetailStatusActionDeferred => 'Resume task';

  @override
  String projectDetailTaskAssignedTo(Object name) {
    return 'Assigned to $name';
  }

  @override
  String get inviteCollaboratorTitle => 'Invite collaborator';

  @override
  String get inviteCollaboratorSelectProject => 'Select project';

  @override
  String get inviteCollaboratorChooseProject => 'Choose project';

  @override
  String get inviteCollaboratorInfoText =>
      'Send a direct invitation via email or pull from your contact list.';

  @override
  String get inviteCollaboratorEmailSection => 'Invite via email';

  @override
  String get inviteCollaboratorEmailHint => 'name@company.com';

  @override
  String get inviteCollaboratorFromContacts => 'From my contacts';

  @override
  String get inviteCollaboratorRoleSection => 'Role in project';

  @override
  String get inviteCollaboratorRoleOwner => 'Owner';

  @override
  String get inviteCollaboratorRoleEditor => 'Editor';

  @override
  String get inviteCollaboratorRoleViewer => 'Viewer';

  @override
  String get inviteCollaboratorCustomRoleHint => 'Add custom role';

  @override
  String get inviteCollaboratorAddRole => 'Add role';

  @override
  String get inviteCollaboratorMessageSection => 'Personal message';

  @override
  String get inviteCollaboratorMessageHint =>
      'Optional message to give context';

  @override
  String get inviteCollaboratorShareLinkTitle => 'Generate shareable link';

  @override
  String get inviteCollaboratorShareLinkSubtitle =>
      'Anyone with the link can request access with the role selected above.';

  @override
  String get inviteCollaboratorCopyLink => 'Copy';

  @override
  String get inviteCollaboratorPrimaryCta => 'Send invitation';

  @override
  String get inviteCollaboratorSnackbarSelectProject =>
      'Choose a project before sending an invite.';

  @override
  String get inviteCollaboratorSnackbarEmailRequired =>
      'Add the collaborator\'s email first.';

  @override
  String inviteCollaboratorSnackbarSent(Object name) {
    return 'Invitation sent to $name.';
  }

  @override
  String get inviteCollaboratorSnackbarSelectProjectContacts =>
      'Choose a project first to invite existing contacts.';

  @override
  String inviteCollaboratorSnackbarContactsQueued(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# invitations queued.',
      one: '# invitation queued.',
    );
    return '$_temp0';
  }

  @override
  String get inviteCollaboratorFallbackName => 'New Collaborator';

  @override
  String get inviteCollaboratorInviteSheetTitle => 'Invite from contacts';

  @override
  String get inviteCollaboratorInviteSheetRoleLabel =>
      'Role applied to selection';

  @override
  String get inviteCollaboratorInviteSheetNoteLabel => 'Add a note (optional)';

  @override
  String get inviteCollaboratorInviteSheetSelectContactError =>
      'Select at least one contact.';

  @override
  String get inviteCollaboratorInviteSheetPrimaryCta => 'Invite selected';

  @override
  String get inviteCollaboratorAvailabilityAvailable => 'Available';

  @override
  String get inviteCollaboratorAvailabilityBusy => 'Busy';

  @override
  String get inviteCollaboratorAvailabilityOffline => 'Offline';

  @override
  String get rolesPermissionsTitle => 'Roles & permissions';

  @override
  String get rolesPermissionsRoleAdmin => 'Admin';

  @override
  String get rolesPermissionsRoleCollaborator => 'Collaborator';

  @override
  String get rolesPermissionsRoleViewer => 'Viewer';

  @override
  String get managementTitle => 'Management';

  @override
  String get managementSubtitle =>
      'Projects, staffing, and blockers in one view';

  @override
  String get managementEmptyTitle => 'No projects yet';

  @override
  String get managementEmptySubtitle =>
      'Create your first project to see progress.';

  @override
  String get managementFilterOngoing => 'Ongoing';

  @override
  String get managementFilterUpcoming => 'Upcoming';

  @override
  String get managementFilterCompleted => 'Completed';

  @override
  String managementProjectsHeading(int count) {
    return 'Projects ($count)';
  }

  @override
  String get managementCreateProjectTooltip => 'Create project';

  @override
  String get crmContactTypeClient => 'Client';

  @override
  String get crmContactTypeCollaborator => 'Collaborator';

  @override
  String get crmRowInsights => 'Insights';

  @override
  String get crmRowEditContact => 'Edit contact';

  @override
  String get crmSectionLinkedProjects => 'Linked projects';

  @override
  String get crmSectionFinanceHistory => 'Finance history';

  @override
  String get crmSectionDocuments => 'Documents';

  @override
  String get crmActionCreateProject => 'Create project for client';

  @override
  String get crmActionSendQuote => 'Send quote';

  @override
  String get crmActionCreateInvoice => 'Create invoice';

  @override
  String get crmActionOpenDetail => 'Open contact detail';

  @override
  String get financeQuoteClientSectionTitle => 'Client & project';

  @override
  String get financeQuoteClientNameLabel => 'Client name';

  @override
  String get financeQuoteReferenceLabel => 'Project / Reference (optional)';

  @override
  String get financeQuoteLineItemsTitle => 'Line items';

  @override
  String get financeQuoteConditionsTitle => 'Conditions & validity';

  @override
  String get financeQuoteConditionsHint =>
      'Payment terms, delivery schedule, notes...';

  @override
  String get financeQuoteOptionsTitle => 'Options';

  @override
  String get financeQuoteRequireSignature => 'Require e-signature';

  @override
  String get financeQuoteGenerateCta => 'Generate quote';

  @override
  String financeQuoteExistingCount(int count) {
    return 'Existing quotes: $count';
  }

  @override
  String get financeQuoteAddLineItem => 'Add line item';

  @override
  String get financeQuoteDescriptionHint => 'Description';

  @override
  String get financeQuoteQuantityHint => 'Qty';

  @override
  String get financeQuoteUnitPriceHint => 'Unit price';

  @override
  String get financeQuoteRemoveTooltip => 'Remove';

  @override
  String financeQuoteSubtotalLabel(Object amount) {
    return 'Subtotal: $amount';
  }

  @override
  String get financeQuoteFallbackClient => 'Unnamed client';

  @override
  String get financeQuoteFallbackDescription => 'Quote draft';

  @override
  String financeInvoiceTitle(Object number) {
    return 'Invoice #$number';
  }

  @override
  String get financeInvoiceUnknownClient => 'Unknown client';

  @override
  String financeInvoiceAmountLabel(Object amount) {
    return 'Amount: $amount';
  }

  @override
  String get financeInvoiceStatusDraft => 'Draft';

  @override
  String get financeInvoiceStatusUnpaid => 'Unpaid';

  @override
  String get financeInvoiceStatusPaid => 'Paid';

  @override
  String get financeInvoiceFieldsTitle => 'Invoice fields';

  @override
  String get financeInvoiceIssueLabel => 'Issue date';

  @override
  String get financeInvoiceDueLabel => 'Payment due';

  @override
  String get financeInvoiceDatePlaceholder => 'Select date';

  @override
  String get financeInvoiceMethodLabel => 'Payment method';

  @override
  String get financeInvoiceMethodBankTransfer => 'Bank transfer';

  @override
  String get financeInvoiceMethodCard => 'Card';

  @override
  String get financeInvoiceMethodApplePay => 'Apple Pay';

  @override
  String get financeInvoiceButtonAlreadyPaid => 'Already paid';

  @override
  String get financeInvoiceButtonMarkPaid => 'Mark paid';

  @override
  String get financeInvoiceButtonSendReminder => 'Send reminder';

  @override
  String financeQuotePreviewTitle(Object id) {
    return 'Quote #$id preview';
  }

  @override
  String get financeQuotePreviewSendTooltip => 'Send quote';

  @override
  String get financeQuotePreviewSendSnack => 'Quote sent for signature';

  @override
  String get financeQuotePreviewTrackCta => 'Track signature';

  @override
  String get financeQuotePreviewTotalLabel => 'Total (incl. VAT)';

  @override
  String get financeQuoteStatusDraft => 'Draft';

  @override
  String get financeQuoteStatusPending => 'Pending signature';

  @override
  String get financeQuoteStatusSigned => 'Signed';

  @override
  String get financeQuoteStatusDeclined => 'Declined';

  @override
  String get financeQuotePreviewDocumentPlaceholder =>
      'Quote PDF layout placeholder';

  @override
  String get financeReportingTitle => 'Financial reporting';

  @override
  String get financeReportingCardRevenue => 'Revenue by month';

  @override
  String get financeReportingCardOutstanding => 'Outstanding invoices';

  @override
  String get financeReportingCardConversion => 'Quote conversion rate';

  @override
  String get financeReportingCardTopClients => 'Top clients';

  @override
  String get financeReportingExportCta => 'Export PDF summary';

  @override
  String get financeReportingFiltersTitle => 'Reports';

  @override
  String get financeReportingFilterRange => 'Range';

  @override
  String get financeReportingFilterGranularity => 'Granularity';

  @override
  String get financeReportingRange7Days => 'Last 7 days';

  @override
  String get financeReportingRange30Days => 'Last 30 days';

  @override
  String get financeReportingRangeQuarter => 'Quarter to date';

  @override
  String get financeReportingRangeYear => 'Year to date';

  @override
  String get financeReportingGranularityDaily => 'Daily';

  @override
  String get financeReportingGranularityWeekly => 'Weekly';

  @override
  String get financeReportingGranularityMonthly => 'Monthly';

  @override
  String get financeInvoicesTitle => 'Invoices';

  @override
  String get financeInvoicesEmpty => 'No invoices yet.';

  @override
  String get financeInvoicesOpenDetail => 'Open detail';

  @override
  String get financeExpensesScreenTitle => 'Expenses';

  @override
  String get financeExpensesFormTitle => 'Log a new expense';

  @override
  String get financeExpensesFormDescription => 'Description';

  @override
  String get financeExpensesFormAmount => 'Amount';

  @override
  String get financeExpensesFormDate => 'Date';

  @override
  String get financeExpensesSelectDate => 'Select date';

  @override
  String get financeExpensesAddCta => 'Add expense';

  @override
  String get financeExpensesAddSuccess => 'Expense added';

  @override
  String get financeExpensesEmptyList => 'No expenses recorded yet.';

  @override
  String get financeExpensesFormError => 'Enter a description and valid amount';

  @override
  String get financeCreateInvoiceTitle => 'Create invoice';

  @override
  String get financeCreateInvoiceClientLabel => 'Client name';

  @override
  String get financeCreateInvoiceAmountLabel => 'Amount';

  @override
  String get financeCreateInvoiceReferenceLabel => 'Reference (optional)';

  @override
  String get financeCreateInvoiceDueLabel => 'Due date';

  @override
  String get financeCreateInvoiceSelectDate => 'Pick date';

  @override
  String get financeCreateInvoiceSubmit => 'Create invoice';

  @override
  String get financeCreateInvoiceSuccess => 'Invoice created';

  @override
  String get financeCreateInvoiceValidationError =>
      'Add a client name and amount';

  @override
  String get financeRecordPaymentTitle => 'Record payment received';

  @override
  String get financeRecordPaymentInvoiceLabel => 'Invoice';

  @override
  String get financeRecordPaymentNoInvoices => 'All invoices are up to date.';

  @override
  String get financeRecordPaymentSubmit => 'Mark as paid';

  @override
  String get financeRecordPaymentSuccess => 'Invoice marked as paid';

  @override
  String get financeRecordPaymentValidationError =>
      'Select an invoice to continue';

  @override
  String get financeReportingChartPlaceholder => 'Chart placeholder';

  @override
  String get financeSignatureTrackingTitle => 'Signature tracking';

  @override
  String financeSignatureTrackingQuoteLabel(Object id) {
    return 'Quote #$id';
  }

  @override
  String get financeSignatureStepWaiting => 'Waiting to be viewed';

  @override
  String get financeSignatureStepOpened => 'Opened';

  @override
  String get financeSignatureStepSigned => 'Signed';

  @override
  String get financeSignatureStepDeclined => 'Declined';

  @override
  String get financeSignatureAdvanceButton => 'Advance status';

  @override
  String get financeSignatureSignedSnack =>
      'Quote signed – invoice draft created';
}
