import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jetcv__utenti/l10n/app_localizations.dart';
import 'package:jetcv__utenti/widgets/attached_media_widget.dart';
import 'package:jetcv__utenti/services/certification_service.dart';
import 'package:jetcv__utenti/models/location_model.dart';
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
                // Category name (certification type) - with more vertical margin
                if (cert.certification?.category?.name != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _getLocalizedCertificationType(
                      context,
                      cert.certification!.category!.name,
                    ),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Legal Entity (shown first, immediately with cached data)
                if (widget.showLegalEntityLogo) ...[
                  _buildOrganizationRow(context),
                  const SizedBox(height: 12),
                ],

                // Certifier name (from expanded certifier data in new API)
                if (widget.showCertifiedUserName &&
                    cert.certification?.certifier != null) ...[
                  Row(
                    children: [
                      const Icon(Icons.person, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _getCertifierFullName(cert.certification!.certifier!),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],

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

                // Location (if available)
                if (cert.certification?.location != null) ...[
                  const SizedBox(height: 12),
                  _buildLocationRow(context, cert.certification!.location!),
                ],

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
    // Get picture URL from certification category
    final pictureUrl =
        widget.certification.certification?.category?.pictureUrl?.trim();
    final hasValidPictureUrl = pictureUrl?.isNotEmpty == true;

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
      child: hasValidPictureUrl
          ? Image.network(
              pictureUrl!,
              height: height,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Fallback to gradient with certification icon if image fails to load
                return _buildFallbackHeaderImage(height);
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
            )
          : _buildFallbackHeaderImage(height),
    );
  }

  Widget _buildFallbackHeaderImage(double height) {
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
          size: 48,
          color: Colors.blue.shade400,
        ),
      ),
    );
  }

  Widget _buildOrganizationRow(BuildContext context) {
    final certification = widget.certification.certification;
    if (certification == null) return const SizedBox.shrink();

    // Get the name directly from expanded legal_entity data (new API) or fallback to service call
    String? organizationName;
    String? legalEntityId;

    if (certification.legalEntity != null) {
      // Use expanded legal_entity data from new API - show immediately!
      organizationName =
          certification.legalEntity!.legalName?.trim().isNotEmpty == true
              ? certification.legalEntity!.legalName!.trim()
              : null;
      legalEntityId = certification.legalEntity!.idLegalEntity;
    } else if (certification.idLegalEntity != null) {
      // Fallback: use legacy loading with cache
      legalEntityId = certification.idLegalEntity!;
      organizationName = _legalEntityIdToNameCache[legalEntityId];
    }

    if (organizationName != null && legalEntityId != null) {
      // Show immediately with available data
      return Row(
        children: [
          _buildLegalEntityLogo(
              legalEntityId), // Logo loads asynchronously with cache
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              organizationName,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
  }

  Widget _buildLegalEntityLogo(String legalEntityId) {
    // Get logo URL from expanded legal_entity data (API 1.0.8) or cache
    String? logoUrl = _legalEntityIdToLogoCache[legalEntityId];

    // If not cached, get from expanded API data and cache it
    if (logoUrl == null) {
      final certification = widget.certification.certification;
      if (certification?.legalEntity?.idLegalEntity == legalEntityId) {
        logoUrl = certification!.legalEntity!.logoPicture?.trim();
        if (logoUrl?.isNotEmpty == true) {
          // Cache the logo URL for future use
          _legalEntityIdToLogoCache[legalEntityId] = logoUrl;
        } else {
          // Cache null to avoid repeated checks
          _legalEntityIdToLogoCache[legalEntityId] = null;
        }
      } else {
        // Cache null if legal entity doesn't match
        _legalEntityIdToLogoCache[legalEntityId] = null;
      }
    }

    if (logoUrl?.isNotEmpty == true) {
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
          logoUrl!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.corporate_fare,
              size: 18,
              color: Colors.grey.shade600,
            );
          },
        ),
      );
    }

    // Show default icon if no logo available
    return Icon(
      Icons.corporate_fare,
      size: 18,
      color: Colors.grey.shade600,
    );
  }

  Widget _buildLocationRow(BuildContext context, LocationModel location) {
    final theme = Theme.of(context);
    final locationText = _formatLocationText(location);

    if (locationText.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        const Icon(Icons.location_on, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            locationText,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _formatLocationText(LocationModel location) {
    final List<String> parts = [];

    // Add name if available (e.g., "Università di Bologna")
    if (location.name?.isNotEmpty == true) {
      parts.add(location.name!);
      return parts.join(', '); // If we have a name, just show that
    }

    // Otherwise build address components

    // Add street (thoroughfare + subThoroughfare)
    if (location.thoroughfare?.isNotEmpty == true) {
      String street = location.thoroughfare!;
      if (location.subThoroughfare?.isNotEmpty == true) {
        street = '${location.subThoroughfare} $street';
      }
      parts.add(street);
    }

    // Add locality (city)
    if (location.locality?.isNotEmpty == true) {
      parts.add(location.locality!);
    }

    // Add administrative area (state/region)
    if (location.administrativeArea?.isNotEmpty == true) {
      parts.add(location.administrativeArea!);
    }

    // Add country
    if (location.country?.isNotEmpty == true) {
      parts.add(location.country!);
    }

    return parts.join(', ');
  }

  String _getCertifierFullName(CertifierInfo certifier) {
    // First try to get name from expanded user data (new API)
    if (certifier.user != null) {
      final user = certifier.user!;
      final firstName = user.firstName?.trim();
      final lastName = user.lastName?.trim();

      if (firstName?.isNotEmpty == true && lastName?.isNotEmpty == true) {
        return '$firstName $lastName';
      }

      // If only one name is available from user data
      if (firstName?.isNotEmpty == true) {
        return firstName!;
      }
      if (lastName?.isNotEmpty == true) {
        return lastName!;
      }

      // Try fullName from user if firstName/lastName are not available
      if (user.fullName?.trim().isNotEmpty == true) {
        return user.fullName!.trim();
      }
    }

    // Fallback to legacy certifier fields if user data is not available
    final firstName = certifier.firstName?.trim();
    final lastName = certifier.lastName?.trim();

    if (firstName?.isNotEmpty == true && lastName?.isNotEmpty == true) {
      return '$firstName $lastName';
    }

    // If only one name is available from certifier
    if (firstName?.isNotEmpty == true) {
      return firstName!;
    }
    if (lastName?.isNotEmpty == true) {
      return lastName!;
    }

    // Try fullName from certifier if firstName/lastName are not available
    if (certifier.fullName?.trim().isNotEmpty == true) {
      return certifier.fullName!.trim();
    }

    return 'Certificatore'; // Final fallback
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
      height: 28, // Reduced LinkedIn button height
      width: double.infinity, // Take full available width with max constraint
      child: ConstrainedBox(
        constraints: const BoxConstraints(
            maxWidth: 180), // Reduced max width for LinkedIn buttons
        child: ElevatedButton.icon(
          onPressed: () => _createOpenBadge(context, cert),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4CAF50),
            foregroundColor: Colors.white,
            elevation: 2,
            shadowColor: const Color(0xFF4CAF50).withValues(alpha: 0.3),
            shape: RoundedRectangleBorder(borderRadius: borderRadius),
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 6), // Reduced padding for 28px height
            minimumSize: const Size(0, 28), // Force minimum height
          ),
          icon: Icon(Icons.workspace_premium,
              size: 14), // Reduced icon size for 28px button
          label: Text(
            AppLocalizations.of(context)!.createOpenBadge,
            style: TextStyle(
              fontSize: 12, // Reduced font size for 28px button
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
    // Scale down LinkedIn image/button by 30%
    const double linkedInScale = 0.7;
    final double linkedInHeight = 28.0 * linkedInScale;
    final double linkedInMaxWidth = 180.0 * linkedInScale;

    return GestureDetector(
      onTap: () => _openLinkedInForCertification(context, cert),
      child: SizedBox(
        height: linkedInHeight, // 30% smaller height
        width: double.infinity, // Take full available width with max constraint
        child: ConstrainedBox(
          constraints: BoxConstraints(
              maxWidth: linkedInMaxWidth), // 30% smaller max width
          child: ClipRRect(
            borderRadius: borderRadius,
            child: Image.asset(
              linkedInButtonImage,
              height: linkedInHeight, // 30% smaller height
              width:
                  null, // Let width adjust automatically to maintain aspect ratio
              fit: BoxFit
                  .fitHeight, // Maintain aspect ratio while fitting height
              errorBuilder: (context, error, stackTrace) {
                // Fallback to styled button matching the same height if image fails to load
                return SizedBox(
                  height: linkedInHeight,
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
                          horizontal: 10,
                          vertical: 5), // Padding retained while smaller height
                      minimumSize:
                          Size(0, linkedInHeight), // Force minimum height
                    ),
                    icon: Icon(Icons.link,
                        size: 14), // Reduced icon size for 28px button
                    label: Text(
                      localizations.addToLinkedIn,
                      style: TextStyle(
                        fontSize: 12, // Reduced font size for 28px button
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
      // Get organization name directly from expanded legal_entity data
      final organizationName =
          cert.certification?.legalEntity?.legalName?.trim().isNotEmpty == true
              ? cert.certification!.legalEntity!.legalName!.trim()
              : 'Organizzazione';
      final issueDate = cert.certificationUser.createdAt;
      final certId = cert.certificationUser.idCertificationUser;

      final baseUrl =
          'https://www.linkedin.com/profile/add?startTask=CERTIFICATION_NAME';
      final certUrl = cert.certification?.idCertification != null
          ? 'https://jetcv.com/certification/${cert.certification!.idCertification}'
          : 'https://jetcv.com';

      final params = {
        'name': Uri.encodeComponent(certName),
        'organizationName': Uri.encodeComponent(organizationName),
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
