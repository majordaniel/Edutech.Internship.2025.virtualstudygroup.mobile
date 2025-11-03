import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OfflineService {
  static final OfflineService _instance = OfflineService._internal();
  factory OfflineService() => _instance;
  OfflineService._internal();

  final Connectivity _connectivity = Connectivity();

  // Check if device has internet connection
  Future<bool> isDeviceOnline() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      final isOnline = connectivityResult != ConnectivityResult.none;
      print('📡 Connectivity: $connectivityResult - Online: $isOnline');
      return isOnline;
    } catch (e) {
      print('❌ Connectivity check error: $e');
      return false;
    }
  }

  // Listen to connectivity changes
  Stream<List<ConnectivityResult>> get connectivityStream {
    return _connectivity.onConnectivityChanged;
  }

  // Save data for offline use
  static Future<void> saveOfflineData(String key, String data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('offline_$key', data);
      print('💾 Saved offline data for key: $key');
    } catch (e) {
      print('❌ Error saving offline data: $e');
    }
  }

  // Get offline data
  static Future<String?> getOfflineData(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('offline_$key');
      print(
        '📁 Retrieved offline data for key: $key - ${data != null ? "EXISTS" : "NULL"}',
      );
      return data;
    } catch (e) {
      print('❌ Error getting offline data: $e');
      return null;
    }
  }

  // Check if we have offline data available
  static Future<bool> hasOfflineData(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasData = prefs.containsKey('offline_$key');
      print('🔍 Offline data check for $key: $hasData');
      return hasData;
    } catch (e) {
      print('❌ Error checking offline data: $e');
      return false;
    }
  }

  // Clear offline data
  static Future<void> clearOfflineData(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('offline_$key');
      print('🗑️ Cleared offline data for key: $key');
    } catch (e) {
      print('❌ Error clearing offline data: $e');
    }
  }

  // Get all offline keys
  static Future<List<String>> getOfflineKeys() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final allKeys = prefs.getKeys();
      final offlineKeys = allKeys
          .where((key) => key.startsWith('offline_'))
          .toList();
      print('🔑 Found ${offlineKeys.length} offline keys');
      return offlineKeys;
    } catch (e) {
      print('❌ Error getting offline keys: $e');
      return [];
    }
  }
}
