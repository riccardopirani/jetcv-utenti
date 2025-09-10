import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jetcv__utenti/l10n/app_localizations.dart';
import 'package:jetcv__utenti/services/legal_entity_service.dart';
import 'package:jetcv__utenti/widgets/attached_media_widget.dart';
import 'package:jetcv__utenti/services/certification_service.dart';
import 'package:url_launcher/url_launcher.dart';

/// Reusable certification card widget to display a user certification
///
/// This widget is intentionally self-contained and can be configured
/// via flags to render a compact variant or a rich variant with media,
/// logos, LinkedIn/OpenBadge actions, etc.
class CertificationCard extends StatefulWidget {
  final UserCertificationDetail certification;

  /// Action controls
  final bool showActions;
  final bool showRejectionReason;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  /// Visual feature flags
  final bool showImageHeader;
  final bool showLegalEntityLogo;
  final bool showMediaSection;
  final bool showOpenBadgeButton;
  final bool showLinkedInButton;
  final bool showCertifiedUserName;

  const CertificationCard({
    super.key,
    required this.certification,
    this.showActions = false,
    this.showRejectionReason = false,
    this.onApprove,
    this.onReject,
    this.showImageHeader = false,
    this.showLegalEntityLogo = false,
    this.showMediaSection = false,
    this.showOpenBadgeButton = false,
    this.showLinkedInButton = false,
    this.showCertifiedUserName = false,
  });

  @override
  State<CertificationCard> createState() => _CertificationCardState();
}

class _CertificationCardState extends State<CertificationCard> {
  // Simple in-memory caches to avoid repeated lookups
  static final Map<String, String> _legalEntityIdToNameCache = {};
  static final Map<String, String?> _legalEntityIdToLogoCache = {};

  // TODO: OpenBadge feature temporarily disabled - can be re-enabled in future
  static const bool _isOpenBadgeEnabled = false;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cert = widget.certification;

    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;

    final headerImageHeight = 120.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.showImageHeader)
            _buildHeaderImage(context, headerImageHeight),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Serial number badge (if available) - moved above title
                if (cert.certificationUser.serialNumber != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
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
                          size: 16,
                          color: Colors.green.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${localizations.serialNumber}: ${cert.certificationUser.serialNumber}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.green.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],

                // Title (Certification category name localized when possible)
                if (cert.certification?.category?.name != null)
                  Text(
                    _getLocalizedCertificationType(
                      context,
                      cert.certification!.category!.name,
                    ),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                const SizedBox(height: 8),

                // Certifier display name (from edge function if present) - only show if enabled
                if (widget.showCertifiedUserName &&
                    cert.certification?.nomeCertificatore != null)
                  Row(
                    children: [
                      const Icon(Icons.person, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          cert.certification!.nomeCertificatore!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                if (widget.showLegalEntityLogo) ...[
                  const SizedBox(height: 8),
                  _buildOrganizationRow(context),
                ],

                const SizedBox(height: 16),

                // Created date
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '${localizations.createdOn} ${DateFormat('dd/MM/yyyy').format(cert.certificationUser.createdAt)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),

                // Rejection reason if available
                if (widget.showRejectionReason &&
                    cert.certificationUser.rejectionReason != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info, size: 16, color: Colors.red),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              localizations.rejectedReason,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              cert.certificationUser.rejectionReason!.isEmpty
                                  ? localizations.noRejectionReason
                                  : cert.certificationUser.rejectionReason!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],

                // Optional content sections
                if (widget.showMediaSection) ...[
                  const SizedBox(height: 12),
                  _buildAttachedMediaSection(cert),
                ],

                // Show OpenBadge and LinkedIn buttons only if certification is accepted
                if ((_isOpenBadgeEnabled && widget.showOpenBadgeButton ||
                        widget.showLinkedInButton) &&
                    cert.certificationUser.status == 'accepted') ...[
                  const SizedBox(height: 12),
                  _buildResponsiveActionButtons(
                      context, cert, isMobile, isTablet),
                ],

                // Actions (approve / reject)
                if (widget.showActions) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: widget.onApprove,
                          icon: const Icon(Icons.check),
                          label: Text(localizations.approve),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: widget.onReject,
                          icon: const Icon(Icons.close),
                          label: Text(localizations.reject),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderImage(BuildContext context, double height) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.network(
        // Demo image - replace with actual certification image later
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800&h=200&fit=crop&crop=center',
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // Fallback to gradient with icon if image fails to load
          return Container(
            height: height,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.blue.shade50, Colors.blue.shade100],
              ),
            ),
            child: Center(
              child: Icon(
                Icons.workspace_premium,
                size: 32,
                color: Colors.grey.shade700,
              ),
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            height: height,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
            ),
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
                strokeWidth: 2,
                color: Colors.grey.shade400,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrganizationRow(BuildContext context) {
    final legalEntityId = widget.certification.certification?.idLegalEntity;
    if (legalEntityId == null) return const SizedBox.shrink();

    return FutureBuilder<(String, String?)>(
      future: _loadOrganization(legalEntityId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }
        final (name, logoUrl) = snapshot.data!;
        return Row(
          children: [
            _buildLegalEntityLogo(logoUrl),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Legal Entity: $name',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLegalEntityLogo(String? logoUrl) {
    if (logoUrl == null || logoUrl.isEmpty) {
      return Icon(
        Icons.corporate_fare,
        size: 18,
        color: Colors.grey.shade600,
      );
    }

    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 0.5,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.network(
        logoUrl,
        fit: BoxFit.cover,
      ),
    );
  }

  Future<(String, String?)> _loadOrganization(String legalEntityId) async {
    // Name cache
    String name;
    if (_legalEntityIdToNameCache.containsKey(legalEntityId)) {
      name = _legalEntityIdToNameCache[legalEntityId]!;
    } else {
      final legalEntity =
          await LegalEntityService.getLegalEntityById(legalEntityId);
      name = LegalEntityService.getCompanyName(legalEntity);
      _legalEntityIdToNameCache[legalEntityId] = name;
    }

    // Logo cache
    String? logo;
    if (_legalEntityIdToLogoCache.containsKey(legalEntityId)) {
      logo = _legalEntityIdToLogoCache[legalEntityId];
    } else {
      final legalEntity =
          await LegalEntityService.getLegalEntityById(legalEntityId);
      if (legalEntity != null &&
          legalEntity.logoPicture != null &&
          legalEntity.logoPicture!.isNotEmpty) {
        logo = legalEntity.logoPicture;
      } else {
        logo = null;
      }
      _legalEntityIdToLogoCache[legalEntityId] = logo;
    }

    return (name, logo);
  }

  Widget _buildAttachedMediaSection(UserCertificationDetail cert) {
    final totalMediaCount =
        cert.media.directMedia.length + cert.media.linkedMedia.length;
    if (totalMediaCount == 0) return const SizedBox.shrink();
    return AttachedMediaWidget(
      certification: cert,
      totalMediaCount: totalMediaCount,
    );
  }

  String _getLocalizedCertificationType(
      BuildContext context, String originalType) {
    final localizations = AppLocalizations.of(context)!;
    final normalizedType =
        originalType.toLowerCase().trim().replaceAll(RegExp(r'\s+'), '_');
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
        return originalType;
    }
  }

  Widget _buildResponsiveActionButtons(
    BuildContext context,
    UserCertificationDetail cert,
    bool isMobile,
    bool isTablet,
  ) {
    final localizations = AppLocalizations.of(context)!;

    // Fixed button styling for all devices
    final buttonHeight = 48.0;
    final iconSize = 20.0;
    final fontSize = 16.0;
    final borderRadius = BorderRadius.circular(10.0);

    return isMobile
        ? Column(
            children: [
              if (_isOpenBadgeEnabled && widget.showOpenBadgeButton)
                SizedBox(
                  width: double.infinity,
                  height: buttonHeight,
                  child: _buildOpenBadgeButton(
                      context, cert, iconSize, fontSize, borderRadius),
                ),
              if (_isOpenBadgeEnabled &&
                  widget.showOpenBadgeButton &&
                  widget.showLinkedInButton)
                const SizedBox(height: 8),
              if (widget.showLinkedInButton)
                SizedBox(
                  width: double.infinity,
                  height: buttonHeight,
                  child: _buildLinkedInButton(context, cert, localizations,
                      iconSize, fontSize, borderRadius),
                ),
            ],
          )
        : Row(
            children: [
              if (_isOpenBadgeEnabled && widget.showOpenBadgeButton)
                Expanded(
                  child: SizedBox(
                    height: buttonHeight,
                    child: _buildOpenBadgeButton(
                        context, cert, iconSize, fontSize, borderRadius),
                  ),
                ),
              if (_isOpenBadgeEnabled &&
                  widget.showOpenBadgeButton &&
                  widget.showLinkedInButton)
                const SizedBox(width: 12),
              if (widget.showLinkedInButton)
                Expanded(
                  child: SizedBox(
                    height: buttonHeight,
                    child: _buildLinkedInButton(context, cert, localizations,
                        iconSize, fontSize, borderRadius),
                  ),
                ),
            ],
          );
  }

  Widget _buildOpenBadgeButton(
    BuildContext context,
    UserCertificationDetail cert,
    double iconSize,
    double fontSize,
    BorderRadius borderRadius,
  ) {
    return SizedBox(
      height: 35, // Match LinkedIn button height (35px)
      width: double.infinity, // Take full available width with max constraint
      child: ConstrainedBox(
        constraints: const BoxConstraints(
            maxWidth: 210), // Max width like LinkedIn buttons
        child: ElevatedButton.icon(
          onPressed: () => _createOpenBadge(context, cert),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4CAF50),
            foregroundColor: Colors.white,
            elevation: 2,
            shadowColor: const Color(0xFF4CAF50).withValues(alpha: 0.3),
            shape: RoundedRectangleBorder(borderRadius: borderRadius),
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 8), // Proper padding for 35px height
            minimumSize: const Size(0, 35), // Force minimum height
          ),
          icon: Icon(Icons.workspace_premium,
              size: 16), // Proper icon size for 35px button
          label: Text(
            AppLocalizations.of(context)!.createOpenBadge,
            style: TextStyle(
              fontSize: 14, // Proper font size for 35px button
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  Widget _buildLinkedInButton(
    BuildContext context,
    UserCertificationDetail cert,
    AppLocalizations localizations,
    double iconSize,
    double fontSize,
    BorderRadius borderRadius,
  ) {
    final linkedInButtonImage = _getLinkedInButtonImage(context);

    return GestureDetector(
      onTap: () => _openLinkedInForCertification(context, cert),
      child: SizedBox(
        height: 35, // Match standard LinkedIn button height
        width: double.infinity, // Take full available width with max constraint
        child: ConstrainedBox(
          constraints: const BoxConstraints(
              maxWidth: 210), // Max width like LinkedIn buttons
          child: ClipRRect(
            borderRadius: borderRadius,
            child: Image.asset(
              linkedInButtonImage,
              height: 35, // Match standard LinkedIn button height
              width:
                  null, // Let width adjust automatically to maintain aspect ratio
              fit: BoxFit
                  .fitHeight, // Maintain aspect ratio while fitting height
              errorBuilder: (context, error, stackTrace) {
                // Fallback to styled button matching the same height if image fails to load
                return SizedBox(
                  height: 35,
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        _openLinkedInForCertification(context, cert),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0077B5),
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shadowColor:
                          const Color(0xFF0077B5).withValues(alpha: 0.3),
                      shape: RoundedRectangleBorder(borderRadius: borderRadius),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8), // Proper padding for 35px height
                      minimumSize: const Size(0, 35), // Force minimum height
                    ),
                    icon: Icon(Icons.link,
                        size: 16), // Proper icon size for 35px button
                    label: Text(
                      localizations.addToLinkedIn,
                      style: TextStyle(
                        fontSize: 14, // Proper font size for 35px button
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  String _getLinkedInButtonImage(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final languageCode = locale.languageCode;
    final countryCode = locale.countryCode;

    // Create locale string in format: language_COUNTRY
    String localeString = '';
    if (countryCode != null) {
      localeString = '${languageCode}_${countryCode.toUpperCase()}';
    } else {
      // Default country codes for languages
      switch (languageCode) {
        case 'it':
          localeString = 'it_IT';
          break;
        case 'en':
          localeString = 'en_US';
          break;
        case 'de':
          localeString = 'de_DE';
          break;
        case 'es':
          localeString = 'es_ES';
          break;
        case 'fr':
          localeString = 'fr_FR';
          break;
        default:
          localeString = 'en_US'; // Default fallback
      }
    }

    // List of available LinkedIn button locales
    const availableLocales = {
      'cs_CZ',
      'da_DK',
      'de_DE',
      'en_US',
      'es_ES',
      'fr_FR',
      'in_ID',
      'it_IT',
      'ja_JP',
      'ko_KR',
      'ms_MY',
      'nl_NL',
      'no_NO',
      'pt_BR',
      'ro_RO',
      'ru_RU',
      'sv_SE',
      'tr_TR',
      'zh_TW'
    };

    // Check if the exact locale exists, otherwise fallback to en_US
    final selectedLocale =
        availableLocales.contains(localeString) ? localeString : 'en_US';

    return 'assets/linkedin-add-to-profile-buttons/$selectedLocale.png';
  }

  Future<void> _createOpenBadge(
    BuildContext context,
    UserCertificationDetail cert,
  ) async {
    // TODO: Implement OpenBadge creation logic similar to OpenBadgeButton widget
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.createOpenBadge),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _openLinkedInForCertification(
    BuildContext context,
    UserCertificationDetail cert,
  ) async {
    try {
      final certName = cert.certification?.category?.name != null
          ? _getLocalizedCertificationType(
              context, cert.certification!.category!.name)
          : 'Certification';
      final organizationName = await _loadOrganization(
        cert.certification?.idLegalEntity ?? '',
      );
      final issueDate = cert.certificationUser.createdAt;
      final certId = cert.certificationUser.idCertificationUser;

      final baseUrl =
          'https://www.linkedin.com/profile/add?startTask=CERTIFICATION_NAME';
      final certUrl = cert.certification?.idCertification != null
          ? 'https://jetcv.com/certification/${cert.certification!.idCertification}'
          : 'https://jetcv.com';

      final params = {
        'name': Uri.encodeComponent(certName),
        'organizationName': Uri.encodeComponent(organizationName.$1),
        'issueYear': issueDate.year.toString(),
        'issueMonth': issueDate.month.toString(),
        'certUrl': Uri.encodeComponent(certUrl),
        'certId': certId,
      };

      final expirationDate = cert.certification?.closedAt;
      if (expirationDate != null) {
        params['expirationYear'] = expirationDate.year.toString();
        params['expirationMonth'] = expirationDate.month.toString();
      }

      final queryString =
          params.entries.map((e) => '${e.key}=${e.value}').join('&');
      final url = '$baseUrl&$queryString';

      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {
      // Non-blocking: ignore failures silently
    }
  }
}
