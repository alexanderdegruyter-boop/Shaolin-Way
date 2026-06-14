import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/breathing_pattern.dart';
import '../../services/app_state.dart';
import '../../widgets/breathing_orb.dart';

/// A guided breathing session: animated orb, phase labels, countdown,
/// optional chime + haptics, synced to the pattern's phase timer.
class BreathingSessionScreen extends StatefulWidget {
  final BreathingPattern pattern;
  final int minutes;

  const BreathingSessionScreen({
    super.key,
    required this.pattern,
    required this.minutes,
  });

  @override
  State<BreathingSessionScreen> createState() => _BreathingSessionScreenState();
}

class _BreathingSessionScreenState extends State<BreathingSessionScreen>
    with SingleTickerProviderStateMixin {
  static const double _minScale = 0.5;
  static const double _maxScale = 1.0;

  late final AnimationController _orb;
  Timer? _ticker;

  late final int _totalSeconds = widget.minutes * 60;
  int _elapsed = 0;
  int _phaseIndex = 0;
  int _phaseSecondsLeft = 0;
  bool _running = false;
  bool _finished = false;

  // Orb scale endpoints for the current phase.
  double _fromScale = _minScale;
  double _toScale = _minScale;

  BreathPhase get _phase => widget.pattern.phases[_phaseIndex];

  @override
  void initState() {
    super.initState();
    _orb = AnimationController(vsync: this);
    // Lock the session to portrait for a calm, stable experience.
    _startPhase(0, cue: false);
    _start();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _orb.dispose();
    super.dispose();
  }

  // --- Session control ---------------------------------------------------

  void _start() {
    setState(() => _running = true);
    _orb.forward();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _pause() {
    _ticker?.cancel();
    _orb.stop();
    setState(() => _running = false);
  }

  void _resume() {
    setState(() => _running = true);
    _orb.forward();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    setState(() {
      _elapsed++;
      _phaseSecondsLeft--;
    });

    if (_elapsed >= _totalSeconds) {
      _complete();
      return;
    }
    if (_phaseSecondsLeft <= 0) {
      final next = (_phaseIndex + 1) % widget.pattern.phases.length;
      _startPhase(next, cue: true);
    }
  }

  /// Configure the orb animation + countdown for a phase.
  void _startPhase(int index, {required bool cue}) {
    final phase = widget.pattern.phases[index];

    // Determine the orb's target scale for this phase.
    double target;
    if (phase.isInhale) {
      target = _maxScale;
    } else if (phase.isExhale) {
      target = _minScale;
    } else {
      // Hold: stay at whatever size we just reached.
      target = _toScale;
    }

    _fromScale = _toScale; // start from where the orb currently is
    _toScale = target;

    _phaseIndex = index;
    _phaseSecondsLeft = phase.seconds;

    _orb
      ..duration = Duration(seconds: phase.seconds)
      ..reset();
    if (_running) _orb.forward();

    if (cue) _cue();
    if (mounted) setState(() {});
  }

  void _cue() {
    final state = context.read<AppState>();
    if (state.hapticsEnabled) HapticFeedback.mediumImpact();
    if (state.soundEnabled) SystemSound.play(SystemSoundType.alert);
  }

  Future<void> _complete() async {
    _ticker?.cancel();
    _orb.stop();
    setState(() {
      _finished = true;
      _running = false;
    });
    // Log the session toward streak + total minutes.
    await context.read<AppState>().recordSession(widget.minutes);
    if (!mounted) return;
    _showCompleteDialog();
  }

  void _showCompleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: Icon(Icons.spa, color: widget.pattern.accent, size: 36),
        title: const Text('Session complete'),
        content: Text(
          '${widget.minutes} minutes of ${widget.pattern.name}.\nWell breathed.',
          textAlign: TextAlign.center,
        ),
        actions: [
          FilledButton(
            style:
                FilledButton.styleFrom(backgroundColor: widget.pattern.accent),
            onPressed: () {
              Navigator.pop(ctx); // close dialog
              Navigator.pop(context); // close session
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  // --- UI ----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final p = widget.pattern;
    final text = Theme.of(context).textTheme;
    final remaining = _totalSeconds - _elapsed;

    return Scaffold(
      appBar: AppBar(
        title: Text(p.name),
        actions: [
          IconButton(
            tooltip: 'End session',
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            // Animated orb driven by the AnimationController.
            AnimatedBuilder(
              animation: _orb,
              builder: (context, _) {
                final t = Curves.easeInOut.transform(_orb.value);
                final scale = _fromScale + (_toScale - _fromScale) * t;
                return BreathingOrb(
                  scale: scale,
                  color: p.accent,
                  phaseLabel: _phase.label,
                  countdown: _phaseSecondsLeft.clamp(0, 999),
                );
              },
            ),
            const Spacer(),
            Text(
              'Time remaining  ${_fmt(remaining)}',
              style: text.bodyMedium,
            ),
            const SizedBox(height: 6),
            LinearProgressIndicator(
              value: _totalSeconds == 0 ? 0 : _elapsed / _totalSeconds,
              minHeight: 4,
              backgroundColor: p.accent.withOpacity(0.15),
              color: p.accent,
            ),
            const SizedBox(height: 28),
            // Pause / resume.
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: p.accent,
                minimumSize: const Size(180, 52),
              ),
              icon: Icon(_running ? Icons.pause : Icons.play_arrow),
              label: Text(_running ? 'Pause' : 'Resume'),
              onPressed: _finished
                  ? null
                  : () => _running ? _pause() : _resume(),
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  String _fmt(int seconds) {
    final m = (seconds ~/ 60).toString();
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
