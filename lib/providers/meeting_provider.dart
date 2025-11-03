import 'dart:async';

import 'package:flutter/foundation.dart';

class MeetingProvider with ChangeNotifier {
  bool _isMeetingActive = false;
  String _activeMeetingGroup = '';
  String _meetingType = ''; // 'audio' or 'video'
  String _meetingUrl = '';
  Timer? _meetingStatusTimer;

  bool get isMeetingActive => _isMeetingActive;
  String get activeMeetingGroup => _activeMeetingGroup;
  String get meetingType => _meetingType;
  String get meetingUrl => _meetingUrl;

  // Start a meeting
  void startMeeting({
    required String groupName,
    required String type,
    required String meetingUrl,
  }) {
    _isMeetingActive = true;
    _activeMeetingGroup = groupName;
    _meetingType = type;
    _meetingUrl = meetingUrl;
    notifyListeners();
    print('🎯 Meeting started: $groupName ($type)');
  }

  void startMeetingStatusPolling(int groupId) {
    _meetingStatusTimer?.cancel();
    _meetingStatusTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _checkMeetingStatus(groupId);
    });
  }

  void stopMeetingStatusPolling() {
    _meetingStatusTimer?.cancel();
  }

  // End a meeting
  void endMeeting() {
    _isMeetingActive = false;
    _activeMeetingGroup = '';
    _meetingType = '';
    _meetingUrl = '';
    notifyListeners();
    print('🎯 Meeting ended');
  }

  // Check if a specific group has an active meeting
  bool isMeetingActiveInGroup(String groupName) {
    return _isMeetingActive && _activeMeetingGroup == groupName;
  }

  Future<void> _checkMeetingStatus(int groupId) async {
    // Call your API to check if meeting is still active
    // If not, call endMeeting()
  }
}
