import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jetcv__utenti/services/certification_service.dart';
import 'package:jetcv__utenti/services/legal_entity_service.dart';
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

      // Ottiene le informazioni dell'azienda
      String organizationName = 'JetCV';
      String? companyWebsite;

      if (firstCert.certification?.idLegalEntity != null) {
        final legalEntity = await LegalEntityService.getLegalEntityById(
          firstCert.certification!.idLegalEntity!,
        );

        if (legalEntity != null) {
          organizationName = LegalEntityService.getCompanyName(legalEntity);
          companyWebsite = LegalEntityService.getCompanyWebsite(legalEntity);
        }
      }

      // Copia le informazioni della certificazione negli appunti
      await copyCertificationToClipboard(
        certName: certName,
        organizationName: organizationName,
        issueYear: issueDate.year,
        issueMonth: issueDate.month,
        certUrl:
            'https://amzhiche.com/certification/${firstCert.certificationUser.idCertificationUser}',
        companyWebsite: companyWebsite,
      );

      // Mostra istruzioni dettagliate per l'utente
      showLinkedInInstructions(
        certName: certName,
        organizationName: organizationName,
        issueYear: issueDate.year,
        issueMonth: issueDate.month,
        certUrl:
            'https://amzhiche.com/certification/${firstCert.certificationUser.idCertificationUser}',
        companyWebsite: companyWebsite,
      );

      // Costruisce l'URL per aprire LinkedIn
      final linkedInUrl = _buildAddToProfileUrl(
        certName: certName,
        organizationName: organizationName,
        issueYear: issueDate.year,
        issueMonth: issueDate.month,
        certUrl:
            'https://amzhiche.com/certification/${firstCert.certificationUser.idCertificationUser}',
        certId: firstCert.certificationUser.idCertificationUser,
        companyWebsite: companyWebsite,
      );

      debugPrint('🔗 LinkedInService: LinkedIn URL: $linkedInUrl');

      // Prova diversi URL di LinkedIn per trovare quello che funziona meglio
      final urlsToTry = [
        'https://www.linkedin.com/in/me/details/certifications/edit/forms/new/?profileFormEntryPoint=PROFILE_SECTION', // URL specifico per form certificazioni
        'https://www.linkedin.com/in/me/details/certifications/add/', // URL diretto
        'https://www.linkedin.com/in/me/', // Pagina principale del profilo
      ];

      bool opened = false;
      for (final url in urlsToTry) {
        final testUri = Uri.parse(url);
        if (await canLaunchUrl(testUri)) {
          await launchUrl(
            testUri,
            mode: LaunchMode.externalApplication,
          );
          debugPrint('✅ LinkedInService: LinkedIn opened with URL: $url');
          opened = true;
          break;
        } else {
          debugPrint('❌ LinkedInService: Could not launch URL: $url');
        }
      }

      if (!opened) {
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
    String? companyWebsite,
  }) async {
    // Crea un testo formattato per facilitare la copia nei campi LinkedIn
    final certificationText = '''
🎓 CERTIFICATION DETAILS FOR LINKEDIN:

📜 Name: $certName
🏢 Organization: $organizationName${companyWebsite != null ? '\n🌐 Organization Website: $companyWebsite' : ''}
📅 Issue Date: $issueMonth/$issueYear
🔗 Certificate URL: $certUrl

📋 STEP-BY-STEP INSTRUCTIONS:
1. LinkedIn should open automatically
2. If not, go to: https://www.linkedin.com/in/me/details/certifications/edit/forms/new/
3. Fill in the form with the details above:
   - Name: $certName
   - Organization: $organizationName
   - Issue Date: $issueMonth/$issueYear
   - Credential URL: $certUrl
4. Click "Save"

⚠️  NOTE: LinkedIn doesn't allow auto-filling for security reasons.
   The details above have been copied to your clipboard for easy pasting.

✅ All details have been copied to your clipboard!
''';

    await Clipboard.setData(ClipboardData(text: certificationText));
    debugPrint('📋 Certification details copied to clipboard');
  }

  /// Copia solo il nome della certificazione negli appunti (per copia rapida)
  static Future<void> copyCertificationName(String certName) async {
    await Clipboard.setData(ClipboardData(text: certName));
    debugPrint('📋 Certification name copied to clipboard: $certName');
  }

  /// Copia solo il nome dell'organizzazione negli appunti (per copia rapida)
  static Future<void> copyOrganizationName(String organizationName) async {
    await Clipboard.setData(ClipboardData(text: organizationName));
    debugPrint('📋 Organization name copied to clipboard: $organizationName');
  }

  /// Copia solo l'URL del certificato negli appunti (per copia rapida)
  static Future<void> copyCertificationUrl(String certUrl) async {
    await Clipboard.setData(ClipboardData(text: certUrl));
    debugPrint('📋 Certification URL copied to clipboard: $certUrl');
  }

  /// Mostra istruzioni dettagliate per l'utente
  static void showLinkedInInstructions({
    required String certName,
    required String organizationName,
    required int issueYear,
    required int issueMonth,
    required String certUrl,
    String? companyWebsite,
  }) {
    debugPrint('''
🎯 LINKEDIN INTEGRATION INSTRUCTIONS:

📋 STEP 1: LinkedIn Form
- LinkedIn should open automatically
- If not, go to: https://www.linkedin.com/in/me/details/certifications/edit/forms/new/

📋 STEP 2: Fill the Form
- Name: $certName
- Organization: $organizationName
- Issue Date: $issueMonth/$issueYear
- Credential URL: $certUrl
${companyWebsite != null ? '- Organization Website: $companyWebsite' : ''}

📋 STEP 3: Quick Copy Commands
- Use copyCertificationName('$certName') for name
- Use copyOrganizationName('$organizationName') for organization
- Use copyCertificationUrl('$certUrl') for URL

✅ All details are already in your clipboard!
''');
  }

  /// Crea un messaggio di notifica per l'utente
  static String createNotificationMessage({
    required String certName,
    required String organizationName,
    required int issueYear,
    required int issueMonth,
    required String certUrl,
    String? companyWebsite,
  }) {
    return '''
🎓 Aggiungi la tua certificazione a LinkedIn!

📋 Dettagli:
• Nome: $certName
• Organizzazione: $organizationName
• Data: $issueMonth/$issueYear
• URL: $certUrl
${companyWebsite != null ? '• Sito web: $companyWebsite' : ''}

📱 Istruzioni:
1. LinkedIn si aprirà automaticamente
2. Compila il form con i dettagli sopra
3. Clicca "Salva"

✅ Tutti i dettagli sono stati copiati negli appunti!
''';
  }

  /// Costruisce l'URL per aggiungere certificazione al profilo LinkedIn
  static String _buildAddToProfileUrl({
    required String certName,
    required String organizationName,
    required int issueYear,
    required int issueMonth,
    required String certUrl,
    required String certId,
    String? companyWebsite,
  }) {
    // Usa l'URL specifico per aggiungere certificazioni che funziona meglio
    // Questo URL apre direttamente il form per aggiungere una nuova certificazione
    final addCertificationUrl =
        'https://www.linkedin.com/in/me/details/certifications/edit/forms/new/?profileFormEntryPoint=PROFILE_SECTION';

    // Prova a precompilare alcuni campi usando i parametri URL
    // Nota: LinkedIn potrebbe ignorare alcuni di questi parametri per motivi di sicurezza
    final encodedCertName = Uri.encodeComponent(certName);
    final encodedOrgName = Uri.encodeComponent(organizationName);
    final encodedCertUrl = Uri.encodeComponent(certUrl);

    // URL con parametri di precompilazione
    final urlWithParams = '$addCertificationUrl&'
        'name=$encodedCertName&'
        'organization=$encodedOrgName&'
        'url=$encodedCertUrl&'
        'issueYear=$issueYear&'
        'issueMonth=$issueMonth';

    debugPrint(
        '🔗 LinkedInService: Using specific LinkedIn certification URL: $urlWithParams');

    return urlWithParams;
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
        skills.add(cert.certification!.category!.name);
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

  /// Genera un messaggio per le certificazioni da condividere con informazioni aziendali
  static Future<String> generateCertificationsMessageWithCompany(
      List<UserCertificationDetail> certifications) async {
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
      final date = cert.certificationUser.createdAt;

      // Ottiene il nome dell'azienda
      String organizationName = 'JetCV';
      if (cert.certification?.idLegalEntity != null) {
        final legalEntity = await LegalEntityService.getLegalEntityById(
          cert.certification!.idLegalEntity!,
        );
        if (legalEntity != null) {
          organizationName = LegalEntityService.getCompanyName(legalEntity);
        }
      }

      buffer.writeln('✅ $certName');
      buffer.writeln('   Issued by: $organizationName');
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

      final message =
          await generateCertificationsMessageWithCompany(certifications);
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
