import 'package:flutter/material.dart';
import 'package:edify_app/constants/colors.dart';
import 'package:edify_app/models/chat_message.dart';
import 'package:edify_app/models/user_model.dart';

class MessageOptionsDialog extends StatelessWidget {
  final ChatMessage message;
  final User? currentUser;
  final bool isCurrentUserAdmin;
  final Function(String) onReply;
  final Function(String) onReact;
  final Function() onShare;
  final Function() onCopy;
  final Function() onDelete;
  final Function() onPin;
  final Function() onForward;

  const MessageOptionsDialog({
    super.key,
    required this.message,
    required this.currentUser,
    required this.isCurrentUserAdmin,
    required this.onReply,
    required this.onReact,
    required this.onShare,
    required this.onCopy,
    required this.onDelete,
    required this.onPin,
    required this.onForward,
  });

  @override
  Widget build(BuildContext context) {
    final isOwnMessage = currentUser?.id == message.userId;
    final canDelete = isOwnMessage || isCurrentUserAdmin;
    final canPin = isCurrentUserAdmin && !message.isPinned;

    return Container(
      constraints: BoxConstraints(maxWidth: 252, maxHeight: 700),
      height: 600,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          // Header with message preview
          if (!message.isDeleted)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryGreyLight,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.message_outlined,
                    size: 16,
                    color: AppColors.primaryBlackLight,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getMessagePreview(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.primaryProgressBlack,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

          // Options List
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Reply
                _buildOptionItem(
                  icon: Icons.reply_outlined,
                  title: 'Reply',
                  textColor: AppColors.primaryBlack,
                  iconColor: AppColors.primaryBlack,
                  onTap: () {
                    Navigator.pop(context);
                    onReply('reply');
                  },
                ),
                //copy
                if (message.hasMessage && message.message != null)
                  _buildOptionItem(
                    icon: Icons.content_copy_outlined,
                    title: 'Copy',
                    textColor: AppColors.primaryBlack,
                    iconColor: AppColors.primaryBlack,
                    onTap: () {
                      Navigator.pop(context);
                      onCopy();
                    },
                  ),

                if (message.hasMessage && message.message != null)
                  _buildOptionItem(
                    icon: Icons.content_copy_outlined,
                    title: 'Reply privately',
                    textColor: AppColors.primaryBlack,
                    iconColor: AppColors.primaryBlack,
                    onTap: () {
                      Navigator.pop(context);
                      onCopy();
                    },
                  ),

                // Forward
                _buildOptionItem(
                  icon: Icons.forward_outlined,
                  title: 'Forward',
                  textColor: AppColors.primaryBlack,
                  iconColor: AppColors.primaryBlack,
                  onTap: () {
                    Navigator.pop(context);
                    onForward();
                  },
                ),

                // Forward
                _buildOptionItem(
                  icon: Icons.star,
                  title: 'Star',
                  textColor: AppColors.primaryBlack,
                  iconColor: AppColors.primaryBlack,
                  onTap: () {
                    Navigator.pop(context);
                    onForward();
                  },
                ),

                // Pin (Admin only)
                if (canPin)
                  _buildOptionItem(
                    icon: Icons.push_pin_outlined,
                    title: 'Pin Message',
                    textColor: AppColors.primaryBlack,
                    iconColor: AppColors.primaryBlack,
                    onTap: () {
                      Navigator.pop(context);
                      onPin();
                    },
                  ),

                // Delete (Own message or admin)
                if (canDelete && !message.isDeleted)
                  _buildOptionItem(
                    icon: Icons.delete_outline,
                    title: 'Delete',
                    textColor: AppColors.primaryOrange,
                    iconColor: AppColors.primaryOrange,
                    onTap: () {
                      Navigator.pop(context);
                      onDelete();
                    },
                  ),

                // Share
                _buildOptionItem(
                  icon: Icons.share_outlined,
                  title: 'Share',
                  textColor: AppColors.primaryBlack,
                  iconColor: AppColors.primaryBlack,
                  onTap: () {
                    Navigator.pop(context);
                    onShare();
                  },
                ),

                // React with emoji
                _buildOptionItem(
                  icon: Icons.emoji_emotions_outlined,
                  title: 'React',
                  textColor: AppColors.primaryBlack,
                  iconColor: AppColors.primaryBlack,
                  onTap: () {
                    Navigator.pop(context);
                    onReact('react');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              Icon(icon, size: 20, color: iconColor ?? AppColors.primaryOrange),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: textColor ?? AppColors.primaryBlack,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getMessagePreview() {
    if (message.isDeleted) {
      return 'This message was deleted';
    }
    if (message.hasFile) {
      return 'File: ${message.fileName ?? 'Unknown file'}';
    }
    if (message.hasCall) {
      return 'Voice call';
    }
    return message.message ?? 'Message';
  }
}
