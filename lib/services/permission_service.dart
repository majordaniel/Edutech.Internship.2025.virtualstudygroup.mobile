import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  // Check current permission status
  static Future<Map<String, bool>> checkCallPermissions(
    bool isVideoCall,
  ) async {
    final micStatus = await Permission.microphone.status;
    final cameraStatus = isVideoCall
        ? await Permission.camera.status
        : PermissionStatus.granted;

    return {
      'microphone': micStatus.isGranted,
      'camera': cameraStatus.isGranted,
    };
  }

  // Request permissions with proper handling
  static Future<Map<String, bool>> requestCallPermissions(
    bool isVideoCall,
  ) async {
    try {
      print('🔐 Requesting call permissions...');

      // Request microphone
      final micStatus = await Permission.microphone.request();
      print('🎤 Microphone status: $micStatus');

      // Request camera only for video calls
      PermissionStatus cameraStatus = PermissionStatus.granted;
      if (isVideoCall) {
        cameraStatus = await Permission.camera.request();
        print('📷 Camera status: $cameraStatus');
      }

      final result = {
        'microphone': micStatus.isGranted,
        'camera': cameraStatus.isGranted,
        'microphonePermanentlyDenied': micStatus.isPermanentlyDenied,
        'cameraPermanentlyDenied': isVideoCall
            ? cameraStatus.isPermanentlyDenied
            : false,
      };

      print('✅ Permission results: $result');
      return result;
    } catch (e) {
      print('❌ Permission request error: $e');
      return {
        'microphone': false,
        'camera': false,
        'microphonePermanentlyDenied': false,
        'cameraPermanentlyDenied': false,
      };
    }
  }

  // Check if we should show rationale
  static Future<bool> shouldShowRationale(Permission permission) async {
    final status = await permission.status;
    return status.isDenied;
  }

  // Open app settings
  static Future<void> openAppSettings() async {
    await openAppSettings();
  }

  // Check if permissions are permanently denied
  static Future<Map<String, bool>> checkPermanentDenials(
    bool isVideoCall,
  ) async {
    final micStatus = await Permission.microphone.status;
    final cameraStatus = isVideoCall
        ? await Permission.camera.status
        : PermissionStatus.granted;

    return {
      'microphone': micStatus.isPermanentlyDenied,
      'camera': cameraStatus.isPermanentlyDenied,
    };
  }
}
