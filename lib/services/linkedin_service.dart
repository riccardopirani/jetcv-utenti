import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jetcv__utenti/services/certification_service.dart';
import 'package:jetcv__utenti/config/linkedin_config.dart';

/// Servizio per l'integrazione con LinkedIn
class LinkedInService {
  static const String _linkedInBaseUrl = 'https://www.linkedin.com';

  /// Apre LinkedIn per aggiungere certificazioni al profilo tramite URL diretto
  static Future<void> addSkillsToLinkedInProfile({
    required List<UserCertificationDetail> certifications,
  }) async {
    try {
      debugPrint(
          '🔗 LinkedInService: Opening LinkedIn to add certifications to profile');

      if (certifications.isEmpty) {
        throw Exception('No certifications found');
      }

      // Prende la prima certificazione per l'URL (LinkedIn supporta una certificazione per volta)
      final firstCert = certifications.first;
      final certName =
          firstCert.certification?.category?.name ?? 'Certification';
      final issueDate = firstCert.certificationUser.createdAt;

      // Copia le informazioni della certificazione negli appunti
      await copyCertificationToClipboard(
        certName: certName,
        organizationName: 'JetCV',
        issueYear: issueDate.year,
        issueMonth: issueDate.month,
        certUrl:
            'https://amzhiche.com/certification/${firstCert.certificationUser.idCertificationUser}',
      );

      // Costruisce l'URL per aprire LinkedIn
      final linkedInUrl = _buildAddToProfileUrl(
        certName: certName,
        organizationName: 'JetCV',
        issueYear: issueDate.year,
        issueMonth: issueDate.month,
        certUrl:
            'https://amzhiche.com/certification/${firstCert.certificationUser.idCertificationUser}',
        certId: firstCert.certificationUser.idCertificationUser,
      );

      debugPrint('🔗 LinkedInService: LinkedIn URL: $linkedInUrl');

      final uri = Uri.parse(linkedInUrl);

      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );

        debugPrint(
            '✅ LinkedInService: LinkedIn opened and certification details copied to clipboard');
      } else {
        debugPrint('❌ LinkedInService: Could not launch LinkedIn URL');
        throw Exception(
            'Could not launch LinkedIn. Please ensure the LinkedIn app is installed or try again later.');
      }
    } catch (e) {
      debugPrint('❌ LinkedInService: Error opening LinkedIn: $e');
      rethrow;
    }
  }

  /// Copia le informazioni della certificazione negli appunti
  static Future<void> copyCertificationToClipboard({
    required String certName,
    required String organizationName,
    required int issueYear,
    required int issueMonth,
    required String certUrl,
  }) async {
    final certificationText = '''
Certification Details for LinkedIn:

Name: $certName
Organization: $organizationName
Issue Date: $issueMonth/$issueYear
Certificate URL: $certUrl

Copy these details and paste them when adding the certification to your LinkedIn profile.
''';

    await Clipboard.setData(ClipboardData(text: certificationText));
    debugPrint('📋 Certification details copied to clipboard');
  }

  /// Costruisce l'URL per aggiungere certificazione al profilo LinkedIn
  static String _buildAddToProfileUrl({
    required String certName,
    required String organizationName,
    required int issueYear,
    required int issueMonth,
    required String certUrl,
    required String certId,
  }) {
    // LinkedIn ha rimosso la funzionalità di precompilazione automatica
    // Ora apriamo direttamente la pagina del profilo
    return 'https://www.linkedin.com/in/me/';
  }

  /// Aggiunge una competenza al profilo LinkedIn tramite API
  static Future<bool> addSkillToProfile({
    required String accessToken,
    required String skillName,
    String language = 'en_US',
  }) async {
    try {
      debugPrint(
          '🔗 LinkedInService: Adding skill "$skillName" to LinkedIn profile');

      // Prima otteniamo l'ID del profilo dell'utente
      final profileId = await _getUserProfileId(accessToken);
      if (profileId == null) {
        throw Exception('Could not get user profile ID');
      }

      // Costruisce il corpo della richiesta per aggiungere la competenza
      final requestBody = {
        'name': {
          'localized': {
            language: skillName,
          },
          'preferredLocale': {
            'country': language.split('_')[1],
            'language': language.split('_')[0],
          },
        },
      };

      final response = await http.post(
        Uri.parse('${LinkedInConfig.apiBaseUrl}/people/$profileId/skills'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
          'X-Restli-Protocol-Version': '2.0.0',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 201) {
        debugPrint('✅ LinkedInService: Skill "$skillName" added successfully');
        return true;
      } else {
        debugPrint(
            '❌ LinkedInService: Failed to add skill. Status: ${response.statusCode}, Body: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ LinkedInService: Error adding skill: $e');
      return false;
    }
  }

  /// Gestisce il callback OAuth e aggiunge tutte le competenze
  static Future<bool> handleOAuthCallback({
    required String authorizationCode,
    required List<UserCertificationDetail> certifications,
  }) async {
    try {
      debugPrint('🔗 LinkedInService: Handling OAuth callback');

      // Scambia il codice di autorizzazione con un token di accesso
      final accessToken = await _exchangeCodeForToken(authorizationCode);
      if (accessToken == null) {
        throw Exception('Failed to get access token');
      }

      // Estrae le competenze dalle certificazioni
      final skills = _extractSkillsFromCertifications(certifications);

      // Aggiunge tutte le competenze al profilo
      int successCount = 0;
      for (final skill in skills) {
        final success = await addSkillToProfile(
          accessToken: accessToken,
          skillName: skill,
        );
        if (success) {
          successCount++;
        }
      }

      debugPrint(
          '✅ LinkedInService: Added $successCount out of ${skills.length} skills');
      return successCount > 0;
    } catch (e) {
      debugPrint('❌ LinkedInService: Error handling OAuth callback: $e');
      return false;
    }
  }

  /// Scambia il codice di autorizzazione con un token di accesso
  static Future<String?> _exchangeCodeForToken(String authorizationCode) async {
    try {
      final response = await http.post(
        Uri.parse('${LinkedInConfig.authBaseUrl}/accessToken'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'grant_type': 'authorization_code',
          'code': authorizationCode,
          'redirect_uri': LinkedInConfig.redirectUri,
          'client_id': LinkedInConfig.clientId,
          'client_secret': LinkedInConfig.clientSecret,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['access_token'];
      } else {
        debugPrint(
            '❌ LinkedInService: Failed to exchange code for token. Status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ LinkedInService: Error exchanging code for token: $e');
      return null;
    }
  }

  /// Ottiene l'ID del profilo dell'utente autenticato
  static Future<String?> _getUserProfileId(String accessToken) async {
    try {
      final response = await http.get(
        Uri.parse('${LinkedInConfig.apiBaseUrl}/people/~'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['id'];
      } else {
        debugPrint(
            '❌ LinkedInService: Failed to get profile ID. Status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ LinkedInService: Error getting profile ID: $e');
      return null;
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
  static String generateSkillsMessage(
      List<UserCertificationDetail> certifications) {
    final skills = _extractSkillsFromCertifications(certifications);

    if (skills.isEmpty) {
      return 'Add your certification skills to LinkedIn!';
    }

    final buffer = StringBuffer();
    buffer.writeln('🎯 Skills to add to your LinkedIn profile:');
    buffer.writeln();

    for (final skill in skills.take(10)) {
      // Limita a 10 competenze
      buffer.writeln('• $skill');
    }

    if (skills.length > 10) {
      buffer.writeln('• ... and ${skills.length - 10} more skills');
    }

    buffer.writeln();
    buffer.writeln(
        '💡 Tip: Go to your LinkedIn profile → Add profile section → Skills');

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
