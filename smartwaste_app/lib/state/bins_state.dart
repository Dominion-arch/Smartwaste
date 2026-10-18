import 'dart:async';
import 'package:flutter/foundation.dart';
import '../config.dart';
import '../models/models.dart';
import '../services/api.dart';

/// Live bin data — polled every 15 s, exactly like the web dashboard.
class BinsState extends ChangeNotifier {
  List<Bin> bins = [];
  bool connected = false;
  bool loaded = false;
  Timer? _timer;
  bool _disposed = false;

  void start() {
    stop();
    refresh();
    _timer = Timer.periodic(const Duration(seconds: AppConfig.pollSeconds), (_) => refresh());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> refresh() async {
    try {
      bins = await Api.bins();
      connected = true;
    } catch (_) {
      connected = false;
    }
    loaded = true;
    if (!_disposed) notifyListeners();
  }

  List<Bin> inZone(String zone) => bins.where((b) => b.zone == zone).toList();

  int get overflowRisk => bins.where((b) => b.fill >= 80).length;

  double get avgFill {
    final online = bins.where((b) => b.sensorOk).toList();
    if (online.isEmpty) return 0;
    final avg = online.fold<double>(0, (s, b) => s + b.fill) / online.length;
    return double.parse(avg.toStringAsFixed(1));
  }

  @override
  void dispose() {
    _disposed = true;
    stop();
    super.dispose();
  }
}
