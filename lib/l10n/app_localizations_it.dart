// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'JetCV';

  @override
  String get personalInformation => 'Informazioni Personali';

  @override
  String get yourProfile => 'Il tuo profilo';

  @override
  String get enterYourPersonalInfo => 'Inserisci le tue informazioni personali';

  @override
  String get personalData => 'Informazioni anagrafiche';

  @override
  String get contactInformation => 'Informazioni di contatto';

  @override
  String get address => 'Indirizzo';

  @override
  String get firstName => 'Nome';

  @override
  String get lastName => 'Cognome';

  @override
  String get gender => 'Genere';

  @override
  String get dateOfBirth => 'Data di nascita';

  @override
  String get email => 'Email';

  @override
  String get phone => 'Telefono';

  @override
  String get addressField => 'Indirizzo';

  @override
  String get city => 'Città';

  @override
  String get state => 'Provincia';

  @override
  String get postalCode => 'Codice Postale';

  @override
  String get country => 'Paese';

  @override
  String get selectPhoto => 'Seleziona foto profilo';

  @override
  String get takePhoto => 'Scatta foto';

  @override
  String get chooseFromGallery => 'Scegli dalla galleria';

  @override
  String get cancel => 'Annulla';

  @override
  String get addPhoto => 'Aggiungi foto';

  @override
  String get replacePhoto => 'Sostituisci foto';

  @override
  String get uploading => 'Caricamento...';

  @override
  String get saveInformation => 'Salva informazioni';

  @override
  String get saving => 'Salvando...';

  @override
  String get firstNameRequired => 'Il nome è obbligatorio';

  @override
  String get lastNameRequired => 'Il cognome è obbligatorio';

  @override
  String get genderRequired => 'Il genere è obbligatorio';

  @override
  String get emailRequired => 'L\'email è obbligatoria';

  @override
  String get validEmailRequired => 'Inserisci un\'email valida';

  @override
  String get phoneRequired => 'Il telefono è obbligatorio';

  @override
  String get addressRequired => 'L\'indirizzo è obbligatorio';

  @override
  String get cityRequired => 'La città è obbligatoria';

  @override
  String get stateRequired => 'La provincia è obbligatoria';

  @override
  String get postalCodeRequired => 'Il CAP è obbligatorio';

  @override
  String get countryRequired => 'Il paese è obbligatorio';

  @override
  String get validDateRequired => 'Inserisci una data di nascita valida';

  @override
  String get dateFormatRequired => 'Formato richiesto: dd/mm/yyyy';

  @override
  String get invalidDate => 'Data non valida';

  @override
  String get invalidDay => 'Giorno non valido (01-31)';

  @override
  String get invalidMonth => 'Mese non valido (01-12)';

  @override
  String invalidYear(int currentYear) {
    return 'Anno non valido (1900-$currentYear)';
  }

  @override
  String get inexistentDate =>
      'Data inesistente (es. 29/02 in anno non bisestile)';

  @override
  String get searchCountry => 'Cerca paese...';

  @override
  String get selectCountry => 'Seleziona paese';

  @override
  String get noCountryFound => 'Nessun paese trovato';

  @override
  String get fileTooLarge => 'Il file è troppo grande. Massimo 5MB consentiti.';

  @override
  String get unsupportedFormat =>
      'Formato file non supportato. Usa JPG, PNG o WebP.';

  @override
  String imageSelectionError(String error) {
    return 'Errore durante la selezione dell\'immagine: $error';
  }

  @override
  String get profilePictureUploaded => 'Foto profilo caricata con successo!';

  @override
  String uploadError(String error) {
    return 'Errore durante il caricamento: $error';
  }

  @override
  String photoUploadError(String error) {
    return 'Errore durante il caricamento della foto: $error. I dati personali verranno comunque salvati.';
  }

  @override
  String get informationSaved => 'Informazioni personali salvate con successo!';

  @override
  String get informationSavedWithPhotoError =>
      'Informazioni personali salvate con successo! (Nota: la foto profilo non è stata caricata)';

  @override
  String saveError(String error) {
    return 'Errore nel salvataggio: $error';
  }

  @override
  String get languageSettings => 'Impostazioni Lingua';

  @override
  String get selectLanguage => 'Seleziona Lingua';

  @override
  String get languageChanged => 'Lingua cambiata con successo';

  @override
  String get language => 'Lingua';

  @override
  String get home => 'Home';

  @override
  String get cv => 'CV';

  @override
  String get profile => 'Profilo';

  @override
  String get welcome => 'Benvenuto,';

  @override
  String get verifiedOnBlockchain => 'Account verificato su blockchain';

  @override
  String get quickActions => 'Azioni rapide';

  @override
  String get newCV => 'Nuovo CV';

  @override
  String get createYourDigitalCV => 'Crea il tuo CV digitale';

  @override
  String get viewCV => 'Visualizza CV';

  @override
  String get yourDigitalCV => 'Il tuo CV digitale';

  @override
  String get cvViewInDevelopment => 'Visualizzazione CV - In sviluppo';

  @override
  String get user => 'Utente';

  @override
  String loginError(String error) {
    return 'Errore durante il login: $error';
  }

  @override
  String googleAuthError(String error) {
    return 'Errore durante l\'autenticazione con Google: $error';
  }

  @override
  String get signInToAccount => 'Accedi al tuo account';

  @override
  String get enterEmail => 'Inserisci la tua email';

  @override
  String get enterValidEmail => 'Inserisci una email valida';

  @override
  String get password => 'Password';

  @override
  String get enterPassword => 'Inserisci la tua password';

  @override
  String get forgotPassword => 'Password dimenticata?';

  @override
  String get signIn => 'Accedi';

  @override
  String get or => 'oppure';

  @override
  String get continueWithGoogle => 'Continua con Google';

  @override
  String get noAccount => 'Non hai un account? ';

  @override
  String get signUp => 'Registrati';

  @override
  String get mustAcceptTerms => 'Devi accettare i termini e condizioni';

  @override
  String get confirmEmail => 'Conferma email';

  @override
  String get emailConfirmationSent =>
      'Ti abbiamo inviato un\'email di conferma. Clicca sul link nell\'email per attivare il tuo account.';

  @override
  String get ok => 'OK';

  @override
  String get registrationCompleted => 'Registrazione completata';

  @override
  String get accountCreatedSuccess =>
      'Account creato con successo! Puoi iniziare a usare JetCV.';

  @override
  String get start => 'Inizia';

  @override
  String get createAccount => 'Crea il tuo account';

  @override
  String get startJourney => 'Inizia il tuo viaggio con JetCV';

  @override
  String get fullName => 'Nome completo';

  @override
  String get enterFullName => 'Inserisci il tuo nome completo';

  @override
  String get nameMinLength => 'Il nome deve avere almeno 2 caratteri';

  @override
  String get viewMyCV => 'Visualizza il mio CV';

  @override
  String get copyLink => 'Copia Link';

  @override
  String get share => 'Condividi';

  @override
  String get createSecurePassword => 'Crea una password sicura';

  @override
  String get passwordMinLength => 'La password deve avere almeno 6 caratteri';

  @override
  String get confirmPassword => 'Conferma password';

  @override
  String get confirmYourPassword => 'Conferma la tua password';

  @override
  String get passwordsDontMatch => 'Le password non coincidono';

  @override
  String get acceptTerms => 'Accetto i ';

  @override
  String get termsAndConditions => 'Termini e Condizioni';

  @override
  String get and => ' e la ';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get haveAccount => 'Hai già un account? ';

  @override
  String errorLabel(String error) {
    return 'Errore: $error';
  }

  @override
  String get emailSent => 'Email inviata!';

  @override
  String get passwordForgotten => 'Password dimenticata?';

  @override
  String get resetInstructionsSent =>
      'Abbiamo inviato le istruzioni per resettare la password alla tua email';

  @override
  String get dontWorryReset =>
      'Non preoccuparti! Inserisci la tua email e ti invieremo un link per resettare la password';

  @override
  String get sendResetEmail => 'Invia email di reset';

  @override
  String get checkEmailInstructions =>
      'Controlla la tua casella email e clicca sul link per resettare la password. Se non vedi l\'email, controlla anche la cartella spam.';

  @override
  String get backToLogin => 'Torna al Login';

  @override
  String get rememberPassword => 'Ricordi la password? ';

  @override
  String get saveErrorGeneric => 'Errore durante il salvataggio';

  @override
  String get blockchainPowered => 'Blockchain Powered';

  @override
  String get digitalCVTitle => 'Il tuo CV digitale\nverificato su blockchain';

  @override
  String get digitalCVDescription =>
      'Crea, gestisci e condividi il tuo curriculum vitae con la sicurezza e l\'autenticità garantite dalla tecnologia blockchain.';

  @override
  String get mainFeatures => 'Funzionalità principali';

  @override
  String get blockchainVerification => 'Verifica Blockchain';

  @override
  String get blockchainVerificationDesc =>
      'I tuoi dati sono immutabili e verificabili sulla blockchain';

  @override
  String get secureSharing => 'Condivisione Sicura';

  @override
  String get secureSharingDesc =>
      'Condividi il tuo CV con un link sicuro e tracciabile';

  @override
  String get realTimeUpdates => 'Aggiornamenti in Tempo Reale';

  @override
  String get realTimeUpdatesDesc =>
      'Modifica e aggiorna il tuo CV in qualsiasi momento';

  @override
  String get jetcvInNumbers => 'JetCV in numeri';

  @override
  String get cvsCreated => 'CV Creati';

  @override
  String get activeUsers => 'Utenti Attivi';

  @override
  String get security => 'Sicurezza';

  @override
  String get readyToStart => 'Pronto a iniziare?';

  @override
  String get createFirstCV =>
      'Crea il tuo primo CV digitale su blockchain in pochi minuti';

  @override
  String get createYourCV => 'Crea il tuo CV';

  @override
  String get signInToYourAccount => 'Accedi al tuo account';

  @override
  String get shareCV => 'Condividi CV';

  @override
  String get shareText => 'Condividi';

  @override
  String get cvLanguage => 'Lingua visualizzazione CV';

  @override
  String get personalInfo => 'Informazioni Personali';

  @override
  String get age => 'età';

  @override
  String get contactInfo => 'Informazioni di Contatto';

  @override
  String get languages => 'Lingue';

  @override
  String get skills => 'Competenze';

  @override
  String get attitudes => 'Attitudini';

  @override
  String get languagesPlaceholder =>
      'Le tue competenze linguistiche verranno mostrate qui';

  @override
  String get attitudesPlaceholder =>
      'Le tue attitudini e soft skills verranno mostrate qui';

  @override
  String get cvShared => 'Link CV copiato negli appunti!';

  @override
  String shareError(Object error) {
    return 'Errore durante la condivisione: $error';
  }

  @override
  String get years => 'anni';

  @override
  String get born => 'nato';

  @override
  String get bornFemale => 'nata';

  @override
  String get blockchainCertified => 'Certificato Blockchain';

  @override
  String get cvSerial => 'Seriale CV';

  @override
  String get serialCode => 'Codice seriale';

  @override
  String get verifiedCV => 'CV Verificato';

  @override
  String get autodichiarazioni => 'Autodichiarazioni';

  @override
  String get spokenLanguages => 'Lingue parlate:';

  @override
  String get noLanguageSpecified => 'Nessuna lingua specificata';

  @override
  String get certifications => 'Certificazioni';

  @override
  String get mostRecent => 'Più Recenti';

  @override
  String get verifiedCertifications => 'certificazioni verificate';

  @override
  String get loadingCertifications => 'Caricamento certificazioni...';

  @override
  String get errorLoadingCertifications =>
      'Errore nel caricamento delle certificazioni';

  @override
  String get retry => 'Riprova';

  @override
  String get noCertificationsFound => 'Nessuna certificazione trovata';

  @override
  String get yourVerifiedCertifications =>
      'Le tue certificazioni verificate appariranno qui';

  @override
  String get certification => 'Certificazione';

  @override
  String get certifyingBody => 'Ente Certificatore';

  @override
  String get status => 'Stato';

  @override
  String get serial => 'Serial';

  @override
  String get verifiedAndAuthenticated =>
      'Certificazione verificata e autenticata';

  @override
  String get approved => 'Approvata';

  @override
  String get verified => 'Verificata';

  @override
  String get completed => 'Completata';

  @override
  String get pending => 'In Attesa';

  @override
  String get inProgress => 'In Corso';

  @override
  String get rejected => 'Rifiutata';

  @override
  String get failed => 'Fallita';

  @override
  String get nationality => 'Nazionalità';

  @override
  String get noNationalitySpecified => 'Nessuna nazionalità specificata';

  @override
  String get cvLinkCopied =>
      'Link del CV copiato negli appunti! Condividilo ora.';

  @override
  String errorChangingLanguage(String error) {
    return 'Errore nel cambiare lingua: $error';
  }

  @override
  String get projectManagement => 'GESTIONE\nPROGETTI';

  @override
  String get flutterDevelopment => 'SVILUPPO\nFLUTTER';

  @override
  String get certified => 'CERTIFICATO';

  @override
  String get myProfile => 'Il mio profilo';

  @override
  String get myCV => 'Il mio Curriculum';

  @override
  String get myCertifications => 'Le mie certificazioni';

  @override
  String get otp => 'OTP';

  @override
  String get myWallets => 'I miei Wallet';

  @override
  String get deleteAccount => 'Elimina account';

  @override
  String get logout => 'Esci';

  @override
  String get otpVerification => 'Verifica OTP';

  @override
  String get otpDescription =>
      'Inserisci il codice a 6 cifre inviato alla tua email registrata';

  @override
  String get enterOTP => 'Inserisci il codice OTP';

  @override
  String get verifyOTP => 'Verifica OTP';

  @override
  String get resendOTP => 'Invia di nuovo OTP';

  @override
  String get otpVerified => 'OTP verificato con successo!';

  @override
  String get invalidOTP => 'Codice OTP non valido. Riprova.';

  @override
  String get otpVerificationError => 'Errore nella verifica OTP. Riprova.';

  @override
  String get otpResent => 'Il codice OTP è stato reinviato alla tua email';

  @override
  String get otpResendError => 'Errore nell\'invio dell\'OTP. Riprova.';

  @override
  String get securityInfo => 'Informazioni di sicurezza';

  @override
  String get otpSecurityNote =>
      'Per la tua sicurezza, questo codice OTP scadrà tra 10 minuti. Non condividere questo codice con nessuno.';

  @override
  String get myOtps => 'I Miei OTP';

  @override
  String get permanentOtpCodes => 'Codici OTP Permanenti';

  @override
  String get manageSecureAccessCodes =>
      'Gestisci i tuoi codici di accesso sicuri';

  @override
  String get activeOtps => 'OTP Attivi';

  @override
  String get noOtpGenerated => 'Nessun OTP Generato';

  @override
  String get createFirstOtpDescription =>
      'Crea il tuo primo codice OTP permanente per accedere in modo sicuro alla piattaforma.';

  @override
  String get generateFirstOtp => 'Genera Primo OTP';

  @override
  String get newOtp => 'Nuovo OTP';

  @override
  String get addOptionalTagDescription =>
      'Aggiungi un tag opzionale per identificare questo OTP:';

  @override
  String get tagOptional => 'Tag (opzionale)';

  @override
  String get generateOtp => 'Genera OTP';

  @override
  String get createdNow => 'Creato ora';

  @override
  String createdMinutesAgo(int minutes) {
    return 'Creato ${minutes}min fa';
  }

  @override
  String createdHoursAgo(int hours) {
    return 'Creato ${hours}h fa';
  }

  @override
  String createdDaysAgo(int days) {
    return 'Creato $days giorni fa';
  }

  @override
  String get copy => 'Copia';

  @override
  String get qrCode => 'QR Code';

  @override
  String get deleteOtp => 'Elimina OTP';

  @override
  String get deleteOtpConfirmation =>
      'Sei sicuro di voler eliminare questo OTP?';

  @override
  String get delete => 'Elimina';

  @override
  String get otpCodeCopied => 'Codice OTP copiato negli appunti!';

  @override
  String get qrCodeOtp => 'QR Code OTP';

  @override
  String get qrCodeFor => 'QR Code per';

  @override
  String get close => 'Chiudi';

  @override
  String errorDuringLogout(String error) {
    return 'Errore durante il logout: $error';
  }

  @override
  String get accountDeletionNotImplemented =>
      'Eliminazione account non ancora implementata';

  @override
  String get userNotLoaded => 'Utente non caricato';

  @override
  String get trainingCourse => 'Corso Training';

  @override
  String otpNumber(int number) {
    return 'OTP #$number';
  }

  @override
  String get certifier => 'Certificatore';

  @override
  String get attachedMedia => 'Media Allegati';

  @override
  String attachedMediaCount(int count) {
    return 'Media Allegati ($count)';
  }

  @override
  String get documentationAndRelatedContent =>
      'Documentazione e contenuti correlati';

  @override
  String get mediaDividedInfo =>
      'I media sono suddivisi tra contenuti generici della certificazione e documenti specifici del tuo percorso.';

  @override
  String get genericMedia => 'Media Generici';

  @override
  String get didacticMaterialAndOfficialDocumentation =>
      'Materiale didattico e documentazione ufficiale';

  @override
  String get personalMedia => 'Media Personali';

  @override
  String get documentsAndContentOfYourCertificationPath =>
      'Documenti e contenuti del tuo percorso di certificazione';

  @override
  String get realTime => 'REAL-TIME';

  @override
  String get uploaded => 'CARICATO';

  @override
  String get view => 'Visualizza';

  @override
  String get download => 'Scarica';

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
  String get addToLinkedIn => 'Aggiungi a LinkedIn';

  @override
  String get addCertificationsToLinkedIn =>
      'Aggiungi Certificazione a LinkedIn';

  @override
  String get linkedInIntegration => 'Integrazione Certificazioni LinkedIn';

  @override
  String get shareCertificationsOnLinkedIn =>
      'Questo copierà i dettagli della certificazione negli appunti e aprirà LinkedIn. Poi vai al tuo profilo → Aggiungi sezione profilo → Licenze e certificazioni e incolla i dettagli.';

  @override
  String get realTimeMediaNotDownloadable =>
      'I media in tempo reale non possono essere scaricati';

  @override
  String get mediaNotAvailable =>
      'Il file media non è disponibile per il download';
}
