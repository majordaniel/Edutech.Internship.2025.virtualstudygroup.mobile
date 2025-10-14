// ignore_for_file: unused_element

import 'package:edify_app/screens/create_group.dart';
import 'package:edify_app/screens/welcome_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:edify_app/constants/colors.dart';
import 'package:edify_app/screens/join_group_page.dart';
import 'package:edify_app/screens/chatroom_chat.dart';

class CustomIconButton extends StatefulWidget {
  final Color iconColor;
  final Color? buttonColor;
  final double iconSize;
  final double buttonPaddingWidth;
  final double buttonPaddingheight;
  final double buttonBorderRadius;

  const CustomIconButton({
    super.key,
    required this.buttonColor,
    required this.iconSize,
    required this.iconColor,
    required this.buttonPaddingWidth,
    required this.buttonPaddingheight,
    required this.buttonBorderRadius,
  });

  @override
  State<CustomIconButton> createState() => _CustomIconButtonState();
}

class _CustomIconButtonState extends State<CustomIconButton> {
  bool _showMoreOptions = false;
  String _activePage = 'Dashboard';
  OverlayEntry? _overlayEntry;

  void _showCustomMenu(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

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
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      // ignore: deprecated_member_use
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: _buildMenuItems(),
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
        // Rebuild the menu with updated state
        _overlayEntry?.markNeedsBuild();
      } else {
        _showMoreOptions = false;
        _closeMenu();
      }
    });

    // Handle navigation for non-Study Group items
    if (value != 'Study Group') {
      switch (value) {
        case 'Dashboard':
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => WelcomePage()),
          );
          break;
        case 'Create Group':
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CreateGroupPage()),
          );
          break;
        case 'Join Group':
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => JoinGroupPage()),
          );
          break;
        case 'Chatroom':
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => Chatroom()),
          );
          break;
        case 'Calendar':
          // Handle calendar logic
          break;
        case 'My Courses':
          // Handle my courses logic
          break;
        case 'Resources':
          // Handle resources logic
          break;
      }
    }
  }

  List<Widget> _buildMenuItems() {
    return [
      _buildMenuItem(
        value: 'Dashboard',
        icon: Icons.dashboard_outlined,
        title: 'Dashboard',
        isSubItem: false,
      ),
      _buildMenuItem(
        value: 'Study Group',
        icon: Icons.group_outlined,
        title: 'Study Group',
        isSubItem: false,
        hasExpandIcon: true,
      ),
      if (_showMoreOptions) ...[
        _buildMenuItem(
          value: 'Create Group',
          title: 'Create Group',
          isSubItem: true,
        ),
        _buildMenuItem(
          value: 'Join Group',
          title: 'Join Group',
          isSubItem: true,
        ),
        _buildMenuItem(value: 'Chatroom', title: 'Chatroom', isSubItem: true),
      ],
      _buildMenuItem(
        value: 'My Courses',
        icon: Icons.school_outlined,
        title: 'My Courses',
        isSubItem: false,
      ),
      _buildMenuItem(
        value: 'Calendar',
        icon: Icons.calendar_today_outlined,
        title: 'Calendar',
        isSubItem: false,
      ),
      _buildMenuItem(
        value: 'Resources',
        icon: Icons.library_books_outlined,
        title: 'Resources',
        isSubItem: false,
      ),
    ];
  }

  Widget _buildMenuItem({
    required String value,
    IconData? icon,
    required String title,
    required bool isSubItem,
    bool hasExpandIcon = false,
  }) {
    return Material(
      color: _activePage == value
          ? AppColors.primaryOrange
          : Colors.transparent,
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        onTap: () {
          _handleMenuSelection(value, context);
        },
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
              Icon(
                icon,
                size: isSubItem ? 20 : 24,
                color: _activePage == value
                    ? AppColors.primaryWhiteIcon
                    : Colors.black,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: isSubItem ? 14 : 16,
                    fontWeight: FontWeight.w400,
                    color: _activePage == value
                        ? AppColors.primaryWhiteIcon
                        : Colors.black,
                  ),
                ),
              ),
              if (hasExpandIcon)
                Icon(
                  _showMoreOptions ? Icons.expand_less : Icons.expand_more,
                  size: 16,
                  color: _activePage == value
                      ? AppColors.primaryWhiteIcon
                      : Colors.black,
                ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isActive(String pageName) {
    return _activePage == pageName;
  }

  Color _getBackgroundColor(String pageName) {
    return _isActive(pageName) ? AppColors.primaryOrange : Colors.transparent;
  }

  Color _getTextColor(String pageName) {
    return _isActive(pageName) ? AppColors.primaryWhiteIcon : Colors.black;
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
        backgroundColor: widget.buttonColor,
        padding: EdgeInsets.symmetric(
          vertical: widget.buttonPaddingheight,
          horizontal: widget.buttonPaddingWidth,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.all(
            Radius.circular(widget.buttonBorderRadius),
          ),
        ),
      ),
      onPressed: () {
        _showCustomMenu(context);
      },
      child: Icon(Icons.menu, size: widget.iconSize, color: widget.iconColor),
    );
  }
}
