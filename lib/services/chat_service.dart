// services/chat_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:edify_app/services/chat_websocket_manager.dart';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import '../models/chat_message.dart';
import '../models/api_response.dart';
import 'package:http_parser/http_parser.dart';

class ChatService {
  // WebSocket Manager Instance
  static final ChatWebSocketManager _webSocketManager = ChatWebSocketManager();

  // Polling variables
  static Timer? _pollingTimer;
  static bool _isPolling = false;
  static int? _currentPollingGroupId;
  static DateTime? _lastMessageTimestamp;
  static final Duration _pollingInterval = Duration(
    seconds: 3,
  ); // Poll every 3 seconds

  static ChatWebSocketManager get webSocketManager => _webSocketManager;

  // Initialize WebSocket for a group
  static Future<void> initializeWebSocket(int groupId) async {
    await _webSocketManager.connectToGroup(groupId);
  }

  // Get WebSocket connection status
  static bool get isWebSocketConnected => _webSocketManager.isConnected;

  static bool get isPollingActive => _isPolling;

  // Get current polling group ID
  static int? get currentPollingGroupId => _currentPollingGroupId;

  // Listen for real-time messages
  static Stream<Map<String, dynamic>> get webSocketMessages =>
      _webSocketManager.onMessage;

  // Listen for connection changes
  static Stream<bool> get connectionChanges =>
      _webSocketManager.onConnectionChange;

  // Listen for errors
  static Stream<String> get webSocketErrors => _webSocketManager.onError;

  // Stream for polling messages (add this to your class)
  static final StreamController<Map<String, dynamic>>
  _pollingMessageController =
      StreamController<Map<String, dynamic>>.broadcast();

  static Stream<Map<String, dynamic>> get pollingMessages =>
      _pollingMessageController.stream;

  // Disconnect WebSocket
  static Future<void> disconnectWebSocket() async {
    await _webSocketManager.disconnect();
  }

  static void startPolling(int groupId) {
    if (_isPolling && _currentPollingGroupId == groupId) {
      print('🔄 Polling already active for group: $groupId');
      return;
    }

    print('🔄 Starting polling for group: $groupId');

    _stopPolling(); // Stop any existing polling

    _currentPollingGroupId = groupId;
    _isPolling = true;
    _lastMessageTimestamp = DateTime.now().subtract(
      Duration(hours: 1),
    ); // Start from 1 hour ago

    // Start immediate poll
    _performPoll();

    // Set up periodic polling
    _pollingTimer = Timer.periodic(_pollingInterval, (timer) {
      if (_isPolling) {
        _performPoll();
      }
    });

    print('✅ Polling started for group: $groupId');
  }

  // Stop polling
  static void stopPolling() {
    _stopPolling();
  }

  static void _stopPolling() {
    print('🛑 Stopping polling');

    _pollingTimer?.cancel();
    _pollingTimer = null;
    _isPolling = false;
    _currentPollingGroupId = null;
    _lastMessageTimestamp = null;
  }

  // Perform a single poll
  static Future<void> _performPoll() async {
    if (!_isPolling || _currentPollingGroupId == null) {
      return;
    }

    try {
      print('📡 Polling for new messages in group: $_currentPollingGroupId');

      final response = await getGroupMessages(_currentPollingGroupId!);

      if (response.status == 'success' && response.data != null) {
        final messages = response.data!;

        if (messages.isNotEmpty) {
          // Filter messages that are newer than our last timestamp
          final newMessages = _lastMessageTimestamp != null
              ? messages.where((msg) {
                  try {
                    final messageTime = DateTime.parse(msg.createdAt);
                    return messageTime.isAfter(_lastMessageTimestamp!);
                  } catch (e) {
                    return true; // If we can't parse, include it
                  }
                }).toList()
              : messages;

          if (newMessages.isNotEmpty) {
            print('📨 Polling found ${newMessages.length} new messages');

            // Update last timestamp to the newest message
            try {
              final newestMessage = newMessages.reduce((a, b) {
                final timeA = DateTime.parse(a.createdAt);
                final timeB = DateTime.parse(b.createdAt);
                return timeA.isAfter(timeB) ? a : b;
              });
              _lastMessageTimestamp = DateTime.parse(newestMessage.createdAt);
            } catch (e) {
              _lastMessageTimestamp = DateTime.now();
            }

            // Emit polling events for new messages
            for (final message in newMessages) {
              _emitPollingMessage(message);
            }
          }
        }
      }
    } catch (e) {
      print('❌ Polling error: $e');
      // Don't stop polling on error - just try again next interval
    }
  }

  // Emit polling messages in the same format as WebSocket
  static void _emitPollingMessage(ChatMessage message) {
    print('📨 Polling emitting message: ${message.id}');

    // Convert to the same format as WebSocket messages
    final eventData = {'type': 'new_message', 'data': message.toJson()};

    // You'll need to add this stream controller to emit polling events
    _pollingMessageController.add(eventData);
  }

  // Send message via WebSocket - FIXED VERSION
  static void sendMessageViaWebSocket({
    required int groupId,
    required String message,
    required int userId,
    String messageType = 'text',
    String? fileUrl,
    String? fileType,
    String? fileName,
    double? fileSize,
    int? repliedToMessageId,
    String? repliedToSenderName,
    String? repliedToMessageText,
  }) {
    _webSocketManager.sendChatMessage(
      groupId: groupId,
      message: message,
      userId: userId,
      messageType: messageType,
      fileUrl: fileUrl,
      fileType: fileType,
      fileName: fileName,
      fileSize: fileSize,
    );
  }

  // Send typing indicator via WebSocket
  static void sendTypingIndicator(
    bool isTyping,
    int groupId,
    int userId,
    String userName,
  ) {
    _webSocketManager.sendTypingIndicator(isTyping, userId, userName);
  }

  // Get existing group messages (REST API - your existing method)
  static Future<ApiResponse<List<ChatMessage>>> getGroupMessages(
    int groupId,
  ) async {
    try {
      final response = await ApiService.get('groups/$groupId/messages');

      if (response is List) {
        final messages = response
            .map((messageData) {
              try {
                // print('📥 Message data: $messageData');
                final message = ChatMessage.fromJson(messageData);
                // print(
                //   '📥 Parsed message - ID: ${message.id}, HasFile: ${message.hasFile}, FileUrl: ${message.fileUrl}',
                // );
                return message;
              } catch (e) {
                // print('❌ Skipping invalid message: $e');
                return null;
              }
            })
            .where((message) => message != null)
            .cast<ChatMessage>()
            .toList();

        messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

        return ApiResponse<List<ChatMessage>>(
          status: 'success',
          message: 'Success',
          data: messages,
        );
      } else if (response is Map<String, dynamic>) {
        final data = response['data'];
        if (data is List) {
          final messages = data
              .map((messageData) {
                try {
                  return ChatMessage.fromJson(messageData);
                } catch (e) {
                  print('❌ Skipping invalid message: $e');
                  return null;
                }
              })
              .where((message) => message != null)
              .cast<ChatMessage>()
              .toList();

          messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

          return ApiResponse<List<ChatMessage>>(
            status: response['status']?.toString() ?? 'success',
            message: response['message']?.toString() ?? 'Success',
            data: messages,
          );
        }
      }

      return ApiResponse<List<ChatMessage>>(
        status: 'error',
        message: 'Unexpected response format',
        data: [],
      );
    } catch (e) {
      print('❌ ChatService Error: $e');
      return ApiResponse<List<ChatMessage>>(
        status: 'error',
        message: e.toString(),
        data: [],
      );
    }
  }

  // Send message (REST API - your existing method)
  static Future<ApiResponse<ChatMessage>> sendMessage({
    required int groupId,
    required String message,
    required int userId,
    String messageType = 'text',
    String? fileUrl,
    String? fileType,
    String? fileName,
    double? fileSize,
    // Add these parameters for replies
    int? repliedToMessageId,
    String? repliedToMessageText,
    String? repliedToSenderName,
  }) async {
    try {
      final Map<String, dynamic> requestBody = {
        'user_id': userId,
        'message': message,
        'message_type': messageType,
      };

      // Add file information if available
      if (fileUrl != null) {
        requestBody['file_url'] = fileUrl;
      }
      if (fileType != null) {
        requestBody['file_type'] = fileType;
      }
      if (fileName != null) {
        requestBody['file_name'] = fileName;
      }
      if (fileSize != null) {
        requestBody['file_size'] = fileSize;
      }

      // Add reply information if available
      if (repliedToMessageId != null) {
        requestBody['replied_to_message_id'] = repliedToMessageId;
      }
      if (repliedToMessageText != null) {
        requestBody['replied_to_message_text'] = repliedToMessageText;
      }
      if (repliedToSenderName != null) {
        requestBody['replied_to_sender_name'] = repliedToSenderName;
      }

      final response = await ApiService.post(
        'groups/$groupId/messages',
        requestBody,
      );

      if (response is Map<String, dynamic>) {
        final status = response['status']?.toString();

        if (status == 'success') {
          final data = response['data'];
          if (data is Map<String, dynamic>) {
            final chatMessage = ChatMessage.fromJson(data);
            return ApiResponse<ChatMessage>(
              status: 'success',
              message: 'Message sent',
              data: chatMessage,
            );
          }
        }
      }

      // Fallback - create local message with file info
      final fallbackMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch,
        groupId: groupId,
        userId: userId,
        message: message,
        createdAt: DateTime.now().toIso8601String(),
        senderName: 'You',
        hasFile: fileUrl != null,
        fileUrl: fileUrl,
        fileType: fileType,
        fileName: fileName,
        fileSize: fileSize,
        // Include reply data in fallback
        repliedToMessageId: repliedToMessageId,
        repliedToMessageText: repliedToMessageText,
        repliedToSenderName: repliedToSenderName,
        hasReply: repliedToMessageId != null,
      );

      return ApiResponse<ChatMessage>(
        status: 'success',
        message: 'Message sent',
        data: fallbackMessage,
      );
    } catch (e) {
      print('❌ Send message API error: $e');
      return ApiResponse<ChatMessage>(
        status: 'error',
        message: 'Failed to send: $e',
        data: null,
      );
    }
  }

  // Hybrid send message - tries WebSocket first, falls back to REST
  static Future<bool> sendMessageHybrid({
    required int groupId,
    required String message,
    required int userId,
    String messageType = 'text',
    String? fileUrl,
    String? fileType,
    String? fileName,
    double? fileSize,
  }) async {
    try {
      // Try WebSocket first if connected
      if (_webSocketManager.isConnected) {
        sendMessageViaWebSocket(
          groupId: groupId,
          message: message,
          userId: userId,
          messageType: messageType,
          fileUrl: fileUrl,
          fileType: fileType,
          fileName: fileName,
          fileSize: fileSize,
        );
        return true;
      } else {
        // Fall back to REST API
        final response = await sendMessage(
          groupId: groupId,
          message: message,
          userId: userId,
          messageType: messageType,
          fileUrl: fileUrl,
          fileType: fileType,
          fileName: fileName,
          fileSize: fileSize,
        );
        return response.status == 'success';
      }
    } catch (e) {
      print('❌ Hybrid send message error: $e');
      return false;
    }
  }

  // File upload methods (your existing methods)
  static Future<ApiResponse<String>> uploadFile(
    File file, {
    required int groupId,
  }) async {
    try {
      print('📤 Uploading file: ${file.path} for group: $groupId');

      // Read file as bytes
      final bytes = await file.readAsBytes();
      final fileName = file.path.split('/').last;
      final fileSize = bytes.length;
      final fileType = _getMimeType(fileName);

      print('📤 File details:');
      print('   Name: $fileName');
      print('   Size: $fileSize bytes');
      print('   Type: $fileType');
      print('   Group ID: $groupId');

      final Map<String, dynamic> payload = {
        'group_id': groupId.toString(),
        'file': base64Encode(bytes),
        'filename': fileName,
        'size': fileSize.toString(),
        'mimetype': fileType,
        'message': 'Shared a file: $fileName',
      };

      print('🔄 Sending to endpoint: groups/file/upload');
      print('🔄 Payload fields: ${payload.keys}');

      final response = await ApiService.post('groups/file/upload', payload);

      print('📡 Upload response: $response');

      if (response is Map<String, dynamic>) {
        final status = response['status']?.toString();

        if (status == 'success') {
          final fileUrl =
              response['file_url']?.toString() ??
              response['url']?.toString() ??
              response['data']?.toString() ??
              response['path']?.toString();

          if (fileUrl != null) {
            print('✅ File uploaded successfully: $fileUrl');
            return ApiResponse<String>(
              status: 'success',
              message: 'File uploaded successfully',
              data: fileUrl,
            );
          }
        }

        return ApiResponse<String>(
          status: 'error',
          message: response['message']?.toString() ?? 'Upload failed',
          data: null,
        );
      }

      return ApiResponse<String>(
        status: 'error',
        message: 'Invalid response format',
        data: null,
      );
    } catch (e) {
      print('❌ File upload error: $e');
      return ApiResponse<String>(
        status: 'error',
        message: 'Upload failed: $e',
        data: null,
      );
    }
  }

  static Future<ApiResponse<String>> uploadFileMultipart(
    File file, {
    required int groupId,
    String? customMessage,
  }) async {
    try {
      print('📤 Uploading via multipart: ${file.path} for group: $groupId');

      final uri = Uri.parse('${ApiService.baseUrl}/groups/file/upload');
      var request = http.MultipartRequest('POST', uri);

      // Add headers
      final headers = await ApiService.getHeaders();
      request.headers.addAll(Map<String, String>.from(headers));

      // Remove Content-Type from headers for multipart
      request.headers.remove('Content-Type');

      // Add file
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
          filename: file.path.split('/').last,
        ),
      );

      // Add required fields
      request.fields['group_id'] = groupId.toString();

      // Add message field
      if (customMessage != null) {
        request.fields['message'] = customMessage;
      } else {
        final fileName = file.path.split('/').last;
        final fileType = _getMimeType(fileName);

        if (fileType.startsWith('image/')) {
          request.fields['message'] = 'Shared an image';
        } else if (fileType.startsWith('video/')) {
          request.fields['message'] = 'Shared a video';
        } else if (fileType.startsWith('audio/')) {
          request.fields['message'] = 'Shared an audio file';
        } else {
          request.fields['message'] = 'Shared a file';
        }
      }

      print('🔄 Sending multipart request to: ${uri.toString()}');
      print('🔄 Request fields: ${request.fields}');

      // Send request
      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      print('📡 Multipart response status: ${response.statusCode}');
      print('📡 Multipart response body: $responseData');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = json.decode(responseData);

        final message =
            jsonResponse['message']?.toString() ?? 'File uploaded successfully';

        print('✅ Backend response: $message');

        return ApiResponse<String>(
          status: 'success',
          message: message,
          data: 'upload_success',
        );
      }

      return ApiResponse<String>(
        status: 'error',
        message: 'Upload failed with status ${response.statusCode}',
        data: null,
      );
    } catch (e) {
      print('❌ Multipart upload error: $e');
      return ApiResponse<String>(
        status: 'error',
        message: 'Multipart upload failed: $e',
        data: null,
      );
    }
  }

  // Helper method to get MIME type
  static String _getMimeType(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;

    final mimeTypes = {
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'png': 'image/png',
      'gif': 'image/gif',
      'pdf': 'application/pdf',
      'doc': 'application/msword',
      'docx':
          'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'xls': 'application/vnd.ms-excel',
      'xlsx':
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'mp3': 'audio/mpeg',
      'wav': 'audio/wav',
      'mp4': 'video/mp4',
      'mov': 'video/quicktime',
      'txt': 'text/plain',
    };

    return mimeTypes[extension] ?? 'application/octet-stream';
  }

  // Test method for WebSocket
  static void testWebSocketConnection(int groupId) async {
    print('🧪 Testing WebSocket connection for group: $groupId');

    try {
      await _webSocketManager.connectToGroup(groupId);

      // Listen for test messages
      _webSocketManager.onMessage.listen((event) {
        print('✅ WebSocket test successful: ${event['type']}');
      });

      _webSocketManager.onConnectionChange.listen((connected) {
        print('🔌 WebSocket connection: $connected');
      });
    } catch (e) {
      print('❌ WebSocket test failed: $e');
    }
  }
}
