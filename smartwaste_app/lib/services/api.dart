import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

/// Every network call the app makes lives here.
class Api {
  static SupabaseClient get _c => Supabase.instance.client;

  // ── Shared: sensor data written by the ESP8266 / read by the dashboard ──
  static Future<List<Bin>> bins() async {
    final rows = await _c.from('bins').select().order('fill', ascending: false);
    return rows.map<Bin>((e) => Bin.fromJson(e)).toList();
  }

  // ── Profile ──
  static Future<Profile?> profile(String userId) async {
    final row = await _c.from('profiles').select().eq('id', userId).maybeSingle();
    return row == null ? null : Profile.fromJson(row);
  }

  // ── Citizen ──
  static Future<List<Report>> myReports() async {
    final rows = await _c.from('reports').select().order('created_at', ascending: false);
    return rows.map<Report>((e) => Report.fromJson(e)).toList();
  }

  static Future<void> addReport({
    required String type, required String zone,
    required String description, required String urgency,
  }) async {
    await _c.from('reports').insert({
      'type': type, 'zone': zone, 'description': description, 'urgency': urgency,
    });
  }

  static Future<List<Pickup>> myPickups() async {
    final rows = await _c.from('pickups').select().order('created_at', ascending: false);
    return rows.map<Pickup>((e) => Pickup.fromJson(e)).toList();
  }

  static Future<void> addPickup({
    required String wasteType, required DateTime date,
    required String timeSlot, required String notes,
  }) async {
    final d = '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
    await _c.from('pickups').insert({
      'waste_type': wasteType, 'pickup_date': d, 'time_slot': timeSlot, 'notes': notes,
    });
  }

  // ── Driver ──
  static Future<Set<String>> collectedSince(DateTime since) async {
    final rows = await _c
        .from('collections')
        .select('bin_id')
        .gte('collected_at', since.toUtc().toIso8601String());
    return rows.map<String>((r) => '${r['bin_id']}').toSet();
  }

  static Future<int> totalCollected() async {
    final rows = await _c.from('collections').select('id');
    return rows.length;
  }

  static Future<void> markCollected(String binId) async {
    await _c.from('collections').insert({'bin_id': binId});
  }
}
