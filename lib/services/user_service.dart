import 'package:flutter/foundation.dart';
import 'package:jetcv__utenti/supabase/supabase_config.dart';
import 'package:jetcv__utenti/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Custom exception for authentication errors
class AuthenticationException implements Exception {
  final String message;
  AuthenticationException(this.message);

  @override
  String toString() => 'AuthenticationException: $message';
}

/// Service for user-related database operations
class UserService {
  static final _client = SupabaseConfig.client;

  /// Get user by ID using the getUserById Edge Function
  /// This uses SERVICE ROLE credentials on the server side for enhanced security
  static Future<UserModel?> getUserById(String userId) async {
    try {
      final response = await _client.functions.invoke(
        'getUserById',
        body: {'idUser': userId},
      );

      if (response.status == 200 && response.data != null) {
        return UserModel.fromJson(response.data);
      } else if (response.status == 404) {
        // User not found
        return null;
      } else if (response.status == 401) {
        // Authentication error - throw specific exception
        debugPrint('❌ UserService.getUserById: Authentication error 401');
        throw AuthenticationException(
            'Authentication failed - invalid or expired session');
      } else {
        throw Exception(
            'Edge Function error ${response.status}: ${response.data}');
      }
    } catch (e) {
      debugPrint('❌ UserService.getUserById error: $e');
      // Re-throw AuthenticationException to preserve error type
      if (e is AuthenticationException) {
        rethrow;
      }
      return null;
    }
  }

  /// Get current authenticated user
  static Future<UserModel?> getCurrentUser() async {
    try {
      final session = _client.auth.currentSession;
      if (session == null || session.user.id.isEmpty) return null;

      return await getUserById(session.user.id);
    } catch (e) {
      debugPrint('❌ UserService.getCurrentUser error: $e');
      return null;
    }
  }

  /// Update user profile using the updateUserProfile Edge Function (v1.6)
  /// Uses PATCH method and supports only allowed fields from the API whitelist
  /// Only updates changed, non-empty fields and automatically calculates profileCompleted
  /// Returns a map with success status and profileCompleted indicator
  static Future<Map<String, dynamic>> updateUser(
      String userId, Map<String, dynamic> updates) async {
    try {
      // Get current session for authorization
      final session = _client.auth.currentSession;
      if (session?.accessToken == null) {
        return {
          'success': false,
          'error': 'Unauthorized',
          'message': 'Valid user session required',
        };
      }

      // Prepare the body with idUser, e and updates
      final body = {
        'idUser': userId,
        'type': 'user',
        ...updates,
      };

      final response = await _client.functions.invoke(
        'updateUserProfile',
        body: body,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${session!.accessToken}',
        },
        method: HttpMethod.post,
      );

      if (response.status == 200 && response.data != null) {
        final data = response.data;
        return {
          'success': data['success'] ?? false,
          'message': data['message'] ?? '',
          'profileCompleted': data['profileCompleted'] ?? false,
        };
      } else if (response.status == 400 && response.data != null) {
        final data = response.data;
        return {
          'success': false,
          'error': data['error'] ?? 'Bad Request',
          'message': data['message'] ?? 'Invalid request data',
        };
      } else if (response.status == 401 && response.data != null) {
        final data = response.data;
        return {
          'success': false,
          'error': data['error'] ?? 'Unauthorized',
          'message': data['message'] ?? 'Valid user session required',
        };
      } else if (response.status == 403 && response.data != null) {
        final data = response.data;
        return {
          'success': false,
          'error': data['error'] ?? 'Forbidden',
          'message': data['message'] ?? 'Cannot update other user\'s profile',
        };
      } else if (response.status == 405 && response.data != null) {
        final data = response.data;
        return {
          'success': false,
          'error': data['error'] ?? 'Method Not Allowed',
          'message': data['message'] ?? 'Use PATCH method',
        };
      } else {
        return {
          'success': false,
          'error': 'Edge Function error ${response.status}',
          'message': response.data != null
              ? response.data.toString()
              : 'Server error occurred',
        };
      }
    } catch (e) {
      debugPrint('❌ UserService.updateUser error: $e');
      return {
        'success': false,
        'error': 'Client Error',
        'message': 'Failed to update user: $e',
      };
    }
  }

  // Altri metodi saranno implementati come chiamate API quando necessario
}
