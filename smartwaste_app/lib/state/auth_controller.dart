import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../models/models.dart';
import '../services/api.dart';

class AuthController extends ChangeNotifier {
  final sb.SupabaseClient _c = sb.Supabase.instance.client;
  StreamSubscription<sb.AuthState>? _sub;

  Profile? profile;
  bool signedIn = false;
  bool initializing = true;
  bool _disposed = false;

  Future<void> init() async {
    _sub = _c.auth.onAuthStateChange.listen((data) {
      _apply(data.session);
    });
    // Covers the case where a session is already restored before we subscribed.
    await _apply(_c.auth.currentSession);
  }

  Future<void> _apply(sb.Session? session) async {
    if (session == null) {
      signedIn = false;
      profile = null;
    } else {
      signedIn = true;
      try {
        profile = await Api.profile(session.user.id);
      } catch (_) {
        profile = null;
      }
    }
    initializing = false;
    if (!_disposed) notifyListeners();
  }

  /// Returns an error message, or null on success.
  Future<String?> signIn(String email, String password) async {
    try {
      await _c.auth.signInWithPassword(email: email.trim(), password: password);
      return null;
    } on sb.AuthException catch (e) {
      return e.message;
    } catch (_) {
      return 'Could not reach the server. Check your connection.';
    }
  }

  /// Citizens only. Returns (error, needsEmailConfirmation).
  Future<(String?, bool)> signUp({
    required String name, required String email,
    required String zone, required String password,
  }) async {
    try {
      final res = await _c.auth.signUp(
        email: email.trim(),
        password: password,
        data: {'name': name.trim(), 'zone': zone},
      );
      return (null, res.session == null);
    } on sb.AuthException catch (e) {
      return (e.message, false);
    } catch (_) {
      return ('Could not reach the server. Check your connection.', false);
    }
  }

  Future<void> signOut() => _c.auth.signOut();

  @override
  void dispose() {
    _disposed = true;
    _sub?.cancel();
    super.dispose();
  }
}
