import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/auth_controller.dart';
import '../theme.dart';
import '../widgets/widgets.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('♻️', style: TextStyle(fontSize: 44)),
            SizedBox(height: 10),
            Logo(color: C.accent, size: 28),
            SizedBox(height: 24),
            SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: C.accent)),
          ]),
        ),
      );
}

class _NoticeScreen extends StatelessWidget {
  final String icon, title, body;
  const _NoticeScreen({required this.icon, required this.title, required this.body});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(icon, style: const TextStyle(fontSize: 44)),
                const SizedBox(height: 14),
                Text(title, textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                Text(body, textAlign: TextAlign.center, style: const TextStyle(color: C.text2, height: 1.4)),
                const SizedBox(height: 24),
                SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: () => context.read<AuthController>().signOut(),
                    child: const Text('Sign Out'),
                  ),
                ),
              ]),
            ),
          ),
        ),
      );
}

/// Admins keep using the existing web dashboard — the mobile app is citizen + driver only.
class AdminUseWebScreen extends StatelessWidget {
  const AdminUseWebScreen({super.key});
  @override
  Widget build(BuildContext context) => const _NoticeScreen(
        icon: '🖥️',
        title: 'Admin accounts use the web dashboard',
        body: 'This app is for citizens and drivers. Please sign in to the SmartWaste admin dashboard in your browser.',
      );
}

class ProfileMissingScreen extends StatelessWidget {
  const ProfileMissingScreen({super.key});
  @override
  Widget build(BuildContext context) => const _NoticeScreen(
        icon: '⚠️',
        title: 'Account profile not found',
        body: 'You are signed in, but your profile could not be loaded. Check your connection, '
            'or ask your administrator to confirm the database setup script has been run.',
      );
}
