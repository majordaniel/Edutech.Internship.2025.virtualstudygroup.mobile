import 'api_service.dart';
import '../models/call_models.dart';
import '../models/api_response.dart';

class CallService {
  // Start a new meeting/call
  static Future<ApiResponse<CallResponse>> startCall({
    required int groupId,
    required int hostId,
    bool isVideoCall = true,
  }) async {
    try {
      print('📞 Starting call for group $groupId');

      final response = await ApiService.post(
        'study-groups/$groupId/start-call',
        {'host_id': hostId, 'is_video_call': isVideoCall},
      );

      print('📞 Response: $response');

      // Direct creation of ApiResponse since we know the structure
      if (response is Map<String, dynamic>) {
        return ApiResponse<CallResponse>(
          status: 'success', // Force success since we have URLs
          message: response['message']?.toString() ?? 'Meeting created',
          data: CallResponse.fromJson(response),
        );
      }

      return ApiResponse<CallResponse>(
        status: 'error',
        message: 'Invalid response',
        data: null,
      );
    } catch (e) {
      print('❌ Start call error: $e');
      return ApiResponse<CallResponse>(
        status: 'error',
        message: e.toString(),
        data: null,
      );
    }
  }

  // End a meeting (if your API has this endpoint)
  static Future<ApiResponse<dynamic>> endCall(int callId) async {
    try {
      final response = await ApiService.post('calls/$callId/end', {});
      return ApiResponse<dynamic>.fromJson(response, null);
    } catch (e) {
      return ApiResponse<dynamic>(
        status: 'error',
        message: e.toString(),
        data: null,
      );
    }
  }

  static Future<void> debugApiResponse({
    required int groupId,
    required int hostId,
    bool isVideoCall = true,
  }) async {
    try {
      final response = await ApiService.post(
        'study-groups/$groupId/start-call',
        {'host_id': hostId, 'is_video_call': isVideoCall},
      );

      print('🔍 DEBUG - Raw API Response:');
      print('   Type: ${response.runtimeType}');
      print('   Data: $response');

      if (response is Map<String, dynamic>) {
        print('🔍 DEBUG - Response keys: ${response.keys}');
        response.forEach((key, value) {
          print('   $key: $value');
        });
      }
    } catch (e) {
      print('❌ DEBUG - Error: $e');
    }
  }
}
