import 'package:flutter/foundation.dart';
import 'package:jetcv__utenti/supabase/supabase_config.dart';
import 'package:jetcv__utenti/models/country_model.dart';
import 'package:jetcv__utenti/services/edge_function_service.dart';

/// Service for country-related database operations
class CountryService {
  static final _client = SupabaseConfig.client;

  /// Get all countries from Supabase Edge Function
  /// Returns a list of countries ordered by name
  static Future<List<CountryModel>> getAllCountries() async {
    try {
      // Prima prova ad aggiornare la sessione per essere sicuri che il token sia valido
      try {
        await _client.auth.refreshSession();
      } catch (refreshError) {
        // Continue with existing session if refresh fails
      }

      final session = _client.auth.currentSession;

      if (session?.accessToken == null) {
        throw Exception(
            'Nessun token di accesso disponibile. Utente non autenticato.');
      }

      // Usa il client Supabase per chiamare la Edge Function
      final response = await _client.functions.invoke('getCountries');

      if (response.status == 200 && response.data != null) {
        final data = response.data;

        // La funzione restituisce direttamente l'array di paesi
        if (data is List) {
          final List<dynamic> countriesData = data;
          return countriesData
              .map((country) => CountryModel.fromJson(country))
              .toList()
            ..sort((a, b) => a.name.compareTo(b.name));
        } else {
          throw Exception(
              'Formato risposta non valido dalla funzione getCountries: $data');
        }
      } else {
        throw Exception(
            'Edge Function error ${response.status}: ${response.data}');
      }
    } catch (e) {
      debugPrint('❌ CountryService error: $e');
      throw Exception('Errore nel caricamento dei paesi: $e');
    }
  }

  /// Recupera un singolo paese tramite la Edge Function get-country
  ///
  /// [countryCode] - Codice del paese da recuperare (es. "it", "us", "fr")
  /// Il codice viene automaticamente convertito in minuscolo per match database
  ///
  /// Restituisce un [EdgeFunctionResponse<CountryModel>] con:
  /// - success: true se il paese è stato trovato
  /// - data: il CountryModel se trovato
  /// - error: messaggio di errore se fallito
  /// - message: messaggio aggiuntivo
  ///
  /// Possibili errori:
  /// - 400 Bad Request: countryCode mancante o non valido
  /// - 401 Unauthorized: token di accesso mancante o non valido
  /// - 404 Not Found: paese non trovato
  /// - 500 Server Error: errore interno del server
  ///
  /// Esempio:
  /// ```dart
  /// final response = await CountryService.getCountryByCode("it"); // o "IT" - viene normalizzato
  /// if (response.success && response.data != null) {
  ///   final country = response.data!;
  ///   print('Paese trovato: ${country.name} ${country.emoji}');
  /// } else {
  ///   print('Errore: ${response.error}');
  /// }
  /// ```
  static Future<EdgeFunctionResponse<CountryModel>> getCountryByCode(
      String countryCode) async {
    // Validazione input: verifica che countryCode non sia vuoto
    if (countryCode.trim().isEmpty) {
      return EdgeFunctionResponse<CountryModel>(
        success: false,
        error: 'Bad Request',
        message: 'countryCode è richiesto e non può essere vuoto',
      );
    }

    try {
      // Chiama la edge function get-country (convertire in minuscolo per match database)
      final normalizedCode = countryCode.trim().toLowerCase();
      debugPrint(
          '🔍 CountryService: calling get-country with code: "$normalizedCode"');

      final response = await EdgeFunctionService.invokeFunction(
        'get-country',
        {'code': normalizedCode},
      );

      debugPrint('🔄 CountryService: get-country response: $response');

      // La edge function restituisce { ok: true/false, data?, error?, message? }
      // Dobbiamo convertirla nel formato atteso da EdgeFunctionResponse
      final bool isSuccess = response['ok'] == true;

      if (isSuccess && response['data'] != null) {
        // Successo: parse del country data
        final countryData = response['data'] as Map<String, dynamic>;
        final country = CountryModel.fromJson(countryData);

        debugPrint(
            '✅ CountryService: country parsed successfully: ${country.name} (${country.code})');

        return EdgeFunctionResponse<CountryModel>(
          success: true,
          data: country,
          message: response['message'] as String?,
        );
      } else {
        // Errore: gestisci i vari tipi di errore
        debugPrint(
            '❌ CountryService: get-country failed - ok: ${response['ok']}, error: ${response['error']}, message: ${response['message']}');

        return EdgeFunctionResponse<CountryModel>(
          success: false,
          error: response['error'] as String? ?? 'Errore sconosciuto',
          message: response['message'] as String?,
        );
      }
    } catch (e) {
      debugPrint('❌ CountryService: Exception during get-country call: $e');
      return EdgeFunctionResponse<CountryModel>(
        success: false,
        error: 'Errore durante il recupero del paese: $e',
      );
    }
  }

  // Altri metodi saranno implementati come chiamate API quando necessario
}
