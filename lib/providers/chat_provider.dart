// providers/chat_provider.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/chat_message.dart';
import '../services/chat_service.dart';

class ChatProvider with ChangeNotifier {
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isConnected = false;
  bool _isSending = false;
  bool _isTyping = false;
  String? _typingUserName;
  String? _error;
  int? _currentGroupId;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  final int _maxReconnectAttempts = 5;

  ChatMessage? _replyMessage;

  ChatMessage? get replyMessage => _replyMessage;

  // Track pending messages for optimistic updates
  final Map<int, ChatMessage> _pendingMessages = {};
  int _pendingMessageId = DateTime.now().millisecondsSinceEpoch;

  // Stream subscriptions
  StreamSubscription<Map<String, dynamic>>? _messageSubscription;
  StreamSubscription<bool>? _connectionSubscription;
  StreamSubscription<String>? _errorSubscription;

  List<ChatMessage> get messages {
    final allMessages = [..._messages];
    allMessages.addAll(_pendingMessages.values);
    allMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return allMessages;
  }

  bool get isLoading => _isLoading;
  bool get isConnected => _isConnected;
  bool get isSending => _isSending;
  bool get isTyping => _isTyping;
  String? get typingUserName => _typingUserName;
  String? get error => _error;
  int? get currentGroupId => _currentGroupId;
  bool _isPolling = false;
  Timer? _pollingFallbackTimer;
  final Duration _pollingFallbackDelay = Duration(
    seconds: 10,
  ); // Wait 10 seconds before starting polling

  // Initialize chat with WebSocket
  Future<void> initializeChat(int groupId) async {
    try {
      _isLoading = true;
      _error = null;
      _currentGroupId = groupId;
      notifyListeners();

      print('🚀 Initializing chat for group: $groupId');

      // Set up WebSocket listeners FIRST
      _setupWebSocketListeners();

      // polling second
      _setupPollingListeners();
      // Then connect to WebSocket
      await ChatService.initializeWebSocket(groupId);

      // Load existing messages
      await _loadExistingMessages(groupId);

      // polling as backup

      _startPollingFallback(groupId);

      _isLoading = false;
      notifyListeners();

      print('✅ Chat initialized successfully for group: $groupId');
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      print('❌ Error initializing chat: $e');

      // if websocket fails start polling

      _startPolling(groupId);
    }
  }

  void _setupWebSocketListeners() {
    // Listen for connection changes
    ChatService.connectionChanges.listen((connected) {
      if (connected) {
        print('✅ WebSocket connected - resetting reconnect attempts');
        _reconnectAttempts = 0;
        _reconnectTimer?.cancel();
      } else {
        print('🔌 WebSocket disconnected - attempting reconnect');
        _scheduleReconnect();
      }
    });

    // Listen for errors
    ChatService.webSocketErrors.listen((error) {
      print('❌ WebSocket error: $error');
      _scheduleReconnect();
    });

    // Listen for messages
    ChatService.webSocketMessages.listen((event) {
      print('📨 WebSocket message received: ${event['type']}');
      _handleWebSocketMessage(event);
    });
  }

  void _setupPollingListeners() {
    // Listen for polling messages
    ChatService.pollingMessages.listen((event) {
      print('📨 Polling message received: ${event['type']}');
      _handleWebSocketMessage(event); // Reuse the same handler
    });
  }

  void _scheduleReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      print('❌ Max reconnect attempts reached');
      return;
    }

    _reconnectTimer?.cancel();

    final delay = Duration(
      seconds: _reconnectAttempts * 2 + 1,
    ); // 1, 3, 5, 7, 9 seconds
    print(
      '🔄 Scheduling reconnect in ${delay.inSeconds} seconds (attempt ${_reconnectAttempts + 1})',
    );

    _reconnectTimer = Timer(delay, () {
      _reconnectAttempts++;
      _reconnect();
    });
  }

  Future<void> _reconnect() async {
    if (_currentGroupId != null) {
      print('🔄 Attempting to reconnect to group: $_currentGroupId');
      try {
        await ChatService.initializeWebSocket(_currentGroupId!);

        // If reconnect successful and polling was active, stop polling
        if (_isPolling) {
          print('✅ WebSocket reconnected - stopping polling');
          _stopPolling();
        }
      } catch (e) {
        print('❌ Reconnect failed: $e');

        // If reconnect fails and polling isn't active, start polling
        if (!_isPolling) {
          print('🔄 Starting polling after reconnect failure');
          _startPolling(_currentGroupId!);
        }
        _scheduleReconnect();
      }
    }
  }

  void _startPollingFallback(int groupId) {
    _pollingFallbackTimer?.cancel();

    _pollingFallbackTimer = Timer(_pollingFallbackDelay, () {
      // If WebSocket isn't connected after the delay, start polling
      if (!_isConnected && !_isPolling) {
        print('🔄 WebSocket not connected, starting polling fallback');
        _startPolling(groupId);
      }
    });
  }

  void _startPolling(int groupId) {
    if (_isPolling) {
      return;
    }

    print('🔄 Starting polling for group: $groupId');
    _isPolling = true;
    ChatService.startPolling(groupId);
    notifyListeners();
  }

  void _stopPolling() {
    if (_isPolling) {
      print('🛑 Stopping polling');
      _isPolling = false;
      ChatService.stopPolling();
      _pollingFallbackTimer?.cancel();
      notifyListeners();
    }
  }

  void _handleWebSocketEvent(Map<String, dynamic> event) {
    try {
      switch (event['type']) {
        case 'new_message':
          _handleNewMessage(event['data']);
          break;
        case 'subscription_succeeded':
          _handleSubscriptionSuccess(event['channel']);
          break;
        case 'connected':
          _handleConnectionChange(true);
          break;
        case 'disconnected':
          _handleConnectionChange(false);
          break;
        case 'typing_start':
          _handleTypingStart(event['data']);
          break;
        case 'typing_stop':
          _handleTypingStop(event['data']);
          break;
        case 'message_deleted':
          _handleMessageDeleted(event['data']);
          break;
        case 'message_reacted':
          _handleMessageReaction(event['data']);
          break;
        default:
          print('🔔 Unhandled WebSocket event: ${event['type']}');
      }
    } catch (e) {
      print('❌ Error handling WebSocket event: $e');
    }
  }

  void _handleWebSocketMessage(Map<String, dynamic> event) {
    try {
      switch (event['type']) {
        case 'new_message':
          _handleNewMessage(event['data']);
          break;
        case 'subscription_succeeded':
          print('✅ WebSocket subscription confirmed');
          break;
        case 'typing_start':
          _handleTypingStart(event['data']);
          break;
        case 'typing_stop':
          _handleTypingStop(event['data']);
          break;
        default:
          print('🔔 Unhandled WebSocket event: ${event['type']}');
      }
    } catch (e) {
      print('❌ Error handling WebSocket message: $e');
    }
  }

  void _handleNewMessage(dynamic messageData) {
    try {
      print('🆕 New real-time message received: $messageData');

      final newMessage = ChatMessage.fromJson(messageData);

      // Check if message already exists
      if (!_messages.any((msg) => msg.id == newMessage.id)) {
        _messages.add(newMessage);
        _messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        notifyListeners();

        print(
          '✅ Real-time message added: ${newMessage.message} from ${newMessage.senderName}',
        );
      }
    } catch (e) {
      print('❌ Error handling new message: $e');
    }
  }

  void _handleTypingStart(dynamic data) {
    try {
      final typingData = data is String ? json.decode(data) : data;
      _isTyping = true;
      _typingUserName = typingData['user_name'] ?? 'Someone';
      notifyListeners();
      print('⌨️ $_typingUserName is typing...');
    } catch (e) {
      print('❌ Error handling typing start: $e');
    }
  }

  void _handleTypingStop(dynamic data) {
    _isTyping = false;
    _typingUserName = null;
    notifyListeners();
    print('⌨️ Typing stopped');
  }

  bool _isSameMessage(ChatMessage a, ChatMessage b) {
    return a.message == b.message &&
        a.userId == b.userId &&
        a.createdAt == b.createdAt;
  }

  void _removePendingMessageByContent(String messageContent) {
    final pendingKey = _pendingMessages.keys.firstWhere(
      (key) => _pendingMessages[key]?.message == messageContent,
      orElse: () => -1,
    );

    if (pendingKey != -1) {
      _pendingMessages.remove(pendingKey);
      print('✅ Confirmed optimistic update for: $messageContent');
    }
  }

  void _handleSubscriptionSuccess(String? channel) {
    print('✅ Successfully subscribed to channel: $channel');
    _isConnected = true;
    _error = null;
    notifyListeners();
  }

  void _handleConnectionChange(bool connected) {
    _isConnected = connected;
    if (connected) {
      // WebSocket connected - stop polling if it's active
      if (_isPolling) {
        print('✅ WebSocket connected - stopping polling');
        _stopPolling();
      }
      _error = null;
    } else {
      // WebSocket disconnected - start polling after a delay
      print('🔌 WebSocket disconnected - will start polling fallback');
      if (_currentGroupId != null && !_isPolling) {
        _startPollingFallback(_currentGroupId!);
      }
    }

    if (!connected) {
      _isTyping = false;
      _typingUserName = null;
    }

    notifyListeners();
    print(connected ? '✅ WebSocket connected' : '🔌 WebSocket disconnected');
  }

  // void _handleTypingStart(dynamic data) {
  //   try {
  //     final typingData = data is String ? json.decode(data) : data;
  //     _isTyping = true;
  //     _typingUserName = typingData['user_name'] ?? 'Someone';
  //     notifyListeners();
  //     print('⌨️ $_typingUserName is typing...');
  //   } catch (e) {
  //     print('❌ Error handling typing start: $e');
  //   }
  // }

  // void _handleTypingStop(dynamic data) {
  //   _isTyping = false;
  //   _typingUserName = null;
  //   notifyListeners();
  //   print('⌨️ Typing stopped');
  // }

  void setReplyMessage(ChatMessage message) {
    _replyMessage = message;
    notifyListeners();
    print('💬 Replying to message: ${message.message}');
  }

  void clearReplyMessage() {
    _replyMessage = null;
    notifyListeners();
    print('💬 Reply cleared');
  }

  // Copy message to clipboard
  Future<void> copyMessage(ChatMessage message) async {
    if (message.message != null && message.message!.isNotEmpty) {
      // You'll need to import 'package:flutter/services.dart'
      await Clipboard.setData(ClipboardData(text: message.message!));
      print('📋 Message copied to clipboard');
    }
  }

  Future<bool> pinMessage(int messageId) async {
    try {
      print('📌 Pinning message: $messageId');

      // First unpin any currently pinned message
      for (int i = 0; i < _messages.length; i++) {
        // if (_messages[i].isPinned == true) {
        //   _messages[i] = _messages[i].copyWith(isPinned: false);
        // }
      }

      // Pin the new message
      final messageIndex = _messages.indexWhere((msg) => msg.id == messageId);
      if (messageIndex != -1) {
        // _messages[messageIndex] = _messages[messageIndex].copyWith(isPinned: true);
        notifyListeners();
      }

      // Your actual API call would go here
      return true;
    } catch (e) {
      print('❌ Error pinning message: $e');
      return false;
    }
  }

  Future<bool> reactToMessage({
    required int messageId,
    required String emoji,
    required int userId,
    required String userName,
  }) async {
    try {
      print('❤️ Reacting to message $messageId with $emoji');

      // Update locally immediately
      final messageIndex = _messages.indexWhere((msg) => msg.id == messageId);
      if (messageIndex != -1) {
        // Add reaction logic here
        notifyListeners();
      }

      // Your actual API call would go here
      return true;
    } catch (e) {
      print('❌ Error reacting to message: $e');
      return false;
    }
  }

  void _handleMessageDeleted(dynamic data) {
    try {
      final deleteData = data is String ? json.decode(data) : data;
      final messageId = deleteData['message_id'];

      _messages.removeWhere((msg) => msg.id == messageId);
      notifyListeners();

      print('🗑️ Message deleted: $messageId');
    } catch (e) {
      print('❌ Error handling message deletion: $e');
    }
  }

  void _handleMessageReaction(dynamic data) {
    try {
      final reactionData = data is String ? json.decode(data) : data;
      final messageId = reactionData['message_id'];
      final emoji = reactionData['emoji'];
      final userId = reactionData['user_id'];
      final userName = reactionData['user_name'];

      // Find the message and update reactions
      final messageIndex = _messages.indexWhere((msg) => msg.id == messageId);
      if (messageIndex != -1) {
        // Your reaction handling logic here
        notifyListeners();
        print('❤️ Reaction added: $emoji to message $messageId by $userName');
      }
    } catch (e) {
      print('❌ Error handling message reaction: $e');
    }
  }

  void _handleWebSocketError(String error) {
    print('❌ WebSocket error: $error');
    _error = error;
    _isConnected = false;
    notifyListeners();
  }

  // Load existing messages via REST API
  Future<void> _loadExistingMessages(int groupId) async {
    try {
      print('📥 Loading existing messages for group: $groupId');

      final response = await ChatService.getGroupMessages(groupId);

      if (response.status == 'success' && response.data != null) {
        _messages = response.data!;
        notifyListeners();
        print('✅ Loaded ${_messages.length} existing messages');
      } else {
        print('❌ Failed to load messages: ${response.message}');
      }
    } catch (e) {
      print('❌ Error loading existing messages: $e');
    }
  }

  // Enhanced send message with better optimistic updates
  Future<bool> sendMessage({
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
      _isSending = true;
      notifyListeners();

      print('📤 Sending message: $message');

      // Check if this is a reply and prepare reply data
      final bool isReply = _replyMessage != null;
      final int? repliedToMessageId = isReply ? _replyMessage!.id : null;
      final String? repliedToMessageText = isReply
          ? _replyMessage!.message
          : null;
      final String? repliedToSenderName = isReply
          ? _replyMessage!.senderName
          : null;

      // Create optimistic message WITH reply data
      final optimisticMessage = ChatMessage(
        id: _pendingMessageId++,
        groupId: groupId,
        userId: userId,
        message: message,
        createdAt: DateTime.now().toIso8601String(),
        senderName: 'You',
        messageType: messageType,
        fileUrl: fileUrl,
        fileType: fileType,
        fileName: fileName,
        fileSize: fileSize,
        isPending: true,
        isFailed: false,
        // Add reply information if available
        repliedToMessageId: repliedToMessageId,
        repliedToMessageText: repliedToMessageText,
        repliedToSenderName: repliedToSenderName,
        hasReply: isReply,
      );

      // Add to pending messages for optimistic update
      _pendingMessages[optimisticMessage.id] = optimisticMessage;
      notifyListeners();

      bool success = false;

      // Try WebSocket first if connected
      if (ChatService.isWebSocketConnected) {
        print('🔄 Sending via WebSocket...');
        ChatService.sendMessageViaWebSocket(
          groupId: groupId,
          message: message,
          userId: userId,
          messageType: messageType,
          fileUrl: fileUrl,
          fileType: fileType,
          fileName: fileName,
          fileSize: fileSize,
          // Pass reply information
          repliedToMessageId: repliedToMessageId,
          repliedToMessageText: repliedToMessageText,
          repliedToSenderName: repliedToSenderName,
        );

        // Clear the reply after sending
        if (isReply) {
          _replyMessage = null;
        }

        _setMessageTimeout(optimisticMessage.id);
        success = true;
      } else {
        // Fall back to REST API
        print('🔄 WebSocket not connected, falling back to REST API...');
        final response = await ChatService.sendMessage(
          groupId: groupId,
          message: message,
          userId: userId,
          messageType: messageType,
          fileUrl: fileUrl,
          fileType: fileType,
          fileName: fileName,
          fileSize: fileSize,
          // Pass reply information
          repliedToMessageId: repliedToMessageId,
          repliedToMessageText: repliedToMessageText,
          repliedToSenderName: repliedToSenderName,
        );

        success = response.status == 'success';

        if (success) {
          // Remove from pending and add to actual messages
          _pendingMessages.remove(optimisticMessage.id);
          if (response.data != null) {
            _messages.add(response.data!);
          }
          _messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

          // Clear the reply after successful send
          if (isReply) {
            _replyMessage = null;
          }
        } else {
          // Mark as failed
          // optimisticMessage.isFailed = true;
        }
      }

      _isSending = false;
      notifyListeners();

      if (success) {
        print('✅ Message sent successfully');
        return true;
      } else {
        print('❌ Failed to send message');
        return false;
      }
    } catch (e) {
      _isSending = false;
      _error = 'Failed to send message: $e';
      notifyListeners();
      print('❌ Error sending message: $e');
      return false;
    }
  }

  void _setMessageTimeout(int messageId) {
    // If we don't receive a server echo within 5 seconds, fall back to REST
    Timer(Duration(seconds: 5), () {
      if (_pendingMessages.containsKey(messageId)) {
        print(
          '⏰ No WebSocket echo received for message $messageId, falling back to REST',
        );
        _fallbackToRestApi(messageId);
      }
    });
  }

  void _fallbackToRestApi(int pendingMessageId) async {
    final pendingMessage = _pendingMessages[pendingMessageId];
    if (pendingMessage == null) return;

    print('🔄 Falling back to REST API for message: ${pendingMessage.message}');

    try {
      final response = await ChatService.sendMessage(
        groupId: pendingMessage.groupId,
        message: pendingMessage.message ?? '',
        userId: pendingMessage.userId,
        messageType: pendingMessage.messageType ?? 'text',
        fileUrl: pendingMessage.fileUrl,
        fileType: pendingMessage.fileType,
        fileName: pendingMessage.fileName,
        fileSize: pendingMessage.fileSize,
      );

      if (response.status == 'success') {
        // Remove from pending and add to actual messages
        _pendingMessages.remove(pendingMessageId);
        if (response.data != null) {
          _messages.add(response.data!);
        }
        _messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        print('✅ Message sent via REST API fallback');
      } else {
        // Mark as failed
        // pendingMessage.isFailed = true;
        print('❌ REST API fallback failed');
      }

      notifyListeners();
    } catch (e) {
      print('❌ REST API fallback error: $e');
      // pendingMessage.isFailed = true;
      notifyListeners();
    }
  }

  // Send typing indicators
  void sendTypingStart(int groupId, int userId, String userName) {
    try {
      ChatService.sendTypingIndicator(true, groupId, userId, userName);
    } catch (e) {
      print('❌ Error sending typing start: $e');
    }
  }

  void sendTypingStop(int groupId, int userId) {
    try {
      ChatService.sendTypingIndicator(false, groupId, userId, '');
    } catch (e) {
      print('❌ Error sending typing stop: $e');
    }
  }

  // Add message locally (for optimistic updates)
  void addMessage(ChatMessage message) {
    if (!_messages.any((msg) => msg.id == message.id)) {
      _messages.add(message);
      _messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      notifyListeners();
      print('➕ Added local message: ${message.message}');
    }
  }

  // Remove message (for failed uploads, etc.)
  void removeMessage(int messageId) {
    _messages.removeWhere((msg) => msg.id == messageId);
    _pendingMessages.remove(messageId);
    notifyListeners();
    print('➖ Removed message: $messageId');
  }

  // Update message (for reactions, edits, etc.)
  void updateMessage(ChatMessage updatedMessage) {
    final index = _messages.indexWhere((msg) => msg.id == updatedMessage.id);
    if (index != -1) {
      _messages[index] = updatedMessage;
      notifyListeners();
      print('✏️ Updated message: ${updatedMessage.id}');
    }
  }

  // Clear all messages
  void clearMessages() {
    _messages.clear();
    _pendingMessages.clear();
    notifyListeners();
    print('🧹 Cleared all messages');
  }

  // Get message by ID
  ChatMessage? getMessageById(int messageId) {
    return _messages.firstWhere((msg) => msg.id == messageId);
  }

  // Your existing methods
  // Future<bool> reactToMessage({
  //   required int messageId,
  //   required String emoji,
  //   required int userId,
  //   required String userName,
  // }) async {
  //   try {
  //     // Your reaction implementation
  //     print('❤️ Reacting to message $messageId with $emoji');

  //     // For now, return success - implement your actual API call
  //     return true;
  //   } catch (e) {
  //     print('❌ Error reacting to message: $e');
  //     return false;
  //   }
  // }

  Future<bool> deleteMessage(int messageId) async {
    try {
      // Your delete implementation
      print('🗑️ Deleting message: $messageId');

      // Remove locally immediately
      removeMessage(messageId);

      // Your actual API call would go here
      return true;
    } catch (e) {
      print('❌ Error deleting message: $e');
      return false;
    }
  }

  // Future<bool> pinMessage(int messageId) async {
  //   try {
  //     // Your pin implementation
  //     print('📌 Pinning message: $messageId');
  //     return true;
  //   } catch (e) {
  //     print('❌ Error pinning message: $e');
  //     return false;
  //   }
  // }

  // Reconnect WebSocket
  Future<void> reconnect() async {
    if (_currentGroupId != null) {
      await initializeChat(_currentGroupId!);
    }
  }

  // Cleanup
  @override
  void dispose() {
    print('🔄 Disposing ChatProvider');

    _messageSubscription?.cancel();
    _connectionSubscription?.cancel();
    _errorSubscription?.cancel();
    _reconnectTimer?.cancel();
    _pollingFallbackTimer?.cancel();

    // Stop polling when provider is disposed
    _stopPolling();

    ChatService.disconnectWebSocket();
    ChatService.stopPolling(); // Double ensure polling is stopped

    super.dispose();
  }

  bool get isPolling => _isPolling;

  // Update debug method to show polling status
  void debugState() {
    print('🔍 ChatProvider Debug:');
    print('  - Messages count: ${_messages.length}');
    print('  - Pending messages: ${_pendingMessages.length}');
    print('  - Loading: $_isLoading');
    print('  - Connected: $_isConnected');
    print('  - Polling: $_isPolling'); // Add this line
    print('  - Sending: $_isSending');
    print('  - Typing: $_isTyping');
    print('  - Typing User: $_typingUserName');
    print('  - Error: $_error');
    print('  - Current Group: $_currentGroupId');

    // Print last 3 messages
    final allMessages = messages;
    for (var i = allMessages.length - 3; i < allMessages.length; i++) {
      if (i >= 0) {
        final msg = allMessages[i];
        final status = msg.isPending == true
            ? '⏳'
            : msg.isFailed == true
            ? '❌'
            : '✅';
        print(
          '  - $status Message ${i + 1}: "${msg.message}" (${msg.senderName})',
        );
      }
    }
  }
}
