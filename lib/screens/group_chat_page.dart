import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'package:edify_app/constants/file_upload_limits.dart';
import 'package:edify_app/providers/group_provider.dart';
import 'package:edify_app/screens/profile_page_group.dart';
import 'package:edify_app/services/call_service.dart';
import 'package:edify_app/services/chat_service.dart';
import 'package:edify_app/services/file_download_service.dart';
import 'package:edify_app/services/voice_recording_service.dart';
import 'package:edify_app/widgets/emoji_picker_widget.dart';
import 'package:edify_app/widgets/icon_button.dart';
import 'package:edify_app/widgets/meeting_snackbar.dart';
import 'package:edify_app/widgets/message_options_dialog.dart';
import 'package:edify_app/widgets/notification_icon.dart';
import 'package:edify_app/widgets/user_avatar.dart';
import 'package:edify_app/widgets/video_player.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:edify_app/widgets/appbar.dart';
import 'package:edify_app/widgets/texts.dart';
import 'package:edify_app/constants/colors.dart';
import 'package:edify_app/providers/chat_provider.dart';
import 'package:edify_app/providers/user_provider.dart';
import 'package:edify_app/models/chat_message.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:edify_app/widgets/voice_whatsapp_player.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class GroupChatPage extends StatefulWidget {
  final dynamic group;

  const GroupChatPage({super.key, required this.group});

  @override
  State<GroupChatPage> createState() => _GroupChatPageState();
}

class _GroupChatPageState extends State<GroupChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _hasText = false;
  late Future<void> _messagesFuture;
  bool _isRecording = false;
  Timer? _recordingTimer;
  String? _currentRecordingPath;
  int _recordingDuration = 0;
  Timer? _backupTimer;

  // Typing indicators
  Timer? _typingTimer;
  Timer? _typingDebounceTimer;
  Timer? _connectionMonitor;

  int? get currentUserId {
    final userProvider = context.read<UserProvider>();
    return userProvider.user?.id;
  }

  // Add this to your GroupChatPage
  // Replace your _testWebSocketConnection method with this:
  void _testWebSocketConnection() async {
    try {
      print('🧪 Testing WebSocket connection...');

      final channel = WebSocketChannel.connect(
        Uri.parse(
          'wss://ediifyapi.tife.com.ng/app/ediify-key?protocol=7&client=js&version=8.4.0',
        ),
      );

      // Test sending a subscription message
      final testMessage = {
        "event": "pusher:subscribe",
        "data": {"channel": "group.${widget.group.id}"},
      };

      channel.sink.add(json.encode(testMessage));

      channel.stream.listen(
        (message) {
          print('✅ WebSocket test successful: $message');
          channel.sink.close();
        },
        onError: (error) {
          print('❌ WebSocket test failed: $error');
          channel.sink.close();
        },
        onDone: () {
          print('🔌 WebSocket test connection closed');
        },
      );

      // Close after 5 seconds
      Timer(Duration(seconds: 5), () {
        channel.sink.close();
      });
    } catch (e) {
      print('❌ WebSocket test connection failed: $e');
    }
  }

  // Add this to your GroupChatPage
  void _debugChatState() {
    final chatProvider = context.read<ChatProvider>();
    final userProvider = context.read<UserProvider>();

    print('🔍 CHAT STATE DEBUG:');
    print('  - Messages count: ${chatProvider.messages.length}');
    print('  - Loading: ${chatProvider.isLoading}');
    print('  - Connected: ${chatProvider.isConnected}');
    print('  - Error: ${chatProvider.error}');
    print('  - Current user: ${userProvider.user?.id}');

    // Print first few messages
    for (var i = 0; i < chatProvider.messages.length && i < 3; i++) {
      final msg = chatProvider.messages[i];
      print('  - Message $i: ${msg.message} (from ${msg.senderName})');
    }
  }

  void _checkWebSocketStatus() {
    final chatProvider = context.read<ChatProvider>();
    print('🔍 WebSocket Status Check:');
    print('  - Connected: ${chatProvider.isConnected}');
    print('  - Current Group: ${chatProvider.currentGroupId}');
    print('  - Messages Count: ${chatProvider.messages.length}');

    // Force reconnect if disconnected
    if (!chatProvider.isConnected) {
      print('🔄 Force reconnecting WebSocket...');
      _initializeWebSocket();
    }
  }

  // Call this in your build method or after init
  @override
  void initState() {
    super.initState();
    _messageController.addListener(_onTextChanged);
    _messagesFuture = _loadMessagesOnInit();
    _initializeWebSocket();
    _startConnectionMonitor();

    // Debug after initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(seconds: 3), () {
        _debugChatState();
      });
    });
  }

  void _initializeWebSocket() {
    final chatProvider = context.read<ChatProvider>();
    chatProvider.initializeChat(widget.group.id);
  }

  void _startConnectionMonitor() {
    _connectionMonitor = Timer.periodic(Duration(seconds: 10), (timer) {
      final chatProvider = context.read<ChatProvider>();
      if (!chatProvider.isConnected && mounted) {
        print('🔄 Connection monitor: Reconnecting WebSocket...');
        _initializeWebSocket();
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _recordingTimer?.cancel();
    _typingTimer?.cancel();
    _typingDebounceTimer?.cancel();
    _connectionMonitor?.cancel();

    // Send typing stop when leaving
    final userProvider = context.read<UserProvider>();
    final chatProvider = context.read<ChatProvider>();
    final currentUser = userProvider.user;

    if (currentUser != null) {
      chatProvider.sendTypingStop(widget.group.id, currentUser.id);
    }

    VoiceRecordingService.dispose();
    super.dispose();
  }

  void _navigateToGroupProfile() {
    print('👥 Navigating to group profile for: ${widget.group.groupName}');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfilePageGroup(group: widget.group),
      ),
    );
  }

  Future<void> _loadMessagesOnInit() async {
    // We'll load messages through the WebSocket now
    // This future is kept for initial loading state
    await Future.delayed(Duration(milliseconds: 100));
  }

  void _onTextChanged() {
    setState(() {
      _hasText = _messageController.text.trim().isNotEmpty;
    });

    // Handle typing indicators
    final userProvider = context.read<UserProvider>();
    final chatProvider = context.read<ChatProvider>();

    final currentUser = userProvider.user;
    if (currentUser != null && _hasText) {
      // Cancel previous debounce timer
      _typingDebounceTimer?.cancel();

      // Send typing start after a short delay
      _typingDebounceTimer = Timer(Duration(milliseconds: 500), () {
        chatProvider.sendTypingStart(
          widget.group.id,
          currentUser.id,
          currentUser.fullName,
        );
      });

      // Reset typing stop timer
      _typingTimer?.cancel();
      _typingTimer = Timer(Duration(seconds: 2), () {
        chatProvider.sendTypingStop(widget.group.id, currentUser.id);
      });
    } else if (currentUser != null && !_hasText) {
      // Send typing stop immediately when text is cleared
      _typingDebounceTimer?.cancel();
      _typingTimer?.cancel();
      chatProvider.sendTypingStop(widget.group.id, currentUser.id);
    }
  }

  void _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Store for retry
    final messageToSend = message;
    final userId = userProvider.user?.id ?? 0;

    // Clear input immediately
    _messageController.clear();
    setState(() {
      _hasText = false;
    });

    // Send typing stop
    chatProvider.sendTypingStop(widget.group.id, userId);

    // Add message locally immediately (optimistic update)
    final tempMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch,
      groupId: widget.group.id,
      userId: userId,
      message: messageToSend,
      createdAt: DateTime.now().toIso8601String(),
      senderName: 'You',
    );

    chatProvider.addMessage(tempMessage);

    // Scroll to bottom after adding new message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });

    // Then try to send to server via WebSocket
    final success = await chatProvider.sendMessage(
      groupId: widget.group.id,
      message: messageToSend,
      userId: userId,
    );

    if (!success && mounted) {
      // Remove the optimistic message if failed
      chatProvider.removeMessage(tempMessage.id);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send message'),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: () {
              _retrySendMessage(messageToSend, userId);
            },
          ),
        ),
      );
    }
  }

  void _retrySendMessage(String message, int userId) async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    final success = await chatProvider.sendMessage(
      groupId: widget.group.id,
      message: message,
      userId: userId,
    );

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Still failed to send message'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // In your GroupChatPage, update these methods:

  void _handleReply(ChatMessage message) {
    final chatProvider = context.read<ChatProvider>();

    // Set the message to reply to
    chatProvider.setReplyMessage(message);

    // Focus on message input and show reply preview
    _messageController.text = '';
    _messageController.selection = TextSelection.collapsed(offset: 0);

    // You might want to add a reply preview UI above the input field
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Replying to ${message.senderName}'),
        backgroundColor: AppColors.primaryOrange,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _copyMessage(ChatMessage message) async {
    final chatProvider = context.read<ChatProvider>();
    await chatProvider.copyMessage(message);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Message copied to clipboard'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  // void _forwardMessage(ChatMessage message) {
  //   // Show a dialog to select groups to forward to
  //   _showForwardDialog(message);
  // }

  // void _starMessage(ChatMessage message) async {
  //   final chatProvider = context.read<ChatProvider>();
  //   final success = await chatProvider.starMessage(message.id);

  //   if (success && mounted) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Message starred'),
  //         backgroundColor: Colors.amber,
  //         duration: Duration(seconds: 2),
  //       ),
  //     );
  //   }
  // }

  void _pinMessage(ChatMessage message) async {
    final chatProvider = context.read<ChatProvider>();
    final success = await chatProvider.pinMessage(message.id);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Message pinned'),
          backgroundColor: AppColors.primaryOrange,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _shareMessage(ChatMessage message) async {
    // final chatProvider = context.read<ChatProvider>();
    // await chatProvider.shareMessage(message);

    // if (mounted) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //       content: Text('Message shared'),
    //       backgroundColor: Colors.blue,
    //       duration: Duration(seconds: 2),
    //     ),
    //   );
    // }
  }

  void _showEmojiPicker(ChatMessage message) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return EmojiPickerWidget(
          onEmojiSelected: (emoji) => _handleReaction(message, emoji),
        );
      },
    );
  }

  void _handleReaction(ChatMessage message, String emoji) async {
    final userProvider = context.read<UserProvider>();
    final chatProvider = context.read<ChatProvider>();

    final currentUser = userProvider.user;
    if (currentUser == null) return;

    final success = await chatProvider.reactToMessage(
      messageId: message.id,
      emoji: emoji,
      userId: currentUser.id,
      userName: currentUser.fullName,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reacted with $emoji'),
          backgroundColor: Colors.pink,
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  void _startVoiceMessage() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildVoiceRecordingUI(),
    );
  }

  Widget _buildVoiceRecordingUI() {
    return Container(
      height: 450,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Voice Message',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlack,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _cancelRecording();
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.close, color: AppColors.primaryBlack),
                ),
              ],
            ),
          ),

          Expanded(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Recording visualization with timer
                  Container(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Timer display - This will now update properly
                        Text(
                          _formatRecordingDuration(_recordingDuration),
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlack,
                          ),
                        ),
                        SizedBox(height: 16),

                        // Recording animation
                        _buildRecordingAnimation(),

                        SizedBox(height: 8),

                        // Recording status
                        Text(
                          _isRecording
                              ? 'Recording...'
                              : 'Tap and hold to record',
                          style: TextStyle(
                            color: AppColors.primaryBlackLight,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 30),

                  // Recording button - WhatsApp style
                  _isRecording
                      ? _buildRecordingInProgress()
                      : _buildStartRecordingButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _startRecording() async {
    try {
      print('🎤 Starting recording from UI...');

      final result = await VoiceRecordingService.startRecording(
        onTimerUpdate: (duration) {
          print('⏰ Timer update received: $duration seconds');
          if (mounted) {
            setState(() {
              _recordingDuration = duration;
            });
          } else {
            print('⚠️ Widget not mounted, cannot update timer');
          }
        },
      );

      if (result.success) {
        setState(() {
          _isRecording = true;
          _currentRecordingPath = result.filePath;
          _recordingDuration = 0;
        });

        print('✅ Recording started successfully: ${result.filePath}');

        // Start a backup timer just in case the callback fails
        _startBackupTimer();
      } else {
        print('❌ Failed to start recording: ${result.error}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start recording: ${result.error}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('❌ Start recording error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Recording error: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _startBackupTimer() {
    _backupTimer?.cancel();
    _backupTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_isRecording && mounted) {
        // This ensures the UI updates even if the service callback fails
        setState(() {
          _recordingDuration = VoiceRecordingService.recordingDuration;
        });
        print('⏰ Backup timer: $_recordingDuration seconds');
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _stopRecording() async {
    try {
      if (!_isRecording) {
        print('⚠️ No active recording to stop');
        return;
      }

      print('⏹️ Stopping recording from UI...');

      // Stop backup timer first
      _backupTimer?.cancel();
      _backupTimer = null;

      final result = await VoiceRecordingService.stopRecording();

      if (result.success && result.filePath != null) {
        print('✅ Recording stopped: ${result.filePath}');
        print(
          '📊 Recording duration: ${result.duration}s, size: ${result.fileSize} bytes',
        );

        // Send the voice message
        await _sendVoiceMessage(result.filePath!);
      } else {
        print('❌ Failed to stop recording: ${result.error}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to stop recording: ${result.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('❌ Stop recording error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Recording error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      _cleanupRecording();
    }
  }

  void _cancelRecording() async {
    try {
      // Stop backup timer
      _backupTimer?.cancel();
      _backupTimer = null;

      await VoiceRecordingService.cancelRecording();
      print('❌ Recording cancelled');
    } catch (e) {
      print('❌ Cancel recording error: $e');
    } finally {
      _cleanupRecording();
    }
  }

  void _cleanupRecording() {
    _backupTimer?.cancel();
    _backupTimer = null;
    if (mounted) {
      setState(() {
        _isRecording = false;
        _recordingDuration = 0;
        _currentRecordingPath = null;
      });
    }
  }

  String _formatRecordingDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  Widget _buildFilePlaceholder(ChatMessage chatMessage, bool isMe) {
    final fileService = FileDownloadService();
    final fileName = chatMessage.fileName ?? 'Unknown File';
    final fileIcon = fileService.getFileIcon(fileName);

    return Container(
      color: Colors.grey.shade200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(fileIcon, size: 40, color: AppColors.primaryOrange),
            SizedBox(height: 8),
            Text(
              fileName,
              style: TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4),
            Text(
              'Tap to download',
              style: TextStyle(
                fontSize: 10,
                color: AppColors.primaryOrange,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Connection Status Widget
  Widget _buildConnectionStatus(ChatProvider chatProvider) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (chatProvider.isConnected) {
      statusColor = AppColors.primaryApproved;
      statusText = 'Online';
      statusIcon = Icons.circle;
    } else if (chatProvider.isLoading) {
      statusColor = AppColors.primaryBlack;
      statusText = 'Connecting...';
      statusIcon = Icons.refresh;
    } else {
      statusColor = AppColors.primaryBlack;
      statusText = 'Offline';
      statusIcon = Icons.circle_outlined;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, color: statusColor, size: 6),
          SizedBox(width: 4),
          CustomTexts(
            title: statusText,
            textColor: statusColor,
            textSize: 10,
            textWeight: FontWeight.w500,
            textAlignment: AlignmentGeometry.centerLeft,
          ),
        ],
      ),
    );
  }

  // Typing Indicator Widget
  Widget _buildTypingIndicator(ChatProvider chatProvider) {
    if (!chatProvider.isTyping || chatProvider.typingUserName == null) {
      return SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 8),
          Text(
            '${chatProvider.typingUserName} is typing...',
            style: TextStyle(
              color: AppColors.primaryBlackLight,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
          SizedBox(width: 8),
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.primaryOrange,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Enhanced Message Bubbles with Content Detection
  Widget _buildMessageBubble({
    required ChatMessage chatMessage,
    required bool isMe,
  }) {
    if (chatMessage.hasFile) {
      if (chatMessage.fileType?.contains('image') == true) {
        return _buildImageMessageBubble(chatMessage, isMe);
      } else if (chatMessage.fileType?.contains('video') == true) {
        return _buildVideoMessageBubble(chatMessage, isMe);
      } else if (chatMessage.fileType?.contains('audio') == true) {
        return _buildVoiceMessageBubble(chatMessage, isMe);
      } else {
        return _buildDocumentMessageBubble(chatMessage, isMe);
      }
    }
    // Handle different content types
    switch (chatMessage.detectedContentType) {
      case 'audio':
        return _buildVoiceMessageBubble(chatMessage, isMe);
      case 'video':
        return _buildVideoMessageBubble(chatMessage, isMe);
      case 'image':
        return _buildImageMessageBubble(chatMessage, isMe);
      case 'link':
        return _buildLinkMessageBubble(chatMessage, isMe);
      case 'phone':
        return _buildPhoneMessageBubble(chatMessage, isMe);
      default:
        return _buildTextMessageBubble(chatMessage, isMe);
    }
  }

  Widget _buildImageMessageBubble(ChatMessage chatMessage, bool isMe) {
    String? fullFileUrl;
    if (chatMessage.fileUrl != null) {
      if (chatMessage.fileUrl!.startsWith('http')) {
        fullFileUrl = chatMessage.fileUrl;
      } else {
        String cleanPath = chatMessage.fileUrl!.replaceFirst(RegExp(r'^/'), '');
        if (cleanPath.startsWith('uploads/')) {
          fullFileUrl = 'https://ediifyapi.tife.com.ng/storage/$cleanPath';
        } else {
          fullFileUrl =
              'https://ediifyapi.tife.com.ng/storage/uploads/$cleanPath';
        }
      }
    }

    return GestureDetector(
      onTap: () {
        if (fullFileUrl != null && chatMessage.fileName != null) {
          FileDownloadService().downloadAndOpenFile(
            url: fullFileUrl!,
            fileName: chatMessage.fileName!,
            fileType: chatMessage.fileType ?? 'image',
            groupId: widget.group.id,
            context: context,
          );
        }
      },
      onLongPress: () => _showMessageOptions(chatMessage),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe && chatMessage.senderAvatar.isNotEmpty)
            CircleAvatar(
              radius: 15,
              backgroundImage: NetworkImage(chatMessage.senderAvatar),
            )
          else if (!isMe)
            CircleAvatar(
              radius: 15,
              backgroundColor: AppColors.primaryOrange.withOpacity(0.1),
              child: Text(
                chatMessage.senderName.isNotEmpty
                    ? chatMessage.senderName[0].toUpperCase()
                    : '?',
                style: TextStyle(
                  color: AppColors.primaryOrange,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          if (!isMe) SizedBox(width: 8),

          Flexible(
            child: Container(
              constraints: BoxConstraints(maxWidth: 283),
              margin: EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: isMe
                    ? AppColors.primaryOrangeLight
                    : AppColors.primaryGreyLight,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: isMe ? Radius.circular(16) : Radius.circular(4),
                  bottomRight: isMe ? Radius.circular(4) : Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isMe && chatMessage.senderName != 'You')
                    Padding(
                      padding: EdgeInsets.only(left: 12, top: 8),
                      child: Text(
                        chatMessage.senderName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          color: AppColors.primaryBlack,
                        ),
                      ),
                    ),

                  // Image preview
                  if (fullFileUrl != null)
                    Container(
                      width: double.infinity,
                      height: 200,
                      margin: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          fullFileUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: Colors.grey.shade200,
                              child: Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return _buildFilePlaceholder(chatMessage, isMe);
                          },
                        ),
                      ),
                    ),

                  Padding(
                    padding: EdgeInsets.only(left: 12, bottom: 8, right: 12),
                    child: Text(
                      _formatTime(chatMessage.createdAt),
                      style: TextStyle(
                        fontSize: 8,
                        color: AppColors.primaryBlack.withOpacity(0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (isMe) SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildVideoMessageBubble(ChatMessage chatMessage, bool isMe) {
    String? fullFileUrl;
    if (chatMessage.fileUrl != null) {
      if (chatMessage.fileUrl!.startsWith('http')) {
        fullFileUrl = chatMessage.fileUrl;
      } else {
        String cleanPath = chatMessage.fileUrl!.replaceFirst(RegExp(r'^/'), '');
        if (cleanPath.startsWith('uploads/')) {
          fullFileUrl = 'https://ediifyapi.tife.com.ng/storage/$cleanPath';
        } else {
          fullFileUrl =
              'https://ediifyapi.tife.com.ng/storage/uploads/$cleanPath';
        }
      }
    }

    return GestureDetector(
      onTap: () {
        if (fullFileUrl != null && chatMessage.fileName != null) {
          FileDownloadService().downloadAndOpenFile(
            url: fullFileUrl!,
            fileName: chatMessage.fileName!,
            fileType: chatMessage.fileType ?? 'video',
            groupId: widget.group.id,
            context: context,
          );
        }
      },
      onLongPress: () => _showMessageOptions(chatMessage),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe && chatMessage.senderAvatar.isNotEmpty)
            CircleAvatar(
              radius: 15,
              backgroundImage: NetworkImage(chatMessage.senderAvatar),
            )
          else if (!isMe)
            CircleAvatar(
              radius: 15,
              backgroundColor: AppColors.primaryOrange.withOpacity(0.1),
              child: Text(
                chatMessage.senderName.isNotEmpty
                    ? chatMessage.senderName[0].toUpperCase()
                    : '?',
                style: TextStyle(
                  color: AppColors.primaryOrange,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          if (!isMe) SizedBox(width: 8),

          Flexible(
            child: Container(
              constraints: BoxConstraints(maxWidth: 283),
              margin: EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: isMe
                    ? AppColors.primaryOrangeLight
                    : AppColors.primaryGreyLight,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: isMe ? Radius.circular(16) : Radius.circular(4),
                  bottomRight: isMe ? Radius.circular(4) : Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isMe && chatMessage.senderName != 'You')
                    Padding(
                      padding: EdgeInsets.only(left: 12, top: 8),
                      child: Text(
                        chatMessage.senderName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          color: AppColors.primaryBlack,
                        ),
                      ),
                    ),

                  // Video preview
                  if (fullFileUrl != null)
                    Container(
                      width: double.infinity,
                      height: 200,
                      margin: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.black.withOpacity(0.1),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Video thumbnail placeholder
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.primaryOrange.withOpacity(0.3),
                                  AppColors.primaryBlack.withOpacity(0.7),
                                ],
                              ),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.play_arrow,
                                      color: AppColors.primaryOrange,
                                      size: 40,
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    'VIDEO',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (chatMessage.fileName != null)
                                    Padding(
                                      padding: EdgeInsets.only(top: 8),
                                      child: Text(
                                        chatMessage.fileName!,
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  Padding(
                    padding: EdgeInsets.only(left: 12, bottom: 8, right: 12),
                    child: Text(
                      _formatTime(chatMessage.createdAt),
                      style: TextStyle(
                        fontSize: 8,
                        color: AppColors.primaryBlack.withOpacity(0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (isMe) SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildDocumentMessageBubble(ChatMessage chatMessage, bool isMe) {
    String? fullFileUrl;
    if (chatMessage.fileUrl != null) {
      if (chatMessage.fileUrl!.startsWith('http')) {
        fullFileUrl = chatMessage.fileUrl;
      } else {
        String cleanPath = chatMessage.fileUrl!.replaceFirst(RegExp(r'^/'), '');
        if (cleanPath.startsWith('uploads/')) {
          fullFileUrl = 'https://ediifyapi.tife.com.ng/storage/$cleanPath';
        } else {
          fullFileUrl =
              'https://ediifyapi.tife.com.ng/storage/uploads/$cleanPath';
        }
      }
    }

    final fileService = FileDownloadService();
    final fileName = chatMessage.fileName ?? 'Unknown File';
    final fileIcon = fileService.getFileIcon(fileName);

    return GestureDetector(
      onTap: () {
        if (fullFileUrl != null && chatMessage.fileName != null) {
          FileDownloadService().downloadAndOpenFile(
            url: fullFileUrl!,
            fileName: chatMessage.fileName!,
            fileType: chatMessage.fileType ?? 'document',
            groupId: widget.group.id,
            context: context,
          );
        }
      },
      onLongPress: () => _showMessageOptions(chatMessage),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe && chatMessage.senderAvatar.isNotEmpty)
            CircleAvatar(
              radius: 15,
              backgroundImage: NetworkImage(chatMessage.senderAvatar),
            )
          else if (!isMe)
            CircleAvatar(
              radius: 15,
              backgroundColor: AppColors.primaryOrange.withOpacity(0.1),
              child: Text(
                chatMessage.senderName.isNotEmpty
                    ? chatMessage.senderName[0].toUpperCase()
                    : '?',
                style: TextStyle(
                  color: AppColors.primaryOrange,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          if (!isMe) SizedBox(width: 8),

          Flexible(
            child: Container(
              constraints: BoxConstraints(maxWidth: 283),
              padding: EdgeInsets.all(12),
              margin: EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: isMe
                    ? AppColors.primaryOrangeLight
                    : AppColors.primaryGreyLight,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: isMe ? Radius.circular(16) : Radius.circular(4),
                  bottomRight: isMe ? Radius.circular(4) : Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isMe && chatMessage.senderName != 'You')
                    Text(
                      chatMessage.senderName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        color: AppColors.primaryBlack,
                      ),
                    ),
                  SizedBox(height: 8),

                  // Document preview
                  Row(
                    children: [
                      Icon(fileIcon, size: 35, color: AppColors.primaryOrange),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fileName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: AppColors.primaryBlack,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4),
                            if (chatMessage.fileSize != null)
                              Text(
                                _formatFileSize(chatMessage.fileSize!),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.primaryBlackLight,
                                ),
                              ),
                            Text(
                              'Tap to open',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.primaryOrange,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 8),
                  Text(
                    _formatTime(chatMessage.createdAt),
                    style: TextStyle(
                      fontSize: 8,
                      color: AppColors.primaryBlack.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (isMe) SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildTextMessageBubble(ChatMessage chatMessage, bool isMe) {
    return GestureDetector(
      onLongPress: () => _showMessageOptions(chatMessage),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe && chatMessage.senderAvatar.isNotEmpty)
            CircleAvatar(
              radius: 15,
              backgroundImage: NetworkImage(chatMessage.senderAvatar),
            )
          else if (!isMe)
            CircleAvatar(
              radius: 15,
              backgroundColor: AppColors.primaryOrange.withOpacity(0.1),
              child: Text(
                chatMessage.senderName.isNotEmpty
                    ? chatMessage.senderName[0].toUpperCase()
                    : '?',
                style: TextStyle(
                  color: AppColors.primaryOrange,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          if (!isMe) SizedBox(width: 8),

          if (chatMessage.reactions.isNotEmpty) _buildReactionsBar(chatMessage),

          Flexible(
            child: Container(
              constraints: BoxConstraints(maxWidth: 303),
              padding: EdgeInsets.all(12),
              margin: EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: isMe
                    ? AppColors.primaryOrangeLight
                    : AppColors.primaryGreyLight,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: isMe ? Radius.circular(16) : Radius.circular(4),
                  bottomRight: isMe ? Radius.circular(4) : Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Reply preview (like WhatsApp)
                  if (chatMessage.hasReply == true &&
                      chatMessage.repliedToMessageText != null)
                    _buildReplyPreviewInMessage(chatMessage, isMe),

                  if (!isMe && chatMessage.senderName != 'You')
                    Text(
                      chatMessage.senderName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        color: AppColors.primaryBlack,
                      ),
                    ),
                  SizedBox(height: 4),

                  // Enhanced text with link/phone detection
                  _buildEnhancedMessageText(chatMessage.message ?? ''),

                  SizedBox(height: 4),
                  Text(
                    _formatTime(chatMessage.createdAt),
                    style: TextStyle(
                      fontSize: 8,
                      color: AppColors.primaryBlack.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (isMe) SizedBox(width: 8),
        ],
      ),
    );
  }

  // Add this method for the reply preview inside the message
  Widget _buildReplyPreviewInMessage(ChatMessage chatMessage, bool isMe) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(8),
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isMe
            ? AppColors.primaryOrange.withOpacity(0.2)
            : AppColors.primaryBlack.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(
            color: isMe ? AppColors.primaryOrange : AppColors.primaryBlack,
            width: 3,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            chatMessage.repliedToSenderName ?? 'Unknown',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isMe ? AppColors.primaryOrange : AppColors.primaryBlack,
            ),
          ),
          SizedBox(height: 2),
          Text(
            chatMessage.repliedToMessageText ?? '',
            style: TextStyle(
              fontSize: 10,
              color: AppColors.primaryBlack.withOpacity(0.7),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedMessageText(String text) {
    final linkRegex = RegExp(
      r'(https?:\/\/[^\s]+|www\.[^\s]+|\b[\w\.]+@[\w\.]+\.[a-zA-Z]{2,}\b)',
      caseSensitive: false,
    );
    final phoneRegex = RegExp(r'(\+?[\d\s\-\(\)]{10,})');

    final matches = <RegExpMatch>[];
    matches.addAll(linkRegex.allMatches(text));
    matches.addAll(phoneRegex.allMatches(text));

    matches.sort((a, b) => a.start.compareTo(b.start));

    if (matches.isEmpty) {
      return Text(
        text,
        style: TextStyle(fontSize: 12, color: AppColors.primaryBlack),
      );
    }

    final textSpans = <TextSpan>[];
    int currentIndex = 0;

    for (final match in matches) {
      // Add text before the match
      if (match.start > currentIndex) {
        textSpans.add(
          TextSpan(
            text: text.substring(currentIndex, match.start),
            style: TextStyle(fontSize: 12, color: AppColors.primaryBlack),
          ),
        );
      }

      // Add the matched text with special styling
      final matchedText = match.group(0)!;
      final isLink = linkRegex.hasMatch(matchedText);
      final isPhone = phoneRegex.hasMatch(matchedText);

      textSpans.add(
        TextSpan(
          text: matchedText,
          style: TextStyle(
            fontSize: 12,
            color: isLink ? Colors.blue : AppColors.primaryOrange,
            decoration: isLink ? TextDecoration.underline : TextDecoration.none,
            fontWeight: FontWeight.w500,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () => isLink
                ? _handleLinkTap(matchedText)
                : _handlePhoneTap(matchedText),
        ),
      );

      currentIndex = match.end;
    }

    // Add remaining text
    if (currentIndex < text.length) {
      textSpans.add(
        TextSpan(
          text: text.substring(currentIndex),
          style: TextStyle(fontSize: 12, color: AppColors.primaryBlack),
        ),
      );
    }

    return RichText(text: TextSpan(children: textSpans));
  }

  // Enhanced Message Bubbles with Content Detection

  Widget _buildLinkMessageBubble(ChatMessage chatMessage, bool isMe) {
    final links = chatMessage.extractLinks;
    final firstLink = links.isNotEmpty ? links.first : '';

    return GestureDetector(
      onTap: () => _handleLinkTap(firstLink),
      onLongPress: () => _showMessageOptions(chatMessage),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe && chatMessage.senderAvatar.isNotEmpty)
            CircleAvatar(
              radius: 15,
              backgroundImage: NetworkImage(chatMessage.senderAvatar),
            )
          else if (!isMe)
            CircleAvatar(
              radius: 15,
              backgroundColor: AppColors.primaryOrange.withOpacity(0.1),
              child: Text(
                chatMessage.senderName.isNotEmpty
                    ? chatMessage.senderName[0].toUpperCase()
                    : '?',
                style: TextStyle(
                  color: AppColors.primaryOrange,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          if (!isMe) SizedBox(width: 8),

          Flexible(
            child: Container(
              constraints: BoxConstraints(maxWidth: 283),
              padding: EdgeInsets.all(12),
              margin: EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: isMe
                    ? AppColors.primaryOrangeLight
                    : AppColors.primaryGreyLight,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: isMe ? Radius.circular(16) : Radius.circular(4),
                  bottomRight: isMe ? Radius.circular(4) : Radius.circular(16),
                ),
                // border: Border.all(
                //   color: Colors.blue.withOpacity(0.3),
                //   width: 1,
                // ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isMe && chatMessage.senderName != 'You')
                    Text(
                      chatMessage.senderName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        color: AppColors.primaryBlack,
                      ),
                    ),
                  SizedBox(height: 4),

                  // Link preview
                  Row(
                    children: [
                      Icon(
                        Icons.link,
                        size: 16,
                        color: AppColors.primaryOrange,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              firstLink,
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.primaryOrange,
                                decoration: TextDecoration.underline,
                                decorationColor: AppColors.primaryOrange,
                                decorationThickness: 2.0,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 4),
                  Text(
                    _formatTime(chatMessage.createdAt),
                    style: TextStyle(
                      fontSize: 8,
                      color: AppColors.primaryBlack.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (isMe) SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildPhoneMessageBubble(ChatMessage chatMessage, bool isMe) {
    final phones = chatMessage.extractPhoneNumbers;
    final firstPhone = phones.isNotEmpty ? phones.first : '';

    return GestureDetector(
      onTap: () => _handlePhoneTap(firstPhone),
      onLongPress: () => _showMessageOptions(chatMessage),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe && chatMessage.senderAvatar.isNotEmpty)
            CircleAvatar(
              radius: 15,
              backgroundImage: NetworkImage(chatMessage.senderAvatar),
            )
          else if (!isMe)
            CircleAvatar(
              radius: 15,
              backgroundColor: AppColors.primaryOrange.withOpacity(0.1),
              child: Text(
                chatMessage.senderName.isNotEmpty
                    ? chatMessage.senderName[0].toUpperCase()
                    : '?',
                style: TextStyle(
                  color: AppColors.primaryOrange,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          if (!isMe) SizedBox(width: 8),

          Flexible(
            child: Container(
              constraints: BoxConstraints(maxWidth: 150),
              padding: EdgeInsets.all(12),
              margin: EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: isMe
                    ? AppColors.primaryOrangeLight
                    : AppColors.primaryGreyLight,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: isMe ? Radius.circular(16) : Radius.circular(4),
                  bottomRight: isMe ? Radius.circular(4) : Radius.circular(16),
                ),
                // border: Border.all(
                //   color: AppColors.primaryOrange.withOpacity(0.3),
                //   width: 1,
                // ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isMe && chatMessage.senderName != 'You')
                    Text(
                      chatMessage.senderName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        color: AppColors.primaryBlack,
                      ),
                    ),
                  SizedBox(height: 4),

                  // Phone preview
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.phone,
                        size: 16,
                        color: AppColors.primaryOrange,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Text(
                            //   'Phone Number',
                            //   style: TextStyle(
                            //     fontSize: 12,
                            //     fontWeight: FontWeight.w500,
                            //     color: AppColors.primaryOrange,
                            //   ),
                            // ),
                            Text(
                              firstPhone,
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.primaryOrange,
                                decoration: TextDecoration.underline,
                                decorationColor: AppColors.primaryOrange,
                                decorationThickness: 2.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 4),
                  Text(
                    _formatTime(chatMessage.createdAt),
                    style: TextStyle(
                      fontSize: 8,
                      color: AppColors.primaryBlack.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (isMe) SizedBox(width: 8),
        ],
      ),
    );
  }

  // Widget _buildVideoMessageBubble(ChatMessage chatMessage, bool isMe) {
  //   String? fullFileUrl;
  //   if (chatMessage.fileUrl != null) {
  //     if (chatMessage.fileUrl!.startsWith('http')) {
  //       fullFileUrl = chatMessage.fileUrl;
  //     } else {
  //       String cleanPath = chatMessage.fileUrl!.replaceFirst(RegExp(r'^/'), '');
  //       if (cleanPath.startsWith('uploads/')) {
  //         fullFileUrl = 'https://ediifyapi.tife.com.ng/storage/$cleanPath';
  //       } else {
  //         fullFileUrl =
  //             'https://ediifyapi.tife.com.ng/storage/uploads/$cleanPath';
  //       }
  //     }
  //   }

  //   return GestureDetector(
  //     onLongPress: () => _showMessageOptions(chatMessage),
  //     child: Row(
  //       mainAxisAlignment: isMe
  //           ? MainAxisAlignment.end
  //           : MainAxisAlignment.start,
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         if (!isMe && chatMessage.senderAvatar.isNotEmpty)
  //           CircleAvatar(
  //             radius: 15,
  //             backgroundImage: NetworkImage(chatMessage.senderAvatar),
  //           )
  //         else if (!isMe)
  //           CircleAvatar(
  //             radius: 15,
  //             backgroundColor: AppColors.primaryOrange.withOpacity(0.1),
  //             child: Text(
  //               chatMessage.senderName.isNotEmpty
  //                   ? chatMessage.senderName[0].toUpperCase()
  //                   : '?',
  //               style: TextStyle(
  //                 color: AppColors.primaryOrange,
  //                 fontWeight: FontWeight.bold,
  //                 fontSize: 12,
  //               ),
  //             ),
  //           ),
  //         if (!isMe) SizedBox(width: 8),

  //         Flexible(
  //           child: Container(
  //             constraints: BoxConstraints(
  //               maxWidth: 283,
  //             ),
  //             margin: EdgeInsets.symmetric(vertical: 4),
  //             decoration: BoxDecoration(
  //               color: isMe
  //                   ? AppColors.primaryOrangeLight
  //                   : AppColors.primaryGreyLight,
  //               borderRadius: BorderRadius.only(
  //                 topLeft: Radius.circular(16),
  //                 topRight: Radius.circular(16),
  //                 bottomLeft: isMe ? Radius.circular(16) : Radius.circular(4),
  //                 bottomRight: isMe ? Radius.circular(4) : Radius.circular(16),
  //               ),
  //             ),
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 if (!isMe && chatMessage.senderName != 'You')
  //                   Padding(
  //                     padding: EdgeInsets.only(left: 12, top: 8),
  //                     child: Text(
  //                       chatMessage.senderName,
  //                       style: TextStyle(
  //                         fontWeight: FontWeight.bold,
  //                         fontSize: 10,
  //                         color: AppColors.primaryBlack,
  //                       ),
  //                     ),
  //                   ),

  //                 // Video preview
  //                 if (fullFileUrl != null)
  //                   GestureDetector(
  //                     onTap: () {
  //                       _showVideoPreview(fullFileUrl!);
  //                     },
  //                     child: Container(
  //                       width: double.infinity,
  //                       height: 200,
  //                       margin: EdgeInsets.all(8),
  //                       decoration: BoxDecoration(
  //                         borderRadius: BorderRadius.circular(12),
  //                         color: Colors.black.withOpacity(0.1),
  //                       ),
  //                       child: Stack(
  //                         fit: StackFit.expand,
  //                         children: [
  //                           // Video thumbnail placeholder
  //                           Container(
  //                             decoration: BoxDecoration(
  //                               borderRadius: BorderRadius.circular(12),
  //                               gradient: LinearGradient(
  //                                 begin: Alignment.topLeft,
  //                                 end: Alignment.bottomRight,
  //                                 colors: [
  //                                   AppColors.primaryOrange.withOpacity(0.3),
  //                                   AppColors.primaryBlack.withOpacity(0.7),
  //                                 ],
  //                               ),
  //                             ),
  //                             child: Center(
  //                               child: Column(
  //                                 mainAxisAlignment: MainAxisAlignment.center,
  //                                 children: [
  //                                   Container(
  //                                     padding: EdgeInsets.all(16),
  //                                     decoration: BoxDecoration(
  //                                       color: Colors.white,
  //                                       shape: BoxShape.circle,
  //                                     ),
  //                                     child: Icon(
  //                                       Icons.play_arrow,
  //                                       color: AppColors.primaryOrange,
  //                                       size: 40,
  //                                     ),
  //                                   ),
  //                                   SizedBox(height: 12),
  //                                   Text(
  //                                     'VIDEO',
  //                                     style: TextStyle(
  //                                       color: Colors.white,
  //                                       fontSize: 14,
  //                                       fontWeight: FontWeight.bold,
  //                                     ),
  //                                   ),
  //                                   if (chatMessage.fileName != null)
  //                                     Padding(
  //                                       padding: EdgeInsets.only(top: 8),
  //                                       child: Text(
  //                                         chatMessage.fileName!,
  //                                         style: TextStyle(
  //                                           color: Colors.white70,
  //                                           fontSize: 12,
  //                                         ),
  //                                         textAlign: TextAlign.center,
  //                                       ),
  //                                     ),
  //                                 ],
  //                               ),
  //                             ),
  //                           ),

  //                           // Video duration badge
  //                           if (chatMessage.fileSize != null)
  //                             Positioned(
  //                               bottom: 12,
  //                               right: 12,
  //                               child: Container(
  //                                 padding: EdgeInsets.symmetric(
  //                                   horizontal: 8,
  //                                   vertical: 4,
  //                                 ),
  //                                 decoration: BoxDecoration(
  //                                   color: Colors.black.withOpacity(0.7),
  //                                   borderRadius: BorderRadius.circular(6),
  //                                 ),
  //                                 child: Text(
  //                                   _estimateVideoDuration(
  //                                     chatMessage.fileSize!,
  //                                   ),
  //                                   style: TextStyle(
  //                                     color: Colors.white,
  //                                     fontSize: 12,
  //                                     fontWeight: FontWeight.w500,
  //                                   ),
  //                                 ),
  //                               ),
  //                             ),
  //                         ],
  //                       ),
  //                     ),
  //                   ),

  //                 Padding(
  //                   padding: EdgeInsets.only(left: 12, bottom: 8, right: 12),
  //                   child: Text(
  //                     _formatTime(chatMessage.createdAt),
  //                     style: TextStyle(
  //                       fontSize: 8,
  //                       color: AppColors.primaryBlack.withOpacity(0.5),
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),

  //         if (isMe) SizedBox(width: 8),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildImageMessageBubble(ChatMessage chatMessage, bool isMe) {
  //   String? fullFileUrl;
  //   if (chatMessage.fileUrl != null) {
  //     if (chatMessage.fileUrl!.startsWith('http')) {
  //       fullFileUrl = chatMessage.fileUrl;
  //     } else {
  //       String cleanPath = chatMessage.fileUrl!.replaceFirst(RegExp(r'^/'), '');
  //       if (cleanPath.startsWith('uploads/')) {
  //         fullFileUrl = 'https://ediifyapi.tife.com.ng/storage/$cleanPath';
  //       } else {
  //         fullFileUrl =
  //             'https://ediifyapi.tife.com.ng/storage/uploads/$cleanPath';
  //       }
  //     }
  //   }

  //   return GestureDetector(
  //     onLongPress: () => _showMessageOptions(chatMessage),
  //     child: Row(
  //       mainAxisAlignment: isMe
  //           ? MainAxisAlignment.end
  //           : MainAxisAlignment.start,
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         if (!isMe && chatMessage.senderAvatar.isNotEmpty)
  //           CircleAvatar(
  //             radius: 15,
  //             backgroundImage: NetworkImage(chatMessage.senderAvatar),
  //           )
  //         else if (!isMe)
  //           CircleAvatar(
  //             radius: 15,
  //             backgroundColor: AppColors.primaryOrange.withOpacity(0.1),
  //             child: Text(
  //               chatMessage.senderName.isNotEmpty
  //                   ? chatMessage.senderName[0].toUpperCase()
  //                   : '?',
  //               style: TextStyle(
  //                 color: AppColors.primaryOrange,
  //                 fontWeight: FontWeight.bold,
  //                 fontSize: 12,
  //               ),
  //             ),
  //           ),
  //         if (!isMe) SizedBox(width: 8),

  //         Flexible(
  //           child: Container(
  //             constraints: BoxConstraints(
  //               maxWidth: 283,
  //             ),
  //             margin: EdgeInsets.symmetric(vertical: 4),
  //             decoration: BoxDecoration(
  //               color: isMe
  //                   ? AppColors.primaryOrangeLight
  //                   : AppColors.primaryGreyLight,
  //               borderRadius: BorderRadius.only(
  //                 topLeft: Radius.circular(16),
  //                 topRight: Radius.circular(16),
  //                 bottomLeft: isMe ? Radius.circular(16) : Radius.circular(4),
  //                 bottomRight: isMe ? Radius.circular(4) : Radius.circular(16),
  //               ),
  //             ),
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 if (!isMe && chatMessage.senderName != 'You')
  //                   Padding(
  //                     padding: EdgeInsets.only(left: 12, top: 8),
  //                     child: Text(
  //                       chatMessage.senderName,
  //                       style: TextStyle(
  //                         fontWeight: FontWeight.bold,
  //                         fontSize: 10,
  //                         color: AppColors.primaryBlack,
  //                       ),
  //                     ),
  //                   ),

  //                 // Image preview
  //                 if (fullFileUrl != null)
  //                   GestureDetector(
  //                     onTap: () {
  //                       _showImagePreview(fullFileUrl!);
  //                     },
  //                     child: Container(
  //                       width: double.infinity,
  //                       height: 200,
  //                       margin: EdgeInsets.all(8),
  //                       decoration: BoxDecoration(
  //                         borderRadius: BorderRadius.circular(12),
  //                         border: Border.all(color: Colors.grey.shade300),
  //                       ),
  //                       child: ClipRRect(
  //                         borderRadius: BorderRadius.circular(12),
  //                         child: Image.network(
  //                           fullFileUrl,
  //                           fit: BoxFit.cover,
  //                           loadingBuilder: (context, child, loadingProgress) {
  //                             if (loadingProgress == null) return child;
  //                             return Container(
  //                               color: Colors.grey.shade200,
  //                               child: Center(
  //                                 child: CircularProgressIndicator(
  //                                   value:
  //                                       loadingProgress.expectedTotalBytes !=
  //                                           null
  //                                       ? loadingProgress
  //                                                 .cumulativeBytesLoaded /
  //                                             loadingProgress
  //                                                 .expectedTotalBytes!
  //                                       : null,
  //                                 ),
  //                               ),
  //                             );
  //                           },
  //                           errorBuilder: (context, error, stackTrace) {
  //                             return Container(
  //                               color: Colors.grey.shade200,
  //                               child: Column(
  //                                 mainAxisAlignment: MainAxisAlignment.center,
  //                                 children: [
  //                                   Icon(
  //                                     Icons.error_outline,
  //                                     color: Colors.red,
  //                                     size: 40,
  //                                   ),
  //                                   SizedBox(height: 8),
  //                                   Text(
  //                                     'Failed to load image',
  //                                     style: TextStyle(fontSize: 12),
  //                                   ),
  //                                 ],
  //                               ),
  //                             );
  //                           },
  //                         ),
  //                       ),
  //                     ),
  //                   ),

  //                 Padding(
  //                   padding: EdgeInsets.only(left: 12, bottom: 8, right: 12),
  //                   child: Text(
  //                     _formatTime(chatMessage.createdAt),
  //                     style: TextStyle(
  //                       fontSize: 8,
  //                       color: AppColors.primaryBlack.withOpacity(0.5),
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),

  //         if (isMe) SizedBox(width: 8),
  //       ],
  //     ),
  //   );
  // }

  // Voice message bubble (existing)
  Widget _buildVoiceMessageBubble(ChatMessage chatMessage, bool isMe) {
    String? fullFileUrl;
    if (chatMessage.fileUrl != null) {
      if (chatMessage.fileUrl!.startsWith('http')) {
        fullFileUrl = chatMessage.fileUrl;
      } else {
        String cleanPath = chatMessage.fileUrl!.replaceFirst(RegExp(r'^/'), '');
        if (cleanPath.startsWith('uploads/')) {
          fullFileUrl = 'https://ediifyapi.tife.com.ng/storage/$cleanPath';
        } else {
          fullFileUrl =
              'https://ediifyapi.tife.com.ng/storage/uploads/$cleanPath';
        }
      }
    }

    return GestureDetector(
      onLongPress: () => _showMessageOptions(chatMessage),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe && chatMessage.senderAvatar.isNotEmpty)
            CircleAvatar(
              radius: 15,
              backgroundImage: NetworkImage(chatMessage.senderAvatar),
            )
          else if (!isMe)
            CircleAvatar(
              radius: 15,
              backgroundColor: AppColors.primaryOrange.withOpacity(0.1),
              child: Text(
                chatMessage.senderName.isNotEmpty
                    ? chatMessage.senderName[0].toUpperCase()
                    : '?',
                style: TextStyle(
                  color: AppColors.primaryOrange,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          if (!isMe) SizedBox(width: 8),

          Flexible(
            child: Container(
              padding: EdgeInsets.all(8),
              margin: EdgeInsets.symmetric(vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isMe && chatMessage.senderName != 'You')
                    Padding(
                      padding: EdgeInsets.only(left: 8, bottom: 4),
                      child: Text(
                        chatMessage.senderName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          color: AppColors.primaryBlack,
                        ),
                      ),
                    ),

                  // WhatsApp-style voice player
                  if (fullFileUrl != null)
                    WhatsAppVoicePlayer(
                      audioUrl: fullFileUrl,
                      fileName: chatMessage.fileName,
                      duration: chatMessage.fileSize != null
                          ? (chatMessage.fileSize! / 16000).round()
                          : null,
                      isMe: isMe,
                    ),

                  SizedBox(height: 4),
                  Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Text(
                      _formatTime(chatMessage.createdAt),
                      style: TextStyle(
                        fontSize: 8,
                        color: AppColors.primaryBlack.withOpacity(0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (isMe) SizedBox(width: 8),
        ],
      ),
    );
  }

  // Widget _buildDateHeader(String dateText) {
  //   return Container(
  //     margin: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
  //     padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  //     decoration: BoxDecoration(
  //       color: AppColors.primaryGreyLight.withOpacity(0.7),
  //       borderRadius: BorderRadius.circular(20),
  //     ),
  //     child: Text(
  //       dateText,
  //       style: TextStyle(
  //         fontSize: 12,
  //         color: AppColors.primaryBlack,
  //         fontWeight: FontWeight.w500,
  //       ),
  //     ),
  //   );
  // }

  // Link and Phone Handlers
  void _handleLinkTap(String link) async {
    String url = link;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Open Link'),
        content: Text('Do you want to open this link?\n\n$url'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              print('🌐 Opening link: $url');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Opening: $url'),
                  backgroundColor: const Color.fromARGB(75, 21, 23, 24),
                ),
              );
            },
            child: Text('Open'),
          ),
        ],
      ),
    );
  }

  void _handlePhoneTap(String phone) {
    final cleanPhone = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Phone Number'),
        content: Text('What would you like to do with this number?\n\n$phone'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              print('📞 Calling: $cleanPhone');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Calling: $phone'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text('Call'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              print('💬 Messaging: $cleanPhone');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Messaging: $phone'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            child: Text('Message'),
          ),
        ],
      ),
    );
  }

  // Simplified Attachment Picker
  void _showAttachmentOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(color: Colors.transparent),
              ),
            ),
            Positioned(
              bottom: 30,
              left: 0,
              child: Container(
                width: 229,
                height: 87,
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryLightGreyJoinR,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _pickAnyFile();
                      },
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.zero),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.attach_file_outlined,
                            color: AppColors.primaryBlack,
                            size: 20,
                          ),
                          CustomTexts(
                            title: 'Attach Files',
                            textColor: AppColors.primaryBlack,
                            textSize: 14,
                            textWeight: FontWeight.w500,
                            textAlignment: AlignmentGeometry.centerLeft,
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _pickImageFromGallery();
                      },
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.zero),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.photo_library_outlined,
                            color: AppColors.primaryBlack,
                            size: 20,
                          ),
                          CustomTexts(
                            title: 'Choose photo or video',
                            textColor: AppColors.primaryBlack,
                            textSize: 14,
                            textWeight: FontWeight.w500,
                            textAlignment: AlignmentGeometry.centerLeft,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // New method to pick any file type
  void _pickAnyFile() async {
    print('📁 Picking any file...');
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final fileName = result.files.single.name;
        final fileSize = result.files.single.size;

        print('📄 Selected file: $fileName (${fileSize} bytes)');

        // Determine file type
        String fileType = 'document';
        if (fileName.toLowerCase().contains(
          RegExp(r'\.(jpg|jpeg|png|gif|bmp|webp)$'),
        )) {
          fileType = 'image';
        } else if (fileName.toLowerCase().contains(
          RegExp(r'\.(mp4|mov|avi|mkv|webm)$'),
        )) {
          fileType = 'video';
        } else if (fileName.toLowerCase().contains(
          RegExp(r'\.(mp3|wav|aac|ogg|flac|m4a)$'),
        )) {
          fileType = 'audio';
        }

        await _validateAndSendFile(file, fileType);
      }
    } catch (e) {
      _showErrorSnackbar('Failed to pick file: ${e.toString()}');
    }
  }

  // _showMessageOptions, _showEmojiPicker, _handleReaction, etc. remain the same
  void _showMessageOptions(ChatMessage message) {
    final userProvider = context.read<UserProvider>();
    final chatProvider = context.read<ChatProvider>();
    final groupProvider = context.read<GroupProvider>();

    final currentUser = userProvider.user;
    final isCurrentUserAdmin = true;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return MessageOptionsDialog(
          message: message,
          currentUser: currentUser,
          isCurrentUserAdmin: isCurrentUserAdmin,
          onReply: (action) => _handleReply(message),
          onReact: (action) => _showEmojiPicker(message),
          onShare: () => _shareMessage(message),
          onCopy: () => _copyMessage(message),
          onDelete: () => _deleteMessage(message),
          onPin: () => _pinMessage(message),
          onForward: () => _forwardMessage(message),
        );
      },
    );
  }

  // void _showEmojiPicker(ChatMessage message) {
  //   showModalBottomSheet(
  //     context: context,
  //     backgroundColor: Colors.transparent,
  //     builder: (context) {
  //       return EmojiPickerWidget(
  //         onEmojiSelected: (emoji) => _handleReaction(message, emoji),
  //       );
  //     },
  //   );
  // }

  // void _handleReaction(ChatMessage message, String emoji) async {
  //   final userProvider = context.read<UserProvider>();
  //   final chatProvider = context.read<ChatProvider>();

  //   final currentUser = userProvider.user;
  //   if (currentUser == null) return;

  //   final success = await chatProvider.reactToMessage(
  //     messageId: message.id,
  //     emoji: emoji,
  //     userId: currentUser.id,
  //     userName: currentUser.fullName,
  //   );

  //   if (success) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text(
  //           'Reacted with $emoji , just kidding not yet functional',
  //         ),
  //         backgroundColor: const Color.fromARGB(0, 76, 175, 79),
  //       ),
  //     );
  //   }
  // }

  void _deleteMessage(ChatMessage message) async {
    final chatProvider = context.read<ChatProvider>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Message'),
        content: Text('Are you sure you want to delete this message?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await chatProvider.deleteMessage(message.id);
              if (success) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Message deleted')));
              }
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _forwardMessage(ChatMessage message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Forward functionality coming soon')),
    );
  }

  Widget _buildReactionsBar(ChatMessage message) {
    final reactionGroups = <String, List<MessageReaction>>{};
    for (final reaction in message.reactions) {
      reactionGroups[reaction.emoji] = [
        ...reactionGroups[reaction.emoji] ?? [],
        reaction,
      ];
    }

    return Container(
      margin: EdgeInsets.only(top: 4),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Wrap(
        spacing: 4,
        children: reactionGroups.entries.map((entry) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(entry.key),
                SizedBox(width: 4),
                Text('${entry.value.length}', style: TextStyle(fontSize: 10)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // [REST OF YOUR EXISTING FILE UPLOAD AND MEDIA METHODS...]
  void _pickImageFromGallery() async {
    print('📸 Picking image from gallery...');
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image != null) {
        await _validateAndSendFile(File(image.path), 'image');
      }
    } catch (e) {
      _showErrorSnackbar('Failed to pick image: ${e.toString()}');
    }
  }

  void _takePhotoWithCamera() async {
    if (!await _requestPermissions()) {
      _showErrorSnackbar('Camera and storage permissions are required');
      return;
    }

    try {
      final image = await ImagePicker().pickImage(source: ImageSource.camera);
      if (image != null) {
        await _validateAndSendFile(File(image.path), 'image');
      }
    } catch (e) {
      _showErrorSnackbar('Failed to take photo: ${e.toString()}');
    }
  }

  Future<bool> _requestPermissions() async {
    if (await Permission.camera.request().isGranted &&
        await Permission.microphone.request().isGranted &&
        await Permission.storage.request().isGranted) {
      return true;
    }
    return false;
  }

  Future<void> _validateAndSendFile(File file, String fileType) async {
    try {
      final fileStat = await file.stat();
      final fileSize = fileStat.size;
      final fileName = file.path.split('/').last;

      // Check file size limits
      final maxSize = _getMaxSizeForType(fileType);
      if (fileSize > maxSize) {
        _showErrorSnackbar(
          'File too large: ${FileUploadLimits.getSizeReadable(fileSize)}\n'
          'Maximum allowed: ${FileUploadLimits.getLimitReadable(fileType)}',
        );
        return;
      }

      // Send the file
      await _sendFileMessageWithProgress(file, fileType);
    } catch (e) {
      _showErrorSnackbar('Error validating file: ${e.toString()}');
    }
  }

  int _getMaxSizeForType(String fileType) {
    switch (fileType) {
      case 'image':
        return FileUploadLimits.maxImageSize;
      case 'audio':
        return FileUploadLimits.maxAudioSize;
      case 'video':
        return FileUploadLimits.maxVideoSize;
      case 'document':
        return FileUploadLimits.maxDocumentSize;
      default:
        return FileUploadLimits.maxDocumentSize;
    }
  }

  Future<void> _sendFileMessageWithProgress(
    File file,
    String messageType,
  ) async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    print('📁 Starting file upload: ${file.path}');

    // Show uploading indicator message
    final tempMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch,
      groupId: widget.group.id,
      userId: userProvider.user?.id ?? 0,
      message: 'Uploading file...',
      createdAt: DateTime.now().toIso8601String(),
      senderName: 'You',
      hasFile: true,
      hasMessage: false,
      fileName: file.path.split('/').last,
    );

    chatProvider.addMessage(tempMessage);
    _scrollToBottom();

    try {
      print('🔄 Uploading file...');

      final fileName = file.path.split('/').last;
      final customMessage = _getFileMessageText(messageType, fileName);

      // Upload without progress tracking
      var uploadResponse = await ChatService.uploadFileMultipart(
        file,
        groupId: widget.group.id,
        customMessage: customMessage,
      );

      print(
        '🔍 Upload response: ${uploadResponse.status} - ${uploadResponse.message}',
      );

      if (uploadResponse.isSuccess) {
        print('✅ File uploaded successfully!');

        // Remove temporary message
        chatProvider.removeMessage(tempMessage.id);

        _showSuccessSnackbar('File uploaded successfully');
      } else {
        print('❌ File upload failed: ${uploadResponse.message}');

        // Update the temporary message to show failure
        final errorMessage = ChatMessage(
          id: tempMessage.id,
          groupId: widget.group.id,
          userId: userProvider.user?.id ?? 0,
          message: 'Upload failed: ${uploadResponse.message}',
          createdAt: DateTime.now().toIso8601String(),
          senderName: 'You',
          hasFile: false,
          hasMessage: true,
        );

        chatProvider.removeMessage(tempMessage.id);
        chatProvider.addMessage(errorMessage);

        _showErrorSnackbar('Upload failed: ${uploadResponse.message}');
      }
    } catch (e) {
      print('❌ File upload error: $e');

      // Update the temporary message to show error
      final errorMessage = ChatMessage(
        id: tempMessage.id,
        groupId: widget.group.id,
        userId: userProvider.user?.id ?? 0,
        message: 'Upload error',
        createdAt: DateTime.now().toIso8601String(),
        senderName: 'You',
        hasFile: false,
        hasMessage: true,
      );

      chatProvider.removeMessage(tempMessage.id);
      chatProvider.addMessage(errorMessage);

      _showErrorSnackbar('Upload error: ${e.toString()}');
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _getFileMessageText(String messageType, String fileName) {
    switch (messageType) {
      case 'image':
        return 'Shared an image: $fileName';
      case 'video':
        return 'Shared a video: $fileName';
      case 'audio':
        return 'Shared an audio file: $fileName';
      case 'document':
        return 'Shared a document: $fileName';
      default:
        return 'Shared a file: $fileName';
    }
  }

  String _formatFileSize(double bytes) {
    const units = ['B', 'KB', 'MB', 'GB'];
    var size = bytes;
    var unitIndex = 0;

    while (size > 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }

    return '${size.toStringAsFixed(1)} ${units[unitIndex]}';
  }

  // Voice Recording Methods
  // void _startVoiceMessage() {
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     backgroundColor: Colors.transparent,
  //     builder: (context) => _buildVoiceRecordingUI(),
  //   );
  // }

  // Widget _buildVoiceRecordingUI() {
  //   return Container(
  //     height: 450,
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  //     ),
  //     child: Column(
  //       children: [
  //         // Header
  //         Container(
  //           padding: EdgeInsets.all(16),
  //           decoration: BoxDecoration(
  //             border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
  //           ),
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: [
  //               Text(
  //                 'Voice Message',
  //                 style: TextStyle(
  //                   fontSize: 18,
  //                   fontWeight: FontWeight.bold,
  //                   color: AppColors.primaryBlack,
  //                 ),
  //               ),
  //               IconButton(
  //                 onPressed: () {
  //                   _cancelRecording();
  //                   Navigator.pop(context);
  //                 },
  //                 icon: Icon(Icons.close, color: AppColors.primaryBlack),
  //               ),
  //             ],
  //           ),
  //         ),

  //         Expanded(
  //           child: Padding(
  //             padding: EdgeInsets.all(20),
  //             child: Column(
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               children: [
  //                 // Recording visualization with timer
  //                 Container(
  //                   padding: EdgeInsets.all(20),
  //                   child: Column(
  //                     children: [
  //                       // Timer display
  //                       Text(
  //                         _formatRecordingDuration(_recordingDuration),
  //                         style: TextStyle(
  //                           fontSize: 32,
  //                           fontWeight: FontWeight.bold,
  //                           color: AppColors.primaryBlack,
  //                         ),
  //                       ),
  //                       SizedBox(height: 16),

  //                       // Recording animation
  //                       _buildRecordingAnimation(),

  //                       SizedBox(height: 8),

  //                       // Recording status
  //                       Text(
  //                         _isRecording
  //                             ? 'Recording...'
  //                             : 'Tap and hold to record',
  //                         style: TextStyle(
  //                           color: AppColors.primaryBlackLight,
  //                           fontSize: 14,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),

  //                 SizedBox(height: 30),

  //                 // Recording button - WhatsApp style
  //                 _isRecording
  //                     ? _buildRecordingInProgress()
  //                     : _buildStartRecordingButton(),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildRecordingAnimation() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      width: _isRecording ? 80 : 60,
      height: _isRecording ? 80 : 60,
      decoration: BoxDecoration(
        color: _isRecording
            ? AppColors.primaryOrange.withOpacity(0.1)
            : Colors.grey.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: _isRecording ? AppColors.primaryOrange : Colors.grey,
          width: 2,
        ),
      ),
      child: Icon(
        Icons.mic,
        size: _isRecording ? 40 : 30,
        color: _isRecording ? AppColors.primaryOrange : Colors.grey,
      ),
    );
  }

  Widget _buildStartRecordingButton() {
    return GestureDetector(
      onLongPressStart: (details) async {
        await _startRecording();
      },
      onLongPressEnd: (details) async {
        await _stopRecording();
        if (mounted) {
          Navigator.pop(context);
        }
      },
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: AppColors.primaryOrange,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryOrange.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(Icons.mic, color: Colors.white, size: 30),
      ),
    );
  }

  Widget _buildRecordingInProgress() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Cancel button
        GestureDetector(
          onTap: () {
            _cancelRecording();
            if (mounted) {
              Navigator.pop(context);
            }
          },
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.red),
            ),
            child: Icon(Icons.delete, color: Colors.red, size: 30),
          ),
        ),

        // Stop button (larger)
        GestureDetector(
          onTap: () async {
            await _stopRecording();
            if (mounted) {
              Navigator.pop(context);
            }
          },
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.primaryOrange,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.stop, color: Colors.white, size: 30),
          ),
        ),

        // Lock/Send button placeholder
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.green),
          ),
          child: Icon(Icons.send, color: Colors.green, size: 30),
        ),
      ],
    );
  }

  // Future<void> _startRecording() async {
  //   try {
  //     print('🎤 Starting recording from UI...');

  //     final result = await VoiceRecordingService.startRecording(
  //       onTimerUpdate: (duration) {
  //         print('⏰ Timer update: $duration seconds');
  //         if (mounted) {
  //           setState(() {
  //             _recordingDuration = duration;
  //           });
  //         } else {
  //           print('⚠️ Widget not mounted, cannot update timer');
  //         }
  //       },
  //     );

  //     if (result.success) {
  //       setState(() {
  //         _isRecording = true;
  //         _currentRecordingPath = result.filePath;
  //         _recordingDuration = 0;
  //       });

  //       print('✅ Recording started successfully: ${result.filePath}');

  //       // Start a backup timer just in case
  //       _startBackupTimer();
  //     } else {
  //       print('❌ Failed to start recording: ${result.error}');
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Failed to start recording: ${result.error}'),
  //           backgroundColor: Colors.red,
  //           duration: Duration(seconds: 3),
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     print('❌ Start recording error: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Recording error: $e'),
  //         backgroundColor: Colors.red,
  //         duration: Duration(seconds: 3),
  //       ),
  //     );
  //   }
  // }

  // void _startBackupTimer() {
  //   _recordingTimer?.cancel();
  //   _recordingTimer = Timer.periodic(Duration(seconds: 1), (timer) {
  //     if (_isRecording && mounted) {
  //       setState(() {
  //         _recordingDuration++;
  //       });
  //       print('⏰ Backup timer: $_recordingDuration seconds');
  //     } else {
  //       timer.cancel();
  //     }
  //   });
  // }

  // Future<void> _stopRecording() async {
  //   try {
  //     if (!_isRecording) {
  //       print('⚠️ No active recording to stop');
  //       return;
  //     }

  //     print('⏹️ Stopping recording from UI...');
  //     final result = await VoiceRecordingService.stopRecording();

  //     if (result.success && result.filePath != null) {
  //       print('✅ Recording stopped: ${result.filePath}');
  //       print(
  //         '📊 Recording duration: ${result.duration}s, size: ${result.fileSize} bytes',
  //       );

  //       // Send the voice message
  //       await _sendVoiceMessage(result.filePath!);
  //     } else {
  //       print('❌ Failed to stop recording: ${result.error}');
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Failed to stop recording: ${result.error}'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     print('❌ Stop recording error: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Recording error: $e'),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //   } finally {
  //     _cleanupRecording();
  //   }
  // }

  // void _cancelRecording() async {
  //   try {
  //     await VoiceRecordingService.cancelRecording();
  //     print('❌ Recording cancelled');
  //   } catch (e) {
  //     print('❌ Cancel recording error: $e');
  //   } finally {
  //     _cleanupRecording();
  //   }
  // }

  // void _cleanupRecording() {
  //   _recordingTimer?.cancel();
  //   setState(() {
  //     _isRecording = false;
  //     _recordingDuration = 0;
  //     _currentRecordingPath = null;
  //   });
  // }

  Future<void> _sendVoiceMessage(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        print('🎵 Sending voice message: $filePath');

        // Use your existing file sending method
        _sendFileMessageWithProgress(file, 'audio');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Voice message sent'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Voice file not found');
      }
    } catch (e) {
      print('❌ Send voice message error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send voice message: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Media Options
  void _showMediaOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Choose Media',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlack,
                ),
              ),
              SizedBox(height: 20),

              // Photo Option
              ListTile(
                leading: Icon(
                  Icons.photo_library_outlined,
                  color: AppColors.primaryOrange,
                  size: 28,
                ),
                title: Text(
                  'Photo Library',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromGallery();
                },
              ),

              // Camera Option
              ListTile(
                leading: Icon(
                  Icons.photo_camera_outlined,
                  color: AppColors.primaryOrange,
                  size: 28,
                ),
                title: Text(
                  'Take Photo',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _takePhotoWithCamera();
                },
              ),

              SizedBox(height: 10),
              Divider(),
              SizedBox(height: 10),

              // Cancel Button
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: AppColors.primaryOrange,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Call Options
  void _showCallOptions() {
    // if (currentUserId == null) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //       content: Text('Unable to start call: User not logged in'),
    //       backgroundColor: Colors.red,
    //     ),
    //   );
    //   return;
  }

  void _startAudioCall() async {
    await _startCall(false);
  }

  void _startVideoCall() async {
    await _startCall(true);
  }

  Future<void> _startCall(bool isVideoCall) async {
    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to start call: User not logged in'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      print(
        '📞 Starting ${isVideoCall ? 'video' : 'audio'} call for group ${widget.group.id}',
      );

      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Start the call via API
      final response = await CallService.startCall(
        groupId: widget.group.id,
        hostId: currentUserId!,
        isVideoCall: isVideoCall,
      );

      // Hide loading
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (response.isSuccess && response.data != null && context.mounted) {
        // Use the host URL to open in browser
        final meetingUrl = response.data!.hostUrl;

        print('🌐 Opening meeting in browser: $meetingUrl');

        // Launch the URL in external browser
        await _launchInAppBrowser(meetingUrl);
      } else if (context.mounted) {
        _showCallError('Failed to start call: ${response.message}');
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        _showCallError('Error starting call: $e');
      }
    }
  }

  Future<void> _launchInAppBrowser(String url) async {
    try {
      final Uri uri = Uri.parse(url);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Opening meeting in browser...'),
            backgroundColor: const Color.fromARGB(54, 11, 14, 11),
          ),
        );
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      print('❌ Failed to launch URL: $e');
      _showCallError('Failed to open browser: $e');
    }
  }

  void _showCallError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  //   showModalBottomSheet(
  //     context: context,
  //     builder: (context) => Container(
  //       padding: const EdgeInsets.all(20),
  //       child: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           const Text(
  //             'Start a Call',
  //             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  //           ),
  //           const SizedBox(height: 20),
  //           CallInitiationWidget(
  //             groupId: widget.group.id,
  //             userId: currentUserId!,
  //             groupName: widget.group.groupName,
  //           ),
  //           const SizedBox(height: 20),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Helper Methods
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  String _formatTime(String createdAt) {
    try {
      final dateTime = DateTime.parse(createdAt);
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'now';
    }
  }

  // String _formatRecordingDuration(int seconds) {
  //   final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
  //   final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
  //   return '$minutes:$remainingSeconds';
  // }

  String _estimateVideoDuration(double fileSizeInBytes) {
    final estimatedSeconds = (fileSizeInBytes / (100 * 1024)).round();
    final minutes = (estimatedSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (estimatedSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _showImagePreview(String imageUrl) {
    print('🖼️ Showing image preview: $imageUrl');
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(2),
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.black87,
              ),
              child: InteractiveViewer(
                panEnabled: true,
                minScale: 0.5,
                maxScale: 3.0,
                child: Center(
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      print('❌ Preview image load error: $error');
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error, color: Colors.white, size: 50),
                            SizedBox(height: 10),
                            Text(
                              'Failed to load image',
                              style: TextStyle(color: Colors.white),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'URL: $imageUrl',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showVideoPreview(String videoUrl, {String? fileName}) {
    print('🎥 Showing enhanced video preview: $videoUrl');
    showDialog(
      context: context,
      builder: (context) => VideoPreviewDialog(
        videoUrl: videoUrl,
        videoTitle: fileName ?? 'Video',
      ),
    );
  }

  Widget _buildMessagesList(
    ChatProvider chatProvider,
    UserProvider userProvider,
  ) {
    if (chatProvider.messages.isEmpty) {
      return Column(
        children: [
          SizedBox(height: 100),
          Icon(
            Icons.chat_outlined,
            size: 64,
            color: AppColors.primaryBlackLight,
          ),
          SizedBox(height: 16),
          CustomTexts(
            title: 'No messages yet',
            textColor: AppColors.primaryBlack,
            textSize: 16,
            textWeight: FontWeight.w500,
            textAlignment: Alignment.center,
          ),
          SizedBox(height: 8),
          CustomTexts(
            title: 'Start the conversation!',
            textColor: AppColors.primaryBlackLight,
            textSize: 14,
            textWeight: FontWeight.w400,
            textAlignment: Alignment.center,
          ),
        ],
      );
    }

    // Group messages by date without modifying the model
    final messagesByDate = <String, List<ChatMessage>>{};

    for (final message in chatProvider.messages) {
      final dateKey = _getDateKey(message.createdAt);
      if (!messagesByDate.containsKey(dateKey)) {
        messagesByDate[dateKey] = [];
      }
      messagesByDate[dateKey]!.add(message);
    }

    // Sort dates in chronological order
    final sortedDates = messagesByDate.keys.toList()
      ..sort((a, b) => a.compareTo(b));

    return Column(
      children: [
        for (final dateKey in sortedDates) ...[
          _buildDateHeader(_formatDateHeader(dateKey)),
          for (final message in messagesByDate[dateKey]!)
            _buildMessageBubble(
              chatMessage: message,
              isMe:
                  message.userId == userProvider.user?.id ||
                  message.senderName == 'You',
            ),
        ],
      ],
    );
  }

  String _getDateKey(String createdAt) {
    try {
      final date = DateTime.parse(createdAt);
      return "${date.year}-${date.month}-${date.day}";
    } catch (e) {
      // Fallback for invalid dates
      final now = DateTime.now();
      return "${now.year}-${now.month}-${now.day}";
    }
  }

  String _formatDateHeader(String dateKey) {
    try {
      final parts = dateKey.split('-');
      if (parts.length == 3) {
        final year = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final day = int.parse(parts[2]);

        final messageDate = DateTime(year, month, day);
        final today = DateTime.now();
        final yesterday = today.subtract(Duration(days: 1));

        // Check if it's today
        if (messageDate.year == today.year &&
            messageDate.month == today.month &&
            messageDate.day == today.day) {
          return 'Today';
        }

        // Check if it's yesterday
        if (messageDate.year == yesterday.year &&
            messageDate.month == yesterday.month &&
            messageDate.day == yesterday.day) {
          return 'Yesterday';
        }

        // Check if it's this year
        if (messageDate.year == today.year) {
          // Format: "Mon 25 Dec"
          return DateFormat('EEE d MMM').format(messageDate);
        } else {
          // Format: "Mon 25 Dec 2023"
          return DateFormat('EEE d MMM yyyy').format(messageDate);
        }
      }
    } catch (e) {
      print('Error formatting date: $e');
    }

    return dateKey; // Fallback
  }

  Widget _buildDateHeader(String dateText) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: AppColors.primaryBlackLight.withOpacity(0.3),
              thickness: 1,
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryGreyLight.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              dateText,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.primaryBlack,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Divider(
              color: AppColors.primaryBlackLight.withOpacity(0.3),
              thickness: 1,
            ),
          ),
        ],
      ),
    );
  }

  // In your GroupChatPage build method, add this above the input field
  Widget _buildReplyPreview() {
    final chatProvider = context.watch<ChatProvider>();
    final replyMessage = chatProvider.replyMessage;

    if (replyMessage == null) return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryOrangeLight,
        // border: Border(
        //   left: BorderSide(color: AppColors.primaryOrange, width: 4),
        // ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Replying to ${replyMessage.senderName}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 8,
                    color: AppColors.primaryOrange,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  replyMessage.message ?? 'File',
                  style: TextStyle(fontSize: 10),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, size: 12),
            onPressed: () {
              chatProvider.clearReplyMessage();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryWhiteIcon,
      appBar: AppBar(
        backgroundColor: AppColors.primaryWhiteIcon,
        actions: [
          NotificationIcon(currentGroupId: widget.group.id),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Consumer<UserProvider>(
                  builder: (context, userProvider, child) {
                    return SimpleUserAvatar(
                      imageUrl: userProvider.user?.avatarUrl,
                      userName: userProvider.user?.fullName,
                      size: 40,
                    );
                  },
                ),
              ),
              CustomIconButton(),
            ],
          ),
          SizedBox(width: 17.81),
        ],
        title: CustomAppbar(),
        elevation: 0,
      ),
      body: FutureBuilder(
        future: _messagesFuture,
        builder: (context, snapshot) {
          final chatProvider = Provider.of<ChatProvider>(context);
          final userProvider = Provider.of<UserProvider>(context);

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading messages: ${snapshot.error}'),
            );
          }

          if (chatProvider.isLoading && chatProvider.messages.isEmpty) {
            return Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.only(
                  left: 15,
                  top: 16,
                  right: 17,
                  bottom: 16,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryWhiteNormal,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Group Icon - Clickable to go to Profile
                    GestureDetector(
                      onTap: () {
                        _navigateToGroupProfile();
                      },
                      child: Icon(
                        Icons.groups_outlined,
                        size: 45,
                        color: AppColors.primaryAppbarBlack,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          _navigateToGroupProfile();
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CustomTexts(
                                  title: widget.group.groupName,
                                  textColor: AppColors.primaryBlack,
                                  textSize: 14,
                                  textWeight: FontWeight.w600,
                                  textAlignment: Alignment.centerLeft,
                                ),
                              ],
                            ),
                            _buildConnectionStatus(chatProvider),
                            // CustomTexts(
                            //   title: 'online',
                            //   textColor: AppColors.primaryBlack,
                            //   textSize: 10,
                            //   textWeight: FontWeight.w400,
                            //   textAlignment: Alignment.centerLeft,
                            // ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        _navigateToGroupProfile();
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.group_add_outlined,
                          size: 24,
                          color: AppColors.primaryOrange,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        // Audio Call Button
                        IconButton(
                          onPressed: _startAudioCall,
                          icon: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(shape: BoxShape.circle),
                            child: Icon(
                              Icons.call_outlined,
                              size: 24,
                              color: AppColors.primaryOrange,
                            ),
                          ),
                        ),

                        // Video Call Button
                        IconButton(
                          onPressed: _startVideoCall,
                          icon: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(shape: BoxShape.circle),
                            child: Icon(
                              Icons.videocam_outlined,
                              size: 24,
                              color: AppColors.primaryOrange,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              MeetingSnackbar(groupName: widget.group.groupName),

              // Typing Indicator
              _buildTypingIndicator(chatProvider),

              // Messages Section
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: EdgeInsets.all(16),
                  child: _buildMessagesList(chatProvider, userProvider),
                ),
              ),

              // Input Section with Icons
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Colors.grey.shade300)),
                ),
                child: Row(
                  children: [
                    // Left Icons - attachment
                    IconButton(
                      onPressed: () {
                        _showAttachmentOptions(context);
                      },
                      icon: Icon(
                        Icons.add_outlined,
                        color: AppColors.primaryOrange,
                        size: 24,
                      ),
                    ),

                    // Text Input with Send Button Inside
                    Expanded(
                      child: Container(
                        constraints: BoxConstraints(maxHeight: 120),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // reply preview section
                            _buildReplyPreview(),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _messageController,
                                    decoration: InputDecoration(
                                      hintText: 'Type a message...',
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                    ),
                                    maxLines: null,
                                    onSubmitted: (value) => _sendMessage(),
                                    cursorColor: AppColors.primaryOrange,
                                  ),
                                ),

                                // Send Button Inside the Text Field
                                Container(
                                  margin: EdgeInsets.all(4),
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: _hasText && !chatProvider.isSending
                                        ? AppColors.primaryOrange
                                        : AppColors.primaryBlackLight
                                              .withOpacity(0.3),
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    onPressed:
                                        _hasText && !chatProvider.isSending
                                        ? _sendMessage
                                        : null,
                                    icon: chatProvider.isSending
                                        ? SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : Icon(
                                            Icons.send,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Right Icon - Camera and Mic
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            _showMediaOptions(context);
                          },
                          icon: Icon(
                            Icons.camera_alt_outlined,
                            color: AppColors.primaryOrange,
                            size: 24,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            _startVoiceMessage();
                          },
                          icon: Icon(
                            Icons.mic_outlined,
                            color: AppColors.primaryOrange,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
