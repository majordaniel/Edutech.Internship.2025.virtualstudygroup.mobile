class Message {
  final int id;
  final String message;
  final int userId;
  final String createdAt;

  Message({
    required this.id,
    required this.message,
    required this.userId,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] ?? 0,
      message: json['message'] ?? '',
      userId: json['user_id'] ?? json['userId'] ?? 0,
      createdAt: json['created_at'] ?? json['createdAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'user_id': userId,
      'created_at': createdAt,
    };
  }
}
