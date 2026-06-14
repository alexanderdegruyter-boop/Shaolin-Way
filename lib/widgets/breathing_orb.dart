import 'package:flutter/material.dart';

/// A soft, layered orb that scales between [minScale] and 1.0.
///
/// The session screen drives [scale] (0..1) so the orb expands on inhale,
/// holds steady, and contracts on exhale — perfectly synced to the timer.
class BreathingOrb extends StatelessWidget {
  /// Current scale factor in the range [minScale]..1.0.
  final double scale;
  final Color color;
  final String phaseLabel;
  final int countdown;
  final double maxDiameter;

  const BreathingOrb({
    super.key,
    required this.scale,
    required this.color,
    required this.phaseLabel,
    required this.countdown,
    this.maxDiameter = 280,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final diameter = maxDiameter * scale;

    return SizedBox(
      width: maxDiameter,
      height: maxDiameter,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Faint outer ring marking the full inhale size.
          Container(
            width: maxDiameter,
            height: maxDiameter,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.18), width: 1.5),
            ),
          ),
          // Soft glow halo.
          Container(
            width: diameter * 1.08,
            height: diameter * 1.08,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.12),
            ),
          ),
          // The breathing orb itself.
          Container(
            width: diameter,
            height: diameter,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  color.withOpacity(0.95),
                  color.withOpacity(0.6),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.35),
                  blurRadius: 40,
                  spreadRadius: 4,
                ),
              ],
            ),
          ),
          // Phase label + countdown in the centre.
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                phaseLabel,
                textAlign: TextAlign.center,
                style: text.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  shadows: const [
                    Shadow(color: Colors.black26, blurRadius: 4),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$countdown',
                style: text.displaySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w300,
                  fontSize: 44,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
