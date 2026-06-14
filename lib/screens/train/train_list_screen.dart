import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/workout.dart';
import '../../services/content_service.dart';
import '../../theme/app_theme.dart';
import 'workout_detail_screen.dart';

class TrainListScreen extends StatefulWidget {
  const TrainListScreen({super.key});

  @override
  State<TrainListScreen> createState() => _TrainListScreenState();
}

class _TrainListScreenState extends State<TrainListScreen> {
  static const _levels = ['All', 'Beginner', 'Intermediate', 'Advanced'];
  String _level = 'All';

  @override
  Widget build(BuildContext context) {
    final content = context.read<ContentService>();
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Train')),
      body: FutureBuilder<List<Workout>>(
        future: content.loadWorkouts(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final all = snapshot.data!;
          final filtered = _level == 'All'
              ? all
              : all.where((w) => w.level == _level).toList();

          // Group by category, preserving order.
          final categories = <String>[];
          for (final w in filtered) {
            if (!categories.contains(w.category)) categories.add(w.category);
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
            children: [
              // Level filter chips.
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _levels.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final lvl = _levels[i];
                    final selected = lvl == _level;
                    return ChoiceChip(
                      label: Text(lvl),
                      selected: selected,
                      onSelected: (_) => setState(() => _level = lvl),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              if (filtered.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 60),
                  child: Center(
                    child: Text('No workouts at this level yet.',
                        style: text.bodyMedium),
                  ),
                ),
              for (final cat in categories) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 16, 0, 10),
                  child: Text(cat, style: text.titleMedium),
                ),
                for (final w in filtered.where((w) => w.category == cat))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _WorkoutCard(workout: w),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _WorkoutCard extends StatelessWidget {
  final Workout workout;
  const _WorkoutCard({required this.workout});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => WorkoutDetailScreen(workout: workout),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(workout.title, style: text.titleMedium),
                  ),
                  _LevelBadge(level: workout.level),
                ],
              ),
              const SizedBox(height: 6),
              Text(workout.description, style: text.bodyMedium),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.fitness_center,
                      size: 16, color: AppTheme.accent),
                  const SizedBox(width: 6),
                  Text('${workout.exercises.length} exercises',
                      style: text.bodyMedium),
                  const SizedBox(width: 16),
                  Icon(Icons.schedule, size: 16, color: AppTheme.accent),
                  const SizedBox(width: 6),
                  Text('~${workout.estimatedMinutes} min',
                      style: text.bodyMedium),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LevelBadge extends StatelessWidget {
  final String level;
  const _LevelBadge({required this.level});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (level) {
      case 'Advanced':
        color = const Color(0xFFC25B45);
        break;
      case 'Intermediate':
        color = const Color(0xFFB07D4B);
        break;
      default:
        color = AppTheme.accent;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        level,
        style: TextStyle(
            color: color, fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }
}
