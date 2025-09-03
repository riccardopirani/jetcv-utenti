/// Legal entity invitation model representing the legal_entity_invitation table
class LegalEntityInvitationModel {
  final String idLegalEntityInvitation;
  final String idLegalEntity;
  final String email;
  final String invitationToken;
  final DateTime? sentAt;
  final DateTime expiresAt;
  final DateTime? acceptedAt;
  final DateTime createdAt;
  final bool valid;

  LegalEntityInvitationModel({
    required this.idLegalEntityInvitation,
    required this.idLegalEntity,
    required this.email,
    required this.invitationToken,
    this.sentAt,
    required this.expiresAt,
    this.acceptedAt,
    required this.createdAt,
    this.valid = true,
  });

  /// Create LegalEntityInvitationModel from JSON/Map
  factory LegalEntityInvitationModel.fromJson(Map<String, dynamic> json) =>
      LegalEntityInvitationModel(
        idLegalEntityInvitation: json['id_legal_entity_invitation'] as String,
        idLegalEntity: json['id_legal_entity'] as String,
        email: json['email'] as String,
        invitationToken: json['invitation_token'] as String,
        sentAt:
            json['sent_at'] != null ? DateTime.parse(json['sent_at']) : null,
        expiresAt: DateTime.parse(json['expires_at']),
        acceptedAt: json['accepted_at'] != null
            ? DateTime.parse(json['accepted_at'])
            : null,
        createdAt: DateTime.parse(json['created_at']),
        valid: json['valid'] as bool? ?? true,
      );

  /// Convert LegalEntityInvitationModel to JSON/Map
  Map<String, dynamic> toJson() => {
        'id_legal_entity_invitation': idLegalEntityInvitation,
        'id_legal_entity': idLegalEntity,
        'email': email,
        'invitation_token': invitationToken,
        'sent_at': sentAt?.toIso8601String(),
        'expires_at': expiresAt.toIso8601String(),
        'accepted_at': acceptedAt?.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
        'valid': valid,
      };

  /// Check if invitation is expired
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Check if invitation has been accepted
  bool get isAccepted => acceptedAt != null;

  /// Check if invitation has been sent
  bool get isSent => sentAt != null;

  /// Check if invitation is still pending (sent but not accepted and not expired)
  bool get isPending => isSent && !isAccepted && !isExpired && valid;

  /// Create copy with updated fields
  LegalEntityInvitationModel copyWith({
    DateTime? sentAt,
    DateTime? acceptedAt,
    bool? valid,
  }) =>
      LegalEntityInvitationModel(
        idLegalEntityInvitation: idLegalEntityInvitation,
        idLegalEntity: idLegalEntity,
        email: email,
        invitationToken: invitationToken,
        sentAt: sentAt ?? this.sentAt,
        expiresAt: expiresAt,
        acceptedAt: acceptedAt ?? this.acceptedAt,
        createdAt: createdAt,
        valid: valid ?? this.valid,
      );

  @override
  String toString() =>
      'LegalEntityInvitationModel(idLegalEntityInvitation: $idLegalEntityInvitation, email: $email, isPending: $isPending)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LegalEntityInvitationModel &&
          runtimeType == other.runtimeType &&
          idLegalEntityInvitation == other.idLegalEntityInvitation;

  @override
  int get hashCode => idLegalEntityInvitation.hashCode;
}
