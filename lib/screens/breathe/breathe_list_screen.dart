import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/breathing_pattern.dart';
import '../../services/content_service.dart';
import 'breathing_session_screen.dart';

/// Library of breathing patterns.
class BreatheListScreen extends StatelessWidget {
  const BreatheListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final content = context.read<ContentService>();
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Breathe')),
      body: FutureBuilder<List<BreathingPattern>>(
        future: content.loadBreathingPatterns(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final patterns = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            itemCount: patterns.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, i) {
              final p = patterns[i];
              return _PatternCard(pattern: p, text: text);
            },
          );
        },
      ),
    );
  }
}

class _PatternCard extends StatelessWidget {
  final BreathingPattern pattern;
  final TextTheme text;
  const _PatternCard({required this.pattern, required this.text});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _openDetails(context),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: pattern.accent.withOpacity(0.18),
                ),
                child: Icon(Icons.air, color: pattern.accent),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(pattern.name, style: text.titleMedium),
                    const SizedBox(height: 2),
                    Text(pattern.subtitle, style: text.bodyMedium),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  void _openDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _PatternDetailsSheet(pattern: pattern),
    );
  }
}

/// Bottom sheet showing instructions, the "why", a length picker, and Start.
class _PatternDetailsSheet extends StatefulWidget {
  final BreathingPattern pattern;
  const _PatternDetailsSheet({required this.pattern});

  @override
  State<_PatternDetailsSheet> createState() => _PatternDetailsSheetState();
}

class _PatternDetailsSheetState extends State<_PatternDetailsSheet> {
  late int _minutes = widget.pattern.defaultMinutes;

  @override
  Widget build(BuildContext context) {
    final p = widget.pattern;
    final text = Theme.of(context).textTheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 16, 22, 22),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(p.name, style: text.headlineSmall),
              Text(p.subtitle, style: text.bodyMedium),
              const SizedBox(height: 16),
              Text(p.description, style: text.bodyLarge),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: p.accent.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.lightbulb_outline, color: p.accent, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Why this helps', style: text.titleMedium),
                          const SizedBox(height: 4),
                          Text(p.why, style: text.bodyMedium),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Text('Session length', style: text.titleMedium),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: _minutes.toDouble(),
                      min: 1,
                      max: 20,
                      divisions: 19,
                      label: '$_minutes min',
                      activeColor: p.accent,
                      onChanged: (v) => setState(() => _minutes = v.round()),
                    ),
                  ),
                  SizedBox(
                    width: 64,
                    child: Text('$_minutes min',
                        textAlign: TextAlign.right, style: text.titleMedium),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: p.accent),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Begin'),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BreathingSessionScreen(
                          pattern: p,
                          minutes: _minutes,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
