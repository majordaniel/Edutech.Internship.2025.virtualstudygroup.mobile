import 'api_service.dart';
import '../models/user_model.dart';
import '../models/api_response.dart';

class UserService {
  // Get all users (for participant selection)
  static Future<ApiResponse<List<User>>> getUsers() async {
    final response = await ApiService.get('users');
    return ApiResponse<List<User>>.fromJson(
      response,
      (data) => (data as List).map((user) => User.fromJson(user)).toList(),
    );
  }

  // Search users by name or email - Use the search group members endpoint
  static Future<ApiResponse<List<User>>> searchUsers(String query) async {
    // Since there's no general user search, get all users and filter client-side
    final allUsersResponse = await getUsers();

    if (allUsersResponse.isSuccess && allUsersResponse.data != null) {
      // Filter users client-side
      final filteredUsers = allUsersResponse.data!.where((user) {
        final fullName = '${user.firstName} ${user.lastName}'.toLowerCase();
        final email = user.email.toLowerCase();
        final searchTerm = query.toLowerCase();

        return fullName.contains(searchTerm) || email.contains(searchTerm);
      }).toList();

      return ApiResponse<List<User>>(
        status: 'success',
        message: '',
        data: filteredUsers,
      );
    } else {
      return ApiResponse<List<User>>(
        status: 'error',
        message: allUsersResponse.message,
        data: [],
      );
    }
  }

  // Add participants to group
}
