import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import '../models/user_model.dart';
import '../models/api_response.dart';
import 'offline_service.dart';

class AuthService {
  static final OfflineService _offlineService = OfflineService();

  // In AuthService, update the login method:
  static Future<ApiResponse<LoginResponseData>> login(
    String email,
    String password,
  ) async {
    // Check connectivity first
    final isOnline = await _offlineService.isDeviceOnline();

    if (!isOnline) {
      print('📴 Device is offline - checking for cached login');
      return _attemptOfflineLogin(email);
    }

    // Online login logic
    try {
      final response = await ApiService.post('auth/login', {
        'email': email,
        'password': password,
      });

      print('✅ LOGIN RESPONSE: ${response}');

      final apiResponse = ApiResponse<LoginResponseData>.fromJson(
        response,
        (data) => LoginResponseData.fromJson(data),
      );

      if (apiResponse.isSuccess) {
        print('✅ LOGIN SUCCESS - Token: ${apiResponse.data!.token}');
        await ApiService.saveToken(apiResponse.data!.token);
        await _saveUserData(apiResponse.data!.user);

        // Cache login data for offline use
        await _cacheLoginData(email, apiResponse.data!);

        await debugTokenStatus();
      } else {
        print('❌ LOGIN FAILED: ${apiResponse.message}');
      }

      return apiResponse;
    } catch (e) {
      print('❌ LOGIN EXCEPTION: $e');

      // Enhanced error analysis
      final errorMessage = _analyzeLoginError(e, email);

      // If it's a network error, try offline login
      if (_isNetworkError(e)) {
        return _attemptOfflineLogin(email);
      }

      // Return the analyzed error
      return ApiResponse<LoginResponseData>(
        status: 'error',
        message: errorMessage,
        data: null,
      );
    }
  }

  // Add these helper methods to AuthService:
  static String _analyzeLoginError(dynamic error, String email) {
    final errorString = error.toString().toLowerCase();

    print('🔍 Analyzing login error: $errorString');

    // Network-related errors
    if (errorString.contains('socket') ||
        errorString.contains('connection') ||
        errorString.contains('network') ||
        errorString.contains('timed out')) {
      return 'No internet connection. Please check your network and try again.';
    }

    // Password-related errors
    if (errorString.contains('password') &&
        (errorString.contains('incorrect') ||
            errorString.contains('invalid') ||
            errorString.contains('mismatch'))) {
      return 'Incorrect password. Please try again.';
    }

    // Email-related errors
    if (errorString.contains('email') &&
        (errorString.contains('not found') ||
            errorString.contains('invalid') ||
            errorString.contains('not exist'))) {
      return 'No account found with this email address. Please check your email or sign up.';
    }

    // Account-related errors
    if (errorString.contains('account') ||
        errorString.contains('user') && errorString.contains('exist')) {
      return 'Account not found. Please check your email or sign up for a new account.';
    }

    // Server-related errors
    if (errorString.contains('server') ||
        errorString.contains('500') ||
        errorString.contains('internal')) {
      return 'Server is temporarily unavailable. Please try again in a few minutes.';
    }

    // Rate limiting
    if (errorString.contains('too many') ||
        errorString.contains('rate limit') ||
        errorString.contains('429')) {
      return 'Too many login attempts. Please wait a few minutes and try again.';
    }

    // Default error message
    return 'Login failed: ${error.toString().replaceFirst('Exception: ', '')}';
  }

  static bool _isNetworkError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('socket') ||
        errorString.contains('connection') ||
        errorString.contains('network') ||
        errorString.contains('timed out');
  }

  // Offline login attempt
  static Future<ApiResponse<LoginResponseData>> _attemptOfflineLogin(
    String email,
  ) async {
    print('📴 Attempting offline login for: $email');

    final cachedData = await OfflineService.getOfflineData('last_login_$email');

    if (cachedData != null) {
      try {
        final jsonData = json.decode(cachedData);
        final loginData = LoginResponseData.fromJson(jsonData);

        // Restore token and user data
        await ApiService.saveToken(loginData.token);
        await _saveUserData(loginData.user);

        print('✅ Offline login successful');
        return ApiResponse<LoginResponseData>(
          status: 'success',
          message: 'Logged in offline with cached credentials',
          data: loginData,
        );
      } catch (e) {
        print('❌ Offline login failed: $e');
      }
    }

    return ApiResponse<LoginResponseData>(
      status: 'error',
      message:
          'No internet connection and no cached login available. Please connect to internet and login first.',
      data: null,
    );
  }

  // Cache login data for offline use
  static Future<void> _cacheLoginData(
    String email,
    LoginResponseData loginData,
  ) async {
    try {
      await OfflineService.saveOfflineData(
        'last_login_$email',
        json.encode(loginData.toJson()),
      );
      print('💾 Cached login data for offline use');
    } catch (e) {
      print('❌ Failed to cache login data: $e');
    }
  }

  static Future<ApiResponse<dynamic>> logout() async {
    final response = await ApiService.post('logout', {});
    await ApiService.removeToken();
    return ApiResponse<dynamic>.fromJson(response, null);
  }

  static Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('user_data');

      if (userData != null) {
        return User.fromJson(json.decode(userData));
      }
      return null;
    } catch (e) {
      print('❌ Error getting current user: $e');
      return null;
    }
  }

  static Future<bool> isLoggedIn() async {
    try {
      await ApiService.initialize();
      final prefs = await SharedPreferences.getInstance();
      final hasToken = prefs.containsKey('auth_token');
      final token = prefs.getString('auth_token');

      print('🔐 AuthService.isLoggedIn():');
      print('   - Has token in storage: $hasToken');
      print('   - Token length: ${token?.length ?? 0}');

      return hasToken && token != null && token.isNotEmpty;
    } catch (e) {
      print('❌ Error in isLoggedIn: $e');
      return false;
    }
  }

  static Future<void> _saveUserData(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', json.encode(user.toJson()));
      print('💾 User data saved to storage');
    } catch (e) {
      print('❌ Error saving user data: $e');
    }
  }

  // Update debug method to use public access
  static Future<void> debugTokenStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final userData = prefs.getString('user_data');

      print('🔍 AUTH SERVICE DEBUG:');
      print('   - Auth token in storage: ${token != null ? "EXISTS" : "NULL"}');
      print(
        '   - User data in storage: ${userData != null ? "EXISTS" : "NULL"}',
      );
      print(
        '   - ApiService.authToken: ${ApiService.authToken != null ? "SET" : "NULL"}',
      );
    } catch (e) {
      print('❌ Error in debugTokenStatus: $e');
    }
  }

  static Future<bool> testApiConnection() async {
    try {
      print('🔌 Testing API connection...');
      final response = await http
          .get(
            Uri.parse('https://ediifyapi.tife.com.ng/api/'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      print('📡 API Connection Test: Status ${response.statusCode}');

      // Consider it connected if we get any response (even 404, 500, etc.)
      // because it means the server is reachable
      final isConnected = response.statusCode < 500;
      print('📡 Server reachable: $isConnected');

      return isConnected;
    } catch (e) {
      print('❌ API Connection Test FAILED: $e');
      return false;
    }
  }

  // services/auth_service.dart - Add this method
  static Future<ApiResponse<dynamic>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    try {
      print('📝 Starting registration for: $email');

      final response = await ApiService.post('auth/register', {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'password': password,
        'password_confirmation': password,
      });

      print('📡 Registration response: $response');

      return ApiResponse<dynamic>.fromJson(response, null);
    } catch (e) {
      print('❌ Registration error: $e');
      return ApiResponse<dynamic>(
        status: 'error',
        message: e.toString(),
        data: null,
      );
    }
  }
}

class LoginResponseData {
  final String message;
  final User user;
  final String token;

  LoginResponseData({
    required this.message,
    required this.user,
    required this.token,
  });

  factory LoginResponseData.fromJson(Map<String, dynamic> json) {
    return LoginResponseData(
      message: json['message'],
      user: User.fromJson(json['user']),
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'message': message, 'user': user.toJson(), 'token': token};
  }
}
