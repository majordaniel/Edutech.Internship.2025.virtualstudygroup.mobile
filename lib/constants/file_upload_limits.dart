// lib/constants/file_upload_limits.dart
import 'dart:math';

class FileUploadLimits {
  static const int maxImageSize = 10 * 1024 * 1024; // 10MB
  static const int maxAudioSize = 25 * 1024 * 1024; // 25MB
  static const int maxVideoSize = 100 * 1024 * 1024; // 100MB
  static const int maxDocumentSize = 50 * 1024 * 1024; // 50MB
  static const int maxVoiceDuration = 300; // 5 minutes in seconds

  static String getSizeReadable(int bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB"];
    final i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(1)} ${suffixes[i]}';
  }

  static String getLimitReadable(String fileType) {
    switch (fileType) {
      case 'image':
        return getSizeReadable(maxImageSize);
      case 'audio':
        return getSizeReadable(maxAudioSize);
      case 'video':
        return getSizeReadable(maxVideoSize);
      case 'document':
        return getSizeReadable(maxDocumentSize);
      default:
        return getSizeReadable(maxDocumentSize);
    }
  }
}
