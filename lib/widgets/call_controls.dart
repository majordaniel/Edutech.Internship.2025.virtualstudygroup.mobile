import 'package:flutter/material.dart';

class CallControlsWidget extends StatefulWidget {
  final bool isVideoCall;
  final VoidCallback onEndCall;
  final VoidCallback onToggleVideo;
  final VoidCallback onToggleAudio;
  final VoidCallback onToggleSpeaker;
  final VoidCallback onFlipCamera;
  final bool isVideoEnabled;
  final bool isAudioEnabled;

  const CallControlsWidget({
    super.key,
    required this.isVideoCall,
    required this.onEndCall,
    required this.onToggleVideo,
    required this.onToggleAudio,
    required this.onToggleSpeaker,
    required this.onFlipCamera,
    this.isVideoEnabled = true,
    this.isAudioEnabled = true,
  });

  @override
  State<CallControlsWidget> createState() => _CallControlsWidgetState();
}

class _CallControlsWidgetState extends State<CallControlsWidget> {
  bool _isSpeakerEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Control buttons row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Video Toggle (only for video calls)
              if (widget.isVideoCall)
                _ControlButton(
                  icon: widget.isVideoEnabled
                      ? Icons.videocam
                      : Icons.videocam_off,
                  label: widget.isVideoEnabled ? 'Video On' : 'Video Off',
                  backgroundColor: widget.isVideoEnabled
                      ? Colors.white
                      : Colors.red,
                  iconColor: widget.isVideoEnabled
                      ? Colors.black
                      : Colors.white,
                  onPressed: widget.onToggleVideo,
                ),

              // Audio Toggle
              _ControlButton(
                icon: widget.isAudioEnabled ? Icons.mic : Icons.mic_off,
                label: widget.isAudioEnabled ? 'Mic On' : 'Mic Off',
                backgroundColor: widget.isAudioEnabled
                    ? Colors.white
                    : Colors.red,
                iconColor: widget.isAudioEnabled ? Colors.black : Colors.white,
                onPressed: widget.onToggleAudio,
              ),

              // Speaker Toggle
              _ControlButton(
                icon: _isSpeakerEnabled ? Icons.volume_up : Icons.volume_off,
                label: _isSpeakerEnabled ? 'Speaker' : 'Earpiece',
                backgroundColor: _isSpeakerEnabled ? Colors.white : Colors.grey,
                iconColor: _isSpeakerEnabled ? Colors.black : Colors.white,
                onPressed: () {
                  setState(() => _isSpeakerEnabled = !_isSpeakerEnabled);
                  widget.onToggleSpeaker();
                },
              ),

              // Flip Camera (only for video calls)
              if (widget.isVideoCall)
                _ControlButton(
                  icon: Icons.camera_front,
                  label: 'Flip Camera',
                  backgroundColor: Colors.white,
                  iconColor: Colors.black,
                  onPressed: widget.onFlipCamera,
                ),
            ],
          ),

          const SizedBox(height: 20),

          // Permission warning (if any)
          if (!widget.isAudioEnabled ||
              (widget.isVideoCall && !widget.isVideoEnabled))
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.warning_amber, color: Colors.orange, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Some permissions are disabled',
                    style: TextStyle(color: Colors.orange, fontSize: 12),
                  ),
                ],
              ),
            ),

          // End Call Button
          Container(
            width: 70,
            height: 70,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red,
            ),
            child: IconButton(
              icon: const Icon(Icons.call_end, size: 30, color: Colors.white),
              onPressed: widget.onEndCall,
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color iconColor;
  final VoidCallback onPressed;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.iconColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(icon, color: iconColor, size: 24),
            onPressed: onPressed,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
