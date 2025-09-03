import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:jetcv__utenti/supabase/supabase_config.dart';
import 'package:jetcv__utenti/services/certification_service.dart';

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
              Text('Downloading media...'),
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
            content: Text('Media downloaded successfully: ${savedFile.path}'),
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
            content: Text('Error downloading media: $e'),
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

      // Ottieni l'URL pubblico del file
      final response = SupabaseConfig.client.storage
          .from(_storageBucket)
          .getPublicUrl(filePath);

      debugPrint('🔗 MediaDownloadService: Generated public URL: $response');
      return response;
    } catch (e) {
      debugPrint('❌ MediaDownloadService: Error getting media URL: $e');
      throw Exception('Failed to get media URL: $e');
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
      // Ottieni la directory dei download
      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        // Per web, usa la directory temporanea
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
      final extension = _getFileExtension(media.fileType);

      // Crea il nome del file
      final fileName =
          '${media.name ?? 'media'}_${media.idCertificationMedia}$extension';
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
  static String _getFileExtension(String? fileType) {
    if (fileType == null) return '.bin';

    switch (fileType.toLowerCase()) {
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
        return '.bin';
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
