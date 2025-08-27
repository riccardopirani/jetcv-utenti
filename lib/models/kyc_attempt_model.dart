/// KYC attempt model representing the kyc_attempt table
class KycAttemptModel {
  final int idKycAttempt;
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
  factory KycAttemptModel.fromJson(Map<String, dynamic> json) => KycAttemptModel(
    idKycAttempt: json['idKycAttempt'] as int,
    idUser: json['idUser'] as String,
    requestBody: json['requestBody'] as String?,
    success: json['success'] as String?,
    message: json['message'] as String?,
    receivedParams: json['receivedParams'] as String?,
    responseStatus: json['responseStatus'] as String?,
    responseVerificationId: json['responseVerificationId'] as String?,
    responseVerificationUrl: json['responseVerificationUrl'] as String?,
    responseVerificationSessionToken: json['responseVerificationSessionToken'] as String?,
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    sessionId: json['sessionId'] as String?,
    verificated: json['verificated'] as bool?,
    verificatedAt: json['verificatedAt'] != null ? DateTime.parse(json['verificatedAt']) : null,
  );

  /// Convert KycAttemptModel to JSON/Map
  Map<String, dynamic> toJson() => {
    'idKycAttempt': idKycAttempt,
    'idUser': idUser,
    'requestBody': requestBody,
    'success': success,
    'message': message,
    'receivedParams': receivedParams,
    'responseStatus': responseStatus,
    'responseVerificationId': responseVerificationId,
    'responseVerificationUrl': responseVerificationUrl,
    'responseVerificationSessionToken': responseVerificationSessionToken,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    'sessionId': sessionId,
    'verificated': verificated,
    'verificatedAt': verificatedAt?.toIso8601String(),
  };

  /// Create copy with updated fields
  KycAttemptModel copyWith({
    String? success,
    String? message,
    String? responseStatus,
    DateTime? updatedAt,
    bool? verificated,
    DateTime? verificatedAt,
  }) => KycAttemptModel(
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
  String toString() => 'KycAttemptModel(idKycAttempt: $idKycAttempt, verificated: $verificated)';

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is KycAttemptModel &&
    runtimeType == other.runtimeType &&
    idKycAttempt == other.idKycAttempt;

  @override
  int get hashCode => idKycAttempt.hashCode;
}