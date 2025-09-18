import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:jetcv__utenti/models/user_model.dart';
import 'package:jetcv__utenti/models/cv_model.dart';
import 'package:jetcv__utenti/models/country_model.dart';
import 'package:jetcv__utenti/services/user_service.dart';
import 'package:jetcv__utenti/services/cv_edge_service.dart';
import 'package:jetcv__utenti/services/country_service.dart';
import 'package:jetcv__utenti/services/locale_service.dart';
import 'package:jetcv__utenti/services/certification_service.dart';
import 'package:jetcv__utenti/screens/cv/blockchain_info_page.dart';
import 'package:jetcv__utenti/screens/cv/open_badges_page.dart';
import 'package:jetcv__utenti/screens/cv/personal_info_page.dart';
import 'package:jetcv__utenti/services/linkedin_service.dart';
import 'package:jetcv__utenti/services/legal_entity_service.dart';
// import 'package:jetcv__utenti/services/image_cache_service.dart';
// import 'package:jetcv__utenti/services/base64_image_service.dart';
import 'package:jetcv__utenti/l10n/app_localizations.dart';
import 'package:jetcv__utenti/widgets/main_layout.dart';
import 'package:jetcv__utenti/widgets/attached_media_widget.dart';
import 'package:jetcv__utenti/widgets/open_badge_button.dart';
import 'package:jetcv__utenti/widgets/certification_card.dart' as reusable;

// import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class CVViewPage extends StatefulWidget {
  final String? cvUserId;

  const CVViewPage({
    super.key,
    this.cvUserId,
  });

  @override
  State<CVViewPage> createState() => _CVViewPageState();
}

class _CVViewPageState extends State<CVViewPage> {
  CvModel? _cv;
  UserModel? _currentUser; // User corrente per controllare l'ownership
  CountryModel? _country; // Paese specifico del CV
  String? _publicCvUrl; // URL pubblico del CV generato dalla edge function
  bool _isLoading = true;
  String? _errorMessage;

  // Certifications data
  List<UserCertificationDetail> _certifications = [];
  bool _certificationsLoading = false;
  String? _certificationsError;
  bool _isMostRecentFirst =
      true; // true = più recenti prima, false = meno recenti prima

  // Legal entities cache
  Map<String, String> _legalEntityNames = {};
  // Legal entities logos cache
  Map<String, String?> _legalEntityLogos = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Get current user first
      _currentUser = await UserService.getCurrentUser();
      if (_currentUser == null) {
        setState(() {
          _errorMessage = 'User not authenticated'; // TODO: localize
          _isLoading = false;
        });
        return;
      }

      // Determine which user's CV to load
      final targetUserId = widget.cvUserId ?? _currentUser!.idUser;

      // Load CV data using CvEdgeService
      final cvResponse = await CvEdgeService.getUserCv(targetUserId);

      if (cvResponse.success) {
        if (cvResponse.data != null) {
          // CV found - load it successfully
          _cv = cvResponse.data!;
        } else {
          // API call successful but no CV found - show call-to-action
          _cv = null; // Ensure _cv is null to trigger call-to-action
        }
      } else {
        // API call failed - show error message
        debugPrint('❌ Failed to load CV: ${cvResponse.error}');
        setState(() {
          _errorMessage =
              cvResponse.error ?? 'Failed to load CV data'; // TODO: localize
          _isLoading = false;
        });
        return;
      }

      // Load country data if CV exists and has country code
      if (_cv != null &&
          _cv!.countryCode != null &&
          _cv!.countryCode!.isNotEmpty) {
        final countryResponse =
            await CountryService.getCountryByCode(_cv!.countryCode!);

        if (countryResponse.success && countryResponse.data != null) {
          _country = countryResponse.data!;
        } else {
          // Country not found, but don't fail the whole page load
          debugPrint('❌ Country not found for code: "${_cv!.countryCode}"');
        }
      }

      setState(() {
        _isLoading = false;
      });

      // Only load additional data if CV exists
      if (_cv != null) {
        // Pre-carica l'URL pubblico in background per l'anteprima
        _getPublicCvUrl();

        // Load certifications data
        _loadCertifications();
      }
    } catch (e) {
      debugPrint('Error loading CV data: $e');
      setState(() {
        _errorMessage = 'Error loading CV data: $e'; // TODO: localize
        _isLoading = false;
      });
    }
  }

  Future<void> _loadCertifications() async {
    setState(() {
      _certificationsLoading = true;
      _certificationsError = null;
    });

    try {
      final response =
          await CertificationService.getUserCertificationsDetails();

      if (response.success && response.data != null) {
        // Filter only accepted certifications and sort by date
        final acceptedCertifications =
            List<UserCertificationDetail>.from(response.data!)
                .where((cert) => cert.certificationUser.status == 'accepted')
                .toList()
              ..sort((a, b) => _isMostRecentFirst
                  ? b.certificationUser.createdAt
                      .compareTo(a.certificationUser.createdAt)
                  : a.certificationUser.createdAt
                      .compareTo(b.certificationUser.createdAt));

        setState(() {
          _certifications = acceptedCertifications;
          _certificationsLoading = false;
        });
        // Precarica i logo delle legal entities
        _preloadLegalEntityLogos();
      } else {
        setState(() {
          _certificationsError = response.error ??
              AppLocalizations.of(context)!.errorLoadingCertifications;
          _certificationsLoading = false;
        });
        debugPrint('❌ Failed to load certifications: ${response.error}');
      }
    } catch (e) {
      setState(() {
        _certificationsError =
            'Error loading certifications: $e'; // TODO: localize
        _certificationsLoading = false;
      });
      debugPrint('Error loading certifications: $e');
    }
  }

  void _toggleSortOrder() {
    setState(() {
      _isMostRecentFirst = !_isMostRecentFirst;
      // Re-sort the existing certifications
      _certifications.sort((a, b) => _isMostRecentFirst
          ? b.certificationUser.createdAt
              .compareTo(a.certificationUser.createdAt)
          : a.certificationUser.createdAt
              .compareTo(b.certificationUser.createdAt));
    });
  }

  Widget _buildSortDropdown() {
    return PopupMenuButton<String>(
      onSelected: (String value) {
        if (value == 'toggle') {
          _toggleSortOrder();
        }
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<String>(
          value: 'toggle',
          child: Row(
            children: [
              Icon(
                _isMostRecentFirst ? Icons.arrow_upward : Icons.arrow_downward,
                size: 16,
                color: Colors.green,
              ),
              const SizedBox(width: 8),
              Text(
                _isMostRecentFirst
                    ? AppLocalizations.of(context)!.lessRecent
                    : AppLocalizations.of(context)!.mostRecent,
                style: TextStyle(
                  color: Colors.grey.shade800,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withValues(alpha: 0.3),
              spreadRadius: 0,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _isMostRecentFirst
                  ? AppLocalizations.of(context)!.mostRecent
                  : AppLocalizations.of(context)!.lessRecent,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              color: Colors.white,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  CountryModel? _getCountryByCode(String? countryCode) {
    // Ora restituiamo direttamente il paese caricato se corrisponde
    if (countryCode == null || _country == null) return null;
    if (_country!.code == countryCode) {
      return _country;
    }
    return null;
  }

  String _calculateAge(DateTime? birthDate) {
    if (birthDate == null) return '';
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age.toString();
  }

  String _formatFormalBirthInfo() {
    if (_cv?.dateOfBirth == null) return '';

    final birthDate = DateTime.tryParse(_cv!.dateOfBirth!);
    if (birthDate == null) return '';

    final age = _calculateAge(birthDate);

    return '${birthDate.day.toString().padLeft(2, '0')}/${birthDate.month.toString().padLeft(2, '0')}/${birthDate.year} ($age ${AppLocalizations.of(context)!.years})';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _generateCVSerial() {
    // serialNumber is now required and has a default value from the database
    return _cv!.serialNumber;
  }

  /// Builds address string avoiding duplication when city == state
  String _buildAddressString() {
    List<String> addressParts = [];

    // Add address street
    if (_cv!.address != null && _cv!.address!.isNotEmpty) {
      addressParts.add(_cv!.address!);
    }

    // Add city
    if (_cv!.city != null && _cv!.city!.isNotEmpty) {
      addressParts.add(_cv!.city!);
    }

    // Add state only if different from city
    if (_cv!.state != null &&
        _cv!.state!.isNotEmpty &&
        _cv!.state != _cv!.city) {
      addressParts.add(_cv!.state!);
    }

    // Add postal code
    if (_cv!.postalCode != null && _cv!.postalCode!.isNotEmpty) {
      addressParts.add(_cv!.postalCode!);
    }

    return addressParts.join(', ');
  }

  String _toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  /// Ottiene il nome localizzato di una lingua
  String _getLocalizedLanguageName(String languageCode) {
    final localizations = AppLocalizations.of(context)!;

    // Prova a ottenere il nome localizzato usando le stringhe di localizzazione
    try {
      switch (languageCode.toLowerCase()) {
        case 'en':
          return localizations.languageName_en;
        case 'it':
          return localizations.languageName_it;
        case 'fr':
          return localizations.languageName_fr;
        case 'es':
          return localizations.languageName_es;
        case 'de':
          return localizations.languageName_de;
        case 'pt':
          return localizations.languageName_pt;
        case 'ru':
          return localizations.languageName_ru;
        case 'zh':
          return localizations.languageName_zh;
        case 'ja':
          return localizations.languageName_ja;
        case 'ko':
          return localizations.languageName_ko;
        case 'ar':
          return localizations.languageName_ar;
        case 'hi':
          return localizations.languageName_hi;
        case 'tr':
          return localizations.languageName_tr;
        case 'pl':
          return localizations.languageName_pl;
        case 'nl':
          return localizations.languageName_nl;
        default:
          // Fallback al nome nativo se non è localizzato
          return LocaleService.languageNames[languageCode] ??
              languageCode.toUpperCase();
      }
    } catch (e) {
      // Fallback al nome nativo se c'è un errore
      return LocaleService.languageNames[languageCode] ??
          languageCode.toUpperCase();
    }
  }

  /// Ottiene il nome localizzato di un paese
  String _getLocalizedCountryName(CountryModel country) {
    final localizations = AppLocalizations.of(context)!;

    // Prova a ottenere il nome localizzato usando le stringhe di localizzazione
    try {
      switch (country.code.toUpperCase()) {
        case 'IT':
          return localizations.countryName_IT;
        case 'FR':
          return localizations.countryName_FR;
        case 'DE':
          return localizations.countryName_DE;
        case 'ES':
          return localizations.countryName_ES;
        case 'GB':
          return localizations.countryName_GB;
        case 'US':
          return localizations.countryName_US;
        case 'CA':
          return localizations.countryName_CA;
        case 'AU':
          return localizations.countryName_AU;
        case 'JP':
          return localizations.countryName_JP;
        case 'CN':
          return localizations.countryName_CN;
        case 'BR':
          return localizations.countryName_BR;
        case 'IN':
          return localizations.countryName_IN;
        case 'RU':
          return localizations.countryName_RU;
        case 'MX':
          return localizations.countryName_MX;
        case 'AR':
          return localizations.countryName_AR;
        case 'NL':
          return localizations.countryName_NL;
        case 'CH':
          return localizations.countryName_CH;
        case 'AT':
          return localizations.countryName_AT;
        case 'BE':
          return localizations.countryName_BE;
        case 'PT':
          return localizations.countryName_PT;
        default:
          // Fallback al nome originale del paese se non è localizzato
          return country.name;
      }
    } catch (e) {
      // Se c'è un errore, usa il fallback
      return country.name;
    }
  }

  /// Ottiene la label localizzata per le informazioni delle certificazioni
  String _getLocalizedCertificationLabel(String originalLabel) {
    final localizations = AppLocalizations.of(context)!;

    // Prova a localizzare le label più comuni
    try {
      switch (originalLabel.toLowerCase().trim()) {
        case 'titolo':
          return localizations.certificationTitle;
        case 'esito':
          return localizations.certificationOutcome;
        case 'dettaglio':
        case 'dettagli':
          return localizations.certificationDetails;
        default:
          // Fallback alla label originale se non è localizzata
          return originalLabel;
      }
    } catch (e) {
      // Se c'è un errore, usa il fallback
      return originalLabel;
    }
  }

  /// Ottiene il nome localizzato del tipo di certificazione
  String _getLocalizedCertificationType(String originalType) {
    final localizations = AppLocalizations.of(context)!;

    // Normalizza il nome del tipo (rimuove spazi extra, converte in lowercase)
    final normalizedType =
        originalType.toLowerCase().trim().replaceAll(RegExp(r'\s+'), '_');

    // Prova a localizzare i tipi di certificazione
    try {
      switch (normalizedType) {
        case 'attestato_di_frequenza':
          return localizations.certType_attestato_di_frequenza;
        case 'programma_certificato':
          return localizations.certType_programma_certificato;
        case 'dottorato_di_ricerca':
          return localizations.certType_dottorato_di_ricerca;
        case 'diploma_its':
          return localizations.certType_diploma_its;
        case 'workshop':
          return localizations.certType_workshop;
        case 'risultato_sportivo':
          return localizations.certType_risultato_sportivo;
        case 'corso_specifico':
          return localizations.certType_corso_specifico;
        case 'team_builder':
          return localizations.certType_team_builder;
        case 'corso_di_aggiornamento':
          return localizations.certType_corso_di_aggiornamento;
        case 'speech':
          return localizations.certType_speech;
        case 'diploma':
          return localizations.certType_diploma;
        case 'master':
          return localizations.certType_master;
        case 'congresso':
          return localizations.certType_congresso;
        case 'corso_specialistico':
          return localizations.certType_corso_specialistico;
        case 'certificazione':
          return localizations.certType_certificazione;
        case 'laurea':
          return localizations.certType_laurea;
        case 'moderatore':
          return localizations.certType_moderatore;
        case 'ruolo_professionale':
          return localizations.certType_ruolo_professionale;
        case 'volontariato':
          return localizations.certType_volontariato;
        case 'certificato_di_competenza':
          return localizations.certType_certificato_di_competenza;
        case 'corso_di_formazione':
          return localizations.certType_corso_di_formazione;
        case 'certificazione_professionale':
          return localizations.certType_certificazione_professionale;
        case 'patente':
          return localizations.certType_patente;
        case 'abilitazione':
          return localizations.certType_abilitazione;
        default:
          // Fallback al nome originale se non è localizzato
          return originalType;
      }
    } catch (e) {
      // Se c'è un errore, usa il fallback
      return originalType;
    }
  }

  // Future<void> _shareCV() async {
  //   final localizations = AppLocalizations.of(context)!;

  //   try {
  //     // Get or generate public CV URL
  //     final cvUrl = await _getPublicCvUrl();
  //     if (cvUrl == null) {
  //       if (mounted) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             content: Text(
  //                 'Errore nella generazione dell\'URL pubblico'), // TODO: localize
  //             backgroundColor: Colors.red,
  //             behavior: SnackBarBehavior.floating,
  //           ),
  //         );
  //       }
  //       return;
  //     }

  //     if (kIsWeb) {
  //       // Su web: copia negli appunti e mostra messaggio
  //       await Clipboard.setData(ClipboardData(text: cvUrl));

  //       if (mounted) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             content: Row(
  //               children: [
  //                 Icon(
  //                   Icons.check_circle,
  //                   color: Colors.white,
  //                   size: 20,
  //                 ),
  //                 const SizedBox(width: 8),
  //                 Expanded(
  //                   child: Text(AppLocalizations.of(context)!.cvLinkCopied),
  //                 ),
  //               ],
  //             ),
  //             backgroundColor: Colors.green,
  //             behavior: SnackBarBehavior.floating,
  //             duration: const Duration(seconds: 3),
  //           ),
  //         );
  //       }
  //     } else {
  //       // Su mobile: apri la condivisione nativa
  //       await Share.share(
  //         cvUrl,
  //         subject: localizations.shareCV,
  //       );

  //       if (mounted) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             content: Text(localizations.cvShared),
  //             backgroundColor: Colors.green,
  //             behavior: SnackBarBehavior.floating,
  //             duration: const Duration(seconds: 2),
  //           ),
  //         );
  //       }
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text(localizations.shareError(e.toString())),
  //           backgroundColor: Colors.red,
  //           behavior: SnackBarBehavior.floating,
  //         ),
  //       );
  //     }
  //   }
  // }

  /// Recupera o genera l'URL pubblico del CV tramite la edge function
  Future<String?> _getPublicCvUrl() async {
    // Se abbiamo già l'URL cached, restituiscilo
    if (_publicCvUrl != null) {
      return _publicCvUrl;
    }

    try {
      // Chiama la edge function per generare l'URL pubblico
      final response = await CvEdgeService.generatePublicCvUrl();

      if (response.success && response.data != null) {
        _publicCvUrl = response.data!['publicUrl'];

        // Aggiorna l'UI per mostrare il nuovo URL nell'anteprima
        if (mounted) {
          setState(() {});
        }

        return _publicCvUrl;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return MainLayout(
        currentRoute: '/cv',
        title: AppLocalizations.of(context)!.viewMyCV,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_cv == null) {
      return MainLayout(
        currentRoute: '/cv',
        title: AppLocalizations.of(context)!.viewMyCV,
        child: _buildNoCVState(),
      );
    }

    final country = _getCountryByCode(_cv!.countryCode);

    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;
    // final isDesktop = screenWidth >= 1024; // reserved for future responsive tweaks

    // Responsive padding and spacing
    final pagePadding = isMobile
        ? 16.0
        : isTablet
            ? 20.0
            : 24.0;
    final sectionSpacing = isMobile
        ? 20.0
        : isTablet
            ? 24.0
            : 32.0;
    // final smallSpacing = isMobile
    //     ? 16.0
    //     : isTablet
    //         ? 20.0
    //         : 24.0;

    return MainLayout(
      currentRoute: '/cv',
      title: AppLocalizations.of(context)!.viewMyCV,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(pagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Share CV section (moved to top)
            // _buildShareSection(),

            // SizedBox(height: smallSpacing),

            // Main profile section (simplified with blockchain cert + openbadges)
            _buildMainProfileSection(country),

            SizedBox(height: sectionSpacing),

            // Personal information section (renamed and expanded)
            _buildPersonalInformationSection(),

            SizedBox(height: sectionSpacing),

            // Autodichiarazioni section
            _buildAutodichiarazioniSection(),

            SizedBox(height: sectionSpacing),

            // Certifications timeline section
            _buildCertificationsSection(),

            SizedBox(height: sectionSpacing),
          ],
        ),
      ),
    );
  }

  /// Standard responsive wrapper for all sections
  Widget _buildStandardSectionWrapper({
    required Widget child,
    EdgeInsets? customPadding,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;
    final isDesktop = screenWidth >= 1024;

    // Responsive constraints
    double? maxWidth;
    if (isMobile) {
      maxWidth = null; // Full width on mobile
    } else if (isTablet) {
      maxWidth = 750;
    } else if (isDesktop) {
      maxWidth = 900;
    }

    final padding = customPadding ??
        EdgeInsets.symmetric(
          horizontal: isMobile ? 16.0 : 24.0,
          vertical: isMobile ? 16.0 : 20.0,
        );

    return Center(
      child: Container(
        width: double.infinity,
        constraints:
            maxWidth != null ? BoxConstraints(maxWidth: maxWidth) : null,
        padding: padding,
        child: child,
      ),
    );
  }

  Widget _buildMainProfileSection(CountryModel? country) {
    final localizations = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;

    final spacing = isMobile
        ? 20.0
        : isTablet
            ? 24.0
            : 28.0;

    return _buildStandardSectionWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Blockchain certification badge with CV dates
          _buildSimplifiedBlockchainBadge(localizations),

          SizedBox(height: spacing),

          // OpenBadge section integrated
          _buildIntegratedOpenBadgeSection(),
        ],
      ),
    );
  }

  /// Personal Information section with profile picture, name, birth date, and contact info
  Widget _buildPersonalInformationSection() {
    final localizations = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;

    final cardPadding = isMobile
        ? 20.0
        : isTablet
            ? 24.0
            : 28.0;
    final sectionSpacing = isMobile
        ? 20.0
        : isTablet
            ? 24.0
            : 28.0;

    return _buildStandardSectionWrapper(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.shade200.withValues(alpha: 0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Professional title without icon
              Text(
                "Informazioni Personali",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),

              SizedBox(height: sectionSpacing),

              // Profile picture and name section
              Center(
                child: Column(
                  children: [
                    // Profile picture
                    _buildEnhancedProfilePicture(),

                    SizedBox(height: 16),

                    // Name and serial number
                    Text(
                      _toTitleCase(
                          '${_cv!.firstName ?? ''} ${_cv!.lastName ?? ''}'
                              .trim()),
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface,
                                letterSpacing: 0.5,
                              ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              SizedBox(height: sectionSpacing),

              // Birth date
              if (_cv!.dateOfBirth != null) ...[
                _buildContactItem(
                  icon: Icons.cake,
                  label: localizations.dateOfBirth,
                  value: _formatFormalBirthInfo(),
                ),
                const SizedBox(height: 16),
              ],

              // Email
              if (_cv!.email != null) ...[
                _buildContactItem(
                  icon: Icons.email,
                  label: localizations.email,
                  value: _cv!.email!,
                ),
                const SizedBox(height: 16),
              ],

              // Phone
              if (_cv!.phone != null) ...[
                _buildContactItem(
                  icon: Icons.phone,
                  label: localizations.phone,
                  value: _cv!.phone!,
                ),
                const SizedBox(height: 16),
              ],

              // Address
              if (_cv!.address != null) ...[
                _buildContactItem(
                  icon: Icons.home,
                  label: localizations.address,
                  value: _toTitleCase(_buildAddressString()),
                ),
                const SizedBox(height: 16),
              ],

              // Nationalities
              if (_cv!.nationalityCodes != null &&
                  _cv!.nationalityCodes!.isNotEmpty) ...[
                _buildNationalitiesItem(
                  icon: Icons.public,
                  label: AppLocalizations.of(context)!.nationality,
                  nationalityCodes: _cv!.nationalityCodes!,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;

    final iconSize = isMobile
        ? 18.0
        : isTablet
            ? 19.0
            : 20.0;
    final spacing = isMobile
        ? 8.0
        : isTablet
            ? 10.0
            : 12.0;
    final labelFontSize = isMobile
        ? 12.0
        : isTablet
            ? 13.0
            : 14.0;
    final valueFontSize = isMobile
        ? 14.0
        : isTablet
            ? 15.0
            : 16.0;
    final verticalSpacing = isMobile
        ? 2.0
        : isTablet
            ? 3.0
            : 4.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: iconSize,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        SizedBox(width: spacing),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                      fontSize: labelFontSize,
                    ),
              ),
              SizedBox(height: verticalSpacing),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: valueFontSize,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNationalitiesItem({
    required IconData icon,
    required String label,
    required List<String> nationalityCodes,
  }) {
    return FutureBuilder<List<CountryModel>>(
      future: _loadNationalities(nationalityCodes),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: 20,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(height: 4),
                    const CircularProgressIndicator(strokeWidth: 2),
                  ],
                ),
              ),
            ],
          );
        }

        final countries = snapshot.data ?? [];
        if (countries.isEmpty) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: 20,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(context)!.noNationalitySpecified,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.italic,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 20,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: countries.map((country) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .outline
                                .withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (country.emoji != null) ...[
                              Text(
                                country.emoji!,
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(width: 4),
                            ],
                            Text(
                              _getLocalizedCountryName(country),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<List<CountryModel>> _loadNationalities(
      List<String> nationalityCodes) async {
    final List<CountryModel> countries = [];

    for (final code in nationalityCodes) {
      try {
        final response = await CountryService.getCountryByCode(code);
        if (response.success && response.data != null) {
          countries.add(response.data!);
        }
      } catch (e) {}
    }

    return countries;
  }

  Widget _buildAutodichiarazioniSection() {
    final languageCodes = _cv?.languageCodes;

    return _buildStandardSectionWrapper(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.shade200.withValues(alpha: 0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Professional title without icon
              Text(
                AppLocalizations.of(context)!.autodichiarazioni,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 20),

              // Languages subsection
              if (languageCodes != null && languageCodes.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(
                      Icons.translate,
                      size: 20,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context)!.spokenLanguages,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: languageCodes.map((languageCode) {
                    final languageName =
                        _getLocalizedLanguageName(languageCode);
                    final languageEmoji =
                        LocaleService.languageEmojis[languageCode];

                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest
                            .withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .outline
                              .withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (languageEmoji != null) ...[
                            Text(
                              languageEmoji,
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(width: 4),
                          ],
                          Text(
                            languageName,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ] else ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .outline
                          .withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.noLanguageSpecified,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCertificationsSection() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;

    final cardPadding = isMobile
        ? 16.0
        : isTablet
            ? 20.0
            : 24.0;
    final titleFontSize = isMobile
        ? 20.0
        : isTablet
            ? 24.0
            : 28.0;
    final subtitleFontSize = isMobile
        ? 12.0
        : isTablet
            ? 13.0
            : 14.0;
    final buttonFontSize = isMobile
        ? 10.0
        : isTablet
            ? 11.0
            : 12.0;
    final sectionSpacing = isMobile
        ? 20.0
        : isTablet
            ? 24.0
            : 32.0;
    final smallSpacing = isMobile
        ? 12.0
        : isTablet
            ? 14.0
            : 16.0;

    // Show loading state
    if (_certificationsLoading) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey.shade50,
          ),
          child: Padding(
            padding: EdgeInsets.all(cardPadding),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.certifications,
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: isMobile
                              ? 8
                              : isTablet
                                  ? 10
                                  : 12,
                          vertical: isMobile
                              ? 4
                              : isTablet
                                  ? 5
                                  : 6),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withValues(alpha: 0.3),
                            spreadRadius: 0,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.mostRecent,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: buttonFontSize,
                              letterSpacing: 0.2,
                            ),
                          ),
                          SizedBox(width: isMobile ? 2 : 4),
                          Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.white,
                            size: isMobile
                                ? 14
                                : isTablet
                                    ? 15
                                    : 16,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: sectionSpacing),
                const Center(
                  child: CircularProgressIndicator(),
                ),
                SizedBox(height: smallSpacing),
                Text(
                  AppLocalizations.of(context)!.loadingCertifications,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: subtitleFontSize,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Show error state
    if (_certificationsError != null) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey.shade50,
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      AppLocalizations.of(context)!.certifications,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const Spacer(),
                    _buildSortDropdown(),
                  ],
                ),
                const SizedBox(height: 32),
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Colors.red.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)!.errorLoadingCertifications,
                  style: TextStyle(
                    color: Colors.red.shade600,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _certificationsError!,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadCertifications,
                  child: Text(AppLocalizations.of(context)!.retry),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Show empty state
    if (_certifications.isEmpty) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey.shade50,
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      AppLocalizations.of(context)!.certifications,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const Spacer(),
                    _buildSortDropdown(),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '0 ${AppLocalizations.of(context)!.verifiedCertifications}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 32),
                Icon(
                  Icons.workspace_premium_outlined,
                  size: 48,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)!.noCertificationsFound,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.yourVerifiedCertifications,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return _buildStandardSectionWrapper(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.shade200.withValues(alpha: 0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with title and sort button - matching image exactly
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.certifications,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_certifications.length} ${AppLocalizations.of(context)!.verifiedCertifications}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  _buildSortDropdown(),
                ],
              ),
              const SizedBox(height: 32),

              // Timeline with certifications - each item aligned independently
              Column(
                children: (_isMostRecentFirst
                        ? _certifications
                        : _certifications.reversed.toList())
                    .asMap()
                    .entries
                    .map((entry) {
                  final index = entry.key;
                  final cert = entry.value;
                  final isLast = index == _certifications.length - 1;

                  return IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Timeline column with date and node - fixed position
                        SizedBox(
                          width: isMobile
                              ? 100
                              : isTablet
                                  ? 110
                                  : 120,
                          child: Column(
                            children: [
                              // Date bubble - fixed at top
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: isMobile
                                        ? 6
                                        : isTablet
                                            ? 8
                                            : 10,
                                    vertical: isMobile
                                        ? 3
                                        : isTablet
                                            ? 4
                                            : 6),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _formatCertificationDate(
                                      cert.certificationUser.createdAt),
                                  style: TextStyle(
                                    color: Colors.blue.shade800,
                                    fontWeight: FontWeight.w600,
                                    fontSize: isMobile
                                        ? 12
                                        : isTablet
                                            ? 14
                                            : 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),

                              SizedBox(height: 8),

                              // Timeline node - fixed position
                              Container(
                                width: isMobile
                                    ? 8
                                    : isTablet
                                        ? 10
                                        : 12,
                                height: isMobile
                                    ? 8
                                    : isTablet
                                        ? 10
                                        : 12,
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                ),
                              ),

                              // Vertical line below node to bottom of card
                              Expanded(
                                child: Container(
                                  width: 2,
                                  color: Colors.grey.shade300,
                                  margin: const EdgeInsets.only(top: 12),
                                ),
                              ),
                              // Extra spacer line to increase inter-card spacing (except for last)
                              if (!isLast)
                                Container(
                                  width: 2,
                                  height: isMobile
                                      ? 40
                                      : isTablet
                                          ? 48
                                          : 56,
                                  color: Colors.grey.shade300,
                                ),
                            ],
                          ),
                        ),

                        SizedBox(
                            width: isMobile
                                ? 12
                                : isTablet
                                    ? 16
                                    : 20),

                        // Certification card - expands as needed
                        Expanded(
                          child: reusable.CertificationCard(
                            certification: cert,
                            showImageHeader: true,
                            showLegalEntityLogo: true,
                            showMediaSection: true,
                            showOpenBadgeButton: true,
                            showLinkedInButton: true,
                            showCertifiedUserName:
                                false, // Hide certified user name in CV view
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatCertificationDate(DateTime date) {
    final localizations = AppLocalizations.of(context)!;
    final months = [
      localizations.monthJan,
      localizations.monthFeb,
      localizations.monthMar,
      localizations.monthApr,
      localizations.monthMay,
      localizations.monthJun,
      localizations.monthJul,
      localizations.monthAug,
      localizations.monthSep,
      localizations.monthOct,
      localizations.monthNov,
      localizations.monthDec,
    ];

    final day = date.day.toString().padLeft(2, '0');
    final month = months[date.month - 1];
    final year = date.year;

    return '$day $month $year';
  }

  // Deprecated method removed - now using reusable.CertificationCard widget
  /*
  Widget _buildCertificationCard(UserCertificationDetail cert) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;

    final imageHeight = isMobile
        ? 80.0
        : isTablet
            ? 100.0
            : 120.0;
    final cardPadding = isMobile
        ? 12.0
        : isTablet
            ? 14.0
            : 16.0;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image section with relevant example images
          Container(
            height: imageHeight,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: _buildCertificationImage(cert),
            ),
          ),

          Padding(
            padding: EdgeInsets.all(cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and date - responsive layout
                isMobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Serial number badge
                          if (cert.certificationUser.serialNumber != null)
                            Container(
                              margin:
                                  EdgeInsets.only(bottom: isMobile ? 8 : 12),
                              padding: EdgeInsets.symmetric(
                                horizontal: isMobile ? 8 : 10,
                                vertical: isMobile ? 4 : 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.green.shade300,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.tag,
                                    size: isMobile ? 14 : 16,
                                    color: Colors.green.shade700,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    '${AppLocalizations.of(context)!.serialNumber}: ${cert.certificationUser.serialNumber}',
                                    style: TextStyle(
                                      fontSize: isMobile ? 11 : 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.green.shade800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          // Certification type
                          if (cert.certification?.category?.name != null &&
                              cert.certification!.category!.name.isNotEmpty)
                            Text(
                              _getLocalizedCertificationType(
                                  cert.certification!.category!.name),
                              style: TextStyle(
                                fontSize: isMobile
                                    ? 16
                                    : isTablet
                                        ? 18
                                        : 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          SizedBox(height: isMobile ? 8 : 12),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: isMobile
                                    ? 8
                                    : isTablet
                                        ? 9
                                        : 10,
                                vertical: isMobile
                                    ? 4
                                    : isTablet
                                        ? 5
                                        : 6),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _formatCertificationDate(
                                  cert.certificationUser.createdAt),
                              style: TextStyle(
                                color: Colors.blue.shade800,
                                fontWeight: FontWeight.w600,
                                fontSize: isMobile
                                    ? 11
                                    : isTablet
                                        ? 12
                                        : 13,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: isMobile
                                    ? 8
                                    : isTablet
                                        ? 9
                                        : 10,
                                vertical: isMobile
                                    ? 4
                                    : isTablet
                                        ? 5
                                        : 6),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _formatCertificationDate(
                                  cert.certificationUser.createdAt),
                              style: TextStyle(
                                color: Colors.blue.shade800,
                                fontWeight: FontWeight.w600,
                                fontSize: isMobile
                                    ? 11
                                    : isTablet
                                        ? 12
                                        : 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                SizedBox(
                    height: isMobile
                        ? 12
                        : isTablet
                            ? 14
                            : 16),

                // Serial number badge and certification type for desktop
                if (!isMobile) ...[
                  // Serial number badge
                  if (cert.certificationUser.serialNumber != null)
                    Container(
                      margin: EdgeInsets.only(bottom: isTablet ? 8 : 12),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isTablet ? 8 : 10,
                              vertical: isTablet ? 4 : 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.green.shade300,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.tag,
                                  size: isTablet ? 14 : 16,
                                  color: Colors.green.shade700,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  '${AppLocalizations.of(context)!.serialNumber}: ${cert.certificationUser.serialNumber}',
                                  style: TextStyle(
                                    fontSize: isTablet ? 11 : 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green.shade800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  // Certification type for desktop
                  if (cert.certification?.category?.name != null &&
                      cert.certification!.category!.name.isNotEmpty)
                    Container(
                      margin: EdgeInsets.only(bottom: isTablet ? 8 : 12),
                      child: Text(
                        _getLocalizedCertificationType(
                            cert.certification!.category!.name),
                        style: TextStyle(
                          fontSize: isTablet ? 18 : 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                ],

                // Issuer with circular logo
                Row(
                  children: [
                    Container(
                      width: isMobile
                          ? 24
                          : isTablet
                              ? 26
                              : 28,
                      height: isMobile
                          ? 24
                          : isTablet
                              ? 26
                              : 28,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.school,
                        size: isMobile
                            ? 14
                            : isTablet
                                ? 15
                                : 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(
                        width: isMobile
                            ? 8
                            : isTablet
                                ? 9
                                : 10),
                    Expanded(
                      child: Text(
                        (cert.certification?.category?.name != null
                                ? _getLocalizedCertificationType(
                                    cert.certification!.category!.name)
                                : null) ??
                            AppLocalizations.of(context)!.certifyingBody,
                        style: TextStyle(
                          fontSize: isMobile
                              ? 12
                              : isTablet
                                  ? 13
                                  : 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                    height: isMobile
                        ? 8
                        : isTablet
                            ? 10
                            : 12),

                // Legal Entity and Certifier info
                // Legal Entity name with logo (moved first)
                FutureBuilder<String>(
                  future: _getOrganizationName(cert),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      return Row(
                        children: [
                          // Legal Entity logo from database
                          _buildLegalEntityLogo(cert, isMobile, isTablet),
                          SizedBox(
                              width: isMobile
                                  ? 6
                                  : isTablet
                                      ? 7
                                      : 8),
                          Expanded(
                            child: Text(
                              'Legal Entity: ${snapshot.data}',
                              style: TextStyle(
                                fontSize: isMobile
                                    ? 14
                                    : isTablet
                                        ? 15
                                        : 16,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                SizedBox(
                    height: isMobile
                        ? 6
                        : isTablet
                            ? 7
                            : 8),

                // Certifier name (moved second with person icon)
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: isMobile
                          ? 14
                          : isTablet
                              ? 15
                              : 16,
                      color: Colors.grey.shade600,
                    ),
                    SizedBox(
                        width: isMobile
                            ? 6
                            : isTablet
                                ? 7
                                : 8),
                    Expanded(
                      child: FutureBuilder<String>(
                        future: _getCertifierDisplayName(cert),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Text(
                              '${AppLocalizations.of(context)!.certifier}: ${snapshot.data}',
                              style: TextStyle(
                                fontSize: isMobile
                                    ? 12
                                    : isTablet
                                        ? 13
                                        : 14,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            );
                          }
                          return Text(
                            '${AppLocalizations.of(context)!.certifier}: ${AppLocalizations.of(context)!.certifyingBody}',
                            style: TextStyle(
                              fontSize: isMobile
                                  ? 12
                                  : isTablet
                                      ? 13
                                      : 14,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          );
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(
                    height: isMobile
                        ? 12
                        : isTablet
                            ? 14
                            : 16),

                // Description from category information
                if (cert.certification?.categoryInformation.isNotEmpty ==
                    true) ...[
                  // Mostra tutte le informazioni della categoria
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: cert.certification!.categoryInformation
                        .where((info) =>
                            info.label != null &&
                            info.value != null &&
                            info.label!.toLowerCase().trim() != 'codice')
                        .map((info) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Text(
                          '${_getLocalizedCertificationLabel(info.label!)}: ${info.value}',
                          style: TextStyle(
                            fontSize: isMobile
                                ? 14
                                : isTablet
                                    ? 15
                                    : 16,
                            color: Colors.grey.shade700,
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ] else ...[
                  Text(
                    AppLocalizations.of(context)!.verifiedAndAuthenticated,
                    style: TextStyle(
                      fontSize: isMobile
                          ? 14
                          : isTablet
                              ? 15
                              : 16,
                      color: Colors.grey.shade700,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],

                SizedBox(
                    height: isMobile
                        ? 12
                        : isTablet
                            ? 14
                            : 16),

                // Attached Media Section
                _buildAttachedMediaSection(cert),

                // Open Badge Section
                _buildOpenBadgeButtonSection(cert),
              ],
            ),
          ),
        ],
      ),
    );
  }
  */

  Widget _buildAttachedMediaSection(UserCertificationDetail cert) {
    final totalMediaCount =
        cert.media.directMedia.length + cert.media.linkedMedia.length;

    if (totalMediaCount == 0) {
      return const SizedBox.shrink();
    }

    return AttachedMediaWidget(
      certification: cert,
      totalMediaCount: totalMediaCount,
    );
  }

  Widget _buildOpenBadgeButtonSection(UserCertificationDetail cert) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;

    final spacing = isMobile
        ? 12.0
        : isTablet
            ? 14.0
            : 16.0;

    return Container(
      margin: EdgeInsets.only(top: spacing),
      child: Column(
        children: [
          // LinkedIn Integration Button - Centrato con 30% di ampiezza
          Center(
            child: SizedBox(
              width: screenWidth * 0.3, // 30% della larghezza dello schermo
              child: _buildLinkedInButton(cert),
            ),
          ),
          const SizedBox(height: 8),
          // Open Badge Button - Centrato con 30% di ampiezza
          Center(
            child: SizedBox(
              width: screenWidth * 0.3, // 30% della larghezza dello schermo
              child: OpenBadgeButton(
                certification: cert,
                isCompact: false,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCertificationImage(UserCertificationDetail cert) {
    // Determine image type based on certification category
    final categoryName = cert.certification?.category?.name.toLowerCase() ?? '';

    if (categoryName.contains('project') ||
        categoryName.contains('management')) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade50,
              Colors.blue.shade100,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Background pattern
            Positioned.fill(
              child: CustomPaint(
                painter: ProjectManagementPatternPainter(),
              ),
            ),
            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.analytics,
                      size: 32,
                      color: Colors.blue.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.projectManagement,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else if (categoryName.contains('flutter') ||
        categoryName.contains('development') ||
        categoryName.contains('mobile')) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.cyan.shade50,
              Colors.blue.shade100,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Background pattern
            Positioned.fill(
              child: CustomPaint(
                painter: FlutterDevelopmentPatternPainter(),
              ),
            ),
            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.phone_android,
                      size: 32,
                      color: Colors.cyan.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.flutterDevelopment,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.cyan.shade700,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      // Default certification image
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.green.shade50,
              Colors.green.shade100,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.workspace_premium,
                  size: 32,
                  color: Colors.green.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.certified,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'verified':
      case 'completed':
        return Icons.check_circle;
      case 'pending':
      case 'in_progress':
        return Icons.hourglass_empty;
      case 'rejected':
      case 'failed':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'verified':
      case 'completed':
        return Colors.green;
      case 'pending':
      case 'in_progress':
        return Colors.orange;
      case 'rejected':
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    final localizations = AppLocalizations.of(context)!;
    switch (status.toLowerCase()) {
      case 'approved':
        return localizations.approved;
      case 'verified':
        return localizations.verified;
      case 'completed':
        return localizations.completed;
      case 'pending':
        return localizations.pending;
      case 'in_progress':
        return localizations.inProgress;
      case 'rejected':
        return localizations.rejected;
      case 'failed':
        return localizations.failed;
      default:
        return status;
    }
  }

  // Widget _buildShareSection() {
  //   return _buildStandardSectionWrapper(
  //     child: Card(
  //       elevation: 2,
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  //       child: Container(
  //         decoration: BoxDecoration(
  //           borderRadius: BorderRadius.circular(12),
  //           color: Theme.of(context).colorScheme.surface,
  //           border: Border.all(
  //             color:
  //                 Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
  //           ),
  //         ),
  //         child: Padding(
  //           padding: const EdgeInsets.all(20),
  //           child: Row(
  //             children: [
  //               // Icon container
  //               Container(
  //                 padding: const EdgeInsets.all(12),
  //                 decoration: BoxDecoration(
  //                   color: Theme.of(context).colorScheme.primary,
  //                   borderRadius: BorderRadius.circular(8),
  //                 ),
  //                 child: Icon(
  //                   Icons.share,
  //                   color: Colors.white,
  //                   size: 20,
  //                 ),
  //               ),

  //               const SizedBox(width: 16),

  //               // Text content
  //               Expanded(
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Text(
  //                       AppLocalizations.of(context)!.shareCV,
  //                       style: Theme.of(context)
  //                           .textTheme
  //                           .titleMedium
  //                           ?.copyWith(
  //                             fontWeight: FontWeight.w600,
  //                             color: Theme.of(context).colorScheme.onSurface,
  //                           ),
  //                     ),
  //                     const SizedBox(height: 4),
  //                     Text(
  //                       AppLocalizations.of(context)!.verifiedCV,
  //                       style: Theme.of(context).textTheme.bodySmall?.copyWith(
  //                             color: Theme.of(context)
  //                                 .colorScheme
  //                                 .onSurfaceVariant,
  //                             fontWeight: FontWeight.w500,
  //                           ),
  //                     ),
  //                   ],
  //                 ),
  //               ),

  //               const SizedBox(width: 16),

  //               // Share button
  //               MouseRegion(
  //                 cursor: SystemMouseCursors.click,
  //                 child: ElevatedButton.icon(
  //                   onPressed: _shareCV,
  //                   style: ElevatedButton.styleFrom(
  //                     backgroundColor: Theme.of(context).colorScheme.primary,
  //                     foregroundColor: Colors.white,
  //                     padding: const EdgeInsets.symmetric(
  //                       horizontal: 16,
  //                       vertical: 10,
  //                     ),
  //                     shape: RoundedRectangleBorder(
  //                       borderRadius: BorderRadius.circular(8),
  //                     ),
  //                     elevation: 1,
  //                   ),
  //                   icon: Icon(
  //                     kIsWeb ? Icons.copy : Icons.share,
  //                     size: 16,
  //                   ),
  //                   label: Text(
  //                     kIsWeb
  //                         ? AppLocalizations.of(context)!.copyLink
  //                         : AppLocalizations.of(context)!.share,
  //                     style: const TextStyle(
  //                       fontWeight: FontWeight.w500,
  //                       fontSize: 13,
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // New premium design methods

  Widget _buildSerialChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.95),
            Colors.green.shade50.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.green.shade300,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.2),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.fingerprint,
                color: Colors.green.shade700,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                "Seriale",
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _generateCVSerial(),
            style: TextStyle(
              color: Colors.green.shade900,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              fontFamily: 'monospace',
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumBadgeWithSerial(AppLocalizations localizations) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 300),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.green.shade100,
                Colors.green.shade50,
                Colors.teal.shade50,
                Colors.blue.shade50,
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              width: 1.5,
              color: Colors.green.shade400,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withValues(alpha: 0.3),
                spreadRadius: 0,
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.teal.withValues(alpha: 0.15),
                spreadRadius: 0,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Certification header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.green.shade300,
                          Colors.green.shade500,
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withValues(alpha: 0.3),
                          spreadRadius: 0,
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.verified,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      localizations.blockchainCertified,
                      style: TextStyle(
                        color: Colors.green.shade900,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        letterSpacing: 0.3,
                        shadows: [
                          Shadow(
                            color: Colors.green.withValues(alpha: 0.2),
                            offset: const Offset(0, 1),
                            blurRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // NFT Link Section (only if nftMintTransactionUrl is present)
              if (_cv?.nftMintTransactionUrl != null &&
                  _cv!.nftMintTransactionUrl!.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildNftLinkSection(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Costruisce la sezione del Link Blockchain
  Widget _buildNftLinkSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Blockchain Info Button
        GestureDetector(
          onTap: () => _openBlockchainInfo(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: Colors.green.shade300,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.green.shade700,
                  size: 14,
                ),
                const SizedBox(width: 5),
                Text(
                  AppLocalizations.of(context)!.viewBlockchainDetails,
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Apre il Link Blockchain in una nuova finestra
  Future<void> _openNftLink() async {
    if (_cv?.nftMintTransactionUrl != null &&
        _cv!.nftMintTransactionUrl!.isNotEmpty) {
      try {
        await launchUrl(
          Uri.parse(_cv!.nftMintTransactionUrl!),
          mode: LaunchMode.externalApplication,
        );
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  '${AppLocalizations.of(context)!.errorOpeningNftLink}: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  /// Apre la pagina delle informazioni blockchain
  Future<void> _openBlockchainInfo() async {
    if (_cv != null && _certifications.isNotEmpty) {
      // Usa la prima certificazione come esempio
      // In futuro potresti voler passare una certificazione specifica
      final certification = _certifications.first;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BlockchainInfoPage(
            cv: _cv!,
            certification: certification,
          ),
        ),
      );
    }
  }

  Widget _buildEnhancedProfilePicture() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            spreadRadius: 0,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(60),
        child: _cv!.profilePicture != null
            ? Image.network(
                _cv!.profilePicture!,
                width: 114,
                height: 114,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            : Container(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Icon(
                  Icons.person,
                  size: 50,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
      ),
    );
  }

  Widget _buildNameSection() {
    return Column(
      children: [
        Text(
          _toTitleCase('${_cv!.firstName ?? ''} ${_cv!.lastName ?? ''}'.trim()),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
                letterSpacing: 0.5,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        // Serial number below name - larger and more prominent
        _buildSerialDisplay(),
      ],
    );
  }

  Widget _buildSerialDisplay() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.shade50,
            Colors.green.shade100,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.green.shade300,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.1),
            spreadRadius: 0,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.fingerprint,
            color: Colors.green.shade700,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            "Seriale",
            style: TextStyle(
              color: Colors.green.shade700,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _generateCVSerial(),
            style: TextStyle(
              color: Colors.green.shade900,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormalInfoItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.shade100.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Colors.green.shade700,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Ottiene il nome del certificatore per una certificazione
  /// Ora utilizza i dati del certifier espanso dalla nuova API
  Future<String> _getCertifierDisplayName(UserCertificationDetail cert) async {
    // Prima prova i dati del certifier espanso dalla nuova API
    if (cert.certification?.certifier != null) {
      final displayName = cert.certification!.certifier!.displayName;
      if (displayName != 'Unknown Certifier') {
        return displayName;
      }
    }

    // Fallback al nome della categoria se disponibile
    if (cert.certification?.category?.name != null &&
        cert.certification!.category!.name.isNotEmpty) {
      return _getLocalizedCertificationType(cert.certification!.category!.name);
    }

    // Ultimo fallback
    return AppLocalizations.of(context)!.certifyingBody;
  }

  Future<String> _getOrganizationName(UserCertificationDetail cert) async {
    final legalEntityId = cert.certification?.idLegalEntity;

    if (legalEntityId == null) {
      return 'JetCV';
    }

    // Controlla se abbiamo già il nome in cache
    if (_legalEntityNames.containsKey(legalEntityId)) {
      return _legalEntityNames[legalEntityId]!;
    }

    try {
      // Ottiene l'entità legale dal servizio
      final legalEntity =
          await LegalEntityService.getLegalEntityById(legalEntityId);
      final organizationName = LegalEntityService.getCompanyName(legalEntity);

      // Memorizza in cache
      _legalEntityNames[legalEntityId] = organizationName;

      return organizationName;
    } catch (e) {
      return 'JetCV';
    }
  }

  /// Precarica i logo delle legal entities per tutte le certificazioni
  Future<void> _preloadLegalEntityLogos() async {
    // Svuota la cache per forzare il ricaricamento
    _legalEntityLogos.clear();

    // Raccoglie tutti gli ID delle legal entities uniche
    final Set<String> legalEntityIds = _certifications
        .map((cert) => cert.certification?.idLegalEntity)
        .where((id) => id != null)
        .cast<String>()
        .toSet();

    // Precarica i logo per ogni legal entity
    for (final legalEntityId in legalEntityIds) {
      try {
        final legalEntity =
            await LegalEntityService.getLegalEntityById(legalEntityId);

        String? logoUrl;
        if (legalEntity != null &&
            legalEntity.logoPicture != null &&
            legalEntity.logoPicture!.isNotEmpty) {
          logoUrl = legalEntity.logoPicture;
        } else {
          logoUrl = null;
        }

        _legalEntityLogos[legalEntityId] = logoUrl;
      } catch (e) {
        _legalEntityLogos[legalEntityId] = null;
      }
    }
  }

  /// Costruisce il widget del logo della legal entity
  Widget _buildLegalEntityLogo(
      UserCertificationDetail cert, bool isMobile, bool isTablet) {
    final legalEntityId = cert.certification?.idLegalEntity;

    if (legalEntityId == null) {
      return Icon(
        Icons.corporate_fare,
        size: isMobile
            ? 14
            : isTablet
                ? 15
                : 16,
        color: Colors.grey.shade600,
      );
    }

    // Se abbiamo il logo in cache, mostralo immediatamente
    if (_legalEntityLogos.containsKey(legalEntityId) &&
        _legalEntityLogos[legalEntityId] != null) {
      final logoUrl = _legalEntityLogos[legalEntityId]!;

      return Container(
        width: isMobile
            ? 16
            : isTablet
                ? 18
                : 20,
        height: isMobile
            ? 16
            : isTablet
                ? 18
                : 20,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: Colors.grey.shade300,
            width: 0.5,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.network(
            logoUrl,
            fit: BoxFit.cover,
            headers: {
              'User-Agent':
                  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                width: isMobile
                    ? 16
                    : isTablet
                        ? 18
                        : 20,
                height: isMobile
                    ? 16
                    : isTablet
                        ? 18
                        : 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.corporate_fare,
                size: isMobile
                    ? 12
                    : isTablet
                        ? 14
                        : 16,
                color: Colors.grey.shade600,
              );
            },
          ),
        ),
      );
    }

    // Se non abbiamo il logo in cache, caricalo
    return FutureBuilder<String?>(
      future: _getLegalEntityLogo(cert),
      builder: (context, logoSnapshot) {
        if (logoSnapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            width: isMobile
                ? 16
                : isTablet
                    ? 18
                    : 20,
            height: isMobile
                ? 16
                : isTablet
                    ? 18
                    : 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
            ),
          );
        }

        if (logoSnapshot.hasData &&
            logoSnapshot.data != null &&
            logoSnapshot.data!.isNotEmpty) {
          return Container(
            width: isMobile
                ? 16
                : isTablet
                    ? 18
                    : 20,
            height: isMobile
                ? 16
                : isTablet
                    ? 18
                    : 20,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: Colors.grey.shade300,
                width: 0.5,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.network(
                logoSnapshot.data!,
                fit: BoxFit.cover,
                headers: {
                  'User-Agent':
                      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: isMobile
                        ? 16
                        : isTablet
                            ? 18
                            : 20,
                    height: isMobile
                        ? 16
                        : isTablet
                            ? 18
                            : 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  debugPrint('❌ Error loading logo image: $error');
                  debugPrint('❌ Logo URL: ${logoSnapshot.data}');
                  debugPrint('❌ Stack trace: $stackTrace');
                  return Icon(
                    Icons.corporate_fare,
                    size: isMobile
                        ? 12
                        : isTablet
                            ? 14
                            : 16,
                    color: Colors.grey.shade600,
                  );
                },
              ),
            ),
          );
        }

        debugPrint('❌ Logo FutureBuilder - Using fallback icon');
        return Icon(
          Icons.corporate_fare,
          size: isMobile
              ? 14
              : isTablet
                  ? 15
                  : 16,
          color: Colors.grey.shade600,
        );
      },
    );
  }

  /// Ottiene il logo della legal entity per una certificazione
  Future<String?> _getLegalEntityLogo(UserCertificationDetail cert) async {
    final legalEntityId = cert.certification?.idLegalEntity;

    if (legalEntityId == null) {
      debugPrint('❌ No legal entity ID for certification');
      return null;
    }

    debugPrint('🔍 Getting logo for legal entity: $legalEntityId');

    // Controlla se abbiamo già il logo in cache
    if (_legalEntityLogos.containsKey(legalEntityId)) {
      debugPrint('✅ Logo found in cache: ${_legalEntityLogos[legalEntityId]}');
      return _legalEntityLogos[legalEntityId];
    }

    try {
      debugPrint('🔄 Loading logo from database for: $legalEntityId');
      // Ottiene l'entità legale dal servizio
      final legalEntity =
          await LegalEntityService.getLegalEntityById(legalEntityId);

      String? logoUrl;
      if (legalEntity != null &&
          legalEntity.logoPicture != null &&
          legalEntity.logoPicture!.isNotEmpty) {
        logoUrl = legalEntity.logoPicture;
        debugPrint('✅ Legal Entity logo found from database: $logoUrl');
        debugPrint(
            '🔍 Legal entity data: ${legalEntity.legalName} - ${legalEntity.logoPicture}');
      } else {
        debugPrint('❌ No logo found for legal entity: $legalEntityId');
        logoUrl = null;
      }

      // Memorizza in cache
      _legalEntityLogos[legalEntityId] = logoUrl;

      return logoUrl;
    } catch (e) {
      debugPrint('❌ Error getting legal entity logo: $e');
      // Memorizza null in cache per evitare chiamate ripetute
      _legalEntityLogos[legalEntityId] = null;
      return null;
    }
  }

  /// Genera l'URL LinkedIn per una certificazione specifica
  Future<String> _generateLinkedInUrl(UserCertificationDetail cert) async {
    final certName = cert.certification?.category?.name != null
        ? _getLocalizedCertificationType(cert.certification!.category!.name)
        : 'Certification';
    final organizationName = await _getOrganizationName(cert);
    final issueDate = cert.certificationUser.createdAt;
    final certId = cert.certificationUser.idCertificationUser;

    // URL di base per aggiungere certificazioni su LinkedIn
    final baseUrl =
        'https://www.linkedin.com/profile/add?startTask=CERTIFICATION_NAME';

    // Genera URL del certificato (se disponibile)
    final certUrl = cert.certification?.idCertification != null
        ? 'https://jetcv.com/certification/${cert.certification!.idCertification}'
        : 'https://jetcv.com';

    // Parametri della certificazione
    final params = {
      'name': Uri.encodeComponent(certName),
      'organizationName': Uri.encodeComponent(organizationName),
      'issueYear': issueDate.year.toString(),
      'issueMonth': issueDate.month.toString(),
      'certUrl': Uri.encodeComponent(certUrl),
      'certId': certId,
    };

    // Aggiungi parametri di scadenza se disponibili (opzionale)
    // LinkedIn accetta anche expirationYear e expirationMonth
    final expirationDate = cert.certification?.closedAt;
    if (expirationDate != null) {
      params['expirationYear'] = expirationDate.year.toString();
      params['expirationMonth'] = expirationDate.month.toString();
    }

    // Costruisce l'URL finale
    final queryString =
        params.entries.map((e) => '${e.key}=${e.value}').join('&');

    return '$baseUrl&$queryString';
  }

  /// Costruisce il pulsante LinkedIn per una certificazione specifica
  Widget _buildLinkedInButton(UserCertificationDetail cert) {
    return ElevatedButton.icon(
      onPressed: () => _openLinkedInForCertification(cert),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0077B5), // LinkedIn blue
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      icon: const Icon(Icons.link, size: 20),
      label: Text(
        AppLocalizations.of(context)!.addToLinkedIn,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    );
  }

  /// Apre LinkedIn per una certificazione specifica
  Future<void> _openLinkedInForCertification(
      UserCertificationDetail cert) async {
    try {
      // Mostra un indicatore di caricamento
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: 12),
                Text(AppLocalizations.of(context)!.preparingLinkedIn),
              ],
            ),
            duration: Duration(seconds: 2),
          ),
        );
      }

      final linkedInUrl = await _generateLinkedInUrl(cert);
      debugPrint(
          '🔗 Opening LinkedIn for certification: ${cert.certification?.category?.name}');
      debugPrint('🔗 LinkedIn URL: $linkedInUrl');

      // Apre l'URL in una nuova finestra/tab
      await launchUrl(Uri.parse(linkedInUrl),
          mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('❌ Error opening LinkedIn: $e');
      // Mostra un messaggio di errore all'utente
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${AppLocalizations.of(context)!.errorOpeningLinkedIn}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Gestisce l'aggiunta delle certificazioni a LinkedIn (metodo legacy - da rimuovere)
  Future<void> _addCertificationsToLinkedIn() async {
    try {
      debugPrint('🔗 Opening LinkedIn for certifications');

      // Check if certifications are available
      if (_certifications.isEmpty) {
        debugPrint('❌ No certifications available for LinkedIn integration');
        return;
      }

      // Mostra un dialog di conferma con i dettagli della certificazione
      final firstCert = _certifications.first;
      final certName = firstCert.certification?.category?.name != null
          ? _getLocalizedCertificationType(
              firstCert.certification!.category!.name)
          : 'Certification';
      final issuer = firstCert.certification?.idCertifier ?? 'JetCV';
      final issueDate = firstCert.certificationUser.createdAt;

      final shouldProceed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.linkedInIntegration),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLocalizations.of(context)!
                    .shareCertificationsOnLinkedIn),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '📜 Certification Details:',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('${AppLocalizations.of(context)!.name}: $certName'),
                      Text('${AppLocalizations.of(context)!.issuer}: $issuer'),
                      Text(
                          'Issue Date: ${issueDate.day}/${issueDate.month}/${issueDate.year}'),
                      const SizedBox(height: 8),
                      Text(
                        'This will copy the certification details to your clipboard and open LinkedIn. Then go to your profile → Add profile section → Licenses & certifications and paste the details.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0077B5),
                foregroundColor: Colors.white,
              ),
              child: Text(AppLocalizations.of(context)!.addToLinkedIn),
            ),
          ],
        ),
      );

      if (shouldProceed == true) {
        // Apre LinkedIn per aggiungere competenze al profilo
        await LinkedInService.addSkillsToLinkedInProfile(
          certifications: _certifications,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'LinkedIn opened! Certification details have been copied to your clipboard. Go to your LinkedIn profile → Add profile section → Licenses & certifications, then paste the details.'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Error opening LinkedIn: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${AppLocalizations.of(context)!.errorOpeningLinkedIn}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Simplified blockchain badge with CV dates
  Widget _buildSimplifiedBlockchainBadge(AppLocalizations localizations) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;

    // Responsive max width for the blockchain card itself
    double maxWidth = isMobile
        ? double.infinity
        : isTablet
            ? 500
            : 600;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.green.shade100.withValues(alpha: 0.9),
                Colors.green.shade50.withValues(alpha: 0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              width: 1,
              color: Colors.green.shade300,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withValues(alpha: 0.2),
                spreadRadius: 0,
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Certification header
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.green.shade400,
                          Colors.green.shade600,
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withValues(alpha: 0.3),
                          spreadRadius: 0,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.verified,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    localizations.blockchainCertified,
                    style: TextStyle(
                      color: Colors.green.shade800,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 0.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Serial number display
              _buildSerialDisplay(),

              const SizedBox(height: 16),

              // CV Dates info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Creation date
                  _buildDateInfo(
                    Icons.create,
                    localizations.cvCreationDate,
                    _formatDate(_cv!.createdAt),
                  ),
                  // Divider
                  Container(
                    height: 40,
                    width: 1,
                    color: Colors.green.shade300,
                  ),
                  // Last update
                  if (_cv!.updatedAt != null)
                    _buildDateInfo(
                      Icons.update,
                      localizations.lastUpdate,
                      _formatDate(_cv!.updatedAt!),
                    ),
                ],
              ),

              // NFT Link Section (only if nftMintTransactionUrl is present)
              if (_cv?.nftMintTransactionUrl != null &&
                  _cv!.nftMintTransactionUrl!.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildNftLinkSection(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Helper widget for date information
  Widget _buildDateInfo(IconData icon, String label, String date) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            color: Colors.green.shade700,
            size: 16,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: Colors.green.shade600,
            fontWeight: FontWeight.w500,
            fontSize: 11,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 3),
        Text(
          date,
          style: TextStyle(
            color: Colors.green.shade800,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Integrated OpenBadge section for the main profile section
  Widget _buildIntegratedOpenBadgeSection() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;

    final subtitleFontSize = isMobile
        ? 11.0
        : isTablet
            ? 12.0
            : 13.0;
    final buttonFontSize = isMobile
        ? 10.0
        : isTablet
            ? 11.0
            : 12.0;

    // Responsive max width for the openbadges card itself
    double maxWidth = isMobile
        ? double.infinity
        : isTablet
            ? 500
            : 600;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey.shade100.withValues(alpha: 0.9),
                Colors.grey.shade50.withValues(alpha: 0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              width: 1,
              color: Colors.grey.shade300,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.2),
                spreadRadius: 0,
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header with title and icon
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.grey.shade400,
                          Colors.grey.shade600,
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.3),
                          spreadRadius: 0,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.workspace_premium,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppLocalizations.of(context)!.openBadges,
                    style: TextStyle(
                      color: Colors.grey.shade800,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 0.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Subtitle
              Text(
                AppLocalizations.of(context)!.digitalCredentialsAndAchievements,
                style: TextStyle(
                  fontSize: subtitleFontSize,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // OpenBadge preview content
              _buildCompactOpenBadgePreview(),

              const SizedBox(height: 16),

              // Manage OpenBadges button
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const OpenBadgesPage(),
                    ),
                  );
                },
                icon: Icon(
                  Icons.settings,
                  size: isMobile ? 14 : 16,
                ),
                label: Text(
                  "Gestisci Open Badge",
                  style: TextStyle(
                    fontSize: buttonFontSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade600,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 12 : 16,
                    vertical: isMobile ? 8 : 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Compact OpenBadge preview for integrated section
  Widget _buildCompactOpenBadgePreview() {
    return Column(
      children: [
        // Icon
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.upload_file,
            size: 32,
            color: Colors.grey.shade600,
          ),
        ),

        const SizedBox(height: 12),

        // Import text
        Text(
          AppLocalizations.of(context)!.importYourOpenBadges,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 6),

        Text(
          AppLocalizations.of(context)!.showcaseYourDigitalCredentials,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Builds the empty state when no CV is available
  Widget _buildNoCVState() {
    final localizations = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 24 : 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              width: isMobile ? 80 : 100,
              height: isMobile ? 80 : 100,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.description_outlined,
                size: isMobile ? 40 : 50,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),

            SizedBox(height: isMobile ? 24 : 32),

            // Title
            Text(
              _errorMessage ?? localizations.noCvAvailable,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: isMobile ? 12 : 16),

            // Description
            Text(
              _errorMessage != null
                  ? localizations.errorLoadingCv
                  : localizations.createYourFirstCv,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: isMobile ? 32 : 40),

            // Action button
            if (_errorMessage == null && _currentUser != null)
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context)
                      .push(
                    MaterialPageRoute(
                      builder: (context) =>
                          PersonalInfoPage(initialUser: _currentUser),
                    ),
                  )
                      .then((result) {
                    if (result == true && mounted) {
                      _loadData(); // Reload data if CV was created
                    }
                  });
                },
                icon: const Icon(Icons.add),
                label: Text(localizations.createYourDigitalCV),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 24 : 32,
                    vertical: isMobile ? 12 : 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              )
            else if (_errorMessage != null)
              ElevatedButton.icon(
                onPressed: () {
                  _loadData(); // Retry loading data
                },
                icon: const Icon(Icons.refresh),
                label: Text(localizations.retry),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 24 : 32,
                    vertical: isMobile ? 12 : 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class EnhancedCornerPainter extends CustomPainter {
  final Color primaryColor;
  final Color accentColor;

  EnhancedCornerPainter({
    required this.primaryColor,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final primaryPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.6)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final accentPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.8)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    // Main corner L-shape
    final mainPath = Path();
    mainPath.moveTo(0, size.height * 0.4);
    mainPath.lineTo(0, 0);
    mainPath.lineTo(size.width * 0.4, 0);

    // Blockchain-inspired connected blocks
    final blockSize = size.width * 0.08;

    // Block 1
    final block1 = Rect.fromLTWH(blockSize, blockSize, blockSize, blockSize);
    canvas.drawRect(block1, fillPaint);
    canvas.drawRect(block1, accentPaint);

    // Block 2 (connected)
    final block2 =
        Rect.fromLTWH(blockSize * 2.5, blockSize, blockSize, blockSize);
    canvas.drawRect(block2, fillPaint);
    canvas.drawRect(block2, accentPaint);

    // Block 3 (vertical)
    final block3 =
        Rect.fromLTWH(blockSize, blockSize * 2.5, blockSize, blockSize);
    canvas.drawRect(block3, fillPaint);
    canvas.drawRect(block3, accentPaint);

    // Connection lines between blocks
    final connectionPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.5)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Horizontal connection
    canvas.drawLine(
      Offset(block1.right, block1.center.dy),
      Offset(block2.left, block2.center.dy),
      connectionPaint,
    );

    // Vertical connection
    canvas.drawLine(
      Offset(block1.center.dx, block1.bottom),
      Offset(block3.center.dx, block3.top),
      connectionPaint,
    );

    // Draw main corner frame
    canvas.drawPath(mainPath, primaryPaint);

    // Add decorative hash patterns (blockchain reference)
    final hashPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.3)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    // Mini hash lines
    for (int i = 0; i < 3; i++) {
      canvas.drawLine(
        Offset(size.width * 0.15 + (i * 3), size.height * 0.25),
        Offset(size.width * 0.18 + (i * 3), size.height * 0.25),
        hashPaint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Custom painter for Project Management certification background
class ProjectManagementPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.shade200.withValues(alpha: 0.3)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = Colors.blue.shade100.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;

    // Draw Gantt chart-like bars
    final barHeight = size.height * 0.08;
    final barSpacing = size.height * 0.12;

    for (int i = 0; i < 4; i++) {
      final y = size.height * 0.2 + (i * barSpacing);
      final barWidth = size.width * (0.3 + (i * 0.1));

      // Bar background
      canvas.drawRect(
        Rect.fromLTWH(0, y, barWidth, barHeight),
        fillPaint,
      );

      // Bar border
      canvas.drawRect(
        Rect.fromLTWH(0, y, barWidth, barHeight),
        paint,
      );
    }

    // Draw project timeline dots
    final dotPaint = Paint()
      ..color = Colors.blue.shade400
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 6; i++) {
      final x = size.width * 0.1 + (i * size.width * 0.15);
      final y = size.height * 0.7;
      canvas.drawCircle(Offset(x, y), 3, dotPaint);
    }

    // Draw connecting lines
    final linePaint = Paint()
      ..color = Colors.blue.shade300.withValues(alpha: 0.5)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 5; i++) {
      final x1 = size.width * 0.1 + (i * size.width * 0.15);
      final x2 = size.width * 0.1 + ((i + 1) * size.width * 0.15);
      final y = size.height * 0.7;
      canvas.drawLine(Offset(x1, y), Offset(x2, y), linePaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Custom painter for Flutter Development certification background
class FlutterDevelopmentPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.cyan.shade300.withValues(alpha: 0.4)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = Colors.cyan.shade100.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    // Draw mobile device outlines
    final deviceWidth = size.width * 0.15;
    final deviceHeight = size.height * 0.25;

    // Device 1 (left)
    final device1Rect = Rect.fromLTWH(
      size.width * 0.1,
      size.height * 0.2,
      deviceWidth,
      deviceHeight,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(device1Rect, const Radius.circular(8)),
      fillPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(device1Rect, const Radius.circular(8)),
      paint,
    );

    // Device 2 (center)
    final device2Rect = Rect.fromLTWH(
      size.width * 0.4,
      size.height * 0.3,
      deviceWidth,
      deviceHeight,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(device2Rect, const Radius.circular(8)),
      fillPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(device2Rect, const Radius.circular(8)),
      paint,
    );

    // Device 3 (right)
    final device3Rect = Rect.fromLTWH(
      size.width * 0.7,
      size.height * 0.25,
      deviceWidth,
      deviceHeight,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(device3Rect, const Radius.circular(8)),
      fillPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(device3Rect, const Radius.circular(8)),
      paint,
    );

    // Draw Flutter logo-like elements
    final logoPaint = Paint()
      ..color = Colors.cyan.shade500
      ..style = PaintingStyle.fill;

    // Draw small circles representing Flutter widgets
    for (int i = 0; i < 8; i++) {
      final x = size.width * 0.1 + (i * size.width * 0.1);
      final y = size.height * 0.6;
      canvas.drawCircle(Offset(x, y), 4, logoPaint);
    }

    // Draw code-like lines
    final codePaint = Paint()
      ..color = Colors.cyan.shade400.withValues(alpha: 0.6)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 5; i++) {
      final y = size.height * 0.75 + (i * 8);
      final lineLength = size.width * (0.2 + (i * 0.1));
      canvas.drawLine(
        Offset(size.width * 0.1, y),
        Offset(size.width * 0.1 + lineLength, y),
        codePaint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
