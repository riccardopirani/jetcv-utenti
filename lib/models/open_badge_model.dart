import 'package:flutter/foundation.dart';

/// Model for OpenBadge data
class OpenBadgeModel {
  final String idOpenBadge;
  final String idUser;
  final Map<String, dynamic> assertionJson;
  final String? assertionId;
  final String? badgeClassId;
  final String? issuerId;
  final bool isRevoked;
  final DateTime? revokedAt;
  final DateTime? issuedAt;
  final DateTime? expiresAt;
  final String? source;
  final String? note;
  final DateTime createdAt;
  final DateTime? updatedAt;

  OpenBadgeModel({
    required this.idOpenBadge,
    required this.idUser,
    required this.assertionJson,
    this.assertionId,
    this.badgeClassId,
    this.issuerId,
    this.isRevoked = false,
    this.revokedAt,
    this.issuedAt,
    this.expiresAt,
    this.source,
    this.note,
    required this.createdAt,
    this.updatedAt,
  });

  /// Create OpenBadgeModel from JSON
  factory OpenBadgeModel.fromJson(Map<String, dynamic> json) {
    return OpenBadgeModel(
      idOpenBadge: json['id_openbadge'] as String,
      idUser: json['id_user'] as String,
      assertionJson: Map<String, dynamic>.from(json['assertion_json'] as Map),
      assertionId: json['assertion_id'] as String?,
      badgeClassId: json['badge_class_id'] as String?,
      issuerId: json['issuer_id'] as String?,
      isRevoked: json['is_revoked'] as bool? ?? false,
      revokedAt: json['revoked_at'] != null
          ? DateTime.parse(json['revoked_at'] as String)
          : null,
      issuedAt: json['issued_at'] != null
          ? DateTime.parse(json['issued_at'] as String)
          : null,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
      source: json['source'] as String?,
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Convert OpenBadgeModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id_openbadge': idOpenBadge,
      'id_user': idUser,
      'assertion_json': assertionJson,
      'assertion_id': assertionId,
      'badge_class_id': badgeClassId,
      'issuer_id': issuerId,
      'is_revoked': isRevoked,
      'revoked_at': revokedAt?.toIso8601String(),
      'issued_at': issuedAt?.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
      'source': source,
      'note': note,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Create a copy of OpenBadgeModel with updated fields
  OpenBadgeModel copyWith({
    String? idOpenBadge,
    String? idUser,
    Map<String, dynamic>? assertionJson,
    String? assertionId,
    String? badgeClassId,
    String? issuerId,
    bool? isRevoked,
    DateTime? revokedAt,
    DateTime? issuedAt,
    DateTime? expiresAt,
    String? source,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OpenBadgeModel(
      idOpenBadge: idOpenBadge ?? this.idOpenBadge,
      idUser: idUser ?? this.idUser,
      assertionJson: assertionJson ?? this.assertionJson,
      assertionId: assertionId ?? this.assertionId,
      badgeClassId: badgeClassId ?? this.badgeClassId,
      issuerId: issuerId ?? this.issuerId,
      isRevoked: isRevoked ?? this.isRevoked,
      revokedAt: revokedAt ?? this.revokedAt,
      issuedAt: issuedAt ?? this.issuedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      source: source ?? this.source,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get badge name from assertion JSON
  String get badgeName {
    try {
      // Try to get name from badge object
      if (assertionJson['badge'] is Map<String, dynamic>) {
        final badge = assertionJson['badge'] as Map<String, dynamic>;
        if (badge['name'] is String) {
          return badge['name'] as String;
        }
      }
      
      // Try to get name from assertion directly
      if (assertionJson['name'] is String) {
        return assertionJson['name'] as String;
      }
      
      // If badge is a URL, extract name from URL or use a default
      if (assertionJson['badge'] is String) {
        final badgeUrl = assertionJson['badge'] as String;
        // Extract name from URL path (e.g., "robotics" from ".../robotics.json")
        final uri = Uri.tryParse(badgeUrl);
        if (uri != null) {
          final pathSegments = uri.pathSegments;
          if (pathSegments.isNotEmpty) {
            final lastSegment = pathSegments.last;
            if (lastSegment.endsWith('.json')) {
              return lastSegment.replaceAll('.json', '').replaceAll('-', ' ').replaceAll('_', ' ');
            }
            return lastSegment.replaceAll('-', ' ').replaceAll('_', ' ');
          }
        }
      }
      
      return 'Unknown Badge';
    } catch (e) {
      debugPrint('Error getting badge name: $e');
      return 'Unknown Badge';
    }
  }

  /// Get badge description from assertion JSON
  String get badgeDescription {
    try {
      // Try to get description from badge object
      if (assertionJson['badge'] is Map<String, dynamic>) {
        final badge = assertionJson['badge'] as Map<String, dynamic>;
        if (badge['description'] is String) {
          return badge['description'] as String;
        }
      }
      
      // Try to get description from assertion directly
      if (assertionJson['description'] is String) {
        return assertionJson['description'] as String;
      }
      
      // Try to get description from evidence
      if (assertionJson['evidence'] is List) {
        final evidence = assertionJson['evidence'] as List;
        if (evidence.isNotEmpty && evidence.first is Map<String, dynamic>) {
          final firstEvidence = evidence.first as Map<String, dynamic>;
          if (firstEvidence['narrative'] is String) {
            return firstEvidence['narrative'] as String;
          }
        }
      }
      
      return 'No description available';
    } catch (e) {
      debugPrint('Error getting badge description: $e');
      return 'No description available';
    }
  }

  /// Get badge image URL from assertion JSON
  String? get badgeImageUrl {
    try {
      // Try to get image from badge object
      if (assertionJson['badge'] is Map<String, dynamic>) {
        final badge = assertionJson['badge'] as Map<String, dynamic>;
        if (badge['image'] is String) {
          return badge['image'] as String;
        }
      }
      
      // Try to get image from assertion directly
      if (assertionJson['image'] is String) {
        return assertionJson['image'] as String;
      }
      
      return null;
    } catch (e) {
      debugPrint('Error getting badge image URL: $e');
      return null;
    }
  }

  /// Get issuer name from assertion JSON
  String get issuerName {
    try {
      // Try to get issuer from badge object
      if (assertionJson['badge'] is Map<String, dynamic>) {
        final badge = assertionJson['badge'] as Map<String, dynamic>;
        if (badge['issuer'] is Map<String, dynamic>) {
          final issuer = badge['issuer'] as Map<String, dynamic>;
          if (issuer['name'] is String) {
            return issuer['name'] as String;
          }
        }
      }
      
      // Try to get issuer from assertion directly
      if (assertionJson['issuer'] is Map<String, dynamic>) {
        final issuer = assertionJson['issuer'] as Map<String, dynamic>;
        if (issuer['name'] is String) {
          return issuer['name'] as String;
        }
      }
      
      return 'Unknown Issuer';
    } catch (e) {
      debugPrint('Error getting issuer name: $e');
      return 'Unknown Issuer';
    }
  }

  /// Get issuer URL from assertion JSON
  String? get issuerUrl {
    try {
      // Try to get issuer from badge object
      if (assertionJson['badge'] is Map<String, dynamic>) {
        final badge = assertionJson['badge'] as Map<String, dynamic>;
        if (badge['issuer'] is Map<String, dynamic>) {
          final issuer = badge['issuer'] as Map<String, dynamic>;
          if (issuer['url'] is String) {
            return issuer['url'] as String;
          }
        }
      }
      
      // Try to get issuer from assertion directly
      if (assertionJson['issuer'] is Map<String, dynamic>) {
        final issuer = assertionJson['issuer'] as Map<String, dynamic>;
        if (issuer['url'] is String) {
          return issuer['url'] as String;
        }
      }
      
      return null;
    } catch (e) {
      debugPrint('Error getting issuer URL: $e');
      return null;
    }
  }

  /// Check if badge is expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Check if badge is valid (not revoked and not expired)
  bool get isValid {
    return !isRevoked && !isExpired;
  }

  @override
  String toString() {
    return 'OpenBadgeModel(idOpenBadge: $idOpenBadge, badgeName: $badgeName, issuerName: $issuerName, isValid: $isValid)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OpenBadgeModel && other.idOpenBadge == idOpenBadge;
  }

  @override
  int get hashCode => idOpenBadge.hashCode;
}
