// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'JetCV';

  @override
  String get comingSoon => 'Bientôt disponible';

  @override
  String get personalInformation => 'Informations Personnelles';

  @override
  String get yourProfile => 'Votre profil';

  @override
  String get enterYourPersonalInfo => 'Entrez vos informations personnelles';

  @override
  String get personalData => 'Données personnelles';

  @override
  String get contactInformation => 'Informations de contact';

  @override
  String get address => 'Adresse';

  @override
  String get firstName => 'Prénom';

  @override
  String get lastName => 'Nom';

  @override
  String get gender => 'Genre';

  @override
  String get dateOfBirth => 'Date de naissance';

  @override
  String get email => 'Email';

  @override
  String get phone => 'Téléphone';

  @override
  String get addressField => 'Adresse';

  @override
  String get city => 'Ville';

  @override
  String get state => 'Province';

  @override
  String get postalCode => 'Code Postal';

  @override
  String get country => 'Pays';

  @override
  String get selectPhoto => 'Sélectionner photo de profil';

  @override
  String get takePhoto => 'Prendre photo';

  @override
  String get chooseFromGallery => 'Choisir de la galerie';

  @override
  String get cancel => 'Annuler';

  @override
  String get addPhoto => 'Ajouter photo';

  @override
  String get replacePhoto => 'Remplacer photo';

  @override
  String get uploading => 'Téléchargement...';

  @override
  String get saveInformation => 'Sauvegarder informations';

  @override
  String get saving => 'Sauvegarde...';

  @override
  String get firstNameRequired => 'Le prénom est obligatoire';

  @override
  String get lastNameRequired => 'Le nom est obligatoire';

  @override
  String get genderRequired => 'Le genre est obligatoire';

  @override
  String get emailRequired => 'L\'email est obligatoire';

  @override
  String get validEmailRequired => 'Entrez un email valide';

  @override
  String get phoneRequired => 'Le téléphone est obligatoire';

  @override
  String get addressRequired => 'L\'adresse est obligatoire';

  @override
  String get cityRequired => 'La ville est obligatoire';

  @override
  String get stateRequired => 'La province est obligatoire';

  @override
  String get postalCodeRequired => 'Le code postal est obligatoire';

  @override
  String get countryRequired => 'Le pays est obligatoire';

  @override
  String get validDateRequired => 'Entrez une date de naissance valide';

  @override
  String get dateFormatRequired => 'Format requis: dd/mm/yyyy';

  @override
  String get invalidDate => 'Date invalide';

  @override
  String get invalidDay => 'Jour invalide (01-31)';

  @override
  String get invalidMonth => 'Mois invalide (01-12)';

  @override
  String invalidYear(int currentYear) {
    return 'Année invalide (1900-$currentYear)';
  }

  @override
  String get inexistentDate =>
      'Date inexistante (ex. 29/02 en année non bissextile)';

  @override
  String get searchCountry => 'Rechercher pays...';

  @override
  String get selectCountry => 'Sélectionner pays';

  @override
  String get noCountryFound => 'Aucun pays trouvé';

  @override
  String get fileTooLarge =>
      'Le fichier est trop volumineux. Maximum 5MB autorisés.';

  @override
  String get unsupportedFormat =>
      'Format de fichier non supporté. Utilisez JPG, PNG ou WebP.';

  @override
  String imageSelectionError(String error) {
    return 'Erreur lors de la sélection d\'image: $error';
  }

  @override
  String get profilePictureUploaded =>
      'Photo de profil téléchargée avec succès!';

  @override
  String uploadError(String error) {
    return 'Erreur lors du téléchargement: $error';
  }

  @override
  String photoUploadError(String error) {
    return 'Erreur lors du téléchargement de photo: $error. Les données personnelles seront quand même sauvegardées.';
  }

  @override
  String get informationSaved =>
      'Informations personnelles sauvegardées avec succès!';

  @override
  String get informationSavedWithPhotoError =>
      'Informations personnelles sauvegardées avec succès! (Note: la photo de profil n\'a pas été téléchargée)';

  @override
  String saveError(String error) {
    return 'Erreur de sauvegarde: $error';
  }

  @override
  String get languageSettings => 'Paramètres de Langue';

  @override
  String get selectLanguage => 'Sélectionner Langue';

  @override
  String get languageChanged => 'Langue changée avec succès';

  @override
  String get language => 'Langue';

  @override
  String get home => 'Accueil';

  @override
  String get cv => 'CV';

  @override
  String get profile => 'Profil';

  @override
  String get welcome => 'Bienvenue,';

  @override
  String get verifiedOnBlockchain => 'Curriculum certifié sur blockchain';

  @override
  String get quickActions => 'Actions rapides';

  @override
  String get newCV => 'Nouveau CV';

  @override
  String get createYourDigitalCV => 'Créez votre CV numérique';

  @override
  String get viewCV => 'Voir CV';

  @override
  String get yourDigitalCV => 'Votre CV numérique';

  @override
  String get cvViewInDevelopment => 'Vue CV - En développement';

  @override
  String get user => 'Utilisateur';

  @override
  String loginError(String error) {
    return 'Erreur de connexion: $error';
  }

  @override
  String googleAuthError(String error) {
    return 'Erreur d\'authentification Google: $error';
  }

  @override
  String get signInToAccount => 'Connectez-vous à votre compte';

  @override
  String get enterEmail => 'Entrez votre email';

  @override
  String get enterValidEmail => 'Entrez un email valide';

  @override
  String get password => 'Mot de passe';

  @override
  String get enterPassword => 'Entrez votre mot de passe';

  @override
  String get forgotPassword => 'Mot de passe oublié?';

  @override
  String get signIn => 'Se connecter';

  @override
  String get or => 'ou';

  @override
  String get continueWithGoogle => 'Continuer avec Google';

  @override
  String get noAccount => 'Vous n\'avez pas de compte? ';

  @override
  String get signUp => 'S\'inscrire';

  @override
  String get mustAcceptTerms => 'Vous devez accepter les termes et conditions';

  @override
  String get confirmEmail => 'Confirmer l\'email';

  @override
  String get emailConfirmationSent =>
      'Nous vous avons envoyé un email de confirmation. Cliquez sur le lien dans l\'email pour activer votre compte.';

  @override
  String get ok => 'OK';

  @override
  String get registrationCompleted => 'Inscription terminée';

  @override
  String get accountCreatedSuccess =>
      'Compte créé avec succès! Vous pouvez commencer à utiliser JetCV.';

  @override
  String get start => 'Commencer';

  @override
  String get createAccount => 'Créez votre compte';

  @override
  String get startJourney => 'Commencez votre parcours avec JetCV';

  @override
  String get fullName => 'Prénom et Nom';

  @override
  String get enterFullName => 'ex. Pierre Dupont';

  @override
  String get nameMinLength => 'Le nom doit avoir au moins 2 caractères';

  @override
  String get viewMyCV => 'Voir mon CV';

  @override
  String get copyLink => 'Copier le lien';

  @override
  String get share => 'Partager';

  @override
  String get createSecurePassword => 'Créez un mot de passe sécurisé';

  @override
  String get passwordMinLength =>
      'Le mot de passe doit avoir au moins 6 caractères';

  @override
  String get confirmPassword => 'Confirmer le mot de passe';

  @override
  String get confirmYourPassword => 'Confirmez votre mot de passe';

  @override
  String get passwordsDontMatch => 'Les mots de passe ne correspondent pas';

  @override
  String get acceptTerms => 'J\'accepte les ';

  @override
  String get termsAndConditions => 'Termes et Conditions';

  @override
  String get and => ' et la ';

  @override
  String get privacyPolicy => 'Politique de Confidentialité';

  @override
  String get haveAccount => 'Vous avez déjà un compte? ';

  @override
  String errorLabel(String error) {
    return 'Erreur: $error';
  }

  @override
  String get emailSent => 'Email envoyé!';

  @override
  String get passwordForgotten => 'Mot de passe oublié?';

  @override
  String get resetInstructionsSent =>
      'Nous avons envoyé les instructions de réinitialisation du mot de passe à votre email';

  @override
  String get dontWorryReset =>
      'Ne vous inquiétez pas! Entrez votre email et nous vous enverrons un lien pour réinitialiser le mot de passe';

  @override
  String get sendResetEmail => 'Envoyer l\'email de réinitialisation';

  @override
  String get checkEmailInstructions =>
      'Vérifiez votre email et cliquez sur le lien pour réinitialiser le mot de passe. Si vous ne voyez pas l\'email, vérifiez aussi le dossier spam.';

  @override
  String get backToLogin => 'Retour à la Connexion';

  @override
  String get rememberPassword => 'Vous vous souvenez du mot de passe? ';

  @override
  String get saveErrorGeneric => 'Erreur de sauvegarde';

  @override
  String get blockchainPowered => 'Alimenté par Blockchain';

  @override
  String get digitalCVTitle => 'Votre CV numérique\nvérifié sur blockchain';

  @override
  String get digitalCVDescription =>
      'Créez, gérez et partagez votre curriculum vitae avec la sécurité et l\'authenticité garanties par la technologie blockchain.';

  @override
  String get mainFeatures => 'Fonctionnalités principales';

  @override
  String get blockchainVerification => 'Vérification Blockchain';

  @override
  String get blockchainVerificationDesc =>
      'Vos données sont immuables et vérifiables sur la blockchain';

  @override
  String get secureSharing => 'Partage Sécurisé';

  @override
  String get secureSharingDesc =>
      'Partagez votre CV avec un lien sécurisé et traçable';

  @override
  String get realTimeUpdates => 'Mises à jour en Temps Réel';

  @override
  String get realTimeUpdatesDesc =>
      'Modifiez et mettez à jour votre CV à tout moment';

  @override
  String get jetcvInNumbers => 'JetCV en chiffres';

  @override
  String get cvsCreated => 'CVs Créés';

  @override
  String get activeUsers => 'Utilisateurs Actifs';

  @override
  String get security => 'Sécurité';

  @override
  String get readyToStart => 'Prêt à commencer?';

  @override
  String get createFirstCV =>
      'Créez votre premier CV numérique sur blockchain en quelques minutes';

  @override
  String get createYourCV => 'Créez votre CV';

  @override
  String get signInToYourAccount => 'Connectez-vous à votre compte';

  @override
  String get shareCV => 'Partager CV';

  @override
  String get shareText => 'Partager';

  @override
  String get cvLanguage => 'Langue affichage CV';

  @override
  String get personalInfo => 'Informations Personnelles';

  @override
  String get age => 'âge';

  @override
  String get contactInfo => 'Informations de Contact';

  @override
  String get languages => 'Langues';

  @override
  String get skills => 'Compétences';

  @override
  String get attitudes => 'Attitudes';

  @override
  String get languagesPlaceholder =>
      'Vos compétences linguistiques seront affichées ici';

  @override
  String get attitudesPlaceholder =>
      'Vos attitudes et compétences personnelles seront affichées ici';

  @override
  String get cvShared => 'Lien CV copié dans le presse-papiers !';

  @override
  String shareError(Object error) {
    return 'Erreur lors du partage : $error';
  }

  @override
  String get years => 'ans';

  @override
  String get born => 'né';

  @override
  String get bornFemale => 'née';

  @override
  String get blockchainCertified => 'Certifié Blockchain';

  @override
  String get cvSerial => 'Série CV';

  @override
  String get serialCode => 'Code série';

  @override
  String get verifiedCV => 'CV Vérifié';

  @override
  String get autodichiarazioni => 'Autodéclarations';

  @override
  String get spokenLanguages => 'Langues parlées :';

  @override
  String get noLanguageSpecified => 'Aucune langue spécifiée';

  @override
  String get certifications => 'Certifications';

  @override
  String get mostRecent => 'Plus Récentes';

  @override
  String get lessRecent => 'Less Recent';

  @override
  String get verifiedCertifications => 'certifications vérifiées';

  @override
  String get loadingCertifications => 'Chargement des certifications...';

  @override
  String get errorLoadingCertifications =>
      'Erreur lors du chargement des certifications';

  @override
  String get retry => 'Réessayer';

  @override
  String get noCvAvailable => 'Aucun CV disponible';

  @override
  String get errorLoadingCv => 'Erreur lors du chargement du CV';

  @override
  String get createYourFirstCv => 'Créez votre premier CV pour commencer';

  @override
  String get noCertificationsFound => 'Aucune certification trouvée';

  @override
  String get yourVerifiedCertifications =>
      'Vos certifications vérifiées apparaîtront ici';

  @override
  String get certification => 'Certification';

  @override
  String get certifyingBody => 'Organisme Certificateur';

  @override
  String get status => 'Statut';

  @override
  String get serial => 'Série';

  @override
  String get verifiedAndAuthenticated =>
      'Certification vérifiée et authentifiée';

  @override
  String get approved => 'Approuvée';

  @override
  String get verified => 'Vérifiée';

  @override
  String get completed => 'Terminée';

  @override
  String get pending => 'En Attente';

  @override
  String get inProgress => 'En Cours';

  @override
  String get rejected => 'Rejetée';

  @override
  String get failed => 'Échouée';

  @override
  String get nationality => 'Nationalité';

  @override
  String get noNationalitySpecified => 'Aucune nationalité spécifiée';

  @override
  String get cvLinkCopied =>
      'Lien du CV copié dans le presse-papiers ! Partagez-le maintenant.';

  @override
  String errorChangingLanguage(String error) {
    return 'Erreur lors du changement de langue : $error';
  }

  @override
  String get projectManagement => 'GESTION\nPROJETS';

  @override
  String get flutterDevelopment => 'DÉVELOPPEMENT\nFLUTTER';

  @override
  String get certified => 'CERTIFIÉ';

  @override
  String get myProfile => 'Mon Profil';

  @override
  String get myCV => 'Mon CV';

  @override
  String get myCertifications => 'Mes Certifications';

  @override
  String get otp => 'OTP';

  @override
  String get blockedByLegalEntity => 'Blocked by';

  @override
  String get legalEntity => 'Legal Entity';

  @override
  String get company => 'Company';

  @override
  String get vatNumber => 'VAT Number';

  @override
  String get website => 'Website';

  @override
  String get loadingLegalEntity => 'Loading company data...';

  @override
  String get legalEntityError => 'Error loading company data';

  @override
  String get filterOtps => 'Filter OTPs';

  @override
  String get allOtps => 'All';

  @override
  String get blockedOtps => 'Blocked';

  @override
  String get activeOtps => 'OTPs Actifs';

  @override
  String get noOtpsFound => 'No OTPs found';

  @override
  String get noOtpsFoundDescription => 'No OTPs match the selected filter';

  @override
  String get deleteAccount => 'Supprimer le Compte';

  @override
  String get logout => 'Déconnexion';

  @override
  String get otpVerification => 'Vérification OTP';

  @override
  String get otpDescription =>
      'Entrez le code à 6 chiffres envoyé à votre email enregistré';

  @override
  String get enterOTP => 'Entrez le code OTP';

  @override
  String get verifyOTP => 'Vérifier OTP';

  @override
  String get resendOTP => 'Renvoyer OTP';

  @override
  String get otpVerified => 'OTP vérifié avec succès !';

  @override
  String get invalidOTP => 'Code OTP invalide. Veuillez réessayer.';

  @override
  String get otpVerificationError =>
      'Erreur lors de la vérification OTP. Veuillez réessayer.';

  @override
  String get otpResent => 'Le code OTP a été renvoyé à votre email';

  @override
  String get otpResendError =>
      'Erreur lors du renvoi de l\'OTP. Veuillez réessayer.';

  @override
  String get securityInfo => 'Informations de Sécurité';

  @override
  String get otpSecurityNote =>
      'Pour votre sécurité, ce code OTP expirera dans 10 minutes. Ne partagez pas ce code avec qui que ce soit.';

  @override
  String get myOtps => 'Mes OTPs';

  @override
  String get permanentOtpCodes => 'Codes OTP Permanents';

  @override
  String get manageSecureAccessCodes => 'Gérez vos codes d\'accès sécurisés';

  @override
  String get noOtpGenerated => 'Aucun OTP Généré';

  @override
  String get createFirstOtpDescription =>
      'Créez votre premier code OTP permanent pour accéder en toute sécurité à la plateforme.';

  @override
  String get generateFirstOtp => 'Générer Premier OTP';

  @override
  String get newOtp => 'Nouveau OTP';

  @override
  String get addOptionalTagDescription =>
      'Ajoutez une étiquette optionnelle pour identifier cet OTP :';

  @override
  String get tagOptional => 'Étiquette (optionnelle)';

  @override
  String get generateOtp => 'Générer OTP';

  @override
  String get createdNow => 'Créé maintenant';

  @override
  String createdMinutesAgo(int minutes) {
    return 'Créé il y a $minutes minutes';
  }

  @override
  String createdHoursAgo(int hours) {
    return 'Créé il y a $hours heures';
  }

  @override
  String createdDaysAgo(int days) {
    return 'Créé il y a $days jours';
  }

  @override
  String get copy => 'Copier';

  @override
  String get qrCode => 'Code QR';

  @override
  String get deleteOtp => 'Supprimer OTP';

  @override
  String get deleteOtpConfirmation =>
      'Êtes-vous sûr de vouloir supprimer cet OTP ?';

  @override
  String get delete => 'Supprimer';

  @override
  String get otpCodeCopied => 'Code OTP copié dans le presse-papiers !';

  @override
  String get qrCodeOtp => 'Code QR OTP';

  @override
  String get qrCodeFor => 'Code QR pour';

  @override
  String get close => 'Fermer';

  @override
  String errorDuringLogout(String error) {
    return 'Erreur lors de la déconnexion : $error';
  }

  @override
  String get accountDeletionNotImplemented =>
      'Suppression de compte pas encore implémentée';

  @override
  String get editOtp => 'Edit OTP';

  @override
  String get editOtpTag => 'Edit OTP Tag';

  @override
  String get updateTag => 'Update Tag';

  @override
  String get otpTagUpdated => 'OTP tag updated successfully!';

  @override
  String get otpTagUpdateError => 'Error updating OTP tag. Please try again.';

  @override
  String get otpBlocked => 'OTP Blocked';

  @override
  String get otpBlockedMessage => 'OTP blocked - Actions not available';

  @override
  String get userNotLoaded => 'Utilisateur non chargé';

  @override
  String get trainingCourse => 'Cours de Formation';

  @override
  String otpNumber(int number) {
    return 'OTP #$number';
  }

  @override
  String get certifier => 'Certificateur';

  @override
  String get attachedMedia => 'Médias Joints';

  @override
  String attachedMediaCount(int count) {
    return 'Médias Joints ($count)';
  }

  @override
  String get documentationAndRelatedContent =>
      'Documentation et contenu connexe';

  @override
  String get mediaDividedInfo =>
      'Les médias sont divisés entre le contenu générique de certification et les documents spécifiques de votre parcours.';

  @override
  String get genericMedia => 'Médias de Contexte';

  @override
  String get didacticMaterialAndOfficialDocumentation =>
      'Matériel didactique et documentation officielle';

  @override
  String get personalMedia => 'Médias Certificatifs';

  @override
  String get documentsAndContentOfYourCertificationPath =>
      'Documents et contenu de votre parcours de certification';

  @override
  String get realTime => 'TEMPS RÉEL';

  @override
  String get uploadedInRealtime => 'téléchargé en temps réel';

  @override
  String get uploaded => 'TÉLÉCHARGÉ';

  @override
  String get view => 'Voir';

  @override
  String get download => 'Télécharger';

  @override
  String get otpCreatedSuccessfully => 'OTP created successfully';

  @override
  String get otpCreationFailed => 'Failed to create OTP';

  @override
  String get otpVerificationSuccess => 'OTP verified successfully';

  @override
  String get otpVerificationFailed => 'OTP verification failed';

  @override
  String get otpBurnedSuccessfully => 'OTP invalidated successfully';

  @override
  String get otpBurnFailed => 'Failed to invalidate OTP';

  @override
  String get otpMetadataRetrieved => 'OTP metadata retrieved';

  @override
  String get otpMetadataFailed => 'Failed to retrieve OTP metadata';

  @override
  String otpCleanupSuccess(int count) {
    return 'Cleaned up $count expired OTPs';
  }

  @override
  String get otpCleanupFailed => 'Failed to cleanup expired OTPs';

  @override
  String get invalidOtpCode => 'Invalid OTP code';

  @override
  String get otpExpired => 'OTP has expired';

  @override
  String get otpAlreadyUsed => 'OTP has already been used';

  @override
  String get otpAlreadyBurned => 'OTP has been invalidated';

  @override
  String get otpNotFound => 'OTP not found';

  @override
  String get generatingOtp => 'Generating OTP...';

  @override
  String get verifyingOtp => 'Verifying OTP...';

  @override
  String get burningOtp => 'Invalidating OTP...';

  @override
  String get loadingOtpMetadata => 'Loading OTP metadata...';

  @override
  String get cleaningUpOtps => 'Cleaning up expired OTPs...';

  @override
  String get otpCodeLength => 'Code length';

  @override
  String get otpTtlSeconds => 'Time to live (seconds)';

  @override
  String get otpNumericOnly => 'Numeric only';

  @override
  String get otpTag => 'Tag';

  @override
  String get otpIdUser => 'User ID';

  @override
  String get otpUsedBy => 'Used by';

  @override
  String get otpMarkUsed => 'Mark as used';

  @override
  String get otpCreatedAt => 'Created at';

  @override
  String get otpExpiresAt => 'Expires at';

  @override
  String get otpUsedAt => 'Used at';

  @override
  String get otpBurnedAt => 'Burned at';

  @override
  String get otpStatus => 'Status';

  @override
  String get otpStatusValid => 'Valid';

  @override
  String get otpStatusExpired => 'Expired';

  @override
  String get otpStatusUsed => 'Used';

  @override
  String get otpStatusBurned => 'Burned';

  @override
  String get addToLinkedIn => 'Add to LinkedIn';

  @override
  String get errorOpeningLinkedIn => 'Erreur lors de l\'ouverture de LinkedIn';

  @override
  String get addCertificationsToLinkedIn => 'Add Certification to LinkedIn';

  @override
  String get nftLink => 'Link Blockchain';

  @override
  String get errorOpeningNftLink => 'Error opening NFT link';

  @override
  String get viewBlockchainDetails => 'Voir les détails de la blockchain';

  @override
  String get linkedInIntegration => 'LinkedIn Certification Integration';

  @override
  String get shareCertificationsOnLinkedIn =>
      'This will copy the certification details to your clipboard and open LinkedIn. Then go to your profile → Add profile section → Licenses & certifications and paste the details.';

  @override
  String get realTimeMediaNotDownloadable =>
      'Real-time media cannot be downloaded';

  @override
  String get mediaNotAvailable => 'Media file is not available for download';

  @override
  String get createOpenBadge => 'Create Open Badge';

  @override
  String get openBadgeDescription =>
      'Create a verifiable digital badge for this certification. Open Badges are portable, verifiable credentials that can be shared on professional platforms.';

  @override
  String get openBadgeBenefits =>
      'Benefits: Portable, verifiable, shareable on LinkedIn and other platforms, follows international standards.';

  @override
  String get createBadge => 'Create Badge';

  @override
  String get openBadgeCreated => 'Open Badge Créé';

  @override
  String get openBadgeError => 'Error creating Open Badge';

  @override
  String get downloadPng => 'Download PNG';

  @override
  String get badgeImageSaved => 'Badge image saved successfully!';

  @override
  String get badgeImageError => 'Error downloading badge image';

  @override
  String get saveImageAs =>
      'Right-click on the image above and select \"Save image as...\" to download the badge PNG.';

  @override
  String get digitalCredentialsAndAchievements =>
      'Références numériques et réalisations';

  @override
  String get importYourOpenBadges => 'Importez vos Open Badges';

  @override
  String get showcaseYourDigitalCredentials =>
      'Mettez en valeur vos références numériques et réalisations';

  @override
  String get languageName_en => 'Anglais';

  @override
  String get languageName_it => 'Italien';

  @override
  String get languageName_fr => 'Français';

  @override
  String get languageName_es => 'Espagnol';

  @override
  String get languageName_de => 'Allemand';

  @override
  String get languageName_pt => 'Portugais';

  @override
  String get languageName_ru => 'Russe';

  @override
  String get languageName_zh => 'Chinois';

  @override
  String get languageName_ja => 'Japonais';

  @override
  String get languageName_ko => 'Coréen';

  @override
  String get languageName_ar => 'Arabe';

  @override
  String get languageName_hi => 'Hindi';

  @override
  String get languageName_tr => 'Turc';

  @override
  String get languageName_pl => 'Polonais';

  @override
  String get languageName_nl => 'Néerlandais';

  @override
  String get countryName_IT => 'Italie';

  @override
  String get countryName_FR => 'France';

  @override
  String get countryName_DE => 'Allemagne';

  @override
  String get countryName_ES => 'Espagne';

  @override
  String get countryName_GB => 'Royaume-Uni';

  @override
  String get countryName_US => 'États-Unis';

  @override
  String get countryName_CA => 'Canada';

  @override
  String get countryName_AU => 'Australie';

  @override
  String get countryName_JP => 'Japon';

  @override
  String get countryName_CN => 'Chine';

  @override
  String get countryName_BR => 'Brésil';

  @override
  String get countryName_IN => 'Inde';

  @override
  String get countryName_RU => 'Russie';

  @override
  String get countryName_MX => 'Mexique';

  @override
  String get countryName_AR => 'Argentine';

  @override
  String get countryName_NL => 'Pays-Bas';

  @override
  String get countryName_CH => 'Suisse';

  @override
  String get countryName_AT => 'Autriche';

  @override
  String get countryName_BE => 'Belgique';

  @override
  String get countryName_PT => 'Portugal';

  @override
  String get lastUpdate => 'Dernière mise à jour';

  @override
  String get certificationTitle => 'Titre';

  @override
  String get certificationOutcome => 'Résultat';

  @override
  String get certificationDetails => 'Détails';

  @override
  String get certType_attestato_di_frequenza => 'Certificat de présence';

  @override
  String get certType_certificato_di_competenza => 'Certificat de compétence';

  @override
  String get certType_diploma => 'Diplôme';

  @override
  String get certType_laurea => 'Diplôme universitaire';

  @override
  String get certType_master => 'Master';

  @override
  String get certType_corso_di_formazione => 'Cours de formation';

  @override
  String get certType_certificazione_professionale =>
      'Certification professionnelle';

  @override
  String get certType_patente => 'Licence';

  @override
  String get certType_abilitazione => 'Habilitation';

  @override
  String get serialNumber => 'Série';

  @override
  String get noOtpsYet => 'Aucun OTP encore';

  @override
  String get createYourFirstOtp => 'Créez votre premier OTP pour commencer';

  @override
  String get secureAccess => 'Accès Sécurisé';

  @override
  String get secureAccessDescription =>
      'Codes d\'accès sécurisés et temporaires';

  @override
  String get timeLimited =>
      'Expiration automatique pour une sécurité renforcée';

  @override
  String get timeLimitedDescription =>
      'Les codes expirent automatiquement pour assurer la sécurité';

  @override
  String get qrCodeSupport => 'Support QR Code';

  @override
  String get qrCodeSupportDescription =>
      'Générez et partagez des codes QR pour un accès rapide';

  @override
  String get otpCode => 'Code OTP';

  @override
  String get errorOccurred => 'Erreur';

  @override
  String get unknownError => 'Erreur inconnue';

  @override
  String get statusBurned => 'Brûlé';

  @override
  String get statusUsed => 'Utilisé';

  @override
  String get statusExpired => 'Expiré';

  @override
  String get statusValid => 'Valide';

  @override
  String get databaseConnectionFailed =>
      'Échec de la connexion à la base de données';

  @override
  String get edgeFunctionNotAccessible => 'Edge Function non accessible';

  @override
  String get preparingLinkedIn => 'Préparation de LinkedIn...';

  @override
  String get name => 'Nom';

  @override
  String get issuer => 'Émetteur';

  @override
  String get downloadingMedia => 'Téléchargement du média...';

  @override
  String get mediaDownloadedSuccessfully => 'Média téléchargé avec succès';

  @override
  String get errorDownloadingMedia => 'Erreur lors du téléchargement du média';

  @override
  String get errorCreatingOpenBadge =>
      'Erreur lors de la création de l\'Open Badge';

  @override
  String get issueDate => 'Date d\'émission';

  @override
  String get yourOpenBadgeCreatedSuccessfully =>
      'Votre Open Badge a été créé avec succès !';

  @override
  String get badge => 'Badge';

  @override
  String get filesSavedTo => 'Fichiers sauvegardés dans';

  @override
  String get connectionTestResults => 'Résultats du Test de Connexion';

  @override
  String get createOtp => 'Créer OTP';

  @override
  String get testConnection => 'Tester la Connexion';

  @override
  String get cleanupExpired => 'Nettoyer les Expirés';

  @override
  String get refresh => 'Actualiser';

  @override
  String get noOtpsAvailable => 'Aucun OTP disponible';

  @override
  String get codeCopiedToClipboard => 'Code copié dans le presse-papiers !';

  @override
  String get openBadges => 'Open Badges';

  @override
  String get badges => 'badges';

  @override
  String get loadingOpenBadges => 'Chargement des Open Badges...';

  @override
  String get errorLoadingOpenBadges =>
      'Erreur lors du chargement des Open Badges';

  @override
  String get noOpenBadgesFound => 'Aucun Open Badge trouvé';

  @override
  String get noOpenBadgesDescription =>
      'Importez votre premier OpenBadge pour commencer';

  @override
  String get importOpenBadge => 'Importer OpenBadge';

  @override
  String get valid => 'Valide';

  @override
  String get invalid => 'Non valide';

  @override
  String get revoked => 'Révoqué';

  @override
  String get source => 'Source (optionnel)';

  @override
  String get note => 'Note (optionnel)';

  @override
  String get import => 'Importer';

  @override
  String get viewAll => 'Voir tout';

  @override
  String get pendingCertifications => 'Certifications en attente';

  @override
  String get approvedCertifications => 'Certifications approuvées';

  @override
  String get rejectedCertifications => 'Certifications rejetées';

  @override
  String get pendingShort => 'En attente';

  @override
  String get approvedShort => 'Approuvées';

  @override
  String get rejectedShort => 'Rejetées';

  @override
  String get approve => 'Approuver';

  @override
  String get reject => 'Rejeter';

  @override
  String get confirmRejection => 'Confirmer le rejet';

  @override
  String get rejectCertificationMessage =>
      'Êtes-vous sûr de vouloir rejeter cette certification ?';

  @override
  String get rejectionReason => 'Motif du rejet (optionnel)';

  @override
  String get enterRejectionReason => 'Entrez le motif du rejet...';

  @override
  String get confirmReject => 'Confirmer le rejet';

  @override
  String get certificationApproved => 'Certification approuvée avec succès !';

  @override
  String get certificationRejected => 'Certification rejetée';

  @override
  String errorApprovingCertification(String error) {
    return 'Erreur lors de l\'approbation de la certification : $error';
  }

  @override
  String errorRejectingCertification(String error) {
    return 'Erreur lors du rejet de la certification : $error';
  }

  @override
  String get createdOn => 'Créé le';

  @override
  String get rejectedReason => 'Motif du rejet :';

  @override
  String get noRejectionReason => 'Aucun motif spécifié';

  @override
  String get blockchainCertificate => 'Certificat Blockchain';

  @override
  String get verifiedOnPolygonNetwork => 'Vérifié sur le réseau Polygon';

  @override
  String get transactionInformation => 'Informations de transaction';

  @override
  String get transactionId => 'ID de transaction';

  @override
  String get network => 'Réseau';

  @override
  String get blockHeight => 'Hauteur du bloc';

  @override
  String get gasUsed => 'Gas utilisé';

  @override
  String get nftInformation => 'Informations NFT';

  @override
  String get tokenId => 'ID du token';

  @override
  String get contractAddress => 'Adresse du contrat';

  @override
  String get standard => 'Standard';

  @override
  String get metadataUri => 'URI des métadonnées';

  @override
  String get mintInformation => 'Informations de frappe';

  @override
  String get mintDate => 'Date de frappe';

  @override
  String get minterAddress => 'Adresse du frappeur';

  @override
  String get mintPrice => 'Prix de frappe';

  @override
  String get certificateStatus => 'Statut';

  @override
  String get confirmed => 'Confirmé';

  @override
  String get certificateDetails => 'Détails du certificat';

  @override
  String get certificateName => 'Nom du certificat';

  @override
  String get blockchainVerified => 'Vérifié par blockchain';

  @override
  String get blockchainVerificationMessage =>
      'Ce certificat a été vérifié et stocké sur le réseau blockchain Polygon.';

  @override
  String get viewOnPolygonExplorer => 'Voir sur Polygon Explorer';

  @override
  String get polygon => 'Polygon';

  @override
  String get erc721 => 'ERC-721';

  @override
  String get cvCreationDate => 'Date de création du CV';

  @override
  String get monthJan => 'Jan';

  @override
  String get monthFeb => 'Fév';

  @override
  String get monthMar => 'Mar';

  @override
  String get monthApr => 'Avr';

  @override
  String get monthMay => 'Mai';

  @override
  String get monthJun => 'Jun';

  @override
  String get monthJul => 'Jul';

  @override
  String get monthAug => 'Aoû';

  @override
  String get monthSep => 'Sep';

  @override
  String get monthOct => 'Oct';

  @override
  String get monthNov => 'Nov';

  @override
  String get monthDec => 'Déc';

  @override
  String get certType_programma_certificato => 'Programme certifié';

  @override
  String get certType_dottorato_di_ricerca => 'Doctorat';

  @override
  String get certType_diploma_its => 'Diplôme ITS';

  @override
  String get certType_workshop => 'Atelier';

  @override
  String get certType_risultato_sportivo => 'Résultat sportif';

  @override
  String get certType_corso_specifico => 'Cours spécifique';

  @override
  String get certType_team_builder => 'Team builder';

  @override
  String get certType_corso_di_aggiornamento => 'Cours de mise à jour';

  @override
  String get certType_speech => 'Discours';

  @override
  String get certType_congresso => 'Congrès';

  @override
  String get certType_corso_specialistico => 'Cours spécialisé';

  @override
  String get certType_certificazione => 'Certification';

  @override
  String get certType_moderatore => 'Modérateur';

  @override
  String get certType_ruolo_professionale => 'Rôle professionnel';

  @override
  String get certType_volontariato => 'Bénévolat';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get resetPasswordTitle => 'Reset Your Password';

  @override
  String get resetPasswordDescription =>
      'Enter your email address and confirm with your old password to set a new password';

  @override
  String get enterEmailAddress => 'Enter Email Address';

  @override
  String get enterOldPassword => 'Enter Old Password';

  @override
  String get enterNewPassword => 'Enter New Password';

  @override
  String get confirmNewPassword => 'Confirm New Password';

  @override
  String get updatePassword => 'Update Password';

  @override
  String get updatingPassword => 'Updating Password...';

  @override
  String get passwordUpdatedSuccessfully => 'Password updated successfully!';

  @override
  String get passwordUpdateFailed => 'Failed to update password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get oldPasswordIncorrect => 'Old password is incorrect';

  @override
  String get newPasswordTooShort =>
      'New password must be at least 6 characters';

  @override
  String get oldPasswordRequired => 'Old password is required';

  @override
  String get newPasswordRequired => 'New password is required';

  @override
  String get confirmPasswordRequired => 'Password confirmation is required';

  @override
  String get passwordUpdateSuccess =>
      'Password updated successfully. Please log in with your new password.';

  @override
  String get authenticationFailed => 'Authentication failed';

  @override
  String get updateFailed => 'Update failed';

  @override
  String get invalidCredentials => 'Invalid credentials';

  @override
  String get authenticationError => 'Authentication error';

  @override
  String get unexpectedError => 'Unexpected error';
}
