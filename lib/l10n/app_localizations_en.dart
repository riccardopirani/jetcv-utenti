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
  String get comingSoon => 'Coming Soon';

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
  String get dateOfBirth => 'Date of Birth';

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
  String get viewMyCV => 'View My CV';

  @override
  String get copyLink => 'Copy Link';

  @override
  String get share => 'Share';

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
  String get cvLanguage => 'CV Display Language';

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
  String get serialCode => 'Serial Code';

  @override
  String get verifiedCV => 'Verified CV';

  @override
  String get autodichiarazioni => 'Self-Declarations';

  @override
  String get spokenLanguages => 'Spoken languages:';

  @override
  String get noLanguageSpecified => 'No language specified';

  @override
  String get certifications => 'Certifications';

  @override
  String get mostRecent => 'Most Recent';

  @override
  String get lessRecent => 'Less Recent';

  @override
  String get verifiedCertifications => 'verified certifications';

  @override
  String get loadingCertifications => 'Loading certifications...';

  @override
  String get errorLoadingCertifications => 'Error loading certifications';

  @override
  String get retry => 'Retry';

  @override
  String get noCertificationsFound => 'No certifications found';

  @override
  String get yourVerifiedCertifications =>
      'Your verified certifications will appear here';

  @override
  String get certification => 'Certification';

  @override
  String get certifyingBody => 'Certifying Body';

  @override
  String get status => 'Status';

  @override
  String get serial => 'Serial';

  @override
  String get verifiedAndAuthenticated =>
      'Verified and authenticated certification';

  @override
  String get approved => 'Approved';

  @override
  String get verified => 'Verified';

  @override
  String get completed => 'Completed';

  @override
  String get pending => 'Pending';

  @override
  String get inProgress => 'In Progress';

  @override
  String get rejected => 'Rejected';

  @override
  String get failed => 'Failed';

  @override
  String get nationality => 'Nationality';

  @override
  String get noNationalitySpecified => 'No nationality specified';

  @override
  String get cvLinkCopied => 'CV link copied to clipboard! Share it now.';

  @override
  String errorChangingLanguage(String error) {
    return 'Error changing language: $error';
  }

  @override
  String get projectManagement => 'PROJECT\nMANAGEMENT';

  @override
  String get flutterDevelopment => 'FLUTTER\nDEVELOPMENT';

  @override
  String get certified => 'CERTIFIED';

  @override
  String get myProfile => 'My Profile';

  @override
  String get myCV => 'My CV';

  @override
  String get myCertifications => 'My Certifications';

  @override
  String get otp => 'OTP';

  @override
  String get myWallets => 'My Wallets';

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
  String get activeOtps => 'Active OTPs';

  @override
  String get noOtpsFound => 'No OTPs found';

  @override
  String get noOtpsFoundDescription => 'No OTPs match the selected filter';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get logout => 'Logout';

  @override
  String get otpVerification => 'OTP Verification';

  @override
  String get otpDescription =>
      'Enter the 6-digit code sent to your registered email';

  @override
  String get enterOTP => 'Enter OTP Code';

  @override
  String get verifyOTP => 'Verify OTP';

  @override
  String get resendOTP => 'Resend OTP';

  @override
  String get otpVerified => 'OTP verified successfully!';

  @override
  String get invalidOTP => 'Invalid OTP code. Please try again.';

  @override
  String get otpVerificationError => 'Error verifying OTP. Please try again.';

  @override
  String get otpResent => 'OTP code has been resent to your email';

  @override
  String get otpResendError => 'Error resending OTP. Please try again.';

  @override
  String get securityInfo => 'Security Information';

  @override
  String get otpSecurityNote =>
      'For your security, this OTP code will expire in 10 minutes. Do not share this code with anyone.';

  @override
  String get myOtps => 'My OTPs';

  @override
  String get permanentOtpCodes => 'Permanent OTP Codes';

  @override
  String get manageSecureAccessCodes => 'Manage your secure access codes';

  @override
  String get noOtpGenerated => 'No OTP Generated';

  @override
  String get createFirstOtpDescription =>
      'Create your first permanent OTP code to securely access the platform.';

  @override
  String get generateFirstOtp => 'Generate First OTP';

  @override
  String get newOtp => 'New OTP';

  @override
  String get addOptionalTagDescription =>
      'Add an optional tag to identify this OTP:';

  @override
  String get tagOptional => 'Tag (optional)';

  @override
  String get generateOtp => 'Generate OTP';

  @override
  String get createdNow => 'Created now';

  @override
  String createdMinutesAgo(int minutes) {
    return 'Created $minutes minutes ago';
  }

  @override
  String createdHoursAgo(int hours) {
    return 'Created $hours hours ago';
  }

  @override
  String createdDaysAgo(int days) {
    return 'Created $days days ago';
  }

  @override
  String get copy => 'Copy';

  @override
  String get qrCode => 'QR Code';

  @override
  String get deleteOtp => 'Delete OTP';

  @override
  String get deleteOtpConfirmation =>
      'Are you sure you want to delete this OTP?';

  @override
  String get delete => 'Delete';

  @override
  String get otpCodeCopied => 'OTP code copied to clipboard!';

  @override
  String get qrCodeOtp => 'QR Code OTP';

  @override
  String get qrCodeFor => 'QR Code for';

  @override
  String get close => 'Close';

  @override
  String errorDuringLogout(String error) {
    return 'Error during logout: $error';
  }

  @override
  String get accountDeletionNotImplemented =>
      'Account deletion not implemented yet';

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
  String get userNotLoaded => 'User not loaded';

  @override
  String get trainingCourse => 'Training Course';

  @override
  String otpNumber(int number) {
    return 'OTP #$number';
  }

  @override
  String get certifier => 'Certifier';

  @override
  String get attachedMedia => 'Attached Media';

  @override
  String attachedMediaCount(int count) {
    return 'Attached Media ($count)';
  }

  @override
  String get documentationAndRelatedContent =>
      'Documentation and related content';

  @override
  String get mediaDividedInfo =>
      'Media are divided between generic certification content and specific documents of your path.';

  @override
  String get genericMedia => 'Context Media';

  @override
  String get didacticMaterialAndOfficialDocumentation =>
      'Didactic material and official documentation';

  @override
  String get personalMedia => 'Certification Media';

  @override
  String get documentsAndContentOfYourCertificationPath =>
      'Documents and content of your certification path';

  @override
  String get realTime => 'REAL-TIME';

  @override
  String get uploadedInRealtime => 'uploaded in realtime';

  @override
  String get uploaded => 'UPLOADED';

  @override
  String get view => 'View';

  @override
  String get download => 'Download';

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
  String get errorOpeningLinkedIn => 'Error opening LinkedIn';

  @override
  String get addCertificationsToLinkedIn => 'Add Certification to LinkedIn';

  @override
  String get nftLink => 'NFT Link';

  @override
  String get errorOpeningNftLink => 'Error opening NFT link';

  @override
  String get viewBlockchainDetails => 'View blockchain details';

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
  String get openBadgeCreated => 'Open Badge Created';

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
      'Digital credentials and achievements';

  @override
  String get importYourOpenBadges => 'Import your Open Badges';

  @override
  String get showcaseYourDigitalCredentials =>
      'Showcase your digital credentials and achievements';

  @override
  String get languageName_en => 'English';

  @override
  String get languageName_it => 'Italian';

  @override
  String get languageName_fr => 'French';

  @override
  String get languageName_es => 'Spanish';

  @override
  String get languageName_de => 'German';

  @override
  String get languageName_pt => 'Portuguese';

  @override
  String get languageName_ru => 'Russian';

  @override
  String get languageName_zh => 'Chinese';

  @override
  String get languageName_ja => 'Japanese';

  @override
  String get languageName_ko => 'Korean';

  @override
  String get languageName_ar => 'Arabic';

  @override
  String get languageName_hi => 'Hindi';

  @override
  String get languageName_tr => 'Turkish';

  @override
  String get languageName_pl => 'Polish';

  @override
  String get languageName_nl => 'Dutch';

  @override
  String get countryName_IT => 'Italy';

  @override
  String get countryName_FR => 'France';

  @override
  String get countryName_DE => 'Germany';

  @override
  String get countryName_ES => 'Spain';

  @override
  String get countryName_GB => 'United Kingdom';

  @override
  String get countryName_US => 'United States';

  @override
  String get countryName_CA => 'Canada';

  @override
  String get countryName_AU => 'Australia';

  @override
  String get countryName_JP => 'Japan';

  @override
  String get countryName_CN => 'China';

  @override
  String get countryName_BR => 'Brazil';

  @override
  String get countryName_IN => 'India';

  @override
  String get countryName_RU => 'Russia';

  @override
  String get countryName_MX => 'Mexico';

  @override
  String get countryName_AR => 'Argentina';

  @override
  String get countryName_NL => 'Netherlands';

  @override
  String get countryName_CH => 'Switzerland';

  @override
  String get countryName_AT => 'Austria';

  @override
  String get countryName_BE => 'Belgium';

  @override
  String get countryName_PT => 'Portugal';

  @override
  String get lastUpdate => 'Last update';

  @override
  String get certificationTitle => 'Title';

  @override
  String get certificationOutcome => 'Outcome';

  @override
  String get certificationDetails => 'Details';

  @override
  String get certType_attestato_di_frequenza => 'Certificate of attendance';

  @override
  String get certType_certificato_di_competenza => 'Certificate of competence';

  @override
  String get certType_diploma => 'Diploma';

  @override
  String get certType_laurea => 'Degree';

  @override
  String get certType_master => 'Master\'s degree';

  @override
  String get certType_corso_di_formazione => 'Training course';

  @override
  String get certType_certificazione_professionale =>
      'Professional certification';

  @override
  String get certType_patente => 'License';

  @override
  String get certType_abilitazione => 'Qualification';

  @override
  String get serialNumber => 'Serial';

  @override
  String get noOtpsYet => 'No OTPs yet';

  @override
  String get createYourFirstOtp => 'Create your first OTP to get started';

  @override
  String get secureAccess => 'Secure Access';

  @override
  String get secureAccessDescription => 'Secure and temporary access codes';

  @override
  String get timeLimited => 'Automatic expiration for enhanced security';

  @override
  String get timeLimitedDescription =>
      'Codes expire automatically to ensure security';

  @override
  String get qrCodeSupport => 'QR Code Support';

  @override
  String get qrCodeSupportDescription =>
      'Generate and share QR codes for quick access';

  @override
  String get otpCode => 'OTP Code';

  @override
  String get errorOccurred => 'Error';

  @override
  String get unknownError => 'Unknown error';

  @override
  String get statusBurned => 'Burned';

  @override
  String get statusUsed => 'Used';

  @override
  String get statusExpired => 'Expired';

  @override
  String get statusValid => 'Valid';

  @override
  String get databaseConnectionFailed => 'Database connection failed';

  @override
  String get edgeFunctionNotAccessible => 'Edge Function not accessible';

  @override
  String get preparingLinkedIn => 'Preparing LinkedIn...';

  @override
  String get name => 'Name';

  @override
  String get issuer => 'Issuer';

  @override
  String get downloadingMedia => 'Downloading media...';

  @override
  String get mediaDownloadedSuccessfully => 'Media downloaded successfully';

  @override
  String get errorDownloadingMedia => 'Error downloading media';

  @override
  String get errorCreatingOpenBadge => 'Error creating Open Badge';

  @override
  String get issueDate => 'Issue Date';

  @override
  String get yourOpenBadgeCreatedSuccessfully =>
      'Your Open Badge has been created successfully!';

  @override
  String get badge => 'Badge';

  @override
  String get filesSavedTo => 'Files saved to';

  @override
  String get connectionTestResults => 'Connection Test Results';

  @override
  String get createOtp => 'Create OTP';

  @override
  String get testConnection => 'Test Connection';

  @override
  String get cleanupExpired => 'Cleanup Expired';

  @override
  String get refresh => 'Refresh';

  @override
  String get noOtpsAvailable => 'No OTPs available';

  @override
  String get codeCopiedToClipboard => 'Code copied to clipboard!';

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
}
