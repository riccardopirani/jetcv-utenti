import 'package:flutter/foundation.dart';
import 'package:jetcv__utenti/models/models.dart';
import 'package:jetcv__utenti/services/edge_function_service.dart';

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
