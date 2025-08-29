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
  String get dateOfBirth => 'Data di nascita (dd/mm/yyyy)';

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
  String get cvLanguage => 'Lingua CV';

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
  String get verifiedCV => 'CV Verificato';
}
