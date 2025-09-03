import 'dart:convert';

/// Modello per Open Badge conforme allo standard Open Badges v2.0
class OpenBadgeModel {
  final String id;
  final String type;
  final String name;
  final String description;
  final String image;
  final String criteria;
  final OpenBadgeIssuer issuer;
  final OpenBadgeRecipient recipient;
  final OpenBadgeVerification verification;
  final DateTime issuedOn;
  final DateTime? expires;
  final List<String> tags;
  final Map<String, dynamic>? evidence;
  final Map<String, dynamic>? alignment;

  OpenBadgeModel({
    required this.id,
    this.type = 'BadgeClass',
    required this.name,
    required this.description,
    required this.image,
    required this.criteria,
    required this.issuer,
    required this.recipient,
    required this.verification,
    required this.issuedOn,
    this.expires,
    this.tags = const [],
    this.evidence,
    this.alignment,
  });

  /// Crea un Open Badge da una certificazione
  factory OpenBadgeModel.fromCertification({
    required String certificationId,
    required String certificationName,
    required String certificationDescription,
    required String issuerName,
    required String issuerUrl,
    required String recipientEmail,
    required String recipientName,
    required String badgeImageUrl,
    required String criteriaUrl,
    required String verificationUrl,
    DateTime? expires,
    List<String>? tags,
    Map<String, dynamic>? evidence,
  }) {
    return OpenBadgeModel(
      id: 'urn:uuid:$certificationId',
      name: certificationName,
      description: certificationDescription,
      image: badgeImageUrl,
      criteria: criteriaUrl,
      issuer: OpenBadgeIssuer(
        id: issuerUrl,
        name: issuerName,
        url: issuerUrl,
      ),
      recipient: OpenBadgeRecipient(
        identity: recipientEmail,
        hashed: false,
        type: 'email',
        name: recipientName,
      ),
      verification: OpenBadgeVerification(
        type: 'HostedBadge',
        url: verificationUrl,
      ),
      issuedOn: DateTime.now(),
      expires: expires,
      tags: tags ?? [],
      evidence: evidence,
    );
  }

  /// Converte il badge in JSON-LD conforme allo standard Open Badges
  Map<String, dynamic> toJsonLd() {
    final jsonLd = {
      '@context': 'https://w3id.org/openbadges/v2',
      'type': type,
      'id': id,
      'name': name,
      'description': description,
      'image': image,
      'criteria': criteria,
      'issuer': issuer.toJson(),
      'recipient': recipient.toJson(),
      'verification': verification.toJson(),
      'issuedOn': issuedOn.toIso8601String(),
    };

    if (expires != null) {
      jsonLd['expires'] = expires!.toIso8601String();
    }

    if (tags.isNotEmpty) {
      jsonLd['tags'] = tags;
    }

    if (evidence != null) {
      jsonLd['evidence'] = evidence as Object;
    }

    if (alignment != null) {
      jsonLd['alignment'] = alignment as Object;
    }

    return jsonLd;
  }

  /// Converte il badge in JSON-LD string
  String toJsonLdString() {
    return jsonEncode(toJsonLd());
  }

  /// Crea una copia del badge con campi aggiornati
  OpenBadgeModel copyWith({
    String? newId,
    String? newType,
    String? newName,
    String? newDescription,
    String? newImage,
    String? newCriteria,
    OpenBadgeIssuer? newIssuer,
    OpenBadgeRecipient? newRecipient,
    OpenBadgeVerification? newVerification,
    DateTime? newIssuedOn,
    DateTime? newExpires,
    List<String>? newTags,
    Map<String, dynamic>? newEvidence,
    Map<String, dynamic>? newAlignment,
  }) {
    return OpenBadgeModel(
      id: newId ?? this.id,
      type: newType ?? this.type,
      name: newName ?? this.name,
      description: newDescription ?? this.description,
      image: newImage ?? this.image,
      criteria: newCriteria ?? this.criteria,
      issuer: newIssuer ?? this.issuer,
      recipient: newRecipient ?? this.recipient,
      verification: newVerification ?? this.verification,
      issuedOn: newIssuedOn ?? this.issuedOn,
      expires: newExpires ?? this.expires,
      tags: newTags ?? this.tags,
      evidence: newEvidence ?? this.evidence,
      alignment: newAlignment ?? this.alignment,
    );
  }

  @override
  String toString() {
    return 'OpenBadgeModel(id: $id, name: $name, issuer: ${issuer.name})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OpenBadgeModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Modello per l'emittente del badge
class OpenBadgeIssuer {
  final String id;
  final String name;
  final String url;
  final String? email;
  final String? description;
  final String? image;

  OpenBadgeIssuer({
    required this.id,
    required this.name,
    required this.url,
    this.email,
    this.description,
    this.image,
  });

  Map<String, dynamic> toJson() {
    final json = {
      'id': id,
      'name': name,
      'url': url,
    };

    if (email != null) json['email'] = email!;
    if (description != null) json['description'] = description!;
    if (image != null) json['image'] = image!;

    return json;
  }

  factory OpenBadgeIssuer.fromJson(Map<String, dynamic> json) {
    return OpenBadgeIssuer(
      id: json['id'] as String,
      name: json['name'] as String,
      url: json['url'] as String,
      email: json['email'] as String?,
      description: json['description'] as String?,
      image: json['image'] as String?,
    );
  }
}

/// Modello per il destinatario del badge
class OpenBadgeRecipient {
  final String identity;
  final bool hashed;
  final String type;
  final String? name;
  final String? salt;

  OpenBadgeRecipient({
    required this.identity,
    this.hashed = false,
    this.type = 'email',
    this.name,
    this.salt,
  });

  Map<String, dynamic> toJson() {
    final json = {
      'identity': identity,
      'hashed': hashed,
      'type': type,
    };

    if (name != null) json['name'] = name!;
    if (salt != null) json['salt'] = salt!;

    return json;
  }

  factory OpenBadgeRecipient.fromJson(Map<String, dynamic> json) {
    return OpenBadgeRecipient(
      identity: json['identity'] as String,
      hashed: json['hashed'] as bool? ?? false,
      type: json['type'] as String? ?? 'email',
      name: json['name'] as String?,
      salt: json['salt'] as String?,
    );
  }
}

/// Modello per la verifica del badge
class OpenBadgeVerification {
  final String type;
  final String? url;
  final String? allowedOrigins;
  final Map<String, dynamic>? verificationProperty;

  OpenBadgeVerification({
    required this.type,
    this.url,
    this.allowedOrigins,
    this.verificationProperty,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'type': type,
    };

    if (url != null) json['url'] = url!;
    if (allowedOrigins != null) json['allowedOrigins'] = allowedOrigins!;
    if (verificationProperty != null)
      json['verificationProperty'] = verificationProperty!;

    return json;
  }

  factory OpenBadgeVerification.fromJson(Map<String, dynamic> json) {
    return OpenBadgeVerification(
      type: json['type'] as String,
      url: json['url'] as String?,
      allowedOrigins: json['allowedOrigins'] as String?,
      verificationProperty:
          json['verificationProperty'] as Map<String, dynamic>?,
    );
  }
}
