import 'dart:io';

import 'package:edify_app/providers/user_provider.dart';
import 'package:edify_app/screens/group_files_screen.dart';
import 'package:edify_app/screens/group_media_screen.dart';
import 'package:edify_app/screens/see_group_members_member.dart';
import 'package:edify_app/services/call_service.dart';
import 'package:edify_app/services/file_manager_service.dart';
import 'package:edify_app/widgets/appbar.dart';
import 'package:edify_app/screens/see_group_members_admin.dart';
import 'package:edify_app/widgets/icon_button.dart';
import 'package:edify_app/widgets/notification_icon.dart';
import 'package:edify_app/widgets/user_avatar.dart';
import 'package:flutter/material.dart';
import 'package:edify_app/widgets/texts.dart';
import 'package:edify_app/constants/colors.dart';
import 'package:edify_app/screens/edit_group.dart';
import 'package:provider/provider.dart';
import 'package:edify_app/services/group_management_service.dart';
import 'package:edify_app/models/user_model.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfilePageGroup extends StatefulWidget {
  final dynamic group;

  const ProfilePageGroup({super.key, required this.group});

  @override
  State<ProfilePageGroup> createState() => _ProfilePageGroupState();
}

class _ProfilePageGroupState extends State<ProfilePageGroup> {
  List<User> _groupMembers = [];
  bool _isLoadingMembers = false;
  String? _membersError;
  List<File> _mediaFiles = [];
  List<File> _documentFiles = [];

  get currentUserId => null;

  @override
  void initState() {
    super.initState();
    _loadGroupMembers();
  }

  Future<void> _loadFileCounts() async {
    try {
      final mediaFiles = await FileManagerService().getGroupMedia(
        widget.group.id,
      );
      final documentFiles = await FileManagerService().getGroupDocuments(
        widget.group.id,
      );

      setState(() {
        _mediaFiles = mediaFiles;
        _documentFiles = documentFiles;
      });
    } catch (e) {
      print('❌ Error loading file counts: $e');
    }
  }

  Future<void> _loadGroupMembers() async {
    setState(() {
      _isLoadingMembers = true;
      _membersError = null;
      _loadFileCounts();
    });

    try {
      print('🔄 Loading ALL group members for group ${widget.group.id}');

      final membersResponse = await GroupManagementService.getGroupMembers(
        widget.group.id,
      );

      if (membersResponse.isSuccess) {
        print('✅ Loaded ${membersResponse.data?.length ?? 0} group members');
        setState(() {
          _groupMembers = membersResponse.data ?? [];
        });
      } else {
        setState(() {
          _membersError = membersResponse.message;
        });
        print('❌ Failed to load members: ${membersResponse.message}');
      }
    } catch (e) {
      setState(() {
        _membersError = 'Failed to load members: $e';
      });
      print('💥 Error loading group members: $e');
    } finally {
      setState(() {
        _isLoadingMembers = false;
      });
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryWhiteIcon,
      appBar: AppBar(
        backgroundColor: AppColors.primaryWhiteIcon,
        actions: [
          NotificationIcon(),
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
                      // onLogout: () => LogoutHandler.logout(context),
                    );
                  },
                ),
              ),
              CustomIconButton(),
              SizedBox(width: 17.81),
            ],
          ),

          SizedBox(width: 17.81),
        ],
        title: CustomAppbar(),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primaryBlack),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Group Icon
              Icon(
                Icons.groups_outlined,
                size: 67.23,
                color: AppColors.primaryBlack,
              ),

              // Group Name with Edit Button
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomTexts(
                    title: widget.group.groupName ?? 'Group Name',
                    textColor: AppColors.primaryBlack,
                    textSize: 18,
                    textWeight: FontWeight.w600,
                    textAlignment: Alignment.center,
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditGroup(group: widget.group),
                        ),
                      );
                    },
                    icon: Icon(Icons.edit_outlined, size: 14.83),
                  ),
                ],
              ),

              // Group Description (if available)
              if (widget.group.description != null &&
                  widget.group.description.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: CustomTexts(
                    title: widget.group.description,
                    textColor: AppColors.primaryBlackLight,
                    textSize: 12,
                    textWeight: FontWeight.w400,
                    textAlignment: Alignment.center,
                  ),
                ),

              SizedBox(height: 46),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildActionButton(
                    icon: Icons.phone_outlined,
                    label: 'Audio',
                    onPressed: () {
                      // Handle audio call from profile
                      _startAudioCall();
                    },
                  ),

                  _buildActionButton(
                    icon: Icons.mic_off_outlined,
                    label: 'Mute',
                    onPressed: () {
                      // Handle mute
                      _toggleMute();
                    },
                  ),

                  _buildActionButton(
                    icon: Icons.videocam_outlined,
                    label: 'Video',
                    onPressed: () {
                      // Handle video call from profile
                      _startVideoCall();
                    },
                  ),

                  _buildActionButton(
                    icon: Icons.search_outlined,
                    label: 'Search',
                    onPressed: () {
                      // Handle search
                      _searchGroupContent();
                    },
                  ),
                ],
              ),

              // Continue with the rest of your existing ProfilePageGroup layout...
              SizedBox(height: 26),
              _buildMenuItem(
                icon: Icons.videocam_outlined,
                label: 'Media',
                count: _mediaFiles.length.toString(),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GroupMediaScreen(
                        groupId: widget.group.id,
                        groupName: widget.group.groupName ?? 'Group',
                      ),
                    ),
                  );
                },
              ),

              _buildMenuItem(
                icon: Icons.file_copy_outlined,
                label: 'Files',
                count: _documentFiles.length.toString(),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GroupFilesScreen(
                        groupId: widget.group.id,
                        groupName: widget.group.groupName ?? 'Group',
                      ),
                    ),
                  );
                },
              ),
              _buildMenuItem(
                icon: Icons.attachment_outlined,
                label: 'Links',
                count: '5',
                onPressed: () {
                  // Navigate to files page
                },
              ),
              _buildMenuItem(
                icon: Icons.mobile_screen_share_outlined,
                label: 'Screen sharing',
                count: '',
                onPressed: () {
                  // Navigate to files page
                },
              ),
              _buildMenuItem(
                icon: Icons.settings_outlined,
                label: 'Permission',
                count: '',
                onPressed: () {
                  // Navigate to files page
                },
              ),
              _buildMenuItem(
                icon: Icons.notifications_off_outlined,
                label: 'Mute',
                count: '',
                onPressed: () {
                  // Navigate to files page
                },
              ),
              SizedBox(height: 28),
              CustomTexts(
                title: 'Course mates(${_groupMembers.length})',
                textColor: AppColors.primaryBlack,
                textSize: 16,
                textWeight: FontWeight.w500,
                textAlignment: AlignmentGeometry.centerLeft,
              ),
              SizedBox(height: 25),

              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    flex: 3,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: _buildMembersAvatars(),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.all(
                            Radius.circular(2),
                          ),
                        ),
                      ),
                      onPressed: () {
                        final userProvider = context.read<UserProvider>();
                        final currentUser = userProvider.user;

                        // Determine if current user is admin in this group
                        bool isAdmin = false;

                        if (currentUser != null && _groupMembers.isNotEmpty) {
                          // Check if current user is in the members list and has admin role
                          final currentUserMember = _groupMembers.firstWhere(
                            (member) => member.id == currentUser.id,
                            orElse: () => User(
                              id: 0,
                              firstName: '',
                              lastName: '',
                              email: '',
                              avatarUrl: '',
                              createdAt: '',
                              updatedAt: '',
                              isAdmin: false,
                            ),
                          );

                          isAdmin = currentUserMember.isAdmin;

                          print('👤 Current user: ${currentUser.fullName}');
                          print('👑 Is admin in this group: $isAdmin');
                        }

                        if (isAdmin) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SeeGroupMembersAdmin(
                                groupId: widget.group.id,
                                isCurrentUserAdmin: true,
                              ),
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SeeGroupMembersMember(
                                groupId: widget.group.id,
                                groupName: widget.group.groupName ?? 'Group',
                              ),
                            ),
                          );
                        }
                      },
                      child: CustomTexts(
                        title: 'See more...',
                        textColor: AppColors.primaryOrange,
                        textSize: 12,
                        textWeight: FontWeight.w400,
                        textAlignment: Alignment.centerLeft,
                      ),
                    ),
                  ),
                ],
              ),

              // Horizontal members avatars
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMembersAvatars() {
    if (_isLoadingMembers) {
      return _buildLoadingAvatars();
    }

    if (_membersError != null) {
      return _buildErrorAvatars();
    }

    if (_groupMembers.isEmpty) {
      return _buildEmptyAvatars();
    }

    // Show first 8 members and "+X more" if there are more
    final membersToShow = _groupMembers.take(8).toList();
    final remainingCount = _groupMembers.length - membersToShow.length;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...membersToShow.map((member) => _buildMemberAvatar(member)),
          if (remainingCount > 0) _buildRemainingCount(remainingCount),
        ],
      ),
    );
  }

  Widget _buildMemberAvatar(User member) {
    return Container(
      margin: EdgeInsets.only(right: 12),
      child: Column(
        children: [
          CircleAvatar(
            radius: 15,
            backgroundImage: member.avatarUrl.isNotEmpty
                ? NetworkImage(member.avatarUrl)
                : _getDefaultAvatar(member),
            child: member.avatarUrl.isEmpty
                ? Text(
                    _getInitials(member.fullName),
                    style: TextStyle(
                      color: AppColors.primaryOrange,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  )
                : null,
          ),
          SizedBox(height: 4),
          Container(
            width: 40,
            child: Text(
              _getShortName(member.fullName),
              style: TextStyle(
                color: AppColors.primaryBlack,
                fontSize: 8,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemainingCount(int count) {
    return Container(
      margin: EdgeInsets.only(right: 12),
      child: Column(
        children: [
          CircleAvatar(
            radius: 15,
            backgroundColor: AppColors.primaryOrange.withOpacity(0.1),
            child: Text(
              '+$count',
              style: TextStyle(
                color: AppColors.primaryOrange,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ),
          SizedBox(height: 4),
          Text(
            'More',
            style: TextStyle(
              color: AppColors.primaryBlack,
              fontSize: 8,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingAvatars() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: List.generate(3, (index) => _buildShimmerAvatar())),
    );
  }

  Widget _buildShimmerAvatar() {
    return Container(
      margin: EdgeInsets.only(right: 12),
      child: Column(
        children: [
          CircleAvatar(radius: 15, backgroundColor: Colors.grey.shade300),
          SizedBox(height: 4),
          Container(width: 30, height: 8, color: Colors.grey.shade300),
        ],
      ),
    );
  }

  Widget _buildErrorAvatars() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Text(
        'Failed to load members',
        style: TextStyle(color: Colors.red, fontSize: 12),
      ),
    );
  }

  Widget _buildEmptyAvatars() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Text(
        'No members yet',
        style: TextStyle(color: AppColors.primaryBlackLight, fontSize: 12),
      ),
    );
  }

  // Helper methods
  ImageProvider _getDefaultAvatar(User member) {
    return AssetImage('asset/duke.png');
  }

  String _getInitials(String fullName) {
    final parts = fullName.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty) {
      return parts[0].length >= 2
          ? parts[0].substring(0, 2).toUpperCase()
          : parts[0].toUpperCase();
    }
    return '?';
  }

  String _getShortName(String fullName) {
    final parts = fullName.split(' ');
    if (parts.length >= 2) {
      return '${parts[0]} ${parts[1][0]}.';
    }
    return fullName.length > 8 ? '${fullName.substring(0, 8)}..' : fullName;
  }

  // Helper method for action buttons
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

  // Helper method for menu items
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

  void _startAudioCallFromProfile() {
    print('🎧 Starting audio call from profile for: ${widget.group.groupName}');
    // You can reuse your existing audio call logic
    Navigator.pop(context); // Go back to chat
    // _startAudioCall(); // Call your existing method
  }

  void _startVideoCallFromProfile() {
    print('🎥 Starting video call from profile for: ${widget.group.groupName}');
    // You can reuse your existing video call logic
    Navigator.pop(context); // Go back to chat
    // _startVideoCall(); // Call your existing method
  }

  void _toggleMute() {
    print('🔇 Toggling mute for: ${widget.group.groupName}');
    // Implement mute functionality
  }

  void _searchGroupContent() {
    print('🔍 Searching content in: ${widget.group.groupName}');
    // Implement search functionality
  }
}
