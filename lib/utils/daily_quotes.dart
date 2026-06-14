/// A rotating set of calming lines. One is chosen per calendar day so the
/// dashboard greeting changes daily but stays the same all day.
class DailyQuotes {
  DailyQuotes._();

  static const List<String> _lines = [
    'The journey of a thousand miles begins beneath one’s feet.',
    'Be not afraid of growing slowly; be afraid only of standing still.',
    'When walking, walk. When eating, eat.',
    'A still mind reflects the world as it is.',
    'Ten thousand repetitions, and the technique performs itself.',
    'The strong have no need to prove their strength.',
    'Empty your cup so that it may be filled.',
    'Fall down seven times, stand up eight.',
    'The breath is the bridge between body and mind.',
    'Patience is the companion of wisdom.',
    'Soft overcomes hard; slow overcomes fast.',
    'Begin again, gently, without judgement.',
    'Roots grow deep in stillness.',
    'The quieter you become, the more you can hear.',
  ];

  /// Returns today's line, stable for the whole calendar day.
  static String today() {
    final now = DateTime.now();
    final dayOfYear =
        now.difference(DateTime(now.year, 1, 1)).inDays; // 0-based
    return _lines[dayOfYear % _lines.length];
  }
}
