import 'package:latlong2/latlong.dart';

/// Same Supabase project the admin dashboard uses (js/supabase.js).
/// The anon key is a public client key by design. Override at build time with:
///   flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
class AppConfig {
  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://mbvaxutvtvamczlmcjdo.supabase.co',
  );
  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1idmF4dXR2dHZhbWN6bG1jamRvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODA2NzYzMDYsImV4cCI6MjA5NjI1MjMwNn0.rUA8fHNlcF5xL0XpuOnvHdRbEYvmrELxL_A3qwbVrj0',
  );

  /// Zones used by the web citizen portal.
  static const zones = <String>[
    'Fiapre', 'Berlin', 'Abesim', 'Nsuatre',
    'Chiraa', 'Odumasi', 'Sunyanikrom', 'Sunyani Central',
  ];

  /// Map fallback (Sunyani) when no bin has coordinates.
  static const defaultCenter = LatLng(7.3349, -2.3123);

  static const pollSeconds = 15; // same refresh rate as the dashboard
}
