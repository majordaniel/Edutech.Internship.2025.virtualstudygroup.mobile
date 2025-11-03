// join_request_service.dart - CORRECTED
import 'api_service.dart';
import '../models/join_request_model.dart';
import '../models/api_response.dart';

class JoinRequestService {
  // Get all notifications and filter for join requests
  static Future<ApiResponse<List<JoinRequest>>>
  getJoinRequestNotifications() async {
    try {
      // print('🔔 Fetching notifications...');
      final response = await ApiService.get('notifications');

      // print('📡 Notifications response: $response');

      List<JoinRequest> joinRequests = [];

      if (response is Map<String, dynamic>) {
        final data = response['data'];
        if (data is List) {
          joinRequests = _parseNotificationsFromList(data);
        } else {
          // print('❌ Notifications data is not a List: ${data.runtimeType}');
          // Try direct parsing if data is not in expected format
          joinRequests = _tryDirectParsing(response);
        }
      } else if (response is List) {
        // Handle case where response is directly a list
        joinRequests = _parseNotificationsFromList(response);
      } else {
        // print('❌ Unexpected notifications response format');
      }

      // print(
      //   '✅ Successfully parsed ${joinRequests.length} join request notifications',
      // );
      return ApiResponse<List<JoinRequest>>(
        status: 'success',
        message: '',
        data: joinRequests,
      );
    } catch (e) {
      // print('❌ Error fetching notifications: $e');
      return ApiResponse<List<JoinRequest>>(
        status: 'error',
        message: e.toString(),
        data: [],
      );
    }
  }

  static List<JoinRequest> _parseNotificationsFromList(
    List<dynamic> notifications,
  ) {
    return notifications
        .where((notification) {
          final type = notification['type']?.toString() ?? '';
          final data = notification['data'] ?? {};

          // More flexible detection of join requests
          final isJoinRequest =
              type.toLowerCase().contains('join') ||
              type.toLowerCase().contains('request') ||
              type.toLowerCase().contains('group') ||
              data['request_id'] != null ||
              data['group_id'] != null ||
              (data is Map && data.containsKey('user_id'));

          if (isJoinRequest) {
            // print('🔔 Found join request notification: $type');
          }

          return isJoinRequest;
        })
        .map((notification) {
          try {
            return JoinRequest.fromJson(notification);
          } catch (e) {
            // print('❌ Error parsing notification: $e - Data: $notification');
            return null;
          }
        })
        .where((request) => request != null)
        .cast<JoinRequest>()
        .toList();
  }

  static List<JoinRequest> _tryDirectParsing(Map<String, dynamic> response) {
    final List<JoinRequest> requests = [];

    // Try to extract from different possible structures
    if (response.containsKey('notifications') &&
        response['notifications'] is List) {
      requests.addAll(_parseNotificationsFromList(response['notifications']));
    }

    if (response.containsKey('data') && response['data'] is Map) {
      try {
        final request = JoinRequest.fromJson(response['data']);
        requests.add(request);
      } catch (e) {
        // print('❌ Error parsing direct data: $e');
      }
    }

    return requests;
  }

  // CORRECTED: Approve request with the exact endpoint structure
  static Future<ApiResponse<dynamic>> approveRequest(
    JoinRequest request,
  ) async {
    try {
      // print('🎯 APPROVING REQUEST:');
      // print('   Request ID: ${request.requestId}');
      // print('   Group ID: ${request.groupId}');
      // print('   User: ${request.userName}');

      // Use the exact endpoint structure from your documentation
      final endpoint = 'study-groups/${request.requestId}/handle-request';

      // Use the exact payload structure from your documentation
      final payload = {'action': 'approve'};

      // print('🔄 Calling endpoint: $endpoint');
      // print('📤 Payload: $payload');

      final response = await ApiService.post(endpoint, payload);

      // print('📡 Approve Response: $response');

      // Mark notification as read
      await _markNotificationAsRead(request.notificationId);

      return ApiResponse<dynamic>.fromJson(response, null);
    } catch (e) {
      // print('❌ Error approving request: $e');

      // Check for specific error types
      String errorMessage = e.toString();

      if (errorMessage.contains('already been handled')) {
        errorMessage = 'This request has already been processed';
      } else if (errorMessage.contains('401') ||
          errorMessage.contains('unauthorized')) {
        errorMessage = 'You are not authorized to approve this request';
      } else if (errorMessage.contains('404') ||
          errorMessage.contains('not found')) {
        errorMessage = 'Request or group not found';
      }

      // Mark notification as read even if there's an error
      try {
        await _markNotificationAsRead(request.notificationId);
      } catch (markError) {
        // print('⚠️ Failed to mark notification as read: $markError');
      }

      return ApiResponse<dynamic>(
        status: 'error',
        message: errorMessage,
        data: null,
      );
    }
  }

  // CORRECTED: Reject request with the exact endpoint structure
  static Future<ApiResponse<dynamic>> rejectRequest(JoinRequest request) async {
    try {
      // print('🎯 REJECTING REQUEST:');
      // print('   Request ID: ${request.requestId}');
      // print('   Group ID: ${request.groupId}');
      // print('   User: ${request.userName}');

      // Use the exact endpoint structure from your documentation
      final endpoint = 'study-groups/${request.groupId}/handle-request';

      // Use the exact payload structure from your documentation
      final payload = {'action': 'reject'};

      // print('🔄 Calling endpoint: $endpoint');
      // print('📤 Payload: $payload');

      final response = await ApiService.post(endpoint, payload);

      // print('📡 Reject Response: $response');

      // Mark notification as read
      await _markNotificationAsRead(request.notificationId);

      return ApiResponse<dynamic>.fromJson(response, null);
    } catch (e) {
      // print('❌ Error rejecting request: $e');

      // Check for specific error types
      final errorMessage = e.toString();

      if (errorMessage.contains('already been handled') ||
          errorMessage.contains('already processed')) {
        // print('✅ Request was already processed - returning status info');
      }
      try {
        await _markNotificationAsRead(request.notificationId);
      } catch (markError) {
        // print('⚠️ Notification already marked as read - this is fine');
      }

      return ApiResponse<dynamic>(
        status: 'success',
        message:
            'already_processed', // Special message to indicate already processed
        data: {
          'previous_status': 'rejected',
        }, // Indicate it was already rejected
      );
    }
  }

  // DEBUG: Test the endpoint directly
  static Future<void> debugApproveRequest(JoinRequest request) async {
    try {
      // print('🐛 DEBUG: Testing approve endpoint directly');
      // print('   Endpoint: study-groups/${request.groupId}/handle-request');
      // print('   Payload: {"action": "approve"}');

      final response = await ApiService.post(
        'study-groups/${request.groupId}/handle-request',
        {'action': 'approve'},
      );

      // print('🐛 DEBUG Response: $response');
    } catch (e) {
      // print('🐛 DEBUG Error: $e');
    }
  }

  static Future<void> _markNotificationAsRead(String notificationId) async {
    try {
      await ApiService.post('notifications/$notificationId/mark-as-read', {});
      // print('✅ Marked notification $notificationId as read');
    } catch (e) {
      // print('⚠️ Failed to mark notification as read: $e');
    }
  }

  static Future<void> markAllAsRead() async {
    try {
      await ApiService.post('notifications/mark-all-as-read', {});
      // print('✅ Marked all notifications as read');
    } catch (e) {
      // print('⚠️ Failed to mark all notifications as read: $e');
    }
  }
}
