// // services/working_websocket_service.dart
// import 'dart:async';
// import 'dart:convert';
// import 'package:web_socket_channel/web_socket_channel.dart';
// import 'package:web_socket_channel/io.dart';

// class WorkingWebSocketService {
//   static final WorkingWebSocketService _instance =
//       WorkingWebSocketService._internal();
//   factory WorkingWebSocketService() => _instance;
//   WorkingWebSocketService._internal();

//   WebSocketChannel? _channel;
//   bool _isConnected = false;
//   String? _currentChannel;
//   Timer? _pingTimer;

//   final StreamController<Map<String, dynamic>> _eventController =
//       StreamController<Map<String, dynamic>>.broadcast();

//   Stream<Map<String, dynamic>> get eventStream => _eventController.stream;
//   bool get isConnected => _isConnected;

//   Future<void> connectToGroup(int groupId) async {
//     try {
//       print('🚀 Connecting to WebSocket for group: $groupId');

//       await disconnect();

//       // Use the EXACT URL from your Postman success
//       _channel = IOWebSocketChannel.connect(
//         'wss://ediifyapi.tife.com.ng/app/ediify-key?protocol=7&client=js&version=8.4.0',
//         headers: {
//           'Origin': 'https://edutech-internship-2025-virtualstud.vercel.app',
//         },
//       );

//       _setupListeners();
//       _startPingInterval();

//       _isConnected = true;
//       print('✅ WebSocket connected successfully');

//       // Subscribe after connection is established
//       _subscribeToGroup(groupId);
//     } catch (e) {
//       print('❌ WebSocket connection failed: $e');
//       rethrow;
//     }
//   }

//   void _setupListeners() {
//     _channel!.stream.listen(
//       (message) {
//         print('📨 RAW WebSocket message: $message');
//         _handleIncomingMessage(message);
//       },
//       onError: (error) {
//         print('❌ WebSocket error: $error');
//         _handleDisconnection();
//       },
//       onDone: () {
//         print('🔌 WebSocket connection closed');
//         _handleDisconnection();
//       },
//     );
//   }

//   void _handleIncomingMessage(dynamic message) {
//     try {
//       final decoded = json.decode(message);
//       final event = decoded['event'];
//       final data = decoded['data'];

//       print('🔍 WebSocket Event: $event, Data: $data');

//       switch (event) {
//         case 'pusher:connection_established':
//           print('✅ Pusher connection established');
//           final connectionData = json.decode(data);
//           print('🔌 Socket ID: ${connectionData['socket_id']}');
//           _eventController.add({
//             'type': 'connected',
//             'socket_id': connectionData['socket_id'],
//           });
//           break;

//         case 'pusher_internal:subscription_succeeded':
//           print('✅ Subscription succeeded to channel: $_currentChannel');
//           _eventController.add({
//             'type': 'subscription_succeeded',
//             'channel': _currentChannel,
//           });
//           break;

//         case 'new_message':
//           _handleNewMessage(data);
//           break;

//         case 'message_deleted':
//           _handleMessageDeleted(data);
//           break;

//         case 'message_reacted':
//           _handleMessageReaction(data);
//           break;

//         case 'App\\Events\\MessageSent':
//           _handleLaravelMessageEvent(data);
//           break;

//         case 'pusher:ping':
//           _sendPong();
//           break;

//         default:
//           print('🔔 Unknown event: $event');
//           _eventController.add({
//             'type': 'unknown_event',
//             'event': event,
//             'data': data,
//           });
//       }
//     } catch (e) {
//       print('❌ Error parsing WebSocket message: $e');
//     }
//   }

//   void _subscribeToGroup(int groupId) {
//     final channelName = 'group.$groupId';
//     _currentChannel = channelName;

//     final subscribeMessage = {
//       'event': 'pusher:subscribe',
//       'data': {
//         'channel': channelName,
//         // If you need auth, add it here:
//         // 'auth': 'your-auth-token',
//       },
//     };

//     _sendMessage(subscribeMessage);
//     print('📡 Subscribing to channel: $channelName');
//   }

//   void _handleNewMessage(dynamic data) {
//     try {
//       // Data might be a string that needs parsing
//       final messageData = data is String ? json.decode(data) : data;
//       _eventController.add({'type': 'new_message', 'data': messageData});
//       print('🆕 New message handled successfully');
//     } catch (e) {
//       print('❌ Error handling new message: $e');
//     }
//   }

//   void _handleLaravelMessageEvent(dynamic data) {
//     try {
//       // Handle Laravel broadcast event format
//       final messageData = data is String ? json.decode(data) : data;
//       _eventController.add({'type': 'new_message', 'data': messageData});
//       print('🆕 Laravel message event handled');
//     } catch (e) {
//       print('❌ Error handling Laravel message event: $e');
//     }
//   }

//   void _handleMessageDeleted(dynamic data) {
//     try {
//       final deleteData = data is String ? json.decode(data) : data;
//       _eventController.add({'type': 'message_deleted', 'data': deleteData});
//     } catch (e) {
//       print('❌ Error handling message deletion: $e');
//     }
//   }

//   void _handleMessageReaction(dynamic data) {
//     try {
//       final reactionData = data is String ? json.decode(data) : data;
//       _eventController.add({'type': 'message_reacted', 'data': reactionData});
//     } catch (e) {
//       print('❌ Error handling message reaction: $e');
//     }
//   }

//   void sendMessage(Map<String, dynamic> messageData) {
//     if (!_isConnected) {
//       print('❌ WebSocket not connected');
//       return;
//     }

//     // Send via client events
//     final eventMessage = {
//       'event': 'client-new_message', // Note: client- prefix for client events
//       'channel': _currentChannel,
//       'data': messageData,
//     };

//     _sendMessage(eventMessage);
//   }

//   void sendTypingIndicator(bool isTyping, int userId, String userName) {
//     final typingMessage = {
//       'event': 'client-typing', // client- prefix for client events
//       'channel': _currentChannel,
//       'data': {
//         'is_typing': isTyping,
//         'user_id': userId,
//         'user_name': userName,
//         'timestamp': DateTime.now().millisecondsSinceEpoch,
//       },
//     };

//     _sendMessage(typingMessage);
//   }

//   void _sendMessage(Map<String, dynamic> message) {
//     try {
//       final jsonMessage = json.encode(message);
//       _channel!.sink.add(jsonMessage);
//       print('📤 Sent WebSocket message: $jsonMessage');
//     } catch (e) {
//       print('❌ Error sending WebSocket message: $e');
//     }
//   }

//   void _startPingInterval() {
//     _pingTimer?.cancel();
//     _pingTimer = Timer.periodic(Duration(seconds: 25), (timer) {
//       if (_isConnected) {
//         _sendPing();
//       } else {
//         timer.cancel();
//       }
//     });
//   }

//   void _sendPing() {
//     final pingMessage = {'event': 'pusher:ping', 'data': {}};
//     _sendMessage(pingMessage);
//   }

//   void _sendPong() {
//     final pongMessage = {'event': 'pusher:pong', 'data': {}};
//     _sendMessage(pongMessage);
//   }

//   void _handleDisconnection() {
//     _isConnected = false;
//     _pingTimer?.cancel();
//     _eventController.add({'type': 'disconnected'});
//   }

//   Future<void> disconnect() async {
//     _pingTimer?.cancel();
//     _isConnected = false;
//     _currentChannel = null;

//     try {
//       await _channel?.sink.close();
//     } catch (e) {
//       print('❌ Error closing WebSocket: $e');
//     }

//     _channel = null;
//     print('🔌 WebSocket disconnected');
//   }
// }

// services/universal_websocket_service.dart
// services/universal_websocket_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

// For web platform
import 'package:web_socket_channel/html.dart'
    if (dart.library.io) 'package:web_socket_channel/io.dart';

class UniversalWebSocketService {
  static final UniversalWebSocketService _instance =
      UniversalWebSocketService._internal();
  factory UniversalWebSocketService() => _instance;
  UniversalWebSocketService._internal();

  WebSocketChannel? _channel;
  bool _isConnected = false;
  String? _currentGroupId; // This tracks the current group ID
  String? _currentChannel; // Add this line - tracks the channel name
  Timer? _pingTimer;

  final StreamController<Map<String, dynamic>> _eventController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get eventStream => _eventController.stream;
  bool get isConnected => _isConnected;

  Future<void> connectToGroup(int groupId) async {
    try {
      print('🚀 Connecting to WebSocket for group: $groupId');

      await disconnect();

      // Use platform-agnostic WebSocket connection
      _channel = WebSocketChannel.connect(
        Uri.parse(
          'wss://ediifyapi.tife.com.ng/app/ediify-key?protocol=7&client=js&version=8.4.0',
        ),
      );

      _currentGroupId = groupId.toString();
      _currentChannel = 'group.$groupId'; // Set the channel name

      // Listen for messages
      _channel!.stream.listen(
        (message) {
          print('📨 WebSocket message: $message');
          _handleIncomingMessage(message);
        },
        onError: (error) {
          print('❌ WebSocket error: $error');
          _handleDisconnection();
        },
        onDone: () {
          print('🔌 WebSocket connection closed');
          _handleDisconnection();
        },
      );

      _isConnected = true;
      print('✅ WebSocket connected successfully');

      // Subscribe to the group channel
      _subscribeToGroup(groupId);
    } catch (e) {
      print('❌ WebSocket connection failed: $e');
      _isConnected = false;
      _eventController.add({'type': 'error', 'error': e.toString()});
      rethrow;
    }
  }

  void _subscribeToGroup(int groupId) {
    final channelName = 'group.$groupId';
    _currentChannel = channelName; // Ensure channel is set

    final subscribeMessage = {
      "event": "pusher:subscribe",
      "data": {"channel": channelName},
    };

    _sendMessage(json.encode(subscribeMessage));
    print('📡 Subscribed to channel: $channelName');
  }

  void _handleIncomingMessage(dynamic message) {
    try {
      final decoded = json.decode(message);
      final event = decoded['event'];
      final channel = decoded['channel']; // Get channel from message
      final data = decoded['data'];

      print('🔍 WebSocket Event: $event on Channel: $channel');

      // Update current channel if different
      if (channel != null && channel != _currentChannel) {
        _currentChannel = channel;
      }

      switch (event) {
        case 'pusher:connection_established':
          print('✅ Pusher connection established');
          final connectionData = json.decode(data);
          _eventController.add({
            'type': 'connected',
            'socket_id': connectionData['socket_id'],
          });
          break;

        case 'pusher_internal:subscription_succeeded':
          print('✅ Subscription succeeded to channel: $_currentChannel');
          _eventController.add({
            'type': 'subscription_succeeded',
            'channel': _currentChannel,
          });
          break;

        case 'new_message':
          _handleNewMessage(data);
          break;

        case 'message_deleted':
          _handleMessageDeleted(data);
          break;

        case 'message_reacted':
          _handleMessageReaction(data);
          break;

        default:
          print('🔔 Unknown event: $event');
      }
    } catch (e) {
      print('❌ Error parsing WebSocket message: $e');
    }
  }

  void _handleNewMessage(dynamic data) {
    try {
      final messageData = data is String ? json.decode(data) : data;
      _eventController.add({'type': 'new_message', 'data': messageData});
    } catch (e) {
      print('❌ Error handling new message: $e');
    }
  }

  void _handleMessageDeleted(dynamic data) {
    try {
      final deleteData = data is String ? json.decode(data) : data;
      _eventController.add({'type': 'message_deleted', 'data': deleteData});
    } catch (e) {
      print('❌ Error handling message deletion: $e');
    }
  }

  void _handleMessageReaction(dynamic data) {
    try {
      final reactionData = data is String ? json.decode(data) : data;
      _eventController.add({'type': 'message_reacted', 'data': reactionData});
    } catch (e) {
      print('❌ Error handling message reaction: $e');
    }
  }

  void sendMessage(Map<String, dynamic> messageData) {
    if (!_isConnected || _channel == null) {
      print('❌ WebSocket not connected');
      return;
    }

    final message = {
      'event': 'client-new_message',
      'channel': _currentChannel, // Use the tracked channel
      'data': messageData,
    };

    _sendMessage(json.encode(message));
  }

  void sendTypingIndicator(bool isTyping, int userId, String userName) {
    final typingMessage = {
      'event': 'client-typing',
      'channel': _currentChannel, // Use the tracked channel
      'data': {
        'is_typing': isTyping,
        'user_id': userId,
        'user_name': userName,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    };

    _sendMessage(json.encode(typingMessage));
  }

  void _sendMessage(String message) {
    try {
      _channel!.sink.add(message);
      print('📤 Sent WebSocket message: $message');
    } catch (e) {
      print('❌ Error sending WebSocket message: $e');
    }
  }

  void _handleDisconnection() {
    _isConnected = false;
    _pingTimer?.cancel();
    _eventController.add({'type': 'disconnected'});
  }

  Future<void> disconnect() async {
    _pingTimer?.cancel();
    _isConnected = false;
    _currentGroupId = null;
    _currentChannel = null; // Clear channel on disconnect

    try {
      await _channel?.sink.close();
    } catch (e) {
      print('❌ Error closing WebSocket: $e');
    }

    _channel = null;
    print('🔌 WebSocket disconnected');
  }

  // Getter for current channel (optional)
  String? get currentChannel => _currentChannel;
}
