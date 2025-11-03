import 'package:edify_app/models/join_request_model.dart';
import 'package:edify_app/services/join_request_service.dart';
import 'package:edify_app/widgets/texts.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edify_app/providers/join_request_provider.dart';
import 'package:edify_app/constants/colors.dart';

class JoinRequestsBottomSheet extends StatefulWidget {
  final List<JoinRequest> requests;

  const JoinRequestsBottomSheet({super.key, required this.requests});

  @override
  State<JoinRequestsBottomSheet> createState() =>
      _JoinRequestsBottomSheetState();
}

class _JoinRequestsBottomSheetState extends State<JoinRequestsBottomSheet> {
  final Map<String, bool> _processingRequests = {};

  @override
  Widget build(BuildContext context) {
    final joinRequestProvider = Provider.of<JoinRequestProvider>(context);

    return Container(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_outlined),
              ),
              SizedBox(width: 30),
              CustomTexts(
                title: 'Pending Requests',
                textColor: AppColors.primaryAppbarBlack,
                textSize: 16,
                textWeight: FontWeight.w500,
                textAlignment: AlignmentGeometry.center,
              ),
            ],
          ),

          const SizedBox(height: 16),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CustomTexts(
                title: 'New members need admin approval',
                textColor: AppColors.primaryBlack,
                textSize: 12,
                textWeight: FontWeight.w500,
                textAlignment: AlignmentGeometry.center,
              ),
              CustomTexts(
                title: 'to join these group',
                textColor: AppColors.primaryBlack,
                textSize: 12,
                textWeight: FontWeight.w500,
                textAlignment: AlignmentGeometry.center,
              ),
            ],
          ),
          SizedBox(height: 15),
          Divider(height: 1, color: AppColors.primaryBlackLightActive),
          SizedBox(height: 22),
          CustomTexts(
            title: 'from invite link',
            textColor: AppColors.primaryGreyDarkActive,
            textSize: 12,
            textWeight: FontWeight.w500,
            textAlignment: AlignmentGeometry.centerLeft,
          ),
          SizedBox(height: 22),
          // Refresh button and stats
          // Row(
          //   children: [
          //     ElevatedButton.icon(
          //       onPressed: joinRequestProvider.isLoading
          //           ? null
          //           : () => joinRequestProvider.loadJoinRequests(),
          //       icon: joinRequestProvider.isLoading
          //           ? SizedBox(
          //               width: 16,
          //               height: 16,
          //               child: CircularProgressIndicator(strokeWidth: 2),
          //             )
          //           : const Icon(Icons.refresh, size: 16),
          //       label: Text(
          //         joinRequestProvider.isLoading ? 'Loading...' : 'Refresh',
          //       ),
          //       style: ElevatedButton.styleFrom(
          //         backgroundColor: AppColors.primaryOrange,
          //         foregroundColor: Colors.white,
          //       ),
          //     ),
          //     const SizedBox(width: 8),
          //     Text(
          //       '${widget.requests.length} pending request${widget.requests.length == 1 ? '' : 's'}',
          //       style: TextStyle(color: AppColors.primaryBlackLight),
          //     ),
          //   ],
          // ),
          // const SizedBox(height: 16),

          // // Error message
          // if (joinRequestProvider.error != null) ...[
          //   Container(
          //     width: double.infinity,
          //     padding: const EdgeInsets.all(12),
          //     decoration: BoxDecoration(
          //       color: Colors.red.withOpacity(0.1),
          //       borderRadius: BorderRadius.circular(8),
          //       border: Border.all(color: Colors.red.withOpacity(0.3)),
          //     ),
          //     child: Row(
          //       children: [
          //         Icon(Icons.error_outline, color: Colors.red, size: 20),
          //         const SizedBox(width: 8),
          //         Expanded(
          //           child: Text(
          //             joinRequestProvider.error!,
          //             style: TextStyle(color: Colors.red),
          //           ),
          //         ),
          //         IconButton(
          //           onPressed: () => joinRequestProvider.clearError(),
          //           icon: Icon(Icons.close, size: 16, color: Colors.red),
          //         ),
          //       ],
          //     ),
          //   ),
          //   const SizedBox(height: 16),
          // ],

          // Requests List or Empty State
          if (widget.requests.isEmpty) ...[
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_off_outlined,
                      size: 64,
                      color: AppColors.primaryBlackLight,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No join requests',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    // Text(
                    //   'New join requests will appear here',
                    //   style: TextStyle(color: AppColors.primaryBlackLight),
                    // ),
                  ],
                ),
              ),
            ),
          ] else ...[
            Expanded(
              child: ListView.builder(
                itemCount: widget.requests.length,
                itemBuilder: (context, index) {
                  final request = widget.requests[index];
                  return _buildRequestItem(request, joinRequestProvider);
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRequestItem(JoinRequest request, JoinRequestProvider provider) {
    final isProcessing = provider.isProcessing(request.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // User Avatar
          CircleAvatar(
            maxRadius: 19,
            backgroundImage:
                request.userAvatar != null && request.userAvatar!.isNotEmpty
                ? NetworkImage(request.userAvatar!)
                : null,
            backgroundColor:
                (request.userAvatar == null || request.userAvatar!.isEmpty)
                ? AppColors.primaryOrangeLight
                : null,
            child: (request.userAvatar == null || request.userAvatar!.isEmpty)
                ? Text(
                    request.userName.isNotEmpty
                        ? request.userName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: AppColors.primaryBlack,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTexts(
                  title: request.userName,
                  textColor: AppColors.primaryBlack,
                  textSize: 14,
                  textWeight: FontWeight.w500,
                  textAlignment: AlignmentGeometry.centerLeft,
                ),
                const SizedBox(height: 4),
                CustomTexts(
                  title: request.message,
                  textColor: AppColors.primaryBlack,
                  textSize: 12,
                  textWeight: FontWeight.w500,
                  textAlignment: AlignmentGeometry.centerLeft,
                ),

                const SizedBox(height: 8),
                Text(
                  'Requested ${_formatTime(request.createdAt)}',
                  style: TextStyle(
                    color: AppColors.primaryBlackLight,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 21),
          // Action Buttons or Status
          if (isProcessing) ...[
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primaryOrange,
              ),
            ),
          ] else if (request.isPending) ...[
            // Show action buttons for pending requests
            Row(
              children: [
                // Reject Button
                IconButton(
                  onPressed: () => _handleReject(request, provider),
                  icon: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryOrangeLight,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primaryOrange),
                    ),
                    child: const Icon(
                      Icons.close,
                      color: AppColors.primaryAppbarBlack,
                      size: 20,
                    ),
                  ),
                ),
                // Approve Button
                IconButton(
                  onPressed: () => _handleApprove(request, provider),
                  icon: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryOrange,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: AppColors.primaryOrangeLight,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            // Show status for processed requests
            CustomTexts(
              title: request.isApproved ? 'Approved' : 'Rejected',
              textColor: request.isApproved
                  ? AppColors.primaryApproved
                  : AppColors.primaryRejected,
              textSize: 12,
              textWeight: FontWeight.w500,
              textAlignment: AlignmentGeometry.centerRight,
            ),
          ],
        ],
      ),
    );
  }
  // Action methods:

  void _handleApprove(JoinRequest request, JoinRequestProvider provider) async {
    final success = await provider.approveRequest(request);

    if (success && mounted) {
      // No need for snackbar since the UI updates immediately with status
      print('✅ Approval action completed');
    } else if (mounted && !success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to approve: ${provider.error ?? "Unknown error"}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleReject(JoinRequest request, JoinRequestProvider provider) async {
    final success = await provider.rejectRequest(request);

    if (success && mounted) {
      // No need for snackbar since the UI updates immediately with status
      print('✅ Rejection action completed');
    } else if (mounted && !success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to reject: ${provider.error ?? "Unknown error"}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _setProcessing(String requestId, bool processing) {
    setState(() {
      if (processing) {
        _processingRequests[requestId] = true;
      } else {
        _processingRequests.remove(requestId);
      }
    });
  }

  String _formatTime(String createdAt) {
    try {
      final dateTime = DateTime.parse(createdAt);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 1) return 'just now';
      if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
      if (difference.inHours < 24) return '${difference.inHours}h ago';
      return '${difference.inDays}d ago';
    } catch (e) {
      return 'recently';
    }
  }

  // For testing
  void _debugRequest(JoinRequest request, JoinRequestProvider provider) async {
    print('🐛 DEBUG: Testing request data');
    print('   Request ID: ${request.requestId}');
    print('   Group ID: ${request.groupId}');
    print('   User ID: ${request.userId}');
    print('   User Name: ${request.userName}');
    print('   Notification ID: ${request.notificationId}');

    // Testing the endpoint directly
    await JoinRequestService.debugApproveRequest(request);
  }
}
