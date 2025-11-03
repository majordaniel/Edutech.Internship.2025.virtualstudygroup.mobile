class ApiResponse<T> {
  final String status;
  final String message;
  final T? data;

  ApiResponse({required this.status, required this.message, this.data});

  factory ApiResponse.fromJson(dynamic json, T Function(dynamic)? fromJson) {
    print('🔧 ApiResponse.fromJson called with type: ${json.runtimeType}');

    // Handle case where API returns a raw list directly (like your users endpoint)
    if (json is List) {
      print('📦 API returned raw list with ${json.length} items');
      if (fromJson != null) {
        try {
          final convertedData = fromJson(json);
          return ApiResponse<T>(
            status: 'success',
            message: '',
            data: convertedData,
          );
        } catch (e) {
          print('❌ Error converting raw list: $e');
          return ApiResponse<T>(
            status: 'error',
            message: 'Failed to convert data: $e',
            data: null,
          );
        }
      } else {
        return ApiResponse<T>(
          status: 'success',
          message: '',
          data: json as T?, // Direct assignment
        );
      }
    }

    // Handle case where API returns a Map (proper API response)
    if (json is Map<String, dynamic>) {
      final status = json['status']?.toString() ?? 'success';
      final message = json['message']?.toString() ?? '';
      final data = json['data'];

      T? convertedData;
      if (fromJson != null && data != null) {
        try {
          convertedData = fromJson(data);
        } catch (e) {
          print('❌ Error converting data: $e');
        }
      } else {
        convertedData = data as T?;
      }

      return ApiResponse<T>(
        status: status,
        message: message,
        data: convertedData,
      );
    }

    // Handle unexpected response type
    print('⚠️ Unexpected API response type: ${json.runtimeType}');
    return ApiResponse<T>(
      status: 'error',
      message: 'Unexpected response format: ${json.runtimeType}',
      data: null,
    );
  }

  bool get isSuccess => status == 'success';
}
