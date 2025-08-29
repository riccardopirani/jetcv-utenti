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

  @override
  String get home => 'Home';

  @override
  String get cv => 'CV';

  @override
  String get profile => 'Profile';

  @override
  String get welcome => 'Welcome,';

  @override
  String get verifiedOnBlockchain => 'Account verified on blockchain';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get newCV => 'New CV';

  @override
  String get createYourDigitalCV => 'Create your digital CV';

  @override
  String get viewCV => 'View CV';

  @override
  String get yourDigitalCV => 'Your digital CV';

  @override
  String get cvViewInDevelopment => 'CV View - In development';

  @override
  String get user => 'User';

  @override
  String loginError(String error) {
    return 'Login error: $error';
  }

  @override
  String googleAuthError(String error) {
    return 'Google authentication error: $error';
  }

  @override
  String get signInToAccount => 'Sign in to your account';

  @override
  String get enterEmail => 'Enter your email';

  @override
  String get enterValidEmail => 'Enter a valid email';

  @override
  String get password => 'Password';

  @override
  String get enterPassword => 'Enter your password';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get signIn => 'Sign In';

  @override
  String get or => 'or';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get noAccount => 'Don\'t have an account? ';

  @override
  String get signUp => 'Sign Up';

  @override
  String get mustAcceptTerms => 'You must accept the terms and conditions';

  @override
  String get confirmEmail => 'Confirm email';

  @override
  String get emailConfirmationSent =>
      'We sent you a confirmation email. Click the link in the email to activate your account.';

  @override
  String get ok => 'OK';

  @override
  String get registrationCompleted => 'Registration completed';

  @override
  String get accountCreatedSuccess =>
      'Account created successfully! You can start using JetCV.';

  @override
  String get start => 'Start';

  @override
  String get createAccount => 'Create your account';

  @override
  String get startJourney => 'Start your journey with JetCV';

  @override
  String get fullName => 'Full name';

  @override
  String get enterFullName => 'Enter your full name';

  @override
  String get nameMinLength => 'Name must be at least 2 characters';

  @override
  String get createSecurePassword => 'Create a secure password';

  @override
  String get passwordMinLength => 'Password must be at least 6 characters';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get confirmYourPassword => 'Confirm your password';

  @override
  String get passwordsDontMatch => 'Passwords don\'t match';

  @override
  String get acceptTerms => 'I accept the ';

  @override
  String get termsAndConditions => 'Terms and Conditions';

  @override
  String get and => ' and the ';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get haveAccount => 'Already have an account? ';

  @override
  String errorLabel(String error) {
    return 'Error: $error';
  }

  @override
  String get emailSent => 'Email sent!';

  @override
  String get passwordForgotten => 'Forgot password?';

  @override
  String get resetInstructionsSent =>
      'We sent password reset instructions to your email';

  @override
  String get dontWorryReset =>
      'Don\'t worry! Enter your email and we\'ll send you a password reset link';

  @override
  String get sendResetEmail => 'Send reset email';

  @override
  String get checkEmailInstructions =>
      'Check your email and click the link to reset your password. If you don\'t see the email, also check your spam folder.';

  @override
  String get backToLogin => 'Back to Login';

  @override
  String get rememberPassword => 'Remember your password? ';

  @override
  String get saveErrorGeneric => 'Save error';

  @override
  String get blockchainPowered => 'Blockchain Powered';

  @override
  String get digitalCVTitle => 'Your digital CV\nverified on blockchain';

  @override
  String get digitalCVDescription =>
      'Create, manage and share your curriculum vitae with the security and authenticity guaranteed by blockchain technology.';

  @override
  String get mainFeatures => 'Main Features';

  @override
  String get blockchainVerification => 'Blockchain Verification';

  @override
  String get blockchainVerificationDesc =>
      'Your data is immutable and verifiable on the blockchain';

  @override
  String get secureSharing => 'Secure Sharing';

  @override
  String get secureSharingDesc =>
      'Share your CV with a secure and traceable link';

  @override
  String get realTimeUpdates => 'Real-Time Updates';

  @override
  String get realTimeUpdatesDesc => 'Edit and update your CV at any time';

  @override
  String get jetcvInNumbers => 'JetCV in numbers';

  @override
  String get cvsCreated => 'CVs Created';

  @override
  String get activeUsers => 'Active Users';

  @override
  String get security => 'Security';

  @override
  String get readyToStart => 'Ready to get started?';

  @override
  String get createFirstCV =>
      'Create your first digital CV on blockchain in just a few minutes';

  @override
  String get createYourCV => 'Create your CV';

  @override
  String get signInToYourAccount => 'Sign in to your account';

  @override
  String get shareCV => 'Share CV';

  @override
  String get shareText => 'Share';

  @override
  String get cvLanguage => 'CV Language';

  @override
  String get personalInfo => 'Personal Information';

  @override
  String get age => 'age';

  @override
  String get contactInfo => 'Contact Information';

  @override
  String get languages => 'Languages';

  @override
  String get skills => 'Skills';

  @override
  String get attitudes => 'Attitudes';

  @override
  String get languagesPlaceholder =>
      'Your language skills will be displayed here';

  @override
  String get attitudesPlaceholder =>
      'Your attitudes and soft skills will be displayed here';

  @override
  String get cvShared => 'CV link copied to clipboard!';

  @override
  String shareError(Object error) {
    return 'Error sharing: $error';
  }

  @override
  String get years => 'years';

  @override
  String get born => 'born';

  @override
  String get bornFemale => 'born';

  @override
  String get blockchainCertified => 'Blockchain Certified';

  @override
  String get cvSerial => 'CV Serial';

  @override
  String get verifiedCV => 'Verified CV';
}
