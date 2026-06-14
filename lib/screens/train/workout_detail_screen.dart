import 'package:flutter/material.dart';

import '../../models/workout.dart';
import '../../theme/app_theme.dart';
import '../../widgets/video_player_widget.dart';
import 'workout_session_screen.dart';

/// Overview of a workout: its exercises, with a preview video for each,
/// plus a button to begin the hands-free guided session.
class WorkoutDetailScreen extends StatelessWidget {
  final Workout workout;
  const WorkoutDetailScreen({super.key, required this.workout});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(workout.title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        children: [
          Text(workout.description, style: text.bodyLarge),
          const SizedBox(height: 16),
          for (var i = 0; i < workout.exercises.length; i++)
            _ExerciseTile(
              index: i + 1,
              exercise: workout.exercises[i],
            ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start guided session'),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => WorkoutSessionScreen(workout: workout),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ExerciseTile extends StatelessWidget {
  final int index;
  final Exercise exercise;
  const _ExerciseTile({required this.index, required this.exercise});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: AppTheme.accent.withOpacity(0.18),
                  child: Text('$index',
                      style: const TextStyle(
                          color: AppTheme.accent,
                          fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 10),
                Expanded(
                    child: Text(exercise.name, style: text.titleMedium)),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(exercise.target,
                      style: const TextStyle(
                          color: AppTheme.accent,
                          fontWeight: FontWeight.w600,
                          fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Each exercise carries a real, working video.
            ExerciseVideo(exercise: exercise),
            const SizedBox(height: 12),
            for (final step in exercise.instructions)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('•  '),
                    Expanded(child: Text(step, style: text.bodyMedium)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
