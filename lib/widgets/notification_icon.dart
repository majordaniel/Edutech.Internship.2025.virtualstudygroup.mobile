import 'package:edify_app/models/join_request_model.dart';
import 'package:edify_app/widgets/join_requests_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edify_app/providers/join_request_provider.dart';
import 'package:edify_app/constants/colors.dart';

class NotificationIcon extends StatefulWidget {
  final int? currentGroupId;

  const NotificationIcon({super.key, this.currentGroupId});

  @override
  State<NotificationIcon> createState() => _NotificationIconState();
}

class _NotificationIconState extends State<NotificationIcon> {
  @override
  void initState() {
    super.initState();
    // Ensure provider is refreshed when this widget is created
    _refreshOnInit();
  }

  void _refreshOnInit() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final joinRequestProvider = context.read<JoinRequestProvider>();
      joinRequestProvider.forceRefresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<JoinRequestProvider>(
      builder: (context, joinRequestProvider, child) {
        // Filter requests for current group if specified
        final relevantRequests = widget.currentGroupId != null
            ? joinRequestProvider.pendingRequests
                  .where((request) => request.groupId == widget.currentGroupId)
                  .toList()
            : joinRequestProvider.pendingRequests;

        final pendingCount = relevantRequests.length;

        // print(
        //   '🔔 NotificationIcon rebuild - Count: $pendingCount, Group: ${widget.currentGroupId}',
        // );

        return Stack(
          children: [
            IconButton(
              onPressed: () => _showJoinRequests(
                context,
                relevantRequests,
                joinRequestProvider,
              ),
              icon: Icon(
                Icons.notifications_outlined,
                color: AppColors.primaryOrange,
                size: 24,
              ),
            ),
            if (pendingCount > 0) ...[
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    pendingCount > 9 ? '9+' : pendingCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  void _showJoinRequests(
    BuildContext context,
    List<JoinRequest> requests,
    JoinRequestProvider joinRequestProvider,
  ) {
    print(
      '🔔 Showing join requests bottom sheet with ${requests.length} requests',
    );

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(color: Colors.transparent),
              ),
            ),
            Positioned(
              top: 30,
              right: 0,
              child: Container(
                height: 287,
                width: 328,
                decoration: BoxDecoration(
                  color: AppColors.primaryLightGreyJoinR,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                child: JoinRequestsBottomSheet(requests: requests),
              ),
            ),
          ],
        ),
      ),
    ).then((_) {
      // Force refresh when bottom sheet is closed to ensure sync
      joinRequestProvider.forceRefresh();
    });

    // showModalBottomSheet(
    //   context: context,
    //   isScrollControlled: true,
    //   shape: const RoundedRectangleBorder(
    //     borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    //   ),
    //   builder: (context) => JoinRequestsBottomSheet(requests: requests),
    // ).then((_) {
    //   // Force refresh when bottom sheet is closed to ensure sync
    //   joinRequestProvider.forceRefresh();
    // });
  }
}
