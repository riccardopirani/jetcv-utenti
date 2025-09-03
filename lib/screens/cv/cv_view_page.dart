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
import 'package:jetcv__utenti/supabase/supabase_config.dart';
import 'package:jetcv__utenti/l10n/app_localizations.dart';
import 'package:jetcv__utenti/widgets/main_layout.dart';

import 'package:share_plus/share_plus.dart';

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
        // Sort certifications by date (most recent first)
        final sortedCertifications =
            List<UserCertificationDetail>.from(response.data!)
              ..sort((a, b) => b.certificationUser.createdAt
                  .compareTo(a.certificationUser.createdAt));

        setState(() {
          _certifications = sortedCertifications;
          _certificationsLoading = false;
        });
        debugPrint(
            '✅ Certifications loaded successfully: ${_certifications.length} items (sorted by date)');
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

    return MainLayout(
      currentRoute: '/cv',
      title: AppLocalizations.of(context)!.viewMyCV,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Language selector
            _buildLanguageSelector(),

            const SizedBox(height: 24),

            // Share CV section (moved to top)
            _buildShareSection(),

            const SizedBox(height: 24),

            // Main profile section
            _buildMainProfileSection(country),

            const SizedBox(height: 32),

            // Contact information section
            _buildContactSection(),

            const SizedBox(height: 32),

            // Autodichiarazioni section
            _buildAutodichiarazioniSection(),

            const SizedBox(height: 32),

            // Certifications timeline section
            _buildCertificationsSection(),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.language,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Text(
              AppLocalizations.of(context)!.cvLanguage,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
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

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Stack(
        children: [
          // Main certificate container with enhanced blockchain-style border
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(4),
            padding: const EdgeInsets.all(3),
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
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                  ),
                  child: Stack(
                    children: [
                      // Serial chip in top-right corner
                      Positioned(
                        top: 16,
                        right: 16,
                        child: _buildSerialChip(),
                      ),
                      // Main content
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Main content: Photo, name, certification, personal info
                            Expanded(
                              child: Column(
                                children: [
                                  // Profile picture
                                  _buildEnhancedProfilePicture(),
                                  const SizedBox(height: 16),
                                  // Name
                                  _buildNameSection(),
                                  const SizedBox(height: 20),
                                  // Personal info (address and birth date)
                                  _buildPersonalInfoSection(
                                      country, localizations),
                                  const SizedBox(height: 20),
                                  // Premium certification badge
                                  _buildPremiumBadgeWithSerial(localizations),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
                  Icons.contact_phone,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  localizations.contactInfo,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ),

            const SizedBox(height: 20),

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
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
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
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
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
                  ],
                ),
                const SizedBox(height: 32),
                const Center(
                  child: CircularProgressIndicator(),
                ),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)!.loadingCertifications,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
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
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
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
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
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
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
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
                  ],
                ),
                const SizedBox(height: 32),

                // Timeline with certifications - dates aligned with card start, matching image exactly
                Stack(
                  children: [
                    // Timeline line (background)
                    Positioned(
                      left: 6,
                      top: 0,
                      child: Container(
                        width: 2,
                        height: _certifications.length *
                            250.0, // Adjust based on content height + spacing
                        color: Colors.grey.shade300,
                      ),
                    ),

                    // Content with aligned dates and cards
                    Column(
                      children: _certifications.asMap().entries.map((entry) {
                        final index = entry.key;
                        final cert = entry.value;
                        final isLast = index == _certifications.length - 1;

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Timeline column with date and node
                            SizedBox(
                              width: 120,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Date bubble
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 6),
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
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // Timeline node
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 24),

                            // Certification card
                            Expanded(
                              child: Column(
                                children: [
                                  _buildCertificationCard(cert),
                                  // Add spacing between cards (except for the last one)
                                  if (!isLast) const SizedBox(height: 32),
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
            height: 140,
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
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and date - matching image layout
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        cert.certification?.category?.name ??
                            AppLocalizations.of(context)!.certification,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
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
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Issuer with circular logo
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
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
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      cert.certification?.category?.name ??
                          AppLocalizations.of(context)!.certifyingBody,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Status
                Row(
                  children: [
                    Icon(
                      _getStatusIcon(cert.certificationUser.status),
                      size: 16,
                      color: _getStatusColor(cert.certificationUser.status),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${AppLocalizations.of(context)!.status}: ${_getStatusText(cert.certificationUser.status)}',
                      style: TextStyle(
                        fontSize: 13,
                        color: _getStatusColor(cert.certificationUser.status),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Serial number if available
                if (cert.certificationUser.serialNumber != null) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.fingerprint,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${AppLocalizations.of(context)!.serial}: ${cert.certificationUser.serialNumber}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],

                // Description from category information
                if (cert.certification?.categoryInformation.isNotEmpty ==
                    true) ...[
                  Text(
                    cert.certification!.categoryInformation
                        .map((info) => info.info?.name ?? '')
                        .where((name) => name.isNotEmpty)
                        .join(', '),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      height: 1.4,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ] else ...[
                  Text(
                    AppLocalizations.of(context)!.verifiedAndAuthenticated,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      height: 1.4,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ],
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
            ],
          ),
        ),
      ),
    );
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
      ],
    );
  }

  Widget _buildPersonalInfoSection(
      CountryModel? country, AppLocalizations localizations) {
    final infoItems = <Widget>[];

    // Location info
    if (_cv!.city != null || _cv!.state != null || country != null) {
      final locationText = [
        _cv!.city,
        _cv!.state,
        if (country != null) '${country.name} ${country.emoji ?? ''}',
      ].where((element) => element != null && element.isNotEmpty).join(', ');

      infoItems.add(_buildFormalInfoItem(
        Icons.location_on,
        AppLocalizations.of(context)!.address,
        _toTitleCase(locationText),
      ));
    }

    // Birth info
    if (_cv!.dateOfBirth != null) {
      infoItems.add(_buildFormalInfoItem(
        Icons.person_outline,
        AppLocalizations.of(context)!.dateOfBirth,
        _formatFormalBirthInfo(),
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
