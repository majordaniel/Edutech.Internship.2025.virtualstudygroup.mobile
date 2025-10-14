import 'package:flutter/material.dart';

class ChatWidget extends StatefulWidget {
  final Widget leadIcon; // Keep as Widget
  final Widget chatName; // Keep as Widget
  final Widget lastChat; // Keep as Widget
  final Widget timeStamp; // Keep as Widget
  final Widget? pinChat; // Keep as Widget

  const ChatWidget({
    super.key,
    required this.chatName,
    required this.lastChat,
    required this.leadIcon,
    this.pinChat,
    required this.timeStamp,
  });

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Use the widget directly - no casting needed
          widget.leadIcon,
          SizedBox(width: 16),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [widget.chatName, SizedBox(height: 4), widget.lastChat],
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              widget.timeStamp,
              SizedBox(height: 8),
              if (widget.pinChat != null) widget.pinChat!,
            ],
          ),
        ],
      ),
    );
  }
}
