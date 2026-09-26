enum DistanceUnit {
  kilometers,
  miles;

  String get code => name;

  static DistanceUnit fromString(String? value) {
    if (value == 'miles') return DistanceUnit.miles;
    return DistanceUnit.kilometers;
  }
}

class UserProfile {
  final String id;
  final String displayName;
  final String? email;
  final String? avatarUrl;
  final String? city;
  final String? clubTag;
  final String language;
  final DistanceUnit units;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const UserProfile({
    required this.id,
    required this.displayName,
    this.email,
    this.avatarUrl,
    this.city,
    this.clubTag,
    this.language = 'en',
    this.units = DistanceUnit.kilometers,
    required this.createdAt,
    this.updatedAt,
  });

  UserProfile copyWith({
    String? id,
    String? displayName,
    String? email,
    String? avatarUrl,
    String? city,
    String? clubTag,
    String? language,
    DistanceUnit? units,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      city: city ?? this.city,
      clubTag: clubTag ?? this.clubTag,
      language: language ?? this.language,
      units: units ?? this.units,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'city': city,
      'club_tag': clubTag,
      'language': language,
      'units': units.code,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map, {String? fallbackEmail}) {
    return UserProfile(
      id: map['id'] as String,
      displayName: (map['display_name'] as String?)?.trim() ?? 'Runner',
      email: (map['email'] as String?) ?? fallbackEmail,
      avatarUrl: map['avatar_url'] as String?,
      city: map['city'] as String?,
      clubTag: map['club_tag'] as String?,
      language: (map['language'] as String?) ?? 'en',
      units: DistanceUnit.fromString(map['units'] as String?),
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'] as String)
          : null,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfile &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          displayName == other.displayName &&
          email == other.email &&
          avatarUrl == other.avatarUrl &&
          city == other.city &&
          clubTag == other.clubTag &&
          language == other.language &&
          units == other.units;

  @override
  int get hashCode => Object.hash(
        id,
        displayName,
        email,
        avatarUrl,
        city,
        clubTag,
        language,
        units,
      );
}
