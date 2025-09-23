// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'JetCV';

  @override
  String get comingSoon => 'Próximamente';

  @override
  String get personalInformation => 'Información Personal';

  @override
  String get yourProfile => 'Tu perfil';

  @override
  String get enterYourPersonalInfo => 'Introduce tu información personal';

  @override
  String get personalData => 'Datos personales';

  @override
  String get contactInformation => 'Información de contacto';

  @override
  String get address => 'Dirección';

  @override
  String get firstName => 'Nombre';

  @override
  String get lastName => 'Apellido';

  @override
  String get gender => 'Género';

  @override
  String get dateOfBirth => 'Fecha de nacimiento';

  @override
  String get email => 'Email';

  @override
  String get phone => 'Teléfono';

  @override
  String get addressField => 'Dirección';

  @override
  String get city => 'Ciudad';

  @override
  String get state => 'Provincia';

  @override
  String get postalCode => 'Código Postal';

  @override
  String get country => 'País';

  @override
  String get selectPhoto => 'Seleccionar foto de perfil';

  @override
  String get takePhoto => 'Tomar foto';

  @override
  String get chooseFromGallery => 'Elegir de la galería';

  @override
  String get cancel => 'Cancelar';

  @override
  String get addPhoto => 'Añadir foto';

  @override
  String get replacePhoto => 'Reemplazar foto';

  @override
  String get uploading => 'Subiendo...';

  @override
  String get saveInformation => 'Guardar información';

  @override
  String get saving => 'Guardando...';

  @override
  String get firstNameRequired => 'El nombre es obligatorio';

  @override
  String get lastNameRequired => 'El apellido es obligatorio';

  @override
  String get genderRequired => 'El género es obligatorio';

  @override
  String get emailRequired => 'El email es obligatorio';

  @override
  String get validEmailRequired => 'Introduce un email válido';

  @override
  String get phoneRequired => 'El teléfono es obligatorio';

  @override
  String get addressRequired => 'La dirección es obligatoria';

  @override
  String get cityRequired => 'La ciudad es obligatoria';

  @override
  String get stateRequired => 'La provincia es obligatoria';

  @override
  String get postalCodeRequired => 'El código postal es obligatorio';

  @override
  String get countryRequired => 'El país es obligatorio';

  @override
  String get validDateRequired => 'Introduce una fecha de nacimiento válida';

  @override
  String get dateFormatRequired => 'Formato requerido: dd/mm/yyyy';

  @override
  String get invalidDate => 'Fecha inválida';

  @override
  String get invalidDay => 'Día inválido (01-31)';

  @override
  String get invalidMonth => 'Mes inválido (01-12)';

  @override
  String invalidYear(int currentYear) {
    return 'Año inválido (1900-$currentYear)';
  }

  @override
  String get inexistentDate =>
      'Fecha inexistente (ej. 29/02 en año no bisiesto)';

  @override
  String get searchCountry => 'Buscar país...';

  @override
  String get selectCountry => 'Seleccionar país';

  @override
  String get noCountryFound => 'Ningún país encontrado';

  @override
  String get fileTooLarge =>
      'El archivo es demasiado grande. Máximo 5MB permitidos.';

  @override
  String get unsupportedFormat =>
      'Formato de archivo no soportado. Usa JPG, PNG o WebP.';

  @override
  String imageSelectionError(String error) {
    return 'Error durante la selección de imagen: $error';
  }

  @override
  String get profilePictureUploaded => 'Foto de perfil subida exitosamente!';

  @override
  String uploadError(String error) {
    return 'Error durante la subida: $error';
  }

  @override
  String photoUploadError(String error) {
    return 'Error durante la subida de foto: $error. Los datos personales se guardarán de todos modos.';
  }

  @override
  String get informationSaved => 'Información personal guardada exitosamente!';

  @override
  String get informationSavedWithPhotoError =>
      'Información personal guardada exitosamente! (Nota: la foto de perfil no se subió)';

  @override
  String saveError(String error) {
    return 'Error en el guardado: $error';
  }

  @override
  String get languageSettings => 'Configuración de Idioma';

  @override
  String get selectLanguage => 'Seleccionar Idioma';

  @override
  String get languageChanged => 'Idioma cambiado exitosamente';

  @override
  String get language => 'Idioma';

  @override
  String get home => 'Inicio';

  @override
  String get cv => 'CV';

  @override
  String get profile => 'Perfil';

  @override
  String get welcome => 'Bienvenido,';

  @override
  String get verifiedOnBlockchain => 'Curriculum certificado en blockchain';

  @override
  String get quickActions => 'Acciones rápidas';

  @override
  String get newCV => 'Nuevo CV';

  @override
  String get createYourDigitalCV => 'Crea tu CV digital';

  @override
  String get viewCV => 'Ver CV';

  @override
  String get yourDigitalCV => 'Tu CV digital';

  @override
  String get cvViewInDevelopment => 'Vista CV - En desarrollo';

  @override
  String get user => 'Usuario';

  @override
  String loginError(String error) {
    return 'Error de inicio de sesión: $error';
  }

  @override
  String googleAuthError(String error) {
    return 'Error de autenticación con Google: $error';
  }

  @override
  String get signInToAccount => 'Inicia sesión en tu cuenta';

  @override
  String get enterEmail => 'Ingresa tu email';

  @override
  String get enterValidEmail => 'Ingresa un email válido';

  @override
  String get password => 'Contraseña';

  @override
  String get enterPassword => 'Ingresa tu contraseña';

  @override
  String get forgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get signIn => 'Iniciar sesión';

  @override
  String get or => 'o';

  @override
  String get continueWithGoogle => 'Continuar con Google';

  @override
  String get noAccount => '¿No tienes una cuenta? ';

  @override
  String get signUp => 'Registrarse';

  @override
  String get mustAcceptTerms => 'Debes aceptar los términos y condiciones';

  @override
  String get confirmEmail => 'Confirmar email';

  @override
  String get emailConfirmationSent =>
      'Te enviamos un email de confirmación. Haz clic en el enlace del email para activar tu cuenta.';

  @override
  String get ok => 'OK';

  @override
  String get registrationCompleted => 'Registro completado';

  @override
  String get accountCreatedSuccess =>
      '¡Cuenta creada exitosamente! Puedes empezar a usar JetCV.';

  @override
  String get start => 'Comenzar';

  @override
  String get createAccount => 'Crea tu cuenta';

  @override
  String get startJourney => 'Comienza tu viaje con JetCV';

  @override
  String get fullName => 'Nombre y Apellido';

  @override
  String get enterFullName => 'ej. Juan García';

  @override
  String get nameMinLength => 'El nombre debe tener al menos 2 caracteres';

  @override
  String get viewMyCV => 'Ver mi CV';

  @override
  String get copyLink => 'Copiar Enlace';

  @override
  String get share => 'Compartir';

  @override
  String get createSecurePassword =>
      'Crea una contraseña segura (8+ caracteres, mayúscula, minúscula, número, símbolo)';

  @override
  String get passwordMinLength =>
      'La contraseña debe tener al menos 8 caracteres';

  @override
  String get passwordComplexityRequired =>
      'La contraseña debe contener mayúscula, minúscula, número y símbolo';

  @override
  String get confirmPassword => 'Confirmar contraseña';

  @override
  String get confirmYourPassword => 'Confirma tu contraseña';

  @override
  String get passwordsDontMatch => 'Las contraseñas no coinciden';

  @override
  String get acceptTerms => 'Acepto los ';

  @override
  String get termsAndConditions => 'Términos y Condiciones';

  @override
  String get and => ' y la ';

  @override
  String get privacyPolicy => 'Política de Privacidad';

  @override
  String get haveAccount => '¿Ya tienes una cuenta? ';

  @override
  String errorLabel(String error) {
    return 'Error: $error';
  }

  @override
  String get emailSent => '¡Email enviado!';

  @override
  String get passwordForgotten => '¿Olvidaste tu contraseña?';

  @override
  String get resetInstructionsSent =>
      'Enviamos instrucciones para restablecer la contraseña a tu email';

  @override
  String get dontWorryReset =>
      '¡No te preocupes! Ingresa tu email y te enviaremos un enlace para restablecer la contraseña';

  @override
  String get sendResetEmail => 'Enviar email de restablecimiento';

  @override
  String get checkEmailInstructions =>
      'Revisa tu email y haz clic en el enlace para restablecer la contraseña. Si no ves el email, revisa también la carpeta de spam.';

  @override
  String get backToLogin => 'Volver al Login';

  @override
  String get rememberPassword => '¿Recuerdas tu contraseña? ';

  @override
  String get saveErrorGeneric => 'Error al guardar';

  @override
  String get blockchainPowered => 'Impulsado por Blockchain';

  @override
  String get digitalCVTitle => 'Tu CV digital\nverificado en blockchain';

  @override
  String get digitalCVDescription =>
      'Crea, gestiona y comparte tu currículum vitae con la seguridad y autenticidad garantizadas por la tecnología blockchain.';

  @override
  String get mainFeatures => 'Características principales';

  @override
  String get blockchainVerification => 'Verificación Blockchain';

  @override
  String get blockchainVerificationDesc =>
      'Tus datos son inmutables y verificables en la blockchain';

  @override
  String get secureSharing => 'Compartir Seguro';

  @override
  String get secureSharingDesc =>
      'Comparte tu CV con un enlace seguro y rastreable';

  @override
  String get realTimeUpdates => 'Actualizaciones en Tiempo Real';

  @override
  String get realTimeUpdatesDesc =>
      'Edita y actualiza tu CV en cualquier momento';

  @override
  String get jetcvInNumbers => 'JetCV en números';

  @override
  String get cvsCreated => 'CVs Creados';

  @override
  String get activeUsers => 'Usuarios Activos';

  @override
  String get security => 'Seguridad';

  @override
  String get readyToStart => '¿Listo para empezar?';

  @override
  String get createFirstCV =>
      'Crea tu primer CV digital en blockchain en solo unos minutos';

  @override
  String get createYourCV => 'Crea tu CV';

  @override
  String get signInToYourAccount => 'Inicia sesión en tu cuenta';

  @override
  String get shareCV => 'Compartir CV';

  @override
  String get shareText => 'Compartir';

  @override
  String get cvLanguage => 'Idioma visualización CV';

  @override
  String get personalInfo => 'Información Personal';

  @override
  String get age => 'edad';

  @override
  String get contactInfo => 'Información de Contacto';

  @override
  String get languages => 'Idiomas';

  @override
  String get skills => 'Habilidades';

  @override
  String get attitudes => 'Actitudes';

  @override
  String get languagesPlaceholder =>
      'Tus competencias lingüísticas se mostrarán aquí';

  @override
  String get attitudesPlaceholder =>
      'Tus actitudes y habilidades blandas se mostrarán aquí';

  @override
  String get cvShared => '¡Enlace del CV copiado al portapapeles!';

  @override
  String shareError(Object error) {
    return 'Error al compartir: $error';
  }

  @override
  String get years => 'años';

  @override
  String get born => 'nacido';

  @override
  String get bornFemale => 'nacida';

  @override
  String get blockchainCertified => 'Certificado Blockchain';

  @override
  String get cvSerial => 'Serial CV';

  @override
  String get serialCode => 'Código serie';

  @override
  String get verifiedCV => 'CV Verificado';

  @override
  String get autodichiarazioni => 'Autodeclaraciones';

  @override
  String get spokenLanguages => 'Idiomas hablados:';

  @override
  String get noLanguageSpecified => 'Ningún idioma especificado';

  @override
  String get certifications => 'Certificaciones';

  @override
  String get mostRecent => 'Más Recientes';

  @override
  String get lessRecent => 'Less Recent';

  @override
  String get verifiedCertifications => 'certificaciones verificadas';

  @override
  String get loadingCertifications => 'Cargando certificaciones...';

  @override
  String get errorLoadingCertifications =>
      'Error al cargar las certificaciones';

  @override
  String get retry => 'Reintentar';

  @override
  String get noCvAvailable => 'No hay CV disponible';

  @override
  String get errorLoadingCv => 'Error al cargar el CV';

  @override
  String get createYourFirstCv => 'Crea tu primer CV para comenzar';

  @override
  String get noCertificationsFound => 'No se encontraron certificaciones';

  @override
  String get yourVerifiedCertifications =>
      'Tus certificaciones verificadas aparecerán aquí';

  @override
  String get certification => 'Certificación';

  @override
  String get certifyingBody => 'Entidad Certificadora';

  @override
  String get status => 'Estado';

  @override
  String get serial => 'Serial';

  @override
  String get verifiedAndAuthenticated =>
      'Certificación verificada y autenticada';

  @override
  String get approved => 'Aprobada';

  @override
  String get verified => 'Verificada';

  @override
  String get completed => 'Completada';

  @override
  String get pending => 'Pendiente';

  @override
  String get inProgress => 'En Progreso';

  @override
  String get rejected => 'Rechazada';

  @override
  String get failed => 'Fallida';

  @override
  String get nationality => 'Nacionalidad';

  @override
  String get noNationalitySpecified => 'Ninguna nacionalidad especificada';

  @override
  String get cvLinkCopied =>
      '¡Enlace del CV copiado al portapapeles! Compártelo ahora.';

  @override
  String errorChangingLanguage(String error) {
    return 'Error al cambiar idioma: $error';
  }

  @override
  String get projectManagement => 'GESTIÓN\nPROYECTOS';

  @override
  String get flutterDevelopment => 'DESARROLLO\nFLUTTER';

  @override
  String get certified => 'CERTIFICADO';

  @override
  String get myProfile => 'Mi Perfil';

  @override
  String get myCV => 'Mi CV';

  @override
  String get myCertifications => 'Mis Certificaciones';

  @override
  String get otp => 'OTP';

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
  String get activeOtps => 'OTPs Activos';

  @override
  String get noOtpsFound => 'No OTPs found';

  @override
  String get noOtpsFoundDescription => 'No OTPs match the selected filter';

  @override
  String get deleteAccount => 'Eliminar Cuenta';

  @override
  String get logout => 'Salir';

  @override
  String get otpVerification => 'Verificación OTP';

  @override
  String get otpDescription =>
      'Ingresa el código de 6 dígitos enviado a tu email registrado';

  @override
  String get enterOTP => 'Ingresa el código OTP';

  @override
  String get verifyOTP => 'Verificar OTP';

  @override
  String get resendOTP => 'Reenviar OTP';

  @override
  String get otpVerified => '¡OTP verificado exitosamente!';

  @override
  String get invalidOTP => 'Código OTP inválido. Inténtalo de nuevo.';

  @override
  String get otpVerificationError =>
      'Error al verificar OTP. Inténtalo de nuevo.';

  @override
  String get otpResent => 'El código OTP ha sido reenviado a tu email';

  @override
  String get otpResendError => 'Error al reenviar OTP. Inténtalo de nuevo.';

  @override
  String get securityInfo => 'Información de Seguridad';

  @override
  String get otpSecurityNote =>
      'Por tu seguridad, este código OTP expirará en 10 minutos. No compartas este código con nadie.';

  @override
  String get myOtps => 'Mis OTPs';

  @override
  String get permanentOtpCodes => 'Códigos OTP Permanentes';

  @override
  String get manageSecureAccessCodes =>
      'Gestiona tus códigos de acceso seguros';

  @override
  String get noOtpGenerated => 'Ningún OTP Generado';

  @override
  String get createFirstOtpDescription =>
      'Crea tu primer código OTP permanente para acceder de forma segura a la plataforma.';

  @override
  String get generateFirstOtp => 'Generar Primer OTP';

  @override
  String get newOtp => 'Nuevo OTP';

  @override
  String get addOptionalTagDescription =>
      'Añade una etiqueta opcional para identificar este OTP:';

  @override
  String get tagOptional => 'Etiqueta (opcional)';

  @override
  String get generateOtp => 'Generar OTP';

  @override
  String get createdNow => 'Creado ahora';

  @override
  String createdMinutesAgo(int minutes) {
    return 'Creado hace $minutes minutos';
  }

  @override
  String createdHoursAgo(int hours) {
    return 'Creado hace $hours horas';
  }

  @override
  String createdDaysAgo(int days) {
    return 'Creado hace $days días';
  }

  @override
  String get copy => 'Copiar';

  @override
  String get qrCode => 'Código QR';

  @override
  String get deleteOtp => 'Eliminar OTP';

  @override
  String get deleteOtpConfirmation =>
      '¿Estás seguro de que quieres eliminar este OTP?';

  @override
  String get delete => 'Eliminar';

  @override
  String get otpCodeCopied => '¡Código OTP copiado al portapapeles!';

  @override
  String get qrCodeOtp => 'Código QR OTP';

  @override
  String get qrCodeFor => 'Código QR para';

  @override
  String get close => 'Cerrar';

  @override
  String errorDuringLogout(String error) {
    return 'Error durante el cierre de sesión: $error';
  }

  @override
  String get accountDeletionNotImplemented =>
      'Eliminación de cuenta aún no implementada';

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
  String get userNotLoaded => 'Usuario no cargado';

  @override
  String get trainingCourse => 'Curso de Entrenamiento';

  @override
  String otpNumber(int number) {
    return 'OTP #$number';
  }

  @override
  String get certifier => 'Certificador';

  @override
  String get attachedMedia => 'Medios Adjuntos';

  @override
  String attachedMediaCount(int count) {
    return 'Medios Adjuntos ($count)';
  }

  @override
  String get documentationAndRelatedContent =>
      'Documentación y contenido relacionado';

  @override
  String get mediaDividedInfo =>
      'Los medios están divididos entre contenido genérico de certificación y documentos específicos de tu trayectoria.';

  @override
  String get genericMedia => 'Medios de Contexto';

  @override
  String get didacticMaterialAndOfficialDocumentation =>
      'Material didáctico y documentación oficial';

  @override
  String get personalMedia => 'Medios Certificativos';

  @override
  String get documentsAndContentOfYourCertificationPath =>
      'Documentos y contenido de tu trayectoria de certificación';

  @override
  String get realTime => 'TIEMPO REAL';

  @override
  String get uploadedInRealtime => 'subido en tiempo real';

  @override
  String get uploaded => 'SUBIDO';

  @override
  String get view => 'Ver';

  @override
  String get download => 'Descargar';

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
  String get errorOpeningLinkedIn => 'Error al abrir LinkedIn';

  @override
  String get addCertificationsToLinkedIn => 'Add Certification to LinkedIn';

  @override
  String get nftLink => 'Link Blockchain';

  @override
  String get errorOpeningNftLink => 'Error opening NFT link';

  @override
  String get viewBlockchainDetails => 'Ver detalles de la blockchain';

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
  String get openBadgeCreated => 'Open Badge Creado';

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
      'Credenciales digitales y logros';

  @override
  String get importYourOpenBadges => 'Importa tus Open Badges';

  @override
  String get showcaseYourDigitalCredentials =>
      'Muestra tus credenciales digitales y logros';

  @override
  String get languageName_en => 'Inglés';

  @override
  String get languageName_it => 'Italiano';

  @override
  String get languageName_fr => 'Francés';

  @override
  String get languageName_es => 'Español';

  @override
  String get languageName_de => 'Alemán';

  @override
  String get languageName_pt => 'Portugués';

  @override
  String get languageName_ru => 'Ruso';

  @override
  String get languageName_zh => 'Chino';

  @override
  String get languageName_ja => 'Japonés';

  @override
  String get languageName_ko => 'Coreano';

  @override
  String get languageName_ar => 'Árabe';

  @override
  String get languageName_hi => 'Hindi';

  @override
  String get languageName_tr => 'Turco';

  @override
  String get languageName_pl => 'Polaco';

  @override
  String get languageName_nl => 'Holandés';

  @override
  String get countryName_IT => 'Italia';

  @override
  String get countryName_FR => 'Francia';

  @override
  String get countryName_DE => 'Alemania';

  @override
  String get countryName_ES => 'España';

  @override
  String get countryName_GB => 'Reino Unido';

  @override
  String get countryName_US => 'Estados Unidos';

  @override
  String get countryName_CA => 'Canadá';

  @override
  String get countryName_AU => 'Australia';

  @override
  String get countryName_JP => 'Japón';

  @override
  String get countryName_CN => 'China';

  @override
  String get countryName_BR => 'Brasil';

  @override
  String get countryName_IN => 'India';

  @override
  String get countryName_RU => 'Rusia';

  @override
  String get countryName_MX => 'México';

  @override
  String get countryName_AR => 'Argentina';

  @override
  String get countryName_NL => 'Países Bajos';

  @override
  String get countryName_CH => 'Suiza';

  @override
  String get countryName_AT => 'Austria';

  @override
  String get countryName_BE => 'Bélgica';

  @override
  String get countryName_PT => 'Portugal';

  @override
  String get lastUpdate => 'Última actualización';

  @override
  String get certificationTitle => 'Título';

  @override
  String get certificationOutcome => 'Resultado';

  @override
  String get certificationDetails => 'Detalles';

  @override
  String get certType_attestato_di_frequenza => 'Certificado de asistencia';

  @override
  String get certType_certificato_di_competenza => 'Certificado de competencia';

  @override
  String get certType_diploma => 'Diploma';

  @override
  String get certType_laurea => 'Título universitario';

  @override
  String get certType_master => 'Máster';

  @override
  String get certType_corso_di_formazione => 'Curso de formación';

  @override
  String get certType_certificazione_professionale =>
      'Certificación profesional';

  @override
  String get certType_patente => 'Licencia';

  @override
  String get certType_abilitazione => 'Habilitación';

  @override
  String get serialNumber => 'Serie';

  @override
  String get noOtpsYet => 'Aún no hay OTPs';

  @override
  String get createYourFirstOtp => 'Crea tu primer OTP para comenzar';

  @override
  String get secureAccess => 'Acceso Seguro';

  @override
  String get secureAccessDescription =>
      'Códigos de acceso seguros y temporales';

  @override
  String get timeLimited => 'Expiración automática para mayor seguridad';

  @override
  String get timeLimitedDescription =>
      'Los códigos expiran automáticamente para garantizar la seguridad';

  @override
  String get qrCodeSupport => 'Soporte QR Code';

  @override
  String get qrCodeSupportDescription =>
      'Genera y comparte códigos QR para acceso rápido';

  @override
  String get otpCode => 'Código OTP';

  @override
  String get errorOccurred => 'Error';

  @override
  String get unknownError => 'Error desconocido';

  @override
  String get statusBurned => 'Quemado';

  @override
  String get statusUsed => 'Usado';

  @override
  String get statusExpired => 'Expirado';

  @override
  String get statusValid => 'Válido';

  @override
  String get databaseConnectionFailed => 'Conexión a la base de datos falló';

  @override
  String get edgeFunctionNotAccessible => 'Edge Function no accesible';

  @override
  String get preparingLinkedIn => 'Preparando LinkedIn...';

  @override
  String get name => 'Nombre';

  @override
  String get issuer => 'Emisor';

  @override
  String get downloadingMedia => 'Descargando media...';

  @override
  String get mediaDownloadedSuccessfully => 'Media descargado exitosamente';

  @override
  String get errorDownloadingMedia => 'Error descargando media';

  @override
  String get errorCreatingOpenBadge => 'Error creando Open Badge';

  @override
  String get issueDate => 'Fecha de emisión';

  @override
  String get yourOpenBadgeCreatedSuccessfully =>
      '¡Tu Open Badge ha sido creado exitosamente!';

  @override
  String get badge => 'Badge';

  @override
  String get filesSavedTo => 'Archivos guardados en';

  @override
  String get connectionTestResults => 'Resultados de Prueba de Conexión';

  @override
  String get createOtp => 'Crear OTP';

  @override
  String get testConnection => 'Probar Conexión';

  @override
  String get cleanupExpired => 'Limpiar Expirados';

  @override
  String get refresh => 'Actualizar';

  @override
  String get noOtpsAvailable => 'No hay OTPs disponibles';

  @override
  String get codeCopiedToClipboard => '¡Código copiado al portapapeles!';

  @override
  String get openBadges => 'Open Badges';

  @override
  String get badges => 'insignias';

  @override
  String get loadingOpenBadges => 'Cargando Open Badges...';

  @override
  String get errorLoadingOpenBadges => 'Error al cargar Open Badges';

  @override
  String get noOpenBadgesFound => 'No se encontraron Open Badges';

  @override
  String get noOpenBadgesDescription =>
      'Importa tu primer OpenBadge para comenzar';

  @override
  String get importOpenBadge => 'Importar OpenBadge';

  @override
  String get valid => 'Válido';

  @override
  String get invalid => 'Inválido';

  @override
  String get revoked => 'Revocado';

  @override
  String get source => 'Fuente (opcional)';

  @override
  String get note => 'Nota (opcional)';

  @override
  String get import => 'Importar';

  @override
  String get viewAll => 'Ver todo';

  @override
  String get pendingCertifications => 'Certificaciones pendientes';

  @override
  String get approvedCertifications => 'Certificaciones aprobadas';

  @override
  String get rejectedCertifications => 'Certificaciones rechazadas';

  @override
  String get pendingShort => 'Pendientes';

  @override
  String get approvedShort => 'Aprobadas';

  @override
  String get rejectedShort => 'Rechazadas';

  @override
  String get approve => 'Aprobar';

  @override
  String get reject => 'Rechazar';

  @override
  String get confirmRejection => 'Confirmar rechazo';

  @override
  String get rejectCertificationMessage =>
      '¿Está seguro de que desea rechazar esta certificación?';

  @override
  String get rejectionReason => 'Motivo del rechazo (opcional)';

  @override
  String get enterRejectionReason => 'Ingrese el motivo del rechazo...';

  @override
  String get confirmReject => 'Confirmar rechazo';

  @override
  String get certificationApproved => '¡Certificación aprobada con éxito!';

  @override
  String get certificationRejected => 'Certificación rechazada';

  @override
  String errorApprovingCertification(String error) {
    return 'Error al aprobar la certificación: $error';
  }

  @override
  String errorRejectingCertification(String error) {
    return 'Error al rechazar la certificación: $error';
  }

  @override
  String get createdOn => 'Creado el';

  @override
  String get rejectedReason => 'Motivo del rechazo:';

  @override
  String get noRejectionReason => 'No se especificó motivo';

  @override
  String get blockchainCertificate => 'Certificado Blockchain';

  @override
  String get verifiedOnPolygonNetwork => 'Verificado en la red Polygon';

  @override
  String get transactionInformation => 'Información de transacción';

  @override
  String get transactionId => 'ID de transacción';

  @override
  String get network => 'Red';

  @override
  String get blockHeight => 'Altura del bloque';

  @override
  String get gasUsed => 'Gas utilizado';

  @override
  String get nftInformation => 'Información NFT';

  @override
  String get tokenId => 'ID del token';

  @override
  String get contractAddress => 'Dirección del contrato';

  @override
  String get standard => 'Estándar';

  @override
  String get metadataUri => 'URI de metadatos';

  @override
  String get mintInformation => 'Información de acuñación';

  @override
  String get mintDate => 'Fecha de acuñación';

  @override
  String get minterAddress => 'Dirección del acuñador';

  @override
  String get mintPrice => 'Precio de acuñación';

  @override
  String get certificateStatus => 'Estado';

  @override
  String get confirmed => 'Confirmado';

  @override
  String get certificateDetails => 'Detalles del certificado';

  @override
  String get certificateName => 'Nombre del certificado';

  @override
  String get blockchainVerified => 'Verificado en blockchain';

  @override
  String get blockchainVerificationMessage =>
      'Este certificado ha sido verificado y almacenado en la red blockchain de Polygon.';

  @override
  String get viewOnPolygonExplorer => 'Ver en Polygon Explorer';

  @override
  String get polygon => 'Polygon';

  @override
  String get erc721 => 'ERC-721';

  @override
  String get cvCreationDate => 'Fecha de creación del CV';

  @override
  String get monthJan => 'Ene';

  @override
  String get monthFeb => 'Feb';

  @override
  String get monthMar => 'Mar';

  @override
  String get monthApr => 'Abr';

  @override
  String get monthMay => 'May';

  @override
  String get monthJun => 'Jun';

  @override
  String get monthJul => 'Jul';

  @override
  String get monthAug => 'Ago';

  @override
  String get monthSep => 'Sep';

  @override
  String get monthOct => 'Oct';

  @override
  String get monthNov => 'Nov';

  @override
  String get monthDec => 'Dic';

  @override
  String get certType_programma_certificato => 'Programa certificado';

  @override
  String get certType_dottorato_di_ricerca => 'Doctorado';

  @override
  String get certType_diploma_its => 'Diploma ITS';

  @override
  String get certType_workshop => 'Taller';

  @override
  String get certType_risultato_sportivo => 'Logro deportivo';

  @override
  String get certType_corso_specifico => 'Curso específico';

  @override
  String get certType_team_builder => 'Team builder';

  @override
  String get certType_corso_di_aggiornamento => 'Curso de actualización';

  @override
  String get certType_speech => 'Conferencia';

  @override
  String get certType_congresso => 'Congreso';

  @override
  String get certType_corso_specialistico => 'Curso especializado';

  @override
  String get certType_certificazione => 'Certificación';

  @override
  String get certType_moderatore => 'Moderador';

  @override
  String get certType_ruolo_professionale => 'Rol profesional';

  @override
  String get certType_volontariato => 'Voluntariado';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get resetPasswordTitle => 'Reset Your Password';

  @override
  String get resetPasswordDescription =>
      'Enter your email address and confirm with your old password to set a new password';

  @override
  String get enterEmailAddress => 'Enter Email Address';

  @override
  String get enterOldPassword => 'Enter Old Password';

  @override
  String get enterNewPassword => 'Enter New Password';

  @override
  String get confirmNewPassword => 'Confirm New Password';

  @override
  String get updatePassword => 'Update Password';

  @override
  String get updatingPassword => 'Updating Password...';

  @override
  String get passwordUpdatedSuccessfully => 'Password updated successfully!';

  @override
  String get passwordUpdateFailed => 'Failed to update password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get oldPasswordIncorrect => 'Old password is incorrect';

  @override
  String get newPasswordTooShort =>
      'New password must be at least 6 characters';

  @override
  String get oldPasswordRequired => 'Old password is required';

  @override
  String get newPasswordRequired => 'New password is required';

  @override
  String get confirmPasswordRequired => 'Password confirmation is required';

  @override
  String get passwordUpdateSuccess =>
      'Password updated successfully. Please log in with your new password.';

  @override
  String get passwordResetDescription =>
      'Enter your new password. Make sure it\'s secure and easy to remember';

  @override
  String get authenticationFailed => 'Authentication failed';

  @override
  String get updateFailed => 'Update failed';

  @override
  String get invalidCredentials => 'Invalid credentials';

  @override
  String get authenticationError => 'Authentication error';

  @override
  String get unexpectedError => 'Unexpected error';
}
