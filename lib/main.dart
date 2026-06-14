import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'services/app_state.dart';
import 'services/content_service.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';
import 'screens/root_nav.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Offline key/value storage for progress + settings.
  await Hive.initFlutter();

  // Local notifications (daily reminder).
  final notifications = NotificationService();
  await notifications.init();

  // Persisted app state + bundled content loader.
  final appState = await AppState.create(notifications);
  final content = ContentService();

  runApp(ShaolinWayApp(appState: appState, content: content));
}

class ShaolinWayApp extends StatelessWidget {
  final AppState appState;
  final ContentService content;

  const ShaolinWayApp({
    super.key,
    required this.appState,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: appState),
        Provider.value(value: content),
      ],
      child: Consumer<AppState>(
        builder: (context, state, _) {
          return MaterialApp(
            title: 'Shaolin Way',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: state.themeMode,
            home: const RootNav(),
          );
        },
      ),
    );
  }
}
