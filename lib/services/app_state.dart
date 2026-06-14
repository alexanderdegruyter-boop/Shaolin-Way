import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'notification_service.dart';

/// Central, persisted application state: settings + practice progress.
///
/// Everything is stored in a single Hive box of primitive values, so there are
/// no Hive adapters to generate. Call [AppState.create] once at startup.
class AppState extends ChangeNotifier {
  final Box _box;
  final NotificationService _notifications;

  AppState._(this._box, this._notifications);

  static Future<AppState> create(NotificationService notifications) async {
    final box = await Hive.openBox('shaolin_way');
    return AppState._(box, notifications);
  }

  // ---------------------------------------------------------------------------
  // Settings
  // ---------------------------------------------------------------------------

  ThemeMode get themeMode {
    switch (_box.get('themeMode', defaultValue: 'system')) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  set themeMode(ThemeMode mode) {
    _box.put('themeMode', mode.name);
    notifyListeners();
  }

  bool get soundEnabled => _box.get('sound', defaultValue: true) as bool;
  set soundEnabled(bool v) {
    _box.put('sound', v);
    notifyListeners();
  }

  bool get hapticsEnabled => _box.get('haptics', defaultValue: true) as bool;
  set hapticsEnabled(bool v) {
    _box.put('haptics', v);
    notifyListeners();
  }

  int get defaultSessionMinutes =>
      _box.get('defaultMinutes', defaultValue: 5) as int;
  set defaultSessionMinutes(int v) {
    _box.put('defaultMinutes', v);
    notifyListeners();
  }

  // ---- Daily reminder ----
  bool get reminderEnabled =>
      _box.get('reminderEnabled', defaultValue: false) as bool;

  TimeOfDay get reminderTime => TimeOfDay(
        hour: _box.get('reminderHour', defaultValue: 8) as int,
        minute: _box.get('reminderMinute', defaultValue: 0) as int,
      );

  Future<void> setReminder({required bool enabled, TimeOfDay? time}) async {
    final t = time ?? reminderTime;
    await _box.put('reminderEnabled', enabled);
    await _box.put('reminderHour', t.hour);
    await _box.put('reminderMinute', t.minute);
    if (enabled) {
      await _notifications.scheduleDailyReminder(hour: t.hour, minute: t.minute);
    } else {
      await _notifications.cancelDailyReminder();
    }
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Reader preferences
  // ---------------------------------------------------------------------------

  /// "light" | "sepia" | "dark"
  String get readerTheme =>
      _box.get('readerTheme', defaultValue: 'sepia') as String;
  set readerTheme(String v) {
    _box.put('readerTheme', v);
    notifyListeners();
  }

  double get readerFontSize =>
      (_box.get('readerFontSize', defaultValue: 18.0) as num).toDouble();
  set readerFontSize(double v) {
    _box.put('readerFontSize', v.clamp(12.0, 30.0));
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Progress / stats
  // ---------------------------------------------------------------------------

  int get totalMinutes => _box.get('totalMinutes', defaultValue: 0) as int;
  int get sessionCount => _box.get('sessionCount', defaultValue: 0) as int;
  int get streak => _box.get('streak', defaultValue: 0) as int;
  String? get lastPracticeDate => _box.get('lastPracticeDate') as String?;

  /// Records a completed session of [minutes] and updates the streak.
  Future<void> recordSession(int minutes) async {
    await _box.put('totalMinutes', totalMinutes + minutes);
    await _box.put('sessionCount', sessionCount + 1);
    _updateStreak();
    notifyListeners();
  }

  void _updateStreak() {
    final today = _dateKey(DateTime.now());
    final last = lastPracticeDate;
    if (last == today) return; // already practised today
    final yesterday = _dateKey(DateTime.now().subtract(const Duration(days: 1)));
    if (last == yesterday) {
      _box.put('streak', streak + 1);
    } else {
      _box.put('streak', 1); // streak broken (or first ever) → restart at 1
    }
    _box.put('lastPracticeDate', today);
  }

  /// True if a practice has already been logged today.
  bool get practisedToday => lastPracticeDate == _dateKey(DateTime.now());

  // ---------------------------------------------------------------------------
  // Reading position + bookmarks
  // ---------------------------------------------------------------------------

  String? get continueReadingBookId => _box.get('lastBookId') as String?;

  /// Persist the user's place in a book: which chapter and scroll offset.
  Future<void> saveReadingPosition(
    String bookId,
    int chapterIndex,
    double offset,
  ) async {
    await _box.put('lastBookId', bookId);
    await _box.put('pos_${bookId}_chapter', chapterIndex);
    await _box.put('pos_${bookId}_offset', offset);
  }

  int readingChapter(String bookId) =>
      _box.get('pos_${bookId}_chapter', defaultValue: 0) as int;

  double readingOffset(String bookId) =>
      (_box.get('pos_${bookId}_offset', defaultValue: 0.0) as num).toDouble();

  // A bookmark stores a single chapter index per book.
  bool isBookmarked(String bookId, int chapterIndex) =>
      (_box.get('bookmark_$bookId') as int?) == chapterIndex;

  int? bookmarkOf(String bookId) => _box.get('bookmark_$bookId') as int?;

  Future<void> toggleBookmark(String bookId, int chapterIndex) async {
    if (isBookmarked(bookId, chapterIndex)) {
      await _box.delete('bookmark_$bookId');
    } else {
      await _box.put('bookmark_$bookId', chapterIndex);
    }
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String _dateKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}
