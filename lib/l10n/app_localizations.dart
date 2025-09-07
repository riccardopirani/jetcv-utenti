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

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoon;

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
  /// **'Date of Birth'**
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

  /// No description provided for @viewMyCV.
  ///
  /// In en, this message translates to:
  /// **'View My CV'**
  String get viewMyCV;

  /// No description provided for @copyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy Link'**
  String get copyLink;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

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
  /// **'CV Display Language'**
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

  /// No description provided for @serialCode.
  ///
  /// In en, this message translates to:
  /// **'Serial Code'**
  String get serialCode;

  /// No description provided for @verifiedCV.
  ///
  /// In en, this message translates to:
  /// **'Verified CV'**
  String get verifiedCV;

  /// No description provided for @autodichiarazioni.
  ///
  /// In en, this message translates to:
  /// **'Self-Declarations'**
  String get autodichiarazioni;

  /// No description provided for @spokenLanguages.
  ///
  /// In en, this message translates to:
  /// **'Spoken languages:'**
  String get spokenLanguages;

  /// No description provided for @noLanguageSpecified.
  ///
  /// In en, this message translates to:
  /// **'No language specified'**
  String get noLanguageSpecified;

  /// No description provided for @certifications.
  ///
  /// In en, this message translates to:
  /// **'Certifications'**
  String get certifications;

  /// No description provided for @mostRecent.
  ///
  /// In en, this message translates to:
  /// **'Most Recent'**
  String get mostRecent;

  /// No description provided for @lessRecent.
  ///
  /// In en, this message translates to:
  /// **'Less Recent'**
  String get lessRecent;

  /// No description provided for @verifiedCertifications.
  ///
  /// In en, this message translates to:
  /// **'verified certifications'**
  String get verifiedCertifications;

  /// No description provided for @loadingCertifications.
  ///
  /// In en, this message translates to:
  /// **'Loading certifications...'**
  String get loadingCertifications;

  /// No description provided for @errorLoadingCertifications.
  ///
  /// In en, this message translates to:
  /// **'Error loading certifications'**
  String get errorLoadingCertifications;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @noCertificationsFound.
  ///
  /// In en, this message translates to:
  /// **'No certifications found'**
  String get noCertificationsFound;

  /// No description provided for @yourVerifiedCertifications.
  ///
  /// In en, this message translates to:
  /// **'Your verified certifications will appear here'**
  String get yourVerifiedCertifications;

  /// No description provided for @certification.
  ///
  /// In en, this message translates to:
  /// **'Certification'**
  String get certification;

  /// No description provided for @certifyingBody.
  ///
  /// In en, this message translates to:
  /// **'Certifying Body'**
  String get certifyingBody;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @serial.
  ///
  /// In en, this message translates to:
  /// **'Serial'**
  String get serial;

  /// No description provided for @verifiedAndAuthenticated.
  ///
  /// In en, this message translates to:
  /// **'Verified and authenticated certification'**
  String get verifiedAndAuthenticated;

  /// No description provided for @approved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get approved;

  /// No description provided for @verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get inProgress;

  /// No description provided for @rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// No description provided for @failed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get failed;

  /// No description provided for @nationality.
  ///
  /// In en, this message translates to:
  /// **'Nationality'**
  String get nationality;

  /// No description provided for @noNationalitySpecified.
  ///
  /// In en, this message translates to:
  /// **'No nationality specified'**
  String get noNationalitySpecified;

  /// No description provided for @cvLinkCopied.
  ///
  /// In en, this message translates to:
  /// **'CV link copied to clipboard! Share it now.'**
  String get cvLinkCopied;

  /// No description provided for @errorChangingLanguage.
  ///
  /// In en, this message translates to:
  /// **'Error changing language: {error}'**
  String errorChangingLanguage(String error);

  /// No description provided for @projectManagement.
  ///
  /// In en, this message translates to:
  /// **'PROJECT\nMANAGEMENT'**
  String get projectManagement;

  /// No description provided for @flutterDevelopment.
  ///
  /// In en, this message translates to:
  /// **'FLUTTER\nDEVELOPMENT'**
  String get flutterDevelopment;

  /// No description provided for @certified.
  ///
  /// In en, this message translates to:
  /// **'CERTIFIED'**
  String get certified;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @myCV.
  ///
  /// In en, this message translates to:
  /// **'My CV'**
  String get myCV;

  /// No description provided for @myCertifications.
  ///
  /// In en, this message translates to:
  /// **'My Certifications'**
  String get myCertifications;

  /// No description provided for @otp.
  ///
  /// In en, this message translates to:
  /// **'OTP'**
  String get otp;

  /// No description provided for @myWallets.
  ///
  /// In en, this message translates to:
  /// **'My Wallets'**
  String get myWallets;

  /// No description provided for @viewYourDigitalWallets.
  ///
  /// In en, this message translates to:
  /// **'View your digital wallets'**
  String get viewYourDigitalWallets;

  /// No description provided for @wallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get wallet;

  /// No description provided for @walletDescription.
  ///
  /// In en, this message translates to:
  /// **'Your CV is saved in this wallet on the blockchain to always guarantee its authenticity'**
  String get walletDescription;

  /// No description provided for @owner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get owner;

  /// No description provided for @walletAddress.
  ///
  /// In en, this message translates to:
  /// **'Wallet Address'**
  String get walletAddress;

  /// No description provided for @copyAddress.
  ///
  /// In en, this message translates to:
  /// **'Copy address'**
  String get copyAddress;

  /// No description provided for @addressCopied.
  ///
  /// In en, this message translates to:
  /// **'Address copied to clipboard'**
  String get addressCopied;

  /// No description provided for @noWalletFound.
  ///
  /// In en, this message translates to:
  /// **'No wallet found'**
  String get noWalletFound;

  /// No description provided for @walletNotFoundDescription.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have a wallet associated with your account yet'**
  String get walletNotFoundDescription;

  /// No description provided for @blockedByLegalEntity.
  ///
  /// In en, this message translates to:
  /// **'Blocked by'**
  String get blockedByLegalEntity;

  /// No description provided for @legalEntity.
  ///
  /// In en, this message translates to:
  /// **'Legal Entity'**
  String get legalEntity;

  /// No description provided for @company.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get company;

  /// No description provided for @vatNumber.
  ///
  /// In en, this message translates to:
  /// **'VAT Number'**
  String get vatNumber;

  /// No description provided for @website.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get website;

  /// No description provided for @loadingLegalEntity.
  ///
  /// In en, this message translates to:
  /// **'Loading company data...'**
  String get loadingLegalEntity;

  /// No description provided for @legalEntityError.
  ///
  /// In en, this message translates to:
  /// **'Error loading company data'**
  String get legalEntityError;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @otpVerification.
  ///
  /// In en, this message translates to:
  /// **'OTP Verification'**
  String get otpVerification;

  /// No description provided for @otpDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code sent to your registered email'**
  String get otpDescription;

  /// No description provided for @enterOTP.
  ///
  /// In en, this message translates to:
  /// **'Enter OTP Code'**
  String get enterOTP;

  /// No description provided for @verifyOTP.
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get verifyOTP;

  /// No description provided for @resendOTP.
  ///
  /// In en, this message translates to:
  /// **'Resend OTP'**
  String get resendOTP;

  /// No description provided for @otpVerified.
  ///
  /// In en, this message translates to:
  /// **'OTP verified successfully!'**
  String get otpVerified;

  /// No description provided for @invalidOTP.
  ///
  /// In en, this message translates to:
  /// **'Invalid OTP code. Please try again.'**
  String get invalidOTP;

  /// No description provided for @otpVerificationError.
  ///
  /// In en, this message translates to:
  /// **'Error verifying OTP. Please try again.'**
  String get otpVerificationError;

  /// No description provided for @otpResent.
  ///
  /// In en, this message translates to:
  /// **'OTP code has been resent to your email'**
  String get otpResent;

  /// No description provided for @otpResendError.
  ///
  /// In en, this message translates to:
  /// **'Error resending OTP. Please try again.'**
  String get otpResendError;

  /// No description provided for @securityInfo.
  ///
  /// In en, this message translates to:
  /// **'Security Information'**
  String get securityInfo;

  /// No description provided for @otpSecurityNote.
  ///
  /// In en, this message translates to:
  /// **'For your security, this OTP code will expire in 10 minutes. Do not share this code with anyone.'**
  String get otpSecurityNote;

  /// No description provided for @myOtps.
  ///
  /// In en, this message translates to:
  /// **'My OTPs'**
  String get myOtps;

  /// No description provided for @permanentOtpCodes.
  ///
  /// In en, this message translates to:
  /// **'Permanent OTP Codes'**
  String get permanentOtpCodes;

  /// No description provided for @manageSecureAccessCodes.
  ///
  /// In en, this message translates to:
  /// **'Manage your secure access codes'**
  String get manageSecureAccessCodes;

  /// No description provided for @activeOtps.
  ///
  /// In en, this message translates to:
  /// **'Active OTPs'**
  String get activeOtps;

  /// No description provided for @noOtpGenerated.
  ///
  /// In en, this message translates to:
  /// **'No OTP Generated'**
  String get noOtpGenerated;

  /// No description provided for @createFirstOtpDescription.
  ///
  /// In en, this message translates to:
  /// **'Create your first permanent OTP code to securely access the platform.'**
  String get createFirstOtpDescription;

  /// No description provided for @generateFirstOtp.
  ///
  /// In en, this message translates to:
  /// **'Generate First OTP'**
  String get generateFirstOtp;

  /// No description provided for @newOtp.
  ///
  /// In en, this message translates to:
  /// **'New OTP'**
  String get newOtp;

  /// No description provided for @addOptionalTagDescription.
  ///
  /// In en, this message translates to:
  /// **'Add an optional tag to identify this OTP:'**
  String get addOptionalTagDescription;

  /// No description provided for @tagOptional.
  ///
  /// In en, this message translates to:
  /// **'Tag (optional)'**
  String get tagOptional;

  /// No description provided for @generateOtp.
  ///
  /// In en, this message translates to:
  /// **'Generate OTP'**
  String get generateOtp;

  /// No description provided for @createdNow.
  ///
  /// In en, this message translates to:
  /// **'Created now'**
  String get createdNow;

  /// No description provided for @createdMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'Created {minutes} minutes ago'**
  String createdMinutesAgo(int minutes);

  /// No description provided for @createdHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'Created {hours} hours ago'**
  String createdHoursAgo(int hours);

  /// No description provided for @createdDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'Created {days} days ago'**
  String createdDaysAgo(int days);

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @qrCode.
  ///
  /// In en, this message translates to:
  /// **'QR Code'**
  String get qrCode;

  /// No description provided for @deleteOtp.
  ///
  /// In en, this message translates to:
  /// **'Delete OTP'**
  String get deleteOtp;

  /// No description provided for @deleteOtpConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this OTP?'**
  String get deleteOtpConfirmation;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @otpCodeCopied.
  ///
  /// In en, this message translates to:
  /// **'OTP code copied to clipboard!'**
  String get otpCodeCopied;

  /// No description provided for @qrCodeOtp.
  ///
  /// In en, this message translates to:
  /// **'QR Code OTP'**
  String get qrCodeOtp;

  /// No description provided for @qrCodeFor.
  ///
  /// In en, this message translates to:
  /// **'QR Code for'**
  String get qrCodeFor;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @errorDuringLogout.
  ///
  /// In en, this message translates to:
  /// **'Error during logout: {error}'**
  String errorDuringLogout(String error);

  /// No description provided for @accountDeletionNotImplemented.
  ///
  /// In en, this message translates to:
  /// **'Account deletion not implemented yet'**
  String get accountDeletionNotImplemented;

  /// No description provided for @editOtp.
  ///
  /// In en, this message translates to:
  /// **'Edit OTP'**
  String get editOtp;

  /// No description provided for @editOtpTag.
  ///
  /// In en, this message translates to:
  /// **'Edit OTP Tag'**
  String get editOtpTag;

  /// No description provided for @updateTag.
  ///
  /// In en, this message translates to:
  /// **'Update Tag'**
  String get updateTag;

  /// No description provided for @otpTagUpdated.
  ///
  /// In en, this message translates to:
  /// **'OTP tag updated successfully!'**
  String get otpTagUpdated;

  /// No description provided for @otpTagUpdateError.
  ///
  /// In en, this message translates to:
  /// **'Error updating OTP tag. Please try again.'**
  String get otpTagUpdateError;

  /// No description provided for @otpBlocked.
  ///
  /// In en, this message translates to:
  /// **'OTP Blocked'**
  String get otpBlocked;

  /// No description provided for @otpBlockedMessage.
  ///
  /// In en, this message translates to:
  /// **'OTP blocked - Actions not available'**
  String get otpBlockedMessage;

  /// No description provided for @userNotLoaded.
  ///
  /// In en, this message translates to:
  /// **'User not loaded'**
  String get userNotLoaded;

  /// No description provided for @trainingCourse.
  ///
  /// In en, this message translates to:
  /// **'Training Course'**
  String get trainingCourse;

  /// No description provided for @otpNumber.
  ///
  /// In en, this message translates to:
  /// **'OTP #{number}'**
  String otpNumber(int number);

  /// No description provided for @certifier.
  ///
  /// In en, this message translates to:
  /// **'Certifier'**
  String get certifier;

  /// No description provided for @attachedMedia.
  ///
  /// In en, this message translates to:
  /// **'Attached Media'**
  String get attachedMedia;

  /// No description provided for @attachedMediaCount.
  ///
  /// In en, this message translates to:
  /// **'Attached Media ({count})'**
  String attachedMediaCount(int count);

  /// No description provided for @documentationAndRelatedContent.
  ///
  /// In en, this message translates to:
  /// **'Documentation and related content'**
  String get documentationAndRelatedContent;

  /// No description provided for @mediaDividedInfo.
  ///
  /// In en, this message translates to:
  /// **'Media are divided between generic certification content and specific documents of your path.'**
  String get mediaDividedInfo;

  /// No description provided for @genericMedia.
  ///
  /// In en, this message translates to:
  /// **'Context Media'**
  String get genericMedia;

  /// No description provided for @didacticMaterialAndOfficialDocumentation.
  ///
  /// In en, this message translates to:
  /// **'Didactic material and official documentation'**
  String get didacticMaterialAndOfficialDocumentation;

  /// No description provided for @personalMedia.
  ///
  /// In en, this message translates to:
  /// **'Certification Media'**
  String get personalMedia;

  /// No description provided for @documentsAndContentOfYourCertificationPath.
  ///
  /// In en, this message translates to:
  /// **'Documents and content of your certification path'**
  String get documentsAndContentOfYourCertificationPath;

  /// No description provided for @realTime.
  ///
  /// In en, this message translates to:
  /// **'REAL-TIME'**
  String get realTime;

  /// No description provided for @uploadedInRealtime.
  ///
  /// In en, this message translates to:
  /// **'uploaded in realtime'**
  String get uploadedInRealtime;

  /// No description provided for @uploaded.
  ///
  /// In en, this message translates to:
  /// **'UPLOADED'**
  String get uploaded;

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @otpCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'OTP created successfully'**
  String get otpCreatedSuccessfully;

  /// No description provided for @otpCreationFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to create OTP'**
  String get otpCreationFailed;

  /// No description provided for @otpVerificationSuccess.
  ///
  /// In en, this message translates to:
  /// **'OTP verified successfully'**
  String get otpVerificationSuccess;

  /// No description provided for @otpVerificationFailed.
  ///
  /// In en, this message translates to:
  /// **'OTP verification failed'**
  String get otpVerificationFailed;

  /// No description provided for @otpBurnedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'OTP invalidated successfully'**
  String get otpBurnedSuccessfully;

  /// No description provided for @otpBurnFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to invalidate OTP'**
  String get otpBurnFailed;

  /// No description provided for @otpMetadataRetrieved.
  ///
  /// In en, this message translates to:
  /// **'OTP metadata retrieved'**
  String get otpMetadataRetrieved;

  /// No description provided for @otpMetadataFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to retrieve OTP metadata'**
  String get otpMetadataFailed;

  /// No description provided for @otpCleanupSuccess.
  ///
  /// In en, this message translates to:
  /// **'Cleaned up {count} expired OTPs'**
  String otpCleanupSuccess(int count);

  /// No description provided for @otpCleanupFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to cleanup expired OTPs'**
  String get otpCleanupFailed;

  /// No description provided for @invalidOtpCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid OTP code'**
  String get invalidOtpCode;

  /// No description provided for @otpExpired.
  ///
  /// In en, this message translates to:
  /// **'OTP has expired'**
  String get otpExpired;

  /// No description provided for @otpAlreadyUsed.
  ///
  /// In en, this message translates to:
  /// **'OTP has already been used'**
  String get otpAlreadyUsed;

  /// No description provided for @otpAlreadyBurned.
  ///
  /// In en, this message translates to:
  /// **'OTP has been invalidated'**
  String get otpAlreadyBurned;

  /// No description provided for @otpNotFound.
  ///
  /// In en, this message translates to:
  /// **'OTP not found'**
  String get otpNotFound;

  /// No description provided for @generatingOtp.
  ///
  /// In en, this message translates to:
  /// **'Generating OTP...'**
  String get generatingOtp;

  /// No description provided for @verifyingOtp.
  ///
  /// In en, this message translates to:
  /// **'Verifying OTP...'**
  String get verifyingOtp;

  /// No description provided for @burningOtp.
  ///
  /// In en, this message translates to:
  /// **'Invalidating OTP...'**
  String get burningOtp;

  /// No description provided for @loadingOtpMetadata.
  ///
  /// In en, this message translates to:
  /// **'Loading OTP metadata...'**
  String get loadingOtpMetadata;

  /// No description provided for @cleaningUpOtps.
  ///
  /// In en, this message translates to:
  /// **'Cleaning up expired OTPs...'**
  String get cleaningUpOtps;

  /// No description provided for @otpCodeLength.
  ///
  /// In en, this message translates to:
  /// **'Code length'**
  String get otpCodeLength;

  /// No description provided for @otpTtlSeconds.
  ///
  /// In en, this message translates to:
  /// **'Time to live (seconds)'**
  String get otpTtlSeconds;

  /// No description provided for @otpNumericOnly.
  ///
  /// In en, this message translates to:
  /// **'Numeric only'**
  String get otpNumericOnly;

  /// No description provided for @otpTag.
  ///
  /// In en, this message translates to:
  /// **'Tag'**
  String get otpTag;

  /// No description provided for @otpIdUser.
  ///
  /// In en, this message translates to:
  /// **'User ID'**
  String get otpIdUser;

  /// No description provided for @otpUsedBy.
  ///
  /// In en, this message translates to:
  /// **'Used by'**
  String get otpUsedBy;

  /// No description provided for @otpMarkUsed.
  ///
  /// In en, this message translates to:
  /// **'Mark as used'**
  String get otpMarkUsed;

  /// No description provided for @otpCreatedAt.
  ///
  /// In en, this message translates to:
  /// **'Created at'**
  String get otpCreatedAt;

  /// No description provided for @otpExpiresAt.
  ///
  /// In en, this message translates to:
  /// **'Expires at'**
  String get otpExpiresAt;

  /// No description provided for @otpUsedAt.
  ///
  /// In en, this message translates to:
  /// **'Used at'**
  String get otpUsedAt;

  /// No description provided for @otpBurnedAt.
  ///
  /// In en, this message translates to:
  /// **'Burned at'**
  String get otpBurnedAt;

  /// No description provided for @otpStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get otpStatus;

  /// No description provided for @otpStatusValid.
  ///
  /// In en, this message translates to:
  /// **'Valid'**
  String get otpStatusValid;

  /// No description provided for @otpStatusExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get otpStatusExpired;

  /// No description provided for @otpStatusUsed.
  ///
  /// In en, this message translates to:
  /// **'Used'**
  String get otpStatusUsed;

  /// No description provided for @otpStatusBurned.
  ///
  /// In en, this message translates to:
  /// **'Burned'**
  String get otpStatusBurned;

  /// No description provided for @addToLinkedIn.
  ///
  /// In en, this message translates to:
  /// **'Add to LinkedIn'**
  String get addToLinkedIn;

  /// No description provided for @errorOpeningLinkedIn.
  ///
  /// In en, this message translates to:
  /// **'Error opening LinkedIn'**
  String get errorOpeningLinkedIn;

  /// No description provided for @addCertificationsToLinkedIn.
  ///
  /// In en, this message translates to:
  /// **'Add Certification to LinkedIn'**
  String get addCertificationsToLinkedIn;

  /// No description provided for @nftLink.
  ///
  /// In en, this message translates to:
  /// **'NFT Link'**
  String get nftLink;

  /// No description provided for @errorOpeningNftLink.
  ///
  /// In en, this message translates to:
  /// **'Error opening NFT link'**
  String get errorOpeningNftLink;

  /// No description provided for @linkedInIntegration.
  ///
  /// In en, this message translates to:
  /// **'LinkedIn Certification Integration'**
  String get linkedInIntegration;

  /// No description provided for @shareCertificationsOnLinkedIn.
  ///
  /// In en, this message translates to:
  /// **'This will copy the certification details to your clipboard and open LinkedIn. Then go to your profile → Add profile section → Licenses & certifications and paste the details.'**
  String get shareCertificationsOnLinkedIn;

  /// No description provided for @realTimeMediaNotDownloadable.
  ///
  /// In en, this message translates to:
  /// **'Real-time media cannot be downloaded'**
  String get realTimeMediaNotDownloadable;

  /// No description provided for @mediaNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Media file is not available for download'**
  String get mediaNotAvailable;

  /// No description provided for @createOpenBadge.
  ///
  /// In en, this message translates to:
  /// **'Create Open Badge'**
  String get createOpenBadge;

  /// No description provided for @openBadgeDescription.
  ///
  /// In en, this message translates to:
  /// **'Create a verifiable digital badge for this certification. Open Badges are portable, verifiable credentials that can be shared on professional platforms.'**
  String get openBadgeDescription;

  /// No description provided for @openBadgeBenefits.
  ///
  /// In en, this message translates to:
  /// **'Benefits: Portable, verifiable, shareable on LinkedIn and other platforms, follows international standards.'**
  String get openBadgeBenefits;

  /// No description provided for @createBadge.
  ///
  /// In en, this message translates to:
  /// **'Create Badge'**
  String get createBadge;

  /// No description provided for @openBadgeCreated.
  ///
  /// In en, this message translates to:
  /// **'Open Badge Created'**
  String get openBadgeCreated;

  /// No description provided for @openBadgeError.
  ///
  /// In en, this message translates to:
  /// **'Error creating Open Badge'**
  String get openBadgeError;

  /// No description provided for @downloadPng.
  ///
  /// In en, this message translates to:
  /// **'Download PNG'**
  String get downloadPng;

  /// No description provided for @badgeImageSaved.
  ///
  /// In en, this message translates to:
  /// **'Badge image saved successfully!'**
  String get badgeImageSaved;

  /// No description provided for @badgeImageError.
  ///
  /// In en, this message translates to:
  /// **'Error downloading badge image'**
  String get badgeImageError;

  /// No description provided for @saveImageAs.
  ///
  /// In en, this message translates to:
  /// **'Right-click on the image above and select \"Save image as...\" to download the badge PNG.'**
  String get saveImageAs;

  /// No description provided for @noOtpsYet.
  ///
  /// In en, this message translates to:
  /// **'No OTPs yet'**
  String get noOtpsYet;

  /// No description provided for @createYourFirstOtp.
  ///
  /// In en, this message translates to:
  /// **'Create your first OTP to get started'**
  String get createYourFirstOtp;

  /// No description provided for @secureAccess.
  ///
  /// In en, this message translates to:
  /// **'Secure Access'**
  String get secureAccess;

  /// No description provided for @secureAccessDescription.
  ///
  /// In en, this message translates to:
  /// **'Secure and temporary access codes'**
  String get secureAccessDescription;

  /// No description provided for @timeLimited.
  ///
  /// In en, this message translates to:
  /// **'Automatic expiration for enhanced security'**
  String get timeLimited;

  /// No description provided for @timeLimitedDescription.
  ///
  /// In en, this message translates to:
  /// **'Codes expire automatically to ensure security'**
  String get timeLimitedDescription;

  /// No description provided for @qrCodeSupport.
  ///
  /// In en, this message translates to:
  /// **'QR Code Support'**
  String get qrCodeSupport;

  /// No description provided for @qrCodeSupportDescription.
  ///
  /// In en, this message translates to:
  /// **'Generate and share QR codes for quick access'**
  String get qrCodeSupportDescription;

  /// No description provided for @otpCode.
  ///
  /// In en, this message translates to:
  /// **'OTP Code'**
  String get otpCode;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorOccurred;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get unknownError;

  /// No description provided for @statusBurned.
  ///
  /// In en, this message translates to:
  /// **'Burned'**
  String get statusBurned;

  /// No description provided for @statusUsed.
  ///
  /// In en, this message translates to:
  /// **'Used'**
  String get statusUsed;

  /// No description provided for @statusExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get statusExpired;

  /// No description provided for @statusValid.
  ///
  /// In en, this message translates to:
  /// **'Valid'**
  String get statusValid;

  /// No description provided for @databaseConnectionFailed.
  ///
  /// In en, this message translates to:
  /// **'Database connection failed'**
  String get databaseConnectionFailed;

  /// No description provided for @edgeFunctionNotAccessible.
  ///
  /// In en, this message translates to:
  /// **'Edge Function not accessible'**
  String get edgeFunctionNotAccessible;

  /// No description provided for @preparingLinkedIn.
  ///
  /// In en, this message translates to:
  /// **'Preparing LinkedIn...'**
  String get preparingLinkedIn;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @issuer.
  ///
  /// In en, this message translates to:
  /// **'Issuer'**
  String get issuer;

  /// No description provided for @downloadingMedia.
  ///
  /// In en, this message translates to:
  /// **'Downloading media...'**
  String get downloadingMedia;

  /// No description provided for @mediaDownloadedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Media downloaded successfully'**
  String get mediaDownloadedSuccessfully;

  /// No description provided for @errorDownloadingMedia.
  ///
  /// In en, this message translates to:
  /// **'Error downloading media'**
  String get errorDownloadingMedia;

  /// No description provided for @errorCreatingOpenBadge.
  ///
  /// In en, this message translates to:
  /// **'Error creating Open Badge'**
  String get errorCreatingOpenBadge;

  /// No description provided for @issueDate.
  ///
  /// In en, this message translates to:
  /// **'Issue Date'**
  String get issueDate;

  /// No description provided for @yourOpenBadgeCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Your Open Badge has been created successfully!'**
  String get yourOpenBadgeCreatedSuccessfully;

  /// No description provided for @badge.
  ///
  /// In en, this message translates to:
  /// **'Badge'**
  String get badge;

  /// No description provided for @filesSavedTo.
  ///
  /// In en, this message translates to:
  /// **'Files saved to'**
  String get filesSavedTo;

  /// No description provided for @connectionTestResults.
  ///
  /// In en, this message translates to:
  /// **'Connection Test Results'**
  String get connectionTestResults;

  /// No description provided for @createOtp.
  ///
  /// In en, this message translates to:
  /// **'Create OTP'**
  String get createOtp;

  /// No description provided for @testConnection.
  ///
  /// In en, this message translates to:
  /// **'Test Connection'**
  String get testConnection;

  /// No description provided for @cleanupExpired.
  ///
  /// In en, this message translates to:
  /// **'Cleanup Expired'**
  String get cleanupExpired;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @noOtpsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No OTPs available'**
  String get noOtpsAvailable;

  /// No description provided for @codeCopiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Code copied to clipboard!'**
  String get codeCopiedToClipboard;
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
