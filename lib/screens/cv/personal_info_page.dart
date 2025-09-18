import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jetcv__utenti/models/user_model.dart';
import 'package:jetcv__utenti/services/user_service.dart';
import 'package:jetcv__utenti/services/country_service.dart';
import 'package:jetcv__utenti/models/country_model.dart';
import 'package:jetcv__utenti/supabase/structure/enumerated_types.dart';
import 'package:jetcv__utenti/supabase/supabase_config.dart';
import 'package:image_picker/image_picker.dart';

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:jetcv__utenti/l10n/app_localizations.dart';

import 'package:jetcv__utenti/services/locale_service.dart';
import 'package:jetcv__utenti/widgets/main_layout.dart';
import 'package:jetcv__utenti/screens/authenticated_home_page.dart';

// Lista ridotta delle nazionalità più comuni
const Map<String, Map<String, String>> NATIONALITIES = {
  'it': {
    'it': 'Italiana',
    'fr': 'Francese',
    'de': 'Tedesca',
    'es': 'Spagnola',
    'pt': 'Portoghese',
    'en': 'Inglese',
    'us': 'Statunitense',
    'ca': 'Canadese',
    'au': 'Australiana',
    'gb': 'Britannica',
    'ie': 'Irlandese',
    'ch': 'Svizzera',
    'at': 'Austriaca',
    'be': 'Belga',
    'nl': 'Olandese',
    'dk': 'Danese',
    'se': 'Svedese',
    'no': 'Norvegese',
    'fi': 'Finlandese',
    'pl': 'Polacca',
    'cz': 'Ceca',
    'sk': 'Slovacca',
    'hu': 'Ungherese',
    'ro': 'Rumena',
    'bg': 'Bulgaro',
    'hr': 'Croata',
    'si': 'Slovena',
    'rs': 'Serba',
    'gr': 'Greca',
    'tr': 'Turca',
    'il': 'Israeliana',
    'ru': 'Russa',
    'ua': 'Ucraina',
    'cn': 'Cinese',
    'jp': 'Giapponese',
    'kr': 'Sudcoreana',
    'in': 'Indiana',
    'br': 'Brasiliana',
    'ar': 'Argentina',
    'mx': 'Messicana',
    'za': 'Sudafricana',
  },
  'en': {
    'it': 'Italian',
    'fr': 'French',
    'de': 'German',
    'es': 'Spanish',
    'pt': 'Portuguese',
    'en': 'English',
    'us': 'American',
    'ca': 'Canadian',
    'au': 'Australian',
    'gb': 'British',
    'ie': 'Irish',
    'ch': 'Swiss',
    'at': 'Austrian',
    'be': 'Belgian',
    'nl': 'Dutch',
    'dk': 'Danish',
    'se': 'Swedish',
    'no': 'Norwegian',
    'fi': 'Finnish',
    'pl': 'Polish',
    'cz': 'Czech',
    'sk': 'Slovak',
    'hu': 'Hungarian',
    'ro': 'Romanian',
    'bg': 'Bulgarian',
    'hr': 'Croatian',
    'si': 'Slovenian',
    'rs': 'Serbian',
    'gr': 'Greek',
    'tr': 'Turkish',
    'il': 'Israeli',
    'ru': 'Russian',
    'ua': 'Ukrainian',
    'cn': 'Chinese',
    'jp': 'Japanese',
    'kr': 'South Korean',
    'in': 'Indian',
    'br': 'Brazilian',
    'ar': 'Argentine',
    'mx': 'Mexican',
    'za': 'South African',
  },
  'es': {
    'it': 'Italiana',
    'fr': 'Francesa',
    'de': 'Alemana',
    'es': 'Española',
    'pt': 'Portuguesa',
    'en': 'Inglesa',
    'us': 'Estadounidense',
    'ca': 'Canadiense',
    'au': 'Australiana',
    'gb': 'Británica',
    'ie': 'Irlandesa',
    'ch': 'Suiza',
    'at': 'Austriaca',
    'be': 'Belga',
    'nl': 'Holandesa',
    'dk': 'Danesa',
    'se': 'Sueca',
    'no': 'Noruega',
    'fi': 'Finlandesa',
    'pl': 'Polaca',
    'cz': 'Checa',
    'sk': 'Eslovaca',
    'hu': 'Húngara',
    'ro': 'Rumana',
    'bg': 'Búlgara',
    'hr': 'Croata',
    'si': 'Eslovena',
    'rs': 'Serbia',
    'gr': 'Griega',
    'tr': 'Turca',
    'il': 'Israelí',
    'ru': 'Rusa',
    'ua': 'Ucraniana',
    'cn': 'China',
    'jp': 'Japonesa',
    'kr': 'Surcoreana',
    'in': 'India',
    'br': 'Brasileña',
    'ar': 'Argentina',
    'mx': 'Mexicana',
    'za': 'Sudafricana',
  },
  'fr': {
    'it': 'Italienne',
    'fr': 'Française',
    'de': 'Allemande',
    'es': 'Espagnole',
    'pt': 'Portugaise',
    'en': 'Anglaise',
    'us': 'Américaine',
    'ca': 'Canadienne',
    'au': 'Australienne',
    'gb': 'Britannique',
    'ie': 'Irlandaise',
    'ch': 'Suisse',
    'at': 'Autrichienne',
    'be': 'Belge',
    'nl': 'Néerlandaise',
    'dk': 'Danoise',
    'se': 'Suédoise',
    'no': 'Norvégienne',
    'fi': 'Finlandaise',
    'pl': 'Polonaise',
    'cz': 'Tchèque',
    'sk': 'Slovaque',
    'hu': 'Hongroise',
    'ro': 'Roumaine',
    'bg': 'Bulgare',
    'hr': 'Croate',
    'si': 'Slovène',
    'rs': 'Serbe',
    'gr': 'Grecque',
    'tr': 'Turque',
    'il': 'Israélienne',
    'ru': 'Russe',
    'ua': 'Ukrainienne',
    'cn': 'Chinoise',
    'jp': 'Japonaise',
    'kr': 'Sud-Coréenne',
    'in': 'Indienne',
    'br': 'Brésilienne',
    'ar': 'Argentine',
    'mx': 'Mexicaine',
    'za': 'Sud-Africaine',
  },
  'de': {
    'it': 'Italienisch',
    'fr': 'Französisch',
    'de': 'Deutsch',
    'es': 'Spanisch',
    'pt': 'Portugiesisch',
    'en': 'Englisch',
    'us': 'Amerikanisch',
    'ca': 'Kanadisch',
    'au': 'Australisch',
    'gb': 'Britisch',
    'ie': 'Irisch',
    'ch': 'Schweizerisch',
    'at': 'Österreichisch',
    'be': 'Belgisch',
    'nl': 'Niederländisch',
    'dk': 'Dänisch',
    'se': 'Schwedisch',
    'no': 'Norwegisch',
    'fi': 'Finnisch',
    'pl': 'Polnisch',
    'cz': 'Tschechisch',
    'sk': 'Slowakisch',
    'hu': 'Ungarisch',
    'ro': 'Rumänisch',
    'bg': 'Bulgarisch',
    'hr': 'Kroatisch',
    'si': 'Slowenisch',
    'rs': 'Serbisch',
    'gr': 'Griechisch',
    'tr': 'Türkisch',
    'il': 'Israelisch',
    'ru': 'Russisch',
    'ua': 'Ukrainisch',
    'cn': 'Chinesisch',
    'jp': 'Japanisch',
    'kr': 'Südkoreanisch',
    'in': 'Indisch',
    'br': 'Brasilianisch',
    'ar': 'Argentinisch',
    'mx': 'Mexikanisch',
    'za': 'Südafrikanisch',
  },
};

// Lista delle lingue più comuni con codici ISO 639-1 e emoji
const Map<String, Map<String, String>> LANGUAGES = {
  'it': {
    'it': '🇮🇹 Italiano',
    'en': '🇬🇧 Inglese',
    'fr': '🇫🇷 Francese',
    'de': '🇩🇪 Tedesco',
    'es': '🇪🇸 Spagnolo',
    'pt': '🇵🇹 Portoghese',
    'ru': '🇷🇺 Russo',
    'zh': '🇨🇳 Cinese',
    'ja': '🇯🇵 Giapponese',
    'ko': '🇰🇷 Coreano',
    'ar': '🇸🇦 Arabo',
    'hi': '🇮🇳 Hindi',
    'nl': '🇳🇱 Olandese',
    'sv': '🇸🇪 Svedese',
    'no': '🇳🇴 Norvegese',
    'da': '🇩🇰 Danese',
    'fi': '🇫🇮 Finlandese',
    'pl': '🇵🇱 Polacco',
    'cs': '🇨🇿 Ceco',
    'sk': '🇸🇰 Slovacco',
    'hu': '🇭🇺 Ungherese',
    'ro': '🇷🇴 Rumeno',
    'bg': '🇧🇬 Bulgaro',
    'hr': '🇭🇷 Croato',
    'sl': '🇸🇮 Sloveno',
    'sr': '🇷🇸 Serbo',
    'el': '🇬🇷 Greco',
    'tr': '🇹🇷 Turco',
    'he': '🇮🇱 Ebraico',
    'uk': '🇺🇦 Ucraino',
  },
  'en': {
    'it': '🇮🇹 Italian',
    'en': '🇬🇧 English',
    'fr': '🇫🇷 French',
    'de': '🇩🇪 German',
    'es': '🇪🇸 Spanish',
    'pt': '🇵🇹 Portuguese',
    'ru': '🇷🇺 Russian',
    'zh': '🇨🇳 Chinese',
    'ja': '🇯🇵 Japanese',
    'ko': '🇰🇷 Korean',
    'ar': '🇸🇦 Arabic',
    'hi': '🇮🇳 Hindi',
    'nl': '🇳🇱 Dutch',
    'sv': '🇸🇪 Swedish',
    'no': '🇳🇴 Norwegian',
    'da': '🇩🇰 Danish',
    'fi': '🇫🇮 Finnish',
    'pl': '🇵🇱 Polish',
    'cs': '🇨🇿 Czech',
    'sk': '🇸🇰 Slovak',
    'hu': '🇭🇺 Hungarian',
    'ro': '🇷🇴 Romanian',
    'bg': '🇧🇬 Bulgarian',
    'hr': '🇭🇷 Croatian',
    'sl': '🇸🇮 Slovenian',
    'sr': '🇷🇸 Serbian',
    'el': '🇬🇷 Greek',
    'tr': '🇹🇷 Turkish',
    'he': '🇮🇱 Hebrew',
    'uk': '🇺🇦 Ukrainian',
  },
  'es': {
    'it': '🇮🇹 Italiano',
    'en': '🇬🇧 Inglés',
    'fr': '🇫🇷 Francés',
    'de': '🇩🇪 Alemán',
    'es': '🇪🇸 Español',
    'pt': '🇵🇹 Portugués',
    'ru': '🇷🇺 Ruso',
    'zh': '🇨🇳 Chino',
    'ja': '🇯🇵 Japonés',
    'ko': '🇰🇷 Coreano',
    'ar': '🇸🇦 Árabe',
    'hi': '🇮🇳 Hindi',
    'nl': '🇳🇱 Holandés',
    'sv': '🇸🇪 Sueco',
    'no': '🇳🇴 Noruego',
    'da': '🇩🇰 Danés',
    'fi': '🇫🇮 Finlandés',
    'pl': '🇵🇱 Polaco',
    'cs': '🇨🇿 Checo',
    'sk': '🇸🇰 Eslovaco',
    'hu': '🇭🇺 Húngaro',
    'ro': '🇷🇴 Rumano',
    'bg': '🇧🇬 Búlgaro',
    'hr': '🇭🇷 Croata',
    'sl': '🇸🇮 Esloveno',
    'sr': '🇷🇸 Serbio',
    'el': '🇬🇷 Griego',
    'tr': '🇹🇷 Turco',
    'he': '🇮🇱 Hebreo',
    'uk': '🇺🇦 Ucraniano',
  },
  'fr': {
    'it': '🇮🇹 Italien',
    'en': '🇬🇧 Anglais',
    'fr': '🇫🇷 Français',
    'de': '🇩🇪 Allemand',
    'es': '🇪🇸 Espagnol',
    'pt': '🇵🇹 Portugais',
    'ru': '🇷🇺 Russe',
    'zh': '🇨🇳 Chinois',
    'ja': '🇯🇵 Japonais',
    'ko': '🇰🇷 Coréen',
    'ar': '🇸🇦 Arabe',
    'hi': '🇮🇳 Hindi',
    'nl': '🇳🇱 Néerlandais',
    'sv': '🇸🇪 Suédois',
    'no': '🇳🇴 Norvégien',
    'da': '🇩🇰 Danois',
    'fi': '🇫🇮 Finlandais',
    'pl': '🇵🇱 Polonais',
    'cs': '🇨🇿 Tchèque',
    'sk': '🇸🇰 Slovaque',
    'hu': '🇭🇺 Hongrois',
    'ro': '🇷🇴 Roumain',
    'bg': '🇧🇬 Bulgare',
    'hr': '🇭🇷 Croate',
    'sl': '🇸🇮 Slovène',
    'sr': '🇷🇸 Serbe',
    'el': '🇬🇷 Grec',
    'tr': '🇹🇷 Turc',
    'he': '🇮🇱 Hébreu',
    'uk': '🇺🇦 Ukrainien',
  },
  'de': {
    'it': '🇮🇹 Italienisch',
    'en': '🇬🇧 Englisch',
    'fr': '🇫🇷 Französisch',
    'de': '🇩🇪 Deutsch',
    'es': '🇪🇸 Spanisch',
    'pt': '🇵🇹 Portugiesisch',
    'ru': '🇷🇺 Russisch',
    'zh': '🇨🇳 Chinesisch',
    'ja': '🇯🇵 Japanisch',
    'ko': '🇰🇷 Koreanisch',
    'ar': '🇸🇦 Arabisch',
    'hi': '🇮🇳 Hindi',
    'nl': '🇳🇱 Niederländisch',
    'sv': '🇸🇪 Schwedisch',
    'no': '🇳🇴 Norwegisch',
    'da': '🇩🇰 Dänisch',
    'fi': '🇫🇮 Finnisch',
    'pl': '🇵🇱 Polnisch',
    'cs': '🇨🇿 Tschechisch',
    'sk': '🇸🇰 Slowakisch',
    'hu': '🇭🇺 Ungarisch',
    'ro': '🇷🇴 Rumänisch',
    'bg': '🇧🇬 Bulgarisch',
    'hr': '🇭🇷 Kroatisch',
    'sl': '🇸🇮 Slowenisch',
    'sr': '🇷🇸 Serbisch',
    'el': '🇬🇷 Griechisch',
    'tr': '🇹🇷 Türkisch',
    'he': '🇮🇱 Hebräisch',
    'uk': '🇺🇦 Ukrainisch',
  },
};

class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text;

    // Allow complete clearing
    if (text.isEmpty) {
      return TextEditingValue(
        text: '',
        selection: const TextSelection.collapsed(offset: 0),
      );
    }

    // Allow only digits and + at the beginning
    if (text.startsWith('+')) {
      // Keep the + and allow only digits after it
      String filtered =
          '+' + text.substring(1).replaceAll(RegExp(r'[^0-9]'), '');
      return TextEditingValue(
        text: filtered,
        selection: TextSelection.collapsed(offset: filtered.length),
      );
    } else {
      // Allow only digits
      String filtered = text.replaceAll(RegExp(r'[^0-9]'), '');
      return TextEditingValue(
        text: filtered,
        selection: TextSelection.collapsed(offset: filtered.length),
      );
    }
  }
}

class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text;

    // Allow only digits and slashes
    text = text.replaceAll(RegExp(r'[^0-9/]'), '');

    // Allow complete clearing
    if (text.isEmpty) {
      return TextEditingValue(
        text: '',
        selection: const TextSelection.collapsed(offset: 0),
      );
    }

    // Don't allow more than 10 characters (dd/mm/yyyy)
    if (text.length > 10) {
      return oldValue;
    }

    // Remove consecutive slashes
    text = text.replaceAll(RegExp(r'/+'), '/');

    // Don't allow slash at the beginning (but allow empty)
    if (text.startsWith('/') && text.length > 1) {
      return oldValue;
    }

    // If user is deleting and we have only "/" or ends with "/", allow it
    if (text == '/' || text.endsWith('/')) {
      // If we're going backwards (deleting), allow incomplete states
      if (newValue.text.length < oldValue.text.length) {
        return TextEditingValue(
          text: text,
          selection: TextSelection.collapsed(offset: text.length),
        );
      }
    }

    // Extract digits only for processing
    String digitsOnly = text.replaceAll('/', '');

    // If no digits, return empty
    if (digitsOnly.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // Build formatted string based on digits
    String formattedText = '';

    // Add day (first 2 digits)
    if (digitsOnly.isNotEmpty) {
      formattedText += digitsOnly.substring(
          0, digitsOnly.length >= 2 ? 2 : digitsOnly.length);

      // Add slash after day if we have more digits or if user typed one
      if (digitsOnly.length >= 2) {
        formattedText += '/';
      }
    }

    // Add month (next 2 digits)
    if (digitsOnly.length > 2) {
      int monthStart = 2;
      int monthEnd = digitsOnly.length >= 4 ? 4 : digitsOnly.length;
      formattedText += digitsOnly.substring(monthStart, monthEnd);

      // Add slash after month if we have more digits
      if (digitsOnly.length >= 4) {
        formattedText += '/';
      }
    }

    // Add year (remaining digits, up to 4)
    if (digitsOnly.length > 4) {
      int yearStart = 4;
      int yearEnd = digitsOnly.length >= 8 ? 8 : digitsOnly.length;
      formattedText += digitsOnly.substring(yearStart, yearEnd);
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

class TitleCaseInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text;

    // Allow complete clearing
    if (text.isEmpty) {
      return TextEditingValue(
        text: '',
        selection: const TextSelection.collapsed(offset: 0),
      );
    }

    // Apply title case formatting
    String formattedText = _toTitleCase(text);

    // Calculate cursor position after formatting
    int cursorOffset = newValue.selection.start;

    // If the text length changed due to formatting, adjust cursor position
    if (formattedText.length != text.length) {
      // Try to maintain cursor position relative to the text
      cursorOffset = cursorOffset.clamp(0, formattedText.length);
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: cursorOffset),
    );
  }

  String _toTitleCase(String text) {
    if (text.isEmpty) return text;

    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}

class PersonalInfoPage extends StatefulWidget {
  final UserModel? initialUser;

  const PersonalInfoPage({
    super.key,
    this.initialUser,
  });

  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage>
    with WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();

  // Controllers per i campi del form
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _dateOfBirthController = TextEditingController();

  // Variabili di stato
  UserModel? _currentUser;
  DateTime? _dateOfBirth;
  UserGender? _selectedGender;
  String? _selectedCountryCode;
  String? _profilePicture;
  dynamic _selectedImage; // XFile on web, File on mobile
  Uint8List? _selectedImageBytes; // For web compatibility
  bool _isUploadingImage = false; // Track upload state
  bool _isSaving = false;
  // Paese - NEW IMPLEMENTATION
  List<CountryModel> _countries = [];
  bool _showCountryDropdown = false;
  final TextEditingController _countrySearchController =
      TextEditingController();
  final FocusNode _countrySearchFocusNode = FocusNode();
  List<CountryModel> _filteredCountries = [];
  final ImagePicker _picker = ImagePicker();

  // Nazionalità
  // Nationality dropdown state - NEW IMPLEMENTATION WITH SEARCH
  List<String> _selectedNationalities = [];
  bool _showNationalityDropdown = false;
  final TextEditingController _nationalitySearchController =
      TextEditingController();
  final FocusNode _nationalitySearchFocusNode = FocusNode();
  List<String> _filteredNationalities = [];

  // Lingue parlate - NEW IMPLEMENTATION
  List<String> _selectedLanguages = [];
  bool _showLanguageDropdown = false;
  final TextEditingController _languageSearchController =
      TextEditingController();
  final FocusNode _languageSearchFocusNode = FocusNode();
  List<String> _filteredLanguages = [];

  // Lingua App (i18n) - NEW IMPLEMENTATION
  bool _showLanguageAppDropdown = false;
  final TextEditingController _languageAppSearchController =
      TextEditingController();
  final FocusNode _languageAppSearchFocusNode = FocusNode();
  List<Locale> _filteredLocalesApp = [];

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadCountries();

    // Listen for language changes to save languageCodeApp on-demand
    LocaleService.instance.addListener(_onLanguageChanged);

    // Listen for app lifecycle changes to refresh data when returning to foreground
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> _loadCurrentUser() async {
    try {
      _currentUser = await UserService.getCurrentUser();
      // Update form fields with fresh data from database
      if (_currentUser != null) {
        _populateFormFields(_currentUser!);
      }
    } catch (e) {
      debugPrint('Errore nel caricamento utente corrente: $e');
    }
  }

  /// Infer firstName and lastName from fullName if they are not set
  Map<String, String> _inferNamesFromFullName(UserModel user) {
    String firstName = user.firstName?.trim() ?? '';
    String lastName = user.lastName?.trim() ?? '';

    // If both firstName and lastName are empty but fullName exists, try to infer them
    if (firstName.isEmpty &&
        lastName.isEmpty &&
        user.fullName != null &&
        user.fullName!.trim().isNotEmpty) {
      final fullName = user.fullName!.trim();
      final nameParts =
          fullName.split(' ').where((part) => part.isNotEmpty).toList();

      if (nameParts.length >= 3) {
        // For names with 3+ parts (e.g., "Mario Rossi Bianchi" or "Maria De Luca")
        // Take first part as firstName and join the rest as lastName
        firstName = nameParts.first;
        lastName = nameParts.skip(1).join(' ');
      } else if (nameParts.length == 2) {
        // Standard case: "Mario Rossi"
        firstName = nameParts.first;
        lastName = nameParts.last;
      } else if (nameParts.length == 1) {
        // If only one part, use it as firstName
        firstName = nameParts.first;
        lastName = ''; // Keep lastName empty
      }

      // Apply title case formatting to inferred names
      firstName = _toTitleCase(firstName);
      lastName = _toTitleCase(lastName);
    }

    return {
      'firstName': firstName,
      'lastName': lastName,
    };
  }

  /// Check if form has been modified by user
  bool _hasFormBeenModified() {
    if (_currentUser == null) return false;

    // Check if any text field has been modified
    final inferredNames = _inferNamesFromFullName(_currentUser!);

    return _firstNameController.text != (inferredNames['firstName'] ?? '') ||
        _lastNameController.text != (inferredNames['lastName'] ?? '') ||
        _emailController.text != (_currentUser!.email ?? '') ||
        _phoneController.text != (_currentUser!.phone ?? '') ||
        _addressController.text != (_currentUser!.address ?? '') ||
        _cityController.text != (_currentUser!.city ?? '') ||
        _stateController.text != (_currentUser!.state ?? '') ||
        _postalCodeController.text != (_currentUser!.postalCode ?? '') ||
        _selectedGender != _currentUser!.gender ||
        _selectedCountryCode != (_currentUser!.countryCode ?? 'it') ||
        _selectedNationalities
            .toSet()
            .difference((_currentUser!.nationalityCodes ?? []).toSet())
            .isNotEmpty ||
        _selectedLanguages
            .toSet()
            .difference((_currentUser!.languageCodes ?? []).toSet())
            .isNotEmpty ||
        _selectedImage != null ||
        _selectedImageBytes != null;
  }

  /// Check if this is the initial load (all text controllers are empty)
  bool _isInitialLoad() {
    return _firstNameController.text.isEmpty &&
        _lastNameController.text.isEmpty &&
        _emailController.text.isEmpty &&
        _phoneController.text.isEmpty &&
        _addressController.text.isEmpty &&
        _cityController.text.isEmpty &&
        _stateController.text.isEmpty &&
        _postalCodeController.text.isEmpty &&
        _dateOfBirthController.text.isEmpty;
  }

  /// Populate form fields with user data only if not modified by user
  void _populateFormFields(UserModel user, {bool forceUpdate = false}) {
    if (mounted) {
      // Always allow initial population, even if it would be considered "modified"
      final isInitialLoad = _isInitialLoad();

      // Don't overwrite user's input unless explicitly forced or it's the initial load
      if (!forceUpdate && !isInitialLoad && _hasFormBeenModified()) {
        // Only update non-text fields and internal state
        setState(() {
          _currentUser = user;
          // Update profile picture if not changed by user
          if (_selectedImage == null && _selectedImageBytes == null) {
            _profilePicture = user.profilePicture;
          }
        });
        return;
      }

      setState(() {
        // Infer names from fullName if needed
        final inferredNames = _inferNamesFromFullName(user);

        // Basic info - update on initial load, when empty, or when forced
        if (forceUpdate || isInitialLoad || _firstNameController.text.isEmpty) {
          _firstNameController.text = inferredNames['firstName']!;
        }
        if (forceUpdate || isInitialLoad || _lastNameController.text.isEmpty) {
          _lastNameController.text = inferredNames['lastName']!;
        }
        if (forceUpdate || isInitialLoad || _emailController.text.isEmpty) {
          _emailController.text = user.email ?? '';
        }
        if (forceUpdate || isInitialLoad || _phoneController.text.isEmpty) {
          _phoneController.text = user.phone ?? '';
        }

        // Address info - update on initial load, when empty, or when forced
        if (forceUpdate || isInitialLoad || _addressController.text.isEmpty) {
          _addressController.text = user.address ?? '';
        }
        if (forceUpdate || isInitialLoad || _cityController.text.isEmpty) {
          _cityController.text = user.city ?? '';
        }
        if (forceUpdate || isInitialLoad || _stateController.text.isEmpty) {
          _stateController.text = user.state ?? '';
        }
        if (forceUpdate ||
            isInitialLoad ||
            _postalCodeController.text.isEmpty) {
          _postalCodeController.text = user.postalCode ?? '';
        }

        // Other fields - always update these as they don't conflict with user input
        _selectedGender = _selectedGender ?? user.gender;
        _selectedCountryCode = _selectedCountryCode ?? user.countryCode ?? 'it';
        _dateOfBirth = _dateOfBirth ?? user.dateOfBirth;

        if ((forceUpdate ||
                isInitialLoad ||
                _dateOfBirthController.text.isEmpty) &&
            user.dateOfBirth != null) {
          _dateOfBirthController.text =
              '${user.dateOfBirth!.day.toString().padLeft(2, '0')}/${user.dateOfBirth!.month.toString().padLeft(2, '0')}/${user.dateOfBirth!.year}';
        }

        // Profile picture - only update if user hasn't selected a new one
        if (_selectedImage == null && _selectedImageBytes == null) {
          _profilePicture = user.profilePicture;
        }

        // Multi-select fields - update on initial load, when empty, or when forced
        if (forceUpdate || isInitialLoad || _selectedNationalities.isEmpty) {
          _selectedNationalities = user.nationalityCodes ?? [];
        }
        if (forceUpdate || isInitialLoad || _selectedLanguages.isEmpty) {
          _selectedLanguages = user.languageCodes ?? [];
        }

        // Always update current user reference
        _currentUser = user;

        // Always initialize filters for dropdowns
        _initializeNationalityFilter();
        _initializeLanguageFilter();
      });
    }
  }

  /// Refresh data from database
  Future<void> _refreshData() async {
    await _loadCurrentUser();
  }

  /// Refresh data with user confirmation if form has been modified
  Future<void> _refreshDataWithConfirmation() async {
    if (_hasFormBeenModified()) {
      // Show confirmation dialog
      final shouldRefresh = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Conferma aggiornamento'),
            content: const Text(
                'L\'aggiornamento cancellerà le modifiche non salvate. Continuare?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(AppLocalizations.of(context)!.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Aggiorna'),
              ),
            ],
          );
        },
      );

      if (shouldRefresh == true) {
        // Force update to overwrite user changes
        final user = await UserService.getCurrentUser();
        if (user != null && mounted) {
          _populateFormFields(user, forceUpdate: true);
        }
      }
    } else {
      // No changes, safe to refresh
      await _refreshData();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Only refresh data when app comes back to foreground if user hasn't made changes
    if (state == AppLifecycleState.resumed) {
      // Don't refresh if user has unsaved changes
      if (!_hasFormBeenModified()) {
        _refreshData();
      }
    }
  }

  /// Called when the app language changes to save languageCodeApp immediately
  void _onLanguageChanged() {
    _saveLanguageCodeApp();
    // Rebuild the UI to reflect language changes without resetting form data
    if (mounted) {
      setState(() {
        // This will trigger rebuild with new localized texts
        // Form data is preserved as we only update UI labels
      });
    }
  }

  /// Get localized text based on current locale
  String _getLocalizedText(String key) {
    final currentLanguage =
        LocaleService.instance.currentLocale?.languageCode ?? 'it';

    switch (key) {
      case 'nationality_section':
        switch (currentLanguage) {
          case 'it':
            return 'Nazionalità';
          case 'en':
            return 'Nationality';
          case 'es':
            return 'Nacionalidad';
          case 'fr':
            return 'Nationalité';
          case 'de':
            return 'Staatsangehörigkeit';
          default:
            return 'Nationality';
        }
      case 'nationality_label':
        switch (currentLanguage) {
          case 'it':
            return 'Nazionalità';
          case 'en':
            return 'Nationality';
          case 'es':
            return 'Nacionalidad';
          case 'fr':
            return 'Nationalité';
          case 'de':
            return 'Staatsangehörigkeit';
          default:
            return 'Nationality';
        }
      case 'select_nationality':
        switch (currentLanguage) {
          case 'it':
            return 'Seleziona nazionalità';
          case 'en':
            return 'Select nationalities';
          case 'es':
            return 'Seleccionar nacionalidades';
          case 'fr':
            return 'Sélectionner les nationalités';
          case 'de':
            return 'Staatsangehörigkeiten auswählen';
          default:
            return 'Select nationalities';
        }
      case 'search_nationality':
        switch (currentLanguage) {
          case 'it':
            return 'Cerca nazionalità...';
          case 'en':
            return 'Search nationality...';
          case 'es':
            return 'Buscar nacionalidad...';
          case 'fr':
            return 'Rechercher nationalité...';
          case 'de':
            return 'Staatsangehörigkeit suchen...';
          default:
            return 'Cerca nazionalità...';
        }
      case 'no_nationality_found':
        switch (currentLanguage) {
          case 'it':
            return 'Nessuna nazionalità trovata';
          case 'en':
            return 'No nationality found';
          case 'es':
            return 'No se encontró nacionalidad';
          case 'fr':
            return 'Aucune nationalité trouvée';
          case 'de':
            return 'Keine Staatsangehörigkeit gefunden';
          default:
            return 'Nessuna nazionalità trovata';
        }
      case 'search_languages':
        switch (currentLanguage) {
          case 'it':
            return 'Cerca lingue...';
          case 'en':
            return 'Search languages...';
          case 'es':
            return 'Buscar idiomas...';
          case 'fr':
            return 'Rechercher langues...';
          case 'de':
            return 'Sprachen suchen...';
          default:
            return 'Cerca lingue...';
        }
      case 'no_languages_found':
        switch (currentLanguage) {
          case 'it':
            return 'Nessuna lingua trovata';
          case 'en':
            return 'No languages found';
          case 'es':
            return 'No se encontraron idiomas';
          case 'fr':
            return 'Aucune langue trouvée';
          case 'de':
            return 'Keine Sprachen gefunden';
          default:
            return 'Nessuna lingua trovata';
        }
      default:
        return key; // fallback to key if not found
    }
  }

  /// Save languageCodeApp immediately when language changes
  Future<void> _saveLanguageCodeApp() async {
    try {
      final currentUser = await UserService.getCurrentUser();
      if (currentUser == null) return;

      final currentLanguageCode =
          LocaleService.instance.currentLocale?.languageCode ?? 'it';

      // Only save if the language actually changed
      if (currentUser.languageCodeApp != currentLanguageCode) {
        final updateData = {
          'languageCodeApp': currentLanguageCode,
        };

        // Call the updateUserProfile Edge Function
        final result = await UserService.updateUser(
          currentUser.idUser,
          updateData,
        );

        if (result['success'] == true) {
          debugPrint('✅ Language code saved: $currentLanguageCode');
        } else {
          debugPrint('⚠️ Failed to save language code: ${result['message']}');
        }
      }
    } catch (e) {
      debugPrint('❌ Error saving language code: $e');
    }
  }

  Future<void> _loadCountries() async {
    try {
      final countries = await CountryService.getAllCountries();
      setState(() {
        _countries = countries;
        _filteredCountries = countries;
      });
    } catch (e) {
      // Errore nel caricamento paesi gestito silenziosamente
    }
  }

  // NEW COUNTRY DROPDOWN FUNCTIONS - SINGLE SELECTION LIKE NATIONALITY
  void _toggleCountryDropdown() {
    setState(() {
      _showCountryDropdown = !_showCountryDropdown;
      if (_showCountryDropdown) {
        _initializeCountryFilter();
        // Set focus on search field when opening
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _countrySearchFocusNode.requestFocus();
        });
      }
    });
  }

  void _closeCountryDropdown() {
    setState(() {
      _showCountryDropdown = false;
    });
  }

  void _initializeCountryFilter() {
    _filteredCountries = _countries;
    _countrySearchController.clear();
  }

  void _filterCountries(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCountries = _countries;
      } else {
        _filteredCountries = _countries.where((country) {
          return country.name.toLowerCase().contains(query.toLowerCase()) ||
              country.code.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _selectCountry(CountryModel country) {
    setState(() {
      _selectedCountryCode = country.code;
      // Clear search text and reset filter after selection
      _countrySearchController.clear();
      _initializeCountryFilter();
    });

    // Close dropdown after selection
    _closeCountryDropdown();
  }

  // NEW NATIONALITY DROPDOWN FUNCTIONS
  void _toggleNationalityDropdown() {
    setState(() {
      _showNationalityDropdown = !_showNationalityDropdown;
      if (_showNationalityDropdown) {
        _initializeNationalityFilter();
        // Set focus on search field when opening
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _nationalitySearchFocusNode.requestFocus();
        });
      }
    });
  }

  void _closeNationalityDropdown() {
    setState(() {
      _showNationalityDropdown = false;
    });
  }

  void _initializeNationalityFilter() {
    final currentLanguage =
        LocaleService.instance.currentLocale?.languageCode ?? 'it';
    final nationalitiesForLanguage =
        NATIONALITIES[currentLanguage] ?? NATIONALITIES['it']!;
    _filteredNationalities = nationalitiesForLanguage.keys.toList();
    _nationalitySearchController.clear();
  }

  void _filterNationalities(String query) {
    final currentLanguage =
        LocaleService.instance.currentLocale?.languageCode ?? 'it';
    final nationalitiesForLanguage =
        NATIONALITIES[currentLanguage] ?? NATIONALITIES['it']!;

    setState(() {
      if (query.isEmpty) {
        _filteredNationalities = nationalitiesForLanguage.keys.toList();
      } else {
        _filteredNationalities = nationalitiesForLanguage.keys.where((code) {
          final name = nationalitiesForLanguage[code] ?? '';
          return name.toLowerCase().contains(query.toLowerCase()) ||
              code.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _toggleNationality(String nationalityCode) {
    setState(() {
      if (_selectedNationalities.contains(nationalityCode)) {
        _selectedNationalities.remove(nationalityCode);
      } else {
        _selectedNationalities.add(nationalityCode);
      }
      // Clear search text and reset filter after selection
      _nationalitySearchController.clear();
      _initializeNationalityFilter();
    });

    // Close dropdown after selection
    _closeNationalityDropdown();
  }

  // NEW LANGUAGE DROPDOWN FUNCTIONS - IDENTICAL TO NATIONALITY
  void _toggleLanguageDropdown() {
    setState(() {
      _showLanguageDropdown = !_showLanguageDropdown;
      if (_showLanguageDropdown) {
        _initializeLanguageFilter();
        // Set focus on search field when opening
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _languageSearchFocusNode.requestFocus();
        });
      }
    });
  }

  void _closeLanguageDropdown() {
    setState(() {
      _showLanguageDropdown = false;
    });
  }

  void _initializeLanguageFilter() {
    final currentLanguage =
        LocaleService.instance.currentLocale?.languageCode ?? 'it';
    final languagesForLanguage = LANGUAGES[currentLanguage] ?? LANGUAGES['it']!;
    _filteredLanguages = languagesForLanguage.keys.toList();
    _languageSearchController.clear();
  }

  void _filterLanguages(String query) {
    final currentLanguage =
        LocaleService.instance.currentLocale?.languageCode ?? 'it';
    final languagesForLanguage = LANGUAGES[currentLanguage] ?? LANGUAGES['it']!;

    setState(() {
      if (query.isEmpty) {
        _filteredLanguages = languagesForLanguage.keys.toList();
      } else {
        _filteredLanguages = languagesForLanguage.keys.where((code) {
          final name = languagesForLanguage[code] ?? '';
          return name.toLowerCase().contains(query.toLowerCase()) ||
              code.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _toggleLanguage(String languageCode) {
    setState(() {
      if (_selectedLanguages.contains(languageCode)) {
        _selectedLanguages.remove(languageCode);
      } else {
        _selectedLanguages.add(languageCode);
      }
      // Clear search text and reset filter after selection
      _languageSearchController.clear();
      _initializeLanguageFilter();
    });

    // Close dropdown after selection
    _closeLanguageDropdown();
  }

  // NEW LANGUAGE APP DROPDOWN FUNCTIONS - SINGLE SELECTION LIKE COUNTRY
  void _toggleLanguageAppDropdown() {
    setState(() {
      _showLanguageAppDropdown = !_showLanguageAppDropdown;
      if (_showLanguageAppDropdown) {
        _initializeLanguageAppFilter();
        // Set focus on search field when opening
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _languageAppSearchFocusNode.requestFocus();
        });
      }
    });
  }

  void _closeLanguageAppDropdown() {
    setState(() {
      _showLanguageAppDropdown = false;
    });
  }

  void _initializeLanguageAppFilter() {
    _filteredLocalesApp = LocaleService.fullyTranslatedLocales;
    _languageAppSearchController.clear();
  }

  void _filterLanguageApp(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredLocalesApp = LocaleService.fullyTranslatedLocales;
      } else {
        _filteredLocalesApp =
            LocaleService.fullyTranslatedLocales.where((locale) {
          final displayName =
              LocaleService.instance.getLanguageName(locale.languageCode);
          return displayName.toLowerCase().contains(query.toLowerCase()) ||
              locale.languageCode.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _selectLanguageApp(Locale locale) {
    // Change the app language
    LocaleService.instance.setLocale(locale);

    setState(() {
      // Clear search text and reset filter after selection
      _languageAppSearchController.clear();
      _initializeLanguageAppFilter();
    });

    // Close dropdown after selection
    _closeLanguageAppDropdown();
  }

  @override
  void dispose() {
    // Remove language change listener
    LocaleService.instance.removeListener(_onLanguageChanged);

    // Remove app lifecycle observer
    WidgetsBinding.instance.removeObserver(this);

    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _dateOfBirthController.dispose();
    _countrySearchController.dispose();
    _countrySearchFocusNode.dispose();
    _nationalitySearchController.dispose();
    _nationalitySearchFocusNode.dispose();
    _languageSearchController.dispose();
    _languageSearchFocusNode.dispose();
    _languageAppSearchController.dispose();
    _languageAppSearchFocusNode.dispose();
    super.dispose();
  }

  String _toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  DateTime? _parseDateFromText(String text) {
    // Check if we have a complete date (dd/mm/yyyy format)
    if (text.length != 10) return null;

    final parts = text.split('/');
    if (parts.length != 3) return null;

    try {
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      // Basic validation
      if (day < 1 || day > 31) return null;
      if (month < 1 || month > 12) return null;
      if (year < 1900 || year > DateTime.now().year) return null;

      // More detailed date validation
      final date = DateTime(year, month, day);
      if (date.day != day || date.month != month || date.year != year) {
        return null; // Invalid date (e.g., 31/02/2000)
      }

      return date;
    } catch (e) {
      return null;
    }
  }

  void _onDateChanged(String value) {
    final parsedDate = _parseDateFromText(value);
    setState(() {
      _dateOfBirth = parsedDate;
    });
  }

  void _onEmailChanged(String value) {
    final lowercased = value.toLowerCase();
    if (lowercased != value) {
      final cursorPosition = _emailController.selection.start;
      _emailController.text = lowercased;
      // Mantieni la posizione del cursore
      _emailController.selection = TextSelection.collapsed(
        offset: cursorPosition.clamp(0, lowercased.length),
      );
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final localizations = AppLocalizations.of(context)!;

    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        // Validate file size (5MB max)
        final fileSizeBytes = await pickedFile.length();
        if (fileSizeBytes > 5 * 1024 * 1024) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(localizations.fileTooLarge),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        if (kIsWeb) {
          // On web, store the XFile and read bytes
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            _selectedImage = pickedFile;
            _selectedImageBytes = bytes;
          });
        } else {
          // On mobile, validate file format and store as File
          final file = File(pickedFile.path);
          final extension = pickedFile.path.toLowerCase().split('.').last;
          if (!['jpg', 'jpeg', 'png', 'webp'].contains(extension)) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(localizations.unsupportedFormat),
                  backgroundColor: Colors.red,
                ),
              );
            }
            return;
          }
          setState(() {
            _selectedImage = file;
            _selectedImageBytes = null;
          });
        }

        // Image selected successfully - will be uploaded when saving the page
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.imageSelectionError(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    final localizations = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations.selectPhoto),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text(localizations.takePhoto),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(localizations.chooseFromGallery),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(localizations.cancel),
            ),
          ],
        );
      },
    );
  }

  Future<void> _uploadProfilePicture() async {
    if (_selectedImageBytes == null || _currentUser?.idUser == null) return;

    final localizations = AppLocalizations.of(context)!;

    setState(() {
      _isUploadingImage = true;
    });

    try {
      late Uint8List fileBytes;
      late String fileName;
      late String contentType;

      if (kIsWeb) {
        fileBytes = _selectedImageBytes!;
        fileName =
            'profile_picture_${DateTime.now().millisecondsSinceEpoch}.jpg';
        contentType = 'image/jpeg';
      } else {
        fileBytes = await _selectedImage!.readAsBytes();
        fileName = _selectedImage!.path.split('/').last;

        // Determina il content type dal nome del file
        final extension = fileName.toLowerCase().split('.').last;
        switch (extension) {
          case 'png':
            contentType = 'image/png';
            break;
          case 'jpg':
          case 'jpeg':
            contentType = 'image/jpeg';
            break;
          case 'webp':
            contentType = 'image/webp';
            break;
          default:
            contentType = 'image/jpeg'; // Default fallback
        }
      }

      // Ottieni il token di autenticazione dal client Supabase
      final session = SupabaseConfig.client.auth.currentSession;
      if (session?.accessToken == null) {
        throw Exception('Sessione non valida');
      }

      // Prepara la richiesta multipart - verifica che l'edge function esista
      final uri = Uri.parse(
          '${SupabaseConfig.supabaseUrl}/functions/v1/updateUserProfilePicture');
      final request = http.MultipartRequest('POST', uri);

      // Aggiungi headers - solo token utente, non apikey anonima
      request.headers['Authorization'] = 'Bearer ${session!.accessToken}';

      // Aggiungi il file con il content type corretto
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: fileName,
          contentType: MediaType.parse(contentType),
        ),
      );

      // Invia la richiesta
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        if (data['success'] == true) {
          // Aggiorna l'URL della foto profilo nell'UI solo se non siamo in modalità salvataggio
          if (!_isSaving) {
            setState(() {
              _profilePicture = data['publicUrl'];
            });
            _showSnackBar(localizations.profilePictureUploaded);
          } else {
            // Durante il salvataggio, aggiorna solo l'URL senza mostrare messaggi
            _profilePicture = data['publicUrl'];
          }
        } else {
          throw Exception(
              data['message'] ?? 'Errore sconosciuto durante il caricamento');
        }
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData is Map<String, dynamic>
            ? errorData['message'] ??
                errorData['error'] ??
                'Errore ${response.statusCode}'
            : 'Errore ${response.statusCode}';
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (!_isSaving) {
        _showSnackBar(localizations.uploadError(e.toString()), isError: true);
      } else {
        // Durante il salvataggio, rilancia l'errore per essere gestito dalla funzione chiamante
        rethrow;
      }
    } finally {
      setState(() {
        _isUploadingImage = false;
      });
    }
  }

  Future<void> _savePersonalInfo() async {
    if (!_formKey.currentState!.validate()) return;

    final localizations = AppLocalizations.of(context)!;

    setState(() {
      _isSaving = true;
    });

    try {
      // Upload profile picture first if a new image was selected
      bool profilePictureUploadFailed = false;
      if (_selectedImage != null || _selectedImageBytes != null) {
        try {
          await _uploadProfilePicture();
          // Clear selected image data after successful upload
          _selectedImage = null;
          _selectedImageBytes = null;
        } catch (uploadError) {
          // Se l'upload della foto fallisce, mostra l'errore ma continua con il salvataggio
          profilePictureUploadFailed = true;
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    localizations.photoUploadError(uploadError.toString())),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 4),
              ),
            );
          }
          // Non fare return - continua con il salvataggio dei dati utente
        }
      }
      // Prepara i dati per l'aggiornamento
      final updateData = <String, dynamic>{};

      if (_firstNameController.text.isNotEmpty) {
        updateData['firstName'] =
            _toTitleCase(_firstNameController.text.trim());
      }
      if (_lastNameController.text.isNotEmpty) {
        updateData['lastName'] = _toTitleCase(_lastNameController.text.trim());
      }
      if (_emailController.text.isNotEmpty) {
        updateData['email'] = _emailController.text.trim().toLowerCase();
      }
      if (_phoneController.text.isNotEmpty) {
        updateData['phone'] = _phoneController.text.trim();
      }
      if (_addressController.text.isNotEmpty) {
        updateData['address'] = _toTitleCase(_addressController.text.trim());
      }
      if (_cityController.text.isNotEmpty) {
        updateData['city'] = _toTitleCase(_cityController.text.trim());
      }
      if (_stateController.text.isNotEmpty) {
        updateData['state'] = _toTitleCase(_stateController.text.trim());
      }
      if (_postalCodeController.text.isNotEmpty) {
        updateData['postalCode'] =
            _postalCodeController.text.trim().toUpperCase();
      }
      if (_dateOfBirth != null) {
        updateData['dateOfBirth'] =
            _dateOfBirth!.toIso8601String().split('T')[0];
      }
      if (_selectedGender != null) {
        updateData['gender'] = _selectedGender!.toDbString();
      }
      if (_selectedCountryCode != null) {
        updateData['countryCode'] = _selectedCountryCode;
      }
      if (_selectedNationalities.isNotEmpty) {
        updateData['nationalityCodes'] = _selectedNationalities;
      }

      if (_selectedLanguages.isNotEmpty) {
        updateData['languageCodes'] = _selectedLanguages;
      }

      // Profile picture update is handled by the Edge Function, so we don't pass it here

      // Ottieni l'utente corrente per l'ID
      final currentUser = await UserService.getCurrentUser();
      if (currentUser == null) {
        throw Exception('Utente non trovato');
      }

      // Aggiorna i dati tramite Edge Function
      final result =
          await UserService.updateUser(currentUser.idUser, updateData);

      if (mounted) {
        if (result['success'] == true) {
          // Personalizza il messaggio in base al successo dell'upload della foto
          final successMessage = profilePictureUploadFailed
              ? localizations.informationSavedWithPhotoError
              : localizations.informationSaved;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(successMessage),
              backgroundColor:
                  profilePictureUploadFailed ? Colors.orange : Colors.green,
              duration: Duration(seconds: profilePictureUploadFailed ? 5 : 3),
            ),
          );
          // Navigate to authenticated home page after successful save and force refresh
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const AuthenticatedHomePage(
                forceRefresh: true,
              ),
            ),
            (route) => false,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ??
                  result['error'] ??
                  localizations.saveErrorGeneric),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.saveError(e.toString())),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentRoute: '/profile',
      title: AppLocalizations.of(context)!.personalInformation,
      actions: [
        if (_isSaving)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
      ],
      child: GestureDetector(
        onTap: () {
          // Close country dropdown when tapping outside
          if (_showCountryDropdown) {
            setState(() {
              _showCountryDropdown = false;
            });
          }
          // Hide keyboard
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _refreshDataWithConfirmation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Intestazione
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.secondary,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.person_outline,
                                color: Colors.white,
                                size: 32,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)!.yourProfile,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    Text(
                                      AppLocalizations.of(context)!
                                          .enterYourPersonalInfo,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: Colors.white
                                                .withValues(alpha: 0.9),
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Foto profilo
                    Center(
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: _showImageSourceDialog,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(60),
                                border: Border.all(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .outline
                                      .withValues(alpha: 0.3),
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    spreadRadius: 2,
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(57),
                                child: _selectedImage != null
                                    ? (kIsWeb
                                        ? Image.memory(
                                            _selectedImageBytes!,
                                            width: 114,
                                            height: 114,
                                            fit: BoxFit.cover,
                                          )
                                        : Image.file(
                                            _selectedImage as File,
                                            width: 114,
                                            height: 114,
                                            fit: BoxFit.cover,
                                          ))
                                    : _profilePicture != null
                                        ? Image.network(
                                            _profilePicture!,
                                            width: 114,
                                            height: 114,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    Icon(
                                              Icons.person,
                                              size: 56,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                          )
                                        : Icon(
                                            Icons.person_add_alt_1,
                                            size: 56,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant
                                                .withValues(alpha: 0.6),
                                          ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextButton.icon(
                            onPressed: _isUploadingImage
                                ? null
                                : _showImageSourceDialog,
                            icon: _isUploadingImage
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : Icon(
                                    _selectedImage != null ||
                                            _profilePicture != null
                                        ? Icons.edit
                                        : Icons.add_a_photo,
                                  ),
                            label: Text(
                              _isUploadingImage
                                  ? AppLocalizations.of(context)!.uploading
                                  : _selectedImage != null ||
                                          _profilePicture != null
                                      ? AppLocalizations.of(context)!
                                          .replacePhoto
                                      : AppLocalizations.of(context)!.addPhoto,
                            ),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 8),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Sezione: Informazioni anagrafiche
                    _buildSectionHeader(
                        AppLocalizations.of(context)!.personalData),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: _buildTextFormField(
                            controller: _firstNameController,
                            label: AppLocalizations.of(context)!.firstName,
                            icon: Icons.person_outline,
                            textCapitalization: TextCapitalization.words,
                            inputFormatters: [TitleCaseInputFormatter()],
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return AppLocalizations.of(context)!
                                    .firstNameRequired;
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextFormField(
                            controller: _lastNameController,
                            label: AppLocalizations.of(context)!.lastName,
                            icon: Icons.person_outline,
                            textCapitalization: TextCapitalization.words,
                            inputFormatters: [TitleCaseInputFormatter()],
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return AppLocalizations.of(context)!
                                    .lastNameRequired;
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: _buildGenderDropdown(),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildDateField(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Sezione: Nazionalità
                    _buildSectionHeader(
                        _getLocalizedText('nationality_section')),
                    const SizedBox(height: 16),

                    _buildNewNationalityDropdown(),

                    const SizedBox(height: 16),

                    _buildNewLanguageDropdown(),

                    const SizedBox(height: 32),

                    // Sezione: Contatti
                    _buildSectionHeader(
                        AppLocalizations.of(context)!.contactInformation),
                    const SizedBox(height: 16),

                    _buildTextFormField(
                      controller: _emailController,
                      label: AppLocalizations.of(context)!.email,
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      textCapitalization: TextCapitalization.none,
                      onChanged: _onEmailChanged,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return AppLocalizations.of(context)!.emailRequired;
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(value!)) {
                          return AppLocalizations.of(context)!
                              .validEmailRequired;
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    _buildTextFormField(
                      controller: _phoneController,
                      label: AppLocalizations.of(context)!.phone,
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [PhoneInputFormatter()],
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return AppLocalizations.of(context)!.phoneRequired;
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 32),

                    // Sezione: Indirizzo
                    _buildSectionHeader(AppLocalizations.of(context)!.address),
                    const SizedBox(height: 16),

                    _buildTextFormField(
                      controller: _addressController,
                      label: AppLocalizations.of(context)!.address,
                      icon: Icons.home_outlined,
                      textCapitalization: TextCapitalization.words,
                      inputFormatters: [TitleCaseInputFormatter()],
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return AppLocalizations.of(context)!.addressRequired;
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: _buildTextFormField(
                            controller: _cityController,
                            label: AppLocalizations.of(context)!.city,
                            icon: Icons.location_city_outlined,
                            textCapitalization: TextCapitalization.words,
                            inputFormatters: [TitleCaseInputFormatter()],
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return AppLocalizations.of(context)!
                                    .cityRequired;
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextFormField(
                            controller: _stateController,
                            label: AppLocalizations.of(context)!.state,
                            icon: Icons.map_outlined,
                            textCapitalization: TextCapitalization.words,
                            inputFormatters: [TitleCaseInputFormatter()],
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return AppLocalizations.of(context)!
                                    .stateRequired;
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _postalCodeController,
                            keyboardType: TextInputType.text,
                            textCapitalization: TextCapitalization.characters,
                            textAlignVertical: TextAlignVertical.top,
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return AppLocalizations.of(context)!
                                    .postalCodeRequired;
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText:
                                  AppLocalizations.of(context)!.postalCode,
                              prefixIcon:
                                  const Icon(Icons.local_post_office_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .outline
                                      .withValues(alpha: 0.5),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildNewCountryDropdown(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // Sezione: Selezione Lingua
                    _buildNewLanguageAppDropdown(),

                    const SizedBox(height: 24),

                    // Pulsante di salvataggio
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _savePersonalInfo,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isSaving
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(AppLocalizations.of(context)!.saving),
                                ],
                              )
                            : Text(
                                AppLocalizations.of(context)!.saveInformation,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    TextCapitalization? textCapitalization,
    List<TextInputFormatter>? inputFormatters,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      textCapitalization: textCapitalization ?? TextCapitalization.none,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildGenderDropdown() {
    final localizations = AppLocalizations.of(context)!;

    return DropdownButtonFormField<UserGender>(
      value: _selectedGender,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: localizations.gender,
        prefixIcon: const Icon(Icons.person_outline),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
      ),
      items: UserGender.values.map((gender) {
        return DropdownMenuItem<UserGender>(
          value: gender,
          child: Text(
            gender.displayLabel,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedGender = value;
        });
      },
      validator: (value) {
        if (value == null) {
          return localizations.genderRequired;
        }
        return null;
      },
    );
  }

  Widget _buildDateField() {
    final localizations = AppLocalizations.of(context)!;

    return TextFormField(
      controller: _dateOfBirthController,
      keyboardType: TextInputType.number,
      inputFormatters: [DateInputFormatter()],
      onChanged: _onDateChanged,
      decoration: InputDecoration(
        labelText: localizations.dateOfBirth,
        hintText: 'es. 21/10/1955',
        prefixIcon: const Icon(Icons.date_range),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return localizations.validDateRequired;
        }

        // Check exact format dd/mm/yyyy
        final dateRegex = RegExp(r'^\d{2}/\d{2}/\d{4}$');
        if (!dateRegex.hasMatch(value)) {
          return localizations.dateFormatRequired;
        }

        final parts = value.split('/');
        if (parts.length != 3) {
          return localizations.dateFormatRequired;
        }

        // Validate ranges for dd, mm, yyyy
        final day = int.tryParse(parts[0]);
        final month = int.tryParse(parts[1]);
        final year = int.tryParse(parts[2]);

        if (day == null || month == null || year == null) {
          return localizations.invalidDate;
        }

        if (day < 1 || day > 31) {
          return localizations.invalidDay;
        }
        if (month < 1 || month > 12) {
          return localizations.invalidMonth;
        }
        if (year < 1900 || year > DateTime.now().year) {
          return localizations.invalidYear(DateTime.now().year);
        }

        final date = _parseDateFromText(value);
        if (date == null) {
          return localizations.inexistentDate;
        }

        return null;
      },
    );
  }

  // NEW COUNTRY DROPDOWN WITH SEARCH - SINGLE SELECTION LIKE NATIONALITY
  Widget _buildNewCountryDropdown() {
    // Find selected country to show in text field
    CountryModel? selectedCountry;
    if (_selectedCountryCode != null) {
      selectedCountry = _countries.firstWhere(
        (country) => country.code == _selectedCountryCode,
        orElse: () => CountryModel(
          code: '',
          name: '',
          createdAt: DateTime.now(),
          emoji: null,
        ),
      );
    }

    return TapRegion(
      onTapOutside: (event) {
        // Close dropdown when tapping outside the entire dropdown area
        if (_showCountryDropdown) {
          _closeCountryDropdown();
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main dropdown button
          GestureDetector(
            onTap: _toggleCountryDropdown,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .outline
                      .withValues(alpha: 0.5),
                ),
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(context).colorScheme.surface,
              ),
              child: Row(
                children: [
                  if (selectedCountry?.emoji != null) ...[
                    Text(
                      selectedCountry!.emoji!,
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 12),
                  ] else ...[
                    Icon(
                      Icons.flag,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.country,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          selectedCountry?.name ??
                              AppLocalizations.of(context)!.selectCountry,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _showCountryDropdown
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 20,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),

          // Expandable dropdown content
          if (_showCountryDropdown) ...[
            const SizedBox(height: 8),
            KeyboardListener(
              focusNode: FocusNode(),
              onKeyEvent: (event) {
                if (event is KeyDownEvent &&
                    event.logicalKey == LogicalKeyboardKey.escape) {
                  _closeCountryDropdown();
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .outline
                        .withValues(alpha: 0.5),
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: Theme.of(context).colorScheme.surface,
                ),
                child: Column(
                  children: [
                    // Search field
                    TextField(
                      controller: _countrySearchController,
                      focusNode: _countrySearchFocusNode,
                      onChanged: _filterCountries,
                      onSubmitted: (value) {
                        // Don't close on enter, allow user to continue searching
                      },
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.searchCountry,
                        prefixIcon: const Icon(Icons.search, size: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest
                            .withValues(alpha: 0.3),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Country list
                    SizedBox(
                      height: 250, // Fixed height for scrollable area
                      child: _filteredCountries.isEmpty
                          ? Center(
                              child: Text(
                                AppLocalizations.of(context)!.noCountryFound,
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: _filteredCountries.length,
                              itemBuilder: (context, index) {
                                final country = _filteredCountries[index];
                                final isSelected =
                                    country.code == _selectedCountryCode;

                                return InkWell(
                                  onTap: () => _selectCountry(country),
                                  borderRadius: BorderRadius.circular(8),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    child: Row(
                                      children: [
                                        if (country.emoji != null) ...[
                                          Text(
                                            country.emoji!,
                                            style:
                                                const TextStyle(fontSize: 20),
                                          ),
                                          const SizedBox(width: 12),
                                        ] else ...[
                                          Icon(
                                            Icons.flag,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 12),
                                        ],
                                        Expanded(
                                          child: Text(
                                            country.name,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  fontWeight: isSelected
                                                      ? FontWeight.w600
                                                      : FontWeight.normal,
                                                ),
                                          ),
                                        ),
                                        if (isSelected)
                                          Icon(
                                            Icons.check,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            size: 20,
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // NEW NATIONALITY DROPDOWN WITH SEARCH
  Widget _buildNewNationalityDropdown() {
    // Get current language for localization
    final currentLanguage =
        LocaleService.instance.currentLocale?.languageCode ?? 'it';
    final nationalitiesForLanguage =
        NATIONALITIES[currentLanguage] ?? NATIONALITIES['it']!;

    // Get selected nationality names
    final selectedNationalityNames = _selectedNationalities
        .map((code) => nationalitiesForLanguage[code] ?? code)
        .toList();

    return TapRegion(
      onTapOutside: (event) {
        // Close dropdown when tapping outside the entire dropdown area
        if (_showNationalityDropdown) {
          _closeNationalityDropdown();
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main dropdown button
          GestureDetector(
            onTap: _toggleNationalityDropdown,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .outline
                      .withValues(alpha: 0.5),
                ),
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(context).colorScheme.surface,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.public,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getLocalizedText('nationality_label'),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _selectedNationalities.isEmpty
                              ? _getLocalizedText('select_nationality')
                              : selectedNationalityNames.join(', '),
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _showNationalityDropdown
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 20,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),

          // Expandable dropdown content
          if (_showNationalityDropdown) ...[
            const SizedBox(height: 8),
            KeyboardListener(
              focusNode: FocusNode(),
              onKeyEvent: (event) {
                if (event is KeyDownEvent &&
                    event.logicalKey == LogicalKeyboardKey.escape) {
                  _closeNationalityDropdown();
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .outline
                        .withValues(alpha: 0.5),
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: Theme.of(context).colorScheme.surface,
                ),
                child: Column(
                  children: [
                    // Search field
                    TextField(
                      controller: _nationalitySearchController,
                      focusNode: _nationalitySearchFocusNode,
                      onChanged: _filterNationalities,
                      onSubmitted: (value) {
                        // Don't close on enter, allow user to continue searching
                      },
                      decoration: InputDecoration(
                        hintText: _getLocalizedText('search_nationality'),
                        prefixIcon: const Icon(Icons.search, size: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest
                            .withValues(alpha: 0.3),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Nationality list
                    SizedBox(
                      height: 250, // Fixed height for scrollable area
                      child: _filteredNationalities.isEmpty
                          ? Center(
                              child: Text(
                                _getLocalizedText('no_nationality_found'),
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: _filteredNationalities.length,
                              itemBuilder: (context, index) {
                                final code = _filteredNationalities[index];
                                final name =
                                    nationalitiesForLanguage[code] ?? code;
                                final isSelected =
                                    _selectedNationalities.contains(code);

                                return InkWell(
                                  onTap: () => _toggleNationality(code),
                                  borderRadius: BorderRadius.circular(8),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    child: Row(
                                      children: [
                                        Checkbox(
                                          value: isSelected,
                                          onChanged: (bool? value) {
                                            _toggleNationality(code);
                                          },
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            name,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  fontWeight: isSelected
                                                      ? FontWeight.w600
                                                      : FontWeight.normal,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ], // Close the if (_showNationalityDropdown) list
        ],
      ),
    );
  }

  // NEW LANGUAGE DROPDOWN WITH SEARCH - IDENTICAL TO NATIONALITY
  Widget _buildNewLanguageDropdown() {
    // Get current language for localization
    final currentLanguage =
        LocaleService.instance.currentLocale?.languageCode ?? 'it';
    final languagesForLanguage = LANGUAGES[currentLanguage] ?? LANGUAGES['it']!;

    // Get selected language names
    final selectedLanguageNames = _selectedLanguages
        .map((code) => languagesForLanguage[code] ?? code)
        .toList();

    return TapRegion(
      onTapOutside: (event) {
        // Close dropdown when tapping outside the entire dropdown area
        if (_showLanguageDropdown) {
          _closeLanguageDropdown();
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main dropdown button
          GestureDetector(
            onTap: _toggleLanguageDropdown,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .outline
                      .withValues(alpha: 0.5),
                ),
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(context).colorScheme.surface,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.language,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.languages,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _selectedLanguages.isEmpty
                              ? AppLocalizations.of(context)!.selectLanguage
                              : selectedLanguageNames.join(', '),
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _showLanguageDropdown
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 20,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),

          // Expandable dropdown content
          if (_showLanguageDropdown) ...[
            const SizedBox(height: 8),
            KeyboardListener(
              focusNode: FocusNode(),
              onKeyEvent: (event) {
                if (event is KeyDownEvent &&
                    event.logicalKey == LogicalKeyboardKey.escape) {
                  _closeLanguageDropdown();
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .outline
                        .withValues(alpha: 0.5),
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: Theme.of(context).colorScheme.surface,
                ),
                child: Column(
                  children: [
                    // Search field
                    TextField(
                      controller: _languageSearchController,
                      focusNode: _languageSearchFocusNode,
                      onChanged: _filterLanguages,
                      onSubmitted: (value) {
                        // Don't close on enter, allow user to continue searching
                      },
                      decoration: InputDecoration(
                        hintText: _getLocalizedText('search_languages'),
                        prefixIcon: const Icon(Icons.search, size: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest
                            .withValues(alpha: 0.3),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Language list
                    SizedBox(
                      height: 250, // Fixed height for scrollable area
                      child: _filteredLanguages.isEmpty
                          ? Center(
                              child: Text(
                                _getLocalizedText('no_languages_found'),
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: _filteredLanguages.length,
                              itemBuilder: (context, index) {
                                final code = _filteredLanguages[index];
                                final name = languagesForLanguage[code] ?? code;
                                final isSelected =
                                    _selectedLanguages.contains(code);

                                return InkWell(
                                  onTap: () => _toggleLanguage(code),
                                  borderRadius: BorderRadius.circular(8),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    child: Row(
                                      children: [
                                        Checkbox(
                                          value: isSelected,
                                          onChanged: (bool? value) {
                                            _toggleLanguage(code);
                                          },
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            name,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  fontWeight: isSelected
                                                      ? FontWeight.w600
                                                      : FontWeight.normal,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // NEW LANGUAGE APP DROPDOWN WITH SEARCH - SINGLE SELECTION LIKE COUNTRY
  Widget _buildNewLanguageAppDropdown() {
    // Get current locale
    final currentLocale = LocaleService.instance.currentLocale;
    final currentDisplayName = currentLocale != null
        ? LocaleService.instance.getLanguageName(currentLocale.languageCode)
        : AppLocalizations.of(context)!.selectLanguage;

    return TapRegion(
      onTapOutside: (event) {
        // Close dropdown when tapping outside the entire dropdown area
        if (_showLanguageAppDropdown) {
          _closeLanguageAppDropdown();
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main dropdown button
          GestureDetector(
            onTap: _toggleLanguageAppDropdown,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .outline
                      .withValues(alpha: 0.5),
                ),
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(context).colorScheme.surface,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.language,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.language,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          currentDisplayName,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _showLanguageAppDropdown
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 20,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),

          // Expandable dropdown content
          if (_showLanguageAppDropdown) ...[
            const SizedBox(height: 8),
            KeyboardListener(
              focusNode: FocusNode(),
              onKeyEvent: (event) {
                if (event is KeyDownEvent &&
                    event.logicalKey == LogicalKeyboardKey.escape) {
                  _closeLanguageAppDropdown();
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .outline
                        .withValues(alpha: 0.5),
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: Theme.of(context).colorScheme.surface,
                ),
                child: Column(
                  children: [
                    // Search field
                    TextField(
                      controller: _languageAppSearchController,
                      focusNode: _languageAppSearchFocusNode,
                      onChanged: _filterLanguageApp,
                      onSubmitted: (value) {
                        // Don't close on enter, allow user to continue searching
                      },
                      decoration: InputDecoration(
                        hintText: 'Search language...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest
                            .withValues(alpha: 0.3),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Language list
                    SizedBox(
                      height: 250, // Fixed height for scrollable area
                      child: _filteredLocalesApp.isEmpty
                          ? Center(
                              child: Text(
                                'No language found',
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: _filteredLocalesApp.length,
                              itemBuilder: (context, index) {
                                final locale = _filteredLocalesApp[index];
                                final displayName = LocaleService.instance
                                    .getLanguageName(locale.languageCode);
                                final isSelected = LocaleService
                                        .instance.currentLocale?.languageCode ==
                                    locale.languageCode;

                                return InkWell(
                                  onTap: () => _selectLanguageApp(locale),
                                  borderRadius: BorderRadius.circular(8),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    child: Row(
                                      children: [
                                        // Flag emoji for language
                                        Text(
                                          LocaleService.instance
                                                  .getLanguageEmoji(
                                                      locale.languageCode) ??
                                              '🌐',
                                          style: const TextStyle(fontSize: 20),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            displayName,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  fontWeight: isSelected
                                                      ? FontWeight.w600
                                                      : FontWeight.normal,
                                                ),
                                          ),
                                        ),
                                        if (isSelected)
                                          Icon(
                                            Icons.check,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            size: 20,
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
