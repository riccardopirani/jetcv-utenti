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
}
