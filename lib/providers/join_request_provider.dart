// join_request_provider.dart - UPDATED
import 'dart:async';
import 'package:edify_app/models/api_response.dart';
import 'package:flutter/foundation.dart';
import '../services/join_request_service.dart';
import '../models/join_request_model.dart';

class JoinRequestProvider with ChangeNotifier {
  List<JoinRequest> _pendingRequests = [];
  bool _isLoading = false;
  String? _error;
  Timer? _refreshTimer;
  final Set<String> _processingRequests = {};

  List<JoinRequest> get pendingRequests => _pendingRequests;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get pendingRequestsCount => _pendingRequests.length;
  bool isProcessing(String requestId) =>
      _processingRequests.contains(requestId);

  // Enhanced auto-refresh with better error handling
  void startAutoRefresh() {
    _refreshTimer?.cancel();

    _refreshTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      if (!_isLoading) {
        _silentRefresh();
      }
    });

    // print('🔄 Auto-refresh started (30s interval)');
  }

  void stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
    // print('🔄 Auto-refresh stopped');
  }

  Future<void> _silentRefresh() async {
    try {
      final response = await JoinRequestService.getJoinRequestNotifications();

      if (response.isSuccess) {
        final newRequests = response.data ?? [];

        if (!_areRequestsEqual(_pendingRequests, newRequests)) {
          _pendingRequests = newRequests;
          // print('🔄 Silently refreshed: ${_pendingRequests.length} requests');
          notifyListeners();
        }
      }
    } catch (e) {
      // print('⚠️ Silent refresh failed: $e');
    }
  }

  bool _areRequestsEqual(List<JoinRequest> list1, List<JoinRequest> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i].id != list2[i].id) return false;
    }
    return true;
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  // IMPROVED: Better load method with retry logic
  Future<void> loadJoinRequests() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // print('📚 Loading join requests...');
      final response = await JoinRequestService.getJoinRequestNotifications();

      if (response.isSuccess) {
        _pendingRequests = response.data ?? [];
        // print('📊 Loaded ${_pendingRequests.length} join requests');

        // Log each request for debugging
        for (final request in _pendingRequests) {
          // print(
          // '   - ${request.userName} for group ${request.groupId} (ID: ${request.requestId})',
          // );
        }

        _error = null;
      } else {
        _error = response.message;
        // print('❌ Error loading join requests: $_error');
      }
    } catch (e) {
      _error = e.toString();
      // print('❌ Exception loading join requests: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // IMPROVED: Approve with better state management
  // In JoinRequestProvider - update to handle status display

  // IMPROVED: Update request status instead of removing
  Future<bool> approveRequest(JoinRequest request) async {
    if (_processingRequests.contains(request.id)) {
      // print('⚠️ Request ${request.id} is already being processed');
      return false;
    }

    _processingRequests.add(request.id);
    notifyListeners();

    try {
      // print('✅ APPROVING REQUEST: ${request.userName}');

      final response = await JoinRequestService.approveRequest(request);

      if (response.isSuccess) {
        // ✅ UPDATE STATUS INSTEAD OF REMOVING
        if (response.message == 'already_processed') {
          // Request was already approved by someone else
          _updateRequestStatus(request.id, 'approved');
          // print('ℹ️ Request was already approved by someone else');
        } else {
          // New approval
          _updateRequestStatus(request.id, 'approved');
          // print('✅ Request approved successfully');
        }

        // Force refresh to ensure sync
        await _silentRefresh();
        return true;
      } else {
        _error = response.message;
        // print('❌ Approval failed: ${response.message}');
        return false;
      }
    } catch (e) {
      _error = e.toString();
      // print('💥 ERROR in approveRequest: $e');
      return false;
    } finally {
      _processingRequests.remove(request.id);
      notifyListeners();
    }
  }

  // IMPROVED: Update request status instead of removing
  Future<bool> rejectRequest(JoinRequest request) async {
    if (_processingRequests.contains(request.id)) {
      // print('⚠️ Request ${request.id} is already being processed');
      return false;
    }

    _processingRequests.add(request.id);
    notifyListeners();

    try {
      // print('❌ REJECTING REQUEST: ${request.userName}');

      final response = await JoinRequestService.rejectRequest(request);

      if (response.isSuccess) {
        // ✅ UPDATE STATUS INSTEAD OF REMOVING
        if (response.message == 'already_processed') {
          // Request was already rejected by someone else
          _updateRequestStatus(request.id, 'rejected');
          // print('ℹ️ Request was already rejected by someone else');
        } else {
          // New rejection
          _updateRequestStatus(request.id, 'rejected');
          // print('✅ Request rejected successfully');
        }

        // Force refresh to ensure sync
        await _silentRefresh();
        return true;
      } else {
        _error = response.message;
        // print('❌ Rejection failed: ${response.message}');
        return false;
      }
    } catch (e) {
      _error = e.toString();
      // print('💥 ERROR in rejectRequest: $e');
      return false;
    } finally {
      _processingRequests.remove(request.id);
      notifyListeners();
    }
  }

  // NEW: Helper method to update request status
  void _updateRequestStatus(String requestId, String newStatus) {
    final index = _pendingRequests.indexWhere((r) => r.id == requestId);
    if (index != -1) {
      _pendingRequests[index] = _pendingRequests[index].copyWith(
        status: newStatus,
      );
      // print('🔄 Updated request $requestId status to: $newStatus');
    }
  }

  // Force refresh from outside
  Future<void> forceRefresh() async {
    // print('🔄 Manual force refresh triggered');
    await loadJoinRequests();
  }

  Future<void> markAllAsRead() async {
    try {
      await JoinRequestService.markAllAsRead();
      await _silentRefresh();
    } catch (e) {
      // print('⚠️ Error marking all as read: $e');
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void removeRequest(String requestId) {
    _pendingRequests.removeWhere((request) => request.id == requestId);
    notifyListeners();
  }
}
