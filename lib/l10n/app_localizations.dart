import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'JetCV'**
  String get appTitle;

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInformation;

  /// No description provided for @yourProfile.
  ///
  /// In en, this message translates to:
  /// **'Your Profile'**
  String get yourProfile;

  /// No description provided for @enterYourPersonalInfo.
  ///
  /// In en, this message translates to:
  /// **'Enter your personal information'**
  String get enterYourPersonalInfo;

  /// No description provided for @personalData.
  ///
  /// In en, this message translates to:
  /// **'Personal Data'**
  String get personalData;

  /// No description provided for @contactInformation.
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get contactInformation;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth (dd/mm/yyyy)'**
  String get dateOfBirth;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @addressField.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get addressField;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @state.
  ///
  /// In en, this message translates to:
  /// **'State/Province'**
  String get state;

  /// No description provided for @postalCode.
  ///
  /// In en, this message translates to:
  /// **'Postal Code'**
  String get postalCode;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// No description provided for @selectPhoto.
  ///
  /// In en, this message translates to:
  /// **'Select Profile Photo'**
  String get selectPhoto;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @addPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add Photo'**
  String get addPhoto;

  /// No description provided for @replacePhoto.
  ///
  /// In en, this message translates to:
  /// **'Replace Photo'**
  String get replacePhoto;

  /// No description provided for @uploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading...'**
  String get uploading;

  /// No description provided for @saveInformation.
  ///
  /// In en, this message translates to:
  /// **'Save Information'**
  String get saveInformation;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// No description provided for @firstNameRequired.
  ///
  /// In en, this message translates to:
  /// **'First name is required'**
  String get firstNameRequired;

  /// No description provided for @lastNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Last name is required'**
  String get lastNameRequired;

  /// No description provided for @genderRequired.
  ///
  /// In en, this message translates to:
  /// **'Gender is required'**
  String get genderRequired;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @validEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get validEmailRequired;

  /// No description provided for @phoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone is required'**
  String get phoneRequired;

  /// No description provided for @addressRequired.
  ///
  /// In en, this message translates to:
  /// **'Address is required'**
  String get addressRequired;

  /// No description provided for @cityRequired.
  ///
  /// In en, this message translates to:
  /// **'City is required'**
  String get cityRequired;

  /// No description provided for @stateRequired.
  ///
  /// In en, this message translates to:
  /// **'State/Province is required'**
  String get stateRequired;

  /// No description provided for @postalCodeRequired.
  ///
  /// In en, this message translates to:
  /// **'Postal code is required'**
  String get postalCodeRequired;

  /// No description provided for @countryRequired.
  ///
  /// In en, this message translates to:
  /// **'Country is required'**
  String get countryRequired;

  /// No description provided for @validDateRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid date of birth'**
  String get validDateRequired;

  /// No description provided for @dateFormatRequired.
  ///
  /// In en, this message translates to:
  /// **'Format required: dd/mm/yyyy'**
  String get dateFormatRequired;

  /// No description provided for @invalidDate.
  ///
  /// In en, this message translates to:
  /// **'Invalid date'**
  String get invalidDate;

  /// No description provided for @invalidDay.
  ///
  /// In en, this message translates to:
  /// **'Invalid day (01-31)'**
  String get invalidDay;

  /// No description provided for @invalidMonth.
  ///
  /// In en, this message translates to:
  /// **'Invalid month (01-12)'**
  String get invalidMonth;

  /// No description provided for @invalidYear.
  ///
  /// In en, this message translates to:
  /// **'Invalid year (1900-{currentYear})'**
  String invalidYear(int currentYear);

  /// No description provided for @inexistentDate.
  ///
  /// In en, this message translates to:
  /// **'Non-existent date (e.g., 29/02 in non-leap year)'**
  String get inexistentDate;

  /// No description provided for @searchCountry.
  ///
  /// In en, this message translates to:
  /// **'Search country...'**
  String get searchCountry;

  /// No description provided for @selectCountry.
  ///
  /// In en, this message translates to:
  /// **'Select country'**
  String get selectCountry;

  /// No description provided for @noCountryFound.
  ///
  /// In en, this message translates to:
  /// **'No country found'**
  String get noCountryFound;

  /// No description provided for @fileTooLarge.
  ///
  /// In en, this message translates to:
  /// **'File is too large. Maximum 5MB allowed.'**
  String get fileTooLarge;

  /// No description provided for @unsupportedFormat.
  ///
  /// In en, this message translates to:
  /// **'Unsupported file format. Use JPG, PNG or WebP.'**
  String get unsupportedFormat;

  /// No description provided for @imageSelectionError.
  ///
  /// In en, this message translates to:
  /// **'Error during image selection: {error}'**
  String imageSelectionError(String error);

  /// No description provided for @profilePictureUploaded.
  ///
  /// In en, this message translates to:
  /// **'Profile picture uploaded successfully!'**
  String get profilePictureUploaded;

  /// No description provided for @uploadError.
  ///
  /// In en, this message translates to:
  /// **'Upload error: {error}'**
  String uploadError(String error);

  /// No description provided for @photoUploadError.
  ///
  /// In en, this message translates to:
  /// **'Error uploading photo: {error}. Personal data will still be saved.'**
  String photoUploadError(String error);

  /// No description provided for @informationSaved.
  ///
  /// In en, this message translates to:
  /// **'Personal information saved successfully!'**
  String get informationSaved;

  /// No description provided for @informationSavedWithPhotoError.
  ///
  /// In en, this message translates to:
  /// **'Personal information saved successfully! (Note: profile picture was not uploaded)'**
  String get informationSavedWithPhotoError;

  /// No description provided for @saveError.
  ///
  /// In en, this message translates to:
  /// **'Save error: {error}'**
  String saveError(String error);

  /// No description provided for @languageSettings.
  ///
  /// In en, this message translates to:
  /// **'Language Settings'**
  String get languageSettings;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @languageChanged.
  ///
  /// In en, this message translates to:
  /// **'Language changed successfully'**
  String get languageChanged;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @cv.
  ///
  /// In en, this message translates to:
  /// **'CV'**
  String get cv;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome,'**
  String get welcome;

  /// No description provided for @verifiedOnBlockchain.
  ///
  /// In en, this message translates to:
  /// **'Account verified on blockchain'**
  String get verifiedOnBlockchain;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @newCV.
  ///
  /// In en, this message translates to:
  /// **'New CV'**
  String get newCV;

  /// No description provided for @createYourDigitalCV.
  ///
  /// In en, this message translates to:
  /// **'Create your digital CV'**
  String get createYourDigitalCV;

  /// No description provided for @viewCV.
  ///
  /// In en, this message translates to:
  /// **'View CV'**
  String get viewCV;

  /// No description provided for @yourDigitalCV.
  ///
  /// In en, this message translates to:
  /// **'Your digital CV'**
  String get yourDigitalCV;

  /// No description provided for @cvViewInDevelopment.
  ///
  /// In en, this message translates to:
  /// **'CV View - In development'**
  String get cvViewInDevelopment;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @loginError.
  ///
  /// In en, this message translates to:
  /// **'Login error: {error}'**
  String loginError(String error);

  /// No description provided for @googleAuthError.
  ///
  /// In en, this message translates to:
  /// **'Google authentication error: {error}'**
  String googleAuthError(String error);

  /// No description provided for @signInToAccount.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your account'**
  String get signInToAccount;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterEmail;

  /// No description provided for @enterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get enterValidEmail;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterPassword;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get noAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @mustAcceptTerms.
  ///
  /// In en, this message translates to:
  /// **'You must accept the terms and conditions'**
  String get mustAcceptTerms;

  /// No description provided for @confirmEmail.
  ///
  /// In en, this message translates to:
  /// **'Confirm email'**
  String get confirmEmail;

  /// No description provided for @emailConfirmationSent.
  ///
  /// In en, this message translates to:
  /// **'We sent you a confirmation email. Click the link in the email to activate your account.'**
  String get emailConfirmationSent;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @registrationCompleted.
  ///
  /// In en, this message translates to:
  /// **'Registration completed'**
  String get registrationCompleted;

  /// No description provided for @accountCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully! You can start using JetCV.'**
  String get accountCreatedSuccess;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get createAccount;

  /// No description provided for @startJourney.
  ///
  /// In en, this message translates to:
  /// **'Start your journey with JetCV'**
  String get startJourney;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @enterFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get enterFullName;

  /// No description provided for @nameMinLength.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 2 characters'**
  String get nameMinLength;

  /// No description provided for @createSecurePassword.
  ///
  /// In en, this message translates to:
  /// **'Create a secure password'**
  String get createSecurePassword;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinLength;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @confirmYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm your password'**
  String get confirmYourPassword;

  /// No description provided for @passwordsDontMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords don\'t match'**
  String get passwordsDontMatch;

  /// No description provided for @acceptTerms.
  ///
  /// In en, this message translates to:
  /// **'I accept the '**
  String get acceptTerms;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions'**
  String get termsAndConditions;

  /// No description provided for @and.
  ///
  /// In en, this message translates to:
  /// **' and the '**
  String get and;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @haveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get haveAccount;

  /// No description provided for @errorLabel.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorLabel(String error);

  /// No description provided for @emailSent.
  ///
  /// In en, this message translates to:
  /// **'Email sent!'**
  String get emailSent;

  /// No description provided for @passwordForgotten.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get passwordForgotten;

  /// No description provided for @resetInstructionsSent.
  ///
  /// In en, this message translates to:
  /// **'We sent password reset instructions to your email'**
  String get resetInstructionsSent;

  /// No description provided for @dontWorryReset.
  ///
  /// In en, this message translates to:
  /// **'Don\'t worry! Enter your email and we\'ll send you a password reset link'**
  String get dontWorryReset;

  /// No description provided for @sendResetEmail.
  ///
  /// In en, this message translates to:
  /// **'Send reset email'**
  String get sendResetEmail;

  /// No description provided for @checkEmailInstructions.
  ///
  /// In en, this message translates to:
  /// **'Check your email and click the link to reset your password. If you don\'t see the email, also check your spam folder.'**
  String get checkEmailInstructions;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get backToLogin;

  /// No description provided for @rememberPassword.
  ///
  /// In en, this message translates to:
  /// **'Remember your password? '**
  String get rememberPassword;

  /// No description provided for @saveErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Save error'**
  String get saveErrorGeneric;

  /// No description provided for @blockchainPowered.
  ///
  /// In en, this message translates to:
  /// **'Blockchain Powered'**
  String get blockchainPowered;

  /// No description provided for @digitalCVTitle.
  ///
  /// In en, this message translates to:
  /// **'Your digital CV\nverified on blockchain'**
  String get digitalCVTitle;

  /// No description provided for @digitalCVDescription.
  ///
  /// In en, this message translates to:
  /// **'Create, manage and share your curriculum vitae with the security and authenticity guaranteed by blockchain technology.'**
  String get digitalCVDescription;

  /// No description provided for @mainFeatures.
  ///
  /// In en, this message translates to:
  /// **'Main Features'**
  String get mainFeatures;

  /// No description provided for @blockchainVerification.
  ///
  /// In en, this message translates to:
  /// **'Blockchain Verification'**
  String get blockchainVerification;

  /// No description provided for @blockchainVerificationDesc.
  ///
  /// In en, this message translates to:
  /// **'Your data is immutable and verifiable on the blockchain'**
  String get blockchainVerificationDesc;

  /// No description provided for @secureSharing.
  ///
  /// In en, this message translates to:
  /// **'Secure Sharing'**
  String get secureSharing;

  /// No description provided for @secureSharingDesc.
  ///
  /// In en, this message translates to:
  /// **'Share your CV with a secure and traceable link'**
  String get secureSharingDesc;

  /// No description provided for @realTimeUpdates.
  ///
  /// In en, this message translates to:
  /// **'Real-Time Updates'**
  String get realTimeUpdates;

  /// No description provided for @realTimeUpdatesDesc.
  ///
  /// In en, this message translates to:
  /// **'Edit and update your CV at any time'**
  String get realTimeUpdatesDesc;

  /// No description provided for @jetcvInNumbers.
  ///
  /// In en, this message translates to:
  /// **'JetCV in numbers'**
  String get jetcvInNumbers;

  /// No description provided for @cvsCreated.
  ///
  /// In en, this message translates to:
  /// **'CVs Created'**
  String get cvsCreated;

  /// No description provided for @activeUsers.
  ///
  /// In en, this message translates to:
  /// **'Active Users'**
  String get activeUsers;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @readyToStart.
  ///
  /// In en, this message translates to:
  /// **'Ready to get started?'**
  String get readyToStart;

  /// No description provided for @createFirstCV.
  ///
  /// In en, this message translates to:
  /// **'Create your first digital CV on blockchain in just a few minutes'**
  String get createFirstCV;

  /// No description provided for @createYourCV.
  ///
  /// In en, this message translates to:
  /// **'Create your CV'**
  String get createYourCV;

  /// No description provided for @signInToYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your account'**
  String get signInToYourAccount;

  /// No description provided for @shareCV.
  ///
  /// In en, this message translates to:
  /// **'Share CV'**
  String get shareCV;

  /// No description provided for @shareText.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get shareText;

  /// No description provided for @cvLanguage.
  ///
  /// In en, this message translates to:
  /// **'CV Language'**
  String get cvLanguage;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInfo;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'age'**
  String get age;

  /// No description provided for @contactInfo.
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get contactInfo;

  /// No description provided for @languages.
  ///
  /// In en, this message translates to:
  /// **'Languages'**
  String get languages;

  /// No description provided for @skills.
  ///
  /// In en, this message translates to:
  /// **'Skills'**
  String get skills;

  /// No description provided for @attitudes.
  ///
  /// In en, this message translates to:
  /// **'Attitudes'**
  String get attitudes;

  /// No description provided for @languagesPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Your language skills will be displayed here'**
  String get languagesPlaceholder;

  /// No description provided for @attitudesPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Your attitudes and soft skills will be displayed here'**
  String get attitudesPlaceholder;

  /// No description provided for @cvShared.
  ///
  /// In en, this message translates to:
  /// **'CV link copied to clipboard!'**
  String get cvShared;

  /// No description provided for @shareError.
  ///
  /// In en, this message translates to:
  /// **'Error sharing: {error}'**
  String shareError(Object error);

  /// No description provided for @years.
  ///
  /// In en, this message translates to:
  /// **'years'**
  String get years;

  /// No description provided for @born.
  ///
  /// In en, this message translates to:
  /// **'born'**
  String get born;

  /// No description provided for @bornFemale.
  ///
  /// In en, this message translates to:
  /// **'born'**
  String get bornFemale;

  /// No description provided for @blockchainCertified.
  ///
  /// In en, this message translates to:
  /// **'Blockchain Certified'**
  String get blockchainCertified;

  /// No description provided for @cvSerial.
  ///
  /// In en, this message translates to:
  /// **'CV Serial'**
  String get cvSerial;

  /// No description provided for @verifiedCV.
  ///
  /// In en, this message translates to:
  /// **'Verified CV'**
  String get verifiedCV;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'es', 'fr', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
