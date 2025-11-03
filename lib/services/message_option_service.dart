import 'api_service.dart';
import '../models/api_response.dart';
import '../models/chat_message.dart';

class MessageOptionsService {
  // React to a message
  static Future<ApiResponse<dynamic>> reactToMessage({
    required int messageId,
    required String emoji,
    required int userId,
  }) async {
    try {
      final response = await ApiService.post('messages/$messageId/react', {
        'emoji': emoji,
        'user_id': userId,
      });

      return ApiResponse<dynamic>.fromJson(response, null);
    } catch (e) {
      return ApiResponse<dynamic>(
        status: 'error',
        message: e.toString(),
        data: null,
      );
    }
  }

  // Remove reaction from a message
  static Future<ApiResponse<dynamic>> removeReaction({
    required int messageId,
    required int userId,
  }) async {
    try {
      final response = await ApiService.delete(
        'messages/$messageId/reactions/$userId',
      );
      return ApiResponse<dynamic>.fromJson(response, null);
    } catch (e) {
      return ApiResponse<dynamic>(
        status: 'error',
        message: e.toString(),
        data: null,
      );
    }
  }

  // Reply to a message
  static Future<ApiResponse<ChatMessage>> replyToMessage({
    required int groupId,
    required String message,
    required int userId,
    required int replyToMessageId,
  }) async {
    try {
      final response = await ApiService.post('groups/$groupId/messages', {
        'user_id': userId,
        'message': message,
        'reply_to_message_id': replyToMessageId,
      });

      return ApiResponse<ChatMessage>.fromJson(
        response,
        (data) => ChatMessage.fromJson(data),
      );
    } catch (e) {
      return ApiResponse<ChatMessage>(
        status: 'error',
        message: e.toString(),
        data: null,
      );
    }
  }

  // Forward message to another group
  static Future<ApiResponse<ChatMessage>> forwardMessage({
    required int messageId,
    required int targetGroupId,
    required int userId,
  }) async {
    try {
      final response = await ApiService.post('messages/$messageId/forward', {
        'target_group_id': targetGroupId,
        'user_id': userId,
      });

      return ApiResponse<ChatMessage>.fromJson(
        response,
        (data) => ChatMessage.fromJson(data),
      );
    } catch (e) {
      return ApiResponse<ChatMessage>(
        status: 'error',
        message: e.toString(),
        data: null,
      );
    }
  }

  // Delete a message
  static Future<ApiResponse<dynamic>> deleteMessage(int messageId) async {
    try {
      final response = await ApiService.delete('messages/$messageId');
      return ApiResponse<dynamic>.fromJson(response, null);
    } catch (e) {
      return ApiResponse<dynamic>(
        status: 'error',
        message: e.toString(),
        data: null,
      );
    }
  }

  // Pin a message
  static Future<ApiResponse<dynamic>> pinMessage(int messageId) async {
    try {
      final response = await ApiService.post('messages/$messageId/pin', {});
      return ApiResponse<dynamic>.fromJson(response, null);
    } catch (e) {
      return ApiResponse<dynamic>(
        status: 'error',
        message: e.toString(),
        data: null,
      );
    }
  }

  // Unpin a message
  static Future<ApiResponse<dynamic>> unpinMessage(int messageId) async {
    try {
      final response = await ApiService.post('messages/$messageId/unpin', {});
      return ApiResponse<dynamic>.fromJson(response, null);
    } catch (e) {
      return ApiResponse<dynamic>(
        status: 'error',
        message: e.toString(),
        data: null,
      );
    }
  }

  // Get message details for reply
  static Future<ApiResponse<ChatMessage>> getMessageDetails(
    int messageId,
  ) async {
    try {
      final response = await ApiService.get('messages/$messageId');
      return ApiResponse<ChatMessage>.fromJson(
        response,
        (data) => ChatMessage.fromJson(data),
      );
    } catch (e) {
      return ApiResponse<ChatMessage>(
        status: 'error',
        message: e.toString(),
        data: null,
      );
    }
  }
}
