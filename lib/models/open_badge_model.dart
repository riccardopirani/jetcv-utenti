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
      return assertionJson['badge']?['name'] as String? ??
          assertionJson['name'] as String? ??
          'Unknown Badge';
    } catch (e) {
      debugPrint('Error getting badge name: $e');
      return 'Unknown Badge';
    }
  }

  /// Get badge description from assertion JSON
  String get badgeDescription {
    try {
      return assertionJson['badge']?['description'] as String? ??
          assertionJson['description'] as String? ??
          'No description available';
    } catch (e) {
      debugPrint('Error getting badge description: $e');
      return 'No description available';
    }
  }

  /// Get badge image URL from assertion JSON
  String? get badgeImageUrl {
    try {
      return assertionJson['badge']?['image'] as String? ??
          assertionJson['image'] as String?;
    } catch (e) {
      debugPrint('Error getting badge image URL: $e');
      return null;
    }
  }

  /// Get issuer name from assertion JSON
  String get issuerName {
    try {
      return assertionJson['badge']?['issuer']?['name'] as String? ??
          assertionJson['issuer']?['name'] as String? ??
          'Unknown Issuer';
    } catch (e) {
      debugPrint('Error getting issuer name: $e');
      return 'Unknown Issuer';
    }
  }

  /// Get issuer URL from assertion JSON
  String? get issuerUrl {
    try {
      return assertionJson['badge']?['issuer']?['url'] as String? ??
          assertionJson['issuer']?['url'] as String?;
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
