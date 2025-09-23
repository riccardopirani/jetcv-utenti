import 'package:flutter/foundation.dart';
import 'package:jetcv__utenti/services/edge_function_service.dart';

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

      final response = await EdgeFunctionService.invokeFunction(
        'forgot-password', // Edge function name for sending reset emails
        {
          'email': email,
        },
      );

      debugPrint('🔐 PasswordService: Send email response: $response');

      // Map the response to expected format
      return {
        'success': response['ok'] == true,
        'message': response['message'] ?? 'Email di reset inviata',
      };
    } catch (e) {
      debugPrint('❌ PasswordService: Send email error: $e');

      // Return a structured error response
      return {
        'success': false,
        'message': localizedMessages?['genericError'] ??
            'Errore durante l\'invio dell\'email. Riprova più tardi.',
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
