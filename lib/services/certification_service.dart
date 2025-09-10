import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jetcv__utenti/supabase/supabase_config.dart';
import 'package:jetcv__utenti/services/edge_function_service.dart';
import 'package:jetcv__utenti/models/certification_user_model.dart';
import 'package:jetcv__utenti/models/location_model.dart';
import 'package:jetcv__utenti/models/legal_entity_model.dart';
import 'package:jetcv__utenti/models/certification_media_model.dart';

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

  /// Recupera le informazioni del certificatore dai dati espansi della nuova API
  /// La nuova API include già i dati del certifier con il relativo user espanso
  static Future<CertifierInfo?> getCertifierInfo(String certifierId) async {
    try {
      // La nuova API list-user-certifications-details include già tutti i dati
      // del certifier espanso con il relativo user, quindi non serve più questa funzione
      return null; // Non più necessario fare query separate
    } catch (e) {
      debugPrint('Error in getCertifierInfo: $e');
      return null;
    }
  }

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

      // Call the edge function with explicit GET method
      final response = await _client.functions.invoke(
        'list-user-certifications-details',
        method: HttpMethod.get,
      );

      if (response.status == 200) {
        // Handle different response formats
        if (response.data is List) {
          // Direct list response
          final List<dynamic> certificationsData =
              response.data as List<dynamic>;

          final certifications = certificationsData.map((item) {
            try {
              // Debug: print the structure of first item to understand the API format
              if (certificationsData.indexOf(item) == 0) {
                debugPrint('🔍 First certification item structure:');
                debugPrint('🔍 Keys: ${(item as Map).keys.toList()}');
                if (item.containsKey('certification_user')) {
                  debugPrint(
                      '🔍 certification_user keys: ${(item['certification_user'] as Map?)?.keys.toList()}');
                }
              }

              return UserCertificationDetail.fromJson(item);
            } catch (e) {
              debugPrint('❌ Error parsing certification item: $e');
              debugPrint('❌ Item data: $item');
              rethrow;
            }
          }).toList();

          // Debug: print only first certification and total count
          debugPrint('✅ Loaded ${certifications.length} certifications');
          if (certifications.isNotEmpty) {
            final first = certifications.first;
            debugPrint(
                '📋 First: ${first.certification?.category?.name ?? "Unknown"} - Status: ${first.certificationUser.status}');
          }

          return CertificationResponse(
            success: true,
            data: certifications,
            warnings: [],
          );
        } else if (response.data is Map<String, dynamic>) {
          // Wrapped response format
          final responseData = response.data as Map<String, dynamic>;
          final List<dynamic> certificationsData = responseData['data'] ?? [];
          final List<String> warnings =
              (responseData['warnings'] as List<dynamic>?)?.cast<String>() ??
                  [];

          final certifications = certificationsData.map((item) {
            try {
              // Debug: print the structure of first item to understand the API format
              if (certificationsData.indexOf(item) == 0) {
                debugPrint('🔍 First certification item structure (wrapped):');
                debugPrint('🔍 Keys: ${(item as Map).keys.toList()}');
                if (item.containsKey('certification_user')) {
                  debugPrint(
                      '🔍 certification_user keys: ${(item['certification_user'] as Map?)?.keys.toList()}');
                }
              }

              return UserCertificationDetail.fromJson(item);
            } catch (e) {
              debugPrint('❌ Error parsing certification item: $e');
              debugPrint('❌ Item data: $item');
              rethrow;
            }
          }).toList();

          // Debug: print only first certification and total count
          debugPrint('✅ Loaded ${certifications.length} certifications');
          if (certifications.isNotEmpty) {
            final first = certifications.first;
            debugPrint(
                '📋 First: ${first.certification?.category?.name ?? "Unknown"} - Status: ${first.certificationUser.status}');
          }

          return CertificationResponse(
            success: true,
            data: certifications,
            warnings: warnings,
          );
        } else {
          return CertificationResponse(
            success: false,
            error: 'Unexpected response format: ${response.data.runtimeType}',
            data: null,
          );
        }
      } else {
        final errorData = response.data as Map<String, dynamic>?;
        return CertificationResponse(
          success: false,
          error: errorData?['error'] ??
              'Failed to fetch certifications (HTTP ${response.status})',
          data: null,
        );
      }
    } catch (e) {
      debugPrint('❌ CertificationService error: $e');
      return CertificationResponse(
        success: false,
        error: 'Error calling certifications service: $e',
        data: null,
      );
    }
  }

  /// Approva o rifiuta una certificazione tramite l'edge function user-approve-certification
  ///
  /// [idCertificationUser] - ID della certificazione utente
  /// [status] - 'accepted' o 'rejected'
  /// [rejectionReason] - motivo del rifiuto (opzionale, solo per status 'rejected')
  static Future<CertificationApprovalResponse> approveCertification({
    required String idCertificationUser,
    required String status, // 'accepted' o 'rejected'
    String? rejectionReason,
  }) async {
    try {
      // Validate status
      if (status != 'accepted' && status != 'rejected') {
        throw ArgumentError('Status must be "accepted" or "rejected"');
      }

      // Prepare request body
      final Map<String, dynamic> requestBody = {
        'id_certification_user': idCertificationUser,
        'status': status,
      };

      // Add rejection reason if status is rejected and reason is provided
      if (status == 'rejected' &&
          rejectionReason != null &&
          rejectionReason.trim().isNotEmpty) {
        requestBody['rejection_reason'] = rejectionReason.trim();
      }

      debugPrint(
          '🔄 ${status == 'accepted' ? 'Approving' : 'Rejecting'} certification: $idCertificationUser');

      // Call the edge function
      final response = await EdgeFunctionService.invokeFunction(
        'user-approve-certification',
        requestBody,
      );

      if (response.containsKey('data') &&
          response['data'].containsKey('certification_user')) {
        final certificationUserData = response['data']['certification_user'];
        final updatedCertificationUser =
            CertificationUserModel.fromJson(certificationUserData);

        debugPrint(
            '✅ Certification ${status == 'accepted' ? 'approved' : 'rejected'} successfully');

        return CertificationApprovalResponse(
          success: true,
          data: updatedCertificationUser,
        );
      } else {
        throw Exception('Invalid response format from edge function');
      }
    } catch (e) {
      debugPrint(
          '❌ Error ${status == 'accepted' ? 'approving' : 'rejecting'} certification: $e');
      return CertificationApprovalResponse(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Approva una certificazione
  static Future<CertificationApprovalResponse> approve(
      String idCertificationUser) {
    return approveCertification(
      idCertificationUser: idCertificationUser,
      status: 'accepted',
    );
  }

  /// Rifiuta una certificazione
  static Future<CertificationApprovalResponse> reject(
    String idCertificationUser, {
    String? rejectionReason,
  }) {
    return approveCertification(
      idCertificationUser: idCertificationUser,
      status: 'rejected',
      rejectionReason: rejectionReason,
    );
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
    try {
      // Check if data comes from new API structure
      if (json.containsKey('certification_user') &&
          json['certification_user'] is Map) {
        final certificationUserData =
            json['certification_user'] as Map<String, dynamic>;

        return UserCertificationDetail(
          certificationUser: CertificationUser.fromJson(certificationUserData),
          certification: certificationUserData['certification'] != null &&
                  certificationUserData['certification'] is Map
              ? Certification.fromJson(certificationUserData['certification']
                  as Map<String, dynamic>)
              : null,
          media: json['media'] != null && json['media'] is Map
              ? CertificationMedia.fromJson(
                  json['media'] as Map<String, dynamic>)
              : CertificationMedia
                  .empty(), // Provide empty media if not present
        );
      }

      // Fallback for old API structure
      return UserCertificationDetail(
        certificationUser: json['certification_user'] != null &&
                json['certification_user'] is Map
            ? CertificationUser.fromJson(
                json['certification_user'] as Map<String, dynamic>)
            : throw ArgumentError(
                'certification_user field is required and must be a valid object'),
        certification:
            json['certification'] != null && json['certification'] is Map
                ? Certification.fromJson(
                    json['certification'] as Map<String, dynamic>)
                : null,
        media: json['media'] != null && json['media'] is Map
            ? CertificationMedia.fromJson(json['media'] as Map<String, dynamic>)
            : CertificationMedia.empty(), // Provide empty media if not present
      );
    } catch (e) {
      debugPrint('❌ Error parsing UserCertificationDetail: $e');
      debugPrint('❌ JSON data: $json');
      rethrow;
    }
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

class CertifierInfo {
  final String idCertifier;
  final String? idUser;
  final String? firstName;
  final String? lastName;
  final String? fullName;
  final UserInfo? user; // Expanded user data from new API

  CertifierInfo({
    required this.idCertifier,
    this.idUser,
    this.firstName,
    this.lastName,
    this.fullName,
    this.user,
  });

  factory CertifierInfo.fromJson(Map<String, dynamic> json) {
    return CertifierInfo(
      idCertifier: json['id_certifier']?.toString() ?? '',
      idUser: json['id_user']?.toString(),
      firstName: json['first_name']?.toString(),
      lastName: json['last_name']?.toString(),
      fullName: json['full_name']?.toString(),
      user: json['user'] != null ? UserInfo.fromJson(json['user']) : null,
    );
  }

  String get displayName {
    // First try the expanded user data from new API
    if (user != null) {
      final userDisplayName = user!.displayName;
      if (userDisplayName.isNotEmpty && userDisplayName != 'Unknown User') {
        return userDisplayName;
      }
    }

    // Fallback to legacy fields
    if (fullName != null && fullName!.trim().isNotEmpty) {
      return fullName!.trim();
    }

    // Poi prova firstName + lastName
    final first = firstName?.trim();
    final last = lastName?.trim();

    if (first != null && first.isNotEmpty && last != null && last.isNotEmpty) {
      return '$first $last';
    }

    // Se solo firstName è disponibile
    if (first != null && first.isNotEmpty) {
      return first;
    }

    // Se solo lastName è disponibile
    if (last != null && last.isNotEmpty) {
      return last;
    }

    // Se abbiamo almeno un nome parziale
    if ((first != null && first.isNotEmpty) ||
        (last != null && last.isNotEmpty)) {
      return '${first ?? ''}${last ?? ''}'.trim();
    }

    return 'Unknown Certifier';
  }
}

/// UserInfo class to handle expanded user data from the new API
class UserInfo {
  final String idUser;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? fullName;

  UserInfo({
    required this.idUser,
    this.firstName,
    this.lastName,
    this.email,
    this.fullName,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      idUser: json['idUser']?.toString() ?? '',
      firstName: json['first_name']?.toString(),
      lastName: json['last_name']?.toString(),
      email: json['email']?.toString(),
      fullName: json['full_name']?.toString(),
    );
  }

  String get displayName {
    // Try fullName first if available
    if (fullName != null && fullName!.trim().isNotEmpty) {
      return fullName!.trim();
    }

    // Try firstName + lastName
    final first = firstName?.trim();
    final last = lastName?.trim();

    if (first != null && first.isNotEmpty && last != null && last.isNotEmpty) {
      return '$first $last';
    }

    // Try firstName only
    if (first != null && first.isNotEmpty) {
      return first;
    }

    // Try lastName only
    if (last != null && last.isNotEmpty) {
      return last;
    }

    // Try email if no name is available
    if (email != null && email!.trim().isNotEmpty) {
      return email!.trim();
    }

    return 'Unknown User';
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
  final CertifierInfo? certifier;
  final LocationModel? location; // Expanded location data from new API
  final LegalEntityModel?
      legalEntity; // Expanded legal entity data from new API
  final List<CertificationMediaWithLocation>
      certificationMedia; // Media with expanded location from new API 1.0.8
  // nomeCertificatore removed - now use expanded certifier.user data from new API

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
    this.certifier,
    this.location,
    this.legalEntity,
    this.certificationMedia = const [],
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
      category: json['certification_category'] != null
          ? CertificationCategory.fromJson(json['certification_category'])
          : null,
      categoryInformation: json['certification_category'] != null &&
              json['certification_category']['certification_information']
                  is List
          ? (json['certification_category']['certification_information']
                  as List<dynamic>)
              .map((item) => CategoryInformation.fromExpandedJson(item))
              .toList()
          : (json['category_information'] as List<dynamic>?)
                  ?.map((item) => CategoryInformation.fromJson(item))
                  .toList() ??
              [],
      certifier: json['certifier'] != null
          ? CertifierInfo.fromJson(json['certifier'])
          : null,
      location: json['location'] != null && json['location'] is Map
          ? LocationModel.fromJson(json['location'] as Map<String, dynamic>)
          : null,
      legalEntity: json['legal_entity'] != null && json['legal_entity'] is Map
          ? LegalEntityModel.fromJson(
              json['legal_entity'] as Map<String, dynamic>)
          : null,
      certificationMedia: json['certification_media'] != null &&
              json['certification_media'] is List
          ? (json['certification_media'] as List<dynamic>)
              .where((item) => item != null && item is Map)
              .map((item) => CertificationMediaWithLocation.fromJson(
                  item as Map<String, dynamic>))
              .toList()
          : [],
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
  final String? value; // Direct value field
  final String? label; // Direct label field

  CategoryInformation({
    this.info,
    this.values = const [],
    this.value,
    this.label,
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
      value: json['value']?.toString(),
      label: json['label']?.toString(),
    );
  }

  /// Factory method for the new API structure where certification_information_value is an array
  /// directly in the certification_information object
  factory CategoryInformation.fromExpandedJson(Map<String, dynamic> json) {
    return CategoryInformation(
      info: CertificationInformation.fromJson(json),
      values: (json['certification_information_value'] as List<dynamic>?)
              ?.map((item) => CertificationInformationValue.fromJson(item))
              .toList() ??
          [],
      value: null, // Direct value not used in expanded format
      label: json['label']?.toString(),
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

  /// Creates an empty CertificationMedia instance
  factory CertificationMedia.empty() {
    return CertificationMedia(
      directMedia: [],
      linkedMedia: [],
    );
  }

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

/// Response class per le operazioni di approvazione/rifiuto
class CertificationApprovalResponse {
  final bool success;
  final String? error;
  final CertificationUserModel? data;

  CertificationApprovalResponse({
    required this.success,
    this.error,
    this.data,
  });
}

/// Certification media with expanded location data from new API
class CertificationMediaWithLocation {
  final CertificationMediaModel media;
  final LocationModel? location;

  CertificationMediaWithLocation({
    required this.media,
    this.location,
  });

  factory CertificationMediaWithLocation.fromJson(Map<String, dynamic> json) {
    return CertificationMediaWithLocation(
      media: CertificationMediaModel.fromJson(json),
      location: json['location'] != null && json['location'] is Map
          ? LocationModel.fromJson(json['location'] as Map<String, dynamic>)
          : null,
    );
  }
}
