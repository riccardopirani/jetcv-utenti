import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jetcv__utenti/supabase/supabase_config.dart';
import 'package:functions_client/functions_client.dart';

/// Helper function to safely parse DateTime from JSON
DateTime parseDateTime(dynamic dateValue) {
  if (dateValue == null) {
    throw ArgumentError(
        'Date value cannot be null - this indicates a data integrity issue');
  }

  if (dateValue is DateTime) {
    return dateValue;
  }

  if (dateValue is String) {
    if (dateValue.isEmpty) {
      throw ArgumentError('Date string cannot be empty');
    }
    try {
      return DateTime.parse(dateValue);
    } catch (e) {
      throw ArgumentError('Invalid date format: $dateValue - $e');
    }
  }

  throw ArgumentError(
      'Invalid date format: $dateValue (type: ${dateValue.runtimeType})');
}

class CertificationService {
  static final SupabaseClient _client = SupabaseConfig.client;

  /// Calls the list-user-certifications-details edge function
  /// Returns all certifications for the authenticated user with expanded details
  static Future<CertificationResponse> getUserCertificationsDetails() async {
    try {
      // Get the current session
      final session = _client.auth.currentSession;
      if (session == null) {
        return CertificationResponse(
          success: false,
          error: 'User not authenticated',
          data: null,
        );
      }

      // Call the edge function with GET method
      final response = await _client.functions.invoke(
        'list-user-certifications-details',
        method: HttpMethod.get,
        headers: {
          'Authorization': 'Bearer ${session.accessToken}',
        },
      );

      if (response.status == 200) {
        final responseData = response.data as Map<String, dynamic>;

        // Parse the response data
        final List<dynamic> certificationsData = responseData['data'] ?? [];
        final List<String> warnings =
            (responseData['warnings'] as List<dynamic>?)?.cast<String>() ?? [];

        final certifications = certificationsData.map((item) {
          try {
            return UserCertificationDetail.fromJson(item);
          } catch (e) {
            print('Error parsing certification item: $e');
            print('Item data: $item');
            rethrow;
          }
        }).toList();

        return CertificationResponse(
          success: true,
          data: certifications,
          warnings: warnings,
        );
      } else {
        final errorData = response.data as Map<String, dynamic>?;
        return CertificationResponse(
          success: false,
          error: errorData?['error'] ?? 'Failed to fetch certifications',
          data: null,
        );
      }
    } catch (e) {
      return CertificationResponse(
        success: false,
        error: 'Error calling certifications service: $e',
        data: null,
      );
    }
  }
}

class CertificationResponse {
  final bool success;
  final String? error;
  final List<UserCertificationDetail>? data;
  final List<String> warnings;

  CertificationResponse({
    required this.success,
    this.error,
    this.data,
    this.warnings = const [],
  });
}

class UserCertificationDetail {
  final CertificationUser certificationUser;
  final Certification? certification;
  final CertificationMedia media;

  UserCertificationDetail({
    required this.certificationUser,
    this.certification,
    required this.media,
  });

  factory UserCertificationDetail.fromJson(Map<String, dynamic> json) {
    return UserCertificationDetail(
      certificationUser: CertificationUser.fromJson(json['certification_user']),
      certification: json['certification'] != null
          ? Certification.fromJson(json['certification'])
          : null,
      media: CertificationMedia.fromJson(json['media']),
    );
  }
}

class CertificationUser {
  final String idCertificationUser;
  final String idCertification;
  final String idUser;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? serialNumber;
  final String? rejectionReason;
  final String? idOtp;

  CertificationUser({
    required this.idCertificationUser,
    required this.idCertification,
    required this.idUser,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.serialNumber,
    this.rejectionReason,
    this.idOtp,
  });

  factory CertificationUser.fromJson(Map<String, dynamic> json) {
    return CertificationUser(
      idCertificationUser: json['id_certification_user']?.toString() ?? '',
      idCertification: json['id_certification']?.toString() ?? '',
      idUser: json['id_user']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      createdAt: parseDateTime(json['created_at']),
      updatedAt:
          json['updated_at'] != null ? parseDateTime(json['updated_at']) : null,
      serialNumber: json['serial_number']?.toString(),
      rejectionReason: json['rejection_reason']?.toString(),
      idOtp: json['id_otp']?.toString(),
    );
  }
}

class Certification {
  final String idCertification;
  final String? idCertifier;
  final String? idLegalEntity;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? serialNumber;
  final String? idLocation;
  final int? nUsers;
  final DateTime? sentAt;
  final DateTime? draftAt;
  final DateTime? closedAt;
  final String? idCertificationCategory;
  final CertificationCategory? category;
  final List<CategoryInformation> categoryInformation;

  Certification({
    required this.idCertification,
    this.idCertifier,
    this.idLegalEntity,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.serialNumber,
    this.idLocation,
    this.nUsers,
    this.sentAt,
    this.draftAt,
    this.closedAt,
    this.idCertificationCategory,
    this.category,
    this.categoryInformation = const [],
  });

  factory Certification.fromJson(Map<String, dynamic> json) {
    return Certification(
      idCertification: json['id_certification']?.toString() ?? '',
      idCertifier: json['id_certifier']?.toString(),
      idLegalEntity: json['id_legal_entity']?.toString(),
      status: json['status']?.toString() ?? '',
      createdAt: parseDateTime(json['created_at']),
      updatedAt:
          json['updated_at'] != null ? parseDateTime(json['updated_at']) : null,
      serialNumber: json['serial_number']?.toString(),
      idLocation: json['id_location']?.toString(),
      nUsers: json['n_users'] is int
          ? json['n_users']
          : int.tryParse(json['n_users']?.toString() ?? ''),
      sentAt: json['sent_at'] != null ? parseDateTime(json['sent_at']) : null,
      draftAt:
          json['draft_at'] != null ? parseDateTime(json['draft_at']) : null,
      closedAt:
          json['closed_at'] != null ? parseDateTime(json['closed_at']) : null,
      idCertificationCategory: json['id_certification_category']?.toString(),
      category: json['category'] != null
          ? CertificationCategory.fromJson(json['category'])
          : null,
      categoryInformation: (json['category_information'] as List<dynamic>?)
              ?.map((item) => CategoryInformation.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class CertificationCategory {
  final String idCertificationCategory;
  final String name;
  final String? type;
  final int? order;
  final String? idLegalEntity;
  final DateTime createdAt;
  final DateTime? updatedAt;

  CertificationCategory({
    required this.idCertificationCategory,
    required this.name,
    this.type,
    this.order,
    this.idLegalEntity,
    required this.createdAt,
    this.updatedAt,
  });

  factory CertificationCategory.fromJson(Map<String, dynamic> json) {
    return CertificationCategory(
      idCertificationCategory:
          json['id_certification_category']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString(),
      order: json['order'] is int
          ? json['order']
          : int.tryParse(json['order']?.toString() ?? ''),
      idLegalEntity: json['id_legal_entity']?.toString(),
      createdAt: parseDateTime(json['created_at']),
      updatedAt:
          json['updated_at'] != null ? parseDateTime(json['updated_at']) : null,
    );
  }
}

class CategoryInformation {
  final CertificationInformation? info;
  final List<CertificationInformationValue> values;

  CategoryInformation({
    this.info,
    this.values = const [],
  });

  factory CategoryInformation.fromJson(Map<String, dynamic> json) {
    return CategoryInformation(
      info: json['info'] != null
          ? CertificationInformation.fromJson(json['info'])
          : null,
      values: (json['values'] as List<dynamic>?)
              ?.map((item) => CertificationInformationValue.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class CertificationInformation {
  final String idCertificationInformation;
  final String name;
  final String? label;
  final String? type;
  final String? scope;
  final int? order;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? idLegalEntity;

  CertificationInformation({
    required this.idCertificationInformation,
    required this.name,
    this.label,
    this.type,
    this.scope,
    this.order,
    required this.createdAt,
    this.updatedAt,
    this.idLegalEntity,
  });

  factory CertificationInformation.fromJson(Map<String, dynamic> json) {
    return CertificationInformation(
      idCertificationInformation:
          json['id_certification_information']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      label: json['label']?.toString(),
      type: json['type']?.toString(),
      scope: json['scope']?.toString(),
      order: json['order'] is int
          ? json['order']
          : int.tryParse(json['order']?.toString() ?? ''),
      createdAt: parseDateTime(json['created_at']),
      updatedAt:
          json['updated_at'] != null ? parseDateTime(json['updated_at']) : null,
      idLegalEntity: json['id_legal_entity']?.toString(),
    );
  }
}

class CertificationInformationValue {
  final String idCertificationInformationValue;
  final String idCertificationInformation;
  final String value;
  final DateTime createdAt;
  final DateTime? updatedAt;

  CertificationInformationValue({
    required this.idCertificationInformationValue,
    required this.idCertificationInformation,
    required this.value,
    required this.createdAt,
    this.updatedAt,
  });

  factory CertificationInformationValue.fromJson(Map<String, dynamic> json) {
    return CertificationInformationValue(
      idCertificationInformationValue:
          json['id_certification_information_value']?.toString() ?? '',
      idCertificationInformation:
          json['id_certification_information']?.toString() ?? '',
      value: json['value']?.toString() ?? '',
      createdAt: parseDateTime(json['created_at']),
      updatedAt:
          json['updated_at'] != null ? parseDateTime(json['updated_at']) : null,
    );
  }
}

class CertificationMedia {
  final List<CertificationMediaItem> directMedia;
  final List<LinkedMediaItem> linkedMedia;

  CertificationMedia({
    this.directMedia = const [],
    this.linkedMedia = const [],
  });

  factory CertificationMedia.fromJson(Map<String, dynamic> json) {
    return CertificationMedia(
      directMedia: (json['direct_media'] as List<dynamic>?)
              ?.map((item) => CertificationMediaItem.fromJson(item))
              .toList() ??
          [],
      linkedMedia: (json['linked_media'] as List<dynamic>?)
              ?.map((item) => LinkedMediaItem.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class CertificationMediaItem {
  final String idCertificationMedia;
  final String? idMediaHash;
  final String? idCertification;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? name;
  final String? description;
  final String? acquisitionType;
  final DateTime? capturedAt;
  final String? idLocation;
  final String? fileType;

  CertificationMediaItem({
    required this.idCertificationMedia,
    this.idMediaHash,
    this.idCertification,
    required this.createdAt,
    this.updatedAt,
    this.name,
    this.description,
    this.acquisitionType,
    this.capturedAt,
    this.idLocation,
    this.fileType,
  });

  factory CertificationMediaItem.fromJson(Map<String, dynamic> json) {
    return CertificationMediaItem(
      idCertificationMedia: json['id_certification_media']?.toString() ?? '',
      idMediaHash: json['id_media_hash']?.toString(),
      idCertification: json['id_certification']?.toString(),
      createdAt: parseDateTime(json['created_at']),
      updatedAt:
          json['updated_at'] != null ? parseDateTime(json['updated_at']) : null,
      name: json['name']?.toString(),
      description: json['description']?.toString(),
      acquisitionType: json['acquisition_type']?.toString(),
      capturedAt: json['captured_at'] != null
          ? parseDateTime(json['captured_at'])
          : null,
      idLocation: json['id_location']?.toString(),
      fileType: json['file_type']?.toString(),
    );
  }
}

class LinkedMediaItem {
  final Map<String, dynamic> link;
  final CertificationMediaItem? media;

  LinkedMediaItem({
    required this.link,
    this.media,
  });

  factory LinkedMediaItem.fromJson(Map<String, dynamic> json) {
    return LinkedMediaItem(
      link: json['link'] as Map<String, dynamic>,
      media: json['media'] != null
          ? CertificationMediaItem.fromJson(json['media'])
          : null,
    );
  }
}
