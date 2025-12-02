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
  }) : preferredTags = preferredTags ?? const [];

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
    );
  }
}
