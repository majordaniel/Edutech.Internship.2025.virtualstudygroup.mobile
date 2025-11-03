import 'dart:math';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:edify_app/constants/colors.dart';

class WhatsAppVoicePlayer extends StatefulWidget {
  final String audioUrl;
  final String? fileName;
  final int? duration;
  final bool isMe;

  const WhatsAppVoicePlayer({
    Key? key,
    required this.audioUrl,
    this.fileName,
    this.duration,
    required this.isMe,
  }) : super(key: key);

  @override
  State<WhatsAppVoicePlayer> createState() => _WhatsAppVoicePlayerState();
}

class _WhatsAppVoicePlayerState extends State<WhatsAppVoicePlayer>
    with SingleTickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _isLoading = false;
  bool _hasError = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  late AnimationController _waveController;
  late Animation<double> _waveAnimation;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();

    // Wave animation
    _waveController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    _waveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.easeInOut),
    );

    _initializeAudio();
    _setupAudioListeners();
  }

  Future<void> _initializeAudio() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
        _isCompleted = false;
      });

      if (widget.audioUrl.isEmpty) {
        throw Exception('Audio URL is empty');
      }

      if (!widget.audioUrl.startsWith('http')) {
        throw Exception('Invalid audio URL format');
      }

      print('🎵 Initializing audio player...');

      // Reset the player completely
      await _audioPlayer.stop();
      await _audioPlayer.setUrl(widget.audioUrl);

      // Explicitly set loop mode to OFF
      await _audioPlayer.setLoopMode(LoopMode.one);

      // Get the actual duration
      final actualDuration = _audioPlayer.duration;
      if (actualDuration != null) {
        setState(() {
          _duration = actualDuration;
        });
      } else if (widget.duration != null) {
        setState(() {
          _duration = Duration(seconds: widget.duration!);
        });
      }

      setState(() {
        _isLoading = false;
      });

      print('✅ Audio initialized - Duration: $_duration, Loop: false');
    } catch (e) {
      print('❌ Audio initialization error: $e');
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  void _setupAudioListeners() {
    _audioPlayer.playerStateStream.listen((state) {
      // print(
      //   '🎵 Player State - Processing: ${state.processingState}, Playing: ${state.playing}',
      // );

      if (state.processingState == ProcessingState.completed) {
        // print('✅ Audio completed - stopping playback');
        _handleAudioCompletion();
      } else if (state.processingState == ProcessingState.ready) {
        if (state.playing) {
          setState(() {
            _isPlaying = true;
            _isCompleted = false;
          });
          _waveController.repeat(reverse: true);
        } else {
          setState(() {
            _isPlaying = false;
          });
          _waveController.stop();
        }
      }
    });

    _audioPlayer.positionStream.listen((position) {
      // Check if we've reached the end (with a small buffer)
      if (_duration > Duration.zero &&
          position >= _duration - Duration(milliseconds: 100)) {
        if (!_isCompleted) {
          print('⏰ Reached end of audio - completing');
          _handleAudioCompletion();
        }
      } else {
        setState(() {
          _position = position;
        });
      }
    });

    _audioPlayer.durationStream.listen((duration) {
      if (duration != null && duration > Duration.zero) {
        setState(() {
          _duration = duration;
        });
      }
    });
  }

  void _handleAudioCompletion() {
    if (_isCompleted) return;

    print('🛑 Handling audio completion');

    setState(() {
      _isPlaying = false;
      _isCompleted = true;
      _position = _duration;
    });

    _waveController.stop();
    _waveController.value = 0.0;

    // Stop the audio player explicitly
    _audioPlayer.stop();

    // Reset to beginning after a short delay
    Future.delayed(Duration(milliseconds: 100), () {
      if (mounted) {
        _audioPlayer.seek(Duration.zero);
        setState(() {
          _position = Duration.zero;
        });
      }
    });
  }

  Future<void> _togglePlayPause() async {
    try {
      if (_isPlaying) {
        print('⏸️ Pausing audio');
        await _audioPlayer.pause();
        setState(() {
          _isPlaying = false;
        });
        _waveController.stop();
      } else {
        print('▶️ Starting audio playback');

        // If audio was completed, reset to start
        if (_isCompleted ||
            (_duration > Duration.zero && _position >= _duration)) {
          print('🔄 Resetting to start position');
          await _audioPlayer.seek(Duration.zero);
          setState(() {
            _isCompleted = true;
            _position = Duration.zero;
          });
        }

        await _audioPlayer.play();
        setState(() {
          _isPlaying = false;
        });
        _waveController.repeat(reverse: true);
      }
    } catch (e) {
      print('❌ Play/pause error: $e');
      setState(() {
        _hasError = true;
      });
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  double get _progress {
    if (_duration.inSeconds == 0) return 0.0;
    return _position.inSeconds / _duration.inSeconds;
  }

  @override
  void dispose() {
    print('🔌 Disposing WhatsAppVoicePlayer - stopping audio');
    _audioPlayer.stop();
    _audioPlayer.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = widget.isMe
        ? AppColors.primaryOrangeLight
        : AppColors.primaryGreyLight;

    final waveColor = widget.isMe
        ? AppColors.primaryOrange
        : AppColors.primaryBlack;

    return Container(
      constraints: BoxConstraints(maxWidth: 220),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Play/Pause Button
          GestureDetector(
            onTap: _isLoading ? null : _togglePlayPause,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: waveColor,
                shape: BoxShape.circle,
              ),
              child: _isLoading
                  ? Center(
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 16,
                    ),
            ),
          ),

          SizedBox(width: 12),

          // Waveform and Progress
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Waveform visualization
                Container(
                  height: 20,
                  child: Row(
                    children: List.generate(20, (index) {
                      return _buildWaveBar(index, waveColor);
                    }),
                  ),
                ),

                SizedBox(height: 4),

                // Duration and progress
                Row(
                  children: [
                    Text(
                      _formatDuration(_position),
                      style: TextStyle(
                        fontSize: 12,
                        color: waveColor.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: _progress,
                        backgroundColor: waveColor.withOpacity(0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(waveColor),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      _formatDuration(_duration),
                      style: TextStyle(
                        fontSize: 12,
                        color: waveColor.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaveBar(int index, Color waveColor) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 1),
        child: AnimatedBuilder(
          animation: _waveAnimation,
          builder: (context, child) {
            double height;
            if (_isPlaying && !_isCompleted) {
              // Animated bars when playing
              final wavePosition = (index / 20 + _waveAnimation.value) % 1.0;
              height = 4 + (sin(wavePosition * 2 * pi) + 1) * 6;
            } else {
              // Static bars when paused or completed
              final barPosition = index / 20;
              height = barPosition < _progress ? 12.0 : 4.0;
            }

            return Container(
              height: height,
              decoration: BoxDecoration(
                color: waveColor,
                borderRadius: BorderRadius.circular(1),
              ),
            );
          },
        ),
      ),
    );
  }
}
