import 'api_service.dart';
import '../models/user_model.dart';
import '../models/api_response.dart';

class GroupManagementService {
  // Get all group members
  static Future<ApiResponse<List<User>>> getGroupMembers(int groupId) async {
    try {
      print('👥 Fetching ALL members for group $groupId');

      // Use the group details endpoint
      final response = await ApiService.get('study-groups/$groupId/details');

      if (response is Map<String, dynamic> && response['status'] == 'success') {
        final data = response['data'];

        if (data is Map<String, dynamic> && data['members'] is List) {
          final membersData = data['members'] as List;
          print('✅ Found ${membersData.length} members in data.members');

          final users = <User>[];

          for (final memberData in membersData) {
            try {
              // Each member has a 'user' object with the actual user data
              final userData = memberData['user'] as Map<String, dynamic>;

              final user = User(
                id: userData['id'] ?? 0,
                firstName: userData['first_name']?.toString() ?? '',
                lastName: userData['last_name']?.toString() ?? '',
                email: userData['email']?.toString() ?? '',
                avatar: userData['avatar']?.toString(),
                emailVerifiedAt: userData['email_verified_at']?.toString(),
                createdAt: userData['created_at']?.toString() ?? '',
                updatedAt: userData['updated_at']?.toString() ?? '',
                avatarUrl: userData['avatar_url']?.toString() ?? '',
                // Check if role is "Leader" to determine admin status
                isAdmin:
                    (memberData['role']?.toString() ?? '').toLowerCase() ==
                    'leader',
              );

              if (user.id > 0) {
                users.add(user);
                print(
                  '✅ Added user: ${user.fullName} (ID: ${user.id}) - Role: ${memberData['role']} - Admin: ${user.isAdmin}',
                );
              }
            } catch (e) {
              print('❌ Error creating user from member data: $e');
              print('   Problematic member data: $memberData');
            }
          }

          print('🎉 Successfully loaded ${users.length} group members');
          return ApiResponse<List<User>>(
            status: 'success',
            message: 'All group members loaded successfully',
            data: users,
          );
        } else {
          print('❌ No members found in expected location: data.members');
          return ApiResponse<List<User>>(
            status: 'error',
            message: 'No members data found',
            data: [],
          );
        }
      } else {
        print('❌ API response not successful: ${response['message']}');
        return ApiResponse<List<User>>(
          status: 'error',
          message:
              response['message']?.toString() ?? 'Failed to load group details',
          data: [],
        );
      }
    } catch (e) {
      print('❌ Error fetching group members: $e');
      return ApiResponse<List<User>>(
        status: 'error',
        message: e.toString(),
        data: [],
      );
    }
  }

  // Get group details
  static Future<ApiResponse<Map<String, dynamic>>> getGroupDetails(
    int groupId,
  ) async {
    try {
      print('🔍 Fetching group details for group $groupId');

      final response = await ApiService.get('study-groups/$groupId/details');

      return ApiResponse<Map<String, dynamic>>.fromJson(
        response,
        (data) => data as Map<String, dynamic>,
      );
    } catch (e) {
      print('❌ Error fetching group details: $e');
      return ApiResponse<Map<String, dynamic>>(
        status: 'error',
        message: e.toString(),
        data: null,
      );
    }
  }

  // Remove member from group (admin only)
  static Future<ApiResponse<dynamic>> removeMemberFromGroup({
    required int groupId,
    required int userId,
  }) async {
    try {
      print('🗑️ Removing user $userId from group $groupId');

      final response = await ApiService.delete(
        'study-groups/$groupId/admin-remove-members/$userId',
      );

      print('✅ Remove member response: $response');

      return ApiResponse<dynamic>.fromJson(response, null);
    } catch (e) {
      print('❌ Error removing member: $e');
      return ApiResponse<dynamic>(
        status: 'error',
        message: e.toString(),
        data: null,
      );
    }
  }

  // Leave group
  static Future<ApiResponse<dynamic>> leaveGroup(int groupId) async {
    try {
      print('🚪 Leaving group $groupId');

      final response = await ApiService.delete('study-groups/$groupId/leave');

      print('✅ Leave group response: $response');

      return ApiResponse<dynamic>.fromJson(response, null);
    } catch (e) {
      print('❌ Error leaving group: $e');
      return ApiResponse<dynamic>(
        status: 'error',
        message: e.toString(),
        data: null,
      );
    }
  }

  // Make member an admin
  static Future<ApiResponse<dynamic>> makeMemberAdmin({
    required int groupId,
    required int userId,
  }) async {
    try {
      print('👑 Making user $userId admin of group $groupId');

      final response = await ApiService.post(
        'study-groups/$groupId/toggle-admin/$userId',
        {"student_id": userId},
      );

      print('✅ Make admin response: $response');

      return ApiResponse<dynamic>.fromJson(response, null);
    } catch (e) {
      print('❌ Error making member admin: $e');
      return ApiResponse<dynamic>(
        status: 'error',
        message: e.toString(),
        data: null,
      );
    }
  }

  // Add this method to your GroupManagementService class
  static Future<ApiResponse<dynamic>> addMemberToGroup({
    required int groupId,
    required int userId,
  }) async {
    try {
      print('👥 Adding user $userId to group $groupId');

      final response = await ApiService.post(
        'study-groups/$groupId/add-member',
        {'student_id': userId},
      );

      print('✅ Add member response: $response');

      return ApiResponse<dynamic>.fromJson(response, null);
    } catch (e) {
      print('❌ Error adding member: $e');
      return ApiResponse<dynamic>(
        status: 'error',
        message: e.toString(),
        data: null,
      );
    }
  }
}
