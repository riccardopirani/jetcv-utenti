import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:jetcv__utenti/models/open_badge_model.dart';
import 'package:jetcv__utenti/services/certification_service.dart';

/// Servizio per la creazione e gestione degli Open Badge
class OpenBadgeService {
  static const String _baseUrl = 'https://amzhiche.com';

  /// Crea un Open Badge per una certificazione
  static Future<OpenBadgeModel> createBadgeForCertification({
    required UserCertificationDetail certification,
    required String recipientEmail,
    required String recipientName,
  }) async {
    try {
      debugPrint(
          '🏆 OpenBadgeService: Creating badge for certification: ${certification.certificationUser.idCertificationUser}');

      // Genera URL per il badge
      final badgeId = certification.certificationUser.idCertificationUser;
      final badgeImageUrl = '$_baseUrl/badges/$badgeId/badge.png';
      final criteriaUrl = '$_baseUrl/badges/$badgeId/criteria';
      final verificationUrl = '$_baseUrl/badges/$badgeId/verify';

      // Crea il badge
      final badge = OpenBadgeModel.fromCertification(
        certificationId: badgeId,
        certificationName:
            certification.certification?.category?.name ?? 'Certification',
        certificationDescription: _generateBadgeDescription(certification),
        issuerName: 'JetCV',
        issuerUrl: _baseUrl,
        recipientEmail: recipientEmail,
        recipientName: recipientName,
        badgeImageUrl: badgeImageUrl,
        criteriaUrl: criteriaUrl,
        verificationUrl: verificationUrl,
        expires: _calculateExpirationDate(certification),
        tags: _generateTags(certification),
        evidence: _generateEvidence(certification),
      );

      debugPrint('✅ OpenBadgeService: Badge created successfully');
      return badge;
    } catch (e) {
      debugPrint('❌ OpenBadgeService: Error creating badge: $e');
      throw Exception('Failed to create Open Badge: $e');
    }
  }

  /// Genera l'immagine del badge
  static Future<Uint8List> generateBadgeImage({
    required OpenBadgeModel badge,
    required BuildContext context,
  }) async {
    try {
      debugPrint('🎨 OpenBadgeService: Generating badge image');

      // Crea un'immagine del badge usando Flutter
      final imageData = await _createBadgeImage(badge, context);

      debugPrint('✅ OpenBadgeService: Badge image generated');
      return imageData;
    } catch (e) {
      debugPrint('❌ OpenBadgeService: Error generating badge image: $e');
      throw Exception('Failed to generate badge image: $e');
    }
  }

  /// Salva il badge come file JSON-LD
  static Future<File> saveBadgeAsJson({
    required OpenBadgeModel badge,
    required String fileName,
  }) async {
    try {
      debugPrint('💾 OpenBadgeService: Saving badge as JSON-LD');

      // Per web, restituiamo un file fittizio
      if (kIsWeb) {
        debugPrint('🌐 OpenBadgeService: Web platform detected, returning virtual file');
        return File('/tmp/$fileName.json');
      }

      // Ottieni la directory dei download per mobile/desktop
      Directory? directory;
      try {
        if (Platform.isAndroid) {
          directory = await getExternalStorageDirectory();
        } else if (Platform.isIOS) {
          directory = await getApplicationDocumentsDirectory();
        } else {
          directory = await getTemporaryDirectory();
        }
      } catch (e) {
        // Fallback per piattaforme non supportate
        directory = await getTemporaryDirectory();
      }

      if (directory == null) {
        throw Exception('Could not get storage directory');
      }

      // Crea la directory dei badge se non esiste
      final badgeDir = Directory('${directory.path}/JetCV_Badges');
      if (!await badgeDir.exists()) {
        await badgeDir.create(recursive: true);
      }

      // Salva il file JSON-LD
      final file = File('${badgeDir.path}/$fileName.json');
      await file.writeAsString(badge.toJsonLdString());

      debugPrint('✅ OpenBadgeService: Badge saved to: ${file.path}');
      return file;
    } catch (e) {
      debugPrint('❌ OpenBadgeService: Error saving badge: $e');
      throw Exception('Failed to save badge: $e');
    }
  }

  /// Condivide il badge
  static Future<void> shareBadge({
    required OpenBadgeModel badge,
    required BuildContext context,
  }) async {
    try {
      debugPrint('📤 OpenBadgeService: Sharing badge');

      // Genera l'immagine del badge
      final imageData =
          await generateBadgeImage(badge: badge, context: context);

      // Salva il badge come JSON-LD
      final fileName =
          '${badge.name.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}';
      final jsonFile = await saveBadgeAsJson(badge: badge, fileName: fileName);

      // Mostra dialog di condivisione
      if (context.mounted) {
        await _showShareDialog(
          context: context,
          badge: badge,
          imageData: imageData,
          jsonFile: jsonFile,
        );
      }

      debugPrint('✅ OpenBadgeService: Badge shared successfully');
    } catch (e) {
      debugPrint('❌ OpenBadgeService: Error sharing badge: $e');
      throw Exception('Failed to share badge: $e');
    }
  }

  /// Verifica un badge
  static Future<bool> verifyBadge(String badgeJsonLd) async {
    try {
      debugPrint('🔍 OpenBadgeService: Verifying badge');

      final badgeData = jsonDecode(badgeJsonLd) as Map<String, dynamic>;
      final verification = badgeData['verification'] as Map<String, dynamic>;
      final verificationUrl = verification['url'] as String;

      // Verifica il badge tramite URL
      final response = await http.get(Uri.parse(verificationUrl));

      if (response.statusCode == 200) {
        debugPrint('✅ OpenBadgeService: Badge verified successfully');
        return true;
      } else {
        debugPrint('❌ OpenBadgeService: Badge verification failed');
        return false;
      }
    } catch (e) {
      debugPrint('❌ OpenBadgeService: Error verifying badge: $e');
      return false;
    }
  }

  /// Genera la descrizione del badge
  static String _generateBadgeDescription(
      UserCertificationDetail certification) {
    final certName =
        certification.certification?.category?.name ?? 'Certification';
    final issuer = certification.certification?.idCertifier ?? 'JetCV';
    final date = certification.certificationUser.createdAt;

    return 'This badge certifies that the recipient has successfully completed the $certName certification issued by $issuer on ${date.day}/${date.month}/${date.year}.';
  }

  /// Calcola la data di scadenza
  static DateTime? _calculateExpirationDate(
      UserCertificationDetail certification) {
    // Per ora, i badge non scadono
    // In futuro si potrebbe implementare una logica di scadenza
    return null;
  }

  /// Genera i tag per il badge
  static List<String> _generateTags(UserCertificationDetail certification) {
    final tags = <String>[];

    // Aggiungi tag basati sul tipo di certificazione
    final certName =
        (certification.certification?.category?.name ?? '').toLowerCase();

    if (certName.contains('team')) tags.add('teamwork');
    if (certName.contains('leadership')) tags.add('leadership');
    if (certName.contains('communication')) tags.add('communication');
    if (certName.contains('technical')) tags.add('technical');
    if (certName.contains('management')) tags.add('management');

    // Tag generici
    tags.addAll(['certification', 'jetcv', 'verified']);

    return tags;
  }

  /// Genera le evidenze per il badge
  static Map<String, dynamic> _generateEvidence(
      UserCertificationDetail certification) {
    return {
      'id':
          '$_baseUrl/certification/${certification.certificationUser.idCertificationUser}',
      'type': 'Certification',
      'name': certification.certification?.category?.name ?? 'Certification',
      'description': 'Official certification record',
      'narrative':
          'This certification was issued after successful completion of the required criteria.',
    };
  }

  /// Crea l'immagine del badge
  static Future<Uint8List> _createBadgeImage(
      OpenBadgeModel badge, BuildContext context) async {
    // Per ora, creiamo un'immagine semplice
    // In futuro si potrebbe implementare un generatore di immagini più sofisticato

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = const Size(400, 400);

    // Sfondo del badge
    final backgroundPaint = Paint()
      ..color = const Color(0xFF2196F3)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(20),
      ),
      backgroundPaint,
    );

    // Testo del badge
    final textPainter = TextPainter(
      text: TextSpan(
        text: badge.name,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        size.height / 2 - 20,
      ),
    );

    // Converti in immagine
    final picture = recorder.endRecording();
    final image =
        await picture.toImage(size.width.toInt(), size.height.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    return byteData!.buffer.asUint8List();
  }

  /// Mostra il dialog di condivisione
  static Future<void> _showShareDialog({
    required BuildContext context,
    required OpenBadgeModel badge,
    required Uint8List imageData,
    required File jsonFile,
  }) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Share Open Badge'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Your Open Badge has been created successfully!'),
            const SizedBox(height: 16),
            Text('Badge: ${badge.name}'),
            Text('Issuer: ${badge.issuer.name}'),
            const SizedBox(height: 16),
            Text('Files saved to: ${jsonFile.path}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () => _downloadBadgeImage(context, badge, imageData),
            icon: const Icon(Icons.download, size: 16),
            label: const Text('Download PNG'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(kIsWeb 
                    ? 'Open Badge created! Copy the JSON-LD content to save your badge.'
                    : 'Badge files saved successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
