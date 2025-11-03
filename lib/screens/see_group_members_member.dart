import 'package:edify_app/widgets/appbar.dart';
import 'package:edify_app/screens/leave_group_confirmation.dart';
import 'package:edify_app/screens/profile_page_person.dart';
import 'package:edify_app/widgets/icon_button.dart';
import 'package:edify_app/widgets/notification_icon.dart';
import 'package:edify_app/widgets/user_avatar.dart';
import 'package:flutter/material.dart';
import 'package:edify_app/constants/colors.dart';
import 'package:edify_app/widgets/texts.dart';
import 'package:edify_app/services/group_management_service.dart';
import 'package:edify_app/models/user_model.dart';
import 'package:provider/provider.dart';
import 'package:edify_app/providers/user_provider.dart';

class SeeGroupMembersMember extends StatefulWidget {
  final int groupId;
  final String groupName;

  const SeeGroupMembersMember({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  State<SeeGroupMembersMember> createState() => _SeeGroupMembersMemberState();
}

class _SeeGroupMembersMemberState extends State<SeeGroupMembersMember> {
  List<User> _members = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadGroupMembers();
  }

  Future<void> _loadGroupMembers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final membersResponse = await GroupManagementService.getGroupMembers(
        widget.groupId,
      );

      if (membersResponse.isSuccess) {
        setState(() {
          _members = membersResponse.data ?? [];
        });
      } else {
        setState(() {
          _error = membersResponse.message;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load members: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToMemberProfile(User member) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfilePagePerson(member: member),
      ),
    );
  }

  Widget _buildMemberItem(User member) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      child: TextButton(
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(2)),
          ),
        ),
        onPressed: () => _navigateToMemberProfile(member),
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

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primaryOrange),
          SizedBox(height: 16),
          CustomTexts(
            title: 'Loading members...',
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red),
          SizedBox(height: 16),
          CustomTexts(
            title: 'Failed to load members',
            textColor: AppColors.primaryBlack,
            textSize: 16,
            textWeight: FontWeight.w500,
            textAlignment: Alignment.center,
          ),
          SizedBox(height: 8),
          CustomTexts(
            title: _error ?? 'Unknown error',
            textColor: AppColors.primaryBlackLight,
            textSize: 14,
            textWeight: FontWeight.w400,
            textAlignment: Alignment.center,
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadGroupMembers,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryOrange,
            ),
            child: Text('Try Again'),
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
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 35),
                    CustomTexts(
                      title: '${widget.groupName} Members (${_members.length})',
                      textColor: AppColors.primaryBlack,
                      textSize: 16,
                      textWeight: FontWeight.w500,
                      textAlignment: AlignmentGeometry.centerLeft,
                    ),
                    SizedBox(height: 15),

                    // Members list
                    ..._members.map((member) => _buildMemberItem(member)),

                    SizedBox(height: 20),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(2)),
                        ),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Invite via link feature coming soon',
                            ),
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
                            textAlignment: AlignmentGeometry.centerLeft,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 17),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(2)),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                LeaveGroupConfirmation(groupId: widget.groupId),
                          ),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(Icons.exit_to_app_outlined),
                          SizedBox(width: 24),
                          CustomTexts(
                            title: 'Leave ${widget.groupName}',
                            textColor: AppColors.primaryBlack,
                            textSize: 16,
                            textWeight: FontWeight.w500,
                            textAlignment: AlignmentGeometry.centerLeft,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 17),
                  ],
                ),
              ),
            ),
    );
  }
}
