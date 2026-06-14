import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

import '../models/breathing_pattern.dart';
import '../models/workout.dart';
import '../models/book.dart';

/// Loads all bundled content (breathing patterns, workouts, books) from the
/// asset JSON/Markdown files. Keeping this in one place means the rest of the
/// app never touches asset loading directly.
class ContentService {
  // Simple in-memory caches so we only parse each file once per launch.
  List<BreathingPattern>? _breathing;
  List<Workout>? _workouts;
  List<Book>? _books;

  Future<List<BreathingPattern>> loadBreathingPatterns() async {
    if (_breathing != null) return _breathing!;
    final raw = await rootBundle.loadString('assets/data/breathing.json');
    final list = json.decode(raw) as List;
    _breathing = list
        .map((e) => BreathingPattern.fromJson(e as Map<String, dynamic>))
        .toList();
    return _breathing!;
  }

  Future<List<Workout>> loadWorkouts() async {
    if (_workouts != null) return _workouts!;
    final raw = await rootBundle.loadString('assets/data/workouts.json');
    final map = json.decode(raw) as Map<String, dynamic>;
    final list = map['workouts'] as List;
    _workouts =
        list.map((e) => Workout.fromJson(e as Map<String, dynamic>)).toList();
    return _workouts!;
  }

  Future<List<Book>> loadBooks() async {
    if (_books != null) return _books!;
    final raw = await rootBundle.loadString('assets/books/manifest.json');
    final map = json.decode(raw) as Map<String, dynamic>;
    final list = map['books'] as List;
    _books = list.map((e) => Book.fromJson(e as Map<String, dynamic>)).toList();
    return _books!;
  }

  /// Load the raw markdown text for a chapter.
  Future<String> loadChapterMarkdown(String assetPath) {
    return rootBundle.loadString(assetPath);
  }

  /// All distinct workout categories, in first-seen order.
  Future<List<String>> workoutCategories() async {
    final workouts = await loadWorkouts();
    final seen = <String>[];
    for (final w in workouts) {
      if (!seen.contains(w.category)) seen.add(w.category);
    }
    return seen;
  }
}
