import 'package:flutter/foundation.dart';
import 'package:jetcv__utenti/services/edge_function_service.dart';
import 'package:jetcv__utenti/config/app_config.dart';

/// Service for handling password operations via Supabase Edge Functions
class PasswordService {
  /// Reset password using a token received via email
  ///
  /// [token] - The reset token from the email link
  /// [newPassword] - The new password to set
  ///
  /// Returns a map with success status and message
  static Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      debugPrint('🔐 PasswordService: Starting password reset');

      final response = await EdgeFunctionService.invokeFunction(
        'reset-password',
        {
          'token': token,
          'password': newPassword,
        },
      );

      debugPrint('🔐 PasswordService: Reset password response: $response');

      return response;
    } catch (e) {
      debugPrint('❌ PasswordService: Password reset error: $e');

      // Return a structured error response
      return {
        'ok': false,
        'status': 500,
        'message': 'Errore nella reimpostazione della password: $e',
      };
    }
  }

  /// Validate password according to security policy
  /// Same rules as signup: min 8 chars, uppercase, lowercase, digit, symbol
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'La password è obbligatoria';
    }

    if (password.length < 8) {
      return 'La password deve essere di almeno 8 caratteri';
    }

    // Check for uppercase letter
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'La password deve contenere almeno una lettera maiuscola, una minuscola, un numero e un simbolo';
    }

    // Check for lowercase letter
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'La password deve contenere almeno una lettera maiuscola, una minuscola, un numero e un simbolo';
    }

    // Check for number
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'La password deve contenere almeno una lettera maiuscola, una minuscola, un numero e un simbolo';
    }

    // Check for symbol
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      return 'La password deve contenere almeno una lettera maiuscola, una minuscola, un numero e un simbolo';
    }

    return null; // Password is valid
  }

  /// Validate that passwords match
  static String? validatePasswordConfirmation(
      String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'La conferma password è obbligatoria';
    }

    if (password != confirmPassword) {
      return 'Le password non coincidono';
    }

    return null; // Passwords match
  }

  /// Send password reset email using edge function
  ///
  /// [email] - The user's email address
  /// [localizedMessages] - Localized error messages for different scenarios
  ///
  /// Returns a map with success status and message
  static Future<Map<String, dynamic>> sendPasswordResetEmail({
    required String email,
    Map<String, String>? localizedMessages,
  }) async {
    try {
      debugPrint('🔐 PasswordService: Sending password reset email');

      // Get the current origin for the reset link
      String origin;
      if (kIsWeb) {
        origin = Uri.base.origin;
      } else {
        // For mobile apps, use the centralized configuration
        origin = AppConfig.mobileOriginUrl;
      }

      debugPrint('🔐 PasswordService: Using origin: $origin');

      final response = await EdgeFunctionService.invokeFunction(
        'send-password-reset-email', // Correct edge function name
        {
          'email': email,
          'origin': origin,
        },
      );

      debugPrint('🔐 PasswordService: Send email response: $response');

      // Handle different response formats based on status codes
      final status = response['status'] ?? 0;
      final isSuccess = response['ok'] == true || status == 200;

      if (isSuccess) {
        return {
          'success': true,
          'message': response['message'] ?? 'Email di reset inviata',
        };
      } else {
        // Map specific error statuses to localized messages
        String errorMessage;
        switch (status) {
          case 404:
            errorMessage = localizedMessages?['userNotFound'] ??
                'Nessun account trovato con questo indirizzo email.';
            break;
          case 409:
            errorMessage = localizedMessages?['multipleUsersFound'] ??
                'Errore interno: più account trovati con questo email.';
            break;
          case 422:
            errorMessage = localizedMessages?['validationError'] ??
                'Indirizzo email non valido.';
            break;
          case 502:
          case 503:
            errorMessage = localizedMessages?['emailServiceError'] ??
                'Servizio email temporaneamente non disponibile. Riprova più tardi.';
            break;
          default:
            errorMessage = localizedMessages?['genericError'] ??
                response['message'] ??
                'Errore durante l\'invio dell\'email. Riprova più tardi.';
        }

        return {
          'success': false,
          'message': errorMessage,
        };
      }
    } catch (e) {
      debugPrint('❌ PasswordService: Send email error: $e');

      // Check if it's a network error
      String errorMessage;
      if (e.toString().contains('Network error') ||
          e.toString().contains('Connection error') ||
          e.toString().contains('Failed to fetch')) {
        errorMessage = localizedMessages?['networkError'] ??
            'Errore di connessione. Verifica la tua connessione internet e riprova.';
      } else {
        errorMessage = localizedMessages?['genericError'] ??
            'Errore durante l\'invio dell\'email. Riprova più tardi.';
      }

      return {
        'success': false,
        'message': errorMessage,
      };
    }
  }

  /// Extract token from browser URL
  /// Looks for 'token' parameter in the current URL
  static String? getTokenFromUrl() {
    try {
      if (kIsWeb) {
        final uri = Uri.base;
        return uri.queryParameters['token'];
      }
      return null;
    } catch (e) {
      debugPrint('❌ PasswordService: Error extracting token from URL: $e');
      return null;
    }
  }
}
