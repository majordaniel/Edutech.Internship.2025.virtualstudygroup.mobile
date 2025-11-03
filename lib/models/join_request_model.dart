// join_request_model.dart - ADD STATUS FIELD
class JoinRequest {
  final String id;
  final int requestId;
  final int groupId;
  final int userId;
  final String userName;
  final String? userAvatar;
  final String message;
  final String createdAt;
  final String notificationId;
  final String status; // NEW: 'pending', 'approved', 'rejected'

  JoinRequest({
    required this.id,
    required this.requestId,
    required this.groupId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.message,
    required this.createdAt,
    required this.notificationId,
    this.status = 'pending', // DEFAULT TO PENDING
  });

  factory JoinRequest.fromJson(Map<String, dynamic> json) {
    // print('🔍 Parsing JoinRequest from JSON: $json');

    Map<String, dynamic> data = {};

    if (json['data'] is Map) {
      data = json['data'];
    } else if (json is Map) {
      data = json;
    }

    // Extract values with better error handling
    final requestId =
        _extractInt(data['request_id']) ?? _extractInt(data['id']) ?? 0;

    final groupId = _extractInt(data['group_id']) ?? 0;
    final userId = _extractInt(data['user_id']) ?? 0;

    // Handle user name extraction
    String userName = 'Unknown User';
    if (data['user_name'] != null) {
      userName = data['user_name'].toString();
    } else if (data['user'] is Map) {
      final user = data['user'];
      final firstName = user['first_name']?.toString() ?? '';
      final lastName = user['last_name']?.toString() ?? '';
      userName = '$firstName $lastName'.trim();
      if (userName.isEmpty) userName = 'Unknown User';
    } else if (data['sender_name'] != null) {
      userName = data['sender_name'].toString();
    }

    final message =
        data['message']?.toString() ??
        data['body']?.toString() ??
        'Wants to join your group';

    // NEW: Extract status from notification or data
    String status = 'pending';
    if (data['status'] != null) {
      status = data['status'].toString().toLowerCase();
    } else if (json['read_at'] != null) {
      // If notification is read but status unknown, assume processed
      status = 'processed';
    }

    return JoinRequest(
      id:
          json['id']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      requestId: requestId,
      groupId: groupId,
      userId: userId,
      userName: userName,
      userAvatar:
          data['avatar_url']?.toString() ??
          data['avatar']?.toString() ??
          data['user_avatar']?.toString(),
      message: message,
      createdAt:
          json['created_at']?.toString() ??
          data['created_at']?.toString() ??
          DateTime.now().toIso8601String(),
      notificationId: json['id']?.toString() ?? 'unknown',
      status: status, // NEW STATUS FIELD
    );
  }

  // Helper getters for easy status checking
  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
  bool get isProcessed => isApproved || isRejected;

  static int? _extractInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'request_id': requestId,
      'group_id': groupId,
      'user_id': userId,
      'user_name': userName,
      'user_avatar': userAvatar,
      'message': message,
      'created_at': createdAt,
      'notification_id': notificationId,
      'status': status, // NEW STATUS FIELD
    };
  }

  // Copy with method for updating status
  JoinRequest copyWith({String? status}) {
    return JoinRequest(
      id: id,
      requestId: requestId,
      groupId: groupId,
      userId: userId,
      userName: userName,
      userAvatar: userAvatar,
      message: message,
      createdAt: createdAt,
      notificationId: notificationId,
      status: status ?? this.status,
    );
  }

  @override
  String toString() {
    return 'JoinRequest(id: $id, requestId: $requestId, groupId: $groupId, userId: $userId, userName: $userName, status: $status)';
  }
}
