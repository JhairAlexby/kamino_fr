class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? gender;
  final List<String> preferredTags;
  final List<String> favoritePlaces;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.gender,
    List<String>? preferredTags,
    List<String>? favoritePlaces,
  }) : preferredTags = preferredTags ?? const [],
       favoritePlaces = favoritePlaces ?? const [];

  User copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? role,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? gender,
    List<String>? preferredTags,
    List<String>? favoritePlaces,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      gender: gender ?? this.gender,
      preferredTags: preferredTags ?? this.preferredTags,
      favoritePlaces: favoritePlaces ?? this.favoritePlaces,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      role: json['role'] as String,
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      gender: json['gender'] as String?,
      preferredTags: (json['preferredTags'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      favoritePlaces: (json['favoritePlaces'] as List?)?.map((e) => e.toString()).toList() ?? const [],
    );
  }
}