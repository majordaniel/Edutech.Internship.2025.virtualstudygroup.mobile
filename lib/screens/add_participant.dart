import 'dart:async';
import 'package:edify_app/providers/user_provider.dart';
import 'package:edify_app/widgets/icon_button.dart';
import 'package:edify_app/widgets/user_avatar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:edify_app/widgets/appbar.dart';
import 'package:edify_app/constants/colors.dart';
import 'package:edify_app/providers/group_provider.dart';
import 'package:edify_app/models/user_model.dart';

class AddParticipantPage extends StatefulWidget {
  final int courseId;
  final String courseName;
  final List<User> selectedParticipants;

  const AddParticipantPage({
    super.key,
    required this.courseId,
    required this.courseName,
    required this.selectedParticipants,
  });

  @override
  State<AddParticipantPage> createState() => _AddParticipantPageState();
}

class _AddParticipantPageState extends State<AddParticipantPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _searchTimer;
  List<User> _selectedParticipants = [];

  @override
  void initState() {
    super.initState();
    _selectedParticipants = List.from(widget.selectedParticipants);
    _searchController.addListener(_onSearchChanged);

    // Load initial users for this course
    _loadInitialUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _searchTimer?.cancel();
    super.dispose();
  }

  void _loadInitialUsers() {
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    // Load users enrolled in this course (empty query = get all)
    groupProvider.searchUsersByCourse(courseId: widget.courseId, query: '');
  }

  void _onSearchChanged() {
    _searchTimer?.cancel();
    _searchTimer = Timer(const Duration(milliseconds: 500), () {
      final query = _searchController.text.trim();
      final groupProvider = Provider.of<GroupProvider>(context, listen: false);

      if (query.isEmpty) {
        groupProvider.searchUsersByCourse(courseId: widget.courseId, query: '');
      } else {
        groupProvider.searchUsersByCourse(
          courseId: widget.courseId,
          query: query,
        );
      }
    });
  }

  void _addParticipant(User user) {
    if (!_selectedParticipants.any((p) => p.id == user.id)) {
      setState(() {
        _selectedParticipants.add(user);
      });
    }
  }

  void _removeParticipant(User user) {
    setState(() {
      _selectedParticipants.removeWhere((p) => p.id == user.id);
    });
  }

  void _saveAndReturn() {
    Navigator.pop(context, _selectedParticipants);
  }

  Widget _buildSelectedParticipantChip(User user) {
    return Container(
      padding: EdgeInsets.all(8),
      margin: EdgeInsets.only(right: 8, bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryWhiteNormal.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primaryBlack),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            user.fullName,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryBlack,
            ),
          ),
          SizedBox(width: 6),
          GestureDetector(
            onTap: () => _removeParticipant(user),
            child: Icon(Icons.close, size: 14, color: AppColors.primaryBlack),
          ),
        ],
      ),
    );
  }

  Widget _buildUserListItem(User user, GroupProvider groupProvider) {
    final isSelected = _selectedParticipants.any((p) => p.id == user.id);

    return ListTile(
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: AppColors.primaryOrange.withOpacity(0.1),
        child: Text(
          user.firstName[0] + user.lastName[0],
          style: GoogleFonts.poppins(
            color: AppColors.primaryBlack,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      title: Text(
        user.fullName,
        style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        user.email,
        style: GoogleFonts.poppins(fontSize: 12, color: AppColors.primaryBlack),
      ),
      trailing: Icon(
        isSelected ? Icons.add_circle_outline : Icons.add_circle_outline,
        color: AppColors.primaryOrange,
        size: 35.83,
      ),
      onTap: () {
        // if (isSelected) {
        //   _removeParticipant(user);
        // } else {
        _addParticipant(user);
        // }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryWhiteIcon,
      appBar: AppBar(
        title: CustomAppbar(),
        backgroundColor: AppColors.primaryWhiteIcon,
        elevation: 0,
        actions: [
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
          // IconButton(
          //   onPressed: _saveAndReturn,
          //   icon: Icon(Icons.check, color: AppColors.primaryOrange),
          // ),
        ],
      ),
      body: Consumer<GroupProvider>(
        builder: (context, groupProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                if (_selectedParticipants.isNotEmpty) ...[
                  // Text(
                  //   'Selected Participants (${_selectedParticipants.length})',
                  //   style: GoogleFonts.poppins(
                  //     fontSize: 14,
                  //     fontWeight: FontWeight.w500,
                  //   ),
                  // ),
                  // SizedBox(height: 8),
                  Wrap(
                    children: _selectedParticipants
                        .map((user) => _buildSelectedParticipantChip(user))
                        .toList(),
                  ),
                  SizedBox(height: 16),
                ],

                SizedBox(height: 20),

                // Search Bar
                TextField(
                  cursorColor: AppColors.primaryOrange,
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  decoration: InputDecoration(
                    hintText: 'Search users by name or email...',
                    prefixIcon: Icon(
                      Icons.search,
                      color: AppColors.primaryOrange,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Selected Participants

                // Users List
                Expanded(
                  child: groupProvider.isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primaryOrange,
                          ),
                        )
                      : groupProvider.availableUsers.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                _searchController.text.isEmpty
                                    ? 'No users found for this course'
                                    : 'No users found',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: AppColors.primaryBlackLight,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: groupProvider.availableUsers.length,
                          itemBuilder: (context, index) {
                            final user = groupProvider.availableUsers[index];
                            return _buildUserListItem(user, groupProvider);
                          },
                        ),
                ),

                // Save Button
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _selectedParticipants.isNotEmpty
                      ? _saveAndReturn
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedParticipants.isNotEmpty
                        ? AppColors.primaryOrange
                        : AppColors.primaryBlackLight.withOpacity(0.3),
                    minimumSize: Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    _selectedParticipants.isEmpty
                        ? 'Select Participants'
                        : 'Add ${_selectedParticipants.length} Participant${_selectedParticipants.length == 1 ? '' : 's'}',
                    style: TextStyle(
                      color: AppColors.primaryWhiteIcon,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
