import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/api.dart';

class DriverState extends ChangeNotifier {
  Set<String> collectedToday = {};
  int allTime = 0;
  bool loading = true;
  bool _disposed = false;

  static DateTime get _startOfToday {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  Future<void> load() async {
    try {
      collectedToday = await Api.collectedSince(_startOfToday);
      allTime = await Api.totalCollected();
    } catch (_) {}
    loading = false;
    if (!_disposed) notifyListeners();
  }

  /// Same rule as the web driver portal: own-zone bins first, plus any other
  /// zone's bins at >= 70 %, highest fill first, capped at 20 stops.
  static List<Bin> stopsFor(List<Bin> bins, String zone) {
    final target = zone.trim();
    final online = bins.where((b) => b.sensorOk).toList();
    final inZone = online
        .where((b) => b.zone.trim().toLowerCase() == target.toLowerCase())
        .toList();
    final outside = online
        .where((b) => b.zone.trim().toLowerCase() != target.toLowerCase() && b.fill >= 70)
        .toList();
    final all = [...inZone, ...outside]
      ..sort((a, b) => b.fill.compareTo(a.fill));
    return all.take(20).toList();
  }

  bool isDone(String binId) => collectedToday.contains(binId);

  /// Throws on failure so the UI can show an error.
  Future<void> markCollected(String binId) async {
    await Api.markCollected(binId);
    collectedToday = {...collectedToday, binId};
    allTime += 1;
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
