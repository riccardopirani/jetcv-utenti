/// Certification category has information model representing the certification_category_has_information table
class CertificationCategoryHasInformationModel {
  final String idCertificationCategoryHasInformation;
  final DateTime createdAt;
  final String idCertificationCategory;
  final String idCertificationInformation;

  CertificationCategoryHasInformationModel({
    required this.idCertificationCategoryHasInformation,
    required this.createdAt,
    required this.idCertificationCategory,
    required this.idCertificationInformation,
  });

  /// Create CertificationCategoryHasInformationModel from JSON/Map
  factory CertificationCategoryHasInformationModel.fromJson(
          Map<String, dynamic> json) =>
      CertificationCategoryHasInformationModel(
        idCertificationCategoryHasInformation:
            json['id_certification_category_has_information'] as String,
        createdAt: DateTime.parse(json['created_at']),
        idCertificationCategory: json['id_certification_category'] as String,
        idCertificationInformation:
            json['id_certification_information'] as String,
      );

  /// Convert CertificationCategoryHasInformationModel to JSON/Map
  Map<String, dynamic> toJson() => {
        'id_certification_category_has_information':
            idCertificationCategoryHasInformation,
        'created_at': createdAt.toIso8601String(),
        'id_certification_category': idCertificationCategory,
        'id_certification_information': idCertificationInformation,
      };

  @override
  String toString() =>
      'CertificationCategoryHasInformationModel(idCertificationCategoryHasInformation: $idCertificationCategoryHasInformation, idCertificationCategory: $idCertificationCategory, idCertificationInformation: $idCertificationInformation)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CertificationCategoryHasInformationModel &&
          runtimeType == other.runtimeType &&
          idCertificationCategoryHasInformation ==
              other.idCertificationCategoryHasInformation;

  @override
  int get hashCode => idCertificationCategoryHasInformation.hashCode;
}


