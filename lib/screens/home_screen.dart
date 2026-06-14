import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/daily_quotes.dart';
import 'root_nav.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  /// A simple rotating daily suggestion.
  String _suggestion() {
    const suggestions = [
      'Start with 5 minutes of Box Breathing.',
      'Hold the Horse Stance and build your roots.',
      'Flow through the Eight Pieces of Brocade.',
      'Wind down with the 4-7-8 Calming Breath.',
      'Read a chapter of A Short History of Shaolin.',
      'Practise Deep Dan Tian Breathing.',
      'Explore the Five Animals of Shaolin.',
      'Move through the Strength & Conditioning set.',
      'Read about Qi in The Way of Qi.',
    ];
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    return suggestions[dayOfYear % suggestions.length];
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final text = Theme.of(context).textTheme;
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 18
            ? 'Good afternoon'
            : 'Good evening';

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            Text(greeting, style: text.bodyMedium),
            const SizedBox(height: 2),
            Text('Shaolin Way', style: text.displaySmall),
            const SizedBox(height: 20),

            // Rotating calming line for the day.
            _QuoteCard(line: DailyQuotes.today()),
            const SizedBox(height: 20),

            // Stats row: streak + total minutes.
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.local_fire_department_outlined,
                    value: '${state.streak}',
                    label: state.streak == 1 ? 'day streak' : 'day streak',
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _StatCard(
                    icon: Icons.timer_outlined,
                    value: '${state.totalMinutes}',
                    label: 'total minutes',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Today's suggestion.
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.wb_twilight, color: AppTheme.accent),
                        const SizedBox(width: 8),
                        Text("Today's practice", style: text.titleMedium),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(_suggestion(), style: text.bodyLarge),
                    if (state.practisedToday) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.check_circle,
                              size: 18,
                              color: AppTheme.accent.withOpacity(0.9)),
                          const SizedBox(width: 6),
                          Text('Practised today — well done.',
                              style: text.bodyMedium),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            Text('Quick start', style: text.titleMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                _QuickStart(
                  icon: Icons.air,
                  label: 'Breathe',
                  onTap: () => RootNav.go(context, 1),
                ),
                const SizedBox(width: 12),
                _QuickStart(
                  icon: Icons.self_improvement,
                  label: 'Train',
                  onTap: () => RootNav.go(context, 2),
                ),
                const SizedBox(width: 12),
                _QuickStart(
                  icon: Icons.menu_book,
                  label: 'Read',
                  onTap: () => RootNav.go(context, 3),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuoteCard extends StatelessWidget {
  final String line;
  const _QuoteCard({required this.line});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.accent.withOpacity(0.16),
            AppTheme.accent.withOpacity(0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.format_quote, color: AppTheme.accent),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              line,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.italic,
                    height: 1.4,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _StatCard(
      {required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.accent, size: 28),
            const SizedBox(height: 8),
            Text(value, style: text.headlineSmall),
            Text(label, style: text.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _QuickStart extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickStart(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 22),
            child: Column(
              children: [
                Icon(icon, color: AppTheme.accent, size: 30),
                const SizedBox(height: 10),
                Text(label, style: text.titleMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
