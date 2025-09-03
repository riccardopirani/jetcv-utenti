import 'package:flutter/foundation.dart';
import 'package:jetcv__utenti/supabase/supabase_config.dart';

/// Service to test OTP function connectivity
class OtpTestService {
  /// Test basic connectivity to the OTP function
  static Future<Map<String, dynamic>> testConnectivity() async {
    try {
      debugPrint(
          '🧪 OtpTestService: Testing connectivity to otp-crud function');

      // Test with minimal payload
      final response = await SupabaseConfig.client.functions.invoke(
        'otp-crud',
        body: {
          'test': true,
        },
      );

      debugPrint('🧪 OtpTestService: Response status: ${response.status}');
      debugPrint('🧪 OtpTestService: Response data: ${response.data}');

      return {
        'success': true,
        'status': response.status,
        'data': response.data,
        'message': 'Function is reachable',
      };
    } catch (e) {
      debugPrint('🧪 OtpTestService: Connectivity test failed: $e');
      debugPrint('🧪 OtpTestService: Error type: ${e.runtimeType}');

      return {
        'success': false,
        'error': e.toString(),
        'message': 'Function is not reachable',
      };
    }
  }

  /// Test OTP creation with minimal parameters
  static Future<Map<String, dynamic>> testCreateOtp() async {
    try {
      debugPrint('🧪 OtpTestService: Testing OTP creation');

      final session = SupabaseConfig.client.auth.currentSession;
      final userId = session?.user.id;

      final response = await SupabaseConfig.client.functions.invoke(
        'otp-crud',
        body: {
          'id_user': userId,
          'tag': 'test',
          'ttl_seconds': 60,
          'length': 4,
          'numeric_only': true,
        },
      );

      debugPrint(
          '🧪 OtpTestService: Create OTP response status: ${response.status}');
      debugPrint(
          '🧪 OtpTestService: Create OTP response data: ${response.data}');

      return {
        'success': response.status == 200,
        'status': response.status,
        'data': response.data,
        'message': response.status == 200
            ? 'OTP creation test successful'
            : 'OTP creation test failed',
      };
    } catch (e) {
      debugPrint('🧪 OtpTestService: OTP creation test failed: $e');

      return {
        'success': false,
        'error': e.toString(),
        'message': 'OTP creation test failed',
      };
    }
  }

  /// Test OTP verification
  static Future<Map<String, dynamic>> testVerifyOtp(String code) async {
    try {
      debugPrint(
          '🧪 OtpTestService: Testing OTP verification with code: $code');

      final session = SupabaseConfig.client.auth.currentSession;
      final userId = session?.user.id;

      final response = await SupabaseConfig.client.functions.invoke(
        'otp-crud',
        body: {
          'code': code,
          'id_user': userId,
          'mark_used': false, // Don't mark as used for testing
        },
      );

      debugPrint(
          '🧪 OtpTestService: Verify OTP response status: ${response.status}');
      debugPrint(
          '🧪 OtpTestService: Verify OTP response data: ${response.data}');

      return {
        'success': response.status == 200,
        'status': response.status,
        'data': response.data,
        'message': response.status == 200
            ? 'OTP verification test successful'
            : 'OTP verification test failed',
      };
    } catch (e) {
      debugPrint('🧪 OtpTestService: OTP verification test failed: $e');

      return {
        'success': false,
        'error': e.toString(),
        'message': 'OTP verification test failed',
      };
    }
  }

  /// Run comprehensive connectivity tests
  static Future<Map<String, dynamic>> runAllTests() async {
    debugPrint('🧪 OtpTestService: Running comprehensive connectivity tests');

    final results = <String, dynamic>{};

    // Test 1: Basic connectivity
    results['connectivity'] = await testConnectivity();

    // Test 2: OTP creation (only if connectivity is successful)
    if (results['connectivity']['success']) {
      results['createOtp'] = await testCreateOtp();
    } else {
      results['createOtp'] = {
        'success': false,
        'message': 'Skipped due to connectivity failure',
      };
    }

    // Test 3: Check authentication
    final session = SupabaseConfig.client.auth.currentSession;
    results['authentication'] = {
      'success': session != null,
      'userId': session?.user.id,
      'message': session != null
          ? 'User is authenticated'
          : 'User is not authenticated',
    };

    // Overall result
    final allSuccessful =
        results.values.every((test) => test['success'] == true);
    results['overall'] = {
      'success': allSuccessful,
      'message': allSuccessful ? 'All tests passed' : 'Some tests failed',
    };

    debugPrint('🧪 OtpTestService: Test results: $results');

    return results;
  }
}
