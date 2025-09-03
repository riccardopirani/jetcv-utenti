import 'package:jetcv__utenti/supabase/structure/enumerated_types.dart';

/// Certification information model representing the certification_information table
class CertificationInformationModel {
  final String idCertificationInformation;
  final String name;
  final int? order;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String label;
  final CertificationInformationType? type;
  final String? idLegalEntity;
  final CertificationInformationScope? scope;

  CertificationInformationModel({
    required this.idCertificationInformation,
    required this.name,
    this.order,
    required this.createdAt,
    this.updatedAt,
    required this.label,
    this.type,
    this.idLegalEntity,
    this.scope,
  });

  /// Create CertificationInformationModel from JSON/Map
  factory CertificationInformationModel.fromJson(Map<String, dynamic> json) =>
      CertificationInformationModel(
        idCertificationInformation:
            json['id_certification_information'] as String,
        name: json['name'] as String,
        order: json['order'] as int?,
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'])
            : null,
        label: json['label'] as String,
        type: json['type'] != null
            ? CertificationInformationType.fromString(json['type'])
            : null,
        idLegalEntity: json['id_legal_entity'] as String?,
        scope: json['scope'] != null
            ? CertificationInformationScope.fromString(json['scope'])
            : null,
      );

  /// Convert CertificationInformationModel to JSON/Map
  Map<String, dynamic> toJson() => {
        'id_certification_information': idCertificationInformation,
        'name': name,
        'order': order,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'label': label,
        'type': type?.toDbString(),
        'id_legal_entity': idLegalEntity,
        'scope': scope?.toDbString(),
      };

  /// Create copy with updated fields
  CertificationInformationModel copyWith({
    String? name,
    int? order,
    DateTime? updatedAt,
    String? label,
    CertificationInformationType? type,
    String? idLegalEntity,
    CertificationInformationScope? scope,
  }) =>
      CertificationInformationModel(
        idCertificationInformation: idCertificationInformation,
        name: name ?? this.name,
        order: order ?? this.order,
        createdAt: createdAt,
        updatedAt: updatedAt ?? DateTime.now(),
        label: label ?? this.label,
        type: type ?? this.type,
        idLegalEntity: idLegalEntity ?? this.idLegalEntity,
        scope: scope ?? this.scope,
      );

  @override
  String toString() =>
      'CertificationInformationModel(idCertificationInformation: $idCertificationInformation, name: $name, label: $label)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CertificationInformationModel &&
          runtimeType == other.runtimeType &&
          idCertificationInformation == other.idCertificationInformation;

  @override
  int get hashCode => idCertificationInformation.hashCode;
}
