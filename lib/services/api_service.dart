import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'https://ediifyapi.tife.com.ng/api';
  static const String corsProxy = 'https://corsproxy.io/?';
  static String? _authToken;

  // Public getter for auth token
  static String? get authToken => _authToken;

  static String get _effectiveBaseUrl {
    if (kIsWeb) {
      return '$corsProxy${Uri.encodeComponent(baseUrl)}';
    }
    return baseUrl;
  }

  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token');
    print(
      '🔐 ApiService initialized - Token: ${_authToken != null ? "EXISTS" : "NULL"}',
    );
  }

  static Future<Map<String, String>> getHeaders() async {
    return await _headers;
  }

  static Future<Map<String, String>> get _headers async {
    // Refresh token from storage in case it was updated
    if (_authToken == null) {
      await initialize();
    }

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Requested-With': 'XMLHttpRequest',
    };

    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
      print('🔐 Adding Bearer token to request');
    } else {
      print('⚠️ No auth token available for API request');
    }

    return headers;
  }

  static Future<dynamic> post(String endpoint, dynamic data) async {
    try {
      final url = '$_effectiveBaseUrl/$endpoint';
      print('🌐 API Call: POST $url');

      final response = await http
          .post(
            Uri.parse(url),
            headers: await _headers,
            body: json.encode(data),
          )
          .timeout(const Duration(seconds: 30));

      print('✅ API Response: ${response.statusCode}');
      return _handleResponse(response);
    } on SocketException {
      throw Exception('No internet connection');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<dynamic> get(String endpoint) async {
    try {
      final url = '$_effectiveBaseUrl/$endpoint';
      print('🌐 API Call: GET $url');

      final response = await http
          .get(Uri.parse(url), headers: await _headers)
          .timeout(const Duration(seconds: 30));

      print('✅ API Response: ${response.statusCode}');
      return _handleResponse(response);
    } on SocketException {
      throw Exception('No internet connection');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // In ApiService, update the _handleResponse method:
  static dynamic _handleResponse(http.Response response) {
    final responseBody = json.decode(response.body);
    final statusCode = response.statusCode;

    print('🔍 API Response Analysis:');
    print('   - Status Code: $statusCode');
    print('   - Response Body: $responseBody');

    switch (statusCode) {
      case 200:
      case 201:
        return responseBody;

      case 400:
        final message = responseBody['message'] ?? 'Bad request';
        final errors = responseBody['errors'];

        if (errors != null && errors is Map) {
          // Handle validation errors from Laravel
          final errorMessages = <String>[];
          errors.forEach((key, value) {
            if (value is List) {
              errorMessages.addAll(value.cast<String>());
            } else if (value is String) {
              errorMessages.add(value);
            }
          });

          if (errorMessages.isNotEmpty) {
            throw Exception(errorMessages.join(', '));
          }
        }

        throw Exception(message);

      case 401:
        final message = responseBody['message'] ?? 'Invalid credentials';

        // More specific 401 errors
        if (message.toLowerCase().contains('invalid credentials') ||
            message.toLowerCase().contains('incorrect password') ||
            message.toLowerCase().contains('password mismatch')) {
          throw Exception('Incorrect password. Please try again.');
        } else if (message.toLowerCase().contains('user not found') ||
            message.toLowerCase().contains('email not found')) {
          throw Exception('No account found with this email address.');
        } else {
          throw Exception('Invalid email or password. Please try again.');
        }

      case 403:
        throw Exception('Access denied. Please contact support.');

      case 404:
        throw Exception('Service not found. Please try again later.');

      case 422: // Laravel validation errors
        final errors = responseBody['errors'];
        if (errors != null && errors is Map) {
          final errorMessages = <String>[];
          errors.forEach((key, value) {
            if (value is List) {
              errorMessages.addAll(value.cast<String>());
            } else if (value is String) {
              errorMessages.add(value);
            }
          });

          if (errorMessages.isNotEmpty) {
            throw Exception(errorMessages.join(', '));
          }
        }
        throw Exception(responseBody['message'] ?? 'Validation failed');

      case 429:
        throw Exception(
          'Too many login attempts. Please try again in a few minutes.',
        );

      case 500:
        throw Exception('Server error. Please try again later.');

      case 502:
      case 503:
      case 504:
        throw Exception(
          'Service temporarily unavailable. Please try again later.',
        );

      default:
        throw Exception(
          'Network error (${response.statusCode}). Please try again.',
        );
    }
  }

  static Future<void> saveToken(String token) async {
    _authToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    print('💾 Token saved to storage');
  }

  static Future<void> removeToken() async {
    _authToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
    print('🗑️ Token removed from storage');
  }

  // Add this method to your existing ApiService class
  static Future<dynamic> put(String endpoint, dynamic data) async {
    try {
      final url = '$_effectiveBaseUrl/$endpoint';
      print('🌐 API Call: PUT $url');

      final response = await http
          .put(Uri.parse(url), headers: await _headers, body: json.encode(data))
          .timeout(const Duration(seconds: 30));

      print('✅ API Response: ${response.statusCode}');
      return _handleResponse(response);
    } on SocketException {
      throw Exception('No internet connection');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<dynamic> delete(String endpoint) async {
    try {
      final url = '$_effectiveBaseUrl/$endpoint';
      print('🌐 API Call: DELETE $url');

      final response = await http
          .delete(Uri.parse(url), headers: await _headers)
          .timeout(const Duration(seconds: 30));

      print('✅ API Response: ${response.statusCode}');
      return _handleResponse(response);
    } on SocketException {
      throw Exception('No internet connection');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<dynamic> postWithoutBody(String endpoint) async {
    try {
      final url = '$_effectiveBaseUrl/$endpoint';
      print('🌐 API Call: POST $url (no body)');

      final response = await http.post(Uri.parse(url), headers: await _headers);

      print('✅ API Response: ${response.statusCode}');
      return _handleResponse(response);
    } on SocketException {
      throw Exception('No internet connection');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Add this public debug method
  static Future<void> debugTokenStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final storedToken = prefs.getString('auth_token');

    print('🔍 ApiService Token Debug:');
    print(
      '   - Stored token: ${storedToken != null ? "EXISTS (${storedToken.length} chars)" : "NULL"}',
    );
    print(
      '   - Memory token: ${_authToken != null ? "EXISTS (${_authToken!.length} chars)" : "NULL"}',
    );
    print('   - Both match: ${storedToken == _authToken}');
  }
}
