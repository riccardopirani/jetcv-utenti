import 'package:flutter/material.dart';
import 'package:jetcv__utenti/l10n/app_localizations.dart';
import 'package:jetcv__utenti/services/certification_service.dart';
import 'package:jetcv__utenti/services/edge_function_service.dart';
import 'package:url_launcher/url_launcher.dart';

class AttachedMediaWidget extends StatefulWidget {
  final UserCertificationDetail certification;
  final int totalMediaCount;

  const AttachedMediaWidget({
    super.key,
    required this.certification,
    required this.totalMediaCount,
  });

  @override
  State<AttachedMediaWidget> createState() => _AttachedMediaWidgetState();
}

class _AttachedMediaWidgetState extends State<AttachedMediaWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;

    // Enhanced sizing for better visibility
    final headerPadding = const EdgeInsets.all(14);
    final iconSize = 20.0; // Increased from 16.0 for better visibility
    final folderIconSize = 28.0;
    final titleFontSize = 14.0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header - clickable to expand/collapse
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Container(
              padding: headerPadding,
              decoration: BoxDecoration(
                borderRadius: _isExpanded
                    ? const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      )
                    : BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  // Folder icon
                  Container(
                    width: folderIconSize,
                    height: folderIconSize,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.perm_media,
                      size: iconSize,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Title with info icon
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          AppLocalizations.of(context)!
                              .attachedMediaCount(widget.totalMediaCount),
                          style: TextStyle(
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Tooltip(
                          message:
                              "Gli allegati sono suddivisi tra media di contesto e media certificativi",
                          decoration: BoxDecoration(
                            color: Colors.grey.shade800,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          textStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                          ),
                          preferBelow: false,
                          waitDuration: const Duration(milliseconds: 500),
                          showDuration: const Duration(seconds: 3),
                          child: Icon(
                            Icons.info_outline,
                            size: 16, // Increased from 12 for better visibility
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Expand/collapse icon
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.grey.shade600,
                    size: iconSize,
                  ),
                ],
              ),
            ),
          ),

          // Expanded content
          if (_isExpanded) ...[
            // Separator line
            Container(
              height: 1,
              color: Colors.grey.shade200,
            ),

            // Media content without separate container
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Media sections - responsive layout
                  if (isDesktop &&
                      (widget.certification.media.directMedia.isNotEmpty ||
                          widget
                              .certification.media.linkedMedia.isNotEmpty)) ...[
                    // Desktop: side by side layout
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Generic Media Section
                        if (widget
                            .certification.media.directMedia.isNotEmpty) ...[
                          Expanded(
                            child: _buildMediaSection(
                              title: AppLocalizations.of(context)!.genericMedia,
                              subtitle:
                                  "Materiale pubblico inerente la certificazione",
                              icon: Icons.description_outlined,
                              mediaItems:
                                  widget.certification.media.directMedia,
                              isDesktop: true,
                            ),
                          ),
                          if (widget.certification.media.linkedMedia.isNotEmpty)
                            const SizedBox(width: 16),
                        ],

                        // Personal Media Section
                        if (widget
                            .certification.media.linkedMedia.isNotEmpty) ...[
                          Expanded(
                            child: _buildMediaSection(
                              title:
                                  AppLocalizations.of(context)!.personalMedia,
                              subtitle:
                                  "Documenti specifici della tua certificazione",
                              icon: Icons.person_outline,
                              mediaItems: widget.certification.media.linkedMedia
                                  .map((linked) => linked.media)
                                  .where((media) => media != null)
                                  .cast<CertificationMediaItem>()
                                  .toList(),
                              isDesktop: true,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ] else ...[
                    // Mobile/Tablet: stacked layout
                    // Generic Media Section
                    if (widget.certification.media.directMedia.isNotEmpty) ...[
                      _buildMediaSection(
                        title: AppLocalizations.of(context)!.genericMedia,
                        subtitle:
                            "Materiale pubblico inerente la certificazione",
                        icon: Icons.description_outlined,
                        mediaItems: widget.certification.media.directMedia,
                        isDesktop: false,
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Personal Media Section
                    if (widget.certification.media.linkedMedia.isNotEmpty) ...[
                      _buildMediaSection(
                        title: AppLocalizations.of(context)!.personalMedia,
                        subtitle:
                            "Documenti specifici della tua certificazione",
                        icon: Icons.person_outline,
                        mediaItems: widget.certification.media.linkedMedia
                            .map((linked) => linked.media)
                            .where((media) => media != null)
                            .cast<CertificationMediaItem>()
                            .toList(),
                        isDesktop: false,
                      ),
                    ],
                  ],
                ], // Close children of Column
              ), // Close media content container
            ),
          ], // Close expanded content
        ], // Close main Column children
      ), // Close main Container
    );
  }

  Widget _buildMediaSection({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<CertificationMediaItem> mediaItems,
    required bool isDesktop,
  }) {
    final iconSize =
        20.0; // Increased from 16.0 for consistency and better visibility
    final titleFontSize = 14.0;
    final subtitleFontSize = 11.0;
    final spacing = 10.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            Icon(
              icon,
              size: iconSize,
              color: Colors.grey.shade600,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: subtitleFontSize,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),

        SizedBox(height: spacing),

        // Media items - responsive grid for desktop
        if (isDesktop && mediaItems.length > 2) ...[
          // Desktop: 2-column grid for many items
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: mediaItems
                .map(
                  (media) => SizedBox(
                    width: (MediaQuery.of(context).size.width - 200) /
                        2, // Responsive width
                    child: _buildMediaItem(media),
                  ),
                )
                .toList(),
          ),
        ] else ...[
          // Mobile/Tablet: single column
          ...mediaItems.map((media) => _buildMediaItem(media)).toList(),
        ],
      ],
    );
  }

  Widget _buildMediaItem(CertificationMediaItem media) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;

    // Debug per vedere il valore effettivo
    debugPrint('🔍 Media acquisition_type: "${media.acquisitionType}"');
    debugPrint('🔍 Media name: "${media.name}"');
    debugPrint('🔍 Media fileType: "${media.fileType}"');
    debugPrint('🔍 Media idMediaHash: "${media.idMediaHash}"');

    // Show all media from API without checking physical file existence
    // Use placeholder status since we don't check file existence
    const isRealTime = false; // Always show as placeholder/uploaded status

    debugPrint('🔍 Showing media from API without file existence check');

    return _buildMediaItemContent(
        media, isRealTime, isMobile, isTablet, screenWidth);
  }

  Widget _buildMediaItemContent(CertificationMediaItem media, bool isRealTime,
      bool isMobile, bool isTablet, double screenWidth) {
    // Determine status based on acquisition_type with icons
    final String statusText;
    final Color statusColor;
    final IconData statusIcon;
    final Color statusTextColor = Colors.white;

    if (media.acquisitionType?.toLowerCase() == 'realtime') {
      statusText = 'Real-time';
      statusColor = Colors.red;
      statusIcon = Icons.sensors;
    } else if (media.acquisitionType?.toLowerCase() == 'deferred') {
      statusText = 'Caricato';
      statusColor = Colors.grey.shade700;
      statusIcon = Icons.cloud_upload;
    } else {
      // Fallback for unknown acquisition types
      statusText = media.acquisitionType ?? 'Sconosciuto';
      statusColor = Colors.grey.shade400;
      statusIcon = Icons.help_outline;
    }

    final icon = _getMediaIcon(media.fileType);
    const actionIcon = Icons.download;

    // Enhanced sizing for better readability
    final itemPadding = const EdgeInsets.all(10);
    final iconSize = 28.0;
    final mediaIconSize = isMobile ? 14.0 : 16.0;
    final titleFontSize = isMobile ? 12.0 : 13.0;
    final descriptionFontSize =
        isMobile ? 13.0 : 14.0; // Increased for better readability
    final timeFontSize =
        isMobile ? 12.0 : 13.0; // Increased for better readability
    final statusFontSize =
        isMobile ? 10.0 : 11.0; // Increased for better readability
    final actionIconSize = isMobile ? 14.0 : 16.0;
    final actionPadding = 6.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: itemPadding,
      decoration: BoxDecoration(
        color: Colors
            .grey.shade50, // Changed from white to light grey for contrast
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Media icon
          Container(
            width: iconSize,
            height: iconSize,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: mediaIconSize,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: media.title?.isNotEmpty == true
                          ? Text(
                              media.title!,
                              style: TextStyle(
                                fontSize: titleFontSize,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade800,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            )
                          : const SizedBox
                              .shrink(), // Don't show anything if title is null/empty
                    ),
                    // Pill and download button aligned together
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                statusIcon,
                                size: statusFontSize + 2,
                                color: statusTextColor,
                              ),
                              const SizedBox(
                                  width:
                                      6), // Increased spacing between icon and text
                              Text(
                                statusText,
                                style: TextStyle(
                                  fontSize: statusFontSize,
                                  fontWeight: FontWeight.bold,
                                  color: statusTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Download button
                        GestureDetector(
                          onTap: () => _handleMediaAction(media),
                          child: Container(
                            padding: EdgeInsets.all(actionPadding),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              actionIcon,
                              size: actionIconSize,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (media.description?.isNotEmpty == true) ...[
                  // Only add spacing if title was shown
                  if (media.title?.isNotEmpty == true)
                    const SizedBox(height: 4),
                  Text(
                    media.description!,
                    style: TextStyle(
                      fontSize: descriptionFontSize,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (media.capturedAt != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 10,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _formatMediaDate(media.capturedAt!),
                          style: TextStyle(
                            fontSize: timeFontSize,
                            color: Colors.grey.shade500,
                          ),
                          overflow: TextOverflow.ellipsis,
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

  /// Handles media download action
  Future<void> _handleMediaAction(CertificationMediaItem media) async {
    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              ),
              SizedBox(width: 12),
              Text('Preparazione download...'),
            ],
          ),
          backgroundColor: Colors.blue,
        ),
      );

      // Call the download edge function
      final response = await EdgeFunctionService.invokeFunction(
        'download-certification-media',
        {'id_certification_media': media.idCertificationMedia},
      );

      // Hide loading snackbar
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (response['ok'] == true && response['url'] != null) {
        // Launch the download URL
        final Uri downloadUrl = Uri.parse(response['url']);

        if (await canLaunchUrl(downloadUrl)) {
          await launchUrl(downloadUrl, mode: LaunchMode.externalApplication);

          // Show success message
          if (mounted) {
            final displayName = media.title?.isNotEmpty == true
                ? media.title!
                : (media.name?.isNotEmpty == true ? media.name! : 'Media');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Download di "$displayName" avviato'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        } else {
          throw Exception('Impossibile aprire il link di download');
        }
      } else {
        throw Exception(
            response['message'] ?? 'Errore sconosciuto durante il download');
      }
    } catch (e) {
      // Hide loading snackbar if still visible
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      debugPrint('❌ AttachedMediaWidget: Download error: $e');

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Errore durante il download: ${e.toString().replaceFirst('Exception: ', '')}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  IconData _getMediaIcon(String? fileType) {
    if (fileType == null) return Icons.insert_drive_file;

    switch (fileType.toLowerCase()) {
      // Primary enum values from API
      case 'image':
        return Icons.image_outlined;
      case 'video':
        return Icons.play_circle_outline;
      case 'document':
        return Icons.description_outlined;
      case 'audio':
        return Icons.audio_file_outlined;

      // Legacy/specific format support
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
        return Icons.image_outlined;
      case 'mp4':
      case 'avi':
      case 'mov':
      case 'mkv':
        return Icons.play_circle_outline;
      case 'pdf':
        return Icons.picture_as_pdf_outlined;
      case 'doc':
      case 'docx':
      case 'txt':
      case 'rtf':
        return Icons.description_outlined;
      case 'mp3':
      case 'wav':
      case 'aac':
      case 'flac':
        return Icons.audio_file_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  String _formatMediaDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month/$year $hour:$minute';
  }
}
