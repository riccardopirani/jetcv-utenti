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
import 'package:jetcv__utenti/supabase/supabase_config.dart';
import 'package:jetcv__utenti/l10n/app_localizations.dart';

import 'package:share_plus/share_plus.dart';

class CVViewPage extends StatefulWidget {
  final String? cvUserId; // ID dell'utente di cui visualizzare il CV

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
          _errorMessage = 'User not authenticated';
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
          _errorMessage = cvResponse.error ?? 'Failed to load CV data';
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
    } catch (e) {
      debugPrint('Error loading CV data: $e');
      setState(() {
        _errorMessage = 'Error loading CV data: $e';
        _isLoading = false;
      });
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

  String _formatBirthInfo() {
    final localizations = AppLocalizations.of(context)!;
    if (_cv?.dateOfBirth == null) return '';

    final birthDate = DateTime.tryParse(_cv!.dateOfBirth!);
    if (birthDate == null) return '';

    final age = _calculateAge(birthDate);
    final gender = _cv?.gender;

    // Use gender-appropriate translation for "born"
    final bornText =
        (gender == 'female') ? localizations.bornFemale : localizations.born;

    return '$bornText ${birthDate.day}/${birthDate.month}/${birthDate.year} ($age ${localizations.years})';
  }

  String _generateCVSerial() {
    if (_cv?.serial != null) {
      return _cv!.serial;
    }

    // Fallback: generate from idCvHash or idCv
    if (_cv?.idCvHash != null) {
      final hash = _cv!.idCvHash!.toUpperCase();
      if (hash.length >= 8) {
        return 'CV-${hash.substring(0, 4)}-${hash.substring(4, 8)}';
      }
      return 'CV-${hash.padRight(8, 'X').substring(0, 4)}-${hash.padRight(8, 'X').substring(4, 8)}';
    }

    return 'CV-XXXX-XXXX';
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
              content: Text('Errore nella generazione dell\'URL pubblico'),
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
                    child: Text(
                        'Link del CV copiato negli appunti! Condividilo ora.'),
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
    final localizations = AppLocalizations.of(context)!;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(localizations.viewCV),
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
          title: Text(localizations.viewCV),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
          child: Text(
            _errorMessage ?? 'CV data not available',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final country = _getCountryByCode(_cv!.countryCode);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.viewCV),
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Removed share action - moved to main body
      ),
      body: SafeArea(
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

              // Languages section (placeholder)
              _buildLanguagesSection(),

              const SizedBox(height: 32),

              // Attitudes section (placeholder)
              _buildAttitudesSection(),

              const SizedBox(height: 32),
            ],
          ),
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
          // Outer glow effect
          Container(
            width: double.infinity,
            height: 400,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.2,
                colors: [
                  Colors.blue.withValues(alpha: 0.15),
                  Colors.purple.withValues(alpha: 0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // Main certificate container
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.shade400,
                  Colors.indigo.shade500,
                  Colors.purple.shade500,
                  Colors.pink.shade400,
                ],
                stops: const [0.0, 0.3, 0.7, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withValues(alpha: 0.3),
                  spreadRadius: 0,
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.purple.withValues(alpha: 0.2),
                  spreadRadius: 0,
                  blurRadius: 30,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white,
                    Colors.grey.shade50,
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.8),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    spreadRadius: 0,
                    blurRadius: 25,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white,
                        Colors.blue.shade50.withValues(alpha: 0.3),
                        Colors.purple.shade50.withValues(alpha: 0.2),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                  child: Column(
                    children: [
                      // Premium certification badge
                      _buildPremiumBadge(localizations),

                      const SizedBox(height: 28),

                      // Enhanced profile picture
                      _buildEnhancedProfilePicture(),

                      const SizedBox(height: 24),

                      // Name with premium styling
                      _buildNameSection(),

                      const SizedBox(height: 20),

                      // Elegant divider
                      _buildElegantDivider(),

                      const SizedBox(height: 20),

                      // Personal information cards
                      _buildPersonalInfoCards(country, localizations),

                      const SizedBox(height: 24),

                      // Premium CV Serial
                      _buildPremiumCVSerial(localizations),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Premium corner decorations
          _buildPremiumCornerDecorations(),

          // Floating verification badge
          _buildFloatingVerificationBadge(),
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
                value: [
                  _cv!.address,
                  _cv!.city,
                  _cv!.state,
                  _cv!.postalCode,
                ]
                    .where((element) => element != null && element.isNotEmpty)
                    .join(', '),
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

  Widget _buildLanguagesSection() {
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
                  Icons.translate,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  localizations.languages,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 20),
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
                localizations.languagesPlaceholder,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttitudesSection() {
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
                  Icons.psychology,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  localizations.attitudes,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 20),
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
                localizations.attitudesPlaceholder,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareSection() {
    final localizations = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue.shade50,
                Colors.indigo.shade50,
                Colors.purple.shade50,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Icon container
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.blue.shade400,
                        Colors.indigo.shade500,
                        Colors.purple.shade600,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withValues(alpha: 0.3),
                        spreadRadius: 0,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.share,
                    color: Colors.white,
                    size: 24,
                  ),
                ),

                const SizedBox(width: 16),

                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizations.shareCV,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo.shade800,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'CV certificato blockchain',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.indigo.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // Single share button
                ElevatedButton.icon(
                  onPressed: _shareCV,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 4,
                    shadowColor: Colors.indigo.withValues(alpha: 0.4),
                  ),
                  icon: Icon(
                    kIsWeb ? Icons.copy : Icons.share,
                    size: 18,
                  ),
                  label: Text(
                    kIsWeb ? 'Copia Link' : 'Condividi',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
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
  Widget _buildPremiumBadge(AppLocalizations localizations) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber.shade100,
            Colors.amber.shade50,
            Colors.orange.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          width: 2,
          color: Colors.amber.shade300,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withValues(alpha: 0.3),
            spreadRadius: 0,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.amber.shade200,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.verified,
              color: Colors.amber.shade800,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            localizations.blockchainCertified,
            style: TextStyle(
              color: Colors.amber.shade900,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.amber.shade600,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withValues(alpha: 0.5),
                  spreadRadius: 2,
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedProfilePicture() {
    return Stack(
      children: [
        // Outer glow ring
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                Colors.blue.shade400,
                Colors.purple.shade400,
                Colors.pink.shade300,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withValues(alpha: 0.4),
                spreadRadius: 0,
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
        ),
        // Middle ring
        Positioned(
          top: 4,
          left: 4,
          child: Container(
            width: 132,
            height: 132,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  spreadRadius: 0,
                  blurRadius: 15,
                ),
              ],
            ),
          ),
        ),
        // Inner picture frame
        Positioned(
          top: 8,
          left: 8,
          child: Container(
            width: 124,
            height: 124,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.shade100,
                  Colors.white,
                  Colors.purple.shade50,
                ],
              ),
              border: Border.all(
                color: Colors.blue.shade200,
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(60),
              child: _cv!.profilePicture != null
                  ? Image.network(
                      _cv!.profilePicture!,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue.shade100,
                              Colors.purple.shade100
                            ],
                          ),
                        ),
                        child: Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.indigo.shade400,
                        ),
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue.shade100,
                            Colors.purple.shade100
                          ],
                        ),
                      ),
                      child: Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.indigo.shade400,
                      ),
                    ),
            ),
          ),
        ),
        // Premium badge overlay
        Positioned(
          bottom: 8,
          right: 8,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.amber.shade400, Colors.orange.shade400],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withValues(alpha: 0.4),
                  spreadRadius: 0,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.diamond,
              color: Colors.white,
              size: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNameSection() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.indigo.shade50,
                Colors.blue.shade50,
                Colors.purple.shade50,
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.indigo.shade100,
              width: 1,
            ),
          ),
          child: Text(
            '${_cv!.firstName ?? ''} ${_cv!.lastName ?? ''}'.trim(),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.indigo.shade800,
              letterSpacing: 1.2,
              shadows: [
                Shadow(
                  color: Colors.indigo.withValues(alpha: 0.1),
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildElegantDivider() {
    return Container(
      height: 60,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background gradient line
          Container(
            height: 2,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.blue.shade300,
                  Colors.purple.shade300,
                  Colors.pink.shade300,
                  Colors.transparent,
                ],
              ),
            ),
          ),
          // Central decoration
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  Colors.white,
                  Colors.blue.shade50,
                ],
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.blue.shade200,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withValues(alpha: 0.2),
                  spreadRadius: 0,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.auto_awesome,
              color: Colors.indigo.shade400,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoCards(
      CountryModel? country, AppLocalizations localizations) {
    final infoItems = <Widget>[];

    // Location card
    if (_cv!.city != null || _cv!.state != null || country != null) {
      final locationText = [
        _cv!.city,
        _cv!.state,
        if (country != null) '${country.name} ${country.emoji ?? ''}',
      ].where((element) => element != null && element.isNotEmpty).join(', ');

      infoItems
          .add(_buildInfoCard(Icons.location_on, locationText, Colors.blue));
    }

    // Birth info card
    if (_cv!.dateOfBirth != null) {
      infoItems
          .add(_buildInfoCard(Icons.cake, _formatBirthInfo(), Colors.purple));
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: infoItems,
    );
  }

  Widget _buildInfoCard(IconData icon, String text, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.shade50,
            color.shade100,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color.shade700,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                color: color.shade800,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumCVSerial(AppLocalizations localizations) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey.shade50,
            Colors.blue.shade50,
            Colors.purple.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.indigo.shade200,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withValues(alpha: 0.1),
            spreadRadius: 0,
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.fingerprint,
                color: Colors.indigo.shade400,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                localizations.cvSerial,
                style: TextStyle(
                  color: Colors.indigo.shade600,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.indigo.shade50],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.indigo.shade100,
                width: 1,
              ),
            ),
            child: Text(
              _generateCVSerial(),
              style: TextStyle(
                color: Colors.indigo.shade800,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                letterSpacing: 3,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumCornerDecorations() {
    return Positioned.fill(
      child: Stack(
        children: [
          // Top corners with animated dots
          ...List.generate(4, (index) {
            final positions = [
              {'top': 20.0, 'left': 20.0}, // Top-left
              {'top': 20.0, 'right': 20.0}, // Top-right
              {'bottom': 20.0, 'left': 20.0}, // Bottom-left
              {'bottom': 20.0, 'right': 20.0}, // Bottom-right
            ];

            return Positioned(
              top: positions[index]['top'],
              left: positions[index]['left'],
              right: positions[index]['right'],
              bottom: positions[index]['bottom'],
              child: _buildCornerDot(index),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCornerDot(int index) {
    final colors = [
      Colors.blue.shade400,
      Colors.purple.shade400,
      Colors.pink.shade400,
      Colors.indigo.shade400,
    ];

    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: colors[index],
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: colors[index].withValues(alpha: 0.4),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingVerificationBadge() {
    return Positioned(
      top: 40,
      right: 40,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade400, Colors.teal.shade400],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.green.withValues(alpha: 0.4),
              spreadRadius: 0,
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(
          Icons.verified_user,
          color: Colors.white,
          size: 24,
        ),
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

                    return InkWell(
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
              'languageCode': locale.languageCode,
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
            content: Text('Error changing language: $e'),
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
        : 'Language';
    final currentLanguageEmoji = currentLocale != null
        ? LocaleService.instance.getLanguageEmoji(currentLocale.languageCode)
        : null;

    return GestureDetector(
      key: _buttonKey,
      onTap: _showDropdown,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
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
