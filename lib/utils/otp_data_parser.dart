import 'dart:convert';
import 'package:jetcv__utenti/models/models.dart';

/// Utility class for parsing OTP API responses
class OtpDataParser {
  /// Parse curl response JSON data into List<OtpModel>
  ///
  /// Example usage:
  /// ```dart
  /// final jsonString = '{"data": [...], "count": 133, "limit": 50, "offset": 0}';
  /// final otps = OtpDataParser.parseFromApiResponse(jsonString);
  /// ```
  static List<OtpModel> parseFromApiResponse(String jsonString) {
    try {
      final Map<String, dynamic> response = json.decode(jsonString);
      return parseFromApiMap(response);
    } catch (e) {
      throw Exception('Failed to parse JSON: $e');
    }
  }

  /// Parse API response map for list endpoint into List<OtpModel>
  /// Expects: { data: [...], count: number, limit: number, offset: number }
  static List<OtpModel> parseFromApiMap(Map<String, dynamic> response) {
    try {
      // Check if the response has the expected structure
      if (!response.containsKey('data') || response['data'] is! List) {
        throw Exception(
            'Invalid response format: missing or invalid "data" field');
      }

      final List<dynamic> dataList = response['data'] as List<dynamic>;
      final List<OtpModel> otps = [];

      for (final item in dataList) {
        if (item is Map<String, dynamic>) {
          try {
            final otp = OtpModel.fromJson(item);
            otps.add(otp);
          } catch (e) {
            // Log the error but continue processing other items
            print('Error parsing OTP item: $e');
            print('Item data: $item');
          }
        }
      }

      return otps;
    } catch (e) {
      throw Exception('Failed to parse API response: $e');
    }
  }

  /// Parse single OTP creation response into OtpModel
  /// Expects: { data: {...} }
  static OtpModel parseFromCreateResponse(String jsonString) {
    try {
      final Map<String, dynamic> response = json.decode(jsonString);
      return parseFromCreateMap(response);
    } catch (e) {
      throw Exception('Failed to parse create response JSON: $e');
    }
  }

  /// Parse single OTP creation response map into OtpModel
  static OtpModel parseFromCreateMap(Map<String, dynamic> response) {
    try {
      // Check if the response has the expected structure
      if (!response.containsKey('data') ||
          response['data'] is! Map<String, dynamic>) {
        throw Exception(
            'Invalid create response format: missing or invalid "data" field');
      }

      final Map<String, dynamic> otpData =
          response['data'] as Map<String, dynamic>;
      return OtpModel.fromJson(otpData);
    } catch (e) {
      throw Exception('Failed to parse create response: $e');
    }
  }

  /// Parse a list of OTP data directly
  static List<OtpModel> parseFromList(List<dynamic> otpDataList) {
    final List<OtpModel> otps = [];

    for (final item in otpDataList) {
      if (item is Map<String, dynamic>) {
        try {
          final otp = OtpModel.fromJson(item);
          otps.add(otp);
        } catch (e) {
          // Log the error but continue processing other items
          print('Error parsing OTP item: $e');
          print('Item data: $item');
        }
      }
    }

    return otps;
  }

  /// Filter OTPs based on status
  static List<OtpModel> filterOtps(List<OtpModel> otps, String filter) {
    switch (filter.toLowerCase()) {
      case 'active':
        return otps.where((otp) => otp.isValid).toList();
      case 'blocked':
        return otps
            .where((otp) =>
                otp.usedByIdUser != null && otp.usedByIdUser != otp.idUser)
            .toList();
      case 'expired':
        return otps.where((otp) => otp.isExpired).toList();
      case 'used':
        return otps.where((otp) => otp.isUsed).toList();
      case 'burned':
        return otps.where((otp) => otp.isBurned).toList();
      case 'all':
      default:
        return otps;
    }
  }

  /// Get OTP statistics from a list
  static Map<String, int> getOtpStatistics(List<OtpModel> otps) {
    return {
      'total': otps.length,
      'active': otps.where((otp) => otp.isValid).length,
      'blocked': otps
          .where((otp) =>
              otp.usedByIdUser != null && otp.usedByIdUser != otp.idUser)
          .length,
      'expired': otps.where((otp) => otp.isExpired).length,
      'used': otps.where((otp) => otp.isUsed).length,
      'burned': otps.where((otp) => otp.isBurned).length,
    };
  }

  /// Sort OTPs by creation date (newest first by default)
  static List<OtpModel> sortByDate(List<OtpModel> otps,
      {bool newestFirst = true}) {
    final sortedOtps = List<OtpModel>.from(otps);
    sortedOtps.sort((a, b) {
      return newestFirst
          ? b.createdAt.compareTo(a.createdAt)
          : a.createdAt.compareTo(b.createdAt);
    });
    return sortedOtps;
  }

  /// Get a sample JSON string for testing (list format)
  static String getSampleJsonData() {
    return '''
{
    "data": [
        {
            "id_otp": "8857b7b3-3375-4a75-808a-debe0f2724af",
            "id_user": "d42f9e25-670c-4e96-9633-d9d4a855dbe8",
            "code": "908105",
            "code_hash": "74657bd8ce486777d302938e5d982ffaea466ac3b86bc52e114fa30629320c36",
            "tag": null,
            "created_at": "2025-09-07T07:40:49.869494+00:00",
            "updated_at": "2025-09-07T07:40:49.869494+00:00",
            "expires_at": "2025-09-07T07:45:49.869494+00:00",
            "used_at": null,
            "used_by_id_user": null,
            "burned_at": null,
            "id_legal_entity": null
        },
        {
            "id_otp": "b5763163-8ae8-41c3-ac05-aec1449f9bea",
            "id_user": "d42f9e25-670c-4e96-9633-d9d4a855dbe8",
            "code": "550505",
            "code_hash": "901ddfc1baaa3eab050409c60a745b0bd37bc1c53bf1348066ecc47e6920c4bc",
            "tag": "test-tag",
            "created_at": "2025-09-07T07:40:46.220404+00:00",
            "updated_at": "2025-09-07T07:40:46.220404+00:00",
            "expires_at": "2025-09-07T07:45:46.220404+00:00",
            "used_at": null,
            "used_by_id_user": null,
            "burned_at": null,
            "id_legal_entity": null
        }
    ],
    "count": 2,
    "limit": 50,
    "offset": 0
}''';
  }

  /// Get a sample create response JSON string for testing
  /// Note: This matches the actual API response format which doesn't include code_hash
  static String getSampleCreateResponse() {
    return '''
{
    "data": {
        "id_otp": "423c3b9f-f2a7-4833-9d4a-bac4691c1cbc",
        "id_user": "d42f9e25-670c-4e96-9633-d9d4a855dbe8",
        "tag": "dsds",
        "code": "024747",
        "expires_at": "2025-09-10T16:07:59.368+00:00",
        "created_at": "2025-09-10T15:07:59.674868+00:00",
        "updated_at": "2025-09-10T15:07:59.368+00:00",
        "id_legal_entity": null
    }
}''';
  }

  /// Test parsing the create response format
  static void testCreateResponseParsing() {
    try {
      final testJson = getSampleCreateResponse();
      final otp = parseFromCreateResponse(testJson);
      print('✅ Successfully parsed create response:');
      print('  - ID: ${otp.idOtp}');
      print('  - Code: ${otp.code}');
      print('  - Tag: ${otp.tag}');
      print('  - CodeHash: ${otp.codeHash ?? "null (as expected)"}');
      print('  - Valid: ${otp.isValid}');
    } catch (e) {
      print('❌ Failed to parse create response: $e');
    }
  }

  /// Get a sample update response JSON string for testing
  /// Note: This matches the actual API response format after updating tag
  static String getSampleUpdateResponse() {
    return '''
{
    "data": {
        "id_otp": "98cb826c-65b7-4c01-9e23-aeb38052c119",
        "id_user": "d42f9e25-670c-4e96-9633-d9d4a855dbe8",
        "tag": "testingnggg g44",
        "code": "103978",
        "expires_at": "2025-09-10T16:11:15.045+00:00",
        "created_at": "2025-09-10T15:11:15.329532+00:00",
        "updated_at": "2025-09-10T15:14:38.421+00:00",
        "id_legal_entity": null
    }
}''';
  }

  /// Test parsing the update response format
  static void testUpdateResponseParsing() {
    try {
      final testJson = getSampleUpdateResponse();
      final otp = parseFromCreateResponse(testJson); // Same format as create
      print('✅ Successfully parsed update response:');
      print('  - ID: ${otp.idOtp}');
      print('  - Code: ${otp.code}');
      print('  - Tag: ${otp.tag}');
      print('  - Updated: ${otp.updatedAt}');
      print('  - CodeHash: ${otp.codeHash ?? "null (as expected)"}');
    } catch (e) {
      print('❌ Failed to parse update response: $e');
    }
  }
}
