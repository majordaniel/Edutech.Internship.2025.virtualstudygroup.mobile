import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:edify_app/models/chat_message.dart';

class FileManagerService {
  static final FileManagerService _instance = FileManagerService._internal();
  factory FileManagerService() => _instance;
  FileManagerService._internal();

  // Get all downloaded files for a specific group
  Future<List<File>> getGroupFiles(int groupId) async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();

      // Check new organized structure first
      final String groupPath = '${appDir.path}/EdifyApp/Group_$groupId';
      final Directory groupDir = Directory(groupPath);

      List<File> files = [];

      if (await groupDir.exists()) {
        // Get files from organized group folder
        final List<FileSystemEntity> entities = await groupDir.list().toList();
        for (final entity in entities) {
          if (entity is File) {
            files.add(entity);
          }
        }
      }

      // Also check old unorganized structure for backward compatibility
      final String oldPath = '${appDir.path}/EdifyApp';
      final Directory oldDir = Directory(oldPath);

      if (await oldDir.exists()) {
        final List<FileSystemEntity> oldEntities = await oldDir.list().toList();
        for (final entity in oldEntities) {
          if (entity is File) {
            // You might want to add some logic to determine if this file
            // belongs to the current group (maybe by filename pattern)
            files.add(entity as File);
          }
        }
      }

      // Sort by modification time (newest first)
      files.sort(
        (a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()),
      );

      return files;
    } catch (e) {
      print('❌ Error getting group files: $e');
      return [];
    }
  }

  // Get all media files (images, videos) for a group
  Future<List<File>> getGroupMedia(int groupId) async {
    final allFiles = await getGroupFiles(groupId);
    final mediaFiles = <File>[];

    for (final file in allFiles) {
      final fileName = file.path.split('/').last.toLowerCase();
      if (_isMediaFile(fileName)) {
        mediaFiles.add(file);
      }
    }

    return mediaFiles;
  }

  // Get all document files for a group
  Future<List<File>> getGroupDocuments(int groupId) async {
    final allFiles = await getGroupFiles(groupId);
    final documentFiles = <File>[];

    for (final file in allFiles) {
      final fileName = file.path.split('/').last.toLowerCase();
      if (_isDocumentFile(fileName)) {
        documentFiles.add(file);
      }
    }

    return documentFiles;
  }

  // Check if file is media
  bool _isMediaFile(String fileName) {
    final imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'];
    final videoExtensions = ['mp4', 'mov', 'avi', 'mkv', 'webm'];
    final ext = fileName.split('.').last.toLowerCase();
    return imageExtensions.contains(ext) || videoExtensions.contains(ext);
  }

  // Check if file is document
  bool _isDocumentFile(String fileName) {
    final documentExtensions = [
      'pdf',
      'doc',
      'docx',
      'xls',
      'xlsx',
      'ppt',
      'pptx',
      'txt',
    ];
    final ext = fileName.split('.').last.toLowerCase();
    return documentExtensions.contains(ext);
  }

  // Get file type
  String getFileType(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();

    if (['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(ext)) {
      return 'image';
    } else if (['mp4', 'mov', 'avi', 'mkv', 'webm'].contains(ext)) {
      return 'video';
    } else if (['pdf'].contains(ext)) {
      return 'pdf';
    } else if (['doc', 'docx'].contains(ext)) {
      return 'word';
    } else if (['xls', 'xlsx'].contains(ext)) {
      return 'excel';
    } else if (['ppt', 'pptx'].contains(ext)) {
      return 'powerpoint';
    } else {
      return 'document';
    }
  }

  // Format file size
  String formatFileSize(int bytes) {
    const units = ['B', 'KB', 'MB', 'GB'];
    var size = bytes.toDouble();
    var unitIndex = 0;

    while (size > 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }

    return '${size.toStringAsFixed(1)} ${units[unitIndex]}';
  }

  // Get file icon
  String getFileIcon(String fileName) {
    final type = getFileType(fileName);
    switch (type) {
      case 'image':
        return '🖼️';
      case 'video':
        return '🎥';
      case 'pdf':
        return '📄';
      case 'word':
        return '📝';
      case 'excel':
        return '📊';
      case 'powerpoint':
        return '📑';
      default:
        return '📎';
    }
  }

  // Delete a file
  Future<bool> deleteFile(File file) async {
    try {
      await file.delete();
      return true;
    } catch (e) {
      print('❌ Error deleting file: $e');
      return false;
    }
  }

  // Get total storage used by group files
  Future<int> getGroupStorageUsage(int groupId) async {
    final files = await getGroupFiles(groupId);
    int totalSize = 0;

    for (final file in files) {
      try {
        totalSize += await file.length();
      } catch (e) {
        print('❌ Error getting file size: $e');
      }
    }

    return totalSize;
  }
}
