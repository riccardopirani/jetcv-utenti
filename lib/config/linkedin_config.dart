/// Configurazione per l'integrazione LinkedIn
class LinkedInConfig {
  // TODO: Configurare queste credenziali nell'app
  static const String clientId = 'YOUR_LINKEDIN_CLIENT_ID';
  static const String clientSecret = 'YOUR_LINKEDIN_CLIENT_SECRET';
  static const String redirectUri =
      'https://amzhiche.com/oauth2/linkedin-callback';

  // Scopes necessari per aggiungere competenze
  static const List<String> scopes = [
    'r_liteprofile', // Leggere il profilo base
    'w_member_social', // Scrivere nel profilo (competenze)
  ];

  // URL dell'API LinkedIn
  static const String apiBaseUrl = 'https://api.linkedin.com/v2';
  static const String authBaseUrl = 'https://www.linkedin.com/oauth/v2';

  /// Verifica se la configurazione è valida
  static bool get isConfigured {
    return clientId != 'YOUR_LINKEDIN_CLIENT_ID' &&
        clientSecret != 'YOUR_LINKEDIN_CLIENT_SECRET' &&
        redirectUri != 'https://your-app.com/linkedin-callback';
  }

  /// Restituisce un messaggio di errore se la configurazione non è valida
  static String get configurationErrorMessage {
    return 'LinkedIn integration is not configured. Please contact the administrator to set up LinkedIn API credentials.';
  }
}
