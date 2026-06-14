import 'package:flutter_test/flutter_test.dart';
import 'package:shaolin_way/utils/daily_quotes.dart';

void main() {
  test('Daily quote is non-empty and stable within a day', () {
    final a = DailyQuotes.today();
    final b = DailyQuotes.today();
    expect(a, isNotEmpty);
    expect(a, equals(b));
  });
}
