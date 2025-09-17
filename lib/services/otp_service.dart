import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:jetcv__utenti/models/models.dart';
import 'package:jetcv__utenti/services/edge_function_service.dart';
import 'package:jetcv__utenti/supabase/supabase_config.dart';
import 'package:http/http.dart' as http;

/// Service for OTP operations using the deployed otp-crud Supabase function
class OtpService {
  static const String _functionName = 'otp-crud';

  /// Create a new OTP via Edge Function
  /// Expected response format: { data: {...} }
  /// Returns the created OTP with code and metadata
  static Future<EdgeFunctionResponse<OtpModel>> createOtp({
    String? idUser,
    String? tag,
    int ttlSeconds = 300,
    int length = 6,
    bool numericOnly = true,
  }) async {
    try {
      debugPrint('🔐 OtpService: Creating OTP with tag: $tag');
      debugPrint('🔐 OtpService: Function name: $_functionName');
      debugPrint('🔐 OtpService: User ID: $idUser');
      debugPrint('🔐 OtpService: Supabase URL: ${SupabaseConfig.supabaseUrl}');
      debugPrint(
          '🔐 OtpService: Current user: ${SupabaseConfig.client.auth.currentUser?.id}');

      final requestBody = {
        'id_user': idUser,
        'tag': tag,
        'ttl_seconds': ttlSeconds,
        'length': length,
        'numeric_only': numericOnly,
      };

      debugPrint('🔐 OtpService: Request body: $requestBody');

      final response = await EdgeFunctionService.invokeFunction(
        _functionName,
        requestBody,
      );

      debugPrint('🔄 OtpService: Create OTP response: $response');
      debugPrint('🔄 OtpService: Response type: ${response.runtimeType}');
      debugPrint('🔄 OtpService: Response keys: ${response.keys.toList()}');

      // The function returns { data: {...} }
      // Check if we have data object in the response
      final bool hasData = response.containsKey('data') &&
          response['data'] is Map<String, dynamic>;

      if (hasData) {
        final otpData = response['data'] as Map<String, dynamic>;
        final otp = OtpModel.fromJson(otpData);

        debugPrint('✅ OtpService: OTP created successfully: ${otp.idOtp}');

        return EdgeFunctionResponse<OtpModel>(
          success: true,
          data: otp,
          message: 'OTP created successfully',
        );
      } else {
        debugPrint(
            '❌ OtpService: Create OTP failed - invalid response format: ${response.keys.toList()}');

        return EdgeFunctionResponse<OtpModel>(
          success: false,
          error: response['error'] as String? ??
              'Invalid response format: expected "data" object but got ${response.keys.toList()}',
        );
      }
    } catch (e) {
      debugPrint('❌ OtpService: Exception during OTP creation: $e');
      debugPrint('❌ OtpService: Exception type: ${e.runtimeType}');

      // Handle specific error types
      String errorMessage = 'Error creating OTP: $e';
      if (e.toString().contains('Failed to fetch')) {
        errorMessage =
            'Network error: Unable to connect to OTP service. Please check your internet connection.';
      } else if (e.toString().contains('ClientException')) {
        errorMessage =
            'Connection error: Unable to reach the OTP service. Please try again later.';
      }

      return EdgeFunctionResponse<OtpModel>(
        success: false,
        error: errorMessage,
      );
    }
  }

  /// Verify an OTP code
  /// Returns verification result with OTP metadata
  static Future<EdgeFunctionResponse<Map<String, dynamic>>> verifyOtp({
    required String code,
    String? idUser,
    String? tag,
    bool markUsed = true,
    String? usedBy,
  }) async {
    try {
      debugPrint('🔍 OtpService: Verifying OTP code: $code');

      final response = await EdgeFunctionService.invokeFunction(
        _functionName,
        {
          'code': code,
          'id_user': idUser,
          'tag': tag,
          'mark_used': markUsed,
          'used_by': usedBy,
        },
      );

      debugPrint('🔄 OtpService: Verify OTP response: $response');

      // The function returns { ok: true, result: {...} }
      final bool isSuccess = response['ok'] == true;

      if (isSuccess && response['result'] != null) {
        final result = response['result'] as Map<String, dynamic>;

        debugPrint('✅ OtpService: OTP verified successfully');

        return EdgeFunctionResponse<Map<String, dynamic>>(
          success: true,
          data: result,
          message: 'OTP verified successfully',
        );
      } else {
        debugPrint(
            '❌ OtpService: Verify OTP failed - ok: ${response['ok']}, error: ${response['error']}');

        return EdgeFunctionResponse<Map<String, dynamic>>(
          success: false,
          error: response['error'] as String? ?? 'Invalid OTP code',
        );
      }
    } catch (e) {
      debugPrint('❌ OtpService: Exception during OTP verification: $e');
      return EdgeFunctionResponse<Map<String, dynamic>>(
        success: false,
        error: 'Error verifying OTP: $e',
      );
    }
  }

  /// Burn (invalidate) an OTP via Edge Function DELETE
  /// Expected response: 204 No Content
  /// Returns success status
  static Future<EdgeFunctionResponse<bool>> burnOtp({
    required String idOtp,
    String? idUser,
  }) async {
    try {
      debugPrint('🔥 OtpService: Burning OTP: $idOtp');

      // Use HTTP DELETE request to Edge Function
      final url =
          '${SupabaseConfig.supabaseUrl}/functions/v1/$_functionName?id=$idOtp';
      final session = SupabaseConfig.client.auth.currentSession;

      if (session == null) {
        throw Exception('No active session');
      }

      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer ${session.accessToken}',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('🔄 OtpService: Burn OTP HTTP status: ${response.statusCode}');
      debugPrint('🔄 OtpService: Burn OTP response body: ${response.body}');

      // DELETE returns 204 No Content on success
      if (response.statusCode == 204) {
        debugPrint('✅ OtpService: OTP burned successfully: $idOtp');

        return EdgeFunctionResponse<bool>(
          success: true,
          data: true,
          message: 'OTP burned successfully',
        );
      } else {
        String errorMessage = 'HTTP ${response.statusCode}';
        if (response.body.isNotEmpty) {
          try {
            final errorData = json.decode(response.body);
            errorMessage = errorData['error'] ?? errorMessage;
          } catch (e) {
            errorMessage = response.body;
          }
        }

        debugPrint(
            '❌ OtpService: Burn OTP failed - HTTP ${response.statusCode}: $errorMessage');

        return EdgeFunctionResponse<bool>(
          success: false,
          error: 'Failed to burn OTP: $errorMessage',
        );
      }
    } catch (e) {
      debugPrint('❌ OtpService: Exception during OTP burn: $e');
      return EdgeFunctionResponse<bool>(
        success: false,
        error: 'Error burning OTP: $e',
      );
    }
  }

  /// Get OTP metadata by ID (without code/hash for security)
  /// Returns OTP metadata
  static Future<EdgeFunctionResponse<OtpMetadataModel>> getOtpMetadata({
    required String idOtp,
  }) async {
    try {
      debugPrint('📋 OtpService: Getting OTP metadata: $idOtp');

      final response = await EdgeFunctionService.invokeFunction(
        _functionName,
        {
          'id_otp': idOtp,
        },
      );

      debugPrint('🔄 OtpService: Get OTP metadata response: $response');

      // The function returns { ok: true, otp: {...} }
      final bool isSuccess = response['ok'] == true;

      if (isSuccess && response['otp'] != null) {
        final otpData = response['otp'] as Map<String, dynamic>;
        final otpMetadata = OtpMetadataModel.fromJson(otpData);

        debugPrint('✅ OtpService: OTP metadata retrieved successfully');

        return EdgeFunctionResponse<OtpMetadataModel>(
          success: true,
          data: otpMetadata,
          message: 'OTP metadata retrieved successfully',
        );
      } else {
        debugPrint(
            '❌ OtpService: Get OTP metadata failed - ok: ${response['ok']}, error: ${response['error']}');

        return EdgeFunctionResponse<OtpMetadataModel>(
          success: false,
          error: response['error'] as String? ?? 'Failed to get OTP metadata',
        );
      }
    } catch (e) {
      debugPrint('❌ OtpService: Exception during OTP metadata retrieval: $e');
      return EdgeFunctionResponse<OtpMetadataModel>(
        success: false,
        error: 'Error getting OTP metadata: $e',
      );
    }
  }

  /// Test database connection and OTP table existence
  /// Returns success status
  static Future<EdgeFunctionResponse<bool>> testDatabaseConnection() async {
    try {
      debugPrint('🧪 OtpService: Testing database connection...');

      // Test if we can query the OTP table
      final response =
          await SupabaseConfig.client.from('otp').select('count').limit(1);

      debugPrint('✅ OtpService: Database connection successful');
      debugPrint('📊 OtpService: OTP table accessible, response: $response');

      return EdgeFunctionResponse<bool>(
        success: true,
        data: true,
        message: 'Database connection successful',
      );
    } catch (e) {
      debugPrint('❌ OtpService: Database connection failed: $e');
      return EdgeFunctionResponse<bool>(
        success: false,
        error: 'Database connection failed: $e',
      );
    }
  }

  /// Get all OTPs for a user via Edge Function
  /// Expected response format: { data: [...], count: number, limit: number, offset: number }
  /// Returns list of OTPs
  static Future<EdgeFunctionResponse<List<OtpModel>>> getUserOtps({
    String? idUser,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      debugPrint('📋 OtpService: Getting user OTPs for user: $idUser');

      if (idUser == null) {
        return EdgeFunctionResponse<List<OtpModel>>(
          success: false,
          error: 'User ID is required',
        );
      }

      // Use Edge Function otp-crud with /by-user endpoint
      debugPrint(
          '🔍 OtpService: Calling Edge Function otp-crud /by-user endpoint');
      debugPrint(
          '🔍 OtpService: Parameters: id_user=$idUser, limit=$limit, offset=$offset');

      // Build URL with query parameters
      final queryParams = {
        'id_user': idUser,
        'limit': limit.toString(),
        'offset': offset.toString(),
      };

      final queryString = queryParams.entries
          .map((e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
          .join('&');

      final url =
          '${SupabaseConfig.supabaseUrl}/functions/v1/otp-crud/by-user?$queryString';
      debugPrint('🔍 OtpService: Full URL: $url');

      // Get current session for authentication
      final session = SupabaseConfig.client.auth.currentSession;
      if (session == null) {
        throw Exception('No active session');
      }

      // Make HTTP GET request
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer ${session.accessToken}',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('📋 OtpService: HTTP response status: ${response.statusCode}');
      debugPrint('📋 OtpService: HTTP response body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception(
            'HTTP request failed with status ${response.statusCode}: ${response.body}');
      }

      final responseData = Map<String, dynamic>.from(
        json.decode(response.body),
      );

      debugPrint('📋 OtpService: Edge Function response: $responseData');
      debugPrint('📋 OtpService: Response type: ${responseData.runtimeType}');
      debugPrint('📋 OtpService: Response keys: ${responseData.keys.toList()}');

      // The function returns { data: [...], count: number, limit: number, offset: number }
      // Check if we have data array in the response
      final bool hasData =
          responseData.containsKey('data') && responseData['data'] is List;

      if (hasData) {
        final List<dynamic> items = responseData['data'] as List<dynamic>;
        debugPrint(
            '📋 OtpService: Found ${items.length} OTPs via Edge Function');

        final List<OtpModel> otps = [];
        for (final otpData in items) {
          try {
            // Convert Edge Function response to OtpModel format
            final otpJson = Map<String, dynamic>.from(otpData);

            // Check if OTP is blocked (used by another user)
            final isBlocked = otpJson['used_by_id_user'] != null;

            // Hide sensitive data for blocked OTPs
            if (isBlocked) {
              // Hide code for blocked OTPs
              otpJson['code'] = '***'; // Don't expose actual code
              otpJson['code_hash'] = null; // Hide hash
            }
            // For non-blocked OTPs, use data as-is from API
            // code_hash can be null (especially for newly created OTPs)

            debugPrint('📋 OtpService: Processing OTP: ${otpJson['id_otp']}');
            debugPrint('📋 OtpService: isBlocked: $isBlocked');
            debugPrint('📋 OtpService: code: ${otpJson['code']}');
            debugPrint(
                '📋 OtpService: used_by_id_user: ${otpJson['used_by_id_user']}');
            debugPrint(
                '📋 OtpService: id_legal_entity: ${otpJson['id_legal_entity']}');
            debugPrint(
                '📋 OtpService: id_legal_entity type: ${otpJson['id_legal_entity'].runtimeType}');
            debugPrint(
                '📋 OtpService: id_legal_entity is null: ${otpJson['id_legal_entity'] == null}');

            final otp = OtpModel.fromJson(otpJson);
            otps.add(otp);
          } catch (e) {
            debugPrint('❌ OtpService: Error parsing OTP: $e, data: $otpData');
          }
        }

        debugPrint(
            '✅ OtpService: Retrieved ${otps.length} OTPs successfully via Edge Function');

        return EdgeFunctionResponse<List<OtpModel>>(
          success: true,
          data: otps,
          message: 'OTPs retrieved successfully',
        );
      } else {
        debugPrint(
            '❌ OtpService: Invalid response format or no data: ${responseData.keys.toList()}');
        return EdgeFunctionResponse<List<OtpModel>>(
          success: false,
          error:
              'Invalid response format: expected "data" array but got ${responseData.keys.toList()}',
        );
      }
    } catch (e) {
      debugPrint('❌ OtpService: Error getting user OTPs: $e');
      debugPrint('❌ OtpService: Error type: ${e.runtimeType}');
      debugPrint('❌ OtpService: Error details: $e');
      return EdgeFunctionResponse<List<OtpModel>>(
        success: false,
        error: 'Error getting user OTPs: $e',
      );
    }
  }

  /// Update OTP tag via Edge Function
  /// Expected response format: { data: {...} }
  /// Returns the updated OTP
  static Future<EdgeFunctionResponse<OtpModel>> updateOtpTag({
    required String idOtp,
    String? idUser,
    required String newTag,
  }) async {
    try {
      debugPrint('✏️ OtpService: Updating OTP tag for: $idOtp');
      debugPrint('✏️ OtpService: New tag: $newTag');

      final response = await EdgeFunctionService.invokeFunction(
        _functionName,
        {
          'id_otp': idOtp,
          'id_user': idUser,
          'tag': newTag,
        },
      );

      debugPrint('🔄 OtpService: Update OTP tag response: $response');

      // The function returns { data: {...} }
      // Check if we have data object in the response
      final bool hasData = response.containsKey('data') &&
          response['data'] is Map<String, dynamic>;

      if (hasData) {
        final otpData = response['data'] as Map<String, dynamic>;
        final otp = OtpModel.fromJson(otpData);

        debugPrint('✅ OtpService: OTP tag updated successfully');

        return EdgeFunctionResponse<OtpModel>(
          success: true,
          data: otp,
          message: 'OTP tag updated successfully',
        );
      } else {
        debugPrint(
            '❌ OtpService: Update OTP tag failed - invalid response format: ${response.keys.toList()}');

        return EdgeFunctionResponse<OtpModel>(
          success: false,
          error: response['error'] as String? ??
              'Invalid response format: expected "data" object but got ${response.keys.toList()}',
        );
      }
    } catch (e) {
      debugPrint('❌ OtpService: Exception during OTP tag update: $e');
      return EdgeFunctionResponse<OtpModel>(
        success: false,
        error: 'Error updating OTP tag: $e',
      );
    }
  }

  /// Get legal entity data for OTP
  /// Returns legal entity information if OTP has idLegalEntity
  static Future<EdgeFunctionResponse<Map<String, dynamic>>>
      getLegalEntityForOtp({
    required String idLegalEntity,
  }) async {
    try {
      debugPrint('🏢 OtpService: Getting legal entity for OTP: $idLegalEntity');
      debugPrint(
          '🔍 OtpService: idLegalEntity type: ${idLegalEntity.runtimeType}');
      debugPrint(
          '🔍 OtpService: idLegalEntity is empty: ${idLegalEntity.isEmpty}');

      // Use Edge Function get-legal-entity-by-id
      try {
        debugPrint(
            '🔍 OtpService: Calling Edge Function get-legal-entity-by-id');
        debugPrint('🔍 OtpService: Parameters: id_legal_entity=$idLegalEntity');

        // Get current session for authentication
        final session = SupabaseConfig.client.auth.currentSession;
        if (session == null) {
          throw Exception('No active session');
        }

        // Build URL with query parameters
        final queryParams = {
          'id_legal_entity': idLegalEntity,
        };

        final queryString = queryParams.entries
            .map((e) =>
                '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
            .join('&');

        final url =
            '${SupabaseConfig.supabaseUrl}/functions/v1/get-legal-entity-by-id?$queryString';
        debugPrint('🔍 OtpService: Full URL: $url');

        // Make HTTP GET request
        final response = await http.get(
          Uri.parse(url),
          headers: {
            'Authorization': 'Bearer ${session.accessToken}',
            'Content-Type': 'application/json',
          },
        );

        debugPrint(
            '📋 OtpService: HTTP response status: ${response.statusCode}');
        debugPrint('📋 OtpService: HTTP response body: ${response.body}');

        if (response.statusCode != 200) {
          throw Exception(
              'HTTP request failed with status ${response.statusCode}: ${response.body}');
        }

        final responseData = Map<String, dynamic>.from(
          json.decode(response.body),
        );

        debugPrint('🔄 OtpService: Get legal entity response received');
        debugPrint('🔄 OtpService: Response type: ${responseData.runtimeType}');
        debugPrint('🔄 OtpService: Response: $responseData');
        debugPrint(
            '🔄 OtpService: Response keys: ${responseData.keys.toList()}');

        // The function returns { ok: true, data: {...}, request_id }
        final bool isSuccess = responseData['ok'] == true;
        debugPrint('🔍 OtpService: Response ok: ${responseData['ok']}');
        debugPrint('🔍 OtpService: isSuccess: $isSuccess');
        debugPrint(
            '🔍 OtpService: data exists: ${responseData['data'] != null}');
        debugPrint('🔍 OtpService: data: ${responseData['data']}');

        if (isSuccess && responseData['data'] != null) {
          final legalEntityData = responseData['data'] as Map<String, dynamic>;

          debugPrint(
              '✅ OtpService: Legal entity retrieved successfully via Edge Function');
          debugPrint(
              '📊 OtpService: Legal entity data keys: ${legalEntityData.keys.toList()}');
          debugPrint('📊 OtpService: Legal entity data: $legalEntityData');

          return EdgeFunctionResponse<Map<String, dynamic>>(
            success: true,
            data: legalEntityData,
            message: 'Legal entity retrieved successfully',
          );
        } else {
          debugPrint(
              '❌ OtpService: Get legal entity failed via Edge Function - ok: ${responseData['ok']}, code: ${responseData['code']}, message: ${responseData['message']}');
          return EdgeFunctionResponse<Map<String, dynamic>>(
            success: false,
            error: 'Legal entity not found: ${responseData['message']}',
          );
        }
      } catch (edgeFunctionError) {
        debugPrint('⚠️ OtpService: Edge Function failed: $edgeFunctionError');
        return EdgeFunctionResponse<Map<String, dynamic>>(
          success: false,
          error: 'Failed to get legal entity: $edgeFunctionError',
        );
      }
    } catch (e) {
      debugPrint('❌ OtpService: Exception during legal entity retrieval: $e');
      return EdgeFunctionResponse<Map<String, dynamic>>(
        success: false,
        error: 'Error getting legal entity: $e',
      );
    }
  }

  /// Clean up expired OTPs (garbage collection)
  /// Returns number of OTPs cleaned up
  static Future<EdgeFunctionResponse<int>> cleanupExpiredOtps({
    DateTime? before,
  }) async {
    try {
      debugPrint('🧹 OtpService: Cleaning up expired OTPs');

      final response = await EdgeFunctionService.invokeFunction(
        _functionName,
        {
          'before': before?.toIso8601String(),
        },
      );

      debugPrint('🔄 OtpService: Cleanup OTPs response: $response');

      // The function returns { ok: true, burned_count: number }
      final bool isSuccess = response['ok'] == true;

      if (isSuccess) {
        final burnedCount = response['burned_count'] as int? ?? 0;

        debugPrint('✅ OtpService: Cleaned up $burnedCount expired OTPs');

        return EdgeFunctionResponse<int>(
          success: true,
          data: burnedCount,
          message: 'Cleaned up $burnedCount expired OTPs',
        );
      } else {
        debugPrint(
            '❌ OtpService: Cleanup OTPs failed - ok: ${response['ok']}, error: ${response['error']}');

        return EdgeFunctionResponse<int>(
          success: false,
          error: response['error'] as String? ?? 'Failed to cleanup OTPs',
        );
      }
    } catch (e) {
      debugPrint('❌ OtpService: Exception during OTP cleanup: $e');
      return EdgeFunctionResponse<int>(
        success: false,
        error: 'Error cleaning up OTPs: $e',
      );
    }
  }
}
