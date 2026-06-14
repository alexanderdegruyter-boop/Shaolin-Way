import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../models/workout.dart';
import '../theme/app_theme.dart';

/// A real, working video player that auto-selects its backend from the
/// exercise data:
///   - videoType "youtube" -> youtube_player_flutter (inline streaming)
///   - videoType "local"   -> video_player (bundled mp4, fully offline)
///
/// To swap in your own video, edit the exercise in assets/data/workouts.json
/// (see README.md). No code changes are needed here.
class ExerciseVideo extends StatelessWidget {
  final Exercise exercise;
  const ExerciseVideo({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    if (exercise.isYouTube) {
      return _YouTubeView(videoId: exercise.videoSource);
    }
    return _LocalVideoView(assetPath: exercise.videoSource);
  }
}

// ---------------------------------------------------------------------------
// YouTube backend
// ---------------------------------------------------------------------------

class _YouTubeView extends StatefulWidget {
  final String videoId;
  const _YouTubeView({required this.videoId});

  @override
  State<_YouTubeView> createState() => _YouTubeViewState();
}

class _YouTubeViewState extends State<_YouTubeView> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        enableCaption: false,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant _YouTubeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // When the user advances to a new exercise, load its video.
    if (oldWidget.videoId != widget.videoId) {
      _controller.load(widget.videoId);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // YoutubePlayerBuilder handles inline play, scrubber, and fullscreen.
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressColors: const ProgressBarColors(
          playedColor: AppTheme.accent,
          handleColor: AppTheme.accent,
        ),
      ),
      builder: (context, player) => ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: player,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Local (bundled asset) backend
// ---------------------------------------------------------------------------

class _LocalVideoView extends StatefulWidget {
  final String assetPath;
  const _LocalVideoView({required this.assetPath});

  @override
  State<_LocalVideoView> createState() => _LocalVideoViewState();
}

class _LocalVideoViewState extends State<_LocalVideoView> {
  VideoPlayerController? _controller;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final c = VideoPlayerController.asset(widget.assetPath);
      await c.initialize();
      await c.setLooping(true);
      if (!mounted) {
        c.dispose();
        return;
      }
      setState(() => _controller = c);
    } catch (_) {
      // Asset missing or not a valid video — show a friendly fallback.
      if (mounted) setState(() => _error = true);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error) {
      return _MissingVideoCard(assetPath: widget.assetPath);
    }
    final c = _controller;
    if (c == null) {
      return const AspectRatio(
        aspectRatio: 16 / 9,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return _LocalControls(controller: c);
  }
}

/// Play/pause, replay, scrubber, and fullscreen controls for local video.
class _LocalControls extends StatefulWidget {
  final VideoPlayerController controller;
  const _LocalControls({required this.controller});

  @override
  State<_LocalControls> createState() => _LocalControlsState();
}

class _LocalControlsState extends State<_LocalControls> {
  VideoPlayerController get c => widget.controller;

  @override
  void initState() {
    super.initState();
    c.addListener(_onUpdate);
  }

  @override
  void dispose() {
    c.removeListener(_onUpdate);
    super.dispose();
  }

  void _onUpdate() => setState(() {});

  void _togglePlay() => c.value.isPlaying ? c.pause() : c.play();

  void _replay() {
    c.seekTo(Duration.zero);
    c.play();
  }

  void _openFullscreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _FullscreenVideo(controller: c),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          AspectRatio(
            aspectRatio: c.value.aspectRatio == 0 ? 16 / 9 : c.value.aspectRatio,
            child: GestureDetector(
              onTap: _togglePlay,
              child: VideoPlayer(c),
            ),
          ),
          // Center play icon when paused.
          if (!c.value.isPlaying)
            IconButton(
              iconSize: 56,
              icon: const Icon(Icons.play_circle_fill, color: Colors.white),
              onPressed: _togglePlay,
            ),
          // Bottom control bar.
          Container(
            color: Colors.black38,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(c.value.isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white),
                  onPressed: _togglePlay,
                ),
                IconButton(
                  icon: const Icon(Icons.replay, color: Colors.white),
                  onPressed: _replay,
                ),
                Expanded(
                  child: VideoProgressIndicator(
                    c,
                    allowScrubbing: true,
                    colors: const VideoProgressColors(
                      playedColor: AppTheme.accent,
                      bufferedColor: Colors.white24,
                      backgroundColor: Colors.white12,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.fullscreen, color: Colors.white),
                  onPressed: _openFullscreen,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A landscape fullscreen page for a local video, sharing the controller.
class _FullscreenVideo extends StatefulWidget {
  final VideoPlayerController controller;
  const _FullscreenVideo({required this.controller});

  @override
  State<_FullscreenVideo> createState() => _FullscreenVideoState();
}

class _FullscreenVideoState extends State<_FullscreenVideo> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: c.value.aspectRatio == 0 ? 16 / 9 : c.value.aspectRatio,
              child: GestureDetector(
                onTap: () => c.value.isPlaying ? c.pause() : c.play(),
                child: VideoPlayer(c),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.fullscreen_exit, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shown when a local asset is referenced but not bundled yet.
class _MissingVideoCard extends StatelessWidget {
  final String assetPath;
  const _MissingVideoCard({required this.assetPath});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
        ),
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.videocam_off_outlined, size: 36),
              const SizedBox(height: 8),
              Text('Demo video not bundled', style: text.titleMedium),
              const SizedBox(height: 4),
              Text(
                'Add $assetPath to assets/videos/\n(see README) — or switch this\nexercise to a YouTube video.',
                textAlign: TextAlign.center,
                style: text.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
