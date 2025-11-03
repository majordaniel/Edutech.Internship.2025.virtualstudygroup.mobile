// services/chat_websocket_manager.dart
import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/html.dart'
    if (dart.library.io) 'package:web_socket_channel/io.dart';

class ChatWebSocketManager {
  static final ChatWebSocketManager _instance =
      ChatWebSocketManager._internal();
  factory ChatWebSocketManager() => _instance;
  ChatWebSocketManager._internal();

  WebSocketChannel? _channel;
  bool _isConnected = false;
  String? _currentGroupId;
  String? _socketId;
  Timer? _pingTimer;
  Timer? _pongTimer;
  final Duration _pingInterval = Duration(seconds: 25); // Send ping every 25s
  final Duration _pongTimeout = Duration(
    seconds: 10,
  ); // Wait 10s for pong response

  // Stream controllers
  final StreamController<Map<String, dynamic>> _messageController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();
  final StreamController<String> _errorController =
      StreamController<String>.broadcast();

  // Public streams
  Stream<Map<String, dynamic>> get onMessage => _messageController.stream;
  Stream<bool> get onConnectionChange => _connectionController.stream;
  Stream<String> get onError => _errorController.stream;

  bool get isConnected => _isConnected;
  String? get socketId => _socketId;
  String? get currentGroupId => _currentGroupId;

  Future<void> connectToGroup(int groupId) async {
    try {
      if (_isConnected && _currentGroupId == groupId.toString()) {
        print('✅ Already connected to group $groupId');
        return;
      }

      await disconnect();

      print('🚀 Connecting to WebSocket for group: $groupId');

      _channel = WebSocketChannel.connect(
        Uri.parse(
          'wss://ediifyapi.tife.com.ng/app/ediify-key?protocol=7&client=js&version=8.4.0',
        ),
      );

      _currentGroupId = groupId.toString();
      _setupMessageHandlers();

      _startHeartbeat();

      _isConnected = true;
      _connectionController.add(true);

      print('✅ WebSocket connection established, waiting for subscription...');
    } catch (e) {
      print('❌ WebSocket connection failed: $e');
      _handleError('Connection failed: $e');
    }

    _startConnectionMonitoring();
  }

  void _startHeartbeat() {
    // Cancel existing timers
    _pingTimer?.cancel();
    _pongTimer?.cancel();

    // Send ping every 25 seconds (before the 30s timeout)
    _pingTimer = Timer.periodic(_pingInterval, (timer) {
      if (_isConnected && _channel != null) {
        _sendPing();
      } else {
        timer.cancel();
      }
    });
  }

  void _sendPing() {
    try {
      final pingMessage = {'event': 'pusher:ping', 'data': {}};

      _sendMessage(json.encode(pingMessage));
      print('💓 Sent ping to keep connection alive');

      // Start pong timeout timer
      _pongTimer?.cancel();
      _pongTimer = Timer(_pongTimeout, () {
        print('❌ Pong timeout - connection may be dead');
        _handleDisconnection();
      });
    } catch (e) {
      print('❌ Error sending ping: $e');
    }
  }

  void _handlePong() {
    // Cancel the pong timeout timer since we received a response
    _pongTimer?.cancel();
    print('💓 Received pong - connection is healthy');
  }

  void _setupMessageHandlers() {
    _channel!.stream.listen(
      (message) {
        print('📨 RAW WebSocket message: $message');
        _handleWebSocketMessage(message);
      },
      onError: (error) {
        print('❌ WebSocket error: $error');
        _handleError('WebSocket error: $error');
        _handleDisconnection();
      },
      onDone: () {
        print('🔌 WebSocket connection closed');
        _handleDisconnection();
      },
    );
  }

  void _handleWebSocketMessage(dynamic message) {
    try {
      final decoded = json.decode(message);
      final event = decoded['event'];
      final data = decoded['data'];
      final channel = decoded['channel'];

      print('🔍 WebSocket Event: $event, Channel: $channel');

      switch (event) {
        case 'pusher:connection_established':
          _handleConnectionEstablished(data);
          break;

        case 'pusher_internal:subscription_succeeded':
          _handleSubscriptionSucceeded(channel);
          break;

        case 'new_message':
          _handleNewMessage(data);
          break;

        case 'App\\Events\\MessageSent':
          _handleLaravelMessageEvent(data);
          break;

        case 'message_deleted':
          _handleMessageDeleted(data);
          break;

        case 'pusher:pong': // Handle pong responses
          _handlePong();
          break;

        case 'pusher:ping': // Handle server ping (send pong back)
          _sendPong();
          break;

        default:
          print('🔔 Unhandled event: $event');
      }
    } catch (e) {
      print('❌ Error parsing WebSocket message: $e');
    }
  }

  void _sendPong() {
    try {
      final pongMessage = {'event': 'pusher:pong', 'data': {}};

      _sendMessage(json.encode(pongMessage));
      print('💓 Sent pong response');
    } catch (e) {
      print('❌ Error sending pong: $e');
    }
  }

  void _handleConnectionEstablished(dynamic data) {
    try {
      final connectionData = json.decode(data);
      _socketId = connectionData['socket_id'];

      print('✅ Pusher connection established. Socket ID: $_socketId');

      // Now that we're connected, subscribe to the group channel
      if (_currentGroupId != null) {
        _subscribeToGroup(int.parse(_currentGroupId!));
      }
    } catch (e) {
      print('❌ Error handling connection established: $e');
    }
  }

  void _handleSubscriptionSucceeded(String? channel) {
    print('✅ Successfully subscribed to channel: $channel');
    _messageController.add({
      'type': 'subscription_succeeded',
      'channel': channel,
    });
  }

  void _handleNewMessage(dynamic data) {
    try {
      print('🆕 New message received: $data');

      final messageData = data is String ? json.decode(data) : data;

      _messageController.add({'type': 'new_message', 'data': messageData});
    } catch (e) {
      print('❌ Error handling new message: $e');
    }
  }

  void _handleLaravelMessageEvent(dynamic data) {
    try {
      print('🆕 Laravel message event: $data');

      final messageData = data is String ? json.decode(data) : data;

      _messageController.add({'type': 'new_message', 'data': messageData});
    } catch (e) {
      print('❌ Error handling Laravel message event: $e');
    }
  }

  void _handleMessageDeleted(dynamic data) {
    try {
      final deleteData = data is String ? json.decode(data) : data;

      _messageController.add({'type': 'message_deleted', 'data': deleteData});
    } catch (e) {
      print('❌ Error handling message deletion: $e');
    }
  }

  void _subscribeToGroup(int groupId) {
    final channelName = 'group.$groupId';

    final subscribeMessage = {
      'event': 'pusher:subscribe',
      'data': {'channel': channelName},
    };

    _sendMessage(json.encode(subscribeMessage));
    print('📡 Subscribing to channel: $channelName');
  }

  // FIXED: This method now accepts a String (JSON encoded)
  void _sendMessage(String message) {
    try {
      if (_channel != null) {
        _channel!.sink.add(message);
        print('📤 Sent WebSocket message: $message');
      }
    } catch (e) {
      print('❌ Error sending WebSocket message: $e');
    }
  }

  void _startConnectionMonitoring() {
    // Monitor connection every 30 seconds
    Timer.periodic(Duration(seconds: 30), (timer) {
      if (!_isConnected && _currentGroupId != null) {
        print(
          '🔍 Connection monitor: WebSocket appears disconnected, reconnecting...',
        );
        connectToGroup(int.parse(_currentGroupId!));
      }
    });
  }

  // NEW: Public method to send chat messages
  void sendChatMessage({
    required int groupId,
    required String message,
    required int userId,
    String messageType = 'text',
    String? fileUrl,
    String? fileType,
    String? fileName,
    double? fileSize,
    int? repliedToMessageId,
    String? repliedToMessageText,
    String? repliedToSenderName,
  }) {
    final messageData = {
      'group_id': groupId,
      'user_id': userId,
      'message': message,
      'message_type': messageType,
      'file_url': fileUrl,
      'file_type': fileType,
      'file_name': fileName,
      'file_size': fileSize,
      'timestamp': DateTime.now().toIso8601String(),
    };

    final webSocketMessage = {
      'event': 'client-new_message',
      'channel': 'group.$groupId',
      'data': messageData,
    };

    _sendMessage(json.encode(webSocketMessage));
  }

  void sendTypingIndicator(bool isTyping, int userId, String userName) {
    final typingMessage = {
      'event': 'client-typing',
      'channel': 'group.$_currentGroupId',
      'data': {
        'is_typing': isTyping,
        'user_id': userId,
        'user_name': userName,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    };

    _sendMessage(json.encode(typingMessage));
  }

  void _handleError(String error) {
    print('❌ WebSocket error: $error');
    _errorController.add(error);
  }

  void _handleDisconnection() {
    _isConnected = false;
    _socketId = null;
    _pingTimer?.cancel();
    _pongTimer?.cancel();
    _connectionController.add(false);
  }

  Future<void> disconnect() async {
    _pingTimer?.cancel();
    _pongTimer?.cancel();

    try {
      await _channel?.sink.close();
    } catch (e) {
      print('❌ Error closing WebSocket: $e');
    }

    _channel = null;
    _isConnected = false;
    _socketId = null;
    _currentGroupId = null;

    print('🔌 WebSocket disconnected');
  }
}
