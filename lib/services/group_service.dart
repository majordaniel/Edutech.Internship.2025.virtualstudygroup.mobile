// ignore_for_file: unused_import

import 'package:edify_app/services/course_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'api_service.dart';
import '../models/group_model.dart';
import '../models/api_response.dart';
import 'package:edify_app/models/user_model.dart';

class GroupService {
  // Get all study groups
  static Future<ApiResponse<List<StudyGroup>>> getGroups() async {
    final response = await ApiService.get('study-rooms');
    return ApiResponse<List<StudyGroup>>.fromJson(
      response,
      (data) =>
          (data as List).map((group) => StudyGroup.fromJson(group)).toList(),
    );
  }

  // Get groups created by current user
  static Future<ApiResponse<List<StudyGroup>>> getMyGroups() async {
    final response = await ApiService.get('study-groups/getUserGroups');
    return ApiResponse<List<StudyGroup>>.fromJson(
      response,
      (data) =>
          (data as List).map((group) => StudyGroup.fromJson(group)).toList(),
    );
  }

  // Get groups user has joined
  static Future<ApiResponse<List<StudyGroup>>> getJoinedGroups() async {
    final response = await ApiService.get('study-groups/getUserGroups');
    return ApiResponse<List<StudyGroup>>.fromJson(
      response,
      (data) =>
          (data as List).map((group) => StudyGroup.fromJson(group)).toList(),
    );
  }

  // Create new study group
  static Future<ApiResponse<StudyGroup>> createGroup({
    required String groupName,
    required int courseId,
    required String description,
    bool isRestricted = false,
    required List<dynamic> members,
  }) async {
    final response = await ApiService.post('study-groups/create', {
      'group_name': groupName,
      'course_id': courseId,
      'description': description,
      'is_restricted': isRestricted,
      'members': members,
    });

    return ApiResponse<StudyGroup>.fromJson(
      response,
      (data) => StudyGroup.fromJson(data),
    );
  }

  // Join a study group (Request to join)
  // In GroupService
  static Future<ApiResponse<dynamic>> joinGroup(int groupId) async {
    try {
      print('🌐 Sending join request to group $groupId');

      // Based on your endpoints: "Request to join a group"
      final response = await ApiService.post(
        'study-groups/$groupId/join-request',
        {
          // Add any required parameters here
          'user_id':
              await _getCurrentUserId(), // You might need to get current user ID
          'request_message': 'Request to join group',
        },
      );

      print('✅ Join request API response: $response');

      return ApiResponse<dynamic>.fromJson(response, null);
    } catch (e) {
      print('❌ Join request API error: $e');
      rethrow;
    }
  }

  // Helper method to get current user ID
  static Future<int> _getCurrentUserId() async {
    // You'll need to implement this based on how you store user data
    // This might come from your UserProvider or SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id') ?? 0;
  }

  // Leave a study group
  static Future<ApiResponse<dynamic>> leaveGroup(int groupId) async {
    final response = await ApiService.post('study-groups/$groupId/leave', {});
    return ApiResponse<dynamic>.fromJson(response, null);
  }

  // Get group details
  static Future<ApiResponse<StudyGroup>> getGroupDetails(int groupId) async {
    final response = await ApiService.get('study-groups/$groupId/details');
    return ApiResponse<StudyGroup>.fromJson(
      response,
      (data) => StudyGroup.fromJson(data),
    );
  }

  // Add participants to group
  static Future<ApiResponse<dynamic>> addParticipants({
    required int groupId,
    required List<int> userIds,
  }) async {
    final response = await ApiService.post('study-groups/$groupId/add-member', {
      'user_ids': userIds,
    });
    return ApiResponse<dynamic>.fromJson(response, null);
  }

  // Get group participants
  static Future<ApiResponse<List<User>>> getGroupParticipants(
    int groupId,
  ) async {
    final response = await ApiService.get('study-groups/$groupId/participants');
    return ApiResponse<List<User>>.fromJson(
      response,
      (data) => (data as List).map((user) => User.fromJson(user)).toList(),
    );
  }

  // Search available users for group
  static Future<ApiResponse<List<User>>> searchAvailableUsers({
    required int groupId,
    required String query,
  }) async {
    print('🔍 Searching available users for group $groupId with query: $query');

    // Try different possible endpoints for searching available users
    try {
      // First try: Search group members (if this endpoint searches all users)
      final response = await ApiService.get(
        'study-groups/$groupId/participants?search=$query',
      );
      print('📡 Search response: ${response.toString()}');

      return ApiResponse<List<User>>.fromJson(
        response,
        (data) => (data as List).map((user) => User.fromJson(user)).toList(),
      );
    } catch (e) {
      print('❌ First search attempt failed: $e');

      // Fallback: Use general user search (client-side filtering)
      return await _fallbackUserSearch(query);
    }
  }

  // Fallback: Client-side user search
  static Future<ApiResponse<List<User>>> _fallbackUserSearch(
    String query,
  ) async {
    try {
      print('🔄 Using fallback client-side search for: $query');

      // Get all users first
      final allUsersResponse = await ApiService.get('users');
      final allUsers = ApiResponse<List<User>>.fromJson(
        allUsersResponse,
        (data) => (data as List).map((user) => User.fromJson(user)).toList(),
      );

      if (allUsers.isSuccess && allUsers.data != null) {
        // Filter users client-side
        final filteredUsers = allUsers.data!.where((user) {
          final fullName = '${user.firstName} ${user.lastName}'.toLowerCase();
          final email = user.email.toLowerCase();
          final searchTerm = query.toLowerCase();

          return fullName.contains(searchTerm) || email.contains(searchTerm);
        }).toList();

        print('✅ Fallback search found ${filteredUsers.length} users');

        return ApiResponse<List<User>>(
          status: 'success',
          message: '',
          data: filteredUsers,
        );
      } else {
        return ApiResponse<List<User>>(
          status: 'error',
          message: 'Failed to load users',
          data: [],
        );
      }
    } catch (e) {
      print('❌ Fallback search failed: $e');
      return ApiResponse<List<User>>(
        status: 'error',
        message: e.toString(),
        data: [],
      );
    }
  }

  // Search groups
  static Future<ApiResponse<List<StudyGroup>>> searchGroups(
    String query,
  ) async {
    final response = await ApiService.get('groups/search?q=$query');
    return ApiResponse<List<StudyGroup>>.fromJson(
      response,
      (data) =>
          (data as List).map((group) => StudyGroup.fromJson(group)).toList(),
    );
  }

  // Search users for participants (using your existing pattern)
  static Future<ApiResponse<List<User>>> searchUsers(String query) async {
    try {
      final response = await ApiService.get('users?search=$query');

      return ApiResponse<List<User>>.fromJson(
        response,
        (data) => (data as List).map((user) => User.fromJson(user)).toList(),
      );
    } catch (e) {
      return ApiResponse<List<User>>(
        status: 'error',
        message: e.toString(),
        data: [],
      );
    }
  }

  // Remove participant from group
  static Future<ApiResponse<dynamic>> removeParticipant({
    required int groupId,
    required int userId,
  }) async {
    final response = await ApiService.delete(
      'study-groups/$groupId/participants/$userId',
    );
    return ApiResponse<dynamic>.fromJson(response, null);
  }

  // Update group information
  static Future<ApiResponse<StudyGroup>> updateGroup({
    required int groupId,
    required String groupName,
    required String description,
  }) async {
    final response = await ApiService.put('study-groups/$groupId/update', {
      'group_name': groupName,
      'description': description,
    });

    return ApiResponse<StudyGroup>.fromJson(
      response,
      (data) => StudyGroup.fromJson(data),
    );
  }

  // Delete group (if user is creator)
  static Future<ApiResponse<dynamic>> deleteGroup(int groupId) async {
    final response = await ApiService.delete('study-groups/$groupId');
    return ApiResponse<dynamic>.fromJson(response, null);
  }
}
