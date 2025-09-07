import 'package:flutter/foundation.dart';
import 'package:jetcv__utenti/models/models.dart';
import 'package:jetcv__utenti/services/edge_function_service.dart';
import 'package:jetcv__utenti/supabase/supabase_config.dart';

/// Service for OTP operations using the deployed otp-crud Supabase function
class OtpService {
  static const String _functionName = 'otp-crud';

  /// Create a new OTP
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

      // The function returns { ok: true, otp: {...} }
      final bool isSuccess = response['ok'] == true;

      if (isSuccess && response['otp'] != null) {
        final otpData = response['otp'] as Map<String, dynamic>;
        final otp = OtpModel.fromJson(otpData);

        debugPrint('✅ OtpService: OTP created successfully: ${otp.idOtp}');

        return EdgeFunctionResponse<OtpModel>(
          success: true,
          data: otp,
          message: 'OTP created successfully',
        );
      } else {
        debugPrint(
            '❌ OtpService: Create OTP failed - ok: ${response['ok']}, error: ${response['error']}');

        return EdgeFunctionResponse<OtpModel>(
          success: false,
          error: response['error'] as String? ?? 'Failed to create OTP',
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

  /// Burn (invalidate) an OTP
  /// Returns success status
  static Future<EdgeFunctionResponse<bool>> burnOtp({
    required String idOtp,
    String? idUser,
  }) async {
    try {
      debugPrint('🔥 OtpService: Burning OTP: $idOtp');

      final response = await EdgeFunctionService.invokeFunction(
        _functionName,
        {
          'id_otp': idOtp,
          'id_user': idUser,
        },
      );

      debugPrint('🔄 OtpService: Burn OTP response: $response');

      // The function returns { ok: true, burned: true/false }
      final bool isSuccess = response['ok'] == true;

      if (isSuccess) {
        final burned = response['burned'] as bool? ?? false;

        debugPrint('✅ OtpService: OTP burned successfully: $burned');

        return EdgeFunctionResponse<bool>(
          success: true,
          data: burned,
          message: 'OTP burned successfully',
        );
      } else {
        debugPrint(
            '❌ OtpService: Burn OTP failed - ok: ${response['ok']}, error: ${response['error']}');

        return EdgeFunctionResponse<bool>(
          success: false,
          error: response['error'] as String? ?? 'Failed to burn OTP',
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

  /// Get all OTPs for a user
  /// Returns list of OTPs
  static Future<EdgeFunctionResponse<List<OtpModel>>> getUserOtps({
    String? idUser,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      debugPrint('📋 OtpService: Getting user OTPs for user: $idUser');

      // Query the OTP table directly
      if (idUser == null) {
        return EdgeFunctionResponse<List<OtpModel>>(
          success: false,
          error: 'User ID is required',
        );
      }

      // Use RPC function as primary method
      debugPrint(
          '🔍 OtpService: Querying OTPs for user: $idUser using RPC function');

      final response = await SupabaseConfig.client.rpc(
        'otp_list_user_otps',
        params: {
          'p_id_user': idUser,
          'p_limit': limit,
          'p_offset': offset,
        },
      );

      debugPrint(
          '📋 OtpService: RPC function successful, found ${response.length} OTPs');

      debugPrint('📋 OtpService: Raw OTP response: $response');
      debugPrint(
          '📊 OtpService: Found ${response.length} OTPs for user $idUser');

      final List<OtpModel> otps = [];
      for (final otpData in response) {
        try {
          // Convert RPC response to OtpModel format
          final otpJson = Map<String, dynamic>.from(otpData);
          // Add missing fields that OtpModel expects
          otpJson['code'] = '***'; // Don't expose actual code
          otpJson['code_hash'] = '***'; // Don't expose hash

          // Get id_legal_entity from database since RPC doesn't include it
          final otpId = otpJson['id_otp'];
          try {
            final legalEntityResponse = await SupabaseConfig.client
                .from('otp')
                .select('id_legal_entity')
                .eq('id_otp', otpId)
                .single();

            otpJson['id_legal_entity'] = legalEntityResponse['id_legal_entity'];

            if (otpJson['id_legal_entity'] == null) {
              debugPrint(
                  '⚠️ OtpService: id_legal_entity is null for OTP: $otpId');
            } else {
              debugPrint(
                  '✅ OtpService: id_legal_entity found for OTP: $otpId -> ${otpJson['id_legal_entity']}');
            }
          } catch (legalEntityError) {
            debugPrint(
                '⚠️ OtpService: Could not fetch id_legal_entity for OTP $otpId: $legalEntityError');
            otpJson['id_legal_entity'] = null;
          }

          debugPrint(
              '📋 OtpService: Processing OTP: $otpId, id_legal_entity: ${otpJson['id_legal_entity']}');

          final otp = OtpModel.fromJson(otpJson);
          otps.add(otp);
        } catch (e) {
          debugPrint('❌ OtpService: Error parsing OTP: $e, data: $otpData');
        }
      }

      debugPrint('✅ OtpService: Retrieved ${otps.length} OTPs successfully');

      return EdgeFunctionResponse<List<OtpModel>>(
        success: true,
        data: otps,
        message: 'OTPs retrieved successfully',
      );
    } catch (e) {
      debugPrint('❌ OtpService: Error getting user OTPs: $e');
      return EdgeFunctionResponse<List<OtpModel>>(
        success: false,
        error: 'Error getting user OTPs: $e',
      );
    }
  }

  /// Test Edge Function accessibility
  /// Returns success status
  static Future<EdgeFunctionResponse<bool>> testEdgeFunction() async {
    try {
      debugPrint('🧪 OtpService: Testing Edge Function accessibility...');

      // Check authentication first
      final currentUser = SupabaseConfig.client.auth.currentUser;
      final currentSession = SupabaseConfig.client.auth.currentSession;

      debugPrint('🔐 OtpService: Current user: ${currentUser?.id}');
      debugPrint('🔐 OtpService: Current session: ${currentSession != null}');
      debugPrint(
          '🔐 OtpService: Session expires at: ${currentSession?.expiresAt}');
      debugPrint(
          '🔐 OtpService: Session is expired: ${currentSession?.isExpired}');

      if (currentUser == null || currentSession == null) {
        return EdgeFunctionResponse<bool>(
          success: false,
          error: 'User not authenticated',
        );
      }

      if (currentSession.isExpired) {
        return EdgeFunctionResponse<bool>(
          success: false,
          error: 'Session expired',
        );
      }

      // Test by creating a temporary OTP (this will be cleaned up)
      final response = await EdgeFunctionService.invokeFunction(
        _functionName,
        {
          'id_user': currentUser.id,
          'tag': 'test-connection',
          'ttl_seconds': 60, // Short TTL for test
          'length': 6,
          'numeric_only': true,
        },
      );

      debugPrint('✅ OtpService: Edge Function accessible');
      debugPrint('📊 OtpService: Edge Function response: $response');

      // Clean up the test OTP if it was created successfully
      if (response['ok'] == true && response['otp'] != null) {
        final otpData = response['otp'] as Map<String, dynamic>;
        final testOtpId = otpData['id_otp'] as String?;

        if (testOtpId != null) {
          debugPrint('🧹 OtpService: Cleaning up test OTP: $testOtpId');
          try {
            await EdgeFunctionService.invokeFunction(
              _functionName,
              {
                'id_otp': testOtpId,
                'id_user': currentUser.id,
              },
            );
            debugPrint('✅ OtpService: Test OTP cleaned up successfully');
          } catch (e) {
            debugPrint('⚠️ OtpService: Failed to clean up test OTP: $e');
          }
        }
      }

      return EdgeFunctionResponse<bool>(
        success: true,
        data: true,
        message: 'Edge Function accessible',
      );
    } catch (e) {
      debugPrint('❌ OtpService: Edge Function test failed: $e');
      return EdgeFunctionResponse<bool>(
        success: false,
        error: 'Edge Function test failed: $e',
      );
    }
  }

  /// Update OTP tag
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

      // The function returns { ok: true, otp: {...} }
      final bool isSuccess = response['ok'] == true;

      if (isSuccess && response['otp'] != null) {
        final otpData = response['otp'] as Map<String, dynamic>;
        final otp = OtpModel.fromJson(otpData);

        debugPrint('✅ OtpService: OTP tag updated successfully');

        return EdgeFunctionResponse<OtpModel>(
          success: true,
          data: otp,
          message: 'OTP tag updated successfully',
        );
      } else {
        debugPrint(
            '❌ OtpService: Update OTP tag failed - ok: ${response['ok']}, error: ${response['error']}');

        return EdgeFunctionResponse<OtpModel>(
          success: false,
          error: response['error'] as String? ?? 'Failed to update OTP tag',
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

      // First try with Edge Function
      try {
        final response = await EdgeFunctionService.invokeFunction(
          'get-legal-entity',
          {
            'id_legal_entity': idLegalEntity,
          },
        );

        debugPrint('🔄 OtpService: Get legal entity response: $response');

        // The function returns { ok: true, legal_entity: {...} }
        final bool isSuccess = response['ok'] == true;

        if (isSuccess && response['legal_entity'] != null) {
          final legalEntityData =
              response['legal_entity'] as Map<String, dynamic>;

          debugPrint(
              '✅ OtpService: Legal entity retrieved successfully via Edge Function');

          return EdgeFunctionResponse<Map<String, dynamic>>(
            success: true,
            data: legalEntityData,
            message: 'Legal entity retrieved successfully',
          );
        } else {
          debugPrint(
              '❌ OtpService: Get legal entity failed via Edge Function - ok: ${response['ok']}, error: ${response['error']}');
        }
      } catch (edgeFunctionError) {
        debugPrint(
            '⚠️ OtpService: Edge Function failed, trying direct database query: $edgeFunctionError');
      }

      // Fallback: Direct database query using Supabase client
      try {
        debugPrint(
            '🔄 OtpService: Trying direct database query for legal entity');

        final response = await SupabaseConfig.client
            .from('legal_entity')
            .select('*')
            .eq('id_legal_entity', idLegalEntity)
            .single();

        debugPrint(
            '✅ OtpService: Legal entity retrieved successfully via direct query');
        debugPrint('📊 Legal entity data: $response');

        return EdgeFunctionResponse<Map<String, dynamic>>(
          success: true,
          data: response,
          message: 'Legal entity retrieved successfully',
        );
      } catch (dbError) {
        debugPrint('❌ OtpService: Direct database query failed: $dbError');
        return EdgeFunctionResponse<Map<String, dynamic>>(
          success: false,
          error: 'Failed to get legal entity: $dbError',
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

  /// Test if id_legal_entity column exists in OTP table
  /// This is a diagnostic method to verify database schema
  static Future<bool> testLegalEntityColumn() async {
    try {
      debugPrint('🔍 Testing if id_legal_entity column exists in OTP table');

      // Try to select id_legal_entity from a sample OTP
      final response = await SupabaseConfig.client
          .from('otp')
          .select('id_legal_entity')
          .limit(1);

      debugPrint('✅ id_legal_entity column exists in OTP table');
      return true;
    } catch (e) {
      debugPrint('❌ id_legal_entity column does not exist in OTP table: $e');
      return false;
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
