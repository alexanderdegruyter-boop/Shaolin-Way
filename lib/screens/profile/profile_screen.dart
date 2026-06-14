import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/app_state.dart';
import '../../services/notification_service.dart';
import '../../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          // --- Stats ---
          Text('Your practice', style: text.titleMedium),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _Stat(
                  icon: Icons.local_fire_department_outlined,
                  value: '${state.streak}',
                  label: 'day streak',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _Stat(
                  icon: Icons.timer_outlined,
                  value: '${state.totalMinutes}',
                  label: 'total minutes',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _Stat(
                  icon: Icons.check_circle_outline,
                  value: '${state.sessionCount}',
                  label: 'sessions',
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // --- Settings ---
          Text('Settings', style: text.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                // Theme
                ListTile(
                  leading: const Icon(Icons.brightness_6_outlined),
                  title: const Text('Theme'),
                  trailing: DropdownButton<ThemeMode>(
                    value: state.themeMode,
                    underline: const SizedBox.shrink(),
                    onChanged: (m) {
                      if (m != null) state.themeMode = m;
                    },
                    items: const [
                      DropdownMenuItem(
                          value: ThemeMode.system, child: Text('System')),
                      DropdownMenuItem(
                          value: ThemeMode.light, child: Text('Light')),
                      DropdownMenuItem(
                          value: ThemeMode.dark, child: Text('Dark')),
                    ],
                  ),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.volume_up_outlined),
                  title: const Text('Sound cues'),
                  value: state.soundEnabled,
                  activeColor: AppTheme.accent,
                  onChanged: (v) => state.soundEnabled = v,
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.vibration),
                  title: const Text('Haptic feedback'),
                  value: state.hapticsEnabled,
                  activeColor: AppTheme.accent,
                  onChanged: (v) => state.hapticsEnabled = v,
                ),
                const Divider(height: 1),
                // Default session length
                ListTile(
                  leading: const Icon(Icons.hourglass_empty),
                  title: const Text('Default session length'),
                  subtitle: Text('${state.defaultSessionMinutes} minutes'),
                  trailing: SizedBox(
                    width: 140,
                    child: Slider(
                      value: state.defaultSessionMinutes.toDouble(),
                      min: 1,
                      max: 20,
                      divisions: 19,
                      activeColor: AppTheme.accent,
                      label: '${state.defaultSessionMinutes}',
                      onChanged: (v) =>
                          state.defaultSessionMinutes = v.round(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // --- Daily reminder ---
          Text('Daily reminder', style: text.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.notifications_outlined),
                  title: const Text('Remind me to practise'),
                  value: state.reminderEnabled,
                  activeColor: AppTheme.accent,
                  onChanged: (v) =>
                      state.setReminder(enabled: v, time: state.reminderTime),
                ),
                if (state.reminderEnabled) ...[
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.access_time),
                    title: const Text('Reminder time'),
                    trailing: Text(formatTimeOfDay(state.reminderTime),
                        style: text.titleMedium),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: state.reminderTime,
                      );
                      if (picked != null) {
                        await state.setReminder(enabled: true, time: picked);
                      }
                    },
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 28),
          Center(
            child: Text(
              'Shaolin Way · personal practice\nv1.0.0',
              textAlign: TextAlign.center,
              style: text.labelSmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _Stat(
      {required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.accent),
            const SizedBox(height: 8),
            Text(value, style: text.headlineSmall),
            Text(label,
                textAlign: TextAlign.center, style: text.labelSmall),
          ],
        ),
      ),
    );
  }
}
