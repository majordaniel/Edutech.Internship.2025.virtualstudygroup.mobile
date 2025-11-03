// ignore_for_file: unused_element

import 'package:edify_app/screens/create_group.dart';
import 'package:edify_app/screens/welcome_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:edify_app/constants/colors.dart';
import 'package:edify_app/screens/join_group_page.dart';
import 'package:edify_app/screens/chatroom_chat.dart';
import 'package:provider/provider.dart';
import 'package:edify_app/providers/user_provider.dart';

class CustomIconButton extends StatefulWidget {
  const CustomIconButton({super.key});

  @override
  State<CustomIconButton> createState() => _CustomIconButtonState();
}

class _CustomIconButtonState extends State<CustomIconButton> {
  bool _showMoreOptions = false;
  String _activePage = 'Dashboard';
  OverlayEntry? _overlayEntry;

  void _showCustomMenu(BuildContext context) {
    // ✅ FIXED: Add null safety checks
    final renderObject = context.findRenderObject();
    if (renderObject == null || renderObject is! RenderBox) {
      print('❌ Could not get render object');
      return;
    }

    final button = renderObject;
    final overlay = Overlay.of(context).context.findRenderObject();
    if (overlay == null || overlay is! RenderBox) {
      print('❌ Could not get overlay render object');
      return;
    }

    final buttonPosition = button.localToGlobal(Offset.zero, ancestor: overlay);
    final buttonSize = button.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Background overlay to capture taps outside
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                _closeMenu();
              },
              child: Container(color: Colors.transparent),
            ),
          ),
          // Menu content
          Positioned(
            top: buttonPosition.dy + buttonSize.height + 5,
            right:
                MediaQuery.of(context).size.width -
                buttonPosition.dx -
                buttonSize.width,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 280,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: _buildMenuItems(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _closeMenu() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _handleMenuSelection(String value, BuildContext context) {
    setState(() {
      _activePage = value;

      if (value == 'Study Group') {
        _showMoreOptions = !_showMoreOptions;
        _overlayEntry?.markNeedsBuild();
      } else {
        _showMoreOptions = false;
        _closeMenu();
      }
    });

    if (value != 'Study Group') {
      _navigateToPage(value, context);
    }
  }

  // ✅ EXTRACTED: Separate navigation logic
  void _navigateToPage(String value, BuildContext context) {
    switch (value) {
      case 'Dashboard':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const WelcomePage()),
        );
        break;
      case 'Create Group':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateGroupPage()),
        );
        break;
      case 'Join Group':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const JoinGroupPage()),
        );
        break;
      case 'Chatroom':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const Chatroom()),
        );
        break;
      case 'Calendar':
        _showComingSoon(context);
        break;
      case 'My Courses':
        _showComingSoon(context);
        break;
      case 'Resources':
        _showComingSoon(context);
        break;
      case 'Logout':
        _handleLogout(context);
        break;
    }
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Feature coming soon!'),
        backgroundColor: AppColors.primaryOrange,
      ),
    );
  }

  // ✅ IMPROVED: Better logout with null safety
  void _handleLogout(BuildContext context) async {
    try {
      print('🚪 Starting logout process...');

      _closeMenu();

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryOrange),
        ),
      );

      // Get user provider with null check
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.logout();

      // Dismiss loading indicator safely
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      print('✅ Logout successful, navigating to welcome page...');

      // Navigate to welcome page
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const WelcomePage()),
        (route) => false,
      );
    } catch (e) {
      print('❌ Logout error: $e');

      // Dismiss loading indicator safely
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logout failed: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  List<Widget> _buildMenuItems(BuildContext context) {
    return [
      _buildMenuItem(
        context: context,
        value: 'Dashboard',
        icon: Icons.dashboard_outlined,
        title: 'Dashboard',
        isSubItem: false,
      ),
      _buildMenuItem(
        context: context,
        value: 'Study Group',
        icon: Icons.group_outlined,
        title: 'Study Group',
        isSubItem: false,
        hasExpandIcon: true,
      ),
      if (_showMoreOptions) ..._buildStudyGroupSubItems(context),
      _buildMenuItem(
        context: context,
        value: 'My Courses',
        icon: Icons.school_outlined,
        title: 'My Courses',
        isSubItem: false,
      ),
      _buildMenuItem(
        context: context,
        value: 'Calendar',
        icon: Icons.calendar_today_outlined,
        title: 'Calendar',
        isSubItem: false,
      ),
      _buildMenuItem(
        context: context,
        value: 'Resources',
        icon: Icons.library_books_outlined,
        title: 'Resources',
        isSubItem: false,
      ),
    ];
  }

  // ✅ EXTRACTED: Study group sub-items
  List<Widget> _buildStudyGroupSubItems(BuildContext context) {
    return [
      _buildMenuItem(
        context: context,
        value: 'Create Group',
        title: 'Create Group',
        isSubItem: true,
      ),
      _buildMenuItem(
        context: context,
        value: 'Join Group',
        title: 'Join Group',
        isSubItem: true,
      ),
      _buildMenuItem(
        context: context,
        value: 'Chatroom',
        title: 'Chatroom',
        isSubItem: true,
      ),
    ];
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required String value,
    IconData? icon,
    required String title,
    required bool isSubItem,
    bool hasExpandIcon = false,
  }) {
    final isActive = _activePage == value;

    return Material(
      color: isActive ? AppColors.primaryOrange : Colors.transparent,
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        onTap: () => _handleMenuSelection(value, context),
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: EdgeInsets.only(
            left: isSubItem ? 24.0 : 12.0,
            right: 12,
            top: 12,
            bottom: 12,
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: isSubItem ? 20 : 24,
                  color: isActive ? AppColors.primaryWhiteIcon : Colors.black,
                ),
                const SizedBox(width: 12),
              ] else if (isSubItem) ...[
                const SizedBox(width: 32),
              ],
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: isSubItem ? 14 : 16,
                    fontWeight: FontWeight.w400,
                    color: isActive ? AppColors.primaryWhiteIcon : Colors.black,
                  ),
                ),
              ),
              if (hasExpandIcon)
                Icon(
                  _showMoreOptions ? Icons.expand_less : Icons.expand_more,
                  size: 16,
                  color: isActive ? AppColors.primaryWhiteIcon : Colors.black,
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: AppColors.primaryOrange,
        padding: EdgeInsets.symmetric(vertical: 2.63, horizontal: 9.63),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.75)),
        ),
      ),
      onPressed: () {
        _showCustomMenu(context);
      },
      child: Icon(Icons.menu, size: 30.63, color: AppColors.primaryWhiteIcon),
    );
  }
}
