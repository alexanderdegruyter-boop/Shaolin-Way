/// A single exercise within a workout.
class Exercise {
  final String name;
  final List<String> instructions;

  /// "youtube" or "local".
  final String videoType;

  /// YouTube video ID (for youtube) or asset path (for local).
  final String videoSource;

  /// If the exercise is time-based, the number of seconds to hold/perform.
  final int? durationSeconds;

  /// If the exercise is rep-based, the target number of reps.
  final int? reps;

  /// Rest in seconds after this exercise before the next one.
  final int restSeconds;

  const Exercise({
    required this.name,
    required this.instructions,
    required this.videoType,
    required this.videoSource,
    required this.durationSeconds,
    required this.reps,
    required this.restSeconds,
  });

  bool get isYouTube => videoType == 'youtube';
  bool get isTimed => durationSeconds != null && durationSeconds! > 0;

  /// Human-readable target, e.g. "45s" or "15 reps".
  String get target {
    if (isTimed) return '${durationSeconds}s';
    if (reps != null) return '$reps reps';
    return '';
  }

  factory Exercise.fromJson(Map<String, dynamic> json) => Exercise(
        name: json['name'] as String,
        instructions:
            (json['instructions'] as List).map((e) => e as String).toList(),
        videoType: json['videoType'] as String,
        videoSource: json['videoSource'] as String,
        durationSeconds: json['durationSeconds'] as int?,
        reps: json['reps'] as int?,
        restSeconds: (json['restSeconds'] as int?) ?? 0,
      );
}

/// A workout: a named, ordered sequence of exercises.
class Workout {
  final String id;
  final String title;
  final String category;

  /// Beginner / Intermediate / Advanced.
  final String level;
  final String description;
  final List<Exercise> exercises;

  const Workout({
    required this.id,
    required this.title,
    required this.category,
    required this.level,
    required this.description,
    required this.exercises,
  });

  /// Rough estimated minutes, used on cards.
  int get estimatedMinutes {
    var seconds = 0;
    for (final e in exercises) {
      seconds += (e.durationSeconds ?? 40) + e.restSeconds;
    }
    return (seconds / 60).ceil();
  }

  factory Workout.fromJson(Map<String, dynamic> json) => Workout(
        id: json['id'] as String,
        title: json['title'] as String,
        category: json['category'] as String,
        level: json['level'] as String,
        description: json['description'] as String,
        exercises: (json['exercises'] as List)
            .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
