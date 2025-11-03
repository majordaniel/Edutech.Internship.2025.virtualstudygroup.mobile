import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/meeting_provider.dart';

class MeetingSnackbar extends StatefulWidget {
  final String groupName;

  const MeetingSnackbar({super.key, required this.groupName});

  @override
  State<MeetingSnackbar> createState() => _MeetingSnackbarState();
}

class _MeetingSnackbarState extends State<MeetingSnackbar> {
  @override
  Widget build(BuildContext context) {
    final meetingProvider = Provider.of<MeetingProvider>(context);
    final isActive = meetingProvider.isMeetingActiveInGroup(widget.groupName);

    if (!isActive) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.blue.shade700,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            meetingProvider.meetingType == 'video'
                ? Icons.videocam
                : Icons.call,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Meeting in Progress',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${meetingProvider.activeMeetingGroup} - ${meetingProvider.meetingType == 'video' ? 'Video Call' : 'Audio Call'}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _buildJoinButton(context, meetingProvider),
          const SizedBox(width: 8),
          _buildEndButton(context, meetingProvider),
        ],
      ),
    );
  }

  Widget _buildJoinButton(
    BuildContext context,
    MeetingProvider meetingProvider,
  ) {
    return ElevatedButton(
      onPressed: () {
        // Navigate to the ongoing meeting
        _joinOngoingMeeting(context, meetingProvider);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: const Text('Join', style: TextStyle(fontSize: 12)),
    );
  }

  Widget _buildEndButton(
    BuildContext context,
    MeetingProvider meetingProvider,
  ) {
    return IconButton(
      onPressed: () {
        _showEndMeetingDialog(context, meetingProvider);
      },
      icon: const Icon(Icons.call_end, size: 18),
      color: Colors.white,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      tooltip: 'End Meeting',
    );
  }

  void _joinOngoingMeeting(
    BuildContext context,
    MeetingProvider meetingProvider,
  ) {
    // Navigate to call screen as guest
    // Navigator.of(context).push(
    //   MaterialPageRoute(
    //     builder: (context) => CallScreen(
    //       hostUrl: meetingProvider.meetingUrl,
    //       guestUrl: meetingProvider.meetingUrl, // Use same URL for guest
    //       groupName: meetingProvider.activeMeetingGroup,
    //       isVideoCall: meetingProvider.meetingType == 'video',
    //       isHost: false, // Join as guest
    //     ),
    //   ),
    // );
  }

  void _showEndMeetingDialog(
    BuildContext context,
    MeetingProvider meetingProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Meeting?'),
        content: Text(
          'Are you sure you want to end the ${meetingProvider.meetingType} call in ${meetingProvider.activeMeetingGroup}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              meetingProvider.endMeeting();
              // You might also want to call your API to end the meeting
              // CallService.endCall(callId);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('End Meeting'),
          ),
        ],
      ),
    );
  }
}
