import 'package:flutter/foundation.dart';
import 'package:jetcv__utenti/supabase/supabase_config.dart';
import 'package:jetcv__utenti/models/legal_entity_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Servizio per la gestione delle entità legali
class LegalEntityService {
  static final _client = SupabaseConfig.client;

  /// Ottiene le informazioni di un'entità legale tramite ID usando l'edge function
  static Future<LegalEntityModel?> getLegalEntityById(
      String idLegalEntity) async {
    try {
      debugPrint(
          '🏢 LegalEntityService: Fetching legal entity via edge function: $idLegalEntity');

      // Ottieni il token di accesso dall'utente autenticato
      final session = _client.auth.currentSession;
      if (session?.accessToken == null) {
        debugPrint('❌ LegalEntityService: No valid session found');
        return null;
      }

      // Costruisci l'URL dell'edge function con query parameters
      // Usa l'URL base da SupabaseConfig
      final supabaseUrl = 'https://skqsuxmdfqxbkhmselaz.supabase.co';
      final functionUrl =
          '$supabaseUrl/functions/v1/get-legal-entity-by-id?id_legal_entity=$idLegalEntity';

      debugPrint('🔍 LegalEntityService: Calling edge function: $functionUrl');

      // Fai una chiamata HTTP GET diretta
      final response = await http.get(
        Uri.parse(functionUrl),
        headers: {
          'Authorization': 'Bearer ${session!.accessToken}',
          'Content-Type': 'application/json',
        },
      );

      debugPrint(
          '🔍 LegalEntityService: HTTP response status: ${response.statusCode}');
      debugPrint('🔍 LegalEntityService: HTTP response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body) as Map<String, dynamic>;

        if (responseData['ok'] == true && responseData['data'] != null) {
          final legalEntity = LegalEntityModel.fromJson(responseData['data']);
          debugPrint(
              '✅ LegalEntityService: Legal entity fetched successfully: ${legalEntity.legalName}');
          return legalEntity;
        } else {
          final errorCode = responseData['code'] ?? 'unknown';
          final errorMessage = responseData['message'] ?? 'Unknown error';
          debugPrint(
              '❌ LegalEntityService: Edge function error - Code: $errorCode, Message: $errorMessage');
          return null;
        }
      } else {
        debugPrint(
            '❌ LegalEntityService: HTTP error ${response.statusCode}: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ LegalEntityService: Error calling edge function: $e');
      return null;
    }
  }

  /// Ottiene il nome dell'azienda da un'entità legale
  static String getCompanyName(LegalEntityModel? legalEntity) {
    if (legalEntity == null) {
      return 'JetCV';
    }

    // Priorità: legalName > identifierCode > 'JetCV'
    return legalEntity.legalName ?? legalEntity.identifierCode ?? 'JetCV';
  }

  /// Ottiene l'URL del sito web dell'azienda
  static String? getCompanyWebsite(LegalEntityModel? legalEntity) {
    return legalEntity?.website;
  }

  /// Ottiene informazioni complete dell'azienda per LinkedIn
  static Map<String, String> getCompanyInfoForLinkedIn(
      LegalEntityModel? legalEntity) {
    return {
      'name': getCompanyName(legalEntity),
      'website': getCompanyWebsite(legalEntity) ?? '',
      'legalName': legalEntity?.legalName ?? '',
      'identifierCode': legalEntity?.identifierCode ?? '',
    };
  }
}
