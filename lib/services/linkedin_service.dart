import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:jetcv__utenti/services/certification_service.dart';

/// Servizio per l'integrazione con LinkedIn
class LinkedInService {
  static const String _linkedInBaseUrl = 'https://www.linkedin.com';

  /// Apre LinkedIn per aggiungere competenze al profilo
  static Future<void> addSkillsToLinkedInProfile({
    required List<UserCertificationDetail> certifications,
  }) async {
    try {
      debugPrint(
          '🔗 LinkedInService: Opening LinkedIn to add skills to profile');

      // Estrae le competenze dalle certificazioni
      final skills = _extractSkillsFromCertifications(certifications);

      if (skills.isEmpty) {
        throw Exception('No skills found in certifications');
      }

      // Costruisce l'URL per la pagina di modifica del profilo LinkedIn
      // LinkedIn non ha un URL diretto per aggiungere competenze, quindi apriamo la pagina del profilo
      final linkedInUrl = '$_linkedInBaseUrl/in/me/';

      debugPrint('🔗 LinkedInService: Opening LinkedIn profile: $linkedInUrl');
      debugPrint('🔗 LinkedInService: Skills to add: $skills');

      final uri = Uri.parse(linkedInUrl);

      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );

        // Mostra un messaggio informativo all'utente
        debugPrint(
            'ℹ️ LinkedInService: User should manually add skills to their profile');
      } else {
        debugPrint('❌ LinkedInService: Could not launch $linkedInUrl');
        throw Exception(
            'Could not launch LinkedIn. Please ensure the LinkedIn app is installed or try again later.');
      }
    } catch (e) {
      debugPrint('❌ LinkedInService: Error opening LinkedIn: $e');
      rethrow;
    }
  }

    /// Estrae le competenze dalle certificazioni
  static List<String> _extractSkillsFromCertifications(
      List<UserCertificationDetail> certifications) {
    final skills = <String>{};
    
    for (final cert in certifications) {
      // Aggiunge il nome della certificazione come competenza
      if (cert.certification?.category?.name != null) {
        skills.add(cert.certification!.category!.name!);
      }
      
      // Aggiunge il tipo di certificazione come competenza
      if (cert.certification?.category?.type != null) {
        skills.add(cert.certification!.category!.type!);
      }
    }
    
    return skills.toList();
  }

  /// Genera un messaggio con le competenze da aggiungere al profilo LinkedIn
  static String generateSkillsMessage(List<UserCertificationDetail> certifications) {
    final skills = _extractSkillsFromCertifications(certifications);
    
    if (skills.isEmpty) {
      return 'Add your certification skills to LinkedIn!';
    }
    
    final buffer = StringBuffer();
    buffer.writeln('🎯 Skills to add to your LinkedIn profile:');
    buffer.writeln();
    
    for (final skill in skills.take(10)) { // Limita a 10 competenze
      buffer.writeln('• $skill');
    }
    
    if (skills.length > 10) {
      buffer.writeln('• ... and ${skills.length - 10} more skills');
    }
    
    buffer.writeln();
    buffer.writeln('💡 Tip: Go to your LinkedIn profile → Add profile section → Skills');
    
    return buffer.toString();
  }

  /// Genera un messaggio per le certificazioni da condividere
  static String generateCertificationsMessage(
      List<UserCertificationDetail> certifications) {
    if (certifications.isEmpty) {
      return 'I have verified certifications on JetCV!';
    }

    final buffer = StringBuffer();
    buffer.writeln('🎓 Verified Certifications:');
    buffer.writeln();

    for (final cert in certifications.take(5)) {
      // Limita a 5 certificazioni
      final certName =
          cert.certification?.category?.name ?? 'Unknown Certification';
      final issuer = cert.certification?.idCertifier ?? 'Unknown Issuer';
      final date = cert.certificationUser.createdAt;

      buffer.writeln('✅ $certName');
      buffer.writeln('   Issued by: $issuer');
      buffer.writeln('   Date: ${date.day}/${date.month}/${date.year}');
      buffer.writeln();
    }

    if (certifications.length > 5) {
      buffer
          .writeln('... and ${certifications.length - 5} more certifications');
      buffer.writeln();
    }

    buffer.writeln('🔗 View all my verified certifications on JetCV!');

    return buffer.toString();
  }

  /// Apre LinkedIn con un messaggio precompilato per le certificazioni
  static Future<void> shareCertificationsOnLinkedIn({
    required List<UserCertificationDetail> certifications,
    String? userProfileUrl,
  }) async {
    try {
      debugPrint('🔗 LinkedInService: Sharing certifications on LinkedIn');

      final message = generateCertificationsMessage(certifications);
      final encodedMessage = Uri.encodeComponent(message);

      // Costruisce l'URL per condividere su LinkedIn
      String linkedInUrl =
          '$_linkedInBaseUrl/feed/?shareActive=true&text=$encodedMessage';

      debugPrint('🔗 LinkedInService: Sharing URL: $linkedInUrl');

      final uri = Uri.parse(linkedInUrl);

      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        debugPrint('✅ LinkedInService: LinkedIn share opened successfully');
      } else {
        debugPrint('❌ LinkedInService: Could not launch LinkedIn share URL');
        throw Exception('Could not open LinkedIn share');
      }
    } catch (e) {
      debugPrint('❌ LinkedInService: Error sharing on LinkedIn: $e');
      rethrow;
    }
  }

  /// Verifica se LinkedIn è installato sul dispositivo
  static Future<bool> isLinkedInInstalled() async {
    try {
      final uri = Uri.parse('linkedin://');
      return await canLaunchUrl(uri);
    } catch (e) {
      debugPrint('❌ LinkedInService: Error checking LinkedIn installation: $e');
      return false;
    }
  }

  /// Apre l'app LinkedIn se installata, altrimenti apre il browser
  static Future<void> openLinkedInAppOrWeb({String? profileUrl}) async {
    try {
      final isInstalled = await isLinkedInInstalled();

      if (isInstalled && profileUrl != null) {
        // Apri l'app LinkedIn con il profilo specifico
        final appUri = Uri.parse('linkedin://profile/$profileUrl');
        if (await canLaunchUrl(appUri)) {
          await launchUrl(appUri, mode: LaunchMode.externalApplication);
          return;
        }
      }

      // Fallback: apri nel browser
      final webUrl = profileUrl != null
          ? '$_linkedInBaseUrl/in/$profileUrl'
          : _linkedInBaseUrl;

      final uri = Uri.parse(webUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('❌ LinkedInService: Error opening LinkedIn app/web: $e');
      rethrow;
    }
  }
}
