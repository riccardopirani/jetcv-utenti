/// Certification information value model representing the certification_information_value table
class CertificationInformationValueModel {
  final int idCertificationInformationValue;
  final String idCertificationInformation;
  final String? value;
  final DateTime createdAt;
  final DateTime? updatedAt;

  CertificationInformationValueModel({
    required this.idCertificationInformationValue,
    required this.idCertificationInformation,
    this.value,
    required this.createdAt,
    this.updatedAt,
  });

  /// Create CertificationInformationValueModel from JSON/Map
  factory CertificationInformationValueModel.fromJson(
          Map<String, dynamic> json) =>
      CertificationInformationValueModel(
        idCertificationInformationValue:
            json['id_certification_information_value'] as int,
        idCertificationInformation:
            json['id_certification_information'] as String,
        value: json['value'] as String?,
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'])
            : null,
      );

  /// Convert CertificationInformationValueModel to JSON/Map
  Map<String, dynamic> toJson() => {
        'id_certification_information_value': idCertificationInformationValue,
        'id_certification_information': idCertificationInformation,
        'value': value,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };

  /// Create copy with updated fields
  CertificationInformationValueModel copyWith({
    String? value,
    DateTime? updatedAt,
  }) =>
      CertificationInformationValueModel(
        idCertificationInformationValue: idCertificationInformationValue,
        idCertificationInformation: idCertificationInformation,
        value: value ?? this.value,
        createdAt: createdAt,
        updatedAt: updatedAt ?? DateTime.now(),
      );

  @override
  String toString() =>
      'CertificationInformationValueModel(idCertificationInformationValue: $idCertificationInformationValue, value: $value)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CertificationInformationValueModel &&
          runtimeType == other.runtimeType &&
          idCertificationInformationValue ==
              other.idCertificationInformationValue;

  @override
  int get hashCode => idCertificationInformationValue.hashCode;
}

