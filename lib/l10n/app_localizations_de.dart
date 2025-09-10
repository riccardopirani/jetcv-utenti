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
  String get comingSoon => 'Demnächst verfügbar';

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
  String get home => 'Startseite';

  @override
  String get cv => 'Lebenslauf';

  @override
  String get profile => 'Profil';

  @override
  String get welcome => 'Willkommen,';

  @override
  String get verifiedOnBlockchain => 'Curriculum auf Blockchain zertifiziert';

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

  @override
  String get autodichiarazioni => 'Selbsterklärungen';

  @override
  String get spokenLanguages => 'Gesprochene Sprachen:';

  @override
  String get noLanguageSpecified => 'Keine Sprache angegeben';

  @override
  String get certifications => 'Zertifizierungen';

  @override
  String get mostRecent => 'Neueste';

  @override
  String get lessRecent => 'Less Recent';

  @override
  String get verifiedCertifications => 'verifizierte Zertifizierungen';

  @override
  String get loadingCertifications => 'Lade Zertifizierungen...';

  @override
  String get errorLoadingCertifications =>
      'Fehler beim Laden der Zertifizierungen';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get noCertificationsFound => 'Keine Zertifizierungen gefunden';

  @override
  String get yourVerifiedCertifications =>
      'Ihre verifizierten Zertifizierungen erscheinen hier';

  @override
  String get certification => 'Zertifizierung';

  @override
  String get certifyingBody => 'Zertifizierungsstelle';

  @override
  String get status => 'Status';

  @override
  String get serial => 'Serie';

  @override
  String get verifiedAndAuthenticated =>
      'Verifizierte und authentifizierte Zertifizierung';

  @override
  String get approved => 'Genehmigt';

  @override
  String get verified => 'Verifiziert';

  @override
  String get completed => 'Abgeschlossen';

  @override
  String get pending => 'Ausstehend';

  @override
  String get inProgress => 'In Bearbeitung';

  @override
  String get rejected => 'Abgelehnt';

  @override
  String get failed => 'Fehlgeschlagen';

  @override
  String get nationality => 'Nationalität';

  @override
  String get noNationalitySpecified => 'Keine Nationalität angegeben';

  @override
  String get cvLinkCopied =>
      'CV-Link in die Zwischenablage kopiert! Teilen Sie ihn jetzt.';

  @override
  String errorChangingLanguage(String error) {
    return 'Fehler beim Ändern der Sprache: $error';
  }

  @override
  String get projectManagement => 'PROJEKTMANAGEMENT';

  @override
  String get flutterDevelopment => 'FLUTTER\nENTWICKLUNG';

  @override
  String get certified => 'ZERTIFIZIERT';

  @override
  String get myProfile => 'Mein Profil';

  @override
  String get myCV => 'Mein Lebenslauf';

  @override
  String get myCertifications => 'Meine Zertifizierungen';

  @override
  String get otp => 'OTP';

  @override
  String get myWallets => 'Meine Wallets';

  @override
  String get viewYourDigitalWallets => 'View your digital wallets';

  @override
  String get wallet => 'Wallet';

  @override
  String get walletDescription =>
      'Your CV is saved in this wallet on the blockchain to always guarantee its authenticity';

  @override
  String get owner => 'Owner';

  @override
  String get walletAddress => 'Wallet Address';

  @override
  String get copyAddress => 'Copy address';

  @override
  String get addressCopied => 'Address copied to clipboard';

  @override
  String get noWalletFound => 'No wallet found';

  @override
  String get walletNotFoundDescription =>
      'You don\'t have a wallet associated with your account yet';

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
  String get activeOtps => 'Aktive OTPs';

  @override
  String get noOtpsFound => 'No OTPs found';

  @override
  String get noOtpsFoundDescription => 'No OTPs match the selected filter';

  @override
  String get deleteAccount => 'Konto löschen';

  @override
  String get logout => 'Abmelden';

  @override
  String get otpVerification => 'OTP-Verifizierung';

  @override
  String get otpDescription =>
      'Geben Sie den 6-stelligen Code ein, der an Ihre registrierte E-Mail gesendet wurde';

  @override
  String get enterOTP => 'OTP-Code eingeben';

  @override
  String get verifyOTP => 'OTP verifizieren';

  @override
  String get resendOTP => 'OTP erneut senden';

  @override
  String get otpVerified => 'OTP erfolgreich verifiziert!';

  @override
  String get invalidOTP =>
      'Ungültiger OTP-Code. Bitte versuchen Sie es erneut.';

  @override
  String get otpVerificationError =>
      'Fehler bei der OTP-Verifizierung. Bitte versuchen Sie es erneut.';

  @override
  String get otpResent => 'Der OTP-Code wurde an Ihre E-Mail erneut gesendet';

  @override
  String get otpResendError =>
      'Fehler beim erneuten Senden des OTP. Bitte versuchen Sie es erneut.';

  @override
  String get securityInfo => 'Sicherheitsinformationen';

  @override
  String get otpSecurityNote =>
      'Zu Ihrer Sicherheit läuft dieser OTP-Code in 10 Minuten ab. Teilen Sie diesen Code mit niemandem.';

  @override
  String get myOtps => 'Meine OTPs';

  @override
  String get permanentOtpCodes => 'Permanente OTP-Codes';

  @override
  String get manageSecureAccessCodes =>
      'Verwalten Sie Ihre sicheren Zugangscodes';

  @override
  String get noOtpGenerated => 'Kein OTP Generiert';

  @override
  String get createFirstOtpDescription =>
      'Erstellen Sie Ihren ersten permanenten OTP-Code, um sicher auf die Plattform zuzugreifen.';

  @override
  String get generateFirstOtp => 'Ersten OTP Generieren';

  @override
  String get newOtp => 'Neuer OTP';

  @override
  String get addOptionalTagDescription =>
      'Fügen Sie ein optionales Tag hinzu, um diesen OTP zu identifizieren:';

  @override
  String get tagOptional => 'Tag (optional)';

  @override
  String get generateOtp => 'OTP Generieren';

  @override
  String get createdNow => 'Jetzt erstellt';

  @override
  String createdMinutesAgo(int minutes) {
    return 'Vor $minutes Minuten erstellt';
  }

  @override
  String createdHoursAgo(int hours) {
    return 'Vor $hours Stunden erstellt';
  }

  @override
  String createdDaysAgo(int days) {
    return 'Vor $days Tagen erstellt';
  }

  @override
  String get copy => 'Kopieren';

  @override
  String get qrCode => 'QR-Code';

  @override
  String get deleteOtp => 'OTP Löschen';

  @override
  String get deleteOtpConfirmation =>
      'Sind Sie sicher, dass Sie diesen OTP löschen möchten?';

  @override
  String get delete => 'Löschen';

  @override
  String get otpCodeCopied => 'OTP-Code in die Zwischenablage kopiert!';

  @override
  String get qrCodeOtp => 'QR-Code OTP';

  @override
  String get qrCodeFor => 'QR-Code für';

  @override
  String get close => 'Schließen';

  @override
  String errorDuringLogout(String error) {
    return 'Fehler beim Abmelden: $error';
  }

  @override
  String get accountDeletionNotImplemented =>
      'Kontolöschung noch nicht implementiert';

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
  String get userNotLoaded => 'Benutzer nicht geladen';

  @override
  String get trainingCourse => 'Schulungskurs';

  @override
  String otpNumber(int number) {
    return 'OTP #$number';
  }

  @override
  String get certifier => 'Zertifizierer';

  @override
  String get attachedMedia => 'Angehängte Medien';

  @override
  String attachedMediaCount(int count) {
    return 'Angehängte Medien ($count)';
  }

  @override
  String get documentationAndRelatedContent =>
      'Dokumentation und verwandte Inhalte';

  @override
  String get mediaDividedInfo =>
      'Medien sind zwischen generischen Zertifizierungsinhalten und spezifischen Dokumenten Ihres Weges aufgeteilt.';

  @override
  String get genericMedia => 'Kontextmedien';

  @override
  String get didacticMaterialAndOfficialDocumentation =>
      'Didaktisches Material und offizielle Dokumentation';

  @override
  String get personalMedia => 'Zertifizierungsmedien';

  @override
  String get documentsAndContentOfYourCertificationPath =>
      'Dokumente und Inhalte Ihres Zertifizierungsweges';

  @override
  String get realTime => 'ECHTZEIT';

  @override
  String get uploadedInRealtime => 'in Echtzeit hochgeladen';

  @override
  String get uploaded => 'HOCHGELADEN';

  @override
  String get view => 'Anzeigen';

  @override
  String get download => 'Herunterladen';

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
  String get errorOpeningLinkedIn => 'Fehler beim Öffnen von LinkedIn';

  @override
  String get addCertificationsToLinkedIn => 'Add Certification to LinkedIn';

  @override
  String get nftLink => 'Link Blockchain';

  @override
  String get errorOpeningNftLink => 'Error opening NFT link';

  @override
  String get viewBlockchainDetails => 'Blockchain-Details anzeigen';

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
  String get openBadgeCreated => 'Open Badge Erstellt';

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
      'Digitale Zeugnisse und Erfolge';

  @override
  String get importYourOpenBadges => 'Importieren Sie Ihre Open Badges';

  @override
  String get showcaseYourDigitalCredentials =>
      'Zeigen Sie Ihre digitalen Zeugnisse und Erfolge';

  @override
  String get languageName_en => 'Englisch';

  @override
  String get languageName_it => 'Italienisch';

  @override
  String get languageName_fr => 'Französisch';

  @override
  String get languageName_es => 'Spanisch';

  @override
  String get languageName_de => 'Deutsch';

  @override
  String get languageName_pt => 'Portugiesisch';

  @override
  String get languageName_ru => 'Russisch';

  @override
  String get languageName_zh => 'Chinesisch';

  @override
  String get languageName_ja => 'Japanisch';

  @override
  String get languageName_ko => 'Koreanisch';

  @override
  String get languageName_ar => 'Arabisch';

  @override
  String get languageName_hi => 'Hindi';

  @override
  String get languageName_tr => 'Türkisch';

  @override
  String get languageName_pl => 'Polnisch';

  @override
  String get languageName_nl => 'Niederländisch';

  @override
  String get countryName_IT => 'Italien';

  @override
  String get countryName_FR => 'Frankreich';

  @override
  String get countryName_DE => 'Deutschland';

  @override
  String get countryName_ES => 'Spanien';

  @override
  String get countryName_GB => 'Vereinigtes Königreich';

  @override
  String get countryName_US => 'Vereinigte Staaten';

  @override
  String get countryName_CA => 'Kanada';

  @override
  String get countryName_AU => 'Australien';

  @override
  String get countryName_JP => 'Japan';

  @override
  String get countryName_CN => 'China';

  @override
  String get countryName_BR => 'Brasilien';

  @override
  String get countryName_IN => 'Indien';

  @override
  String get countryName_RU => 'Russland';

  @override
  String get countryName_MX => 'Mexiko';

  @override
  String get countryName_AR => 'Argentinien';

  @override
  String get countryName_NL => 'Niederlande';

  @override
  String get countryName_CH => 'Schweiz';

  @override
  String get countryName_AT => 'Österreich';

  @override
  String get countryName_BE => 'Belgien';

  @override
  String get countryName_PT => 'Portugal';

  @override
  String get lastUpdate => 'Letzte Aktualisierung';

  @override
  String get certificationTitle => 'Titel';

  @override
  String get certificationOutcome => 'Ergebnis';

  @override
  String get certificationDetails => 'Details';

  @override
  String get certType_attestato_di_frequenza => 'Teilnahmebescheinigung';

  @override
  String get certType_certificato_di_competenza => 'Kompetenzzertifikat';

  @override
  String get certType_diploma => 'Diplom';

  @override
  String get certType_laurea => 'Abschluss';

  @override
  String get certType_master => 'Master';

  @override
  String get certType_corso_di_formazione => 'Ausbildungskurs';

  @override
  String get certType_certificazione_professionale => 'Berufszertifizierung';

  @override
  String get certType_patente => 'Führerschein';

  @override
  String get certType_abilitazione => 'Berechtigung';

  @override
  String get serialNumber => 'Seriennummer';

  @override
  String get noOtpsYet => 'Noch keine OTPs';

  @override
  String get createYourFirstOtp =>
      'Erstellen Sie Ihr erstes OTP, um zu beginnen';

  @override
  String get secureAccess => 'Sicherer Zugang';

  @override
  String get secureAccessDescription => 'Sichere und temporäre Zugangscodes';

  @override
  String get timeLimited => 'Automatisches Ablaufen für erhöhte Sicherheit';

  @override
  String get timeLimitedDescription =>
      'Codes laufen automatisch ab, um die Sicherheit zu gewährleisten';

  @override
  String get qrCodeSupport => 'QR-Code-Unterstützung';

  @override
  String get qrCodeSupportDescription =>
      'Generieren und teilen Sie QR-Codes für schnellen Zugang';

  @override
  String get otpCode => 'OTP-Code';

  @override
  String get errorOccurred => 'Fehler';

  @override
  String get unknownError => 'Unbekannter Fehler';

  @override
  String get statusBurned => 'Verbrannt';

  @override
  String get statusUsed => 'Verwendet';

  @override
  String get statusExpired => 'Abgelaufen';

  @override
  String get statusValid => 'Gültig';

  @override
  String get databaseConnectionFailed => 'Datenbankverbindung fehlgeschlagen';

  @override
  String get edgeFunctionNotAccessible => 'Edge Function nicht zugänglich';

  @override
  String get preparingLinkedIn => 'LinkedIn wird vorbereitet...';

  @override
  String get name => 'Name';

  @override
  String get issuer => 'Aussteller';

  @override
  String get downloadingMedia => 'Medien werden heruntergeladen...';

  @override
  String get mediaDownloadedSuccessfully =>
      'Medien erfolgreich heruntergeladen';

  @override
  String get errorDownloadingMedia => 'Fehler beim Herunterladen der Medien';

  @override
  String get errorCreatingOpenBadge => 'Fehler beim Erstellen des Open Badge';

  @override
  String get issueDate => 'Ausstellungsdatum';

  @override
  String get yourOpenBadgeCreatedSuccessfully =>
      'Ihr Open Badge wurde erfolgreich erstellt!';

  @override
  String get badge => 'Badge';

  @override
  String get filesSavedTo => 'Dateien gespeichert in';

  @override
  String get connectionTestResults => 'Verbindungstest-Ergebnisse';

  @override
  String get createOtp => 'OTP Erstellen';

  @override
  String get testConnection => 'Verbindung Testen';

  @override
  String get cleanupExpired => 'Abgelaufene Bereinigen';

  @override
  String get refresh => 'Aktualisieren';

  @override
  String get noOtpsAvailable => 'Keine OTPs verfügbar';

  @override
  String get codeCopiedToClipboard => 'Code in die Zwischenablage kopiert!';

  @override
  String get openBadges => 'Open Badges';

  @override
  String get badges => 'badges';

  @override
  String get loadingOpenBadges => 'Loading Open Badges...';

  @override
  String get errorLoadingOpenBadges => 'Error Loading Open Badges';

  @override
  String get noOpenBadgesFound => 'No Open Badges Found';

  @override
  String get noOpenBadgesDescription =>
      'Import your first OpenBadge to get started';

  @override
  String get importOpenBadge => 'Import OpenBadge';

  @override
  String get valid => 'Valid';

  @override
  String get invalid => 'Invalid';

  @override
  String get revoked => 'Revoked';

  @override
  String get source => 'Source (optional)';

  @override
  String get note => 'Note (optional)';

  @override
  String get import => 'Import';

  @override
  String get viewAll => 'View All';

  @override
  String get pendingCertifications => 'Pending Certifications';

  @override
  String get approvedCertifications => 'Approved Certifications';

  @override
  String get rejectedCertifications => 'Rejected Certifications';

  @override
  String get pendingShort => 'Pending';

  @override
  String get approvedShort => 'Approved';

  @override
  String get rejectedShort => 'Rejected';

  @override
  String get approve => 'Approve';

  @override
  String get reject => 'Reject';

  @override
  String get confirmRejection => 'Confirm Rejection';

  @override
  String get rejectCertificationMessage =>
      'Are you sure you want to reject this certification?';

  @override
  String get rejectionReason => 'Rejection reason (optional)';

  @override
  String get enterRejectionReason => 'Enter rejection reason...';

  @override
  String get confirmReject => 'Confirm Reject';

  @override
  String get certificationApproved => 'Certification approved successfully!';

  @override
  String get certificationRejected => 'Certification rejected';

  @override
  String errorApprovingCertification(String error) {
    return 'Error approving certification: $error';
  }

  @override
  String errorRejectingCertification(String error) {
    return 'Error rejecting certification: $error';
  }

  @override
  String get createdOn => 'Created on';

  @override
  String get rejectedReason => 'Rejection reason:';

  @override
  String get noRejectionReason => 'No reason specified';

  @override
  String get blockchainCertificate => 'Blockchain Certificate';

  @override
  String get verifiedOnPolygonNetwork => 'Verified on Polygon Network';

  @override
  String get transactionInformation => 'Transaction Information';

  @override
  String get transactionId => 'Transaction ID';

  @override
  String get network => 'Network';

  @override
  String get blockHeight => 'Block Height';

  @override
  String get gasUsed => 'Gas Used';

  @override
  String get nftInformation => 'NFT Information';

  @override
  String get tokenId => 'Token ID';

  @override
  String get contractAddress => 'Contract Address';

  @override
  String get standard => 'Standard';

  @override
  String get metadataUri => 'Metadata URI';

  @override
  String get mintInformation => 'Mint Information';

  @override
  String get mintDate => 'Mint Date';

  @override
  String get minterAddress => 'Minter Address';

  @override
  String get mintPrice => 'Mint Price';

  @override
  String get certificateStatus => 'Status';

  @override
  String get confirmed => 'Confirmed';

  @override
  String get certificateDetails => 'Certificate Details';

  @override
  String get certificateName => 'Certificate Name';

  @override
  String get blockchainVerified => 'Blockchain Verified';

  @override
  String get blockchainVerificationMessage =>
      'This certificate has been verified and stored on the Polygon blockchain network.';

  @override
  String get viewOnPolygonExplorer => 'View on Polygon Explorer';

  @override
  String get polygon => 'Polygon';

  @override
  String get erc721 => 'ERC-721';

  @override
  String get cvCreationDate => 'CV-Erstellungsdatum';

  @override
  String get monthJan => 'Jan';

  @override
  String get monthFeb => 'Feb';

  @override
  String get monthMar => 'Mär';

  @override
  String get monthApr => 'Apr';

  @override
  String get monthMay => 'Mai';

  @override
  String get monthJun => 'Jun';

  @override
  String get monthJul => 'Jul';

  @override
  String get monthAug => 'Aug';

  @override
  String get monthSep => 'Sep';

  @override
  String get monthOct => 'Okt';

  @override
  String get monthNov => 'Nov';

  @override
  String get monthDec => 'Dez';

  @override
  String get certType_programma_certificato => 'Zertifiziertes Programm';

  @override
  String get certType_dottorato_di_ricerca => 'Doktorat';

  @override
  String get certType_diploma_its => 'ITS Diplom';

  @override
  String get certType_workshop => 'Workshop';

  @override
  String get certType_risultato_sportivo => 'Sportliche Leistung';

  @override
  String get certType_corso_specifico => 'Spezifischer Kurs';

  @override
  String get certType_team_builder => 'Team Builder';

  @override
  String get certType_corso_di_aggiornamento => 'Auffrischungskurs';

  @override
  String get certType_speech => 'Vortrag';

  @override
  String get certType_congresso => 'Kongress';

  @override
  String get certType_corso_specialistico => 'Spezialistenkurs';

  @override
  String get certType_certificazione => 'Zertifizierung';

  @override
  String get certType_moderatore => 'Moderator';

  @override
  String get certType_ruolo_professionale => 'Berufliche Rolle';

  @override
  String get certType_volontariato => 'Freiwilligenarbeit';
}
