import 'dart:convert';

import 'package:edify_app/models/api_response.dart';
import 'package:edify_app/models/course_model.dart';
import 'package:edify_app/models/user_model.dart';
import 'package:edify_app/providers/join_request_provider.dart';
import 'package:edify_app/services/api_service.dart';
import 'package:edify_app/services/course_service.dart';
import 'package:edify_app/services/user_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/group_service.dart';
import '../models/group_model.dart';

class GroupProvider with ChangeNotifier {
  // Add these properties to your GroupProvider class
  List<User> _availableUsers = [];
  List<User> _selectedParticipants = [];
  List<User> _currentParticipants = [];

  List<User> get availableUsers => _availableUsers;
  List<User> get selectedParticipants => _selectedParticipants;
  List<User> get currentParticipants => _currentParticipants;
  List<Course> _availableCourses = [];
  bool _isLoadingCourses = false;

  // Add these getters
  List<Course> get availableCourses => _availableCourses;
  bool get isLoadingCourses => _isLoadingCourses;

  // Course management methods
  // Simplified GroupProvider loadCourses method
  Future<void> loadCourses() async {
    if (_isLoadingCourses) return;

    _isLoadingCourses = true;
    _error = null;
    notifyListeners();

    try {
      print('📚 DIRECT: Fetching courses via ApiService...');

      final response = await ApiService.get('study-groups/getcourses');

      print('📚 DIRECT: Response type: ${response.runtimeType}');

      if (response is List) {
        _availableCourses = response.map((courseJson) {
          try {
            final course = Course.fromJson(courseJson);
            print('✅ Parsed: ${course.displayName}');
            return course;
          } catch (e) {
            print('❌ Failed to parse: $e - Data: $courseJson');
            // Return default course to avoid breaking
            return Course(
              id: 0,
              courseName: 'Unknown',
              courseCode: 'UNK',
              courseDescription: '',
              creditUnits: 0,
              semester: '',
              level: '',
              department: '',
              createdAt: '',
              updatedAt: '',
            );
          }
        }).toList();

        print('🎉 SUCCESS: Loaded ${_availableCourses.length} courses!');
        _error = null;
      } else {
        _error = 'Unexpected response format';
        print('❌ Unexpected format: ${response.runtimeType}');
      }
    } catch (e) {
      _error = 'Error: $e';
      print('❌ Error: $e');
    } finally {
      _isLoadingCourses = false;
      notifyListeners();
      print('🏁 FINAL: ${_availableCourses.length} courses in provider');
    }
  }

  // Helper method to try alternative endpoints
  Future<void> _tryAlternativeEndpoints() async {
    print('🔄 Trying alternative course endpoints...');

    // Try different possible endpoints
    final alternativeEndpoints = [
      '/courses',
      '/study-groups/courses',
      '/user/courses',
    ];

    for (final endpoint in alternativeEndpoints) {
      try {
        print('🔄 Trying endpoint: $endpoint');
        final response = await ApiService.get(endpoint);

        if (response.isSuccess && response.data is List) {
          _availableCourses = (response.data as List)
              .map((courseJson) => Course.fromJson(courseJson))
              .toList();
          print('✅ Loaded ${_availableCourses.length} courses from $endpoint');
          _error = null;
          return; // Success, exit the loop
        }
      } catch (e) {
        print('❌ Failed with endpoint $endpoint: $e');
      }
    }
  }

  // Add participants to group
  Future<bool> addParticipantsToGroup({
    required int groupId,
    required List<int> userIds,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await GroupService.addParticipants(
        groupId: groupId,
        userIds: userIds,
      );

      if (response.isSuccess) {
        _selectedParticipants.clear();
        _error = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Load current participants
  Future<void> loadGroupParticipants(int groupId) async {
    _isLoading = true;
    _error = null;

    try {
      final response = await GroupService.getGroupParticipants(groupId);

      if (response.isSuccess) {
        _currentParticipants = response.data ?? [];
        _error = null;
      } else {
        _error = response.message;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners(); // Only here in finally block - GOOD
    }
  }

  // Search available users for group
  Future<void> searchAvailableUsers({
    required int groupId,
    required String query,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('🔍 Searching non-members for group $groupId with query: $query');
      final response = await GroupService.searchAvailableUsers(
        groupId: groupId,
        query: query,
      );

      if (response.isSuccess) {
        _availableUsers = response.data ?? [];
        print('✅ Found ${_availableUsers.length} available users');
        _error = null;
      } else {
        _error = response.message;
        print('❌ Search failed: $_error');

        // Fallback to general user search if specific endpoint fails
        if (query.isNotEmpty) {
          print('🔄 Falling back to general user search...');
          await searchAllUsers(query);
        }
      }
    } catch (e) {
      _error = e.toString();
      print('❌ Search error: $e');

      // Fallback to general user search
      if (query.isNotEmpty) {
        print('🔄 Falling back to general user search after error...');
        await searchAllUsers(query);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add these methods to your GroupProvider
  Future<void> searchUsersByCourse({
    required int courseId,
    required String query,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('🔍 Searching users for course $courseId with query: $query');

      // First, try to get users enrolled in the specific course
      final response = await ApiService.get(
        'courses/$courseId/users?search=$query',
      );

      if (response.isSuccess && response.data is List) {
        _availableUsers = (response.data as List)
            .map((userJson) => User.fromJson(userJson))
            .toList();
        print('✅ Found ${_availableUsers.length} users in course $courseId');
      } else {
        // Fallback: search all users if course-specific search fails
        await searchAllUsers(query);
      }
    } catch (e) {
      print('❌ Course-based user search failed: $e');
      // Fallback to general search
      await searchAllUsers(query);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Enhanced searchAllUsers method
  Future<void> searchAllUsers(String query) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('🔍 Searching all users with query: $query');
      final response = await UserService.searchUsers(query);

      if (response.isSuccess) {
        _availableUsers = response.data ?? [];
        print('✅ Found ${_availableUsers.length} users');
        _error = null;
      } else {
        _error = response.message;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Manage selected participants
  void addToSelectedParticipants(User user) {
    if (!_selectedParticipants.any((u) => u.id == user.id)) {
      _selectedParticipants.add(user);
      notifyListeners();
    }
  }

  void removeFromSelectedParticipants(User user) {
    _selectedParticipants.removeWhere((u) => u.id == user.id);
    notifyListeners();
  }

  void clearSelectedParticipants() {
    _selectedParticipants.clear();
    notifyListeners();
  }

  void clearAvailableUsers() {
    _availableUsers.clear();
    notifyListeners();
  }

  List<StudyGroup> _allGroups = [];
  List<StudyGroup> _myGroups = [];
  List<StudyGroup> _joinedGroups = [];
  bool _isLoading = false;
  String? _error;

  List<StudyGroup> get allGroups => _allGroups;
  List<StudyGroup> get myGroups => _myGroups;
  List<StudyGroup> get joinedGroups => _joinedGroups;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load all groups
  // In your GroupProvider methods
  // In providers/group_provider.dart - FIXED VERSION
  Future<void> loadAllGroups() async {
    if (_isLoading) return; // Prevent multiple simultaneous calls

    _isLoading = true;
    _error = null;
    // Don't call notifyListeners() here

    try {
      final response = await GroupService.getGroups();

      if (response.isSuccess) {
        _allGroups = response.data ?? [];
        _error = null;
      } else {
        _error = response.message;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      // Safe to notify listeners after async operation completes
      notifyListeners();
    }
  }

  // Load my created groups
  // Load my created groups - FIXED
  Future<void> loadMyGroups() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    // Remove notifyListeners() here

    try {
      final response = await GroupService.getMyGroups();

      if (response.isSuccess) {
        _myGroups = response.data ?? [];
        _error = null;
      } else {
        _error = response.message;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners(); // Only call here
    }
  }

  // Load joined groups - FIXED
  Future<void> loadJoinedGroups() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    // Remove notifyListeners() here

    try {
      final response = await GroupService.getJoinedGroups();

      if (response.isSuccess) {
        _joinedGroups = response.data ?? [];
        _error = null;
      } else {
        _error = response.message;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners(); // Only call here
    }
  }

  // Create a new group
  Future<bool> createGroup({
    required String groupName,
    required int courseId,
    required String description,
    bool isRestricted = false,
    List<dynamic> members = const [],
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await GroupService.createGroup(
        groupName: groupName,
        courseId: courseId,
        description: description,
        isRestricted: isRestricted,
        members: members,
      );

      if (response.isSuccess) {
        // Add the new group to my groups list
        if (response.data != null) {
          _myGroups.add(response.data!);
          _allGroups.add(response.data!);
        }
        _error = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Add this method to handle group creation with participants
  Future<bool> createGroupWithParticipants({
    required String groupName,
    required int courseId,
    required String description,
    bool isRestricted = false,
    required List<int> participantIds,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Use the existing createGroup method but include participants
      final response = await GroupService.createGroup(
        groupName: groupName,
        courseId: courseId,
        description: description,
        isRestricted: isRestricted,
        members: participantIds, // Pass participant IDs as members
      );

      if (response.isSuccess) {
        if (response.data != null) {
          _myGroups.add(response.data!);
          _allGroups.add(response.data!);
        }
        _error = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Join a group
  // In GroupProvider
  Future<bool> joinGroup(int groupId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('🌐 Sending join request to group $groupId');

      final response = await GroupService.joinGroup(groupId);

      print('📡 Join group response - Success: ${response.isSuccess}');
      print('📡 Join group response - Message: ${response.message}');
      print('📡 Join group response - Data: ${response.data}');

      if (response.isSuccess) {
        // Find the group and update it
        final groupIndex = _allGroups.indexWhere(
          (group) => group.id == groupId,
        );
        if (groupIndex != -1) {
          _joinedGroups.add(_allGroups[groupIndex]);
        }
        _error = null;
        _isLoading = false;
        notifyListeners();

        // Trigger notification refresh after successful join request
        _triggerNotificationRefresh();

        return true;
      } else {
        _error = response.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('❌ Error joining group: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // FIXED: Make this an instance method and remove static
  Future<void> triggerNotificationRefresh(BuildContext context) async {
    try {
      final joinRequestProvider = context.read<JoinRequestProvider>();
      await joinRequestProvider.forceRefresh();
      // print('🔄 Manually triggered notification refresh');
    } catch (e) {
      // print('⚠️ Failed to trigger notification refresh: $e');
    }
  }

  // Helper method to trigger notification refresh without context
  void _triggerNotificationRefresh() {
    // This will be handled by the auto-refresh mechanism
    // If you need immediate refresh, you'll need to pass context
    // or use a different approach
    print(
      '🔄 Join request successful - notification refresh will happen automatically',
    );
  }

  // Add this method to manually trigger notification refresh
  // Leave a group
  Future<bool> leaveGroup(int groupId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await GroupService.leaveGroup(groupId);

      if (response.isSuccess) {
        // Remove from joined groups
        _joinedGroups.removeWhere((group) => group.id == groupId);
        _error = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Search groups
  Future<List<StudyGroup>> searchGroups(String query) async {
    try {
      final response = await GroupService.searchGroups(query);

      if (response.isSuccess) {
        return response.data ?? [];
      } else {
        _error = response.message;
        return [];
      }
    } catch (e) {
      _error = e.toString();
      return [];
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Add this method to your GroupProvider for testing
  Future<void> debugCourseApi() async {
    print('🐛 DEBUG: Testing course API endpoints...');

    final endpoints = [
      '/study-groups/getcourses',
      '/courses',
      '/study-groups/courses',
      '/user/courses',
    ];

    for (final endpoint in endpoints) {
      try {
        print('🐛 Testing: $endpoint');
        final response = await ApiService.get(endpoint);
        print('🐛 Response for $endpoint:');
        print('   Status: ${response.status}');
        print('   Message: ${response.message}');
        print('   Data type: ${response.data?.runtimeType}');
        print('   Data: ${response.data}');
        print('   ---');
      } catch (e) {
        print('🐛 Error for $endpoint: $e');
      }
    }
  }

  Future<void> debugSearchUsers(String query) async {
    print('🐛 DEBUG: Starting search with query: "$query"');

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('🐛 DEBUG: Calling UserService.searchUsers...');
      final response = await UserService.searchUsers(query);

      print(
        '🐛 DEBUG: Search response - Success: ${response.isSuccess}, Message: ${response.message}',
      );

      if (response.isSuccess) {
        _availableUsers = response.data ?? [];
        print(
          '🐛 DEBUG: Available users set to: ${_availableUsers.length} users',
        );
        _error = null;
      } else {
        _error = response.message;
        print('🐛 DEBUG: Search failed with error: $_error');
      }
    } catch (e) {
      _error = e.toString();
      print('🐛 DEBUG: Search threw exception: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
      print('🐛 DEBUG: Search completed. Loading: $_isLoading, Error: $_error');
    }
  }
}
