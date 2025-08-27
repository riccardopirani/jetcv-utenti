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
  String get dateOfBirth => 'Geburtsdatum (dd/mm/yyyy)';

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
}
