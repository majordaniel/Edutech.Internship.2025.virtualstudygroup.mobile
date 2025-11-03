// services/course_service.dart
import 'dart:convert';
import 'package:edify_app/models/api_response.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/course_model.dart';
import 'api_service.dart';

class CourseService {
  static Future<ApiResponse<List<Course>>> getCourses() async {
    try {
      print('📚 Fetching courses from API...');

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        print('❌ No auth token found');
        return ApiResponse(
          status: 'error',
          message: 'Not authenticated',
          data: null,
        );
      }

      // FIXED: Use the correct endpoint
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/study-groups/getcourses'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📡 Course API Response: ${response.statusCode}');
      print('📡 Course API Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        print('📦 Course API JSON: $jsonResponse');

        // Handle different response formats
        List<Course> courses = [];

        if (jsonResponse is List) {
          // If API returns raw list
          courses = jsonResponse
              .map((courseJson) => Course.fromJson(courseJson))
              .toList();
        } else if (jsonResponse['data'] is List) {
          // If API returns {status, message, data} format
          courses = (jsonResponse['data'] as List)
              .map((courseJson) => Course.fromJson(courseJson))
              .toList();
        } else if (jsonResponse['courses'] is List) {
          // If API returns {courses: []} format
          courses = (jsonResponse['courses'] as List)
              .map((courseJson) => Course.fromJson(courseJson))
              .toList();
        }

        print('✅ Loaded ${courses.length} courses');
        return ApiResponse(
          status: 'success',
          message: 'Courses loaded successfully',
          data: courses,
        );
      } else {
        print('❌ Course API error: ${response.statusCode}');
        return ApiResponse(
          status: 'error',
          message: 'Failed to load courses: ${response.statusCode}',
          data: null,
        );
      }
    } catch (e) {
      print('❌ Course service error: $e');
      return ApiResponse(
        status: 'error',
        message: 'Error loading courses: $e',
        data: null,
      );
    }
  }

  static Future<void> debugApiResponse() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      print('🔑 Auth token: ${token != null ? "Exists" : "NULL"}');

      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/courses'), // Adjust your endpoint
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('🐛 DEBUG Course API:');
      print('   Status: ${response.statusCode}');
      print('   Body: ${response.body}');
    } catch (e) {
      print('🐛 DEBUG Course API Error: $e');
    }
  }
}
