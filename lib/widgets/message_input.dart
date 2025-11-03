import 'package:flutter/material.dart';
import 'package:edify_app/constants/colors.dart';

class MessageInput extends StatefulWidget {
  final Function(String) onSendMessage;
  final bool isSending;

  const MessageInput({
    super.key,
    required this.onSendMessage,
    this.isSending = false,
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final TextEditingController _messageController = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _hasText = _messageController.text.trim().isNotEmpty;
    });
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty && !widget.isSending) {
      widget.onSendMessage(message);
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: AppColors.primaryBlackLight.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Attachment Button (optional)
          IconButton(
            onPressed: () {
              // TODO: Implement file attachment
            },
            icon: Icon(
              Icons.attach_file_outlined,
              color: AppColors.primaryBlackLight,
              size: 24,
            ),
          ),
          SizedBox(width: 8),

          // Text Input Field
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primaryWhiteNormal,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.primaryBlackLight.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      cursorColor: AppColors.primaryOrange,
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: TextStyle(
                          color: AppColors.primaryBlackLight.withOpacity(0.5),
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (value) => _sendMessage(),
                    ),
                  ),

                  // Emoji Button (optional)
                  IconButton(
                    onPressed: () {
                      // TODO: Implement emoji picker
                    },
                    icon: Icon(
                      Icons.emoji_emotions_outlined,
                      color: AppColors.primaryBlackLight,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 8),

          // Send Button
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _hasText && !widget.isSending
                  ? AppColors.primaryOrange
                  : AppColors.primaryBlackLight.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: _hasText && !widget.isSending ? _sendMessage : null,
              icon: widget.isSending
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
