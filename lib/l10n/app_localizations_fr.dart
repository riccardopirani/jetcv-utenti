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
  String get dateOfBirth => 'Date de naissance (dd/mm/yyyy)';

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
  String get verifiedOnBlockchain => 'Compte vérifié sur blockchain';

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
  String get fullName => 'Nom complet';

  @override
  String get enterFullName => 'Entrez votre nom complet';

  @override
  String get nameMinLength => 'Le nom doit avoir au moins 2 caractères';

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
  String get cvLanguage => 'Langue CV';

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
  String get verifiedCV => 'CV Vérifié';
}
