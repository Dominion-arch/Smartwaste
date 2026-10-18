import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/api.dart';

class CitizenState extends ChangeNotifier {
  List<Report> reports = [];
  List<Pickup> pickups = [];
  bool loading = true;
  String? error;
  bool _disposed = false;

  /// Points are derived from the rows themselves, so they can't be tampered with client-side.
  int get score => reports.length * Report.points + pickups.length * Pickup.points;

  String get level => score >= 750
      ? 'ECO CHAMPION'
      : score >= 400
          ? 'ECO WARRIOR'
          : score >= 150
              ? 'ECO RISING'
              : 'ECO STARTER';

  List<Activity> get activity {
    final list = <Activity>[
      ...reports.map((r) => Activity('📢', 'Reported: ${r.type}', Report.points, r.createdAt)),
      ...pickups.map((p) => Activity('📅', 'Pickup: ${p.wasteType}', Pickup.points, p.createdAt)),
    ]..sort((a, b) => b.time.compareTo(a.time));
    return list;
  }

  Future<void> load() async {
    try {
      final r = await Api.myReports();
      final p = await Api.myPickups();
      reports = r;
      pickups = p;
      error = null;
    } catch (e) {
      error = 'Could not load your data.';
    }
    loading = false;
    if (!_disposed) notifyListeners();
  }

  Future<void> submitReport({
    required String type, required String zone,
    required String description, required String urgency,
  }) async {
    await Api.addReport(type: type, zone: zone, description: description, urgency: urgency);
    await load();
  }

  Future<void> schedulePickup({
    required String wasteType, required DateTime date,
    required String timeSlot, required String notes,
  }) async {
    await Api.addPickup(wasteType: wasteType, date: date, timeSlot: timeSlot, notes: notes);
    await load();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
