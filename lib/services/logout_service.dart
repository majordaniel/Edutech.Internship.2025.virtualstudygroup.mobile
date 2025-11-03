// logout_service.dart
// ignore_for_file: unused_local_variable

import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class LogoutService {
  static Future<void> performLogout() async {
    try {
      print('🚪 Starting logout process...');

      // Option 1: Try with empty body (some APIs expect this)
      print('🔄 Attempting logout with empty body...');
      // In LogoutService.performLogout()
      final response = await ApiService.postWithoutBody('auth/logout');
      print('✅ Logout API response: $response');
    } catch (e) {
      print('⚠️ Logout with empty body failed: $e');

      // Option 2: Try with null body
      try {
        print('🔄 Attempting logout with null body...');
        final response = await ApiService.post('auth/logout', null);
        print('✅ Logout API response with null: $response');
      } catch (e2) {
        print('⚠️ Logout with null body also failed: $e2');

        // Option 3: Try without any body at all
        try {
          print('🔄 Attempting logout with no body...');
          final response = await _postWithoutBody('auth/logout');
          print('✅ Logout API response without body: $response');
        } catch (e3) {
          print('⚠️ All logout attempts failed: $e3');
          // We'll continue to clear local data anyway
        }
      }
    } finally {
      // Always clear local storage
      await _clearLocalData();
    }
  }

  // Helper method for POST without body
  static Future<dynamic> _postWithoutBody(String endpoint) async {
    // You might need to add this method to your ApiService
    // For now, we'll use a direct http call
    try {
      final headers = await ApiService.getHeaders();
      final url = '${ApiService.baseUrl}/$endpoint';

      print('🌐 Calling POST $url with no body');

      // Since we can't modify ApiService easily, we'll use a workaround
      // by sending an empty string instead of a map
      final response = await ApiService.post(endpoint, '');
      return response;
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> _clearLocalData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_data');
      print('✅ Local storage cleared');
    } catch (e) {
      print('❌ Error clearing local storage: $e');
      throw e;
    }
  }
}
