import 'package:edify_app/services/api_service.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/offline_service.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;
  bool _isOffline = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isOffline => _isOffline;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Add this method to clear errors
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // In your UserProvider, update the login method:
  Future<bool> login(String email, String password) async {
    try {
      _setLoading(true);
      _error = null;

      print('🔐 Attempting login for: $email');

      final response = await AuthService.login(email, password);

      if (response.isSuccess && response.data != null) {
        _user = response.data!.user;
        _isOffline = false; // We're online since login succeeded
        _error = null;

        print('✅ Login successful for: ${_user?.email}');
        notifyListeners();
        return true;
      } else {
        // Use the specific error message from AuthService
        _error = response.message;
        _isOffline = _checkIfOfflineError(response.message);

        print('❌ Login failed: ${response.message}');
        notifyListeners();
        return false;
      }
    } catch (e) {
      // This should rarely happen now with better error handling
      final errorMessage = _parseLoginError(e.toString());
      _error = errorMessage;
      _isOffline = _checkIfOfflineError(errorMessage);

      print('💥 Login exception: $e');
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Add these helper methods to UserProvider:
  String _parseLoginError(String error) {
    final errorLower = error.toLowerCase();

    if (errorLower.contains('incorrect password')) {
      return 'Incorrect password. Please try again.';
    } else if (errorLower.contains('no account found') ||
        errorLower.contains('email not found')) {
      return 'No account found with this email address.';
    } else if (errorLower.contains('no internet') ||
        errorLower.contains('network')) {
      return 'No internet connection. Please check your network.';
    } else if (errorLower.contains('server') ||
        errorLower.contains('unavailable')) {
      return 'Server is temporarily unavailable. Please try again later.';
    }

    return error.replaceFirst('Exception: ', '');
  }

  bool _checkIfOfflineError(String error) {
    final errorLower = error.toLowerCase();
    return errorLower.contains('no internet') ||
        errorLower.contains('network') ||
        errorLower.contains('offline');
  }

  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await AuthService.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
      );

      if (response.isSuccess) {
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

  // In your UserProvider class
  Future<void> logout() async {
    try {
      print('🌐 Calling logout API...');

      // Clear state first
      _user = null;
      _isOffline = false;
      _error = null;

      // Call API logout if online
      if (!_isOffline) {
        try {
          await AuthService.logout();
        } catch (e) {
          print('⚠️ API logout failed, but continuing: $e');
        }
      }

      // Clear local storage
      await ApiService.removeToken();

      // Notify listeners
      notifyListeners();

      print('✅ Logout completed successfully');
    } catch (e) {
      print('❌ Logout error: $e');
      // Even if logout fails, clear local data
      await ApiService.removeToken();
      _user = null;
      _isOffline = false;
      notifyListeners();
      rethrow;
    }
  }

  // Update initialize to work offline
  Future<void> initialize() async {
    print('🔄 UserProvider initializing...');

    // Check connectivity
    final offlineService = OfflineService();
    _isOffline = !(await offlineService.isDeviceOnline());

    if (_isOffline) {
      print('📴 Initializing in offline mode');
    } else {
      print('📱 Initializing in online mode');
    }

    await AuthService.debugTokenStatus();

    final isLoggedIn = await AuthService.isLoggedIn();
    print('📊 Login status: $isLoggedIn');

    if (isLoggedIn) {
      _user = await AuthService.getCurrentUser();
      print('✅ User loaded: ${_user?.email}');
    } else {
      print('❌ No user logged in');
    }

    notifyListeners();
  }

  // Add method to check connectivity
  Future<void> checkConnectivity() async {
    try {
      final offlineService = OfflineService();
      final wasOffline = _isOffline;
      _isOffline = !(await offlineService.isDeviceOnline());

      if (wasOffline != _isOffline) {
        print(_isOffline ? '📴 Went offline' : '📱 Back online');
        notifyListeners();
      }
    } catch (e) {
      print('❌ Error checking connectivity: $e');
    }
  }
}
