import 'package:edify_app/widgets/icon_button.dart';
import 'package:edify_app/widgets/notification_icon.dart';
import 'package:edify_app/widgets/user_avatar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edify_app/widgets/appbar.dart';
import 'package:edify_app/widgets/texts.dart';
import 'package:edify_app/constants/colors.dart';
import 'package:edify_app/providers/group_provider.dart';
import 'package:edify_app/providers/user_provider.dart';

class JoinGroupPage extends StatefulWidget {
  const JoinGroupPage({super.key});

  @override
  State<JoinGroupPage> createState() => _JoinGroupPageState();
}

class _JoinGroupPageState extends State<JoinGroupPage> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _filteredGroups = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    // Delay the initial load to avoid build conflicts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadGroups();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadGroups() async {
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    await groupProvider.loadAllGroups();

    if (mounted) {
      setState(() {
        _filteredGroups = groupProvider.allGroups;
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);

    if (query.isEmpty) {
      if (mounted) {
        setState(() {
          _filteredGroups = groupProvider.allGroups;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _filteredGroups = groupProvider.allGroups.where((group) {
            return group.groupName.toLowerCase().contains(query) ||
                group.description.toLowerCase().contains(query);
          }).toList();
        });
      }
    }
  }

  void _joinGroup(int groupId, String groupName) async {
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.primaryOrange),
              SizedBox(height: 16),
              Text(
                'Sending join request...',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      final success = await groupProvider.joinGroup(groupId);

      // Hide loading dialog
      if (mounted) {
        Navigator.pop(context);
      }

      if (success && mounted) {
        _showSuccessDialog(context, groupName);

        // Manually trigger notification refresh for immediate update
        groupProvider.triggerNotificationRefresh(context);
      } else if (mounted) {
        final errorMessage =
            groupProvider.error ?? 'Failed to send join request';
        _showErrorDialog(context, errorMessage);
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        _showErrorDialog(context, 'Network error: $e');
      }
    }
  }

  void _showSuccessDialog(BuildContext context, String groupName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Icon(Icons.check_circle, color: Colors.green, size: 24),
              Text(
                'Request Sent',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryAppbarBlack,
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                ),
                onPressed: () {
                  Navigator.pop(context);
                  // Refresh the groups list
                  if (mounted) {
                    _loadGroups();
                  }
                },
                child: Icon(
                  Icons.cancel,
                  size: 30,
                  color: AppColors.primaryOrange,
                ),
              ),
            ],
          ),
          content: Container(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 63),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  'You will be added to "$groupName" once admin approves your request.',
                  style: TextStyle(
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: AppColors.primaryBlack,
                  ),
                ),
                SizedBox(height: 25),
                // Text(
                //   'You will be notified once the admin approves your request.',
                //   style: TextStyle(
                //     fontSize: 14,
                //     color: AppColors.primaryBlackLight,
                //     fontStyle: FontStyle.italic,
                //   ),
                // ),
                Align(
                  alignment: AlignmentGeometry.center,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.all(8),
                      backgroundColor: AppColors.primaryOrange,
                      foregroundColor: AppColors.primaryWhiteIcon,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      // Cancel request
                      if (mounted) {
                        _loadGroups();
                      }
                    },
                    child: CustomTexts(
                      title: 'Cancel request',
                      textColor: AppColors.primaryWhiteIcon,
                      textSize: 12,
                      textWeight: FontWeight.w500,
                      textAlignment: AlignmentGeometry.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // actions: [
          //   TextButton(
          //     onPressed: () {
          //       Navigator.pop(context);
          //       // Refresh the groups list
          //       if (mounted) {
          //         _loadGroups();
          //       }
          //     },
          //     child: Text(
          //       'Okay',
          //       style: TextStyle(
          //         color: AppColors.primaryOrange,
          //         fontWeight: FontWeight.w500,
          //       ),
          //     ),
          //   ),
          // ],
        );
      },
    );
  }

  void _showErrorDialog(BuildContext context, String error) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 24),
              SizedBox(width: 8),
              Text(
                'Request Failed',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryBlack,
                ),
              ),
            ],
          ),
          content: Text(
            _getUserFriendlyErrorMessage(error),
            style: TextStyle(fontSize: 14, color: AppColors.primaryBlack),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Try Again',
                style: TextStyle(
                  color: AppColors.primaryOrange,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _getUserFriendlyErrorMessage(String error) {
    if (error.contains('401') || error.contains('unauthorized')) {
      return 'Please log in again to join groups.';
    } else if (error.contains('404') || error.contains('not found')) {
      return 'Group not found. It may have been deleted.';
    } else if (error.contains('409') || error.contains('already')) {
      return 'You have already requested to join this group.';
    } else if (error.contains('500') || error.contains('server')) {
      return 'Server error. Please try again later.';
    } else {
      return 'Failed to send join request: $error';
    }
  }

  Widget _buildGroupCard(dynamic group) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 13, horizontal: 10),
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: AppColors.primaryBlackLight),
        borderRadius: BorderRadius.all(Radius.circular(6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTexts(
                  title: group.groupName,
                  textColor: AppColors.primaryAppbarBlack,
                  textSize: 16,
                  textWeight: FontWeight.w500,
                  textAlignment: Alignment.centerLeft,
                ),
                SizedBox(height: 4),
                CustomTexts(
                  title: group.description.isNotEmpty
                      ? group.description
                      : 'No description provided',
                  textColor: AppColors.primaryBlack,
                  textSize: 12,
                  textWeight: FontWeight.w400,
                  textAlignment: Alignment.centerLeft,
                  // maxLines: 2,
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.lock_outline,
                      size: 12,
                      color: AppColors.primaryBlack,
                    ),
                    SizedBox(width: 4),
                    CustomTexts(
                      title: group.isRestricted ? 'Restricted' : 'Open',
                      textColor: AppColors.primaryBlack,
                      textSize: 10,
                      textWeight: FontWeight.w400,
                      textAlignment: Alignment.centerLeft,
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
          TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              backgroundColor: AppColors.primaryOrange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              _joinGroup(group.id, group.groupName);
            },
            child: CustomTexts(
              title: 'Join Room',
              textColor: AppColors.primaryWhiteIcon,
              textSize: 12,
              textWeight: FontWeight.w500,
              textAlignment: Alignment.center,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context);

    // Initialize filtered groups once when provider data is available
    if (_filteredGroups.isEmpty &&
        groupProvider.allGroups.isNotEmpty &&
        !_isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _filteredGroups = groupProvider.allGroups;
          });
        }
      });
    }

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
                  hintText: 'Search for groups (course code and names)',
                  hintStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: Icon(Icons.search_outlined),
                ),
              ),
              SizedBox(height: 28),

              // Loading State
              if (_isLoading)
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 50),
                    child: CircularProgressIndicator(
                      color: AppColors.primaryOrange,
                    ),
                  ),
                )
              // Empty State
              else if (_filteredGroups.isEmpty &&
                  _searchController.text.isEmpty)
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 50),
                    child: Column(
                      children: [
                        Icon(
                          Icons.group_outlined,
                          size: 64,
                          color: AppColors.primaryBlackLight,
                        ),
                        SizedBox(height: 16),
                        CustomTexts(
                          title: 'No Study Groups Available',
                          textColor: AppColors.primaryBlack,
                          textSize: 16,
                          textWeight: FontWeight.w500,
                          textAlignment: Alignment.center,
                        ),
                        SizedBox(height: 8),
                        CustomTexts(
                          title:
                              'Create the first study group or check back later',
                          textColor: AppColors.primaryBlackLight,
                          textSize: 14,
                          textWeight: FontWeight.w400,
                          textAlignment: Alignment.center,
                        ),
                      ],
                    ),
                  ),
                )
              // No Search Results
              else if (_filteredGroups.isEmpty &&
                  _searchController.text.isNotEmpty)
                Center(
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
                          title: 'No Groups Found',
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
                )
              // Groups List
              else
                Column(
                  children: _filteredGroups
                      .map((group) => _buildGroupCard(group))
                      .toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
