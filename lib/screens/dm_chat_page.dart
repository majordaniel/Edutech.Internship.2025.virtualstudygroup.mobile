import 'package:edify_app/widgets/appbar.dart';
import 'package:edify_app/screens/profile_page_person.dart';
import 'package:flutter/material.dart';
import 'package:edify_app/widgets/texts.dart';
import 'package:edify_app/constants/colors.dart';

class DmChatPage extends StatelessWidget {
  const DmChatPage({super.key});

  void _showCustomDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: 229,
            padding: EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.all(
                        Radius.circular(2),
                      ),
                    ),
                  ),
                  onPressed: () {},
                  child: Row(
                    children: [
                      Icon(
                        Icons.attach_file_outlined,
                        size: 20,
                        color: AppColors.primaryBlack,
                      ),
                      SizedBox(width: 10),
                      CustomTexts(
                        title: 'Attach file',
                        textColor: AppColors.primaryBlack,
                        textSize: 14,
                        textWeight: FontWeight.w500,
                        textAlignment: AlignmentGeometry.centerLeft,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 23),
                TextButton(
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.all(
                        Radius.circular(2),
                      ),
                    ),
                  ),
                  onPressed: () {},
                  child: Row(
                    children: [
                      Icon(
                        Icons.photo_album_outlined,
                        size: 20,
                        color: AppColors.primaryBlack,
                      ),
                      SizedBox(width: 10),
                      CustomTexts(
                        title: 'choose photo or video',
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryWhiteIcon,
      appBar: AppBar(actions: [Icon(null)], title: CustomAppbar()),
      body: Column(
        children: [
          // Header Section
          Container(
            padding: EdgeInsets.only(left: 15, top: 16, right: 17, bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.primaryWhiteNormal,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(backgroundImage: AssetImage('assets/adeola.png')),
                SizedBox(width: 12),
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.all(
                          Radius.circular(2),
                        ),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfilePagePerson(),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTexts(
                          title: 'Adeola Manni',
                          textColor: AppColors.primaryBlack,
                          textSize: 14,
                          textWeight: FontWeight.w600,
                          textAlignment: AlignmentGeometry.centerLeft,
                        ),
                        CustomTexts(
                          title: 'online',
                          textColor: AppColors.primaryBlack,
                          textSize: 10,
                          textWeight: FontWeight.w400,
                          textAlignment: AlignmentGeometry.centerLeft,
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.group_outlined,
                        size: 24,
                        color: AppColors.primaryOrange,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.call_outlined,
                        size: 24,
                        color: AppColors.primaryOrange,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.video_camera_back_outlined,
                        size: 24,
                        color: AppColors.primaryOrange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Messages Section
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  SizedBox(height: 37),
                  _buildMessageBubble(
                    isMe: false,
                    message:
                        'As a student, I want to search for and join an existing study group so I can collaborate with peers in my class and program.',
                    avatar: 'assets/freeavatar.png',
                  ),
                  SizedBox(height: 60),
                  _buildMessageBubble(
                    isMe: true,
                    message:
                        'Add a new member to the group. So you should say HI',
                  ),
                  SizedBox(height: 60),
                  _buildMessageBubble(
                    isMe: false,
                    message:
                        'As a student, I want to search for and join an existing study group so I can collaborate with peers in my class and program.',
                    avatar: 'assets/freeavatar.png',
                  ),
                  SizedBox(height: 60),
                  _buildMessageBubble(
                    isMe: true,
                    message:
                        'Add a new member to the group. So you should say HI',
                  ),
                  SizedBox(height: 60),
                  _buildMessageBubble(
                    isMe: false,
                    message:
                        'As a student, I want to search for and join an existing study group so I can collaborate with peers in my class and program.',
                    avatar: 'assets/freeavatar.png',
                  ),
                  SizedBox(height: 32),
                  CustomTexts(
                    title: 'Only admins can send messages',
                    // ignore: deprecated_member_use
                    textColor: AppColors.primaryBlack.withOpacity(0.6),
                    textSize: 10,
                    textWeight: FontWeight.w400,
                    textAlignment: AlignmentGeometry.center,
                  ),
                ],
              ),
            ),
          ),
          // Container(_buildDialogContent()),
          // Input Section
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              children: [
                // Attachment button
                IconButton(
                  onPressed: () {
                    _showCustomDialog(context);
                  },
                  icon: Icon(
                    Icons.add_outlined,
                    color: AppColors.primaryOrange,
                    size: 24,
                  ),
                ),

                // Text field
                Expanded(
                  child: Container(
                    constraints: BoxConstraints(maxHeight: 100),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      maxLines: null,
                    ),
                  ),
                ),

                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.mic_outlined,
                    color: AppColors.primaryOrange,
                    size: 24,
                  ),
                ),

                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.photo_camera_outlined,
                    color: AppColors.primaryOrange,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble({
    required bool isMe,
    required String message,
    String? avatar,
  }) {
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isMe && avatar != null)
          CircleAvatar(radius: 15, backgroundImage: AssetImage(avatar)),
        if (!isMe) SizedBox(width: 8),

        Flexible(
          child: Container(
            padding: EdgeInsets.all(12),
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
            child: CustomTexts(
              title: message,
              textColor: AppColors.primaryBlack,
              textSize: 12,
              textWeight: FontWeight.w400,
              textAlignment: AlignmentGeometry.centerLeft,
            ),
          ),
        ),

        if (isMe) SizedBox(width: 8),
      ],
    );
  }
}
