import 'package:flutter/foundation.dart';

class NotificationProvider with ChangeNotifier {
  int _notificationCount = 0;
  Map<int, int> _groupNotifications = {}; // groupId -> count

  int get notificationCount => _notificationCount;

  int getGroupNotificationCount(int groupId) {
    return _groupNotifications[groupId] ?? 0;
  }

  // Update global notification count
  void updateNotificationCount(int count) {
    _notificationCount = count;
    notifyListeners();
  }

  // Update group-specific notifications
  void updateGroupNotification(int groupId, int count) {
    _groupNotifications[groupId] = count;

    // Recalculate total count
    _notificationCount = _groupNotifications.values.fold(
      0,
      (sum, count) => sum + count,
    );
    notifyListeners();
  }

  // Clear notifications for a specific group
  void clearGroupNotifications(int groupId) {
    _groupNotifications.remove(groupId);
    _notificationCount = _groupNotifications.values.fold(
      0,
      (sum, count) => sum + count,
    );
    notifyListeners();
  }

  // Clear all notifications
  void clearAllNotifications() {
    _notificationCount = 0;
    _groupNotifications.clear();
    notifyListeners();
  }

  // Mark notification as read
  void markAsRead(int groupId) {
    if (_groupNotifications.containsKey(groupId) &&
        _groupNotifications[groupId]! > 0) {
      _groupNotifications[groupId] = 0;
      _notificationCount = _groupNotifications.values.fold(
        0,
        (sum, count) => sum + count,
      );
      notifyListeners();
    }
  }
}
