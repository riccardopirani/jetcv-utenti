import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:jetcv__utenti/models/models.dart';
import 'package:jetcv__utenti/supabase/supabase_config.dart';
import 'package:jetcv__utenti/services/edge_function_service.dart';

/// Service for OpenBadge operations
class OpenBadgeService {
  /// Get all OpenBadges for a user
  static Future<EdgeFunctionResponse<List<OpenBadgeModel>>> getUserOpenBadges(
      String userId) async {
    try {
      debugPrint('🏆 OpenBadgeService: Getting OpenBadges for user: $userId');

      final response = await SupabaseConfig.client
          .from('openbadge')
          .select('*')
          .eq('id_user', userId)
          .order('created_at', ascending: false);

      debugPrint('📋 OpenBadgeService: Response length: ${response.length}');

      final List<OpenBadgeModel> openBadges = [];
      for (final badgeData in response) {
        try {
          final openBadge = OpenBadgeModel.fromJson(badgeData);
          openBadges.add(openBadge);

          debugPrint(
              '📋 OpenBadgeService: Processed badge: ${openBadge.badgeName}');
          debugPrint('📋 OpenBadgeService: Issuer: ${openBadge.issuerName}');
          debugPrint('📋 OpenBadgeService: Valid: ${openBadge.isValid}');
        } catch (e) {
          debugPrint('❌ OpenBadgeService: Error parsing OpenBadge: $e');
        }
      }

      debugPrint(
          '✅ OpenBadgeService: Retrieved ${openBadges.length} OpenBadges successfully');

      return EdgeFunctionResponse<List<OpenBadgeModel>>(
        success: true,
        data: openBadges,
        message: 'OpenBadges retrieved successfully',
      );
    } catch (e) {
      debugPrint('❌ OpenBadgeService: Error getting user OpenBadges: $e');
      return EdgeFunctionResponse<List<OpenBadgeModel>>(
        success: false,
        error: 'Failed to get OpenBadges: $e',
      );
    }
  }

  /// Import OpenBadge from JSON
  static Future<EdgeFunctionResponse<OpenBadgeModel>> importOpenBadge({
    required String userId,
    required Map<String, dynamic> assertionJson,
    String? source,
    String? note,
  }) async {
    try {
      debugPrint('🏆 OpenBadgeService: Importing OpenBadge for user: $userId');
      debugPrint(
          '🏆 OpenBadgeService: Assertion JSON keys: ${assertionJson.keys.toList()}');

      // Validate assertion JSON structure
      if (!assertionJson.containsKey('@context') ||
          !assertionJson.containsKey('type')) {
        return EdgeFunctionResponse<OpenBadgeModel>(
          success: false,
          error: 'Invalid OpenBadge assertion: missing required fields',
        );
      }

      // Extract badge information
      final assertionId = assertionJson['id'] as String?;
      final badgeClassId = assertionJson['badge']?['id'] as String?;
      final issuerId = assertionJson['badge']?['issuer']?['id'] as String?;

      // Parse dates
      DateTime? issuedAt;
      DateTime? expiresAt;

      if (assertionJson['issuedOn'] != null) {
        try {
          issuedAt = DateTime.parse(assertionJson['issuedOn'] as String);
        } catch (e) {
          debugPrint('⚠️ OpenBadgeService: Error parsing issuedOn: $e');
        }
      }

      if (assertionJson['expires'] != null) {
        try {
          expiresAt = DateTime.parse(assertionJson['expires'] as String);
        } catch (e) {
          debugPrint('⚠️ OpenBadgeService: Error parsing expires: $e');
        }
      }

      // Insert OpenBadge into database
      final response = await SupabaseConfig.client
          .from('openbadge')
          .insert({
            'id_user': userId,
            'assertion_json': assertionJson,
            'assertion_id': assertionId,
            'badge_class_id': badgeClassId,
            'issuer_id': issuerId,
            'issued_at': issuedAt?.toIso8601String(),
            'expires_at': expiresAt?.toIso8601String(),
            'source': source,
            'note': note,
          })
          .select()
          .single();

      final openBadge = OpenBadgeModel.fromJson(response);

      debugPrint('✅ OpenBadgeService: OpenBadge imported successfully');
      debugPrint('📋 OpenBadgeService: Badge name: ${openBadge.badgeName}');
      debugPrint('📋 OpenBadgeService: Issuer: ${openBadge.issuerName}');

      return EdgeFunctionResponse<OpenBadgeModel>(
        success: true,
        data: openBadge,
        message: 'OpenBadge imported successfully',
      );
    } catch (e) {
      debugPrint('❌ OpenBadgeService: Error importing OpenBadge: $e');
      return EdgeFunctionResponse<OpenBadgeModel>(
        success: false,
        error: 'Failed to import OpenBadge: $e',
      );
    }
  }

  /// Delete OpenBadge
  static Future<EdgeFunctionResponse<bool>> deleteOpenBadge(
      String openBadgeId) async {
    try {
      debugPrint('🏆 OpenBadgeService: Deleting OpenBadge: $openBadgeId');

      await SupabaseConfig.client
          .from('openbadge')
          .delete()
          .eq('id_openbadge', openBadgeId);

      debugPrint('✅ OpenBadgeService: OpenBadge deleted successfully');

      return EdgeFunctionResponse<bool>(
        success: true,
        data: true,
        message: 'OpenBadge deleted successfully',
      );
    } catch (e) {
      debugPrint('❌ OpenBadgeService: Error deleting OpenBadge: $e');
      return EdgeFunctionResponse<bool>(
        success: false,
        error: 'Failed to delete OpenBadge: $e',
      );
    }
  }

  /// Update OpenBadge note
  static Future<EdgeFunctionResponse<OpenBadgeModel>> updateOpenBadgeNote({
    required String openBadgeId,
    required String note,
  }) async {
    try {
      debugPrint('🏆 OpenBadgeService: Updating OpenBadge note: $openBadgeId');

      final response = await SupabaseConfig.client
          .from('openbadge')
          .update({'note': note})
          .eq('id_openbadge', openBadgeId)
          .select()
          .single();

      final openBadge = OpenBadgeModel.fromJson(response);

      debugPrint('✅ OpenBadgeService: OpenBadge note updated successfully');

      return EdgeFunctionResponse<OpenBadgeModel>(
        success: true,
        data: openBadge,
        message: 'OpenBadge note updated successfully',
      );
    } catch (e) {
      debugPrint('❌ OpenBadgeService: Error updating OpenBadge note: $e');
      return EdgeFunctionResponse<OpenBadgeModel>(
        success: false,
        error: 'Failed to update OpenBadge note: $e',
      );
    }
  }

  /// Validate OpenBadge JSON structure
  static bool validateOpenBadgeJson(Map<String, dynamic> json) {
    try {
      // Check required fields
      if (!json.containsKey('@context') || !json.containsKey('type')) {
        return false;
      }

      // Check type is Assertion
      final type = json['type'];
      if (type is String) {
        return type == 'Assertion';
      } else if (type is List) {
        return type.contains('Assertion');
      }

      return false;
    } catch (e) {
      debugPrint('❌ OpenBadgeService: Error validating OpenBadge JSON: $e');
      return false;
    }
  }

  /// Parse OpenBadge from file content
  static Future<EdgeFunctionResponse<Map<String, dynamic>>>
      parseOpenBadgeFromFile(String fileContent) async {
    try {
      debugPrint('🏆 OpenBadgeService: Parsing OpenBadge from file content');

      final Map<String, dynamic> assertionJson = json.decode(fileContent);

      if (!validateOpenBadgeJson(assertionJson)) {
        return EdgeFunctionResponse<Map<String, dynamic>>(
          success: false,
          error: 'Invalid OpenBadge JSON structure',
        );
      }

      debugPrint('✅ OpenBadgeService: OpenBadge JSON parsed successfully');

      return EdgeFunctionResponse<Map<String, dynamic>>(
        success: true,
        data: assertionJson,
        message: 'OpenBadge JSON parsed successfully',
      );
    } catch (e) {
      debugPrint('❌ OpenBadgeService: Error parsing OpenBadge from file: $e');
      return EdgeFunctionResponse<Map<String, dynamic>>(
        success: false,
        error: 'Failed to parse OpenBadge JSON: $e',
      );
    }
  }

  /// Create OpenBadge for certification (placeholder method)
  static Future<EdgeFunctionResponse<OpenBadgeModel>>
      createBadgeForCertification({
    required dynamic certification,
    required String recipientEmail,
    required String recipientName,
  }) async {
    try {
      debugPrint('🏆 OpenBadgeService: Creating OpenBadge for certification');

      // This is a placeholder implementation
      // In a real implementation, you would create an OpenBadge assertion
      // based on the certification data

      return EdgeFunctionResponse<OpenBadgeModel>(
        success: false,
        error: 'OpenBadge creation not yet implemented',
      );
    } catch (e) {
      debugPrint('❌ OpenBadgeService: Error creating OpenBadge: $e');
      return EdgeFunctionResponse<OpenBadgeModel>(
        success: false,
        error: 'Failed to create OpenBadge: $e',
      );
    }
  }

  /// Share OpenBadge (placeholder method)
  static Future<void> shareBadge({
    required OpenBadgeModel badge,
    required String message,
  }) async {
    try {
      debugPrint('🏆 OpenBadgeService: Sharing OpenBadge');

      // This is a placeholder implementation
      // In a real implementation, you would share the badge
      // using the platform's sharing mechanism

      debugPrint('✅ OpenBadgeService: OpenBadge sharing not yet implemented');
    } catch (e) {
      debugPrint('❌ OpenBadgeService: Error sharing OpenBadge: $e');
    }
  }
}
