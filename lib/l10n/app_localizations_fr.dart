// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Rush Manage';

  @override
  String get contactsTitle => 'Contacts';

  @override
  String get contactsSubtitle =>
      'Centralisez clients et collaborateurs au même endroit.';

  @override
  String get contactsAdd => 'Ajouter un contact';

  @override
  String get contactsEmptyMessage =>
      'No contacts yet. Add your first client or collaborator to get started.';

  @override
  String get collaboratorsTitle => 'Mes collaborateurs';

  @override
  String get collaboratorsInvitationsButton => 'Invitations';

  @override
  String get collaboratorsInviteCta => '+ Inviter';

  @override
  String get collaboratorsNoHistory =>
      'Aucune collaboration précédente enregistrée';

  @override
  String collaboratorsLastProject(Object project) {
    return 'Dernière collaboration sur $project';
  }

  @override
  String get collaboratorsActionViewProfile => 'Voir le profil';

  @override
  String get collaboratorsActionConversation => 'Démarrer une conversation';

  @override
  String get collaboratorsActionInvite => 'Inviter au projet';

  @override
  String get collaboratorsActionSendQuote => 'Envoyer un devis';

  @override
  String get collaboratorsActionManagePermissions => 'Gérer les autorisations';

  @override
  String get collaboratorsActionViewFiles => 'Voir les fichiers partagés';

  @override
  String get collaboratorsStatusOnline => 'En ligne';

  @override
  String get collaboratorsStatusBusy => 'Occupé';

  @override
  String get collaboratorsStatusOffline => 'Hors ligne';

  @override
  String get collaboratorInviteTooltip => 'Inviter au projet';

  @override
  String get collaboratorStartChatTooltip => 'Démarrer une discussion';

  @override
  String get collaboratorSectionSkills => 'Compétences clés';

  @override
  String get collaboratorSectionAbout => 'À propos';

  @override
  String get collaboratorSectionHistory => 'Historique de collaboration';

  @override
  String get collaboratorStatProjectsLabel => 'Projets';

  @override
  String get collaboratorStatCompletedTasksLabel => 'Tâches terminées';

  @override
  String get collaboratorStatActiveTasksLabel => 'Tâches en cours';

  @override
  String get collaboratorStatOverdueTasksLabel => 'En retard';

  @override
  String get collaboratorSendMessage => 'Envoyer un message';

  @override
  String collaboratorReviewsMeta(Object rating, int count) {
    return '$rating • $count avis';
  }

  @override
  String get languageLabel => 'Langue';

  @override
  String get languageDescription =>
      'S\'adapte automatiquement à votre pays sauf si vous choisissez une langue ci-dessous.';

  @override
  String get languageSystemDefault => 'Utiliser la langue de l\'appareil';

  @override
  String get languageEnglish => 'Anglais';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageDropdownHint => 'Sélectionnez une langue';

  @override
  String get profileTitle => 'Profil';

  @override
  String get profileEditTooltip => 'Modifier le profil';

  @override
  String get profileEditButton => 'Modifier le profil';

  @override
  String get profileViewAnalytics => 'Voir les analyses';

  @override
  String get profileInvitationNotifications => 'Notifications d\'invitation';

  @override
  String get editProfileTitle => 'Modifier le profil';

  @override
  String get editProfileHeadline =>
      'Actualisez vos informations pour garder l\'équipe alignée.';

  @override
  String get editProfileSubtitle =>
      'Chaque modification est partagée instantanément dans Rush Manage.';

  @override
  String get editProfileSave => 'Enregistrer les modifications';

  @override
  String get editProfileSuccess => 'Profil mis à jour';

  @override
  String get profileLogoutButton => 'Se déconnecter';

  @override
  String get profileLogoutError =>
      'Nous n\'avons pas pu vous déconnecter. Veuillez réessayer.';

  @override
  String get profileContactSection => 'Contact';

  @override
  String get profileFocusAreaSection => 'Domaine d\'expertise';

  @override
  String get profileEmailLabel => 'E-mail';

  @override
  String get profilePhoneLabel => 'Téléphone';

  @override
  String get profileLocationLabel => 'Localisation';

  @override
  String get profileErrorFullName =>
      'Ajoutez votre nom complet avant de continuer.';

  @override
  String get profileErrorRole => 'Indiquez votre rôle ou titre.';

  @override
  String get profileErrorLocation => 'Précisez votre localisation.';

  @override
  String get profileErrorFocus =>
      'Choisissez au moins un domaine d\'expertise.';

  @override
  String get profileErrorIndustry =>
      'Sélectionnez l\'industrie principale que vous servez.';

  @override
  String get profileErrorAvatar =>
      'Ajoutez une photo de profil pour continuer.';

  @override
  String get profileErrorGeneric =>
      'Impossible d\'enregistrer le profil, veuillez réessayer.';

  @override
  String get commonOr => 'OU';

  @override
  String get commonEmailAddress => 'Adresse e-mail';

  @override
  String get commonPassword => 'Mot de passe';

  @override
  String get commonEnterPassword => 'Saisissez le mot de passe';

  @override
  String get commonNewPassword => 'Nouveau mot de passe';

  @override
  String get commonConfirmPassword => 'Confirmez le mot de passe';

  @override
  String get commonName => 'Nom';

  @override
  String get commonFullName => 'Nom complet';

  @override
  String get commonRoleTitle => 'Rôle / Titre';

  @override
  String get commonLocation => 'Localisation';

  @override
  String get commonFocusAreas => 'Domaines d\'expertise';

  @override
  String get commonUploadPhoto => 'Télécharger une photo';

  @override
  String get commonSkip => 'Ignorer pour l\'instant';

  @override
  String get commonTryAgain => 'Réessayer';

  @override
  String get commonSearchContacts =>
      'Rechercher des contacts par nom ou projet';

  @override
  String get commonSearchThreads => 'Rechercher des fils ou des contacts';

  @override
  String get commonAllFilter => 'Tous';

  @override
  String get commonClientsFilter => 'Clients';

  @override
  String get commonCollaboratorsFilter => 'Collaborateurs';

  @override
  String get commonSuppliersFilter => 'Fournisseurs';

  @override
  String get planUpgradeProjectsTitle => 'Limite de l\'offre gratuite atteinte';

  @override
  String get planUpgradeProjectsDescription =>
      'L\'espace gratuit permet de gérer jusqu\'à 2 projets actifs. Passez à l\'offre supérieure pour continuer.';

  @override
  String get planUpgradeDocumentsTitle => 'Limite de documents atteinte';

  @override
  String get planUpgradeDocumentsDescription =>
      'L\'espace gratuit permet d\'envoyer jusqu\'à 5 devis ou factures au total. Passez à l\'offre supérieure pour continuer à facturer.';

  @override
  String get planUpgradeGeneralHeading => 'Offres générales';

  @override
  String get planUpgradeAddOnHeading => 'Modules par profession';

  @override
  String get planUpgradeTrialCta => 'Ajouter 1 jour Pro';

  @override
  String get planUpgradeTrialFooter =>
      'Paiements disponibles bientôt. Cette période d\'essai débloque tout temporairement.';

  @override
  String get planUpgradeTrialActivated => 'Accès Pro activé pendant 1 jour.';

  @override
  String get commonProjectsFilter => 'Projets';

  @override
  String get commonContactsFilter => 'Contacts';

  @override
  String get commonAddContact => 'Ajouter un contact';

  @override
  String get commonComingSoon => 'Sélecteur d\'image bientôt disponible.';

  @override
  String get commonFocusPlanning => 'Planification';

  @override
  String get commonFocusEngineering => 'Ingénierie';

  @override
  String get commonFocusFinance => 'Finance';

  @override
  String get commonFocusLogistics => 'Logistique';

  @override
  String get welcomeSubtitle => 'La meilleure façon de gérer vos projets.';

  @override
  String get welcomeCreateAccount => 'Créer un nouveau compte';

  @override
  String get welcomeLogin => 'Se connecter';

  @override
  String get loginTitle => 'Connectez-vous';

  @override
  String get loginSubtitle =>
      'Saisissez votre e-mail et votre mot de passe pour vous connecter';

  @override
  String get loginForgotPrompt => 'Mot de passe oublié ?';

  @override
  String get loginResetLink => 'Réinitialiser';

  @override
  String get loginButton => 'Se connecter';

  @override
  String get loginSocialGoogle => 'Continuer avec Google';

  @override
  String get loginSocialApple => 'Continuer avec Apple';

  @override
  String get loginAppleUnavailable =>
      'La connexion Apple n\'est pas encore configurée.';

  @override
  String get loginNoAccountPrompt => 'Pas encore de compte ?';

  @override
  String get loginCreateNow => 'Créer maintenant';

  @override
  String get loginMissingFields =>
      'Veuillez saisir votre email et votre mot de passe.';

  @override
  String get loginGenericError =>
      'Impossible de vous connecter. Veuillez réessayer.';

  @override
  String get registrationTitle => 'Créez votre compte';

  @override
  String get registrationSubtitle =>
      'Veuillez remplir vos informations pour créer un compte';

  @override
  String get registrationButton => 'Enregistrer et suivant';

  @override
  String get registrationAlreadyPrompt => 'Déjà inscrit ?';

  @override
  String get registrationLoginNow => 'Connectez-vous maintenant';

  @override
  String get registrationMissingFields =>
      'Veuillez renseigner votre nom, email et mot de passe.';

  @override
  String get registrationPasswordTooShort =>
      'Le mot de passe doit contenir au moins 6 caractères.';

  @override
  String get registrationEmailConflict =>
      'Un compte existe déjà avec cet e-mail. Essayez de vous connecter.';

  @override
  String get registrationGenericError =>
      'Impossible de créer votre compte. Veuillez réessayer.';

  @override
  String get forgotTitle => 'Réinitialiser le mot de passe';

  @override
  String get forgotSubtitle =>
      'Saisissez votre e-mail pour réinitialiser votre mot de passe';

  @override
  String get forgotButton => 'Envoyer le lien de réinitialisation';

  @override
  String get forgotInvalidEmail => 'Veuillez saisir une adresse e-mail valide.';

  @override
  String get forgotEmailSent =>
      'Consultez votre boîte mail pour le lien de réinitialisation.';

  @override
  String get forgotGenericError =>
      'Impossible d\'envoyer l\'e-mail de réinitialisation. Réessayez.';

  @override
  String get verifyTitle => 'Vérifier l\'e-mail par OTP';

  @override
  String get verifySubtitle =>
      'Un code de vérification a été envoyé sur votre e-mail';

  @override
  String get verifyConfirm => 'Confirmer';

  @override
  String get verifyNoCode => 'Vous n\'avez pas reçu de code ?';

  @override
  String verifyResendIn(Object time) {
    return 'Renvoyer dans $time';
  }

  @override
  String get verifyResendNow => 'Renvoyer maintenant';

  @override
  String get resetTitle => 'Saisissez un nouveau mot de passe';

  @override
  String get resetSubtitle =>
      'Saisissez le nouveau mot de passe que vous souhaitez utiliser';

  @override
  String get resetButton => 'Modifier le mot de passe';

  @override
  String get resetPasswordLengthError =>
      'Le mot de passe doit contenir au moins 6 caractères.';

  @override
  String get resetPasswordMismatch => 'Les mots de passe ne correspondent pas.';

  @override
  String get resetNoRecoverySession =>
      'Ouvrez le lien reçu par e-mail pour continuer.';

  @override
  String get resetGenericError =>
      'Impossible de réinitialiser votre mot de passe. Réessayez.';

  @override
  String get resetSuccess =>
      'Mot de passe mis à jour. Connectez-vous de nouveau.';

  @override
  String get setupTitle => 'Configurer le profil';

  @override
  String get setupHeadline => 'Personnalisez votre espace de travail';

  @override
  String get setupSubtitle =>
      'Ajoutez un visage, un rôle et des domaines d\'expertise pour que l\'équipe sache qui vous êtes.';

  @override
  String get setupIndustrySectionTitle => 'Primary industry';

  @override
  String get setupIndustrySectionSubtitle =>
      'Activate an industry module to unlock tailored workflows.';

  @override
  String get setupIndustryOptionCore => 'General workspace';

  @override
  String get setupIndustryOptionCaterer => 'Events & catering';

  @override
  String get setupFinish => 'Terminer la configuration';

  @override
  String get navHome => 'Accueil';

  @override
  String get navFinance => 'Finance';

  @override
  String get navCrm => 'CRM';

  @override
  String get navCheckout => 'Caisse';

  @override
  String get navManagement => 'Management';

  @override
  String get chatsTitle => 'Discussions projets';

  @override
  String get chatsBadgeProject => 'Projet';

  @override
  String get chatsBadgeContact => 'Contact';

  @override
  String get chatsEmptyTitle => 'Aucun fil de projet';

  @override
  String get chatsEmptySubtitle =>
      'Les collaborateurs apparaîtront ici dès qu\'un chat démarre.';

  @override
  String get chatsNoMessagesYet =>
      'Pas encore de mises à jour. Ouvrez le projet pour commencer à échanger.';

  @override
  String get chatsUnnamedProject => 'Projet sans nom';

  @override
  String get chatsSearchEmpty =>
      'Aucune conversation ne correspond à vos filtres.';

  @override
  String homeGreeting(Object name) {
    return 'Salut, $name';
  }

  @override
  String get homePulseSubtitle =>
      'Voici la pulsation de votre espace de travail pour aujourd\'hui.';

  @override
  String get homePulseDescription =>
      'Gardez vos projets, finances et signaux d\'équipe alignés.';

  @override
  String get homeFinanceOverviewTitle => 'Vue d\'ensemble financière';

  @override
  String get homeFinanceCollected => 'Collecté sur cette période';

  @override
  String get homeFinanceUnpaid => 'Factures impayées';

  @override
  String get homeFinanceCreateInvoice => 'Créer une facture';

  @override
  String get homeFinanceOpenWorkspace => 'Ouvrir l\'espace Finance';

  @override
  String get homeProjectsHealth => 'Santé des projets';

  @override
  String get homeProjectsActiveLabel => 'Actifs';

  @override
  String get homeProjectsActiveSubtitle => 'en cours';

  @override
  String get homeProjectsLateLabel => 'En retard';

  @override
  String get homeProjectsLateSubtitle => 'nécessite une attention';

  @override
  String get homeProjectsCompletedLabel => 'Terminés';

  @override
  String get homeProjectsCompletedSubtitle => 'ce mois-ci';

  @override
  String get homeCreateProject => 'Créer un projet';

  @override
  String get homeOpenProjects => 'Ouvrir le tableau de bord Projets';

  @override
  String get homeMessagesTitle => 'Messages et activité';

  @override
  String get homeMessagesEmpty =>
      'Aucune activité récente. Les nouvelles réponses apparaîtront ici.';

  @override
  String get homeOpenMessages => 'Ouvrir les messages';

  @override
  String homeVariationLabel(Object value) {
    return '$value % vs le mois dernier';
  }

  @override
  String homeUnpaidWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# factures en attente',
      one: '# facture en attente',
    );
    return '$_temp0';
  }

  @override
  String homeUnreadCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# non lus',
      one: '# non lu',
    );
    return '$_temp0';
  }

  @override
  String get homeAuthorYou => 'Vous';

  @override
  String get homeCollaboratorFallback => 'Collaborateur';

  @override
  String get relativeTimeJustNow => 'À l\'instant';

  @override
  String relativeTimeMinutes(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: 'il y a # minutes',
      one: 'il y a # minute',
    );
    return '$_temp0';
  }

  @override
  String relativeTimeHours(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: 'il y a # heures',
      one: 'il y a # heure',
    );
    return '$_temp0';
  }

  @override
  String relativeTimeDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'il y a # jours',
      one: 'il y a # jour',
    );
    return '$_temp0';
  }

  @override
  String get crmTitle => 'Contacts';

  @override
  String get crmSubtitle =>
      'Centralisez clients et collaborateurs en un seul endroit.';

  @override
  String get calendarPlaceholder => 'Écran calendrier';

  @override
  String get vehiclesTitle => 'Véhicules';

  @override
  String get vehiclesPlaceholder => 'Écran véhicules';

  @override
  String get sharedFilesTitle => 'Fichiers partagés';

  @override
  String get sharedFilesFilterAll => 'Tous';

  @override
  String get sharedFilesFilterPdf => 'PDF';

  @override
  String get sharedFilesFilterImage => 'Image';

  @override
  String get sharedFilesFilterSpreadsheet => 'Tableur';

  @override
  String get sharedFilesUploadCta => '+ Télécharger un fichier';

  @override
  String sharedFilesFileMeta(Object type, Object size) {
    return '$type • $size';
  }

  @override
  String sharedFilesUploadedMeta(Object uploader, Object timestamp) {
    return 'Ajouté par $uploader · $timestamp';
  }

  @override
  String get sharedFilesWorkspaceLibrary =>
      'Bibliothèque de l\'espace de travail';

  @override
  String get sharedFilesOriginLibrary => 'Bibliothèque partagée';

  @override
  String get sharedFilesUploadSuccess =>
      'Fichier ajouté à la bibliothèque partagée.';

  @override
  String get sharedFilesUploadFailure =>
      'Impossible de téléverser le fichier. Réessayez.';

  @override
  String get sharedFilesPickerTitle => 'Choisissez une source de fichier';

  @override
  String get sharedFilesDestinationTitle =>
      'Où devons-nous stocker ce fichier ?';

  @override
  String get sharedFilesDestinationWorkspaceSubtitle =>
      'Le conserver dans la bibliothèque de l\'espace';

  @override
  String get sharedFilesDestinationProjectSubtitle => 'L\'associer à ce projet';

  @override
  String get sharedFilesDownloadError =>
      'Impossible d\'ouvrir le lien du fichier.';

  @override
  String get sharedFilesMenuCopyLink => 'Copier le lien';

  @override
  String get sharedFilesMenuOpen => 'Ouvrir dans le navigateur';

  @override
  String get sharedFilesMenuRemove => 'Retirer de la bibliothèque';

  @override
  String get sharedFilesCopySuccess => 'Lien copié dans le presse-papiers.';

  @override
  String sharedFilesRemoveConfirm(Object name) {
    return 'Retirer $name des fichiers partagés ?';
  }

  @override
  String get sharedFilesRemoveSuccess =>
      'Fichier retiré de la bibliothèque partagée.';

  @override
  String get sharedFilesRemoveFailure => 'Impossible de retirer ce fichier.';

  @override
  String get analyticsTitle => 'Analyses';

  @override
  String analyticsUpdatedLabel(Object date) {
    return 'Mis à jour le $date';
  }

  @override
  String get analyticsMetricCompleted => 'Terminés ce mois-ci';

  @override
  String get analyticsMetricAvgDuration => 'Durée moyenne par projet';

  @override
  String analyticsAvgDurationValue(Object days) {
    return '$days jours';
  }

  @override
  String get analyticsAvgDurationEmpty =>
      'Aucune plage terminée pour l\'instant';

  @override
  String get analyticsMetricOnTime => 'Taux de livraison à temps';

  @override
  String get analyticsValueNotAvailable => 'N/D';

  @override
  String analyticsPercentValue(Object percent) {
    return '$percent %';
  }

  @override
  String get analyticsOnTimeHint =>
      'Nécessite des échéances et des temps de livraison';

  @override
  String get analyticsMetricRevenue => 'Revenu total';

  @override
  String get analyticsRevenueHint => 'Synchronisez avec le module Finance';

  @override
  String get analyticsInsightsTitle => 'Aperçus rapides';

  @override
  String get analyticsInsightTotalProjects => 'Total des projets';

  @override
  String get analyticsInsightCompletedProjects => 'Projets terminés';

  @override
  String get analyticsInsightInProgress => 'En cours';

  @override
  String get checkoutFeatureTapTitle => 'Tap to Pay';

  @override
  String get checkoutFeatureTapDescription =>
      'Paiements sans contact instantanés depuis tout appareil Rush.';

  @override
  String get checkoutFeatureCardTitle => 'Paiements par carte';

  @override
  String get checkoutFeatureCardDescription =>
      'Acceptez les principales cartes de débit et crédit avec des frais adaptés.';

  @override
  String get checkoutFeatureQrTitle => 'Paiements QR';

  @override
  String get checkoutFeatureQrDescription =>
      'Partagez des QR codes payables en personne ou à l\'écran.';

  @override
  String get checkoutFeatureLinksTitle => 'Liens de paiement';

  @override
  String get checkoutFeatureLinksDescription =>
      'Envoyez des liens personnalisés qui confirment le paiement automatiquement.';

  @override
  String get checkoutFeatureCatalogTitle => 'Catalogue rapide';

  @override
  String get checkoutFeatureCatalogDescription =>
      'Créez des services et forfaits enregistrés pour des encaissements rapides.';

  @override
  String get checkoutFeatureReceiptTitle => 'Reçu automatique';

  @override
  String get checkoutFeatureReceiptDescription =>
      'Envoyez des confirmations par e-mail ou SMS sans quitter l\'écran.';

  @override
  String get checkoutRoadmapStep1Label => 'Étape 1';

  @override
  String get checkoutRoadmapStep1Title => 'Shell de caisse unifiée';

  @override
  String get checkoutRoadmapStep1Description =>
      'Centralisez devis, factures et orchestration des paiements.';

  @override
  String get checkoutRoadmapStep2Label => 'Étape 2';

  @override
  String get checkoutRoadmapStep2Title =>
      'Déploiement des méthodes de paiement';

  @override
  String get checkoutRoadmapStep2Description =>
      'Lancez Tap to Pay, QR et liens de paiement progressivement.';

  @override
  String get checkoutRoadmapStep3Label => 'Étape 3';

  @override
  String get checkoutRoadmapStep3Title => 'Automatisation et insights';

  @override
  String get checkoutRoadmapStep3Description =>
      'Activez reçus, rappels et rapports de règlement en direct.';

  @override
  String get checkoutHeroPill => 'Checkout en préparation';

  @override
  String get checkoutHeroHeadline => 'Des paiements sans patchwork.';

  @override
  String get checkoutHeroBody =>
      'Tap, scan ou lien partagé. Checkout unifie chaque action de paiement dans Rush.';

  @override
  String get checkoutHeroBadgeTitle => 'En cours de construction';

  @override
  String get checkoutHeroBadgeSubtitle =>
      'Des parcours de paiement fluides pour les équipes Rush et leurs clients.';

  @override
  String get checkoutRoadmapTitle => 'Feuille de route';

  @override
  String get checkoutEarlyAccessTitle => 'Envie d\'un accès anticipé ?';

  @override
  String get checkoutEarlyAccessBody =>
      'Nous inviterons une petite équipe à piloter Checkout avant le lancement public.';

  @override
  String get checkoutEarlyAccessContact =>
      'Contactez votre responsable Rush pour réserver un créneau.';

  @override
  String get collaborationChatTitleFallback => 'Discussion de collaboration';

  @override
  String get collaborationChatSubtitleFallback =>
      'Touchez pour voir le contact';

  @override
  String get collaborationChatSharedFilesTooltip => 'Fichiers partagés';

  @override
  String get collaborationChatAddAttachment => 'Ajouter une pièce jointe';

  @override
  String get collaborationChatComposerHint => 'Écrire un message…';

  @override
  String get collaborationChatSendMessage => 'Envoyer le message';

  @override
  String get collaborationChatAttachTitle => 'Ajouter depuis';

  @override
  String get collaborationChatAttachPhoto => 'Photo ou image';

  @override
  String get collaborationChatAttachDocument => 'Document';

  @override
  String get collaborationChatAttachPdf => 'PDF';

  @override
  String get collaborationChatAttachCamera => 'Prendre avec l\'appareil photo';

  @override
  String get collaborationChatReactTooltip => 'Réagir au message';

  @override
  String get emojiReactionPickerTitle => 'Réagir avec un emoji';

  @override
  String get chatReplyAction => 'Répondre';

  @override
  String chatReplyingTo(Object name) {
    return 'Réponse à $name';
  }

  @override
  String get chatCancelReplyTooltip => 'Annuler la réponse';

  @override
  String get chatMessageNotAvailable => 'Message indisponible';

  @override
  String get chatQuotedFallbackMessage => 'Message';

  @override
  String get chatAttachmentUploadError =>
      'Impossible d\'envoyer la pièce jointe. Veuillez réessayer.';

  @override
  String chatAttachmentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# pièces jointes',
      one: '# pièce jointe',
    );
    return '$_temp0';
  }

  @override
  String get contactDetailTitle => 'Fiche contact';

  @override
  String get contactDetailStartChat => 'Démarrer une discussion';

  @override
  String get contactDetailSectionContact => 'Contact';

  @override
  String get contactDetailSectionExpertise => 'Expertise';

  @override
  String get contactDetailSectionProjects => 'Projets ensemble';

  @override
  String get contactDetailSectionNotes => 'Notes';

  @override
  String get contactDetailEditContact => 'Modifier le contact';

  @override
  String get contactDetailCreateProject => 'Créer un projet';

  @override
  String get contactDetailSendQuote => 'Envoyer un devis';

  @override
  String get contactDetailCreateInvoice => 'Créer une facture';

  @override
  String get createProjectSelectDate => 'Sélectionner une date';

  @override
  String get createProjectCategoryEventManagement => 'Gestion d\'événements';

  @override
  String get createProjectCategoryPhotography => 'Photographie';

  @override
  String get createProjectCategoryMarketing => 'Marketing';

  @override
  String get createProjectCategoryLogistics => 'Logistique';

  @override
  String get createProjectCategoryOther => 'Autre';

  @override
  String get createProjectRoleOwner => 'Propriétaire';

  @override
  String get createProjectRoleEditor => 'Éditeur';

  @override
  String get createProjectRoleViewer => 'Lecteur';

  @override
  String get createProjectDateError =>
      'La date de fin ne peut pas être antérieure à la date de début';

  @override
  String get createProjectTitle => 'Nouveau projet';

  @override
  String get createProjectSubtitle =>
      'Configurez l\'essentiel en quelques étapes.';

  @override
  String get createProjectFieldNameLabel => 'Nom du projet';

  @override
  String get createProjectFieldNameHint => 'ex. Mariage Dupont';

  @override
  String get createProjectFieldNameRequired => 'Le nom du projet est requis';

  @override
  String get createProjectFieldClientLabel => 'Client';

  @override
  String get createProjectFieldClientHint =>
      'Nom du client ou de l\'entreprise';

  @override
  String get createProjectFieldCategoryLabel => 'Catégorie';

  @override
  String get createProjectFieldCategoryHint => 'Sélectionnez une catégorie';

  @override
  String get createProjectFieldStartDate => 'Date de début';

  @override
  String get createProjectFieldEndDate => 'Date de fin';

  @override
  String get createProjectFieldDescriptionLabel => 'Description (optionnel)';

  @override
  String get createProjectFieldDescriptionHint =>
      'Ajoutez un bref résumé pour votre équipe...';

  @override
  String get createProjectCatererSectionTitle => 'Event & catering context';

  @override
  String get createProjectCatererSectionSubtitle =>
      'Capture headcount, menu preferences, and kitchen needs for this project.';

  @override
  String get createProjectCatererGuestCountLabel => 'Guests';

  @override
  String get createProjectCatererGuestCountHint => 'Number of expected guests';

  @override
  String get createProjectCatererMenuLabel => 'Menu style';

  @override
  String get createProjectCatererMenuHint =>
      'e.g. Seated dinner, buffet, cocktail';

  @override
  String get createProjectCatererAllergyLabel => 'Allergies & dietary notes';

  @override
  String get createProjectCatererAllergyHint =>
      'Summarise restrictions or allergy notes';

  @override
  String get createProjectCatererServiceLabel => 'Service flow';

  @override
  String get createProjectCatererServiceHint =>
      'e.g. Ceremony canapés, plated mains, late-night snacks';

  @override
  String get createProjectCatererTastingToggle => 'Tasting required';

  @override
  String get createProjectCatererKitchenToggle => 'On-site kitchen support';

  @override
  String get createProjectCatererKitchenLabel => 'Kitchen notes';

  @override
  String get createProjectCatererKitchenHint =>
      'Access constraints, equipment, or vendor notes';

  @override
  String get createProjectInviteTitle => 'Inviter des membres de l\'équipe';

  @override
  String get createProjectInviteDescription =>
      'Attribuez des rôles pour contrôler l\'accès.';

  @override
  String get createProjectCustomRolePlaceholder =>
      'Rôle personnalisé (ex. Coordinateur)';

  @override
  String get createProjectAddRole => 'Ajouter un rôle';

  @override
  String get createProjectAddMember => 'Ajouter un membre';

  @override
  String get createProjectInviteExternalTitle =>
      'Inviter un collaborateur externe';

  @override
  String get createProjectInviteExternalDescription =>
      'Envoyez un lien sécurisé par e-mail ou WhatsApp pour un accès limité.';

  @override
  String createProjectPreviewLink(Object link) {
    return 'Lien de prévisualisation : $link';
  }

  @override
  String get createProjectErrorGeneric =>
      'Impossible de créer le projet. Veuillez réessayer.';

  @override
  String get createProjectPrimaryCta => 'Créer le projet';

  @override
  String get financeNewQuoteTooltip => 'Nouveau devis';

  @override
  String get financePrimaryCta => 'Créer un devis / facture';

  @override
  String get financeQuickActionsTitle => 'Actions rapides';

  @override
  String get financeQuickActionCreateQuote => 'Créer un devis';

  @override
  String get financeQuickActionCreateInvoice => 'Créer une facture';

  @override
  String get financeQuickActionAddExpense => 'Ajouter une dépense';

  @override
  String get financeQuickActionAddPayment => 'Ajouter un paiement reçu';

  @override
  String get financeBalanceTitle => 'Solde global';

  @override
  String financeBalanceVariationLabel(Object value, Object period) {
    return '$value % vs dernier $period';
  }

  @override
  String get financePeriodMonth => 'mois';

  @override
  String get financePeriodYear => 'année';

  @override
  String get financeBalanceToggleMonth => 'Mois';

  @override
  String get financeBalanceToggleYear => 'Année';

  @override
  String get financeUnpaidTitle => 'Factures impayées';

  @override
  String financeUnpaidMeta(int count, Object amount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# factures',
      one: '# facture',
    );
    return '$_temp0 · $amount';
  }

  @override
  String get financeUnpaidReminderCta => 'Relancer';

  @override
  String get financeUnpaidViewList => 'Voir la liste';

  @override
  String get financeReminderSentSnack => 'Relance planifiée';

  @override
  String get financeLatestDocumentsTitle => 'Derniers documents';

  @override
  String get financeQuickAccessTitle => 'Accès rapide';

  @override
  String get financeQuickAccessCreateQuote => 'Créer un devis';

  @override
  String get financeQuickAccessReporting => 'Reporting';

  @override
  String get financeQuickAccessPreview => 'Aperçu (temp)';

  @override
  String get financeQuickAccessSignature => 'Signature (temp)';

  @override
  String get financeQuickAccessInvoice => 'Facture (temp)';

  @override
  String get financeMetricDraftQuotes => 'Devis brouillons';

  @override
  String get financeMetricPendingSignatures => 'Signatures en attente';

  @override
  String get financeMetricSignedQuotes => 'Devis signés';

  @override
  String get financeMetricDeclinedQuotes => 'Devis refusés';

  @override
  String get financeMetricUnpaidInvoices => 'Factures impayées';

  @override
  String get financeMetricPaidInvoices => 'Factures payées';

  @override
  String get financePipelineTitle => 'Vue pipeline';

  @override
  String get financeUpcomingTitle => 'Factures à venir / en retard';

  @override
  String get financeUpcomingEmpty =>
      'Aucune facture impayée avec date d\'échéance';

  @override
  String get financeUpcomingSeeAll => 'Voir toutes les factures';

  @override
  String get financeUpcomingNoDueDate => 'Pas d\'échéance';

  @override
  String financeUpcomingBadgeOverdue(int days) {
    return 'En retard de $days j';
  }

  @override
  String get financeUpcomingBadgeDueSoon => 'Bientôt dû';

  @override
  String financeUpcomingBadgeDueIn(int days) {
    return 'Dû dans $days j';
  }

  @override
  String get financeUpcomingBadgeDueToday => 'Échéance aujourd\'hui';

  @override
  String financeUpcomingInvoiceLabel(Object id, Object amount) {
    return 'Facture n°$id · $amount';
  }

  @override
  String get financeExpensesTitle => 'Dépenses (ce mois)';

  @override
  String get financeExpensesView => 'Voir les dépenses';

  @override
  String financeExpensesTopCategory(Object category) {
    return 'Dépense principale : $category';
  }

  @override
  String get financeExpensesEmpty => 'Aucune dépense enregistrée ce mois-ci';

  @override
  String get financeRecentTitle => 'Activité récente';

  @override
  String financeRecentQuote(Object id, Object status) {
    return 'Devis $id → $status';
  }

  @override
  String financeRecentInvoice(Object id, Object status) {
    return 'Facture $id → $status';
  }

  @override
  String financeRecentExpense(Object label, Object amount) {
    return 'Dépense $label → $amount';
  }

  @override
  String financeRecentPayment(Object id, Object amount) {
    return 'Paiement reçu sur n°$id → $amount';
  }

  @override
  String get financeRecentEmpty => 'Aucune activité récente';

  @override
  String get projectNotFoundTitle => 'Projet introuvable';

  @override
  String get commonBack => 'Retour';

  @override
  String get projectTimelineHeaderSubtitle =>
      'Faites glisser les tâches sur la frise pour replanifier';

  @override
  String get projectTimelineUnscheduledTitle => 'À planifier';

  @override
  String get projectTimelineUnscheduledHint =>
      'Définissez des dates de début et de fin pour placer cette tâche sur la frise.';

  @override
  String get taskStatusPlanned => 'Planifiée';

  @override
  String get taskStatusInProgress => 'En cours';

  @override
  String get taskStatusCompleted => 'Terminés';

  @override
  String get taskStatusDeferred => 'Reportés';

  @override
  String get invitationOnboardingMissing =>
      'Invitation introuvable ou expirée.';

  @override
  String get invitationOnboardingCompleteTitle => 'Vous êtes prêt';

  @override
  String get invitationNotificationsViewProject => 'Voir le projet';

  @override
  String get invitationOnboardingStepAccount => 'Créez votre compte';

  @override
  String get invitationOnboardingStepProfile => 'Complétez votre profil';

  @override
  String get invitationOnboardingStepReview => 'Revoyez et rejoignez';

  @override
  String get invitationOnboardingAcceptTermsError =>
      'Veuillez accepter les conditions pour continuer.';

  @override
  String invitationOnboardingWelcome(Object name) {
    return 'Bienvenue à bord, $name !';
  }

  @override
  String get invitationOnboardingContinueButton => 'Continuer';

  @override
  String get invitationOnboardingJoinButton => 'Rejoindre le projet';

  @override
  String get invitationOnboardingAccountIntro =>
      'Bienvenue ! Créez un mot de passe pour activer l\'accès.';

  @override
  String get invitationOnboardingWorkEmail => 'E-mail professionnel';

  @override
  String get invitationOnboardingCreatePassword => 'Créer un mot de passe';

  @override
  String get invitationOnboardingPasswordHint =>
      'Utilisez au moins 8 caractères.';

  @override
  String get invitationOnboardingConfirmPassword => 'Confirmez le mot de passe';

  @override
  String get invitationOnboardingPasswordMismatch =>
      'Les mots de passe ne correspondent pas.';

  @override
  String get invitationOnboardingTermsAgreement =>
      'J\'accepte les conditions de collaboration Rush Manage.';

  @override
  String get invitationOnboardingProfileIntro =>
      'Indiquez comment vous contacter et ce que vous faites.';

  @override
  String get invitationOnboardingFullName => 'Nom complet';

  @override
  String get invitationOnboardingFullNameError => 'Indiquez votre nom complet.';

  @override
  String get invitationOnboardingRoleLabel => 'Rôle / Titre';

  @override
  String get invitationOnboardingRoleError =>
      'Indiquez votre rôle pour ce projet.';

  @override
  String get invitationOnboardingLocationLabel => 'Localisation (optionnel)';

  @override
  String get invitationOnboardingReviewIntro =>
      'Vous y êtes presque ! Revoyez les détails du projet avant de rejoindre.';

  @override
  String invitationOnboardingReviewRole(Object role) {
    return 'Vous rejoindrez en tant que $role.';
  }

  @override
  String get financeCreateQuoteTitle => 'Créer un devis';

  @override
  String get financeCreateQuoteSectionProject => 'Informations projet';

  @override
  String get financeCreateQuoteFieldProjectNameLabel => 'Nom du projet';

  @override
  String get financeCreateQuoteFieldProjectNameHint =>
      'Nom ou référence pour ce devis';

  @override
  String get financeCreateQuoteFieldScopeLabel => 'Portée & services';

  @override
  String get financeCreateQuoteFieldScopeHint =>
      'Décrivez les services, livrables ou le contexte';

  @override
  String get financeCreateQuoteSectionPricing => 'Tarification';

  @override
  String get financeCreateQuoteFieldAmountLabel => 'Montant';

  @override
  String get financeCreateQuoteFieldAmountHint => 'Saisissez le montant total';

  @override
  String get financeCreateQuoteFieldCurrencyLabel => 'Devise';

  @override
  String get financeCreateQuoteFieldPaymentTermsLabel =>
      'Conditions de paiement';

  @override
  String get financeCreateQuoteSectionDeliverables => 'Livrables';

  @override
  String get financeCreateQuoteDeliverablePhotosTitle =>
      'Galerie photo retouchée';

  @override
  String get financeCreateQuoteDeliverablePhotosDescription =>
      'Sélection adaptée avec retouches globales.';

  @override
  String get financeCreateQuoteDeliverableSelectsTitle => 'Sélections premium';

  @override
  String get financeCreateQuoteDeliverableSelectsDescription =>
      'Jusqu\'à 20 retouches avancées.';

  @override
  String get financeCreateQuoteSectionNotes => 'Notes au client';

  @override
  String get financeCreateQuoteNotesHint =>
      'Ajoutez des précisions, délais ou conditions';

  @override
  String get financeCreateQuotePrimaryCta => 'Envoyer le devis';

  @override
  String get financeCreateQuotePaymentDueReceipt => 'Payable à réception';

  @override
  String get financeCreateQuotePaymentDue15 => 'Échéance à 15 jours';

  @override
  String get financeCreateQuotePaymentDue30 => 'Échéance à 30 jours';

  @override
  String get invitationNotificationsTitle => 'Notifications d\'invitation';

  @override
  String invitationNotificationsRole(Object role) {
    return 'Invité en tant que $role';
  }

  @override
  String get invitationNotificationsMarkRead => 'Marquer comme lu';

  @override
  String get invitationNotificationsStatusPending => 'En attente';

  @override
  String get invitationNotificationsStatusAccepted => 'Acceptée';

  @override
  String get invitationNotificationsStatusDeclined => 'Refusée';

  @override
  String get invitationNotificationsAcceptCta => 'Accepter';

  @override
  String get invitationNotificationsDeclineCta => 'Refuser';

  @override
  String get invitationNotificationsInviteAgain => 'Inviter à nouveau';

  @override
  String get invitationNotificationsEmptyAll => 'Aucune invitation à afficher.';

  @override
  String get invitationNotificationsEmptyPending =>
      'Tout est à jour : aucune invitation en attente.';

  @override
  String get invitationNotificationsEmptyResponded =>
      'Personne n\'a encore répondu.';

  @override
  String get invitationNotificationsFilterAll => 'Toutes';

  @override
  String get invitationNotificationsFilterPending => 'En attente';

  @override
  String get invitationNotificationsFilterResponded => 'Répondues';

  @override
  String get projectChatCollaboratorsTitle => 'Collaborateurs du projet';

  @override
  String get projectChatCollaboratorsEmpty =>
      'Aucun collaborateur ajouté pour l\'instant.';

  @override
  String get projectChatCollaboratorRoleFallback => 'Collaborateur';

  @override
  String get projectChatViewCollaboratorsHint =>
      'Touchez pour voir les collaborateurs';

  @override
  String get projectChatReceiptRead => 'Lu';

  @override
  String get projectChatReceiptReceived => 'Reçu';

  @override
  String get projectChatReceiptUnread => 'Non lu';

  @override
  String get projectChatReceiptSent => 'Envoyé';

  @override
  String get projectDetailBackToProjects => 'Retour aux projets';

  @override
  String get projectDetailClientPlaceholder => 'Client non renseigné';

  @override
  String get projectDetailMenuProjectChat => 'Discussion projet';

  @override
  String get projectDetailMenuInviteCollaborator => 'Inviter un collaborateur';

  @override
  String get projectDetailMenuRolesPermissions => 'Rôles & autorisations';

  @override
  String get projectDetailMenuArchive => 'Archiver le projet';

  @override
  String get projectDetailMenuDuplicate => 'Dupliquer le projet';

  @override
  String get projectDetailMenuDelete => 'Supprimer le projet';

  @override
  String get projectDetailScheduleTitle => 'Planning';

  @override
  String get projectDetailScheduleCta => 'Ouvrir le planning';

  @override
  String get projectDetailIndustryTitle => 'Contexte événement & traiteur';

  @override
  String get projectDetailIndustryGuests => 'Invités';

  @override
  String projectDetailIndustryGuestsValue(int count) {
    return '$count invités';
  }

  @override
  String get projectDetailIndustryMenu => 'Style de menu';

  @override
  String get projectDetailIndustryAllergies => 'Allergies & restrictions';

  @override
  String get projectDetailIndustryService => 'Déroulé du service';

  @override
  String get projectDetailIndustryTasting => 'Dégustation';

  @override
  String projectDetailIndustryTastingScheduled(Object date) {
    return 'Prévue le $date';
  }

  @override
  String get projectDetailIndustryTastingPending => 'Date à confirmer';

  @override
  String get projectDetailIndustryKitchen => 'Support cuisine';

  @override
  String get projectDetailIndustryKitchenRequired =>
      'Cuisine sur place requise';

  @override
  String get projectDetailIndustryKitchenOptional =>
      'Support cuisine optionnel';

  @override
  String get projectDetailIndustryKitchenNotes => 'Notes cuisine';

  @override
  String get projectDetailIndustryEmptyLabel => 'Détails industrie';

  @override
  String get projectDetailIndustryEmptyValue =>
      'Aucun contexte supplémentaire pour l\'instant.';

  @override
  String get projectDetailTeamTitle => 'Équipe';

  @override
  String projectDetailTeamCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# membres',
      one: '# membre',
    );
    return '$_temp0';
  }

  @override
  String get projectDetailTeamEmpty =>
      'Invitez des collaborateurs pour constituer l\'équipe.';

  @override
  String get projectDetailTasksTitle => 'Tâches';

  @override
  String get projectDetailTasksAddCta => 'Ajouter une tâche';

  @override
  String get projectDetailTasksEmpty => 'Aucune tâche pour l\'instant.';

  @override
  String get projectDetailDiscussionTitle => 'Discussion';

  @override
  String get projectDetailFinanceBilled => 'Facturé';

  @override
  String get projectDetailFinancePaid => 'Payé';

  @override
  String get projectDetailFinanceRemaining => 'Restant';

  @override
  String get projectDetailFinanceCreateQuote => 'Créer un devis';

  @override
  String get projectDetailFilesTitle => 'Fichiers';

  @override
  String get projectDetailFilesAdd => 'Ajouter un fichier';

  @override
  String get projectDetailTaskCreateTitle => 'Créer une tâche';

  @override
  String get projectDetailTaskTitleHint => 'Titre de la tâche';

  @override
  String get projectDetailTaskTitleError =>
      'Veuillez saisir un titre de tâche.';

  @override
  String get projectDetailTaskStatusLabel => 'Statut';

  @override
  String get projectDetailTaskStatusHint => 'Sélectionner un statut';

  @override
  String get projectDetailTaskScheduleLabel => 'Planification';

  @override
  String get projectDetailTaskStartDate => 'Date de début';

  @override
  String get projectDetailTaskDueDate => 'Date d\'échéance';

  @override
  String get projectDetailTaskAssigneeLabel => 'Assigné à';

  @override
  String get projectDetailTaskAssigneeHint => 'Choisir un membre';

  @override
  String get projectDetailTaskAssigneeEmpty =>
      'Invitez des collaborateurs pour assigner des tâches.';

  @override
  String get projectDetailTaskDetailsLabel => 'Détails';

  @override
  String get projectDetailTaskDetailsHint => 'Décrivez la tâche';

  @override
  String get projectDetailTaskAttachmentsLabel => 'Pièces jointes';

  @override
  String get projectDetailTaskAttachmentHint =>
      'Collez un lien ou un nom de fichier';

  @override
  String get projectDetailTaskAddAttachment => 'Ajouter une pièce jointe';

  @override
  String get projectDetailTaskStatusChange => 'Changer le statut';

  @override
  String projectDetailBadgeCompleted(Object range) {
    return 'Terminé $range';
  }

  @override
  String projectDetailBadgeDeferred(Object range) {
    return 'Reporté $range';
  }

  @override
  String projectDetailBadgeDueOn(Object date) {
    return 'Échéance le $date';
  }

  @override
  String projectDetailBadgeOverdue(Object range) {
    return 'En retard $range';
  }

  @override
  String projectDetailBadgeDueTodayRange(Object range) {
    return 'Échéance aujourd\'hui • $range';
  }

  @override
  String get projectDetailBadgeDueToday => 'Échéance aujourd\'hui';

  @override
  String projectDetailBadgeUpcoming(Object range) {
    return 'À venir • $range';
  }

  @override
  String projectDetailBadgeTimeline(Object range) {
    return 'Période • $range';
  }

  @override
  String projectDetailBadgeStarts(Object date) {
    return 'Début $date';
  }

  @override
  String get projectDetailProgressTitle => 'Progression du projet';

  @override
  String get projectDetailProgressEmpty =>
      'Aucune tâche suivie pour l\'instant.';

  @override
  String projectDetailProgressSummary(int completed, int total) {
    return '$completed sur $total tâches terminées';
  }

  @override
  String get projectDetailProgressMetricInProgress => 'En cours';

  @override
  String get projectDetailProgressMetricCompleted => 'Terminées';

  @override
  String get projectDetailProgressMetricRemaining => 'Restantes';

  @override
  String get projectDetailDiscussionEmpty => 'Aucun message pour le moment.';

  @override
  String get projectDetailDiscussionSend => 'Ouvrir la discussion';

  @override
  String get projectDetailTaskAssigneeUnassigned => 'Non assignée';

  @override
  String get projectDetailTaskScheduleEmpty => 'Aucun planning défini';

  @override
  String get projectDetailStatusActionPlanned => 'Marquer en cours';

  @override
  String get projectDetailStatusActionInProgress => 'Marquer terminé';

  @override
  String get projectDetailStatusActionCompleted => 'Rouvrir la tâche';

  @override
  String get projectDetailStatusActionDeferred => 'Réactiver la tâche';

  @override
  String projectDetailTaskAssignedTo(Object name) {
    return 'Assigné à $name';
  }

  @override
  String get inviteCollaboratorTitle => 'Inviter un collaborateur';

  @override
  String get inviteCollaboratorSelectProject => 'Sélectionner un projet';

  @override
  String get inviteCollaboratorChooseProject => 'Choisir un projet';

  @override
  String get inviteCollaboratorInfoText =>
      'Envoyez une invitation directe par e-mail ou depuis votre liste de contacts.';

  @override
  String get inviteCollaboratorEmailSection => 'Inviter par e-mail';

  @override
  String get inviteCollaboratorEmailHint => 'nom@entreprise.com';

  @override
  String get inviteCollaboratorFromContacts => 'Depuis mes contacts';

  @override
  String get inviteCollaboratorRoleSection => 'Rôle dans le projet';

  @override
  String get inviteCollaboratorRoleOwner => 'Propriétaire';

  @override
  String get inviteCollaboratorRoleEditor => 'Éditeur';

  @override
  String get inviteCollaboratorRoleViewer => 'Lecteur';

  @override
  String get inviteCollaboratorCustomRoleHint => 'Ajouter un rôle personnalisé';

  @override
  String get inviteCollaboratorAddRole => 'Ajouter un rôle';

  @override
  String get inviteCollaboratorMessageSection => 'Message personnel';

  @override
  String get inviteCollaboratorMessageHint =>
      'Message facultatif pour donner du contexte';

  @override
  String get inviteCollaboratorShareLinkTitle => 'Générer un lien partageable';

  @override
  String get inviteCollaboratorShareLinkSubtitle =>
      'Toute personne avec ce lien peut demander l\'accès avec le rôle sélectionné ci-dessus.';

  @override
  String get inviteCollaboratorCopyLink => 'Copier';

  @override
  String get inviteCollaboratorPrimaryCta => 'Envoyer l\'invitation';

  @override
  String get inviteCollaboratorSnackbarSelectProject =>
      'Choisissez un projet avant d\'envoyer une invitation.';

  @override
  String get inviteCollaboratorSnackbarEmailRequired =>
      'Ajoutez d\'abord l\'e-mail du collaborateur.';

  @override
  String inviteCollaboratorSnackbarSent(Object name) {
    return 'Invitation envoyée à $name.';
  }

  @override
  String get inviteCollaboratorSnackbarSelectProjectContacts =>
      'Choisissez d\'abord un projet pour inviter des contacts existants.';

  @override
  String inviteCollaboratorSnackbarContactsQueued(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# invitations planifiées.',
      one: '# invitation planifiée.',
    );
    return '$_temp0';
  }

  @override
  String get inviteCollaboratorFallbackName => 'Nouveau collaborateur';

  @override
  String get inviteCollaboratorInviteSheetTitle =>
      'Inviter depuis les contacts';

  @override
  String get inviteCollaboratorInviteSheetRoleLabel =>
      'Rôle appliqué à la sélection';

  @override
  String get inviteCollaboratorInviteSheetNoteLabel =>
      'Ajouter une note (optionnel)';

  @override
  String get inviteCollaboratorInviteSheetSelectContactError =>
      'Sélectionnez au moins un contact.';

  @override
  String get inviteCollaboratorInviteSheetPrimaryCta => 'Inviter les contacts';

  @override
  String get inviteCollaboratorAvailabilityAvailable => 'Disponible';

  @override
  String get inviteCollaboratorAvailabilityBusy => 'Occupé';

  @override
  String get inviteCollaboratorAvailabilityOffline => 'Hors ligne';

  @override
  String get rolesPermissionsTitle => 'Rôles & autorisations';

  @override
  String get rolesPermissionsRoleAdmin => 'Administrateur';

  @override
  String get rolesPermissionsRoleCollaborator => 'Collaborateur';

  @override
  String get rolesPermissionsRoleViewer => 'Lecteur';

  @override
  String get managementTitle => 'Gestion';

  @override
  String get managementSubtitle =>
      'Projets, staffing et blocages dans une seule vue.';

  @override
  String get managementEmptyTitle => 'Aucun projet pour l\'instant';

  @override
  String get managementEmptySubtitle =>
      'Créez votre premier projet pour suivre l\'avancement.';

  @override
  String get managementFilterOngoing => 'En cours';

  @override
  String get managementFilterUpcoming => 'À venir';

  @override
  String get managementFilterCompleted => 'Terminés';

  @override
  String managementProjectsHeading(int count) {
    return 'Projets ($count)';
  }

  @override
  String get managementCreateProjectTooltip => 'Créer un projet';

  @override
  String get crmContactTypeClient => 'Client';

  @override
  String get crmContactTypeCollaborator => 'Collaborateur';

  @override
  String get crmContactTypeSupplier => 'Fournisseur';

  @override
  String get crmRowInsights => 'Aperçus';

  @override
  String get crmRowEditContact => 'Modifier le contact';

  @override
  String get crmSectionLinkedProjects => 'Projets liés';

  @override
  String get crmSectionFinanceHistory => 'Historique financier';

  @override
  String get crmSectionDocuments => 'Documents';

  @override
  String get crmActionCreateProject => 'Créer un projet pour le client';

  @override
  String get crmActionSendQuote => 'Envoyer un devis';

  @override
  String get crmActionCreateInvoice => 'Créer une facture';

  @override
  String get crmActionOpenDetail => 'Ouvrir la fiche contact';

  @override
  String get financeQuoteClientSectionTitle => 'Client & projet';

  @override
  String get financeQuoteClientNameLabel => 'Nom du client';

  @override
  String get financeQuoteReferenceLabel => 'Projet / Référence (optionnel)';

  @override
  String get financeQuoteLineItemsTitle => 'Lignes';

  @override
  String get financeQuoteConditionsTitle => 'Conditions & validité';

  @override
  String get financeQuoteConditionsHint =>
      'Conditions de paiement, calendrier de livraison, notes...';

  @override
  String get financeQuoteOptionsTitle => 'Options';

  @override
  String get financeQuoteRequireSignature =>
      'Exiger une signature électronique';

  @override
  String get financeQuoteGenerateCta => 'Générer le devis';

  @override
  String financeQuoteExistingCount(int count) {
    return 'Devis existants : $count';
  }

  @override
  String get financeQuoteAddLineItem => 'Ajouter une ligne';

  @override
  String get financeQuoteDescriptionHint => 'Description';

  @override
  String get financeQuoteQuantityHint => 'Qté';

  @override
  String get financeQuoteUnitPriceHint => 'Prix unitaire';

  @override
  String get financeQuoteRemoveTooltip => 'Supprimer';

  @override
  String financeQuoteSubtotalLabel(Object amount) {
    return 'Sous-total : $amount';
  }

  @override
  String get financeQuoteFallbackClient => 'Client sans nom';

  @override
  String get financeQuoteFallbackDescription => 'Brouillon de devis';

  @override
  String financeInvoiceTitle(Object number) {
    return 'Facture n°$number';
  }

  @override
  String get financeInvoiceUnknownClient => 'Client inconnu';

  @override
  String financeInvoiceAmountLabel(Object amount) {
    return 'Montant : $amount';
  }

  @override
  String get financeInvoiceStatusDraft => 'Brouillon';

  @override
  String get financeInvoiceStatusUnpaid => 'Impayée';

  @override
  String get financeInvoiceStatusPaid => 'Payée';

  @override
  String get financeInvoiceFieldsTitle => 'Champs de facture';

  @override
  String get financeInvoiceIssueLabel => 'Date d\'émission';

  @override
  String get financeInvoiceDueLabel => 'Échéance';

  @override
  String get financeInvoiceDatePlaceholder => 'Sélectionner une date';

  @override
  String get financeInvoiceMethodLabel => 'Mode de paiement';

  @override
  String get financeInvoiceMethodBankTransfer => 'Virement bancaire';

  @override
  String get financeInvoiceMethodCard => 'Carte';

  @override
  String get financeInvoiceMethodApplePay => 'Apple Pay';

  @override
  String get financeInvoiceButtonAlreadyPaid => 'Déjà payée';

  @override
  String get financeInvoiceButtonMarkPaid => 'Marquer comme payée';

  @override
  String get financeInvoiceButtonSendReminder => 'Envoyer un rappel';

  @override
  String financeQuotePreviewTitle(Object id) {
    return 'Aperçu du devis n°$id';
  }

  @override
  String get financeQuotePreviewSendTooltip => 'Envoyer le devis';

  @override
  String get financeQuotePreviewSendSnack => 'Devis envoyé pour signature';

  @override
  String get financeQuotePreviewTrackCta => 'Suivre la signature';

  @override
  String get financeQuotePreviewTotalLabel => 'Total (TVA incluse)';

  @override
  String get financeQuoteStatusDraft => 'Brouillon';

  @override
  String get financeQuoteStatusPending => 'En attente de signature';

  @override
  String get financeQuoteStatusSigned => 'Signé';

  @override
  String get financeQuoteStatusDeclined => 'Refusé';

  @override
  String get financeQuotePreviewDocumentPlaceholder => 'Aperçu du PDF du devis';

  @override
  String get financeReportingTitle => 'Rapports financiers';

  @override
  String get financeReportingCardRevenue => 'Revenus par mois';

  @override
  String get financeReportingCardOutstanding => 'Factures impayées';

  @override
  String get financeReportingCardConversion => 'Taux de conversion des devis';

  @override
  String get financeReportingCardTopClients => 'Meilleurs clients';

  @override
  String get financeReportingExportCta => 'Exporter le résumé en PDF';

  @override
  String get financeReportingFiltersTitle => 'Rapports';

  @override
  String get financeReportingFilterRange => 'Période';

  @override
  String get financeReportingFilterGranularity => 'Granularité';

  @override
  String get financeReportingRange7Days => '7 derniers jours';

  @override
  String get financeReportingRange30Days => '30 derniers jours';

  @override
  String get financeReportingRangeQuarter => 'Depuis le début du trimestre';

  @override
  String get financeReportingRangeYear => 'Depuis le début de l\'année';

  @override
  String get financeReportingGranularityDaily => 'Quotidien';

  @override
  String get financeReportingGranularityWeekly => 'Hebdomadaire';

  @override
  String get financeReportingGranularityMonthly => 'Mensuel';

  @override
  String get financeInvoicesTitle => 'Factures';

  @override
  String get financeInvoicesEmpty => 'Aucune facture pour le moment.';

  @override
  String get financeInvoicesOpenDetail => 'Ouvrir la fiche';

  @override
  String get financeExpensesScreenTitle => 'Dépenses';

  @override
  String get financeExpensesFormTitle => 'Enregistrer une dépense';

  @override
  String get financeExpensesFormDescription => 'Description';

  @override
  String get financeExpensesFormAmount => 'Montant';

  @override
  String get financeExpensesFormDate => 'Date';

  @override
  String get financeExpensesSelectDate => 'Choisir une date';

  @override
  String get financeExpensesAddCta => 'Ajouter la dépense';

  @override
  String get financeExpensesAddSuccess => 'Dépense ajoutée';

  @override
  String get financeExpensesEmptyList => 'Aucune dépense enregistrée.';

  @override
  String get financeExpensesFormError =>
      'Ajoutez une description et un montant valide';

  @override
  String get financeCreateInvoiceTitle => 'Créer une facture';

  @override
  String get financeCreateInvoiceClientLabel => 'Nom du client';

  @override
  String get financeCreateInvoiceAmountLabel => 'Montant';

  @override
  String get financeCreateInvoiceReferenceLabel => 'Référence (optionnel)';

  @override
  String get financeCreateInvoiceDueLabel => 'Échéance';

  @override
  String get financeCreateInvoiceSelectDate => 'Choisir une date';

  @override
  String get financeCreateInvoiceSubmit => 'Créer la facture';

  @override
  String get financeCreateInvoiceSuccess => 'Facture créée';

  @override
  String get financeCreateInvoiceValidationError =>
      'Ajoutez un client et un montant';

  @override
  String get financeRecordPaymentTitle => 'Enregistrer un paiement';

  @override
  String get financeRecordPaymentInvoiceLabel => 'Facture';

  @override
  String get financeRecordPaymentNoInvoices =>
      'Toutes les factures sont à jour.';

  @override
  String get financeRecordPaymentSubmit => 'Marquer comme payée';

  @override
  String get financeRecordPaymentSuccess => 'Facture marquée payée';

  @override
  String get financeRecordPaymentValidationError =>
      'Sélectionnez une facture pour continuer';

  @override
  String get financeReportingChartPlaceholder => 'Graphique à venir';

  @override
  String get financeSignatureTrackingTitle => 'Suivi des signatures';

  @override
  String financeSignatureTrackingQuoteLabel(Object id) {
    return 'Devis n°$id';
  }

  @override
  String get financeSignatureStepWaiting => 'En attente de lecture';

  @override
  String get financeSignatureStepOpened => 'Ouvert';

  @override
  String get financeSignatureStepSigned => 'Signé';

  @override
  String get financeSignatureStepDeclined => 'Refusé';

  @override
  String get financeSignatureAdvanceButton => 'Avancer le statut';

  @override
  String get financeSignatureSignedSnack =>
      'Devis signé – brouillon de facture créé';
}
