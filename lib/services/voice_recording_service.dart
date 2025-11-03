import 'dart:async';
import 'dart:io';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class VoiceRecordingService {
  static final AudioRecorder _audioRecorder = AudioRecorder();
  static bool _isRecording = false;
  static String? _currentRecordingPath;
  static DateTime? _recordingStartTime;
  static Timer? _recordingTimer;
  static Function(int)? _onTimerUpdate;
  static int _currentDuration = 0;

  // Check and request recording permissions
  static Future<bool> _checkPermissions() async {
    try {
      print('🔐 Checking permissions...');

      // Request microphone permission
      final micStatus = await Permission.microphone.status;
      if (!micStatus.isGranted) {
        print('🎤 Microphone permission not granted, requesting...');
        final micResult = await Permission.microphone.request();
        if (!micResult.isGranted) {
          print('❌ Microphone permission denied');
          return false;
        }
      }

      // Request storage permission (for Android)
      if (Platform.isAndroid) {
        final storageStatus = await Permission.storage.status;
        if (!storageStatus.isGranted) {
          print('💾 Storage permission not granted, requesting...');
          final storageResult = await Permission.storage.request();
          if (!storageResult.isGranted) {
            print('❌ Storage permission denied');
            return false;
          }
        }
      }

      // For iOS, we might need speech recognition permission
      if (Platform.isIOS) {
        final speechStatus = await Permission.speech.status;
        if (!speechStatus.isGranted) {
          print('🗣️ Speech permission not granted, requesting...');
          final speechResult = await Permission.speech.request();
          if (!speechResult.isGranted) {
            print('❌ Speech permission denied');
            return false;
          }
        }
      }

      print('✅ All permissions granted');
      return true;
    } catch (e) {
      print('❌ Permission error: $e');
      return false;
    }
  }

  // Start voice recording with timer callback
  static Future<VoiceRecordingResult> startRecording({
    Function(int)? onTimerUpdate,
  }) async {
    try {
      if (_isRecording) {
        return VoiceRecordingResult(
          success: false,
          error: 'Already recording',
          filePath: null,
        );
      }

      print('🎤 Starting recording process...');

      // Check permissions
      final hasPermission = await _checkPermissions();
      if (!hasPermission) {
        return VoiceRecordingResult(
          success: false,
          error: 'Microphone or storage permission denied',
          filePath: null,
        );
      }

      // Create recording file path
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${directory.path}/voice_message_$timestamp.m4a';

      print('📁 Recording file path: $filePath');

      // Configure recording settings
      final config = RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
        numChannels: 1,
      );

      print('⚙️ Recording config: $config');

      // Start recording
      try {
        await _audioRecorder.start(config, path: filePath);
        print('✅ Recording started successfully');
      } catch (startError) {
        print('❌ Error starting recorder: $startError');
        return VoiceRecordingResult(
          success: false,
          error: 'Failed to start audio recorder: $startError',
          filePath: null,
        );
      }

      _isRecording = true;
      _currentRecordingPath = filePath;
      _recordingStartTime = DateTime.now();
      _onTimerUpdate = onTimerUpdate;
      _currentDuration = 0;

      // Start timer with callback
      _startTimer();

      print('🎤 Started recording: $filePath');
      return VoiceRecordingResult(
        success: true,
        error: null,
        filePath: filePath,
      );
    } catch (e) {
      print('❌ Start recording error: $e');
      return VoiceRecordingResult(
        success: false,
        error: 'Failed to start recording: $e',
        filePath: null,
      );
    }
  }

  static void _startTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_isRecording) {
        _currentDuration++;
        print('⏰ Recording duration: $_currentDuration seconds');
        _onTimerUpdate?.call(_currentDuration);
      } else {
        timer.cancel();
      }
    });
  }

  // Stop voice recording
  static Future<VoiceRecordingResult> stopRecording() async {
    try {
      if (!_isRecording) {
        return VoiceRecordingResult(
          success: false,
          error: 'No active recording',
          filePath: null,
        );
      }

      print('⏹️ Stopping recording...');

      _recordingTimer?.cancel();
      _recordingTimer = null;
      _onTimerUpdate = null;

      final recordingPath = await _audioRecorder.stop();
      _isRecording = false;

      print('📁 Stopped recording, path: $recordingPath');

      if (recordingPath != null && File(recordingPath).existsSync()) {
        final file = File(recordingPath);
        final fileSize = await file.length();
        final duration = _currentDuration;

        print('⏹️ Stopped recording: $recordingPath');
        print(
          '📊 Recording stats - Size: ${fileSize} bytes, Duration: ${duration}s',
        );

        _currentRecordingPath = null;
        _recordingStartTime = null;
        _currentDuration = 0;

        return VoiceRecordingResult(
          success: true,
          error: null,
          filePath: recordingPath,
          duration: duration,
          fileSize: fileSize,
        );
      } else {
        print('❌ Recording file not found or path is null');
        return VoiceRecordingResult(
          success: false,
          error: 'Recording file not found',
          filePath: null,
        );
      }
    } catch (e) {
      print('❌ Stop recording error: $e');
      _isRecording = false;
      _currentRecordingPath = null;
      _recordingStartTime = null;
      _currentDuration = 0;
      _recordingTimer?.cancel();
      _recordingTimer = null;
      _onTimerUpdate = null;
      return VoiceRecordingResult(
        success: false,
        error: 'Failed to stop recording: $e',
        filePath: null,
      );
    }
  }

  // Cancel recording
  static Future<void> cancelRecording() async {
    try {
      print('❌ Cancelling recording...');

      _recordingTimer?.cancel();
      _recordingTimer = null;
      _onTimerUpdate = null;

      if (_isRecording) {
        await _audioRecorder.stop();
        if (_currentRecordingPath != null) {
          final file = File(_currentRecordingPath!);
          if (await file.exists()) {
            await file.delete();
            print('🗑️ Deleted recording file: ${_currentRecordingPath}');
          }
        }
      }
    } catch (e) {
      print('❌ Cancel recording error: $e');
    } finally {
      _isRecording = false;
      _currentRecordingPath = null;
      _recordingStartTime = null;
      _currentDuration = 0;
    }
  }

  // Check if currently recording
  static bool get isRecording => _isRecording;

  // Get recording duration
  static int get recordingDuration => _currentDuration;

  // Dispose resources
  static Future<void> dispose() async {
    print('🔌 Disposing voice recording service...');
    if (_isRecording) {
      await cancelRecording();
    }
    await _audioRecorder.dispose();
  }
}

class VoiceRecordingResult {
  final bool success;
  final String? error;
  final String? filePath;
  final int? duration;
  final int? fileSize;

  VoiceRecordingResult({
    required this.success,
    required this.error,
    required this.filePath,
    this.duration,
    this.fileSize,
  });
}
