import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:jetcv__utenti/models/user_model.dart';
import 'package:jetcv__utenti/models/cv_model.dart';
import 'package:jetcv__utenti/models/country_model.dart';
import 'package:jetcv__utenti/services/user_service.dart';
import 'package:jetcv__utenti/services/cv_edge_service.dart';
import 'package:jetcv__utenti/services/country_service.dart';
import 'package:jetcv__utenti/services/locale_service.dart';
import 'package:jetcv__utenti/services/certification_service.dart';
import 'package:jetcv__utenti/screens/cv/blockchain_info_page.dart';
import 'package:jetcv__utenti/services/linkedin_service.dart';
import 'package:jetcv__utenti/services/legal_entity_service.dart';
import 'package:jetcv__utenti/services/image_cache_service.dart';
import 'package:jetcv__utenti/services/base64_image_service.dart';
import 'package:jetcv__utenti/supabase/supabase_config.dart';
import 'package:jetcv__utenti/l10n/app_localizations.dart';
import 'package:jetcv__utenti/widgets/main_layout.dart';
import 'package:jetcv__utenti/widgets/attached_media_widget.dart';
import 'package:jetcv__utenti/widgets/open_badge_button.dart';

import 'package:share_plus/share_plus.dart';
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

      if (cvResponse.success && cvResponse.data != null) {
        _cv = cvResponse.data!;
        debugPrint('✅ CV loaded successfully for user: $targetUserId');
        debugPrint(
            '🌍 CV countryCode: "${_cv!.countryCode}" (${_cv!.countryCode?.runtimeType})');
      } else {
        debugPrint('❌ Failed to load CV: ${cvResponse.error}');
        setState(() {
          _errorMessage =
              cvResponse.error ?? 'Failed to load CV data'; // TODO: localize
          _isLoading = false;
        });
        return;
      }

      // Load country data if available
      if (_cv!.countryCode != null && _cv!.countryCode!.isNotEmpty) {
        debugPrint('🔍 Loading country with code: "${_cv!.countryCode}"');

        final countryResponse =
            await CountryService.getCountryByCode(_cv!.countryCode!);

        if (countryResponse.success && countryResponse.data != null) {
          _country = countryResponse.data!;
          debugPrint(
              '✅ Country loaded successfully: ${_country!.name} ${_country!.emoji}');
        } else {
          // Country not found, but don't fail the whole page load
          debugPrint('❌ Country not found for code: "${_cv!.countryCode}"');
          debugPrint('❌ Country service error: ${countryResponse.error}');
          debugPrint('❌ Country service message: ${countryResponse.message}');
        }
      } else {
        debugPrint(
            '⚠️ CV countryCode is null or empty - skipping country lookup');
      }

      setState(() {
        _isLoading = false;
      });

      // Pre-carica l'URL pubblico in background per l'anteprima
      _getPublicCvUrl();

      // Load certifications data
      _loadCertifications();
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
        // Sort certifications by date based on current sort order
        final sortedCertifications =
            List<UserCertificationDetail>.from(response.data!)
              ..sort((a, b) => _isMostRecentFirst
                  ? b.certificationUser.createdAt
                      .compareTo(a.certificationUser.createdAt)
                  : a.certificationUser.createdAt
                      .compareTo(b.certificationUser.createdAt));

        setState(() {
          _certifications = sortedCertifications;
          _certificationsLoading = false;
        });
        debugPrint(
            '✅ Certifications loaded successfully: ${_certifications.length} items (sorted by date)');

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
    debugPrint(
        '🔄 Sort order changed to: ${_isMostRecentFirst ? "Most recent first" : "Least recent first"}');
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

  String _toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  Future<void> _shareCV() async {
    final localizations = AppLocalizations.of(context)!;

    try {
      // Get or generate public CV URL
      final cvUrl = await _getPublicCvUrl();
      if (cvUrl == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Errore nella generazione dell\'URL pubblico'), // TODO: localize
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }

      if (kIsWeb) {
        // Su web: copia negli appunti e mostra messaggio
        await Clipboard.setData(ClipboardData(text: cvUrl));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(AppLocalizations.of(context)!.cvLinkCopied),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        // Su mobile: apri la condivisione nativa
        await Share.share(
          cvUrl,
          subject: localizations.shareCV,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(localizations.cvShared),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.shareError(e.toString())),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

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
        debugPrint(
            'Errore nella generazione dell\'URL pubblico: ${response.error}');
        return null;
      }
    } catch (e) {
      debugPrint('Errore durante la chiamata per l\'URL pubblico: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.viewMyCV),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_cv == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.viewMyCV),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
          child: Text(
            _errorMessage ?? 'CV data not available', // TODO: localize
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final country = _getCountryByCode(_cv!.countryCode);

    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;
    final isDesktop = screenWidth >= 1024;

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
    final smallSpacing = isMobile
        ? 16.0
        : isTablet
            ? 20.0
            : 24.0;

    return MainLayout(
      currentRoute: '/cv',
      title: AppLocalizations.of(context)!.viewMyCV,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(pagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Language selector
            _buildLanguageSelector(),

            SizedBox(height: smallSpacing),

            // Share CV section (moved to top)
            _buildShareSection(),

            SizedBox(height: smallSpacing),

            // Main profile section
            _buildMainProfileSection(country),

            SizedBox(height: sectionSpacing),

            // Contact information section
            _buildContactSection(),

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

  Widget _buildLanguageSelector() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;

    final cardPadding = isMobile
        ? 12.0
        : isTablet
            ? 14.0
            : 16.0;
    final iconSize = isMobile
        ? 20.0
        : isTablet
            ? 22.0
            : 24.0;
    final spacing = isMobile
        ? 8.0
        : isTablet
            ? 10.0
            : 12.0;
    final titleFontSize = isMobile
        ? 14.0
        : isTablet
            ? 16.0
            : 18.0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(cardPadding),
        child: isMobile
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.language,
                        color: Theme.of(context).colorScheme.primary,
                        size: iconSize,
                      ),
                      SizedBox(width: spacing),
                      Text(
                        AppLocalizations.of(context)!.cvLanguage,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: titleFontSize,
                                ),
                      ),
                    ],
                  ),
                  SizedBox(height: spacing),
                  CVLanguageDropdown(),
                ],
              )
            : Row(
                children: [
                  Icon(
                    Icons.language,
                    color: Theme.of(context).colorScheme.primary,
                    size: iconSize,
                  ),
                  SizedBox(width: spacing),
                  Text(
                    AppLocalizations.of(context)!.cvLanguage,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: titleFontSize,
                        ),
                  ),
                  const Spacer(),
                  Expanded(
                    child: CVLanguageDropdown(),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildMainProfileSection(CountryModel? country) {
    final localizations = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;

    // Responsive sizing
    final containerMargin = isMobile
        ? 2.0
        : isTablet
            ? 3.0
            : 4.0;
    final containerPadding = isMobile
        ? 2.0
        : isTablet
            ? 2.5
            : 3.0;
    final innerPadding = isMobile
        ? 16.0
        : isTablet
            ? 20.0
            : 24.0;
    final contentPadding = isMobile
        ? 16.0
        : isTablet
            ? 20.0
            : 24.0;
    final spacing = isMobile
        ? 12.0
        : isTablet
            ? 16.0
            : 20.0;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: containerMargin),
      child: Stack(
        children: [
          // Main certificate container with enhanced blockchain-style border
          Container(
            width: double.infinity,
            margin: EdgeInsets.all(containerMargin),
            padding: EdgeInsets.all(containerPadding),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.green.shade100.withValues(alpha: 0.3),
                  Colors.teal.shade50.withValues(alpha: 0.2),
                  Colors.blue.shade50.withValues(alpha: 0.1),
                ],
              ),
              border: Border.all(
                color: Colors.green.shade300.withValues(alpha: 0.6),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withValues(alpha: 0.2),
                  spreadRadius: 0,
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  spreadRadius: 0,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: Theme.of(context).colorScheme.surface,
                border: Border.all(
                  color: Colors.green.shade200.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: Container(
                  padding: EdgeInsets.all(innerPadding),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(contentPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Profile picture
                        _buildEnhancedProfilePicture(),
                        SizedBox(height: spacing),
                        // Name
                        _buildNameSection(),
                        SizedBox(height: spacing),
                        // Personal info (address and birth date)
                        _buildPersonalInfoSection(country, localizations),
                        SizedBox(height: spacing),
                        // Premium certification badge
                        _buildPremiumBadgeWithSerial(localizations),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    final localizations = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;

    final cardPadding = isMobile
        ? 16.0
        : isTablet
            ? 18.0
            : 20.0;
    final iconSize = isMobile
        ? 20.0
        : isTablet
            ? 22.0
            : 24.0;
    final spacing = isMobile
        ? 8.0
        : isTablet
            ? 10.0
            : 12.0;
    final titleFontSize = isMobile
        ? 16.0
        : isTablet
            ? 18.0
            : 20.0;
    final sectionSpacing = isMobile
        ? 16.0
        : isTablet
            ? 18.0
            : 20.0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.contact_phone,
                  color: Theme.of(context).colorScheme.primary,
                  size: iconSize,
                ),
                SizedBox(width: spacing),
                Expanded(
                  child: Text(
                    localizations.contactInfo,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: titleFontSize,
                        ),
                  ),
                ),
              ],
            ),

            SizedBox(height: sectionSpacing),

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
                value: _toTitleCase([
                  _cv!.address,
                  _cv!.city,
                  _cv!.state,
                  _cv!.postalCode,
                ]
                    .where((element) => element != null && element.isNotEmpty)
                    .join(', ')),
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
                              country.name,
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
      } catch (e) {
        debugPrint('Error loading nationality $code: $e');
      }
    }

    return countries;
  }

  Widget _buildAutodichiarazioniSection() {
    final languageCodes = _cv?.languageCodes;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.assignment_ind,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  AppLocalizations.of(context)!.autodichiarazioni,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
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
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: languageCodes.map((languageCode) {
                  final languageName =
                      LocaleService.languageNames[languageCode] ??
                          languageCode.toUpperCase();
                  final languageEmoji =
                      LocaleService.languageEmojis[languageCode];

                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (languageEmoji != null) ...[
                          Text(
                            languageEmoji,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Text(
                          languageName,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.onSurface,
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
                        fontSize: 28,
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
                        fontSize: 28,
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

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color:
                Colors.grey.shade50, // Light gray background like in the image
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
                            fontSize: 28,
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

                // Timeline with certifications - responsive layout
                Stack(
                  children: [
                    // Timeline line (background) - responsive positioning
                    Positioned(
                      left: isMobile
                          ? 50
                          : isTablet
                              ? 55
                              : 60, // Responsive center positioning
                      top: 0,
                      child: Container(
                        width: 2,
                        height: _certifications.length *
                            (isMobile
                                ? 180.0
                                : isTablet
                                    ? 200.0
                                    : 220.0), // Reduced height to prevent overflow
                        color: Colors.grey.shade300,
                      ),
                    ),

                    // Content with aligned dates and cards
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

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Timeline column with date and node
                            SizedBox(
                              width: isMobile
                                  ? 100
                                  : isTablet
                                      ? 110
                                      : 120, // Responsive width
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Date bubble
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
                                            ? 7
                                            : isTablet
                                                ? 8
                                                : 9,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  SizedBox(
                                      height: isMobile
                                          ? 4
                                          : isTablet
                                              ? 5
                                              : 6),
                                  // Timeline node - centered
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
                                ],
                              ),
                            ),
                            SizedBox(
                                width: isMobile
                                    ? 12
                                    : isTablet
                                        ? 16
                                        : 20),

                            // Certification card
                            Expanded(
                              child: Column(
                                children: [
                                  _buildCertificationCard(cert),
                                  // Add spacing between cards (except for the last one)
                                  if (!isLast)
                                    SizedBox(
                                        height: isMobile
                                            ? 16
                                            : isTablet
                                                ? 20
                                                : 24),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatCertificationDate(DateTime date) {
    final months = [
      'Gen',
      'Feb',
      'Mar',
      'Apr',
      'Mag',
      'Giu',
      'Lug',
      'Ago',
      'Set',
      'Ott',
      'Nov',
      'Dic'
    ];

    final day = date.day.toString().padLeft(2, '0');
    final month = months[date.month - 1];
    final year = date.year;

    return '$day $month $year';
  }

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

          // Serial number directly under the image
          if (cert.certificationUser.serialNumber != null) ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: isMobile
                    ? 8
                    : isTablet
                        ? 10
                        : 12,
                vertical: isMobile
                    ? 6
                    : isTablet
                        ? 8
                        : 10,
              ),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                border: Border(
                  top: BorderSide(
                    color: Colors.green.shade200,
                    width: 1,
                  ),
                  bottom: BorderSide(
                    color: Colors.green.shade200,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.fingerprint,
                    size: isMobile
                        ? 14
                        : isTablet
                            ? 16
                            : 18,
                    color: Colors.green.shade700,
                  ),
                  SizedBox(
                      width: isMobile
                          ? 6
                          : isTablet
                              ? 8
                              : 10),
                  Text(
                    '${AppLocalizations.of(context)!.serial}: ',
                    style: TextStyle(
                      fontSize: isMobile
                          ? 10
                          : isTablet
                              ? 11
                              : 12,
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    cert.certificationUser.serialNumber!,
                    style: TextStyle(
                      fontSize: isMobile
                          ? 10
                          : isTablet
                              ? 11
                              : 12,
                      color: Colors.green.shade900,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],

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
                          Text(
                            cert.certification?.category?.name ??
                                AppLocalizations.of(context)!.certification,
                            style: TextStyle(
                              fontSize: isMobile
                                  ? 11
                                  : isTablet
                                      ? 12
                                      : 13,
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
                                    ? 9
                                    : isTablet
                                        ? 10
                                        : 11,
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
                                    ? 9
                                    : isTablet
                                        ? 10
                                        : 11,
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
                        cert.certification?.category?.name ??
                            AppLocalizations.of(context)!.certifyingBody,
                        style: TextStyle(
                          fontSize: isMobile
                              ? 9
                              : isTablet
                                  ? 10
                                  : 11,
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

                // Certifier name and organization info
                if (cert.certificationUser.serialNumber != null) ...[
                  // Certifier name
                  Row(
                    children: [
                      Icon(
                        Icons.business,
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
                                      ? 8
                                      : isTablet
                                          ? 9
                                          : 10,
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
                                    ? 8
                                    : isTablet
                                        ? 9
                                        : 10,
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
                          ? 6
                          : isTablet
                              ? 7
                              : 8),

                  // Legal Entity name with logo
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
                                      ? 8
                                      : isTablet
                                          ? 9
                                          : 10,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
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
                          ? 12
                          : isTablet
                              ? 14
                              : 16),
                ],

                // Description from category information
                if (cert.certification?.categoryInformation.isNotEmpty ==
                    true) ...[
                  // Mostra tutte le informazioni della categoria
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: cert.certification!.categoryInformation
                        .where(
                            (info) => info.label != null && info.value != null)
                        .map((info) {
                      debugPrint(
                          'Category info - label: ${info.label}, value: ${info.value}');
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Text(
                          '${info.label}: ${info.value}',
                          style: TextStyle(
                            fontSize: isMobile
                                ? 9
                                : isTablet
                                    ? 10
                                    : 11,
                            color: Colors.grey.shade700,
                            height: 1.4,
                            fontWeight: FontWeight.w400,
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
                          ? 9
                          : isTablet
                              ? 10
                              : 11,
                      color: Colors.grey.shade700,
                      height: 1.4,
                      fontWeight: FontWeight.w400,
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
                _buildOpenBadgeSection(cert),
              ],
            ),
          ),
        ],
      ),
    );
  }

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

  Widget _buildOpenBadgeSection(UserCertificationDetail cert) {
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
    final categoryName =
        cert.certification?.category?.name?.toLowerCase() ?? '';

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

  Widget _buildShareSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context).colorScheme.surface,
            border: Border.all(
              color:
                  Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Icon container
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.share,
                    color: Colors.white,
                    size: 20,
                  ),
                ),

                const SizedBox(width: 16),

                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.shareCV,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppLocalizations.of(context)!.verifiedCV,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // Share button
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: ElevatedButton.icon(
                    onPressed: _shareCV,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 1,
                    ),
                    icon: Icon(
                      kIsWeb ? Icons.copy : Icons.share,
                      size: 16,
                    ),
                    label: Text(
                      kIsWeb
                          ? AppLocalizations.of(context)!.copyLink
                          : AppLocalizations.of(context)!.share,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
                size: 14,
              ),
              const SizedBox(width: 6),
              Text(
                AppLocalizations.of(context)!.serialCode,
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
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
              fontSize: 12,
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
        constraints: const BoxConstraints(maxWidth: 400),
        child: Container(
          padding: const EdgeInsets.all(20),
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
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              width: 2,
              color: Colors.green.shade400,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withValues(alpha: 0.4),
                spreadRadius: 0,
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: Colors.teal.withValues(alpha: 0.2),
                spreadRadius: 0,
                blurRadius: 8,
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
                    padding: const EdgeInsets.all(10),
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
                          color: Colors.green.withValues(alpha: 0.4),
                          spreadRadius: 0,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.verified,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      localizations.blockchainCertified,
                      style: TextStyle(
                        color: Colors.green.shade900,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        letterSpacing: 0.5,
                        shadows: [
                          Shadow(
                            color: Colors.green.withValues(alpha: 0.3),
                            offset: const Offset(0, 1),
                            blurRadius: 2,
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
                const SizedBox(height: 16),
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.blue.shade200,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Blockchain Info Button
          GestureDetector(
            onTap: () => _openBlockchainInfo(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(6),
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
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Blockchain Info',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
        debugPrint('❌ Error opening NFT link: $e');
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
            AppLocalizations.of(context)!.serialCode,
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

  Widget _buildPersonalInfoSection(
      CountryModel? country, AppLocalizations localizations) {
    final infoItems = <Widget>[];

    // Birth info
    if (_cv!.dateOfBirth != null) {
      infoItems.add(_buildFormalInfoItem(
        Icons.person_outline,
        AppLocalizations.of(context)!.dateOfBirth,
        _formatFormalBirthInfo(),
      ));
    }

    // CV Creation and Update dates
    if (_cv!.createdAt != null) {
      infoItems.add(_buildFormalInfoItem(
        Icons.create,
        'Data creazione CV',
        _formatDate(_cv!.createdAt!),
      ));
    }

    if (_cv!.updatedAt != null) {
      infoItems.add(_buildFormalInfoItem(
        Icons.update,
        'Ultimo aggiornamento',
        _formatDate(_cv!.updatedAt!),
      ));
    }

    if (infoItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withValues(alpha: 0.4),
                Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withValues(alpha: 0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.green.shade200.withValues(alpha: 0.4),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withValues(alpha: 0.1),
                spreadRadius: 0,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: infoItems,
          ),
        ),
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
  /// Ora utilizza il campo nomeCertificatore fornito dall'edge function
  Future<String> _getCertifierDisplayName(UserCertificationDetail cert) async {
    // Debug: stampa le informazioni disponibili
    debugPrint('=== CERTIFIER DEBUG ===');
    debugPrint('Certification ID: ${cert.certification?.idCertification}');
    debugPrint('Certifier ID: ${cert.certification?.idCertifier}');
    debugPrint('Nome Certificatore: ${cert.certification?.nomeCertificatore}');
    debugPrint('Category name: ${cert.certification?.category?.name}');

    // Prima prova il campo nomeCertificatore fornito dall'edge function
    if (cert.certification?.nomeCertificatore != null &&
        cert.certification!.nomeCertificatore!.isNotEmpty) {
      debugPrint(
          '✅ Using nomeCertificatore from edge function: ${cert.certification!.nomeCertificatore}');
      return cert.certification!.nomeCertificatore!;
    }

    // Fallback al nome della categoria se disponibile
    if (cert.certification?.category?.name != null &&
        cert.certification!.category!.name.isNotEmpty) {
      debugPrint(
          'Using category name as fallback: ${cert.certification!.category!.name}');
      return cert.certification!.category!.name;
    }

    // Ultimo fallback
    debugPrint('Using default certifying body');
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
      debugPrint('❌ Error getting organization name: $e');
      return 'JetCV';
    }
  }

  /// Precarica i logo delle legal entities per tutte le certificazioni
  Future<void> _preloadLegalEntityLogos() async {
    debugPrint('🔄 Preloading legal entity logos...');

    // Svuota la cache per forzare il ricaricamento
    _legalEntityLogos.clear();
    debugPrint('🗑️ Cleared legal entity logos cache');

    // Raccoglie tutti gli ID delle legal entities uniche
    final Set<String> legalEntityIds = _certifications
        .map((cert) => cert.certification?.idLegalEntity)
        .where((id) => id != null)
        .cast<String>()
        .toSet();

    debugPrint('🔍 Found ${legalEntityIds.length} unique legal entity IDs');

    // Precarica i logo per ogni legal entity
    for (final legalEntityId in legalEntityIds) {
      try {
        debugPrint('🔄 Preloading logo for: $legalEntityId');
        final legalEntity =
            await LegalEntityService.getLegalEntityById(legalEntityId);

        String? logoUrl;
        if (legalEntity != null &&
            legalEntity.logoPicture != null &&
            legalEntity.logoPicture!.isNotEmpty) {
          logoUrl = legalEntity.logoPicture;
          debugPrint('✅ Preloaded logo from database: $logoUrl');
          debugPrint(
              '🔍 Legal entity data: ${legalEntity.legalName} - ${legalEntity.logoPicture}');
        } else {
          debugPrint('❌ No logo found for: $legalEntityId');
          logoUrl = null;
        }

        _legalEntityLogos[legalEntityId] = logoUrl;
      } catch (e) {
        debugPrint('❌ Error preloading logo for $legalEntityId: $e');
        _legalEntityLogos[legalEntityId] = null;
      }
    }

    debugPrint('✅ Legal entity logos preloading completed');
  }

  /// Costruisce il widget del logo della legal entity
  Widget _buildLegalEntityLogo(
      UserCertificationDetail cert, bool isMobile, bool isTablet) {
    final legalEntityId = cert.certification?.idLegalEntity;

    if (legalEntityId == null) {
      debugPrint('❌ No legal entity ID for certification');
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
      debugPrint('✅ Displaying cached logo: $logoUrl');

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
              debugPrint('❌ Error loading logo image: $error');
              debugPrint('❌ Logo URL: $logoUrl');
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

    // Se non abbiamo il logo in cache, caricalo
    return FutureBuilder<String?>(
      future: _getLegalEntityLogo(cert),
      builder: (context, logoSnapshot) {
        debugPrint(
            '🔍 Logo FutureBuilder - hasData: ${logoSnapshot.hasData}, data: ${logoSnapshot.data}');

        if (logoSnapshot.connectionState == ConnectionState.waiting) {
          debugPrint('⏳ Logo FutureBuilder - Still loading...');
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
          debugPrint(
              '✅ Logo FutureBuilder - Displaying logo: ${logoSnapshot.data}');

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
    final certName = cert.certification?.category?.name ?? 'Certification';
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
      final certName =
          firstCert.certification?.category?.name ?? 'Certification';
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
            content: Text('${AppLocalizations.of(context)!.errorOpeningLinkedIn}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class CVLanguageDropdown extends StatefulWidget {
  const CVLanguageDropdown({super.key});

  @override
  State<CVLanguageDropdown> createState() => _CVLanguageDropdownState();
}

class _CVLanguageDropdownState extends State<CVLanguageDropdown> {
  final GlobalKey _buttonKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  bool _isDropdownOpen = false;

  @override
  void dispose() {
    _cleanupOverlay();
    super.dispose();
  }

  void _cleanupOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isDropdownOpen = false;
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) {
      setState(() {
        _isDropdownOpen = false;
      });
    }
  }

  void _showDropdown() {
    if (_isDropdownOpen) {
      _removeOverlay();
      return;
    }

    final renderBox =
        _buttonKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Invisible barrier to detect taps outside
          Positioned.fill(
            child: GestureDetector(
              onTap: _removeOverlay,
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          // Actual dropdown menu
          Positioned(
            left: offset.dx,
            top: offset.dy + size.height + 4,
            width: size.width,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                constraints: const BoxConstraints(maxHeight: 200),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .outline
                        .withValues(alpha: 0.2),
                  ),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(8),
                  itemCount: LocaleService.fullyTranslatedLocales.length,
                  itemBuilder: (context, index) {
                    final locale = LocaleService.fullyTranslatedLocales[index];
                    final languageName = LocaleService.instance
                        .getLanguageName(locale.languageCode);
                    final languageEmoji = LocaleService.instance
                        .getLanguageEmoji(locale.languageCode);
                    final isSelected =
                        LocaleService.instance.currentLocale?.languageCode ==
                            locale.languageCode;

                    return MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () => _selectLanguage(locale),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          child: Row(
                            children: [
                              if (languageEmoji != null) ...[
                                Text(
                                  languageEmoji,
                                  style: const TextStyle(fontSize: 20),
                                ),
                                const SizedBox(width: 12),
                              ],
                              Expanded(
                                child: Text(
                                  languageName,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: isSelected
                                            ? Theme.of(context)
                                                .colorScheme
                                                .primary
                                            : null,
                                      ),
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.check,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 20,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      _isDropdownOpen = true;
    });
  }

  Future<void> _selectLanguage(Locale locale) async {
    _removeOverlay();

    try {
      // Update the locale
      await LocaleService.instance.setLocale(locale);

      // Update user language preference if authenticated
      final session = SupabaseConfig.client.auth.currentSession;
      if (session != null) {
        try {
          final currentUser = await UserService.getCurrentUser();
          if (currentUser != null) {
            await UserService.updateUser(currentUser.idUser, {
              'languageCodeApp': locale.languageCode,
            });
          }
        } catch (e) {
          debugPrint('Error updating user language preference: $e');
          // Non-blocking - language change in UI still works
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.languageChanged),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!
                .errorChangingLanguage(e.toString())),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = LocaleService.instance.currentLocale;
    final currentLanguageName = currentLocale != null
        ? LocaleService.instance.getLanguageName(currentLocale.languageCode)
        : AppLocalizations.of(context)!.language;
    final currentLanguageEmoji = currentLocale != null
        ? LocaleService.instance.getLanguageEmoji(currentLocale.languageCode)
        : null;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        key: _buttonKey,
        onTap: _showDropdown,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(
              color:
                  Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            ),
            borderRadius: BorderRadius.circular(8),
            color: Theme.of(context).colorScheme.surface,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (currentLanguageEmoji != null) ...[
                Text(
                  currentLanguageEmoji,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  currentLanguageName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                _isDropdownOpen
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                size: 20,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
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
