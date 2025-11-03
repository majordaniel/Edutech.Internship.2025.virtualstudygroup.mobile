import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';

class FileDownloadService {
  static final FileDownloadService _instance = FileDownloadService._internal();
  factory FileDownloadService() => _instance;
  FileDownloadService._internal();

  // Download file and return local path

  Future<String?> downloadAndSaveFile({
    required String url,
    required String fileName,
    required String fileType,
    required int groupId, // Add groupId parameter
    Function(int, int)? onProgress,
  }) async {
    try {
      print('📥 Starting download: $fileName from $url for group $groupId');

      // Check storage permission
      if (!await _checkStoragePermission()) {
        throw Exception('Storage permission denied');
      }

      // Get downloads directory with group subfolder
      final Directory downloadsDir = await getApplicationDocumentsDirectory();
      final String savePath =
          '${downloadsDir.path}/EdifyApp/Group_$groupId/$fileName';

      // Create directory if it doesn't exist
      final File file = File(savePath);
      await file.parent.create(recursive: true);

      // Check if file already exists
      if (await file.exists()) {
        print('✅ File already exists: $savePath');
        return savePath;
      }

      // Download file
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Save file
        await file.writeAsBytes(response.bodyBytes);
        print('✅ File saved: $savePath');
        return savePath;
      } else {
        throw Exception('Failed to download file: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Download error: $e');
      rethrow;
    }
  }

  // Open file with external app
  Future<void> openFileWithExternalApp(String filePath) async {
    try {
      print('📂 Opening file: $filePath');

      final result = await OpenFilex.open(filePath);

      print('🔍 Open file result: ${result.type} - ${result.message}');

      switch (result.type) {
        case ResultType.done:
          print('✅ File opened successfully');
          break;
        case ResultType.noAppToOpen:
          throw Exception('No app available to open this file type');
        case ResultType.fileNotFound:
          throw Exception('File not found: $filePath');
        case ResultType.permissionDenied:
          throw Exception('Permission denied to open file');
        case ResultType.error:
          throw Exception('Error opening file: ${result.message}');
      }
    } catch (e) {
      print('❌ Error opening file: $e');
      rethrow;
    }
  }

  // Download and open file in one operation
  Future<void> downloadAndOpenFile({
    required String url,
    required String fileName,
    required String fileType,
    required int groupId, // Add this parameter
    required BuildContext context,
  }) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Downloading $fileName...'),
            ],
          ),
        ),
      );

      // Download file with groupId
      final String? localPath = await downloadAndSaveFile(
        url: url,
        fileName: fileName,
        fileType: fileType,
        groupId: groupId, // Pass groupId here
      );

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (localPath != null) {
        // Open file
        await openFileWithExternalApp(localPath);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Opening $fileName'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      _showError(context, 'Failed to open file: ${e.toString()}');
    }
  }

  // Check storage permission
  Future<bool> _checkStoragePermission() async {
    try {
      final status = await Permission.storage.status;

      if (status.isGranted) {
        return true;
      } else {
        final result = await Permission.storage.request();
        return result.isGranted;
      }
    } catch (e) {
      print('❌ Permission check error: $e');
      return false;
    }
  }

  // Show error dialog
  void _showError(BuildContext context, String message) {
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  // Get file extension from URL or filename
  String getFileExtension(String fileName) {
    try {
      return fileName.split('.').last.toLowerCase();
    } catch (e) {
      return 'unknown';
    }
  }

  // Check if file is supported image type
  bool isImageFile(String fileName) {
    final ext = getFileExtension(fileName);
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(ext);
  }

  // Check if file is supported video type
  bool isVideoFile(String fileName) {
    final ext = getFileExtension(fileName);
    return ['mp4', 'mov', 'avi', 'mkv', 'webm'].contains(ext);
  }

  // Check if file is supported audio type
  bool isAudioFile(String fileName) {
    final ext = getFileExtension(fileName);
    return ['mp3', 'wav', 'aac', 'ogg', 'm4a'].contains(ext);
  }

  // Check if file is document type
  bool isDocumentFile(String fileName) {
    final ext = getFileExtension(fileName);
    return [
      'pdf',
      'doc',
      'docx',
      'xls',
      'xlsx',
      'ppt',
      'pptx',
      'txt',
    ].contains(ext);
  }

  // Get file icon based on type
  IconData getFileIcon(String fileName) {
    if (isImageFile(fileName)) return Icons.image;
    if (isVideoFile(fileName)) return Icons.video_library;
    if (isAudioFile(fileName)) return Icons.audio_file;
    if (isDocumentFile(fileName)) {
      final ext = getFileExtension(fileName);
      if (ext == 'pdf') return Icons.picture_as_pdf;
      if (['doc', 'docx'].contains(ext)) return Icons.description;
      if (['xls', 'xlsx'].contains(ext)) return Icons.table_chart;
      if (['ppt', 'pptx'].contains(ext)) return Icons.slideshow;
    }
    return Icons.insert_drive_file;
  }
}
