import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/workout.dart';
import '../../services/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/video_player_widget.dart';

/// One internal step of the guided session: either performing an exercise
/// ("work") or resting before the next one ("rest").
class _Step {
  final bool isRest;
  final Exercise exercise; // for rest, this is the *upcoming* exercise
  final int? seconds; // null = manual (rep-based, wait for the user)
  _Step({required this.isRest, required this.exercise, this.seconds});
}

/// Hands-free guided workout: shows one exercise at a time with its video,
/// a timer that auto-advances through the sequence, and rest intervals.
class WorkoutSessionScreen extends StatefulWidget {
  final Workout workout;
  const WorkoutSessionScreen({super.key, required this.workout});

  @override
  State<WorkoutSessionScreen> createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends State<WorkoutSessionScreen> {
  late final List<_Step> _steps = _buildSteps();
  int _index = 0;
  int _secondsLeft = 0;
  bool _running = true;
  bool _finished = false;
  Timer? _ticker;

  List<_Step> _buildSteps() {
    final steps = <_Step>[];
    final exercises = widget.workout.exercises;
    for (var i = 0; i < exercises.length; i++) {
      final e = exercises[i];
      steps.add(_Step(
        isRest: false,
        exercise: e,
        seconds: e.isTimed ? e.durationSeconds : null,
      ));
      // Rest after every exercise except the last.
      final isLast = i == exercises.length - 1;
      if (!isLast && e.restSeconds > 0) {
        steps.add(_Step(
          isRest: true,
          exercise: exercises[i + 1], // preview the next exercise
          seconds: e.restSeconds,
        ));
      }
    }
    return steps;
  }

  _Step get _step => _steps[_index];

  @override
  void initState() {
    super.initState();
    _enterStep(0, cue: false);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _enterStep(int i, {required bool cue}) {
    _ticker?.cancel();
    _index = i;
    final step = _steps[i];
    _secondsLeft = step.seconds ?? 0;
    if (cue) _cue();
    setState(() {});
    if (step.seconds != null) _startTicker();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_running) return;
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) _advance();
    });
  }

  void _advance() {
    if (_index >= _steps.length - 1) {
      _complete();
      return;
    }
    _enterStep(_index + 1, cue: true);
  }

  void _skip() => _advance();

  void _togglePause() => setState(() => _running = !_running);

  void _cue() {
    final state = context.read<AppState>();
    if (state.hapticsEnabled) HapticFeedback.mediumImpact();
    if (state.soundEnabled) SystemSound.play(SystemSoundType.alert);
  }

  Future<void> _complete() async {
    _ticker?.cancel();
    setState(() => _finished = true);
    await context
        .read<AppState>()
        .recordSession(widget.workout.estimatedMinutes);
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.emoji_events_outlined,
            color: AppTheme.accent, size: 36),
        title: const Text('Workout complete'),
        content: Text('${widget.workout.title}\nWell trained.',
            textAlign: TextAlign.center),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final step = _step;
    final progress = (_index + 1) / _steps.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('Step ${_index + 1} of ${_steps.length}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: AppTheme.accent.withOpacity(0.15),
              color: AppTheme.accent,
            ),
            Expanded(
              child: step.isRest
                  ? _restView(step, text)
                  : _workView(step, text),
            ),
            _controls(step),
          ],
        ),
      ),
    );
  }

  Widget _workView(_Step step, TextTheme text) {
    final e = step.exercise;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      children: [
        Text(e.name, style: text.headlineSmall),
        const SizedBox(height: 4),
        Text('Target: ${e.target}', style: text.bodyMedium),
        const SizedBox(height: 16),
        ExerciseVideo(exercise: e),
        const SizedBox(height: 20),
        // Timed exercises show a big countdown; rep-based show the target.
        Center(
          child: e.isTimed
              ? Text(_fmt(_secondsLeft),
                  style: text.displaySmall?.copyWith(fontSize: 56))
              : Column(
                  children: [
                    Text('${e.reps}',
                        style: text.displaySmall?.copyWith(fontSize: 56)),
                    Text('reps — tap Next when done', style: text.bodyMedium),
                  ],
                ),
        ),
        const SizedBox(height: 20),
        for (final s in e.instructions)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('•  '),
                Expanded(child: Text(s, style: text.bodyMedium)),
              ],
            ),
          ),
      ],
    );
  }

  Widget _restView(_Step step, TextTheme text) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.self_improvement, size: 56, color: AppTheme.accent),
          const SizedBox(height: 16),
          Text('Rest', style: text.headlineSmall),
          const SizedBox(height: 8),
          Text(_fmt(_secondsLeft),
              style: text.displaySmall?.copyWith(fontSize: 56)),
          const SizedBox(height: 24),
          Text('Next up', style: text.bodyMedium),
          Text(step.exercise.name, style: text.titleMedium),
        ],
      ),
    );
  }

  Widget _controls(_Step step) {
    final isManual = step.seconds == null;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Row(
        children: [
          if (!isManual)
            Expanded(
              child: OutlinedButton.icon(
                icon: Icon(_running ? Icons.pause : Icons.play_arrow),
                label: Text(_running ? 'Pause' : 'Resume'),
                onPressed: _finished ? null : _togglePause,
              ),
            ),
          if (!isManual) const SizedBox(width: 12),
          Expanded(
            child: FilledButton.icon(
              icon: Icon(step.isRest
                  ? Icons.skip_next
                  : (isManual ? Icons.check : Icons.skip_next)),
              label: Text(step.isRest
                  ? 'Skip rest'
                  : (isManual ? 'Next' : 'Skip')),
              onPressed: _finished ? null : _skip,
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(int seconds) {
    final s = seconds.clamp(0, 5999);
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final sec = (s % 60).toString().padLeft(2, '0');
    return '$m:$sec';
  }
}
