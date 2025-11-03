import 'package:edify_app/screens/profile_page_person.dart';
import 'package:edify_app/services/user_service.dart';
import 'package:edify_app/widgets/icon_button.dart';
import 'package:edify_app/widgets/notification_icon.dart';
import 'package:edify_app/widgets/user_avatar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edify_app/widgets/appbar.dart';
import 'package:edify_app/constants/colors.dart';
import 'package:edify_app/widgets/texts.dart';
import 'package:edify_app/services/group_management_service.dart';
import 'package:edify_app/models/user_model.dart';
import 'package:edify_app/providers/user_provider.dart';

class SeeGroupMembersAdmin extends StatefulWidget {
  final int groupId;
  final bool isCurrentUserAdmin;

  const SeeGroupMembersAdmin({
    super.key,
    required this.groupId,
    required this.isCurrentUserAdmin,
  });

  @override
  State<SeeGroupMembersAdmin> createState() => _SeeGroupMembersAdminState();
}

class _SeeGroupMembersAdminState extends State<SeeGroupMembersAdmin> {
  List<User> _members = [];
  bool _isLoading = true;
  String? _error;
  String _groupName = 'Group';
  List<User> _availableUsers = [];
  bool _isLoadingUsers = false;

  @override
  void initState() {
    super.initState();
    _loadGroupData();
    _loadAvailableUsers();
  }

  Future<void> _loadGroupData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      print('🔄 Loading ALL group members for group ${widget.groupId}');

      // Use the method that gets ALL members
      final membersResponse = await GroupManagementService.getGroupMembers(
        widget.groupId,
      );

      if (membersResponse.isSuccess) {
        print(
          '✅ Successfully loaded ${membersResponse.data?.length ?? 0} members',
        );

        // Debug: Print member details
        if (membersResponse.data != null) {
          final adminCount = membersResponse.data!
              .where((user) => user.isAdmin)
              .length;
          print('👑 Found $adminCount admin users');

          for (final member in membersResponse.data!) {
            print(
              '👤 Member: ${member.fullName} (ID: ${member.id}) - Admin: ${member.isAdmin}',
            );
          }
        }

        setState(() {
          _members = membersResponse.data ?? [];
        });

        // Also load group details to get the group name
        final detailsResponse = await GroupManagementService.getGroupDetails(
          widget.groupId,
        );
        if (detailsResponse.isSuccess && detailsResponse.data != null) {
          setState(() {
            _groupName = detailsResponse.data!['group_name'] ?? 'Group';
          });
        }
      } else {
        print('❌ Failed to load members: ${membersResponse.message}');
        setState(() {
          _error = membersResponse.message;
        });
      }
    } catch (e) {
      print('💥 Exception loading group data: $e');
      setState(() {
        _error = 'Failed to load group data: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadAvailableUsers() async {
    setState(() {
      _isLoadingUsers = true;
    });

    try {
      final response = await UserService.getUsers();
      if (response.isSuccess && mounted) {
        // Filter out users who are already members
        final currentMemberIds = _members.map((m) => m.id).toSet();
        final availableUsers =
            response.data
                ?.where((user) => !currentMemberIds.contains(user.id))
                .toList() ??
            [];

        setState(() {
          _availableUsers = availableUsers;
        });
      }
    } catch (e) {
      print('Error loading available users: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingUsers = false;
        });
      }
    }
  }

  void _showAddMemberDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            // constraints: BoxConstraints(maxWidth: 400),
            padding: EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Add Members to $_groupName',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlack,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: AppColors.primaryBlack),
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Available Users List
                Text(
                  'Select members to add:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryBlack,
                  ),
                ),
                SizedBox(height: 14),

                if (_isLoadingUsers)
                  Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryOrange,
                    ),
                  )
                else if (_availableUsers.isEmpty)
                  Container(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 48,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'No available users to add',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    height: 480,
                    child: ListView.builder(
                      itemCount: _availableUsers.length,
                      itemBuilder: (context, index) {
                        final user = _availableUsers[index];
                        return ListTile(
                          leading: CircleAvatar(
                            radius: 20,
                            backgroundColor: AppColors.primaryOrange
                                .withOpacity(0.1),
                            child: Text(
                              user.firstName[0] + user.lastName[0],
                              style: TextStyle(
                                color: AppColors.primaryBlack,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            user.fullName,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            user.email,
                            style: TextStyle(fontSize: 12),
                          ),
                          trailing: Icon(
                            Icons.person_add_alt_1,
                            color: AppColors.primaryOrange,
                          ),
                          onTap: () => _addMemberToGroup(user),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _addMemberToGroup(User user) async {
    Navigator.pop(context); // Close the dialog

    // Show loading
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            SizedBox(width: 12),
            Text('Adding ${user.fullName} to group...'),
          ],
        ),
        backgroundColor: AppColors.primaryOrange,
        duration: Duration(seconds: 10),
      ),
    );

    try {
      final response = await GroupManagementService.addMemberToGroup(
        groupId: widget.groupId,
        userId: user.id,
      );

      // Hide loading snackbar
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (response.isSuccess) {
        // Refresh the members list
        await _loadGroupData();
        // Refresh available users
        await _loadAvailableUsers();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${user.fullName} added to $_groupName'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add member: ${response.message}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding member: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _showMemberOptions(BuildContext context, User member) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(color: Colors.transparent),
                ),
              ),
              Positioned(
                top: 40,
                right: 0,
                child: Container(
                  width: 262,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: AppColors.primaryWhiteIcon,
                  ),
                  padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header with admin badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundImage: member.avatarUrl.isNotEmpty
                                      ? NetworkImage(member.avatarUrl)
                                      : AssetImage('assets/jerry.jpg')
                                            as ImageProvider,
                                  radius: 15,
                                ),
                                SizedBox(width: 11),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        member.fullName,
                                        style: TextStyle(
                                          color: AppColors.primaryBlack,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        'Admin Actions',
                                        style: TextStyle(
                                          color: AppColors.primaryOrange,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(
                              Icons.cancel_outlined,
                              color: AppColors.primaryBlack,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 23),

                      // Admin actions
                      Text(
                        'Manage ${member.fullName}',
                        style: TextStyle(
                          color: AppColors.primaryBlackLight,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 15),

                      // Make Admin / Remove Admin button
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 9,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          backgroundColor: AppColors.primaryOrangeLight,
                        ),
                        onPressed: () => _toggleAdminStatus(member),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              member.isAdmin
                                  ? 'Remove as admin'
                                  : 'Make group admin',
                              style: TextStyle(
                                color: AppColors.primaryBlack,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Icon(
                              member.isAdmin
                                  ? Icons.person_remove_outlined
                                  : Icons.person_add_alt_1_outlined,
                              color: AppColors.primaryBlack,
                              size: 21,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 15),

                      // Remove from group button
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 9,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          backgroundColor: AppColors.primaryOrangeLight,
                        ),
                        onPressed: () => _showRemoveConfirmation(member),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Remove from group',
                              style: TextStyle(
                                color: AppColors.primaryBlack,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Icon(
                              Icons.person_remove_alt_1_outlined,
                              color: AppColors.primaryBlack,
                              size: 21,
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
        );
      },
    );
  }

  void _toggleAdminStatus(User member) async {
    Navigator.pop(context);

    try {
      final response = await GroupManagementService.makeMemberAdmin(
        groupId: widget.groupId,
        userId: member.id,
      );

      if (response.isSuccess) {
        // Refresh the members list to get updated admin status
        await _loadGroupData();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              member.isAdmin
                  ? '${member.fullName} admin privileges removed'
                  : '${member.fullName} is now an admin',
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update admin status: ${response.message}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _showRemoveConfirmation(User member) {
    Navigator.pop(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.primaryWhiteIcon,
              borderRadius: BorderRadius.circular(16),
            ),
            width: 328,
            padding: EdgeInsets.symmetric(vertical: 32, horizontal: 51),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTexts(
                  title:
                      'Are you sure you want to remove ${member.fullName} from $_groupName?',
                  textColor: AppColors.primaryConfirmBlue,
                  textSize: 12,
                  textWeight: FontWeight.w500,
                  textAlignment: Alignment.center,
                ),
                SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                          side: BorderSide(color: AppColors.primaryOrange),
                        ),
                        backgroundColor: AppColors.primaryWhiteNormal,
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: CustomTexts(
                        title: 'Cancel',
                        textColor: AppColors.primaryStrongBlack900,
                        textSize: 12,
                        textWeight: FontWeight.w500,
                        textAlignment: Alignment.center,
                      ),
                    ),
                    SizedBox(width: 10),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                          side: BorderSide(color: AppColors.primaryOrange),
                        ),
                        backgroundColor: AppColors.primaryOrange,
                      ),
                      onPressed: () => _removeMember(member),
                      child: CustomTexts(
                        title: 'Remove',
                        textColor: AppColors.primaryWhiteIcon,
                        textSize: 12,
                        textWeight: FontWeight.w500,
                        textAlignment: Alignment.center,
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

  void _removeMember(User member) async {
    Navigator.pop(context);

    // Show loading
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            SizedBox(width: 12),
            Text('Removing ${member.fullName}...'),
          ],
        ),
        backgroundColor: AppColors.primaryOrange,
        duration: Duration(seconds: 10), // Long duration for loading
      ),
    );

    try {
      final response = await GroupManagementService.removeMemberFromGroup(
        groupId: widget.groupId,
        userId: member.id,
      );

      // Hide loading snackbar
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (response.isSuccess) {
        setState(() {
          _members.removeWhere((m) => m.id == member.id);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${member.fullName} removed from $_groupName'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove member: ${response.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _leaveGroup() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.primaryWhiteIcon,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: EdgeInsets.symmetric(vertical: 32, horizontal: 51),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTexts(
                  title: 'Are you sure you want to leave $_groupName?',
                  textColor: AppColors.primaryBlack,
                  textSize: 12,
                  textWeight: FontWeight.w500,
                  textAlignment: Alignment.center,
                ),
                SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                          side: BorderSide(color: AppColors.primaryOrange),
                        ),
                        backgroundColor: AppColors.primaryWhiteNormal,
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: CustomTexts(
                        title: 'Cancel',
                        textColor: AppColors.primaryStrongBlack900,
                        textSize: 12,
                        textWeight: FontWeight.w500,
                        textAlignment: Alignment.center,
                      ),
                    ),
                    SizedBox(width: 10),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                          side: BorderSide(color: AppColors.primaryOrange),
                        ),
                        backgroundColor: AppColors.primaryOrange,
                      ),
                      onPressed: () => _confirmLeaveGroup(),
                      child: CustomTexts(
                        title: 'Leave',
                        textColor: AppColors.primaryWhiteIcon,
                        textSize: 12,
                        textWeight: FontWeight.w500,
                        textAlignment: Alignment.center,
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

  void _confirmLeaveGroup() async {
    Navigator.pop(context); // Close confirmation dialog

    try {
      final response = await GroupManagementService.leaveGroup(widget.groupId);

      if (response.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You have left $_groupName'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );

        // Navigate back to groups list or previous screen
        Navigator.popUntil(context, (route) => route.isFirst);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to leave group: ${response.message}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _navigateToMemberProfile(User member) {
    print('👤 Navigating to profile of: ${member.fullName} (ID: ${member.id})');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfilePagePerson(member: member),
      ),
    );
  }

  Widget _buildMemberList() {
    if (_members.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.group_off,
                size: 64,
                color: AppColors.primaryBlackLight,
              ),
              SizedBox(height: 16),
              CustomTexts(
                title: 'No members found',
                textColor: AppColors.primaryBlack,
                textSize: 16,
                textWeight: FontWeight.w500,
                textAlignment: Alignment.center,
              ),
              SizedBox(height: 8),
              CustomTexts(
                title: 'This group currently has no members',
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

    return Column(
      children: _members.map((member) => _buildMemberItem(member)).toList(),
    );
  }

  Widget _buildMemberItem(User member) {
    final currentUser = context.read<UserProvider>().user;
    final isCurrentUser = currentUser?.id == member.id;

    return Container(
      margin: EdgeInsets.only(bottom: 8),
      child: TextButton(
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(2)),
          ),
        ),
        onPressed: () {
          print('👤 Member tapped: ${member.fullName} (ID: ${member.id})');
          print('   Current user is admin: ${widget.isCurrentUserAdmin}');
          print('   Is current user: $isCurrentUser');
          print('   Member is admin: ${member.isAdmin}');

          // Show admin options ONLY if:
          // 1. Current user is admin
          // 2. It's not themselves
          // 3. The member is not an admin (admins can't manage other admins)
          if (widget.isCurrentUserAdmin && !isCurrentUser && !member.isAdmin) {
            print('   Showing admin options dialog');
            _showMemberOptions(context, member);
          } else {
            // For all other cases, navigate to profile page
            print('   Navigating to profile page');
            _navigateToMemberProfile(member);
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 15,
                  backgroundImage: member.avatarUrl.isNotEmpty
                      ? NetworkImage(member.avatarUrl)
                      : AssetImage('assets/duke.png') as ImageProvider,
                ),
                SizedBox(width: 11),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CustomTexts(
                          title: member.fullName,
                          textColor: AppColors.primaryBlack,
                          textSize: 14,
                          textWeight: FontWeight.w500,
                          textAlignment: Alignment.centerLeft,
                        ),
                        if (member.isAdmin) ...[
                          SizedBox(width: 6),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryOrange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: AppColors.primaryOrange.withOpacity(0.3),
                                width: 0.5,
                              ),
                            ),
                            child: Text(
                              'Admin',
                              style: TextStyle(
                                color: AppColors.primaryOrange,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (member.email.isNotEmpty)
                      CustomTexts(
                        title: member.email,
                        textColor: AppColors.primaryBlackLight,
                        textSize: 12,
                        textWeight: FontWeight.w400,
                        textAlignment: Alignment.centerLeft,
                      ),
                  ],
                ),
              ],
            ),
            Icon(Icons.keyboard_arrow_right_outlined),
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
      body: _isLoading
          ? _buildLoadingState()
          : _error != null
          ? _buildErrorState()
          : _buildContent(),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primaryOrange),
          SizedBox(height: 16),
          CustomTexts(
            title: 'Loading $_groupName members...',
            textColor: AppColors.primaryBlack,
            textSize: 16,
            textWeight: FontWeight.w500,
            textAlignment: Alignment.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            CustomTexts(
              title: 'Unable to Load Group Data',
              textColor: AppColors.primaryBlack,
              textSize: 18,
              textWeight: FontWeight.w600,
              textAlignment: Alignment.center,
            ),
            SizedBox(height: 8),
            CustomTexts(
              title: _error ?? 'Unknown error occurred',
              textColor: AppColors.primaryBlackLight,
              textSize: 14,
              textWeight: FontWeight.w400,
              textAlignment: Alignment.center,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadGroupData,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: CustomTexts(
                title: 'Try Again',
                textColor: Colors.white,
                textSize: 16,
                textWeight: FontWeight.w500,
                textAlignment: Alignment.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 35),
            CustomTexts(
              title: '$_groupName Members (${_members.length})',
              textColor: AppColors.primaryBlack,
              textSize: 16,
              textWeight: FontWeight.w500,
              textAlignment: Alignment.centerLeft,
            ),
            SizedBox(height: 15),
            _buildMemberList(),
            SizedBox(height: 20),

            // Only show admin options if current user is admin
            if (widget.isCurrentUserAdmin) ...[
              TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(2)),
                  ),
                ),
                onPressed:
                    _showAddMemberDialog, // FIXED: Call the dialog method
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(Icons.group_add_outlined),
                    SizedBox(width: 24),
                    CustomTexts(
                      title: 'Add people',
                      textColor: AppColors.primaryBlack,
                      textSize: 16,
                      textWeight: FontWeight.w500,
                      textAlignment: Alignment.centerLeft,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 17),
            ],

            TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(2)),
                ),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Invite via link feature coming soon'),
                    backgroundColor: AppColors.primaryOrange,
                  ),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(Icons.link_outlined),
                  SizedBox(width: 24),
                  CustomTexts(
                    title: 'Invite to group via link',
                    textColor: AppColors.primaryBlack,
                    textSize: 16,
                    textWeight: FontWeight.w500,
                    textAlignment: Alignment.centerLeft,
                  ),
                ],
              ),
            ),
            SizedBox(height: 17),
            TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(2)),
                ),
              ),
              onPressed: _leaveGroup,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(Icons.exit_to_app_outlined),
                  SizedBox(width: 24),
                  CustomTexts(
                    title: 'Leave $_groupName',
                    textColor: AppColors.primaryBlack,
                    textSize: 16,
                    textWeight: FontWeight.w500,
                    textAlignment: Alignment.centerLeft,
                  ),
                ],
              ),
            ),
            SizedBox(height: 17),
          ],
        ),
      ),
    );
  }
}
