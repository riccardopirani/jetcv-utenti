// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'JetCV';

  @override
  String get personalInformation => 'Persönliche Informationen';

  @override
  String get yourProfile => 'Ihr Profil';

  @override
  String get enterYourPersonalInfo =>
      'Geben Sie Ihre persönlichen Informationen ein';

  @override
  String get personalData => 'Persönliche Daten';

  @override
  String get contactInformation => 'Kontaktinformationen';

  @override
  String get address => 'Adresse';

  @override
  String get firstName => 'Vorname';

  @override
  String get lastName => 'Nachname';

  @override
  String get gender => 'Geschlecht';

  @override
  String get dateOfBirth => 'Geburtsdatum';

  @override
  String get email => 'E-Mail';

  @override
  String get phone => 'Telefon';

  @override
  String get addressField => 'Adresse';

  @override
  String get city => 'Stadt';

  @override
  String get state => 'Bundesland';

  @override
  String get postalCode => 'Postleitzahl';

  @override
  String get country => 'Land';

  @override
  String get selectPhoto => 'Profilbild auswählen';

  @override
  String get takePhoto => 'Foto aufnehmen';

  @override
  String get chooseFromGallery => 'Aus Galerie wählen';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get addPhoto => 'Foto hinzufügen';

  @override
  String get replacePhoto => 'Foto ersetzen';

  @override
  String get uploading => 'Hochladen...';

  @override
  String get saveInformation => 'Informationen speichern';

  @override
  String get saving => 'Speichere...';

  @override
  String get firstNameRequired => 'Vorname ist erforderlich';

  @override
  String get lastNameRequired => 'Nachname ist erforderlich';

  @override
  String get genderRequired => 'Geschlecht ist erforderlich';

  @override
  String get emailRequired => 'E-Mail ist erforderlich';

  @override
  String get validEmailRequired => 'Geben Sie eine gültige E-Mail ein';

  @override
  String get phoneRequired => 'Telefon ist erforderlich';

  @override
  String get addressRequired => 'Adresse ist erforderlich';

  @override
  String get cityRequired => 'Stadt ist erforderlich';

  @override
  String get stateRequired => 'Bundesland ist erforderlich';

  @override
  String get postalCodeRequired => 'Postleitzahl ist erforderlich';

  @override
  String get countryRequired => 'Land ist erforderlich';

  @override
  String get validDateRequired => 'Geben Sie ein gültiges Geburtsdatum ein';

  @override
  String get dateFormatRequired => 'Erforderliches Format: dd/mm/yyyy';

  @override
  String get invalidDate => 'Ungültiges Datum';

  @override
  String get invalidDay => 'Ungültiger Tag (01-31)';

  @override
  String get invalidMonth => 'Ungültiger Monat (01-12)';

  @override
  String invalidYear(int currentYear) {
    return 'Ungültiges Jahr (1900-$currentYear)';
  }

  @override
  String get inexistentDate =>
      'Nicht existierendes Datum (z.B. 29/02 in einem Nicht-Schaltjahr)';

  @override
  String get searchCountry => 'Land suchen...';

  @override
  String get selectCountry => 'Land auswählen';

  @override
  String get noCountryFound => 'Kein Land gefunden';

  @override
  String get fileTooLarge => 'Die Datei ist zu groß. Maximum 5MB erlaubt.';

  @override
  String get unsupportedFormat =>
      'Nicht unterstütztes Dateiformat. Verwenden Sie JPG, PNG oder WebP.';

  @override
  String imageSelectionError(String error) {
    return 'Fehler bei der Bildauswahl: $error';
  }

  @override
  String get profilePictureUploaded => 'Profilbild erfolgreich hochgeladen!';

  @override
  String uploadError(String error) {
    return 'Upload-Fehler: $error';
  }

  @override
  String photoUploadError(String error) {
    return 'Fehler beim Hochladen des Fotos: $error. Persönliche Daten werden trotzdem gespeichert.';
  }

  @override
  String get informationSaved =>
      'Persönliche Informationen erfolgreich gespeichert!';

  @override
  String get informationSavedWithPhotoError =>
      'Persönliche Informationen erfolgreich gespeichert! (Hinweis: Profilbild wurde nicht hochgeladen)';

  @override
  String saveError(String error) {
    return 'Speicherfehler: $error';
  }

  @override
  String get languageSettings => 'Spracheinstellungen';

  @override
  String get selectLanguage => 'Sprache auswählen';

  @override
  String get languageChanged => 'Sprache erfolgreich geändert';

  @override
  String get language => 'Sprache';

  @override
  String get home => 'Start';

  @override
  String get cv => 'Lebenslauf';

  @override
  String get profile => 'Profil';

  @override
  String get welcome => 'Willkommen,';

  @override
  String get verifiedOnBlockchain => 'Konto auf Blockchain verifiziert';

  @override
  String get quickActions => 'Schnelle Aktionen';

  @override
  String get newCV => 'Neuer Lebenslauf';

  @override
  String get createYourDigitalCV => 'Erstellen Sie Ihren digitalen Lebenslauf';

  @override
  String get viewCV => 'Lebenslauf anzeigen';

  @override
  String get yourDigitalCV => 'Ihr digitaler Lebenslauf';

  @override
  String get cvViewInDevelopment => 'Lebenslauf-Ansicht - In Entwicklung';

  @override
  String get user => 'Benutzer';

  @override
  String loginError(String error) {
    return 'Anmeldefehler: $error';
  }

  @override
  String googleAuthError(String error) {
    return 'Google-Authentifizierungsfehler: $error';
  }

  @override
  String get signInToAccount => 'Melden Sie sich in Ihrem Konto an';

  @override
  String get enterEmail => 'Geben Sie Ihre E-Mail ein';

  @override
  String get enterValidEmail => 'Geben Sie eine gültige E-Mail ein';

  @override
  String get password => 'Passwort';

  @override
  String get enterPassword => 'Geben Sie Ihr Passwort ein';

  @override
  String get forgotPassword => 'Passwort vergessen?';

  @override
  String get signIn => 'Anmelden';

  @override
  String get or => 'oder';

  @override
  String get continueWithGoogle => 'Mit Google fortfahren';

  @override
  String get noAccount => 'Haben Sie kein Konto? ';

  @override
  String get signUp => 'Registrieren';

  @override
  String get mustAcceptTerms =>
      'Sie müssen die Nutzungsbedingungen akzeptieren';

  @override
  String get confirmEmail => 'E-Mail bestätigen';

  @override
  String get emailConfirmationSent =>
      'Wir haben Ihnen eine Bestätigungs-E-Mail gesendet. Klicken Sie auf den Link in der E-Mail, um Ihr Konto zu aktivieren.';

  @override
  String get ok => 'OK';

  @override
  String get registrationCompleted => 'Registrierung abgeschlossen';

  @override
  String get accountCreatedSuccess =>
      'Konto erfolgreich erstellt! Sie können JetCV verwenden.';

  @override
  String get start => 'Starten';

  @override
  String get createAccount => 'Erstellen Sie Ihr Konto';

  @override
  String get startJourney => 'Beginnen Sie Ihre Reise mit JetCV';

  @override
  String get fullName => 'Vollständiger Name';

  @override
  String get enterFullName => 'Geben Sie Ihren vollständigen Namen ein';

  @override
  String get nameMinLength => 'Der Name muss mindestens 2 Zeichen haben';

  @override
  String get viewMyCV => 'Mein CV anzeigen';

  @override
  String get copyLink => 'Link kopieren';

  @override
  String get share => 'Teilen';

  @override
  String get createSecurePassword => 'Erstellen Sie ein sicheres Passwort';

  @override
  String get passwordMinLength =>
      'Das Passwort muss mindestens 6 Zeichen haben';

  @override
  String get confirmPassword => 'Passwort bestätigen';

  @override
  String get confirmYourPassword => 'Bestätigen Sie Ihr Passwort';

  @override
  String get passwordsDontMatch => 'Die Passwörter stimmen nicht überein';

  @override
  String get acceptTerms => 'Ich akzeptiere die ';

  @override
  String get termsAndConditions => 'Nutzungsbedingungen';

  @override
  String get and => ' und die ';

  @override
  String get privacyPolicy => 'Datenschutzrichtlinie';

  @override
  String get haveAccount => 'Haben Sie bereits ein Konto? ';

  @override
  String errorLabel(String error) {
    return 'Fehler: $error';
  }

  @override
  String get emailSent => 'E-Mail gesendet!';

  @override
  String get passwordForgotten => 'Passwort vergessen?';

  @override
  String get resetInstructionsSent =>
      'Wir haben Anweisungen zum Zurücksetzen des Passworts an Ihre E-Mail gesendet';

  @override
  String get dontWorryReset =>
      'Keine Sorge! Geben Sie Ihre E-Mail ein und wir senden Ihnen einen Link zum Zurücksetzen des Passworts';

  @override
  String get sendResetEmail => 'Zurücksetzungs-E-Mail senden';

  @override
  String get checkEmailInstructions =>
      'Überprüfen Sie Ihre E-Mail und klicken Sie auf den Link, um das Passwort zurückzusetzen. Wenn Sie die E-Mail nicht sehen, überprüfen Sie auch den Spam-Ordner.';

  @override
  String get backToLogin => 'Zurück zur Anmeldung';

  @override
  String get rememberPassword => 'Erinnern Sie sich an das Passwort? ';

  @override
  String get saveErrorGeneric => 'Speicherfehler';

  @override
  String get blockchainPowered => 'Blockchain-betrieben';

  @override
  String get digitalCVTitle =>
      'Ihr digitaler Lebenslauf\nauf Blockchain verifiziert';

  @override
  String get digitalCVDescription =>
      'Erstellen, verwalten und teilen Sie Ihren Lebenslauf mit der Sicherheit und Authentizität, die durch Blockchain-Technologie garantiert wird.';

  @override
  String get mainFeatures => 'Hauptfunktionen';

  @override
  String get blockchainVerification => 'Blockchain-Verifizierung';

  @override
  String get blockchainVerificationDesc =>
      'Ihre Daten sind unveränderlich und auf der Blockchain verifizierbar';

  @override
  String get secureSharing => 'Sicheres Teilen';

  @override
  String get secureSharingDesc =>
      'Teilen Sie Ihren Lebenslauf mit einem sicheren und nachverfolgbaren Link';

  @override
  String get realTimeUpdates => 'Echtzeit-Updates';

  @override
  String get realTimeUpdatesDesc =>
      'Bearbeiten und aktualisieren Sie Ihren Lebenslauf jederzeit';

  @override
  String get jetcvInNumbers => 'JetCV in Zahlen';

  @override
  String get cvsCreated => 'Lebensläufe Erstellt';

  @override
  String get activeUsers => 'Aktive Benutzer';

  @override
  String get security => 'Sicherheit';

  @override
  String get readyToStart => 'Bereit anzufangen?';

  @override
  String get createFirstCV =>
      'Erstellen Sie Ihren ersten digitalen Lebenslauf auf Blockchain in wenigen Minuten';

  @override
  String get createYourCV => 'Erstellen Sie Ihren Lebenslauf';

  @override
  String get signInToYourAccount => 'Melden Sie sich in Ihrem Konto an';

  @override
  String get shareCV => 'Lebenslauf teilen';

  @override
  String get shareText => 'Teilen';

  @override
  String get cvLanguage => 'CV-Anzeigesprache';

  @override
  String get personalInfo => 'Persönliche Informationen';

  @override
  String get age => 'Alter';

  @override
  String get contactInfo => 'Kontaktinformationen';

  @override
  String get languages => 'Sprachen';

  @override
  String get skills => 'Fähigkeiten';

  @override
  String get attitudes => 'Einstellungen';

  @override
  String get languagesPlaceholder =>
      'Ihre Sprachkenntnisse werden hier angezeigt';

  @override
  String get attitudesPlaceholder =>
      'Ihre Einstellungen und Soft Skills werden hier angezeigt';

  @override
  String get cvShared => 'Lebenslauf-Link in die Zwischenablage kopiert!';

  @override
  String shareError(Object error) {
    return 'Fehler beim Teilen: $error';
  }

  @override
  String get years => 'Jahre';

  @override
  String get born => 'geboren';

  @override
  String get bornFemale => 'geboren';

  @override
  String get blockchainCertified => 'Blockchain Zertifiziert';

  @override
  String get cvSerial => 'Lebenslauf-Serie';

  @override
  String get serialCode => 'Seriencode';

  @override
  String get verifiedCV => 'Verifizierter Lebenslauf';
}
