/// General app configuration constants
class AppConfig {
  // App URLs and origins
  static const String productionWebsiteUrl = 'https://www.jetcv.com';
  static const String appDomainUrl = 'https://jetcv.com';

  /// Default origin URL used for password reset links in mobile apps
  /// This should be the main website URL where the password reset page is hosted
  static const String mobileOriginUrl = productionWebsiteUrl;

  // App metadata
  static const String appName = 'JetCV';
  static const String appVersion = '1.0.0';

  // Deep link schemes
  static const String deepLinkScheme = 'jetcv';
  static const String authCallbackPath = 'auth/callback';
  static const String passwordResetPath = 'password-reset';

  // API and service endpoints
  static const String privacyPolicyPath = 'privacy-policy';

  /// Get the full deep link URL for auth callback
  static String get authCallbackDeepLink =>
      '$deepLinkScheme://$authCallbackPath';

  /// Get the full web URL for password reset
  static String getPasswordResetUrl(String token) =>
      '$productionWebsiteUrl/$passwordResetPath?token=$token';

  /// Get the full web URL for CV viewing
  static String getCvUrl(String publicId) =>
      '$productionWebsiteUrl/cv/$publicId';

  /// Get the full web URL for certification viewing
  static String getCertificationUrl(String? certificationId) =>
      certificationId != null
          ? '$appDomainUrl/certification/$certificationId'
          : appDomainUrl;

  /// Get the full web URL for privacy policy
  static String get privacyPolicyUrl =>
      '$productionWebsiteUrl/$privacyPolicyPath';

  /// Check if the app is running in development mode
  static bool get isDevelopment {
    bool isDebug = false;
    assert(isDebug = true);
    return isDebug;
  }
}
