import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:jetcv__utenti/supabase/supabase_config.dart';
import 'package:jetcv__utenti/services/certification_service.dart';

// Import condizionale per web
import 'dart:html' as html show Blob, Url, AnchorElement, document;

/// Servizio per il download dei media dalle certificazioni
class MediaDownloadService {
  static const String _storageBucket = 'certification-media';

  /// Scarica un media dalla certificazione
  static Future<void> downloadMedia({
    required CertificationMediaItem media,
    required BuildContext context,
  }) async {
    try {
      debugPrint(
          '📥 MediaDownloadService: Starting download for media: ${media.idCertificationMedia}');

      // Mostra dialog di caricamento
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text(AppLocalizations.of(context)!.downloadingMedia),
            ],
          ),
        ),
      );

      // Ottieni l'URL del file da Supabase Storage
      final fileUrl = await _getMediaUrl(media);
      debugPrint('🔗 MediaDownloadService: File URL: $fileUrl');

      // Scarica il file
      final fileData = await _downloadFile(fileUrl);
      debugPrint(
          '📦 MediaDownloadService: File downloaded, size: ${fileData.length} bytes');

      // Salva il file localmente
      final savedFile = await _saveFileLocally(media, fileData);
      debugPrint('💾 MediaDownloadService: File saved to: ${savedFile.path}');

      // Chiudi il dialog di caricamento
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Mostra messaggio di successo
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.mediaDownloadedSuccessfully}: ${savedFile.path}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ MediaDownloadService: Error downloading media: $e');

      // Chiudi il dialog di caricamento se è ancora aperto
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Mostra messaggio di errore
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.errorDownloadingMedia}: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Ottiene l'URL del file da Supabase Storage
  static Future<String> _getMediaUrl(CertificationMediaItem media) async {
    try {
      // Usa l'ID del media hash per costruire il path del file
      final filePath = '${media.idMediaHash}';

      // Aggiungi l'estensione del file se disponibile
      final extension = _getFileExtension(media.fileType, media);
      debugPrint(
          '🔍 MediaDownloadService: URL extension determined: "$extension"');
      final fullFilePath = '$filePath$extension';

      // Ottieni l'URL pubblico del file con estensione
      final response = SupabaseConfig.client.storage
          .from(_storageBucket)
          .getPublicUrl(fullFilePath);

      debugPrint('🔗 MediaDownloadService: Generated public URL: $response');
      debugPrint(
          '🔗 MediaDownloadService: File path with extension: $fullFilePath');
      return response;
    } catch (e) {
      debugPrint(
          '❌ MediaDownloadService: Error getting media URL with extension: $e');

      // Fallback: prova senza estensione se il file con estensione non esiste
      try {
        final filePath = '${media.idMediaHash}';
        final response = SupabaseConfig.client.storage
            .from(_storageBucket)
            .getPublicUrl(filePath);

        debugPrint(
            '🔗 MediaDownloadService: Fallback URL without extension: $response');
        return response;
      } catch (fallbackError) {
        debugPrint(
            '❌ MediaDownloadService: Error getting media URL (fallback): $fallbackError');
        throw Exception('Failed to get media URL: $e');
      }
    }
  }

  /// Scarica il file dall'URL
  static Future<Uint8List> _downloadFile(String url) async {
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('Failed to download file: HTTP ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ MediaDownloadService: Error downloading file: $e');
      throw Exception('Failed to download file: $e');
    }
  }

  /// Salva il file localmente
  static Future<File> _saveFileLocally(
      CertificationMediaItem media, Uint8List data) async {
    try {
      // Gestione specifica per web
      if (kIsWeb) {
        return await _saveFileForWeb(media, data);
      }

      // Ottieni la directory dei download per mobile/desktop
      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        // Per desktop, usa la directory temporanea
        directory = await getTemporaryDirectory();
      }

      if (directory == null) {
        throw Exception('Could not get storage directory');
      }

      // Crea la directory dei download se non esiste
      final downloadDir = Directory('${directory.path}/JetCV_Downloads');
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }

      // Determina l'estensione del file
      String extension = _getFileExtension(media.fileType, media);
      debugPrint(
          '🔍 MediaDownloadService: File extension determined: "$extension"');

      // Se l'estensione è .bin, prova a determinarla dal contenuto
      if (extension == '.bin') {
        final detectedExtension = _detectFileTypeFromContent(data);
        if (detectedExtension != null) {
          extension = detectedExtension;
          debugPrint(
              '🔍 MediaDownloadService: Updated extension from content: "$extension"');
        }
      }

      // Crea il nome del file
      final fileName =
          '${media.name ?? 'media'}_${media.idCertificationMedia}$extension';
      debugPrint('🔍 MediaDownloadService: Final file name: "$fileName"');
      final filePath = '${downloadDir.path}/$fileName';

      // Salva il file
      final file = File(filePath);
      await file.writeAsBytes(data);

      return file;
    } catch (e) {
      debugPrint('❌ MediaDownloadService: Error saving file: $e');
      throw Exception('Failed to save file: $e');
    }
  }

  /// Determina l'estensione del file basata sul tipo
  static String _getFileExtension(
      String? fileType, CertificationMediaItem? media) {
    debugPrint('🔍 MediaDownloadService: File type received: "$fileType"');
    debugPrint(
        '🔍 MediaDownloadService: File type length: ${fileType?.length ?? 0}');
    debugPrint(
        '🔍 MediaDownloadService: File type bytes: ${fileType?.codeUnits ?? []}');

    if (fileType == null) {
      debugPrint('🔍 MediaDownloadService: File type is null, returning .bin');
      return '.bin';
    }

    final lowerFileType = fileType.toLowerCase().trim();
    debugPrint(
        '🔍 MediaDownloadService: File type (lowercase, trimmed): "$lowerFileType"');
    debugPrint(
        '🔍 MediaDownloadService: File type (lowercase, trimmed) length: ${lowerFileType.length}');

    switch (lowerFileType) {
      case 'image/jpeg':
      case 'jpeg':
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
        debugPrint(
            '🔍 MediaDownloadService: PDF file type detected, returning .pdf');
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
        debugPrint(
            '🔍 MediaDownloadService: Unknown file type "$lowerFileType", trying to extract from name');
        // Prova a estrarre l'estensione dal nome del file se disponibile
        return _extractExtensionFromName(media?.name) ?? '.bin';
    }
  }

  /// Estrae l'estensione dal nome del file come fallback
  static String? _extractExtensionFromName(String? fileName) {
    if (fileName == null || fileName.isEmpty) return null;

    // Prima prova a estrarre l'estensione classica (con punto)
    final lastDotIndex = fileName.lastIndexOf('.');
    if (lastDotIndex != -1 && lastDotIndex < fileName.length - 1) {
      final extension = fileName.substring(lastDotIndex).toLowerCase();
      debugPrint(
          '🔍 MediaDownloadService: Extracted extension from name: "$extension"');

      // Verifica che sia un'estensione valida
      if (extension.length > 1 && extension.length <= 5) {
        return extension;
      }
    }

    // Se non trova un'estensione classica, cerca pattern comuni nel nome
    final lowerFileName = fileName.toLowerCase();

    // Cerca PDF tra parentesi o nel nome
    if (lowerFileName.contains('(pdf)') || lowerFileName.contains('pdf')) {
      debugPrint('🔍 MediaDownloadService: Found PDF in name, returning .pdf');
      return '.pdf';
    }

    // Cerca altri formati comuni
    if (lowerFileName.contains('(jpg)') || lowerFileName.contains('(jpeg)')) {
      debugPrint('🔍 MediaDownloadService: Found JPEG in name, returning .jpg');
      return '.jpg';
    }

    if (lowerFileName.contains('(png)')) {
      debugPrint('🔍 MediaDownloadService: Found PNG in name, returning .png');
      return '.png';
    }

    if (lowerFileName.contains('(doc)')) {
      debugPrint('🔍 MediaDownloadService: Found DOC in name, returning .doc');
      return '.doc';
    }

    if (lowerFileName.contains('(docx)')) {
      debugPrint(
          '🔍 MediaDownloadService: Found DOCX in name, returning .docx');
      return '.docx';
    }

    debugPrint(
        '🔍 MediaDownloadService: Could not extract valid extension from name: "$fileName"');
    return null;
  }

  /// Determina il tipo di file dal contenuto (magic bytes)
  static String? _detectFileTypeFromContent(Uint8List data) {
    if (data.length < 4) return null;

    // PDF: %PDF
    if (data.length >= 4 &&
        data[0] == 0x25 &&
        data[1] == 0x50 &&
        data[2] == 0x44 &&
        data[3] == 0x46) {
      debugPrint('🔍 MediaDownloadService: Detected PDF from content');
      return '.pdf';
    }

    // JPEG: FF D8 FF
    if (data.length >= 3 &&
        data[0] == 0xFF &&
        data[1] == 0xD8 &&
        data[2] == 0xFF) {
      debugPrint('🔍 MediaDownloadService: Detected JPEG from content');
      return '.jpg';
    }

    // PNG: 89 50 4E 47
    if (data.length >= 4 &&
        data[0] == 0x89 &&
        data[1] == 0x50 &&
        data[2] == 0x4E &&
        data[3] == 0x47) {
      debugPrint('🔍 MediaDownloadService: Detected PNG from content');
      return '.png';
    }

    debugPrint(
        '🔍 MediaDownloadService: Could not detect file type from content');
    return null;
  }

  /// Salva il file per la piattaforma web
  static Future<File> _saveFileForWeb(
      CertificationMediaItem media, Uint8List data) async {
    try {
      // Determina l'estensione del file
      String extension = _getFileExtension(media.fileType, media);
      debugPrint(
          '🔍 MediaDownloadService: Web file extension determined: "$extension"');

      // Se l'estensione è .bin, prova a determinarla dal contenuto
      if (extension == '.bin') {
        final detectedExtension = _detectFileTypeFromContent(data);
        if (detectedExtension != null) {
          extension = detectedExtension;
          debugPrint(
              '🔍 MediaDownloadService: Web updated extension from content: "$extension"');
        }
      }

      // Crea il nome del file
      final fileName =
          '${media.name ?? 'media'}_${media.idCertificationMedia}$extension';
      debugPrint('🔍 MediaDownloadService: Web final file name: "$fileName"');

      // Per web, avvia il download del browser
      await _triggerWebDownload(fileName, data);
      debugPrint(
          '💾 MediaDownloadService: Web download triggered for: $fileName');

      // Restituisci un file fittizio per compatibilità
      return File('/web/downloads/$fileName');
    } catch (e) {
      debugPrint('❌ MediaDownloadService: Error saving web file: $e');
      throw Exception('Failed to save web file: $e');
    }
  }

  /// Avvia il download del file nel browser web
  static Future<void> _triggerWebDownload(
      String fileName, Uint8List data) async {
    try {
      // Verifica che siamo su web
      if (!kIsWeb) {
        throw Exception('Web download can only be used on web platform');
      }

      // Crea un blob URL per il download
      final blob = html.Blob([data]);
      final url = html.Url.createObjectUrlFromBlob(blob);

      // Crea un elemento anchor temporaneo per il download
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', fileName)
        ..style.display = 'none';

      // Aggiungi al DOM, clicca e rimuovi
      html.document.body?.children.add(anchor);
      anchor.click();
      anchor.remove();

      // Pulisci l'URL del blob
      html.Url.revokeObjectUrl(url);

      debugPrint(
          '💾 MediaDownloadService: Web download completed for: $fileName');
    } catch (e) {
      debugPrint('❌ MediaDownloadService: Error triggering web download: $e');
      throw Exception('Failed to trigger web download: $e');
    }
  }

  /// Verifica se un media può essere scaricato
  static bool canDownload(CertificationMediaItem media) {
    // Per ora, tutti i media possono essere scaricati
    // In futuro si potrebbero aggiungere controlli di permessi
    return media.idMediaHash != null && media.idMediaHash!.isNotEmpty;
  }

  /// Ottiene la dimensione del file in formato leggibile
  static String getFileSizeString(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }
}
