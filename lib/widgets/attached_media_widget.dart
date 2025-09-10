import 'package:flutter/material.dart';
import 'package:jetcv__utenti/l10n/app_localizations.dart';
import 'package:jetcv__utenti/services/certification_service.dart';
import 'package:jetcv__utenti/services/media_download_service.dart';
import 'package:http/http.dart' as http;

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

  /// Verifica se il file esiste effettivamente sul backend
  Future<bool> _checkFileExists(CertificationMediaItem media) async {
    try {
      // Costruisci l'URL del file come fa il MediaDownloadService
      final filePath = '${media.idMediaHash}';
      final extension = _getFileExtension(media.fileType, media);
      final fullFilePath = '$filePath$extension';

      debugPrint('🔍 Media fileType: "${media.fileType}"');
      debugPrint('🔍 Media name: "${media.name}"');
      debugPrint('🔍 Determined extension: "$extension"');
      debugPrint('🔍 Full file path: "$fullFilePath"');

      // URL pubblico di Supabase Storage
      final fileUrl =
          'https://skqsuxmdfqxbkhmselaz.supabase.co/storage/v1/object/public/certification-media/$fullFilePath';

      debugPrint('🔍 Checking file existence: $fileUrl');

      // Fai una richiesta HEAD per verificare se il file esiste
      final response = await http.head(Uri.parse(fileUrl));

      final exists = response.statusCode == 200;
      debugPrint('🔍 File exists: $exists (status: ${response.statusCode})');
      debugPrint('🔍 Response headers: ${response.headers}');
      debugPrint('🔍 Response body: ${response.body}');

      // Se il file con estensione non esiste, prova senza estensione
      if (!exists && extension.isNotEmpty) {
        final fallbackUrl =
            'https://skqsuxmdfqxbkhmselaz.supabase.co/storage/v1/object/public/certification-media/$filePath';
        debugPrint('🔍 Trying fallback URL: $fallbackUrl');

        final fallbackResponse = await http.head(Uri.parse(fallbackUrl));
        final fallbackExists = fallbackResponse.statusCode == 200;
        debugPrint(
            '🔍 Fallback file exists: $fallbackExists (status: ${fallbackResponse.statusCode})');
        debugPrint('🔍 Fallback response headers: ${fallbackResponse.headers}');
        debugPrint('🔍 Fallback response body: ${fallbackResponse.body}');

        return fallbackExists;
      }

      return exists;
    } catch (e) {
      debugPrint('❌ Error checking file existence: $e');
      // In caso di errore, assumiamo che il file non esista
      return false;
    }
  }

  /// Determina l'estensione del file basata sul tipo (usa la stessa logica di MediaDownloadService)
  String _getFileExtension(String? fileType, CertificationMediaItem media) {
    debugPrint('🔍 _getFileExtension called with fileType: "$fileType"');
    debugPrint('🔍 _getFileExtension called with media.name: "${media.name}"');

    if (fileType == null) {
      debugPrint('🔍 fileType is null, returning .bin');
      return '.bin';
    }

    final lowerFileType = fileType.toLowerCase().trim();
    debugPrint('🔍 lowerFileType: "$lowerFileType"');

    switch (lowerFileType) {
      case 'image/jpeg':
      case 'jpeg':
      case 'image': // Aggiunto caso generico per 'image' dal database
        return '.jpg';
      case 'image/png':
      case 'png':
        return '.png';
      case 'image/gif':
      case 'gif':
        return '.gif';
      case 'image/webp':
      case 'webp':
        return '.webp';
      case 'application/pdf':
      case 'pdf':
      case 'pdf ':
      case ' pdf':
      case 'pdf.':
      case '.pdf':
      case 'document': // Aggiunto caso per 'document' dal database
        debugPrint('🔍 Matched PDF case, returning .pdf');
        return '.pdf';
      case 'text/plain':
      case 'txt':
        return '.txt';
      case 'application/msword':
      case 'doc':
        return '.doc';
      case 'application/vnd.openxmlformats-officedocument.wordprocessingml.document':
      case 'docx':
        return '.docx';
      case 'application/vnd.ms-excel':
      case 'xls':
        return '.xls';
      case 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet':
      case 'xlsx':
        return '.xlsx';
      case 'application/vnd.ms-powerpoint':
      case 'ppt':
        return '.ppt';
      case 'application/vnd.openxmlformats-officedocument.presentationml.presentation':
      case 'pptx':
        return '.pptx';
      case 'video/mp4':
      case 'mp4':
      case 'video': // Aggiunto caso generico per 'video' dal database
        return '.mp4';
      case 'video/avi':
      case 'avi':
        return '.avi';
      case 'video/mov':
      case 'mov':
        return '.mov';
      case 'audio/mp3':
      case 'mp3':
        return '.mp3';
      case 'audio/wav':
      case 'wav':
        return '.wav';
      default:
        debugPrint('🔍 No match found, trying to extract from name');
        // Prova a estrarre l'estensione dal nome del file se disponibile
        final extracted = _extractExtensionFromName(media.name);
        debugPrint('🔍 Extracted from name: "$extracted"');
        return extracted ?? '.bin';
    }
  }

  /// Estrae l'estensione dal nome del file come fallback
  String? _extractExtensionFromName(String? fileName) {
    if (fileName == null || fileName.isEmpty) return null;

    final lastDotIndex = fileName.lastIndexOf('.');
    if (lastDotIndex != -1 && lastDotIndex < fileName.length - 1) {
      return fileName.substring(lastDotIndex);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;

    // Fixed padding and sizing for all devices
    final headerPadding = const EdgeInsets.all(20);
    final iconSize = 20.0;
    final folderIconSize = 36.0;
    final titleFontSize = 18.0;
    final subtitleFontSize = 14.0;

    return Column(
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
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey.shade200,
                width: 1,
              ),
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
                    Icons.folder_outlined,
                    size: iconSize,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(width: 12),
                // Title and subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                      const SizedBox(height: 2),
                      Text(
                        AppLocalizations.of(context)!
                            .documentationAndRelatedContent,
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
          const SizedBox(height: 16),

          // Info box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.blue.shade200,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 18,
                  color: Colors.blue.shade600,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.mediaDividedInfo,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Media sections - responsive layout
          if (isDesktop &&
              (widget.certification.media.directMedia.isNotEmpty ||
                  widget.certification.media.linkedMedia.isNotEmpty)) ...[
            // Desktop: side by side layout
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Generic Media Section
                if (widget.certification.media.directMedia.isNotEmpty) ...[
                  Expanded(
                    child: _buildMediaSection(
                      title: AppLocalizations.of(context)!.genericMedia,
                      subtitle: AppLocalizations.of(context)!
                          .didacticMaterialAndOfficialDocumentation,
                      icon: Icons.description_outlined,
                      mediaItems: widget.certification.media.directMedia,
                      isDesktop: true,
                    ),
                  ),
                  if (widget.certification.media.linkedMedia.isNotEmpty)
                    const SizedBox(width: 16),
                ],

                // Personal Media Section
                if (widget.certification.media.linkedMedia.isNotEmpty) ...[
                  Expanded(
                    child: _buildMediaSection(
                      title: AppLocalizations.of(context)!.personalMedia,
                      subtitle: AppLocalizations.of(context)!
                          .documentsAndContentOfYourCertificationPath,
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
                subtitle: AppLocalizations.of(context)!
                    .didacticMaterialAndOfficialDocumentation,
                icon: Icons.description_outlined,
                mediaItems: widget.certification.media.directMedia,
                isDesktop: false,
              ),
              const SizedBox(height: 16),
            ],

            // Personal Media Section
            if (widget.certification.media.linkedMedia.isNotEmpty) ...[
              _buildMediaSection(
                title: AppLocalizations.of(context)!.personalMedia,
                subtitle: AppLocalizations.of(context)!
                    .documentsAndContentOfYourCertificationPath,
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
        ],
      ],
    );
  }

  Widget _buildMediaSection({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<CertificationMediaItem> mediaItems,
    required bool isDesktop,
  }) {
    final iconSize = 18.0;
    final titleFontSize = 16.0;
    final subtitleFontSize = 13.0;
    final spacing = 12.0;

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
    debugPrint(
        '🔍 Media acquisition_type lowercase: "${media.acquisitionType?.toLowerCase()}"');

    // Usa FutureBuilder per verificare l'esistenza del file in modo asincrono
    return FutureBuilder<bool>(
      future: _checkFileExists(media),
      builder: (context, snapshot) {
        final isFilePresent = snapshot.data ?? false;
        final isRealTime =
            !isFilePresent; // Se il file NON esiste sul backend, è realtime

        debugPrint('🔍 File present on backend: $isFilePresent');
        debugPrint('🔍 Is realtime: $isRealTime');

        return _buildMediaItemContent(
            media, isRealTime, isMobile, isTablet, screenWidth);
      },
    );
  }

  Widget _buildMediaItemContent(CertificationMediaItem media, bool isRealTime,
      bool isMobile, bool isTablet, double screenWidth) {
    final statusText = isRealTime
        ? AppLocalizations.of(context)!.realTime
        : AppLocalizations.of(context)!.uploaded;
    final statusColor = isRealTime ? Colors.green : Colors.yellow;
    final statusTextColor = isRealTime ? Colors.white : Colors.black;

    debugPrint('🔍 Status text: "$statusText"');
    debugPrint('🔍 Status color: $statusColor');

    final icon = _getMediaIcon(media.fileType);
    final actionIcon = isRealTime ? Icons.visibility : Icons.download;

    // Fixed sizing for all devices
    final itemPadding = const EdgeInsets.all(12);
    final iconSize = 32.0;
    final mediaIconSize = 16.0;
    final titleFontSize = 13.0;
    final descriptionFontSize = 14.0;
    final timeFontSize = 13.0;
    final statusFontSize = 9.0;
    final actionIconSize = 16.0;
    final actionPadding = 8.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: itemPadding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            spreadRadius: 0,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
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
                  children: [
                    Expanded(
                      child: Text(
                        media.name ?? 'Media',
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          fontSize: statusFontSize,
                          fontWeight: FontWeight.bold,
                          color: statusTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
                if (media.description != null) ...[
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

          const SizedBox(width: 8),

          // Action button
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
    );
  }

  /// Gestisce l'azione del media (download o visualizzazione)
  void _handleMediaAction(CertificationMediaItem media) {
    final isRealTime = media.acquisitionType?.toLowerCase() == 'real-time';

    if (isRealTime) {
      // Per i media real-time, mostra un messaggio
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(AppLocalizations.of(context)!.realTimeMediaNotDownloadable),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      // Per i media caricati, avvia il download
      if (MediaDownloadService.canDownload(media)) {
        MediaDownloadService.downloadMedia(
          media: media,
          context: context,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.mediaNotAvailable),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  IconData _getMediaIcon(String? fileType) {
    if (fileType == null) return Icons.insert_drive_file;

    switch (fileType.toLowerCase()) {
      case 'video':
      case 'mp4':
      case 'avi':
        return Icons.play_circle_outline;
      case 'image':
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      default:
        return Icons.insert_drive_file;
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
