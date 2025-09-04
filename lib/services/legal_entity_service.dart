import 'package:flutter/foundation.dart';
import 'package:jetcv__utenti/supabase/supabase_config.dart';
import 'package:jetcv__utenti/models/legal_entity_model.dart';

/// Servizio per la gestione delle entità legali
class LegalEntityService {
  static final _client = SupabaseConfig.client;

  /// Ottiene le informazioni di un'entità legale tramite ID
  static Future<LegalEntityModel?> getLegalEntityById(
      String idLegalEntity) async {
    try {
      debugPrint(
          '🏢 LegalEntityService: Fetching legal entity: $idLegalEntity');

      final response = await _client
          .from('legal_entity')
          .select()
          .eq('id_legal_entity', idLegalEntity)
          .maybeSingle();

      if (response == null) {
        debugPrint(
            '❌ LegalEntityService: Legal entity not found: $idLegalEntity');
        return null;
      }

      final legalEntity = LegalEntityModel.fromJson(response);
      debugPrint('✅ LegalEntityService: Legal entity fetched successfully');
      return legalEntity;
    } catch (e) {
      debugPrint('❌ LegalEntityService: Error fetching legal entity: $e');
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
