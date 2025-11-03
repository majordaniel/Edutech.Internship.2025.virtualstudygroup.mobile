// ultra_simple_user_avatar.dart
import 'package:flutter/material.dart';
import 'package:edify_app/constants/colors.dart';

class UltraSimpleUserAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? userName;
  final double size;
  final VoidCallback onLogout;

  const UltraSimpleUserAvatar({
    super.key,
    this.imageUrl,
    this.userName,
    this.size = 40,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: _buildAvatar(),
      onSelected: (value) {
        if (value == 'logout') {
          onLogout();
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout_outlined, color: Colors.red),
              SizedBox(width: 12),
              Text('Logout', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar() {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: size / 2,
        backgroundImage: NetworkImage(imageUrl!),
      );
    } else {
      return CircleAvatar(
        radius: size / 2,
        backgroundColor: AppColors.primaryOrange,
        child: Text(
          _getInitials(),
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
  }

  String _getInitials() {
    if (userName == null || userName!.isEmpty) return 'U';
    final names = userName!.split(' ');
    if (names.length == 1) return names[0][0].toUpperCase();
    return '${names[0][0]}${names[1][0]}'.toUpperCase();
  }
}
