class User {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String? avatar;
  final String? emailVerifiedAt;
  final String createdAt;
  final String updatedAt;
  final String avatarUrl;
  final bool isAdmin;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.avatar,
    this.emailVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.avatarUrl,
    this.isAdmin = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      avatar: json['avatar'],
      emailVerifiedAt: json['email_verified_at'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      avatarUrl: json['avatar_url'],
      isAdmin: json['is_admin'] ?? json['isAdmin'] ?? false,
    );
  }

  String get fullName => '$firstName $lastName';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'avatar': avatar,
      'email_verified_at': emailVerifiedAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'avatar_url': avatarUrl,
      'is_admin': isAdmin,
    };
  }

  @override
  String toString() {
    return 'User{id: $id, name: $fullName, email: $email, isAdmin: $isAdmin}';
  }
}
