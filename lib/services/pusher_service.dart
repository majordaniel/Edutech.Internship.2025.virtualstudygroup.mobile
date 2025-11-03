// services/pusher_client_service.dart (Updated)
import 'dart:async';
import 'dart:convert';
import 'package:pusher_client/pusher_client.dart';

class PusherClientService {
  static final PusherClientService _instance = PusherClientService._internal();
  factory PusherClientService() => _instance;
  PusherClientService._internal();

  late PusherClient _pusher;
  Channel? _channel;
  bool _isConnected = false;

  final StreamController<Map<String, dynamic>> _messageController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;
  bool get isConnected => _isConnected;
  Channel? get currentChannel => _channel; // Added this getter

  Future<void> initialize() async {
    try {
      print('🚀 Initializing Pusher client...');

      _pusher = PusherClient(
        'ediify-key',
        PusherOptions(
          host: 'ediifyapi.tife.com.ng',
          wsPort: 6001, // Laravel WebSockets default port
          wssPort: 443,
          encrypted: true,
          auth: PusherAuth(
            'https://ediifyapi.tife.com.ng/broadcasting/auth', // Laravel WebSockets auth endpoint
            headers: {
              'Authorization':
                  'Bearer YOUR_TOKEN_HERE', // You need to implement token retrieval
              'Accept': 'application/json',
            },
          ),
        ),
        enableLogging: true,
      );

      // Set up connection listeners
      _pusher.onConnectionStateChange((state) {
        print('🔄 Pusher connection state: ${state?.currentState}');
        if (state?.currentState == 'connected') {
          _isConnected = true;
          _messageController.add({'type': 'connected'});
          print('✅ Pusher connected successfully');
        } else if (state?.currentState == 'disconnected') {
          _isConnected = false;
          _messageController.add({'type': 'disconnected'});
          print('🔌 Pusher disconnected');
        }
      });

      _pusher.onConnectionError((error) {
        print('❌ Pusher connection error: $error');
        _isConnected = false;
        _messageController.add({
          'type': 'error',
          'error': error?.message ?? 'Unknown connection error',
        });
      });

      print('✅ Pusher client initialized');
    } catch (e) {
      print('❌ Error initializing Pusher: $e');
      rethrow;
    }
  }

  Future<void> subscribeToGroup(int groupId) async {
    try {
      final channelName =
          'presence-group.$groupId'; // Use presence channel for typing indicators
      print('📡 Subscribing to channel: $channelName');

      _channel = _pusher.subscribe(channelName);

      // Bind to channel events
      _channel?.bind('pusher:subscription_succeeded', (event) {
        print('✅ Successfully subscribed to $channelName');
        _messageController.add({
          'type': 'subscription_succeeded',
          'channel': channelName,
        });
      });

      // Bind to subscription error
      _channel?.bind('pusher:subscription_error', (event) {
        print('❌ Subscription error: $event');
        _messageController.add({
          'type': 'error',
          'error': 'Subscription failed',
        });
      });

      // Bind to your custom events
      _bindToEvent('new_message', _handleNewMessage);
      _bindToEvent('message_deleted', _handleMessageDeleted);
      _bindToEvent('message_reacted', _handleMessageReaction);
      _bindToEvent('typing_start', _handleTypingStart);
      _bindToEvent('typing_stop', _handleTypingStop);
    } catch (e) {
      print('❌ Error subscribing to channel: $e');
      rethrow;
    }
  }

  void _bindToEvent(String eventName, Function(String?) handler) {
    _channel?.bind(eventName, (event) {
      print('📨 Event received: $eventName - ${event?.data}');
      handler(event?.data);
    });
  }

  void _handleNewMessage(String? data) {
    try {
      if (data != null) {
        final messageData = json.decode(data);
        _messageController.add({'type': 'new_message', 'data': messageData});
      }
    } catch (e) {
      print('❌ Error handling new message: $e');
    }
  }

  void _handleMessageDeleted(String? data) {
    try {
      if (data != null) {
        final deleteData = json.decode(data);
        _messageController.add({'type': 'message_deleted', 'data': deleteData});
      }
    } catch (e) {
      print('❌ Error handling message deletion: $e');
    }
  }

  void _handleMessageReaction(String? data) {
    try {
      if (data != null) {
        final reactionData = json.decode(data);
        _messageController.add({
          'type': 'message_reacted',
          'data': reactionData,
        });
      }
    } catch (e) {
      print('❌ Error handling message reaction: $e');
    }
  }

  void _handleTypingStart(String? data) {
    try {
      if (data != null) {
        final typingData = json.decode(data);
        _messageController.add({'type': 'typing_start', 'data': typingData});
      }
    } catch (e) {
      print('❌ Error handling typing start: $e');
    }
  }

  void _handleTypingStop(String? data) {
    try {
      if (data != null) {
        final typingData = json.decode(data);
        _messageController.add({'type': 'typing_stop', 'data': typingData});
      }
    } catch (e) {
      print('❌ Error handling typing stop: $e');
    }
  }

  void sendEvent(String eventName, Map<String, dynamic> data) {
    try {
      if (_channel != null && _isConnected) {
        _channel!.trigger(eventName, data);
        print('📤 Sent event: $eventName with data: $data');
      } else {
        print('❌ Cannot send event - channel not connected');
      }
    } catch (e) {
      print('❌ Error sending event: $e');
    }
  }

  void disconnect() {
    try {
      _pusher.disconnect();
      _isConnected = false;
      _channel = null;
      print('🔌 Pusher disconnected');
    } catch (e) {
      print('❌ Error disconnecting Pusher: $e');
    }
  }
}
