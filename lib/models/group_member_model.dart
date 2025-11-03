class GroupMember {
  final int id;
  final String name;
  final String? avatar;
  final String email;
  final bool isAdmin;
  final DateTime joinedAt;

  GroupMember({
    required this.id,
    required this.name,
    this.avatar,
    required this.email,
    required this.isAdmin,
    required this.joinedAt,
  });

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    return GroupMember(
      id: json['id'] ?? json['memberId'] ?? 0,
      name: json['name'] ?? json['memberName'] ?? 'Unknown User',
      avatar: json['avatar'] ?? json['avatarUrl'],
      email: json['email'] ?? '',
      isAdmin: json['is_admin'] ?? json['isAdmin'] ?? false,
      joinedAt: DateTime.parse(
        json['joined_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
      'email': email,
      'is_admin': isAdmin,
      'joined_at': joinedAt.toIso8601String(),
    };
  }
}
