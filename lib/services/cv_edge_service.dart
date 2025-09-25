import 'package:jetcv__utenti/services/edge_function_service.dart';
import 'package:jetcv__utenti/models/cv_model.dart';

/// Servizio per gestire le Edge Functions relative ai CV
class CvEdgeService {
  /// Recupera il CV dell'utente specificato tramite la Edge Function get-user-cv
  ///
  /// Questa funzione richiede che l'utente sia autenticato e può recuperare
  /// solo il proprio CV (ownership check lato server).
  ///
  /// [idUser] - UUID dell'utente di cui recuperare il CV (deve essere un UUID valido)
  ///
  /// Restituisce un [EdgeFunctionResponse<CvModel>] con:
  /// - success: true se il CV è stato recuperato con successo
  /// - data: il CvModel se recuperato con successo
  /// - error: messaggio di errore se fallito (es. "Bad Request", "Unauthorized", "Forbidden", "Not Found")
  /// - message: messaggio aggiuntivo con dettagli
  ///
  /// Possibili errori:
  /// - 400 Bad Request: idUser non valido o malformato
  /// - 401 Unauthorized: token di accesso mancante o non valido
  /// - 403 Forbidden: tentativo di accedere al CV di un altro utente
  /// - 404 Not Found: CV non trovato per l'utente specificato
  /// - 500 Server Error: errore interno del server
  ///
  /// Esempio:
  /// ```dart
  /// final response = await CvEdgeService.getUserCv(currentUser.id);
  /// if (response.success && response.data != null) {
  ///   final cv = response.data!;
  ///   print('CV trovato: ${cv.firstName} ${cv.lastName}');
  /// } else {
  ///   print('Errore: ${response.error}');
  /// }
  /// ```
  static Future<EdgeFunctionResponse<CvModel>> getUserCv(String idUser) async {
    // Validazione input: verifica che idUser sia un UUID valido
    final uuidRegex = RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
        caseSensitive: false);
    if (idUser.trim().isEmpty || !uuidRegex.hasMatch(idUser.trim())) {
      return EdgeFunctionResponse<CvModel>(
        success: false,
        error: 'Bad Request',
        message: 'idUser deve essere un UUID valido',
      );
    }

    try {
      // Chiama la edge function get-user-cv
      final response = await EdgeFunctionService.invokeFunction(
        'get-user-cv',
        {'idUser': idUser.trim()},
      );

      // La edge function restituisce { ok: true/false, data?, error?, message? }
      // Dobbiamo convertirla nel formato atteso da EdgeFunctionResponse
      final bool isSuccess = response['ok'] == true;

      if (isSuccess) {
        if (response['data'] != null) {
          // Successo con CV: parse del CV data
          final cvData = response['data'] as Map<String, dynamic>;
          final cv = CvModel.fromJson(cvData);

          return EdgeFunctionResponse<CvModel>(
            success: true,
            data: cv,
            message: response['message'] as String?,
          );
        } else {
          // Successo ma nessun CV trovato: restituisci success=true con data=null
          return EdgeFunctionResponse<CvModel>(
            success: true,
            data: null,
            message: response['message'] as String? ??
                'Nessun CV trovato per questo utente',
          );
        }
      } else {
        // Errore API: gestisci i vari tipi di errore
        return EdgeFunctionResponse<CvModel>(
          success: false,
          error: response['error'] as String? ?? 'Errore sconosciuto',
          message: response['message'] as String?,
        );
      }
    } catch (e) {
      return EdgeFunctionResponse<CvModel>(
        success: false,
        error: 'Errore durante il recupero del CV: $e',
      );
    }
  }

  /// Genera un URL pubblico per il CV dell'utente autenticato tramite la Edge Function generate-public-cv-url
  ///
  /// Questa funzione:
  /// - Estrae l'utente dalla sessione corrente
  /// - Carica il CV dell'utente
  /// - Se publicId è null, genera un NanoID e aggiorna la riga
  /// - Restituisce l'URL pubblico usando AppConfig.getCvUrl(publicId)
  ///
  /// Restituisce un [EdgeFunctionResponse<Map<String, String>>] con:
  /// - success: true se l'URL è stato generato con successo
  /// - data: mappa con 'publicId' e 'publicUrl'
  /// - error: messaggio di errore se fallito
  /// - message: messaggio aggiuntivo
  ///
  /// Possibili errori:
  /// - 401 Unauthorized: token di accesso mancante o non valido
  /// - 404 Not Found: CV non trovato per l'utente
  /// - 500 Server Error: errore interno del server o database
  ///
  /// Esempio:
  /// ```dart
  /// final response = await CvEdgeService.generatePublicCvUrl();
  /// if (response.success && response.data != null) {
  ///   final publicUrl = response.data!['publicUrl']!;
  ///   print('URL pubblico generato: $publicUrl');
  /// } else {
  ///   print('Errore: ${response.error}');
  /// }
  /// ```
  static Future<EdgeFunctionResponse<Map<String, String>>>
      generatePublicCvUrl() async {
    try {
      // Chiama la edge function generate-public-cv-url (non richiede body)
      final response = await EdgeFunctionService.invokeFunction(
        'generate-public-cv-url',
        {}, // Corpo vuoto - la funzione legge idUser dal token
      );

      // La edge function restituisce { ok: true/false, publicId?, publicUrl?, error?, message? }
      final bool isSuccess = response['ok'] == true;

      if (isSuccess &&
          response['publicId'] != null &&
          response['publicUrl'] != null) {
        // Successo: estrai publicId e publicUrl
        return EdgeFunctionResponse<Map<String, String>>(
          success: true,
          data: {
            'publicId': response['publicId'] as String,
            'publicUrl': response['publicUrl'] as String,
          },
          message: response['message'] as String?,
        );
      } else {
        // Errore: gestisci i vari tipi di errore
        return EdgeFunctionResponse<Map<String, String>>(
          success: false,
          error: response['error'] as String? ?? 'Errore sconosciuto',
          message: response['message'] as String?,
        );
      }
    } catch (e) {
      return EdgeFunctionResponse<Map<String, String>>(
        success: false,
        error: 'Errore durante la generazione dell\'URL pubblico: $e',
      );
    }
  }
}
