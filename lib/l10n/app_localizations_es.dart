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
  String get verifiedOnBlockchain => 'Cuenta verificada en blockchain';

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
  String get fullName => 'Nombre completo';

  @override
  String get enterFullName => 'Ingresa tu nombre completo';

  @override
  String get nameMinLength => 'El nombre debe tener al menos 2 caracteres';

  @override
  String get viewMyCV => 'Ver mi CV';

  @override
  String get copyLink => 'Copiar Enlace';

  @override
  String get share => 'Compartir';

  @override
  String get createSecurePassword => 'Crea una contraseña segura';

  @override
  String get passwordMinLength =>
      'La contraseña debe tener al menos 6 caracteres';

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
  String get verifiedCertifications => 'certificaciones verificadas';

  @override
  String get loadingCertifications => 'Cargando certificaciones...';

  @override
  String get errorLoadingCertifications =>
      'Error al cargar las certificaciones';

  @override
  String get retry => 'Reintentar';

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
  String get myWallets => 'Mis Wallets';

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
  String get activeOtps => 'OTPs Activos';

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
    return 'Creado hace ${minutes}min';
  }

  @override
  String createdHoursAgo(int hours) {
    return 'Creado hace ${hours}h';
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
  String get userNotLoaded => 'Usuario no cargado';

  @override
  String get trainingCourse => 'Curso de Entrenamiento';

  @override
  String otpNumber(int number) {
    return 'OTP #$number';
  }
}
