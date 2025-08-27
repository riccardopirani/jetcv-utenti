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
  String get dateOfBirth => 'Fecha de nacimiento (dd/mm/yyyy)';

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
}
