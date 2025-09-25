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

// Lista dei prefissi telefonici più comuni con chiavi per i18n
const List<Map<String, String>> PHONE_PREFIXES = [
  {'code': '+39', 'country': 'it', 'emoji': '🇮🇹'},
  {'code': '+1', 'country': 'us', 'emoji': '🇺🇸'},
  {'code': '+33', 'country': 'fr', 'emoji': '🇫🇷'},
  {'code': '+49', 'country': 'de', 'emoji': '🇩🇪'},
  {'code': '+34', 'country': 'es', 'emoji': '🇪🇸'},
  {'code': '+351', 'country': 'pt', 'emoji': '🇵🇹'},
  {'code': '+44', 'country': 'gb', 'emoji': '🇬🇧'},
  {'code': '+41', 'country': 'ch', 'emoji': '🇨🇭'},
  {'code': '+43', 'country': 'at', 'emoji': '🇦🇹'},
  {'code': '+32', 'country': 'be', 'emoji': '🇧🇪'},
  {'code': '+31', 'country': 'nl', 'emoji': '🇳🇱'},
  {'code': '+45', 'country': 'dk', 'emoji': '🇩🇰'},
  {'code': '+46', 'country': 'se', 'emoji': '🇸🇪'},
  {'code': '+47', 'country': 'no', 'emoji': '🇳🇴'},
  {'code': '+358', 'country': 'fi', 'emoji': '🇫🇮'},
  {'code': '+48', 'country': 'pl', 'emoji': '🇵🇱'},
  {'code': '+420', 'country': 'cz', 'emoji': '🇨🇿'},
  {'code': '+421', 'country': 'sk', 'emoji': '🇸🇰'},
  {'code': '+36', 'country': 'hu', 'emoji': '🇭🇺'},
  {'code': '+40', 'country': 'ro', 'emoji': '🇷🇴'},
  {'code': '+359', 'country': 'bg', 'emoji': '🇧🇬'},
  {'code': '+385', 'country': 'hr', 'emoji': '🇭🇷'},
  {'code': '+386', 'country': 'si', 'emoji': '🇸🇮'},
  {'code': '+381', 'country': 'rs', 'emoji': '🇷🇸'},
  {'code': '+30', 'country': 'gr', 'emoji': '🇬🇷'},
  {'code': '+90', 'country': 'tr', 'emoji': '🇹🇷'},
  {'code': '+972', 'country': 'il', 'emoji': '🇮🇱'},
  {'code': '+7', 'country': 'ru', 'emoji': '🇷🇺'},
  {'code': '+380', 'country': 'ua', 'emoji': '🇺🇦'},
  {'code': '+86', 'country': 'cn', 'emoji': '🇨🇳'},
  {'code': '+81', 'country': 'jp', 'emoji': '🇯🇵'},
  {'code': '+82', 'country': 'kr', 'emoji': '🇰🇷'},
  {'code': '+91', 'country': 'in', 'emoji': '🇮🇳'},
  {'code': '+55', 'country': 'br', 'emoji': '🇧🇷'},
  {'code': '+54', 'country': 'ar', 'emoji': '🇦🇷'},
  {'code': '+52', 'country': 'mx', 'emoji': '🇲🇽'},
  {'code': '+27', 'country': 'za', 'emoji': '🇿🇦'},
  {'code': '+61', 'country': 'au', 'emoji': '🇦🇺'},
];

// Nomi localizzati dei paesi (codice ISO -> nome localizzato)
const Map<String, Map<String, String>> LOCALIZED_COUNTRIES = {
  'it': {
    'ad': 'Andorra',
    'ae': 'Emirati Arabi Uniti',
    'af': 'Afghanistan',
    'ag': 'Antigua e Barbuda',
    'ai': 'Anguilla',
    'al': 'Albania',
    'am': 'Armenia',
    'ao': 'Angola',
    'aq': 'Antartide',
    'ar': 'Argentina',
    'as': 'Samoa Americane',
    'at': 'Austria',
    'au': 'Australia',
    'aw': 'Aruba',
    'ax': 'Isole Åland',
    'az': 'Azerbaigian',
    'ba': 'Bosnia ed Erzegovina',
    'bb': 'Barbados',
    'bd': 'Bangladesh',
    'be': 'Belgio',
    'bf': 'Burkina Faso',
    'bg': 'Bulgaria',
    'bh': 'Bahrein',
    'bi': 'Burundi',
    'bj': 'Benin',
    'bl': 'Saint-Barthélemy',
    'bm': 'Bermuda',
    'bn': 'Brunei',
    'bo': 'Bolivia',
    'bq': 'Bonaire, Sint Eustatius e Saba',
    'br': 'Brasile',
    'bs': 'Bahamas',
    'bt': 'Bhutan',
    'bv': 'Isola Bouvet',
    'bw': 'Botswana',
    'by': 'Bielorussia',
    'bz': 'Belize',
    'ca': 'Canada',
    'cc': 'Isole Cocos',
    'cd': 'Repubblica Democratica del Congo',
    'cf': 'Repubblica Centrafricana',
    'cg': 'Repubblica del Congo',
    'ch': 'Svizzera',
    'ci': 'Costa d\'Avorio',
    'ck': 'Isole Cook',
    'cl': 'Cile',
    'cm': 'Camerun',
    'cn': 'Cina',
    'co': 'Colombia',
    'cr': 'Costa Rica',
    'cu': 'Cuba',
    'cv': 'Capo Verde',
    'cw': 'Curaçao',
    'cx': 'Isola Christmas',
    'cy': 'Cipro',
    'cz': 'Repubblica Ceca',
    'de': 'Germania',
    'dj': 'Gibuti',
    'dk': 'Danimarca',
    'dm': 'Dominica',
    'do': 'Repubblica Dominicana',
    'dz': 'Algeria',
    'ec': 'Ecuador',
    'ee': 'Estonia',
    'eg': 'Egitto',
    'eh': 'Sahara Occidentale',
    'er': 'Eritrea',
    'es': 'Spagna',
    'et': 'Etiopia',
    'fi': 'Finlandia',
    'fj': 'Figi',
    'fk': 'Isole Falkland',
    'fm': 'Micronesia',
    'fo': 'Isole Fær Øer',
    'fr': 'Francia',
    'ga': 'Gabon',
    'gb': 'Regno Unito',
    'gd': 'Grenada',
    'ge': 'Georgia',
    'gf': 'Guyana Francese',
    'gg': 'Guernsey',
    'gh': 'Ghana',
    'gi': 'Gibilterra',
    'gl': 'Groenlandia',
    'gm': 'Gambia',
    'gn': 'Guinea',
    'gp': 'Guadalupa',
    'gq': 'Guinea Equatoriale',
    'gr': 'Grecia',
    'gs': 'Georgia del Sud e Isole Sandwich Australi',
    'gt': 'Guatemala',
    'gu': 'Guam',
    'gw': 'Guinea-Bissau',
    'gy': 'Guyana',
    'hk': 'Hong Kong',
    'hm': 'Isola Heard e Isole McDonald',
    'hn': 'Honduras',
    'hr': 'Croazia',
    'ht': 'Haiti',
    'hu': 'Ungheria',
    'id': 'Indonesia',
    'ie': 'Irlanda',
    'il': 'Israele',
    'im': 'Isola di Man',
    'in': 'India',
    'io': 'Territorio Britannico dell\'Oceano Indiano',
    'iq': 'Iraq',
    'ir': 'Iran',
    'is': 'Islanda',
    'it': 'Italia',
    'je': 'Jersey',
    'jm': 'Giamaica',
    'jo': 'Giordania',
    'jp': 'Giappone',
    'ke': 'Kenya',
    'kg': 'Kirghizistan',
    'kh': 'Cambogia',
    'ki': 'Kiribati',
    'km': 'Comore',
    'kn': 'Saint Kitts e Nevis',
    'kp': 'Corea del Nord',
    'kr': 'Corea del Sud',
    'kw': 'Kuwait',
    'ky': 'Isole Cayman',
    'kz': 'Kazakistan',
    'la': 'Laos',
    'lb': 'Libano',
    'lc': 'Saint Lucia',
    'li': 'Liechtenstein',
    'lk': 'Sri Lanka',
    'lr': 'Liberia',
    'ls': 'Lesotho',
    'lt': 'Lituania',
    'lu': 'Lussemburgo',
    'lv': 'Lettonia',
    'ly': 'Libia',
    'ma': 'Marocco',
    'mc': 'Monaco',
    'md': 'Moldavia',
    'me': 'Montenegro',
    'mf': 'Saint-Martin',
    'mg': 'Madagascar',
    'mh': 'Isole Marshall',
    'mk': 'Macedonia del Nord',
    'ml': 'Mali',
    'mm': 'Myanmar',
    'mn': 'Mongolia',
    'mo': 'Macao',
    'mp': 'Isole Marianne Settentrionali',
    'mq': 'Martinica',
    'mr': 'Mauritania',
    'ms': 'Montserrat',
    'mt': 'Malta',
    'mu': 'Mauritius',
    'mv': 'Maldive',
    'mw': 'Malawi',
    'mx': 'Messico',
    'my': 'Malesia',
    'mz': 'Mozambico',
    'na': 'Namibia',
    'nc': 'Nuova Caledonia',
    'ne': 'Niger',
    'nf': 'Isola Norfolk',
    'ng': 'Nigeria',
    'ni': 'Nicaragua',
    'nl': 'Paesi Bassi',
    'no': 'Norvegia',
    'np': 'Nepal',
    'nr': 'Nauru',
    'nu': 'Niue',
    'nz': 'Nuova Zelanda',
    'om': 'Oman',
    'pa': 'Panama',
    'pe': 'Perù',
    'pf': 'Polinesia Francese',
    'pg': 'Papua Nuova Guinea',
    'ph': 'Filippine',
    'pk': 'Pakistan',
    'pl': 'Polonia',
    'pm': 'Saint-Pierre e Miquelon',
    'pn': 'Isole Pitcairn',
    'pr': 'Porto Rico',
    'ps': 'Palestina',
    'pt': 'Portogallo',
    'pw': 'Palau',
    'py': 'Paraguay',
    'qa': 'Qatar',
    're': 'Riunione',
    'ro': 'Romania',
    'rs': 'Serbia',
    'ru': 'Russia',
    'rw': 'Ruanda',
    'sa': 'Arabia Saudita',
    'sb': 'Isole Salomone',
    'sc': 'Seicelle',
    'sd': 'Sudan',
    'se': 'Svezia',
    'sg': 'Singapore',
    'sh': 'Sant\'Elena, Ascensione e Tristan da Cunha',
    'si': 'Slovenia',
    'sj': 'Svalbard e Jan Mayen',
    'sk': 'Slovacchia',
    'sl': 'Sierra Leone',
    'sm': 'San Marino',
    'sn': 'Senegal',
    'so': 'Somalia',
    'sr': 'Suriname',
    'ss': 'Sudan del Sud',
    'st': 'São Tomé e Príncipe',
    'sv': 'El Salvador',
    'sx': 'Sint Maarten',
    'sy': 'Siria',
    'sz': 'Swaziland',
    'tc': 'Isole Turks e Caicos',
    'td': 'Ciad',
    'tf': 'Terre Australi e Antartiche Francesi',
    'tg': 'Togo',
    'th': 'Tailandia',
    'tj': 'Tagikistan',
    'tk': 'Tokelau',
    'tl': 'Timor Est',
    'tm': 'Turkmenistan',
    'tn': 'Tunisia',
    'to': 'Tonga',
    'tr': 'Turchia',
    'tt': 'Trinidad e Tobago',
    'tv': 'Tuvalu',
    'tw': 'Taiwan',
    'tz': 'Tanzania',
    'ua': 'Ucraina',
    'ug': 'Uganda',
    'um': 'Isole Minori Esterne degli Stati Uniti',
    'us': 'Stati Uniti',
    'uy': 'Uruguay',
    'uz': 'Uzbekistan',
    'va': 'Città del Vaticano',
    'vc': 'Saint Vincent e Grenadine',
    've': 'Venezuela',
    'vg': 'Isole Vergini Britanniche',
    'vi': 'Isole Vergini Americane',
    'vn': 'Vietnam',
    'vu': 'Vanuatu',
    'wf': 'Wallis e Futuna',
    'ws': 'Samoa',
    'ye': 'Yemen',
    'yt': 'Mayotte',
    'za': 'Sudafrica',
    'zm': 'Zambia',
    'zw': 'Zimbabwe',
  },
  'en': {
    'ad': 'Andorra',
    'ae': 'United Arab Emirates',
    'af': 'Afghanistan',
    'al': 'Albania',
    'ar': 'Argentina',
    'at': 'Austria',
    'au': 'Australia',
    'be': 'Belgium',
    'bg': 'Bulgaria',
    'br': 'Brazil',
    'ca': 'Canada',
    'ch': 'Switzerland',
    'cn': 'China',
    'co': 'Colombia',
    'cr': 'Costa Rica',
    'cz': 'Czech Republic',
    'de': 'Germany',
    'dk': 'Denmark',
    'ec': 'Ecuador',
    'ee': 'Estonia',
    'eg': 'Egypt',
    'es': 'Spain',
    'et': 'Ethiopia',
    'fi': 'Finland',
    'fr': 'France',
    'gb': 'United Kingdom',
    'ge': 'Georgia',
    'gr': 'Greece',
    'hr': 'Croatia',
    'hu': 'Hungary',
    'id': 'Indonesia',
    'ie': 'Ireland',
    'il': 'Israel',
    'in': 'India',
    'ir': 'Iran',
    'is': 'Iceland',
    'it': 'Italy',
    'jp': 'Japan',
    'ke': 'Kenya',
    'kr': 'South Korea',
    'kw': 'Kuwait',
    'lb': 'Lebanon',
    'li': 'Liechtenstein',
    'lt': 'Lithuania',
    'lu': 'Luxembourg',
    'lv': 'Latvia',
    'ma': 'Morocco',
    'mc': 'Monaco',
    'md': 'Moldova',
    'me': 'Montenegro',
    'mk': 'North Macedonia',
    'mt': 'Malta',
    'mx': 'Mexico',
    'my': 'Malaysia',
    'ng': 'Nigeria',
    'nl': 'Netherlands',
    'no': 'Norway',
    'nz': 'New Zealand',
    'pe': 'Peru',
    'ph': 'Philippines',
    'pk': 'Pakistan',
    'pl': 'Poland',
    'pt': 'Portugal',
    'qa': 'Qatar',
    'ro': 'Romania',
    'rs': 'Serbia',
    'ru': 'Russia',
    'sa': 'Saudi Arabia',
    'se': 'Sweden',
    'sg': 'Singapore',
    'si': 'Slovenia',
    'sk': 'Slovakia',
    'th': 'Thailand',
    'tr': 'Turkey',
    'ua': 'Ukraine',
    'us': 'United States',
    've': 'Venezuela',
    'vn': 'Vietnam',
    'za': 'South Africa',
  },
  'es': {
    'ad': 'Andorra',
    'ae': 'Emiratos Árabes Unidos',
    'af': 'Afganistán',
    'al': 'Albania',
    'ar': 'Argentina',
    'at': 'Austria',
    'au': 'Australia',
    'be': 'Bélgica',
    'bg': 'Bulgaria',
    'br': 'Brasil',
    'ca': 'Canadá',
    'ch': 'Suiza',
    'cn': 'China',
    'co': 'Colombia',
    'cr': 'Costa Rica',
    'cz': 'República Checa',
    'de': 'Alemania',
    'dk': 'Dinamarca',
    'ec': 'Ecuador',
    'ee': 'Estonia',
    'eg': 'Egipto',
    'es': 'España',
    'et': 'Etiopía',
    'fi': 'Finlandia',
    'fr': 'Francia',
    'gb': 'Reino Unido',
    'ge': 'Georgia',
    'gr': 'Grecia',
    'hr': 'Croacia',
    'hu': 'Hungría',
    'id': 'Indonesia',
    'ie': 'Irlanda',
    'il': 'Israel',
    'in': 'India',
    'ir': 'Irán',
    'is': 'Islandia',
    'it': 'Italia',
    'jp': 'Japón',
    'ke': 'Kenia',
    'kr': 'Corea del Sur',
    'kw': 'Kuwait',
    'lb': 'Líbano',
    'li': 'Liechtenstein',
    'lt': 'Lituania',
    'lu': 'Luxemburgo',
    'lv': 'Letonia',
    'ma': 'Marruecos',
    'mc': 'Mónaco',
    'md': 'Moldavia',
    'me': 'Montenegro',
    'mk': 'Macedonia del Norte',
    'mt': 'Malta',
    'mx': 'México',
    'my': 'Malasia',
    'ng': 'Nigeria',
    'nl': 'Países Bajos',
    'no': 'Noruega',
    'nz': 'Nueva Zelanda',
    'pe': 'Perú',
    'ph': 'Filipinas',
    'pk': 'Pakistán',
    'pl': 'Polonia',
    'pt': 'Portugal',
    'qa': 'Qatar',
    'ro': 'Rumania',
    'rs': 'Serbia',
    'ru': 'Rusia',
    'sa': 'Arabia Saudí',
    'se': 'Suecia',
    'sg': 'Singapur',
    'si': 'Eslovenia',
    'sk': 'Eslovaquia',
    'th': 'Tailandia',
    'tr': 'Turquía',
    'ua': 'Ucrania',
    'us': 'Estados Unidos',
    've': 'Venezuela',
    'vn': 'Vietnam',
    'za': 'Sudáfrica',
  },
  'fr': {
    'ad': 'Andorre',
    'ae': 'Émirats Arabes Unis',
    'af': 'Afghanistan',
    'al': 'Albanie',
    'ar': 'Argentine',
    'at': 'Autriche',
    'au': 'Australie',
    'be': 'Belgique',
    'bg': 'Bulgarie',
    'br': 'Brésil',
    'ca': 'Canada',
    'ch': 'Suisse',
    'cn': 'Chine',
    'co': 'Colombie',
    'cr': 'Costa Rica',
    'cz': 'République tchèque',
    'de': 'Allemagne',
    'dk': 'Danemark',
    'ec': 'Équateur',
    'ee': 'Estonie',
    'eg': 'Égypte',
    'es': 'Espagne',
    'et': 'Éthiopie',
    'fi': 'Finlande',
    'fr': 'France',
    'gb': 'Royaume-Uni',
    'ge': 'Géorgie',
    'gr': 'Grèce',
    'hr': 'Croatie',
    'hu': 'Hongrie',
    'id': 'Indonésie',
    'ie': 'Irlande',
    'il': 'Israël',
    'in': 'Inde',
    'ir': 'Iran',
    'is': 'Islande',
    'it': 'Italie',
    'jp': 'Japon',
    'ke': 'Kenya',
    'kr': 'Corée du Sud',
    'kw': 'Koweït',
    'lb': 'Liban',
    'li': 'Liechtenstein',
    'lt': 'Lituanie',
    'lu': 'Luxembourg',
    'lv': 'Lettonie',
    'ma': 'Maroc',
    'mc': 'Monaco',
    'md': 'Moldavie',
    'me': 'Monténégro',
    'mk': 'Macédoine du Nord',
    'mt': 'Malte',
    'mx': 'Mexique',
    'my': 'Malaisie',
    'ng': 'Nigeria',
    'nl': 'Pays-Bas',
    'no': 'Norvège',
    'nz': 'Nouvelle-Zélande',
    'pe': 'Pérou',
    'ph': 'Philippines',
    'pk': 'Pakistan',
    'pl': 'Pologne',
    'pt': 'Portugal',
    'qa': 'Qatar',
    'ro': 'Roumanie',
    'rs': 'Serbie',
    'ru': 'Russie',
    'sa': 'Arabie Saoudite',
    'se': 'Suède',
    'sg': 'Singapour',
    'si': 'Slovénie',
    'sk': 'Slovaquie',
    'th': 'Thaïlande',
    'tr': 'Turquie',
    'ua': 'Ukraine',
    'us': 'États-Unis',
    've': 'Venezuela',
    'vn': 'Vietnam',
    'za': 'Afrique du Sud',
  },
  'de': {
    'ad': 'Andorra',
    'ae': 'Vereinigte Arabische Emirate',
    'af': 'Afghanistan',
    'al': 'Albanien',
    'ar': 'Argentinien',
    'at': 'Österreich',
    'au': 'Australien',
    'be': 'Belgien',
    'bg': 'Bulgarien',
    'br': 'Brasilien',
    'ca': 'Kanada',
    'ch': 'Schweiz',
    'cn': 'China',
    'co': 'Kolumbien',
    'cr': 'Costa Rica',
    'cz': 'Tschechische Republik',
    'de': 'Deutschland',
    'dk': 'Dänemark',
    'ec': 'Ecuador',
    'ee': 'Estland',
    'eg': 'Ägypten',
    'es': 'Spanien',
    'et': 'Äthiopien',
    'fi': 'Finnland',
    'fr': 'Frankreich',
    'gb': 'Vereinigtes Königreich',
    'ge': 'Georgien',
    'gr': 'Griechenland',
    'hr': 'Kroatien',
    'hu': 'Ungarn',
    'id': 'Indonesien',
    'ie': 'Irland',
    'il': 'Israel',
    'in': 'Indien',
    'ir': 'Iran',
    'is': 'Island',
    'it': 'Italien',
    'jp': 'Japan',
    'ke': 'Kenia',
    'kr': 'Südkorea',
    'kw': 'Kuwait',
    'lb': 'Libanon',
    'li': 'Liechtenstein',
    'lt': 'Litauen',
    'lu': 'Luxemburg',
    'lv': 'Lettland',
    'ma': 'Marokko',
    'mc': 'Monaco',
    'md': 'Moldau',
    'me': 'Montenegro',
    'mk': 'Nordmazedonien',
    'mt': 'Malta',
    'mx': 'Mexiko',
    'my': 'Malaysia',
    'ng': 'Nigeria',
    'nl': 'Niederlande',
    'no': 'Norwegen',
    'nz': 'Neuseeland',
    'pe': 'Peru',
    'ph': 'Philippinen',
    'pk': 'Pakistan',
    'pl': 'Polen',
    'pt': 'Portugal',
    'qa': 'Katar',
    'ro': 'Rumänien',
    'rs': 'Serbien',
    'ru': 'Russland',
    'sa': 'Saudi-Arabien',
    'se': 'Schweden',
    'sg': 'Singapur',
    'si': 'Slowenien',
    'sk': 'Slowakei',
    'th': 'Thailand',
    'tr': 'Türkei',
    'ua': 'Ukraine',
    'us': 'Vereinigte Staaten',
    've': 'Venezuela',
    'vn': 'Vietnam',
    'za': 'Südafrika',
  },
};

// Localized texts for UI components
const Map<String, Map<String, String>> UI_TEXTS = {
  'it': {
    'selectPhonePrefix': 'Seleziona prefisso internazionale',
    'searchCountryOrPrefix': 'Cerca paese o prefisso...',
    'noPrefixFound': 'Nessun prefisso trovato',
    'removeProfilePhoto': 'Rimuovi foto profilo',
    'removePhotoConfirmation':
        'Sei sicuro di voler rimuovere la tua foto profilo?',
    'removing': 'Rimozione...',
    'cancelSelection': 'Annulla selezione',
    'removePhoto': 'Rimuovi foto',
    'spokenLanguages': 'Lingue parlate',
    'selectCountry': 'Seleziona un paese',
  },
  'en': {
    'selectPhonePrefix': 'Select international prefix',
    'searchCountryOrPrefix': 'Search country or prefix...',
    'noPrefixFound': 'No prefix found',
    'removeProfilePhoto': 'Remove profile photo',
    'removePhotoConfirmation':
        'Are you sure you want to remove your profile photo?',
    'removing': 'Removing...',
    'cancelSelection': 'Cancel selection',
    'removePhoto': 'Remove photo',
    'spokenLanguages': 'Spoken languages',
    'selectCountry': 'Select a country',
  },
  'es': {
    'selectPhonePrefix': 'Seleccionar prefijo internacional',
    'searchCountryOrPrefix': 'Buscar país o prefijo...',
    'noPrefixFound': 'No se encontró prefijo',
    'removeProfilePhoto': 'Eliminar foto de perfil',
    'removePhotoConfirmation':
        '¿Estás seguro de que quieres eliminar tu foto de perfil?',
    'removing': 'Eliminando...',
    'cancelSelection': 'Cancelar selección',
    'removePhoto': 'Eliminar foto',
    'spokenLanguages': 'Idiomas hablados',
    'selectCountry': 'Selecciona un país',
  },
  'fr': {
    'selectPhonePrefix': 'Sélectionner le préfixe international',
    'searchCountryOrPrefix': 'Rechercher pays ou préfixe...',
    'noPrefixFound': 'Aucun préfixe trouvé',
    'removeProfilePhoto': 'Supprimer la photo de profil',
    'removePhotoConfirmation':
        'Êtes-vous sûr de vouloir supprimer votre photo de profil ?',
    'removing': 'Suppression...',
    'cancelSelection': 'Annuler la sélection',
    'removePhoto': 'Supprimer la photo',
    'spokenLanguages': 'Langues parlées',
    'selectCountry': 'Sélectionner un pays',
  },
  'de': {
    'selectPhonePrefix': 'Internationale Vorwahl auswählen',
    'searchCountryOrPrefix': 'Land oder Vorwahl suchen...',
    'noPrefixFound': 'Keine Vorwahl gefunden',
    'removeProfilePhoto': 'Profilbild entfernen',
    'removePhotoConfirmation':
        'Sind Sie sicher, dass Sie Ihr Profilbild entfernen möchten?',
    'removing': 'Entfernen...',
    'cancelSelection': 'Auswahl abbrechen',
    'removePhoto': 'Foto entfernen',
    'spokenLanguages': 'Gesprochene Sprachen',
    'selectCountry': 'Land auswählen',
  },
};

// Helper function to get localized country name
String getLocalizedCountryName(String countryCode, String languageCode) {
  final countries =
      LOCALIZED_COUNTRIES[languageCode] ?? LOCALIZED_COUNTRIES['it'] ?? {};
  return countries[countryCode.toLowerCase()] ?? countryCode.toUpperCase();
}

// Helper function to get localized text for UI components
String getLocalizedText(String key, String languageCode) {
  final texts = UI_TEXTS[languageCode] ?? UI_TEXTS['it'] ?? {};
  return texts[key] ?? key;
}

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

    // Allow only digits (prefix is handled separately)
    String filtered = text.replaceAll(RegExp(r'[^0-9]'), '');
    return TextEditingValue(
      text: filtered,
      selection: TextSelection.collapsed(offset: filtered.length),
    );
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
  bool _isRemovingImage = false; // Track removal state
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

  // Language App variables removed

  // Phone prefix state
  String _selectedPhonePrefix = '+39'; // Default to Italy

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
          final phoneNumber = user.phone ?? '';
          if (phoneNumber.isNotEmpty) {
            // Try to extract prefix and number from existing phone
            final match =
                RegExp(r'^\+(\d{1,4})\s*(.*)').firstMatch(phoneNumber);
            if (match != null) {
              final prefixCode = '+${match.group(1)}';
              final number = match.group(2) ?? '';

              // Check if the prefix exists in our list
              final prefixExists =
                  PHONE_PREFIXES.any((p) => p['code'] == prefixCode);
              if (prefixExists) {
                _selectedPhonePrefix = prefixCode;
                _phoneController.text = number;
              } else {
                // If prefix not in our list, use the full number
                _phoneController.text = phoneNumber;
              }
            } else {
              // No prefix found, use full number
              _phoneController.text = phoneNumber;
            }
          }
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
        final currentLanguage =
            LocaleService.instance.currentLocale?.languageCode ?? 'it';
        _filteredCountries = _countries.where((country) {
          final localizedName =
              getLocalizedCountryName(country.code, currentLanguage);
          return localizedName.toLowerCase().contains(query.toLowerCase()) ||
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

  Future<void> _removeProfilePicture() async {
    final localizations = AppLocalizations.of(context)!;

    // If user only has a newly selected image (not saved), just clear the selection
    if ((_selectedImage != null || _selectedImageBytes != null) &&
        _profilePicture == null) {
      setState(() {
        _selectedImage = null;
        _selectedImageBytes = null;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Selezione foto annullata'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    // Show confirmation dialog for removing saved profile picture
    final shouldRemove = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        final currentLanguage =
            LocaleService.instance.currentLocale?.languageCode ?? 'it';
        return AlertDialog(
          title: Text(getLocalizedText('removeProfilePhoto', currentLanguage)),
          content: Text(
              getLocalizedText('removePhotoConfirmation', currentLanguage)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(localizations.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Rimuovi'),
            ),
          ],
        );
      },
    );

    if (shouldRemove != true || !mounted) return;

    setState(() {
      _isRemovingImage = true;
    });

    try {
      // Get authentication token
      final session = SupabaseConfig.client.auth.currentSession;
      if (session?.accessToken == null) {
        throw Exception('Sessione non valida');
      }

      // Call removeUserProfilePicture Edge Function
      final uri = Uri.parse(
          '${SupabaseConfig.supabaseUrl}/functions/v1/removeUserProfilePicture');

      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer ${session!.accessToken}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        if (data['ok'] == true) {
          // Successfully removed - update UI
          setState(() {
            _profilePicture = null;
            _selectedImage = null;
            _selectedImageBytes = null;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Foto profilo rimossa con successo'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          throw Exception(data['message'] ?? 'Errore durante la rimozione');
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore durante la rimozione: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRemovingImage = false;
        });
      }
    }
  }

  Future<void> _savePersonalInfo() async {
    if (!_formKey.currentState!.validate()) return;

    final localizations = AppLocalizations.of(context)!;

    // Validate multi-select dropdowns (nationality, languages) and country
    if (_selectedNationalities.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Seleziona almeno una nazionalità'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    if (_selectedLanguages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Seleziona almeno una lingua parlata'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    if (_selectedCountryCode == null || _selectedCountryCode!.isEmpty) {
      final currentLanguage =
          LocaleService.instance.currentLocale?.languageCode ?? 'it';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(getLocalizedText('selectCountry', currentLanguage)),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

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
        updateData['phone'] =
            '$_selectedPhonePrefix ${_phoneController.text.trim()}';
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

      // Include current app language code
      final appLanguageCode =
          LocaleService.instance.currentLocale?.languageCode ?? 'it';
      updateData['languageCodeApp'] = appLanguageCode;

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
          // Close dropdowns when tapping outside
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton.icon(
                                onPressed:
                                    (_isUploadingImage || _isRemovingImage)
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
                                          : AppLocalizations.of(context)!
                                              .addPhoto,
                                ),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                ),
                              ),
                              // Show remove button only if there's an existing photo
                              if (_profilePicture != null ||
                                  _selectedImage != null) ...[
                                const SizedBox(width: 8),
                                TextButton.icon(
                                  onPressed:
                                      (_isUploadingImage || _isRemovingImage)
                                          ? null
                                          : _removeProfilePicture,
                                  icon: _isRemovingImage
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2),
                                        )
                                      : Icon(
                                          (_profilePicture == null &&
                                                  (_selectedImage != null ||
                                                      _selectedImageBytes !=
                                                          null))
                                              ? Icons.close
                                              : Icons.delete_outline,
                                        ),
                                  label: Builder(
                                    builder: (context) {
                                      final currentLanguage = LocaleService
                                              .instance
                                              .currentLocale
                                              ?.languageCode ??
                                          'it';
                                      return Text(
                                        _isRemovingImage
                                            ? getLocalizedText(
                                                'removing', currentLanguage)
                                            : (_profilePicture == null &&
                                                    (_selectedImage != null ||
                                                        _selectedImageBytes !=
                                                            null))
                                                ? getLocalizedText(
                                                    'cancelSelection',
                                                    currentLanguage)
                                                : getLocalizedText(
                                                    'removePhoto',
                                                    currentLanguage),
                                      );
                                    },
                                  ),
                                  style: TextButton.styleFrom(
                                    foregroundColor: (_profilePicture == null &&
                                            (_selectedImage != null ||
                                                _selectedImageBytes != null))
                                        ? Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant
                                        : Theme.of(context).colorScheme.error,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                  ),
                                ),
                              ],
                            ],
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
                            isRequired: true,
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
                            isRequired: true,
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

                    const SizedBox(height: 32),

                    // Sezione: Lingue parlate
                    _buildSectionHeader(getLocalizedText(
                        'spokenLanguages',
                        LocaleService.instance.currentLocale?.languageCode ??
                            'it')),
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
                      isRequired: true,
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

                    const SizedBox(height: 32),

                    // Sezione: Telefono
                    _buildSectionHeader(
                        '${AppLocalizations.of(context)!.phone} *'),
                    const SizedBox(height: 16),

                    // Phone field with prefix dropdown
                    Container(
                      height: 60,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Phone prefix dropdown
                          _buildPhonePrefixDropdown(),
                          // Phone number field
                          Expanded(
                            child: TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [PhoneInputFormatter()],
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return AppLocalizations.of(context)!
                                      .phoneRequired;
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 20,
                                ),
                                border: const OutlineInputBorder(
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(12),
                                    bottomRight: Radius.circular(12),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(12),
                                    bottomRight: Radius.circular(12),
                                  ),
                                  borderSide: BorderSide(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .outline
                                        .withValues(alpha: 0.5),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(12),
                                    bottomRight: Radius.circular(12),
                                  ),
                                  borderSide: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    width: 2,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(12),
                                    bottomRight: Radius.circular(12),
                                  ),
                                  borderSide: BorderSide(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(12),
                                    bottomRight: Radius.circular(12),
                                  ),
                                  borderSide: BorderSide(
                                    color: Theme.of(context).colorScheme.error,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Sezione: Indirizzo
                    _buildSectionHeader(AppLocalizations.of(context)!.address),
                    const SizedBox(height: 16),

                    // 1. Country (Paese)
                    _buildNewCountryDropdown(),

                    const SizedBox(height: 16),

                    // 2. City (Città) and 3. State (Stato/Provincia)
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextFormField(
                            controller: _cityController,
                            label: AppLocalizations.of(context)!.city,
                            icon: Icons.location_city_outlined,
                            textCapitalization: TextCapitalization.words,
                            inputFormatters: [TitleCaseInputFormatter()],
                            isRequired: true,
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
                            isRequired: true,
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

                    // 4. Address (Indirizzo)
                    _buildTextFormField(
                      controller: _addressController,
                      label: AppLocalizations.of(context)!.address,
                      icon: Icons.home_outlined,
                      textCapitalization: TextCapitalization.words,
                      inputFormatters: [TitleCaseInputFormatter()],
                      isRequired: true,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return AppLocalizations.of(context)!.addressRequired;
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // 5. Postal Code (Codice Postale)
                    TextFormField(
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
                            '${AppLocalizations.of(context)!.postalCode} *',
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

                    const SizedBox(height: 40),

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
    bool isRequired = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      textCapitalization: textCapitalization ?? TextCapitalization.none,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: isRequired ? '$label *' : label,
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
        labelText: '${localizations.gender} *',
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
        labelText: '${localizations.dateOfBirth} *',
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
                          '${AppLocalizations.of(context)!.country} *',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                        const SizedBox(height: 2),
                        Builder(
                          builder: (context) {
                            final currentLanguage = LocaleService
                                    .instance.currentLocale?.languageCode ??
                                'it';
                            return Text(
                              selectedCountry?.code != null
                                  ? getLocalizedCountryName(
                                      selectedCountry!.code, currentLanguage)
                                  : getLocalizedText(
                                      'selectCountry', currentLanguage),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                              overflow: TextOverflow.ellipsis,
                            );
                          },
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
                                          child: Builder(
                                            builder: (context) {
                                              final currentLanguage =
                                                  LocaleService
                                                          .instance
                                                          .currentLocale
                                                          ?.languageCode ??
                                                      'it';
                                              return Text(
                                                getLocalizedCountryName(
                                                    country.code,
                                                    currentLanguage),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                      fontWeight: isSelected
                                                          ? FontWeight.w600
                                                          : FontWeight.normal,
                                                    ),
                                              );
                                            },
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
                          '${_getLocalizedText('nationality_label')} *',
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
                        Builder(
                          builder: (context) {
                            final currentLanguage = LocaleService
                                    .instance.currentLocale?.languageCode ??
                                'it';
                            return Text(
                              '${getLocalizedText('spokenLanguages', currentLanguage)} *',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                            );
                          },
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

  // PHONE PREFIX DROPDOWN WIDGET - OVERLAY VERSION
  Widget _buildPhonePrefixDropdown() {
    // Find selected prefix to show in button
    final selectedPrefix = PHONE_PREFIXES.firstWhere(
      (prefix) => prefix['code'] == _selectedPhonePrefix,
      orElse: () => {'code': '+39', 'country': 'it', 'emoji': '🇮🇹'},
    );

    return GestureDetector(
      onTap: _showPhonePrefixOverlay,
      child: Container(
        width: 110, // Slightly increased width for better balance
        height: 60, // Exact match with TextFormField height
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            bottomLeft: Radius.circular(12),
          ),
          color: Theme.of(context).colorScheme.surface,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              selectedPrefix['emoji']!,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                selectedPrefix['code']!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  // Show phone prefix selection overlay
  Future<void> _showPhonePrefixOverlay() async {
    final currentLanguage =
        LocaleService.instance.currentLocale?.languageCode ?? 'it';
    final result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return _PhonePrefixDialog(
          currentPrefix: _selectedPhonePrefix,
          languageCode: currentLanguage,
        );
      },
    );

    if (result != null) {
      setState(() {
        _selectedPhonePrefix = result;
      });
    }
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

// Phone Prefix Selection Dialog
class _PhonePrefixDialog extends StatefulWidget {
  final String currentPrefix;
  final String languageCode;

  const _PhonePrefixDialog({
    required this.currentPrefix,
    required this.languageCode,
  });

  @override
  State<_PhonePrefixDialog> createState() => _PhonePrefixDialogState();
}

class _PhonePrefixDialogState extends State<_PhonePrefixDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _filteredPrefixes = PHONE_PREFIXES;

  @override
  void initState() {
    super.initState();
    _filterPrefixes('');
  }

  void _filterPrefixes(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredPrefixes = PHONE_PREFIXES;
      } else {
        _filteredPrefixes = PHONE_PREFIXES.where((prefix) {
          final localizedCountryName =
              getLocalizedCountryName(prefix['country']!, widget.languageCode);
          return localizedCountryName
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              prefix['code']!.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 400,
        height: 500,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    getLocalizedText('selectPhonePrefix', widget.languageCode),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  style: IconButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Search field
            TextField(
              controller: _searchController,
              onChanged: _filterPrefixes,
              autofocus: true,
              decoration: InputDecoration(
                hintText: getLocalizedText(
                    'searchCountryOrPrefix', widget.languageCode),
                prefixIcon: const Icon(Icons.search, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withValues(alpha: 0.3),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),

            const SizedBox(height: 16),

            // Prefix list
            Expanded(
              child: _filteredPrefixes.isEmpty
                  ? Center(
                      child: Text(getLocalizedText(
                          'noPrefixFound', widget.languageCode)),
                    )
                  : ListView.builder(
                      itemCount: _filteredPrefixes.length,
                      itemBuilder: (context, index) {
                        final prefix = _filteredPrefixes[index];
                        final isSelected =
                            prefix['code'] == widget.currentPrefix;
                        final localizedCountryName = getLocalizedCountryName(
                            prefix['country']!, widget.languageCode);

                        return InkWell(
                          onTap: () =>
                              Navigator.of(context).pop(prefix['code']),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                            child: Row(
                              children: [
                                Text(
                                  prefix['emoji']!,
                                  style: const TextStyle(fontSize: 20),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  prefix['code']!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: isSelected
                                            ? Theme.of(context)
                                                .colorScheme
                                                .primary
                                            : null,
                                      ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    localizedCountryName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                        ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (isSelected)
                                  Icon(
                                    Icons.check,
                                    color:
                                        Theme.of(context).colorScheme.primary,
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
    );
  }
}
