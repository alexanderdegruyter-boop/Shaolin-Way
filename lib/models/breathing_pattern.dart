import 'package:flutter/material.dart';

/// One phase of a breathing cycle (e.g. "Inhale" for 4 seconds).
class BreathPhase {
  final String label;
  final int seconds;

  /// One of: inhale, hold, exhale, holdEmpty.
  /// Drives how the orb animates (expand / stay big / contract / stay small).
  final String type;

  const BreathPhase({
    required this.label,
    required this.seconds,
    required this.type,
  });

  factory BreathPhase.fromJson(Map<String, dynamic> json) => BreathPhase(
        label: json['label'] as String,
        seconds: json['seconds'] as int,
        type: json['type'] as String,
      );

  bool get isInhale => type == 'inhale';
  bool get isExhale => type == 'exhale';
  bool get isHold => type == 'hold' || type == 'holdEmpty';
}

/// A complete guided breathing pattern (e.g. Box Breathing).
class BreathingPattern {
  final String id;
  final String name;
  final String subtitle;
  final String description;
  final String why;
  final int defaultMinutes;
  final Color accent;
  final List<BreathPhase> phases;

  const BreathingPattern({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.description,
    required this.why,
    required this.defaultMinutes,
    required this.accent,
    required this.phases,
  });

  /// Total seconds in one full cycle through all phases.
  int get cycleSeconds => phases.fold(0, (sum, p) => sum + p.seconds);

  factory BreathingPattern.fromJson(Map<String, dynamic> json) {
    return BreathingPattern(
      id: json['id'] as String,
      name: json['name'] as String,
      subtitle: json['subtitle'] as String,
      description: json['description'] as String,
      why: json['why'] as String,
      defaultMinutes: (json['defaultMinutes'] as int?) ?? 5,
      accent: _parseHexColor(json['accent'] as String? ?? '#6B8F71'),
      phases: (json['phases'] as List)
          .map((e) => BreathPhase.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Parse a "#RRGGBB" string into a [Color].
Color _parseHexColor(String hex) {
  final cleaned = hex.replaceAll('#', '').trim();
  final value = int.parse(cleaned, radix: 16);
  return Color(0xFF000000 | value);
}
