import 'package:edify_app/widgets/appbar.dart';
import 'package:edify_app/widgets/icon_button.dart';
import 'package:edify_app/widgets/notification_icon.dart';
import 'package:edify_app/widgets/user_avatar.dart';
import 'package:flutter/material.dart';
import 'package:edify_app/widgets/texts.dart';
import 'package:edify_app/constants/colors.dart';
import 'package:edify_app/models/user_model.dart';
import 'package:provider/provider.dart';
import 'package:edify_app/providers/user_provider.dart';

class ProfilePagePerson extends StatelessWidget {
  final User member;

  const ProfilePagePerson({super.key, required this.member});

  void _showCustomDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: 361,
            height: 185,
            padding: EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomTexts(
                      title: 'Edit Contact',
                      textColor: AppColors.primaryBlack,
                      textSize: 16,
                      textWeight: FontWeight.w500,
                      textAlignment: AlignmentGeometry.centerLeft,
                    ),
                    Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryOrange,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.delete_outline,
                          color: AppColors.primaryWhiteIcon,
                          size: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                CircleAvatar(
                  radius: 50,
                  backgroundImage: member.avatarUrl.isNotEmpty
                      ? NetworkImage(member.avatarUrl)
                      : AssetImage('assets/adeola.png') as ImageProvider,
                ),
                CustomTexts(
                  title: 'First name',
                  textColor: AppColors.primaryBlack,
                  textSize: 12,
                  textWeight: FontWeight.w400,
                  textAlignment: AlignmentGeometry.centerLeft,
                ),
                TextField(
                  cursorColor: AppColors.primaryOrange,
                  decoration: InputDecoration(
                    focusColor: AppColors.primaryOrange,
                    hintText: member.firstName.isNotEmpty
                        ? member.firstName
                        : 'first name',
                    hintStyle: TextStyle(color: AppColors.primaryBlack),
                  ),
                ),
                SizedBox(height: 18),
                CustomTexts(
                  title: 'Last name',
                  textColor: AppColors.primaryBlack,
                  textSize: 12,
                  textWeight: FontWeight.w400,
                  textAlignment: AlignmentGeometry.centerLeft,
                ),
                TextField(
                  cursorColor: AppColors.primaryOrange,
                  decoration: InputDecoration(
                    focusColor: AppColors.primaryOrange,
                    hintText: member.lastName.isNotEmpty
                        ? member.lastName
                        : 'Last name',
                    hintStyle: TextStyle(color: AppColors.primaryBlack),
                  ),
                ),
                SizedBox(height: 18),
                CustomTexts(
                  title: 'Email',
                  textColor: AppColors.primaryBlack,
                  textSize: 12,
                  textWeight: FontWeight.w400,
                  textAlignment: AlignmentGeometry.centerLeft,
                ),
                TextField(
                  cursorColor: AppColors.primaryOrange,
                  decoration: InputDecoration(
                    focusColor: AppColors.primaryOrange,
                    hintText: member.email.isNotEmpty ? member.email : 'email',
                    hintStyle: TextStyle(color: AppColors.primaryBlack),
                  ),
                ),
                SizedBox(height: 18),
                Row(
                  children: [
                    Container(
                      width: 160,
                      padding: EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryOrange,
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      child: TextButton(
                        onPressed: () {},
                        child: CustomTexts(
                          title: 'Save',
                          textColor: AppColors.primaryWhiteIcon,
                          textSize: 12,
                          textWeight: FontWeight.w500,
                          textAlignment: AlignmentGeometry.center,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      width: 160,
                      padding: EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        border: Border.all(color: AppColors.primaryOrange),
                      ),
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: CustomTexts(
                          title: 'Cancel',
                          textColor: AppColors.primaryOrange,
                          textSize: 12,
                          textWeight: FontWeight.w500,
                          textAlignment: AlignmentGeometry.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          side: BorderSide(color: AppColors.primaryOrange),
          borderRadius: BorderRadius.circular(6),
        ),
        padding: EdgeInsets.fromLTRB(14, 5, 14, 7),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.primaryOrange,
        elevation: 0,
      ),
      onPressed: onPressed,
      child: Column(
        children: [
          Icon(icon, color: AppColors.primaryOrange, size: 20),
          SizedBox(height: 6),
          CustomTexts(
            title: label,
            textColor: AppColors.primaryBlack,
            textSize: 6,
            textWeight: FontWeight.w500,
            textAlignment: Alignment.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    String? count,
    required VoidCallback onPressed,
  }) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: AppColors.primaryAppbarBlack),
              SizedBox(width: 7),
              CustomTexts(
                title: label,
                textColor: AppColors.primaryBlack,
                textSize: 12,
                textWeight: FontWeight.w500,
                textAlignment: Alignment.centerLeft,
              ),
            ],
          ),
          if (count != null)
            Row(
              children: [
                CustomTexts(
                  title: count,
                  textColor: AppColors.primaryBlack,
                  textSize: 12,
                  textWeight: FontWeight.w500,
                  textAlignment: Alignment.centerLeft,
                ),
                SizedBox(width: 7),
                Icon(
                  Icons.keyboard_arrow_right_outlined,
                  size: 8.19,
                  color: AppColors.primaryAppbarBlack,
                ),
              ],
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<UserProvider>().user;
    final isCurrentUser = currentUser?.id == member.id;

    return Scaffold(
      backgroundColor: AppColors.primaryWhiteIcon,
      appBar: AppBar(
        backgroundColor: AppColors.primaryWhiteIcon,
        elevation: 0,
        title: const CustomAppbar(),
        actions: [
          NotificationIcon(),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 0,
                ),
                child: Consumer<UserProvider>(
                  builder: (context, userProvider, child) {
                    return SimpleUserAvatar(
                      imageUrl: userProvider.user?.avatarUrl,
                      userName: userProvider.user?.fullName,
                      size: 40,
                      // onLogout: () => LogoutHandler.logout(context),
                    );
                  },
                ),
              ),
              CustomIconButton(),
              SizedBox(width: 17.81),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: member.avatarUrl.isNotEmpty
                    ? NetworkImage(member.avatarUrl)
                    : AssetImage('assets/adeola.png') as ImageProvider,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomTexts(
                    title: member.fullName,
                    textColor: AppColors.primaryBlack,
                    textSize: 14,
                    textWeight: FontWeight.w600,
                    textAlignment: AlignmentGeometry.center,
                  ),
                  // Only show edit button if it's the current user's profile
                  if (isCurrentUser)
                    IconButton(
                      onPressed: () {
                        _showCustomDialog(context);
                      },
                      icon: Icon(Icons.edit_outlined, size: 14.83),
                    ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.mail_outline_outlined, size: 14),
                  CustomTexts(
                    title: member.email.isNotEmpty
                        ? member.email
                        : 'No email available',
                    textColor: AppColors.primaryBlack,
                    textSize: 14,
                    textWeight: FontWeight.w500,
                    textAlignment: AlignmentGeometry.center,
                  ),
                ],
              ),

              SizedBox(height: 26),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildActionButton(
                    icon: Icons.phone_outlined,
                    label: 'Audio',
                    onPressed: () {
                      // Handle audio call to this member
                      _startAudioCallToMember(context);
                    },
                  ),
                  _buildActionButton(
                    icon: Icons.mic_off_outlined,
                    label: 'Mute',
                    onPressed: () {
                      // Handle mute
                      _toggleMuteForMember();
                    },
                  ),
                  _buildActionButton(
                    icon: Icons.videocam_outlined,
                    label: 'Video',
                    onPressed: () {
                      // Handle video call to this member
                      _startVideoCallToMember(context);
                    },
                  ),
                  _buildActionButton(
                    icon: Icons.search_outlined,
                    label: 'Search',
                    onPressed: () {
                      // Handle search in chat with this member
                      _searchChatWithMember();
                    },
                  ),
                ],
              ),
              SizedBox(height: 26),
              // TextButton(
              //   onPressed: () {
              //     // Navigate to chat with this member
              //     _startChatWithMember(context);
              //   },
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //     children: [
              //       CustomTexts(
              //         title: 'Send a quick message',
              //         textColor: AppColors.primaryOrange,
              //         textSize: 14,
              //         textWeight: FontWeight.w500,
              //         textAlignment: AlignmentGeometry.centerLeft,
              //       ),
              //       Icon(
              //         Icons.send_outlined,
              //         size: 14,
              //         color: AppColors.primaryBlack,
              //       ),
              //     ],
              //   ),
              // ),
              // SizedBox(height: 26),
              Container(
                padding: EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(Icons.circle_notifications_outlined, size: 14),
                    SizedBox(width: 7),
                    CustomTexts(
                      title: 'Last seen recently',
                      textColor: AppColors.primaryBlack,
                      textSize: 14,
                      textWeight: FontWeight.w500,
                      textAlignment: AlignmentGeometry.centerLeft,
                    ),
                  ],
                ),
              ),
              // SizedBox(height: 19),
              // _buildMenuItem(
              //   icon: Icons.videocam_outlined,
              //   label: 'Media',
              //   count: '5',
              //   onPressed: () {
              //     // Navigate to media shared with this member
              //   },
              // ),
              // SizedBox(height: 19),
              // _buildMenuItem(
              //   icon: Icons.file_copy_outlined,
              //   label: 'Files',
              //   count: '5',
              //   onPressed: () {
              //     // Navigate to files shared with this member
              //   },
              // ),
              // SizedBox(height: 19),
              // _buildMenuItem(
              //   icon: Icons.link_outlined,
              //   label: 'Links',
              //   count: '5',
              //   onPressed: () {
              //     // Navigate to links shared with this member
              //   },
              // ),
              // SizedBox(height: 19),
              // _buildMenuItem(
              //   icon: Icons.mobile_screen_share_outlined,
              //   label: 'Screen sharing',
              //   count: '',
              //   onPressed: () {
              //     // Handle screen sharing with this member
              //   },
              // ),
              // SizedBox(height: 19),
              // _buildMenuItem(
              //   icon: Icons.settings_outlined,
              //   label: 'Permission',
              //   count: '',
              //   onPressed: () {
              //     // Handle permissions for this member
              //   },
              // ),
              // SizedBox(height: 19),
              // _buildMenuItem(
              //   icon: Icons.notifications_off_outlined,
              //   label: 'Mute',
              //   count: '',
              //   onPressed: () {
              //     // Handle muting this member
              //   },
              // ),
            ],
          ),
        ),
      ),
    );
  }

  void _startAudioCallToMember(BuildContext context) {
    print('🎧 Starting audio call to: ${member.fullName}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Starting audio call to ${member.fullName}'),
        backgroundColor: AppColors.primaryOrange,
      ),
    );
  }

  void _startVideoCallToMember(BuildContext context) {
    print('🎥 Starting video call to: ${member.fullName}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Starting video call to ${member.fullName}'),
        backgroundColor: AppColors.primaryOrange,
      ),
    );
  }

  // void _startChatWithMember(BuildContext context) {
  //   print('💬 Starting chat with: ${member.fullName}');
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text('Opening chat with ${member.fullName}'),
  //       backgroundColor: AppColors.primaryOrange,
  //     ),
  //   );
  //   // Here you would navigate to the chat screen with this member
  // }

  void _toggleMuteForMember() {
    print('🔇 Toggling mute for: ${member.fullName}');
  }

  void _searchChatWithMember() {
    print('🔍 Searching chat with: ${member.fullName}');
  }
}
