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
}
