import 'package:jetcv__utenti/supabase/supabase_config.dart';
import 'package:jetcv__utenti/models/country_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Service for country-related database operations
class CountryService {
  static final _client = SupabaseConfig.client;

  /// Get all countries from Supabase Edge Function
  /// Returns a list of countries ordered by name
  static Future<List<CountryModel>> getAllCountries() async {
    try {
      // Prima prova ad aggiornare la sessione per essere sicuri che il token sia valido
      try {
        print('🔍 DEBUG CountryService - Refreshing session...');
        final refreshResponse = await _client.auth.refreshSession();
        print('🔍 DEBUG CountryService - Session refresh success: ${refreshResponse.session != null}');
      } catch (refreshError) {
        print('🔍 DEBUG CountryService - Session refresh failed: $refreshError');
        // Continue with existing session if refresh fails
      }
      
      final session = _client.auth.currentSession;
      
      // Debug: verifica stato sessione dopo refresh
      print('🔍 DEBUG CountryService - Session exists: ${session != null}');
      print('🔍 DEBUG CountryService - User ID: ${session?.user?.id}');
      print('🔍 DEBUG CountryService - Access token exists: ${session?.accessToken != null}');
      
      if (session?.accessToken == null) {
        throw Exception('Nessun token di accesso disponibile. Utente non autenticato.');
      }
      
      print('🔍 DEBUG CountryService - Calling Edge Function via Supabase client...');
      
      // Usa il client Supabase senza header Authorization per vedere se funziona
      final response = await _client.functions.invoke('getCountries');

      print('🔍 DEBUG CountryService - Edge Function response status: ${response.status}');
      //print('🔍 DEBUG CountryService - Edge Function response data: ${response.data}');

      if (response.status == 200 && response.data != null) {
        final data = response.data;
        
        // La funzione restituisce direttamente l'array di paesi
        if (data is List) {
          final List<dynamic> countriesData = data;
          return countriesData.map((country) => CountryModel.fromJson(country)).toList()
            ..sort((a, b) => a.name.compareTo(b.name));
        } else {
          throw Exception('Formato risposta non valido dalla funzione getCountries: $data');
        }
      } else {
        throw Exception('Edge Function error ${response.status}: ${response.data}');
      }
    } catch (e) {
      print('🔍 DEBUG CountryService - Exception caught: $e');
      throw Exception('Errore nel caricamento dei paesi: $e');
    }
  }


  // Altri metodi saranno implementati come chiamate API quando necessario
}