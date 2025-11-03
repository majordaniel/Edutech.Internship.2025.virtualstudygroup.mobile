// ignore_for_file: unused_field

import 'package:edify_app/widgets/icon_button.dart';
import 'package:edify_app/widgets/notification_icon.dart';
import 'package:edify_app/widgets/user_avatar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:edify_app/widgets/appbar.dart';
import 'package:edify_app/constants/colors.dart';
import 'package:edify_app/widgets/texts.dart';
import 'package:edify_app/providers/group_provider.dart';
import 'package:edify_app/providers/user_provider.dart';
import 'package:edify_app/services/user_service.dart';
import 'package:edify_app/models/user_model.dart';
import 'package:edify_app/models/course_model.dart';
import 'package:edify_app/screens/add_participant.dart';

class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({super.key});

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final _formKey = GlobalKey<FormState>();
  final _groupNameController = TextEditingController();
  final _descriptionController = TextEditingController();

  Course? _selectedCourse;
  List<User> _selectedParticipants = [];
  List<User> _availableUsers = [];
  bool _isLoadingUsers = false;

  @override
  void initState() {
    super.initState();
    _loadAvailableUsers();
    _loadCourses();
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _loadCourses() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final groupProvider = Provider.of<GroupProvider>(context, listen: false);
      groupProvider.loadCourses();
    });
  }

  void _loadAvailableUsers() async {
    setState(() {
      _isLoadingUsers = true;
    });

    try {
      final response = await UserService.getUsers();
      if (response.isSuccess && mounted) {
        setState(() {
          _availableUsers = response.data ?? [];
        });
      }
    } catch (e) {
      print('Error loading users: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingUsers = false;
        });
      }
    }
  }

  void _navigateToAddParticipant() {
    if (_selectedCourse == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddParticipantPage(
          courseId: _selectedCourse!.id,
          courseName: _selectedCourse!.courseName,
          selectedParticipants: _selectedParticipants,
        ),
      ),
    ).then((result) {
      if (result != null && result is List<User>) {
        setState(() {
          _selectedParticipants = result;
        });
      }
    });
  }

  void _createGroup(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      if (_selectedCourse == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select a course'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      if (_selectedParticipants.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please add at least one participant'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final groupProvider = Provider.of<GroupProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      // Show creating dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.primaryOrange),
              SizedBox(height: 16),
              Text('Creating group...'),
            ],
          ),
        ),
      );

      try {
        // Include creator in participants
        final allParticipantIds = [
          userProvider.user?.id ?? 0,
          ..._selectedParticipants.map((user) => user.id),
        ];

        final success = await groupProvider.createGroupWithParticipants(
          groupName: _groupNameController.text.trim(),
          courseId: _selectedCourse!.id,
          description: _descriptionController.text.trim(),
          isRestricted: false,
          participantIds: allParticipantIds,
        );

        // Close the dialog
        if (mounted) Navigator.of(context).pop();

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Group "${_groupNameController.text}" created successfully!',
                style: TextStyle(fontSize: 16),
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );

          Navigator.pop(context, true);
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                groupProvider.error ?? 'Failed to create group',
                style: TextStyle(fontSize: 16),
              ),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } catch (e) {
        // Close the dialog if there's an error
        if (mounted) Navigator.of(context).pop();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error creating group: $e',
                style: TextStyle(fontSize: 16),
              ),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  Widget _buildCourseDropdown(GroupProvider groupProvider) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.primaryOrangeLight,
        border: Border.all(color: AppColors.primaryWhiteNormal),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Course>(
          value: _selectedCourse,
          isExpanded: true,
          hint: Text(
            groupProvider.isLoadingCourses
                ? 'Loading courses...'
                : groupProvider.availableCourses.isEmpty
                ? 'No courses available'
                : 'Select a course',
            style: GoogleFonts.poppins(
              color: AppColors.primaryBlackLightActive,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          icon: groupProvider.isLoadingCourses
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(
                  Icons.keyboard_arrow_down_outlined,
                  color: AppColors.primaryBlack,
                ),
          items: groupProvider.availableCourses.map((Course course) {
            return DropdownMenuItem<Course>(
              value: course,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    course.displayName,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 2),
                  // Text(
                  //   course.courseDescription.isNotEmpty
                  //       ? course.courseDescription
                  //       : '${course.department} • ${course.level}',
                  //   style: GoogleFonts.poppins(
                  //     fontSize: 11,
                  //     color: AppColors.primaryBlackLight,
                  //   ),
                  //   maxLines: 1,
                  //   overflow: TextOverflow.ellipsis,
                  // ),
                ],
              ),
            );
          }).toList(),
          onChanged:
              groupProvider.isLoadingCourses ||
                  groupProvider.availableCourses.isEmpty
              ? null
              : (Course? newCourse) {
                  setState(() {
                    _selectedCourse = newCourse;
                  });
                },
        ),
      ),
    );
  }

  // Widget _buildSelectedParticipantsChips() {
  //   if (_selectedParticipants.isEmpty) {
  //     return SizedBox.shrink();
  //   }

  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       SizedBox(height: 16),
  //       Text(
  //         'Selected Participants (${_selectedParticipants.length})',
  //         style: GoogleFonts.poppins(
  //           fontSize: 14,
  //           fontWeight: FontWeight.w500,
  //           color: AppColors.primaryBlack,
  //         ),
  //       ),
  //       SizedBox(height: 8),
  //       Wrap(
  //         spacing: 8,
  //         runSpacing: 8,
  //         children: _selectedParticipants.map((user) {
  //           return Container(
  //             padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  //             decoration: BoxDecoration(
  //               color: AppColors.primaryOrange.withOpacity(0.1),
  //               borderRadius: BorderRadius.circular(16),
  //               border: Border.all(color: AppColors.primaryOrange),
  //             ),
  //             child: Row(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 CircleAvatar(
  //                   radius: 12,
  //                   backgroundColor: AppColors.primaryOrange.withOpacity(0.2),
  //                   child: Text(
  //                     user.firstName[0],
  //                     style: TextStyle(
  //                       fontSize: 10,
  //                       fontWeight: FontWeight.bold,
  //                       color: AppColors.primaryOrange,
  //                     ),
  //                   ),
  //                 ),
  //                 SizedBox(width: 6),
  //                 Text(
  //                   user.fullName,
  //                   style: GoogleFonts.poppins(
  //                     fontSize: 12,
  //                     fontWeight: FontWeight.w500,
  //                   ),
  //                 ),
  //                 SizedBox(width: 4),
  //                 GestureDetector(
  //                   onTap: () {
  //                     setState(() {
  //                       _selectedParticipants.removeWhere(
  //                         (p) => p.id == user.id,
  //                       );
  //                     });
  //                   },
  //                   child: Icon(
  //                     Icons.close,
  //                     size: 14,
  //                     color: AppColors.primaryOrange,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           );
  //         }).toList(),
  //       ),
  //     ],
  //   );
  // }

  String _getCreateButtonText() {
    if (_selectedCourse == null) {
      return 'Select Course to Create Group';
    } else if (_selectedParticipants.isEmpty) {
      return 'Add Participants to Create Group';
    } else {
      return 'Create Group';
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context);

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
          padding: const EdgeInsets.all(18.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTexts(
                  title: 'Create Group',
                  textColor: AppColors.primaryBlack,
                  textSize: 20,
                  textWeight: FontWeight.w500,
                  textAlignment: Alignment.center,
                ),
                SizedBox(height: 54),

                // Group Name Field
                Row(
                  children: [
                    CustomTexts(
                      title: 'Group Name',
                      textColor: AppColors.primaryBlack,
                      textSize: 16,
                      textWeight: FontWeight.w500,
                      textAlignment: Alignment.centerLeft,
                    ),
                    Text(
                      '*',
                      style: GoogleFonts.poppins(
                        color: AppColors.primaryOrange,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: _groupNameController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: AppColors.primaryWhiteNormal,
                      ),
                    ),
                    hintText: 'Enter group name',
                    hintStyle: GoogleFonts.poppins(
                      color: AppColors.primaryBlackLightActive,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a group name';
                    }
                    if (value.length < 3) {
                      return 'Group name must be at least 3 characters';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 26),

                // Course Selection Dropdown
                Row(
                  children: [
                    CustomTexts(
                      title: 'Select Course',
                      textColor: AppColors.primaryBlack,
                      textSize: 16,
                      textWeight: FontWeight.w500,
                      textAlignment: Alignment.centerLeft,
                    ),
                    Text(
                      '*',
                      style: GoogleFonts.poppins(
                        color: AppColors.primaryOrange,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                _buildCourseDropdown(groupProvider),
                SizedBox(height: 26),

                // Description Field
                Row(
                  children: [
                    CustomTexts(
                      title: 'Group Description',
                      textColor: AppColors.primaryBlack,
                      textSize: 16,
                      textWeight: FontWeight.w500,
                      textAlignment: Alignment.centerLeft,
                    ),
                    Text(
                      '*',
                      style: GoogleFonts.poppins(
                        color: AppColors.primaryOrange,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                SizedBox(
                  height: 186,
                  child: TextFormField(
                    controller: _descriptionController,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: AppColors.primaryWhiteNormal,
                        ),
                      ),
                      hintText: 'Enter group description...',
                      hintStyle: GoogleFonts.poppins(
                        color: AppColors.primaryBlackLightActive,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      alignLabelWithHint: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a group description';
                      }
                      if (value.length < 5) {
                        return 'Description must be at least 5 characters';
                      }
                      return null;
                    },
                  ),
                ),

                // Selected Participants Chips
                // _buildSelectedParticipantsChips(),

                // Add Participant Section
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _selectedCourse != null
                      ? _navigateToAddParticipant
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedCourse != null
                        ? AppColors.primaryOrange
                        : AppColors.primaryBlackLight.withOpacity(0.3),
                    minimumSize: Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Add Participant ${_selectedParticipants.isNotEmpty ? '(${_selectedParticipants.length})' : ''}',
                    style: TextStyle(
                      color: AppColors.primaryWhiteIcon,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                SizedBox(height: 24),

                // Group Summary
                // if (_selectedCourse != null && _selectedParticipants.isNotEmpty)
                //   Container(
                //     width: double.infinity,
                //     padding: EdgeInsets.all(16),
                //     decoration: BoxDecoration(
                //       color: AppColors.primaryOrange.withOpacity(0.1),
                //       borderRadius: BorderRadius.circular(8),
                //       border: Border.all(
                //         color: AppColors.primaryOrange.withOpacity(0.3),
                //       ),
                //     ),
                //     child: Column(
                //       crossAxisAlignment: CrossAxisAlignment.start,
                //       children: [
                //         Text(
                //           'Group Summary',
                //           style: GoogleFonts.poppins(
                //             fontSize: 16,
                //             fontWeight: FontWeight.w600,
                //             color: AppColors.primaryBlack,
                //           ),
                //         ),
                //         SizedBox(height: 8),
                //         Text(
                //           'Course: ${_selectedCourse!.displayName}',
                //           style: GoogleFonts.poppins(
                //             fontSize: 14,
                //             color: AppColors.primaryBlack,
                //           ),
                //         ),
                //         SizedBox(height: 4),
                //         Text(
                //           'Participants: ${_selectedParticipants.length + 1} members (You + ${_selectedParticipants.length} others)',
                //           style: GoogleFonts.poppins(
                //             fontSize: 14,
                //             color: AppColors.primaryBlack,
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                SizedBox(height: 16),

                // Create Group Button
                groupProvider.isLoading
                    ? Container(
                        height: 48,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlackLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primaryBlack,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Creating Group...',
                                style: GoogleFonts.poppins(
                                  color: AppColors.primaryBlack,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ElevatedButton(
                        onPressed:
                            _selectedCourse != null &&
                                _selectedParticipants.isNotEmpty
                            ? () => _createGroup(context)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _selectedCourse != null &&
                                  _selectedParticipants.isNotEmpty
                              ? AppColors.primaryBlackLight
                              : AppColors.primaryBlackLight.withOpacity(0.3),
                          minimumSize: Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          _getCreateButtonText(),
                          style: TextStyle(
                            color: AppColors.primaryBlack,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
