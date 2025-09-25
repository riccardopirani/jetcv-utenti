import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jetcv__utenti/l10n/app_localizations.dart';
import 'package:jetcv__utenti/widgets/attached_media_widget.dart';
import 'package:jetcv__utenti/services/certification_service.dart';
import 'package:jetcv__utenti/models/location_model.dart';

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
  final bool showCertifiedUserName;
  final bool showSerialNumber;
  final bool showCreatedDate;
  final bool showLocation;

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
    this.showCertifiedUserName = false,
    this.showSerialNumber = true,
    this.showCreatedDate = true,
    this.showLocation = true,
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

    final headerImageHeight = 144.0; // Increased by 20% from 120

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
                // Title (Certification category name) - now shown only in blur overlay

                // Title information (from certification_information_value where name = "titolo")
                if (widget.showLegalEntityLogo) ...[
                  if (_getTitleInformation() != null) ...[
                    Text(
                      _getTitleInformation()!,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Legal Entity (shown first, immediately with cached data)
                  _buildOrganizationRow(context),
                  const SizedBox(height: 12),
                ],

                // Certifier name (from expanded certifier data in new API)
                if (widget.showCertifiedUserName &&
                    cert.certification?.certifier?.user != null &&
                    _hasCertifierName(cert.certification!.certifier!)) ...[
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

                // Show OpenBadge button only if certification is accepted
                if (_isOpenBadgeEnabled &&
                    widget.showOpenBadgeButton &&
                    cert.certificationUser.status == 'accepted') ...[
                  const SizedBox(height: 12),
                  _buildResponsiveActionButtons(
                    context,
                    cert,
                    isMobile,
                    isTablet,
                  ),
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
                            minimumSize: const Size(0, 48),
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
                            minimumSize: const Size(0, 48),
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
    final cert = widget.certification;

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
      child: Stack(
        children: [
          // Background image
          SizedBox(
            height: height,
            width: double.infinity,
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
                        decoration: BoxDecoration(color: Colors.grey.shade100),
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
          ),

          // Blur overlay at the bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.1),
                        Colors.black.withValues(alpha: 0.3),
                      ],
                      stops: const [0.0, 0.3, 1.0],
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left side - certification info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Certification type name
                            Text(
                              _getLocalizedCertificationType(
                                context,
                                cert.certification?.category?.name ??
                                    'Certificazione',
                              ),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                shadows: const [
                                  Shadow(
                                    offset: Offset(0, 1),
                                    blurRadius: 2,
                                    color: Colors.black54,
                                  ),
                                ],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),

                            // Pills
                            _buildImageOverlayPills(cert),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Right side - certified badge (centered vertically)
                      Align(
                        alignment: Alignment.center,
                        child: _buildCertifiedBadge(),
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

  Widget _buildImageOverlayPills(UserCertificationDetail cert) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: [
        // Data pill - first
        _buildOverlayPill(
          icon: Icons.calendar_today,
          label: _formatCertificationDate(cert.certificationUser.createdAt),
          isMobile: isMobile,
        ),

        // Location pill with flag emoji or generic icon
        if (cert.certification?.location != null)
          _buildOverlayPill(
            icon: _getLocationIconOrEmoji(cert.certification!.location!),
            label: _formatLocationForOverlayPill(cert.certification!.location!),
            isMobile: isMobile,
          ),

        // Serial pill
        if (cert.certificationUser.serialNumber != null)
          _buildOverlayPill(
            icon: Icons.tag,
            label: cert.certificationUser.serialNumber!,
            isMobile: isMobile,
          ),
      ],
    );
  }

  Widget _buildOverlayPill({
    required dynamic icon, // Can be IconData or String (emoji)
    required String label,
    required bool isMobile,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 8 : 10,
        vertical: isMobile ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle both emoji (String) and icon (IconData)
          if (icon is String)
            Text(icon, style: TextStyle(fontSize: isMobile ? 12 : 14))
          else if (icon is IconData)
            Icon(icon, size: isMobile ? 12 : 14, color: Colors.grey.shade700),
          SizedBox(width: isMobile ? 4 : 6),
          Text(
            label,
            style: TextStyle(
              fontSize: isMobile ? 11 : 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCertificationDate(DateTime date) {
    return DateFormat('d MMM yyyy', 'it_IT').format(date);
  }

  String _formatLocationForOverlayPill(dynamic location) {
    if (location is LocationModel) {
      // Use name if available (e.g. "Università di Bologna")
      if (location.name?.isNotEmpty == true) {
        return location.name!;
      }

      // Otherwise build from locality and country
      if (location.locality?.isNotEmpty == true &&
          location.country?.isNotEmpty == true) {
        return '${location.locality}, ${location.country}';
      } else if (location.country?.isNotEmpty == true) {
        return location.country!;
      } else if (location.locality?.isNotEmpty == true) {
        return location.locality!;
      }
    } else if (location is Map<String, dynamic>) {
      // If it's a map, extract the values
      final city = location['city']?.toString();
      final country = location['country']?.toString();
      if (city?.isNotEmpty == true && country?.isNotEmpty == true) {
        return '$city, $country';
      } else if (country?.isNotEmpty == true) {
        return country!;
      } else if (city?.isNotEmpty == true) {
        return city!;
      }
    } else if (location is String) {
      // If it's a string, return it directly
      return location;
    }

    return 'Luogo non specificato';
  }

  /// Convert ISO country code to flag emoji
  String _getCountryFlagEmoji(String? isoCountryCode) {
    if (isoCountryCode == null || isoCountryCode.length != 2) {
      return ''; // Return empty string if no valid ISO code
    }

    // Convert ISO country code to flag emoji
    // Each flag emoji is made of two regional indicator symbols
    final String countryCode = isoCountryCode.toUpperCase();
    final int firstLetter = countryCode.codeUnitAt(0) - 0x41 + 0x1F1E6;
    final int secondLetter = countryCode.codeUnitAt(1) - 0x41 + 0x1F1E6;

    return String.fromCharCode(firstLetter) + String.fromCharCode(secondLetter);
  }

  /// Get location icon or emoji based on ISO country code
  dynamic _getLocationIconOrEmoji(dynamic location) {
    if (location is LocationModel &&
        location.isoCountryCode?.isNotEmpty == true) {
      final flagEmoji = _getCountryFlagEmoji(location.isoCountryCode);
      if (flagEmoji.isNotEmpty) {
        return flagEmoji; // Return emoji string
      }
    }
    return Icons.location_on; // Return icon as fallback
  }

  /// Extract title information from certification_information_value where name = "titolo"
  String? _getTitleInformation() {
    final certification = widget.certification.certification;
    if (certification?.categoryInformation == null) return null;

    // Search for certification information with name = "titolo"
    for (final categoryInfo in certification!.categoryInformation) {
      final infoName = categoryInfo.info?.name;
      if (infoName != null &&
          infoName.toLowerCase() == 'titolo' &&
          categoryInfo.values.isNotEmpty) {
        // Return the first value found
        final value = categoryInfo.values.first.value;
        return value.isNotEmpty == true ? value : null;
      }
    }

    return null;
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildLegalEntityLogo(
            legalEntityId,
          ), // Logo loads asynchronously with cache
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              organizationName,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                  ),
              softWrap: true,
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
        width:
            34, // Increased by additional 30% (26 * 1.3 = 33.8, rounded to 34)
        height:
            34, // Increased by additional 30% (26 * 1.3 = 33.8, rounded to 34)
        decoration: BoxDecoration(
          shape: BoxShape.circle, // Changed to circular shape
          border: Border.all(color: Colors.grey.shade300, width: 0.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: Image.network(
          logoUrl!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.corporate_fare,
              size:
                  30, // Increased by additional 30% (23 * 1.3 = 29.9, rounded to 30)
              color: Colors.grey.shade600,
            );
          },
        ),
      );
    }

    // Show default icon if no logo available
    return Container(
      width: 34, // Same size as logo container
      height: 34, // Same size as logo container
      decoration: BoxDecoration(
        shape: BoxShape.circle, // Changed to circular shape
        color: Colors.grey.shade100,
        border: Border.all(color: Colors.grey.shade300, width: 0.5),
      ),
      child: Icon(
        Icons.corporate_fare,
        size:
            30, // Increased by additional 30% (23 * 1.3 = 29.9, rounded to 30)
        color: Colors.grey.shade600,
      ),
    );
  }

  bool _hasCertifierName(CertifierInfo certifier) {
    if (certifier.user == null) return false;

    final user = certifier.user!;
    final firstName = user.firstName?.trim();
    final lastName = user.lastName?.trim();

    return (firstName?.isNotEmpty == true) || (lastName?.isNotEmpty == true);
  }

  String _getCertifierFullName(CertifierInfo certifier) {
    // Use firstName and lastName from user data only
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
    }

    return ''; // Never show fallback text
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
    BuildContext context,
    String originalType,
  ) {
    final localizations = AppLocalizations.of(context)!;
    final normalizedType = originalType.toLowerCase().trim().replaceAll(
          RegExp(r'\s+'),
          '_',
        );
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
    // Fixed button styling for all devices
    final buttonHeight = 48.0;
    final iconSize = 20.0;
    final fontSize = 16.0;
    final borderRadius = BorderRadius.circular(10.0);

    // Only show OpenBadge button now
    if (_isOpenBadgeEnabled && widget.showOpenBadgeButton) {
      return SizedBox(
        width: double.infinity,
        height: buttonHeight,
        child: _buildOpenBadgeButton(
          context,
          cert,
          iconSize,
          fontSize,
          borderRadius,
        ),
      );
    }

    return const SizedBox.shrink();
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
          maxWidth: 180,
        ), // Reduced max width for LinkedIn buttons
        child: ElevatedButton.icon(
          onPressed: () => _createOpenBadge(context, cert),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4CAF50),
            foregroundColor: Colors.white,
            elevation: 2,
            shadowColor: const Color(0xFF4CAF50).withValues(alpha: 0.3),
            shape: RoundedRectangleBorder(borderRadius: borderRadius),
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ), // Reduced padding for 28px height
            minimumSize: const Size(0, 28), // Force minimum height
          ),
          icon: Icon(
            Icons.workspace_premium,
            size: 14,
          ), // Reduced icon size for 28px button
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

  /// Build the certified badge with white background as pill
  Widget _buildCertifiedBadge() {
    return Container(
      width: 125, // Increased by 30% from 96 to 125
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(12), // Reduced rounding from 16 to 12
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            spreadRadius: 0,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 12.0,
            vertical: 4.0), // More horizontal, less vertical padding
        child: Image.asset(
          'assets/images/badge_certified/certified_expanded_yes.png',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            // Fallback to check icon if image fails to load
            return Icon(Icons.verified, color: Colors.blue, size: 32);
          },
        ),
      ),
    );
  }
}
