// simple_user_avatar_stateful.dart
import 'package:edify_app/auth/login_page.dart';
import 'package:edify_app/widgets/texts.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edify_app/providers/user_provider.dart';
import 'package:edify_app/constants/colors.dart';

class SimpleUserAvatar extends StatefulWidget {
  final String? imageUrl;
  final String? userName;
  final double size;

  const SimpleUserAvatar({
    super.key,
    this.imageUrl,
    this.userName,
    this.size = 40,
  });

  @override
  State<SimpleUserAvatar> createState() => _SimpleUserAvatarState();
}

class _SimpleUserAvatarState extends State<SimpleUserAvatar> {
  bool _isLoggingOut = false;

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final currentUser = userProvider.user;
    final displayName = widget.userName ?? currentUser?.fullName ?? 'User';
    final initials = _getInitials(displayName);

    return PopupMenuButton<String>(
      icon: _isLoggingOut
          ? SizedBox(
              width: widget.size,
              height: widget.size,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primaryOrange,
              ),
            )
          : _buildAvatar(initials),
      onSelected: (value) async {
        if (value == 'logout') {
          await _handleLogout();
        }
      },
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (context) => _isLoggingOut
          ? [
              const PopupMenuItem<String>(
                value: 'loading',
                enabled: false,
                height: 40,
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 12),
                    Text('Logging out...'),
                  ],
                ),
              ),
            ]
          : [
              // User info header
              PopupMenuItem<String>(
                value: 'user_info',
                enabled: false,
                height: 60,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // User name
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryBlack,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // User email
                    if (currentUser?.email != null)
                      Text(
                        currentUser!.email,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.primaryBlack.withOpacity(0.6),
                        ),
                      ),
                  ],
                ),
              ),
              // Divider
              const PopupMenuDivider(height: 8),
              // Logout option
              const PopupMenuItem<String>(
                value: 'logout',
                height: 40,
                child: Row(
                  children: [
                    Icon(Icons.logout_outlined, color: Colors.red, size: 20),
                    SizedBox(width: 12),
                    Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
    );
  }

  Widget _buildAvatar(String initials) {
    if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: widget.size / 2,
        backgroundImage: NetworkImage(widget.imageUrl!),
      );
    } else {
      return CircleAvatar(
        radius: widget.size / 2,
        backgroundColor: AppColors.primaryOrange,
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: widget.size * 0.4,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
  }

  String _getInitials(String displayName) {
    if (displayName.isEmpty) return 'U';

    final names = displayName.split(' ');
    if (names.length == 1) {
      return names[0][0].toUpperCase();
    } else {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
  }

  Future<void> _handleLogout() async {
    if (_isLoggingOut) return;

    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 328,
          height: 150,
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            color: AppColors.primaryLightGreyJoinR,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomTexts(
                title: 'Are you sure you want to logout?',
                textColor: AppColors.primaryBlack,
                textSize: 16,
                textWeight: FontWeight.w500,
                textAlignment: AlignmentGeometry.center,
              ),
              SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.all(10),
                      foregroundColor: AppColors.primaryOrange,
                      backgroundColor: AppColors.primaryWhiteIcon,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        side: BorderSide(color: AppColors.primaryOrange),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                  SizedBox(width: 10),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.all(10),
                      foregroundColor: AppColors.primaryWhiteIcon,
                      backgroundColor: AppColors.primaryOrange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                    ),
                    child: const Text('Logout'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (shouldLogout != true) return;

    setState(() {
      _isLoggingOut = true;
    });

    try {
      // Perform logout
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.logout();

      // Navigate to login page
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoggingOut = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
