import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleService extends ChangeNotifier {
  static const String _localeKey = 'selected_locale';
  static LocaleService? _instance;
  
  LocaleService._();
  
  static LocaleService get instance {
    _instance ??= LocaleService._();
    return _instance!;
  }

  Locale? _currentLocale;
  
  Locale? get currentLocale => _currentLocale;

  // Lingue supportate con tutti i locale di flutter_localizations
  static const List<Locale> supportedLocales = [
    Locale('af'), // Afrikaans
    Locale('am'), // Amharic
    Locale('ar'), // Arabic
    Locale('as'), // Assamese
    Locale('az'), // Azerbaijani
    Locale('be'), // Belarusian
    Locale('bg'), // Bulgarian
    Locale('bn'), // Bengali
    Locale('bs'), // Bosnian
    Locale('ca'), // Catalan
    Locale('cs'), // Czech
    Locale('cy'), // Welsh
    Locale('da'), // Danish
    Locale('de'), // German
    Locale('el'), // Greek
    Locale('en'), // English
    Locale('es'), // Spanish
    Locale('et'), // Estonian
    Locale('eu'), // Basque
    Locale('fa'), // Persian
    Locale('fi'), // Finnish
    Locale('fil'), // Filipino
    Locale('fr'), // French
    Locale('gl'), // Galician
    Locale('gsw'), // Swiss German
    Locale('gu'), // Gujarati
    Locale('he'), // Hebrew
    Locale('hi'), // Hindi
    Locale('hr'), // Croatian
    Locale('hu'), // Hungarian
    Locale('hy'), // Armenian
    Locale('id'), // Indonesian
    Locale('is'), // Icelandic
    Locale('it'), // Italian
    Locale('ja'), // Japanese
    Locale('ka'), // Georgian
    Locale('kk'), // Kazakh
    Locale('km'), // Khmer
    Locale('kn'), // Kannada
    Locale('ko'), // Korean
    Locale('ky'), // Kyrgyz
    Locale('lo'), // Lao
    Locale('lt'), // Lithuanian
    Locale('lv'), // Latvian
    Locale('mk'), // Macedonian
    Locale('ml'), // Malayalam
    Locale('mn'), // Mongolian
    Locale('mr'), // Marathi
    Locale('ms'), // Malay
    Locale('my'), // Myanmar
    Locale('nb'), // Norwegian Bokmål
    Locale('ne'), // Nepali
    Locale('nl'), // Dutch
    Locale('no'), // Norwegian
    Locale('or'), // Odia
    Locale('pa'), // Punjabi
    Locale('pl'), // Polish
    Locale('ps'), // Pashto
    Locale('pt'), // Portuguese
    Locale('ro'), // Romanian
    Locale('ru'), // Russian
    Locale('si'), // Sinhala
    Locale('sk'), // Slovak
    Locale('sl'), // Slovenian
    Locale('sq'), // Albanian
    Locale('sr'), // Serbian
    Locale('sv'), // Swedish
    Locale('sw'), // Swahili
    Locale('ta'), // Tamil
    Locale('te'), // Telugu
    Locale('th'), // Thai
    Locale('tl'), // Tagalog
    Locale('tr'), // Turkish
    Locale('uk'), // Ukrainian
    Locale('ur'), // Urdu
    Locale('uz'), // Uzbek
    Locale('vi'), // Vietnamese
    Locale('zh'), // Chinese
    Locale('zu'), // Zulu
  ];

  // Mappa dei nomi delle lingue per visualizzazione
  static const Map<String, String> languageNames = {
    'af': 'Afrikaans',
    'am': 'አማርኛ',
    'ar': 'العربية',
    'as': 'অসমীয়া',
    'az': 'Azərbaycan',
    'be': 'Беларуская',
    'bg': 'Български',
    'bn': 'বাংলা',
    'bs': 'Bosanski',
    'ca': 'Català',
    'cs': 'Čeština',
    'cy': 'Cymraeg',
    'da': 'Dansk',
    'de': 'Deutsch',
    'el': 'Ελληνικά',
    'en': 'English',
    'es': 'Español',
    'et': 'Eesti',
    'eu': 'Euskera',
    'fa': 'فارسی',
    'fi': 'Suomi',
    'fil': 'Filipino',
    'fr': 'Français',
    'gl': 'Galego',
    'gsw': 'Schwiizertüütsch',
    'gu': 'ગુજરાતી',
    'he': 'עברית',
    'hi': 'हिन्दी',
    'hr': 'Hrvatski',
    'hu': 'Magyar',
    'hy': 'Հայերեն',
    'id': 'Bahasa Indonesia',
    'is': 'Íslenska',
    'it': 'Italiano',
    'ja': '日本語',
    'ka': 'ქართული',
    'kk': 'Қазақ тілі',
    'km': 'ខ្មែរ',
    'kn': 'ಕನ್ನಡ',
    'ko': '한국어',
    'ky': 'Кыргызча',
    'lo': 'ລາວ',
    'lt': 'Lietuvių',
    'lv': 'Latviešu',
    'mk': 'Македонски',
    'ml': 'മലയാളം',
    'mn': 'Монгол',
    'mr': 'मराठी',
    'ms': 'Bahasa Melayu',
    'my': 'မြန်မာ',
    'nb': 'Norsk Bokmål',
    'ne': 'नेपाली',
    'nl': 'Nederlands',
    'no': 'Norsk',
    'or': 'ଓଡ଼ିଆ',
    'pa': 'ਪੰਜਾਬੀ',
    'pl': 'Polski',
    'ps': 'پښتو',
    'pt': 'Português',
    'ro': 'Română',
    'ru': 'Русский',
    'si': 'සිංහල',
    'sk': 'Slovenčina',
    'sl': 'Slovenščina',
    'sq': 'Shqip',
    'sr': 'Српски',
    'sv': 'Svenska',
    'sw': 'Kiswahili',
    'ta': 'தமிழ்',
    'te': 'తెలుగు',
    'th': 'ไทย',
    'tl': 'Tagalog',
    'tr': 'Türkçe',
    'uk': 'Українська',
    'ur': 'اردو',
    'uz': 'O\'zbek',
    'vi': 'Tiếng Việt',
    'zh': '中文',
    'zu': 'IsiZulu',
  };

  // Lingue per cui abbiamo traduzioni complete
  static const List<Locale> fullyTranslatedLocales = [
    Locale('en'),
    Locale('it'),
    Locale('es'),
    Locale('fr'),
    Locale('de'),
  ];

  // Emoji delle bandiere per le lingue supportate
  static const Map<String, String> languageEmojis = {
    'en': '🇺🇸', // English - USA flag
    'it': '🇮🇹', // Italian - Italy flag
    'es': '🇪🇸', // Spanish - Spain flag
    'fr': '🇫🇷', // French - France flag
    'de': '🇩🇪', // German - Germany flag
  };

  Future<void> loadSavedLocale() async {
    try {
      // Prima proviamo a caricare la lingua dal profilo utente (se autenticato)
      await _loadLocaleFromUserProfile();
      
      // Se non c'è lingua nel profilo, carichiamo da SharedPreferences
      if (_currentLocale == null) {
        final prefs = await SharedPreferences.getInstance();
        final savedLocaleCode = prefs.getString(_localeKey);
        
        if (savedLocaleCode != null) {
          _currentLocale = Locale(savedLocaleCode);
        }
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading saved locale: $e');
    }
  }

  Future<void> _loadLocaleFromUserProfile() async {
    // Per ora, non carichiamo dal profilo utente per evitare dipendenze circolari
    // Il caricamento dal profilo utente verrà fatto dall'app principale dopo l'autenticazione
    // Questo metodo rimane per future implementazioni
  }

  Future<void> setLocale(Locale locale) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, locale.languageCode);
      
      _currentLocale = locale;
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving locale: $e');
    }
  }

  String getLanguageName(String languageCode) {
    return languageNames[languageCode] ?? languageCode.toUpperCase();
  }

  String? getLanguageEmoji(String languageCode) {
    return languageEmojis[languageCode];
  }

  bool isFullyTranslated(Locale locale) {
    return fullyTranslatedLocales.any((l) => l.languageCode == locale.languageCode);
  }

  /// Carica la lingua dal profilo utente se disponibile
  /// Questo metodo deve essere chiamato dopo il login
  Future<void> loadLanguageFromUserProfile(String? userLanguageCode) async {
    try {
      if (userLanguageCode != null && userLanguageCode.isNotEmpty) {
        final newLocale = Locale(userLanguageCode);
        
        // Verifica che sia una lingua supportata e tradotta
        if (fullyTranslatedLocales.any((l) => l.languageCode == userLanguageCode)) {
          _currentLocale = newLocale;
          
          // Salva anche in SharedPreferences per consistenza
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_localeKey, userLanguageCode);
          
          notifyListeners();
          debugPrint('✅ Lingua caricata dal profilo utente: $userLanguageCode');
        }
      }
    } catch (e) {
      debugPrint('⚠️ Errore nel caricare lingua dal profilo utente: $e');
    }
  }
}