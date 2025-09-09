import 'package:jetcv__utenti/supabase/structure/enumerated_types.dart';

/// Certification category model representing the certification_category table
class CertificationCategoryModel {
  final String idCertificationCategory;
  final String name;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final CertificationCategoryType type;
  final int? order;
  final String? idLegalEntity;

  CertificationCategoryModel({
    required this.idCertificationCategory,
    required this.name,
    required this.createdAt,
    this.updatedAt,
    required this.type,
    this.order,
    this.idLegalEntity,
  });

  /// Create CertificationCategoryModel from JSON/Map
  factory CertificationCategoryModel.fromJson(Map<String, dynamic> json) =>
      CertificationCategoryModel(
        idCertificationCategory: json['id_certification_category'] as String,
        name: json['name'] as String,
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'])
            : null,
        type: CertificationCategoryType.fromString(json['type']),
        order: json['order'] as int?,
        idLegalEntity: json['id_legal_entity'] as String?,
      );

  /// Convert CertificationCategoryModel to JSON/Map
  Map<String, dynamic> toJson() => {
        'id_certification_category': idCertificationCategory,
        'name': name,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'type': type.toDbString(),
        'order': order,
        'id_legal_entity': idLegalEntity,
      };

  /// Create copy with updated fields
  CertificationCategoryModel copyWith({
    String? name,
    DateTime? updatedAt,
    CertificationCategoryType? type,
    int? order,
    String? idLegalEntity,
  }) =>
      CertificationCategoryModel(
        idCertificationCategory: idCertificationCategory,
        name: name ?? this.name,
        createdAt: createdAt,
        updatedAt: updatedAt ?? DateTime.now(),
        type: type ?? this.type,
        order: order ?? this.order,
        idLegalEntity: idLegalEntity ?? this.idLegalEntity,
      );

  @override
  String toString() =>
      'CertificationCategoryModel(idCertificationCategory: $idCertificationCategory, name: $name, type: $type)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CertificationCategoryModel &&
          runtimeType == other.runtimeType &&
          idCertificationCategory == other.idCertificationCategory;

  @override
  int get hashCode => idCertificationCategory.hashCode;
}



