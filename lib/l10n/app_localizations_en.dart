// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'JetCV';

  @override
  String get personalInformation => 'Personal Information';

  @override
  String get yourProfile => 'Your Profile';

  @override
  String get enterYourPersonalInfo => 'Enter your personal information';

  @override
  String get personalData => 'Personal Data';

  @override
  String get contactInformation => 'Contact Information';

  @override
  String get address => 'Address';

  @override
  String get firstName => 'First Name';

  @override
  String get lastName => 'Last Name';

  @override
  String get gender => 'Gender';

  @override
  String get dateOfBirth => 'Date of Birth (dd/mm/yyyy)';

  @override
  String get email => 'Email';

  @override
  String get phone => 'Phone';

  @override
  String get addressField => 'Address';

  @override
  String get city => 'City';

  @override
  String get state => 'State/Province';

  @override
  String get postalCode => 'Postal Code';

  @override
  String get country => 'Country';

  @override
  String get selectPhoto => 'Select Profile Photo';

  @override
  String get takePhoto => 'Take Photo';

  @override
  String get chooseFromGallery => 'Choose from Gallery';

  @override
  String get cancel => 'Cancel';

  @override
  String get addPhoto => 'Add Photo';

  @override
  String get replacePhoto => 'Replace Photo';

  @override
  String get uploading => 'Uploading...';

  @override
  String get saveInformation => 'Save Information';

  @override
  String get saving => 'Saving...';

  @override
  String get firstNameRequired => 'First name is required';

  @override
  String get lastNameRequired => 'Last name is required';

  @override
  String get genderRequired => 'Gender is required';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get validEmailRequired => 'Enter a valid email';

  @override
  String get phoneRequired => 'Phone is required';

  @override
  String get addressRequired => 'Address is required';

  @override
  String get cityRequired => 'City is required';

  @override
  String get stateRequired => 'State/Province is required';

  @override
  String get postalCodeRequired => 'Postal code is required';

  @override
  String get countryRequired => 'Country is required';

  @override
  String get validDateRequired => 'Enter a valid date of birth';

  @override
  String get dateFormatRequired => 'Format required: dd/mm/yyyy';

  @override
  String get invalidDate => 'Invalid date';

  @override
  String get invalidDay => 'Invalid day (01-31)';

  @override
  String get invalidMonth => 'Invalid month (01-12)';

  @override
  String invalidYear(int currentYear) {
    return 'Invalid year (1900-$currentYear)';
  }

  @override
  String get inexistentDate =>
      'Non-existent date (e.g., 29/02 in non-leap year)';

  @override
  String get searchCountry => 'Search country...';

  @override
  String get selectCountry => 'Select country';

  @override
  String get noCountryFound => 'No country found';

  @override
  String get fileTooLarge => 'File is too large. Maximum 5MB allowed.';

  @override
  String get unsupportedFormat =>
      'Unsupported file format. Use JPG, PNG or WebP.';

  @override
  String imageSelectionError(String error) {
    return 'Error during image selection: $error';
  }

  @override
  String get profilePictureUploaded => 'Profile picture uploaded successfully!';

  @override
  String uploadError(String error) {
    return 'Upload error: $error';
  }

  @override
  String photoUploadError(String error) {
    return 'Error uploading photo: $error. Personal data will still be saved.';
  }

  @override
  String get informationSaved => 'Personal information saved successfully!';

  @override
  String get informationSavedWithPhotoError =>
      'Personal information saved successfully! (Note: profile picture was not uploaded)';

  @override
  String saveError(String error) {
    return 'Save error: $error';
  }

  @override
  String get languageSettings => 'Language Settings';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get languageChanged => 'Language changed successfully';

  @override
  String get language => 'Language';
}
