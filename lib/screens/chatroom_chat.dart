import 'package:edify_app/widgets/icon_button.dart';
import 'package:edify_app/widgets/notification_icon.dart';
import 'package:edify_app/widgets/user_avatar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edify_app/widgets/appbar.dart';
import 'package:edify_app/screens/chatroom_unread.dart';
import 'package:edify_app/screens/group_chat_page.dart';
import 'package:edify_app/widgets/texts.dart';
import 'package:edify_app/constants/colors.dart';
import 'package:edify_app/widgets/chat_widget.dart';
import 'package:edify_app/providers/group_provider.dart';
import 'package:edify_app/providers/user_provider.dart';

class Chatroom extends StatefulWidget {
  const Chatroom({super.key});

  @override
  State<Chatroom> createState() => _ChatroomState();
}

class _ChatroomState extends State<Chatroom> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _filteredGroups = [];
  bool _isLoading = true;
  bool _showChats = true; // true for chats, false for unread

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);

    // Replace your current _loadJoinedGroups() call with:
    Future.delayed(Duration.zero, () {
      _loadJoinedGroups();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadJoinedGroups() async {
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    await groupProvider.loadJoinedGroups();

    setState(() {
      _filteredGroups = groupProvider.joinedGroups;
      _isLoading = false;
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);

    if (query.isEmpty) {
      setState(() {
        _filteredGroups = groupProvider.joinedGroups;
      });
    } else {
      setState(() {
        _filteredGroups = groupProvider.joinedGroups.where((group) {
          return group.groupName.toLowerCase().contains(query) ||
              group.description.toLowerCase().contains(query);
        }).toList();
      });
    }
  }

  void _navigateToGroupChat(dynamic group) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GroupChatPage(group: group)),
    );
  }

  Widget _buildGroupChatItem(dynamic group) {
    return TextButton(
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.all(Radius.circular(2)),
        ),
        padding: EdgeInsets.zero,
      ),
      onPressed: () {
        _navigateToGroupChat(group);
      },
      child: ChatWidget(
        chatName: CustomTexts(
          title: group.groupName,
          textColor: AppColors.primaryBlack,
          textSize: 16,
          textWeight: FontWeight.w500,
          textAlignment: Alignment.centerLeft,
        ),
        lastChat: CustomTexts(
          title: group.description.isNotEmpty
              ? (group.description.length > 30
                    ? '${group.description.substring(0, 30)}...'
                    : group.description)
              : 'No messages yet',
          textColor: AppColors.primaryBlack,
          textSize: 12,
          textWeight: FontWeight.w500,
          textAlignment: Alignment.centerLeft,
        ),
        leadIcon: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primaryOrange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.groups_outlined,
            color: AppColors.primaryOrange,
            size: 24,
          ),
        ),
        pinChat: group.isRestricted
            ? Icon(Icons.lock_outline, color: AppColors.primaryOrange, size: 16)
            : Icon(
                Icons.group_outlined,
                color: AppColors.primaryBlack,
                size: 16,
              ),
        timeStamp: CustomTexts(
          title: _formatTimeStamp(group.createdAt),
          textColor: AppColors.primaryOrange,
          textSize: 9,
          textWeight: FontWeight.w500,
          textAlignment: Alignment.centerLeft,
        ),
      ),
    );
  }

  String _formatTimeStamp(String createdAt) {
    try {
      final dateTime = DateTime.parse(createdAt);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 365) {
        return '${difference.inDays ~/ 365}y';
      } else if (difference.inDays > 30) {
        return '${difference.inDays ~/ 30}mo';
      } else if (difference.inDays > 0) {
        return '${difference.inDays}d';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m';
      } else {
        return 'now';
      }
    } catch (e) {
      return 'new';
    }
  }

  Widget _buildLoadingState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 50),
        child: Column(
          children: [
            CircularProgressIndicator(color: AppColors.primaryOrange),
            SizedBox(height: 16),
            CustomTexts(
              title: 'Loading your chats...',
              textColor: AppColors.primaryBlack,
              textSize: 14,
              textWeight: FontWeight.w500,
              textAlignment: Alignment.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 50),
        child: Column(
          children: [
            Icon(
              Icons.chat_outlined,
              size: 64,
              color: AppColors.primaryBlackLight,
            ),
            SizedBox(height: 16),
            CustomTexts(
              title: 'No Chats Yet',
              textColor: AppColors.primaryBlack,
              textSize: 16,
              textWeight: FontWeight.w500,
              textAlignment: Alignment.center,
            ),
            SizedBox(height: 8),
            CustomTexts(
              title: 'Join study groups to start chatting',
              textColor: AppColors.primaryBlackLight,
              textSize: 14,
              textWeight: FontWeight.w400,
              textAlignment: Alignment.center,
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              decoration: BoxDecoration(
                color: AppColors.primaryOrange,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextButton(
                onPressed: () {
                  // Navigate to join groups page
                  Navigator.pushNamed(context, '/join-group');
                },
                child: CustomTexts(
                  title: 'Join Groups',
                  textColor: AppColors.primaryWhiteIcon,
                  textSize: 14,
                  textWeight: FontWeight.w500,
                  textAlignment: Alignment.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoSearchResults() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 50),
        child: Column(
          children: [
            Icon(
              Icons.search_off_outlined,
              size: 64,
              color: AppColors.primaryBlackLight,
            ),
            SizedBox(height: 16),
            CustomTexts(
              title: 'No Chats Found',
              textColor: AppColors.primaryBlack,
              textSize: 16,
              textWeight: FontWeight.w500,
              textAlignment: Alignment.center,
            ),
            SizedBox(height: 8),
            CustomTexts(
              title: 'Try different search terms',
              textColor: AppColors.primaryBlackLight,
              textSize: 14,
              textWeight: FontWeight.w400,
              textAlignment: Alignment.center,
            ),
          ],
        ),
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
            ],
          ),
          SizedBox(width: 17.81),
        ],
        title: CustomAppbar(),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(17),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              SizedBox(height: 20),
              TextField(
                cursorColor: AppColors.primaryOrange,
                controller: _searchController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  hintText: 'search or start a new chat',
                  hintStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: Icon(Icons.search_outlined),
                ),
              ),
              SizedBox(height: 28),

              // Chat/Unread Toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: _showChats
                            ? AppColors.primaryOrange
                            : AppColors.primaryWhiteNormal,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.only(
                            topLeft: Radius.circular(8),
                            bottomLeft: Radius.circular(8),
                          ),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _showChats = true;
                        });
                      },
                      child: CustomTexts(
                        title: 'Chat',
                        textColor: _showChats
                            ? AppColors.primaryWhiteIcon
                            : AppColors.primaryUnread,
                        textSize: 14,
                        textWeight: FontWeight.w600,
                        textAlignment: Alignment.center,
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: !_showChats
                            ? AppColors.primaryOrange
                            : AppColors.primaryWhiteNormal,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.only(
                            topRight: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _showChats = false;
                        });
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => ChatroomUnread(),
                        //   ),
                        // );
                      },
                      child: CustomTexts(
                        title: 'Unread',
                        textColor: !_showChats
                            ? AppColors.primaryWhiteIcon
                            : AppColors.primaryUnread,
                        textSize: 14,
                        textWeight: FontWeight.w600,
                        textAlignment: Alignment.center,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 28),

              // Content based on state
              if (_isLoading)
                _buildLoadingState()
              else if (_showChats)
                _filteredGroups.isEmpty && _searchController.text.isEmpty
                    ? _buildEmptyState()
                    : _filteredGroups.isEmpty &&
                          _searchController.text.isNotEmpty
                    ? _buildNoSearchResults()
                    : Column(
                        children: [
                          ..._filteredGroups
                              .map(
                                (group) => Column(
                                  children: [
                                    _buildGroupChatItem(group),
                                    SizedBox(height: 28),
                                  ],
                                ),
                              )
                              .toList(),
                        ],
                      )
              else
                // For unread - you can implement similar logic for unread messages
                _buildEmptyState(),
            ],
          ),
        ),
      ),
    );
  }
}
