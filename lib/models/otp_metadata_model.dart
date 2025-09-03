/// OTP metadata model for safe display (without code/hash)
class OtpMetadataModel {
  final String idOtp;
  final String idUser;
  final String? tag;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime expiresAt;
  final DateTime? usedAt;
  final String? usedByIdUser;
  final DateTime? burnedAt;

  OtpMetadataModel({
    required this.idOtp,
    required this.idUser,
    this.tag,
    required this.createdAt,
    this.updatedAt,
    required this.expiresAt,
    this.usedAt,
    this.usedByIdUser,
    this.burnedAt,
  });

  /// Create OtpMetadataModel from JSON/Map
  factory OtpMetadataModel.fromJson(Map<String, dynamic> json) =>
      OtpMetadataModel(
        idOtp: json['id_otp'] as String,
        idUser: json['id_user'] as String,
        tag: json['tag'] as String?,
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'])
            : null,
        expiresAt: DateTime.parse(json['expires_at']),
        usedAt:
            json['used_at'] != null ? DateTime.parse(json['used_at']) : null,
        usedByIdUser: json['used_by_id_user'] as String?,
        burnedAt: json['burned_at'] != null
            ? DateTime.parse(json['burned_at'])
            : null,
      );

  /// Convert OtpMetadataModel to JSON/Map
  Map<String, dynamic> toJson() => {
        'id_otp': idOtp,
        'id_user': idUser,
        'tag': tag,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'expires_at': expiresAt.toIso8601String(),
        'used_at': usedAt?.toIso8601String(),
        'used_by_id_user': usedByIdUser,
        'burned_at': burnedAt?.toIso8601String(),
      };

  /// Check if OTP is expired
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Check if OTP has been used
  bool get isUsed => usedAt != null;

  /// Check if OTP has been burned
  bool get isBurned => burnedAt != null;

  /// Check if OTP is valid (not expired, used, or burned)
  bool get isValid => !isExpired && !isUsed && !isBurned;

  /// Get status string for display
  String get statusString {
    if (isBurned) return 'Burned';
    if (isUsed) return 'Used';
    if (isExpired) return 'Expired';
    return 'Valid';
  }

  /// Create copy with updated fields
  OtpMetadataModel copyWith({
    String? tag,
    DateTime? updatedAt,
    DateTime? usedAt,
    String? usedByIdUser,
    DateTime? burnedAt,
  }) =>
      OtpMetadataModel(
        idOtp: idOtp,
        idUser: idUser,
        tag: tag ?? this.tag,
        createdAt: createdAt,
        updatedAt: updatedAt ?? DateTime.now(),
        expiresAt: expiresAt,
        usedAt: usedAt ?? this.usedAt,
        usedByIdUser: usedByIdUser ?? this.usedByIdUser,
        burnedAt: burnedAt ?? this.burnedAt,
      );

  @override
  String toString() =>
      'OtpMetadataModel(idOtp: $idOtp, tag: $tag, status: $statusString, expiresAt: $expiresAt)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OtpMetadataModel &&
          runtimeType == other.runtimeType &&
          idOtp == other.idOtp;

  @override
  int get hashCode => idOtp.hashCode;
}
