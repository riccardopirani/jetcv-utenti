/// KYC attempt model representing the kyc_attempt table
class KycAttemptModel {
  final String idKycAttempt;
  final String idUser;
  final String? requestBody;
  final String? success;
  final String? message;
  final String? receivedParams;
  final String? responseStatus;
  final String? responseVerificationId;
  final String? responseVerificationUrl;
  final String? responseVerificationSessionToken;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? sessionId;
  final bool? verificated;
  final DateTime? verificatedAt;

  KycAttemptModel({
    required this.idKycAttempt,
    required this.idUser,
    this.requestBody,
    this.success,
    this.message,
    this.receivedParams,
    this.responseStatus,
    this.responseVerificationId,
    this.responseVerificationUrl,
    this.responseVerificationSessionToken,
    required this.createdAt,
    this.updatedAt,
    this.sessionId,
    this.verificated,
    this.verificatedAt,
  });

  /// Create KycAttemptModel from JSON/Map
  factory KycAttemptModel.fromJson(Map<String, dynamic> json) =>
      KycAttemptModel(
        idKycAttempt: json['id_kyc_attempt'] as String,
        idUser: json['id_user'] as String,
        requestBody: json['request_body'] as String?,
        success: json['success'] as String?,
        message: json['message'] as String?,
        receivedParams: json['received_params'] as String?,
        responseStatus: json['response_status'] as String?,
        responseVerificationId: json['response_verification_id'] as String?,
        responseVerificationUrl: json['response_verification_url'] as String?,
        responseVerificationSessionToken:
            json['response_verification_session_token'] as String?,
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'])
            : null,
        sessionId: json['session_id'] as String?,
        verificated: json['verificated'] as bool?,
        verificatedAt: json['verificated_at'] != null
            ? DateTime.parse(json['verificated_at'])
            : null,
      );

  /// Convert KycAttemptModel to JSON/Map
  Map<String, dynamic> toJson() => {
        'id_kyc_attempt': idKycAttempt,
        'id_user': idUser,
        'request_body': requestBody,
        'success': success,
        'message': message,
        'received_params': receivedParams,
        'response_status': responseStatus,
        'response_verification_id': responseVerificationId,
        'response_verification_url': responseVerificationUrl,
        'response_verification_session_token': responseVerificationSessionToken,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'session_id': sessionId,
        'verificated': verificated,
        'verificated_at': verificatedAt?.toIso8601String(),
      };

  /// Create copy with updated fields
  KycAttemptModel copyWith({
    String? success,
    String? message,
    String? responseStatus,
    DateTime? updatedAt,
    bool? verificated,
    DateTime? verificatedAt,
  }) =>
      KycAttemptModel(
        idKycAttempt: idKycAttempt,
        idUser: idUser,
        requestBody: requestBody,
        success: success ?? this.success,
        message: message ?? this.message,
        receivedParams: receivedParams,
        responseStatus: responseStatus ?? this.responseStatus,
        responseVerificationId: responseVerificationId,
        responseVerificationUrl: responseVerificationUrl,
        responseVerificationSessionToken: responseVerificationSessionToken,
        createdAt: createdAt,
        updatedAt: updatedAt ?? DateTime.now(),
        sessionId: sessionId,
        verificated: verificated ?? this.verificated,
        verificatedAt: verificatedAt ?? this.verificatedAt,
      );

  @override
  String toString() =>
      'KycAttemptModel(idKycAttempt: $idKycAttempt, verificated: $verificated)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KycAttemptModel &&
          runtimeType == other.runtimeType &&
          idKycAttempt == other.idKycAttempt;

  @override
  int get hashCode => idKycAttempt.hashCode;
}
