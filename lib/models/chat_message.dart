import 'package:flutter/material.dart';

class ChatMessage {
  final int id;
  final int groupId;
  final int userId;
  final String? message;
  final String createdAt;
  final String senderName;
  final String senderAvatar;
  final bool hasCall;
  final bool hasFile;
  final bool hasMessage;
  final String? fileUrl;
  final String? fileType;
  final String? fileName;
  final double? fileSize;
  // New properties for message options
  final List<MessageReaction> reactions;
  final bool isPinned;
  final int? replyToMessageId;
  final ChatMessage? repliedMessage;
  final bool isDeleted;
  //new features for call
  final int? callId;
  final bool isCallEnded;
  final String? callUrl;
  // WebSocket and optimistic update fields
  final bool isPending;
  final bool isFailed;
  final String messageType;
  final int? repliedToMessageId;
  final ChatMessage? repliedToMessage;
  final String? repliedToMessageText;
  final String? repliedToSenderName;
  final bool? hasReply;

  ChatMessage({
    required this.id,
    required this.groupId,
    required this.userId,
    required this.message,
    required this.createdAt,
    this.senderName = 'Unknown User',
    this.senderAvatar = '',
    this.hasCall = false,
    this.hasFile = false,
    this.hasMessage = true,
    this.fileUrl,
    this.fileType,
    this.fileName,
    this.fileSize,
    // New properties with defaults
    this.reactions = const [],
    this.isPinned = false,
    this.replyToMessageId,
    this.repliedToMessageText,
    this.repliedToSenderName,
    this.hasReply = false,
    this.repliedMessage,
    this.isDeleted = false,
    //new feature for call
    this.callId,
    this.isCallEnded = false,
    this.callUrl,
    // WebSocket and optimistic update fields
    this.isPending = false,
    this.isFailed = false,
    this.messageType = 'text',
    this.repliedToMessageId,
    this.repliedToMessage,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    // Extract sender info from user object or direct fields
    String senderName = 'Unknown User';
    String senderAvatar = '';

    // Check if user data is available
    if (json['user'] is Map<String, dynamic>) {
      final user = json['user'];
      final firstName =
          user['first_name']?.toString() ?? user['firstName']?.toString() ?? '';
      final lastName =
          user['last_name']?.toString() ?? user['lastName']?.toString() ?? '';
      senderName = '$firstName $lastName'.trim();
      if (senderName.isEmpty) senderName = 'Unknown User';

      senderAvatar =
          user['avatar_url']?.toString() ??
          user['avatarUrl']?.toString() ??
          user['avatar']?.toString() ??
          '';
    } else {
      // Fallback to direct fields
      final firstName =
          json['first_name']?.toString() ?? json['firstName']?.toString() ?? '';
      final lastName =
          json['last_name']?.toString() ?? json['lastName']?.toString() ?? '';
      senderName = '$firstName $lastName'.trim();
      if (senderName.isEmpty) senderName = 'Unknown User';
    }

    // Handle file detection from backend structure
    bool hasFile = false;
    String? fileUrl;
    String? fileType;
    String? fileName;
    double? fileSize;

    // Check if message has a file attached (backend structure)
    if (json['file'] is Map<String, dynamic>) {
      final fileData = json['file'];
      hasFile = true;
      fileUrl = fileData['path']?.toString();
      fileType = fileData['mime_type']?.toString();
      fileName = fileData['original_name']?.toString();
      fileSize = fileData['size'] != null
          ? double.tryParse(fileData['size'].toString())
          : null;
    }
    // Also check direct file fields (fallback)
    else if (json['file_url'] != null || json['file_type'] != null) {
      hasFile = true;
      fileUrl = json['file_url']?.toString() ?? json['fileUrl']?.toString();
      fileType = json['file_type']?.toString() ?? json['fileType']?.toString();
      fileName = json['file_name']?.toString() ?? json['fileName']?.toString();
      fileSize = json['file_size'] != null
          ? double.tryParse(json['file_size'].toString())
          : null;
    }

    // Determine message type based on content
    String messageType = json['message_type']?.toString() ?? 'text';
    final bool hasCall = messageType == 'call';
    final bool hasMessage =
        json['message'] != null && json['message'].toString().isNotEmpty;

    // Parse reactions if available
    final List<MessageReaction> reactions = [];
    if (json['reactions'] is List) {
      reactions.addAll(
        (json['reactions'] as List)
            .map((r) => MessageReaction.fromJson(r))
            .toList(),
      );
    }

    // Parse replied message if available
    ChatMessage? repliedMessage;
    if (json['replied_message'] is Map<String, dynamic>) {
      repliedMessage = ChatMessage.fromJson(json['replied_message']);
    }

    // WebSocket and optimistic update fields
    final bool isPending = json['is_pending'] ?? json['isPending'] ?? false;
    final bool isFailed = json['is_failed'] ?? json['isFailed'] ?? false;

    return ChatMessage(
      id: int.parse(json['id'].toString()),
      groupId: int.parse((json['group_id'] ?? json['groupId']).toString()),
      userId: int.parse((json['user_id'] ?? json['userId']).toString()),
      message: json['message']?.toString(),
      createdAt:
          json['created_at']?.toString() ??
          json['createdAt']?.toString() ??
          DateTime.now().toIso8601String(),
      senderName: senderName,
      senderAvatar: senderAvatar,
      hasCall: hasCall,
      hasFile: hasFile,
      hasMessage: hasMessage,
      fileUrl: fileUrl,
      fileType: fileType,
      fileName: fileName,
      fileSize: fileSize,
      // New properties
      reactions: reactions,
      isPinned: json['is_pinned'] ?? json['isPinned'] ?? false,
      replyToMessageId: json['reply_to_message_id'] ?? json['replyToMessageId'],
      repliedMessage: repliedMessage,
      isDeleted: json['is_deleted'] ?? json['isDeleted'] ?? false,
      //new call feature
      callId: json['call_id'],
      isCallEnded: json['is_call_ended'] ?? false,
      callUrl: json['call_url'],
      // WebSocket and optimistic update fields
      isPending: isPending,
      isFailed: isFailed,
      messageType: messageType,
      repliedToMessageId:
          json['replied_to_message_id'] ?? json['repliedToMessageId'],
      repliedToMessageText:
          json['replied_to_message_text'] ?? json['repliedToMessageText'],
      repliedToSenderName:
          json['replied_to_sender_name'] ?? json['repliedToSenderName'],
      hasReply: json['has_reply'] ?? json['hasReply'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'group_id': groupId,
      'user_id': userId,
      'message': message,
      'created_at': createdAt,
      'message_type': messageType,
      'sender_name': senderName,
      'sender_avatar': senderAvatar,
      if (fileUrl != null) 'file_url': fileUrl,
      if (fileType != null) 'file_type': fileType,
      if (fileName != null) 'file_name': fileName,
      if (fileSize != null) 'file_size': fileSize,
      // New properties
      'reactions': reactions.map((r) => r.toJson()).toList(),
      'is_pinned': isPinned,
      'reply_to_message_id': replyToMessageId,
      'is_deleted': isDeleted,
      // WebSocket and optimistic update fields
      'is_pending': isPending,
      'is_failed': isFailed,
      'replied_to_message_id': repliedToMessageId,
      'replied_to_message_text': repliedToMessageText,
      'replied_to_sender_name': repliedToSenderName,
      'has_reply': hasReply,
    };
  }

  // Helper method to check if this is an image message
  bool get isImage =>
      hasFile &&
      (fileType?.startsWith('image/') == true ||
          fileName?.toLowerCase().contains(
                RegExp(r'\.(jpg|jpeg|png|gif|bmp|webp)$'),
              ) ==
              true);

  // Helper method to check if this is a video message
  bool get isVideo =>
      hasFile &&
      (fileType?.startsWith('video/') == true ||
          fileName?.toLowerCase().contains(
                RegExp(r'\.(mp4|mov|avi|mkv|webm)$'),
              ) ==
              true);

  // Helper method to check if this is an audio message
  bool get isAudio {
    final isAudioFile =
        hasFile &&
        (fileType?.startsWith('audio/') == true ||
            fileName?.toLowerCase().contains(
                  RegExp(r'\.(mp3|wav|aac|ogg|flac|m4a|aac)$'),
                ) ==
                true);

    // print('🎵 Audio detection for file: $fileName');
    // print('   FileType: $fileType');
    // print('   IsAudio: $isAudioFile');

    return isAudioFile;
  }

  // Helper method to check if this is a document message
  bool get isDocument => hasFile && !isImage && !isVideo && !isAudio;

  // Helper method to get file extension
  String? get fileExtension {
    if (fileName == null) return null;
    final parts = fileName!.split('.');
    return parts.length > 1 ? parts.last.toLowerCase() : null;
  }

  // Helper method to format file size for display
  String get formattedFileSize {
    if (fileSize == null) return 'Unknown size';

    const units = ['B', 'KB', 'MB', 'GB'];
    double size = fileSize!;
    int unitIndex = 0;

    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }

    return '${size.toStringAsFixed(1)} ${units[unitIndex]}';
  }

  // Helper method to get file icon based on type
  IconData get fileIcon {
    if (isImage) return Icons.image;
    if (isVideo) return Icons.video_library;
    if (isAudio) return Icons.audio_file;

    final ext = fileExtension;
    switch (ext) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      default:
        return Icons.insert_drive_file;
    }
  }

  //helper methods for call
  bool get isCallMessage => callId != null || hasCall;
  bool get isActiveCall => isCallMessage && !isCallEnded;

  // New helper methods for message options
  bool get canBeDeletedByUser => !isDeleted;
  bool get canBePinned => !isDeleted;
  bool get canBeRepliedTo => !isDeleted;

  // Content detection methods
  bool get containsPhoneNumber {
    if (message == null) return false;
    final phoneRegex = RegExp(r'(\+?[\d\s\-\(\)]{10,})');
    return phoneRegex.hasMatch(message!);
  }

  bool get containsLinks {
    if (message == null) return false;
    final linkRegex = RegExp(
      r'(https?:\/\/[^\s]+|www\.[^\s]+|\b[\w\.]+@[\w\.]+\.[a-zA-Z]{2,}\b)',
      caseSensitive: false,
    );
    return linkRegex.hasMatch(message!);
  }

  List<String> get extractPhoneNumbers {
    if (message == null) return [];
    final phoneRegex = RegExp(r'(\+?[\d\s\-\(\)]{10,})');
    return phoneRegex
        .allMatches(message!)
        .map((match) => match.group(0)!)
        .toList();
  }

  List<String> get extractLinks {
    if (message == null) return [];
    final linkRegex = RegExp(
      r'(https?:\/\/[^\s]+|www\.[^\s]+|\b[\w\.]+@[\w\.]+\.[a-zA-Z]{2,}\b)',
      caseSensitive: false,
    );
    return linkRegex
        .allMatches(message!)
        .map((match) => match.group(0)!)
        .toList();
  }

  // Enhanced message type detection
  String get detectedContentType {
    if (hasFile) {
      if (isAudio) return 'audio';
      if (isVideo) return 'video';
      if (isImage) return 'image';
      return 'document';
    }
    if (containsLinks) return 'link';
    if (containsPhoneNumber) return 'phone';
    return 'text';
  }

  // Copy with method for updating properties
  ChatMessage copyWith({
    int? id,
    int? groupId,
    int? userId,
    String? message,
    String? createdAt,
    String? senderName,
    String? senderAvatar,
    bool? hasCall,
    bool? hasFile,
    bool? hasMessage,
    String? fileUrl,
    String? fileType,
    String? fileName,
    double? fileSize,
    List<MessageReaction>? reactions,
    bool? isPinned,
    int? replyToMessageId,
    ChatMessage? repliedMessage,
    bool? isDeleted,
    int? callId,
    bool? isCallEnded,
    String? callUrl,
    // WebSocket and optimistic update fields
    bool? isPending,
    bool? isFailed,
    String? messageType,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      userId: userId ?? this.userId,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      senderName: senderName ?? this.senderName,
      senderAvatar: senderAvatar ?? this.senderAvatar,
      hasCall: hasCall ?? this.hasCall,
      hasFile: hasFile ?? this.hasFile,
      hasMessage: hasMessage ?? this.hasMessage,
      fileUrl: fileUrl ?? this.fileUrl,
      fileType: fileType ?? this.fileType,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      reactions: reactions ?? this.reactions,
      isPinned: isPinned ?? this.isPinned,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      repliedMessage: repliedMessage ?? this.repliedMessage,
      isDeleted: isDeleted ?? this.isDeleted,
      callId: callId ?? this.callId,
      isCallEnded: isCallEnded ?? this.isCallEnded,
      callUrl: callUrl ?? this.callUrl,
      // WebSocket and optimistic update fields
      isPending: isPending ?? this.isPending,
      isFailed: isFailed ?? this.isFailed,
      messageType: messageType ?? this.messageType,
    );
  }

  @override
  String toString() {
    return 'ChatMessage{id: $id, groupId: $groupId, userId: $userId, message: $message, hasFile: $hasFile, fileType: $fileType, fileName: $fileName, isPending: $isPending, isFailed: $isFailed, messageType: $messageType}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatMessage &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          groupId == other.groupId &&
          userId == other.userId;

  @override
  int get hashCode => id.hashCode ^ groupId.hashCode ^ userId.hashCode;
}

// New model for message reactions
class MessageReaction {
  final String emoji;
  final int userId;
  final String userName;
  final DateTime createdAt;

  MessageReaction({
    required this.emoji,
    required this.userId,
    required this.userName,
    required this.createdAt,
  });

  factory MessageReaction.fromJson(Map<String, dynamic> json) {
    return MessageReaction(
      emoji: json['emoji'] ?? '❤️',
      userId: json['user_id'] ?? json['userId'] ?? 0,
      userName: json['user_name'] ?? json['userName'] ?? 'Unknown',
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'emoji': emoji,
      'user_id': userId,
      'user_name': userName,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Date for new chat day/date
  DateTime get date {
    try {
      return DateTime.parse(createdAt as String);
    } catch (e) {
      return DateTime.now();
    }
  }

  String get dateKey {
    final date = this.date;
    return "${date.year}-${date.month}-${date.day}";
  }
}
