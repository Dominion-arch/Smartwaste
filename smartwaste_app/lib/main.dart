import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config.dart';
import 'state/auth_controller.dart';
import 'state/bins_state.dart';
import 'theme.dart';
import 'screens/login_screen.dart';
import 'screens/notice_screens.dart';
import 'screens/citizen/citizen_shell.dart';
import 'screens/driver/driver_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    publishableKey: AppConfig.supabaseAnonKey,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()..init()),
        ChangeNotifierProvider(create: (_) => BinsState()),
      ],
      child: const SmartWasteApp(),
    ),
  );
}

class SmartWasteApp extends StatelessWidget {
  const SmartWasteApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final role = auth.profile?.role;
    // Citizen = purple, driver = blue, everything else = green (matches the web portals).
    final primary = role == 'citizen'
        ? C.purple
        : role == 'driver'
            ? C.info
            : C.accent;

    Widget home;
    if (auth.initializing) {
      home = const SplashScreen();
    } else if (!auth.signedIn) {
      home = const LoginScreen();
    } else if (auth.profile == null) {
      home = const ProfileMissingScreen();
    } else {
      switch (auth.profile!.role) {
        case 'citizen':
          home = const CitizenShell();
          break;
        case 'driver':
          home = const DriverShell();
          break;
        default:
          home = const AdminUseWebScreen();
      }
    }

    return MaterialApp(
      title: 'SmartWaste',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(primary),
      home: home,
    );
  }
}
