import 'package:flutter_test/flutter_test.dart';
import 'package:smartwaste_app/models/models.dart';
import 'package:smartwaste_app/state/citizen_state.dart';
import 'package:smartwaste_app/state/driver_state.dart';

Bin bin(String id, String zone, double fill, {bool ok = true}) => Bin(
      id: id, zone: zone, type: 'General', fill: fill,
      lat: 0, lng: 0, sensorOk: ok, lastUpdate: DateTime(2026),
    );

void main() {
  group('DriverState.stopsFor', () {
    test('own zone first, other zones only when >= 70%, offline sensors skipped', () {
      final stops = DriverState.stopsFor([
        bin('A', 'Fiapre', 20),
        bin('B', 'Berlin', 95),
        bin('C', 'Berlin', 40),
        bin('D', 'Fiapre', 85, ok: false),
        bin('E', 'Fiapre', 60),
      ], 'Fiapre');
      expect(stops.map((b) => b.id).toList(), ['B', 'E', 'A']);
    });

    test('capped at 20 stops', () {
      final many = List.generate(30, (i) => bin('B$i', 'Fiapre', i.toDouble()));
      expect(DriverState.stopsFor(many, 'Fiapre').length, 20);
    });
  });

  group('CitizenState eco score', () {
    test('50 per report + 30 per pickup, level thresholds', () {
      final s = CitizenState();
      expect(s.score, 0);
      expect(s.level, 'ECO STARTER');
      s.reports = List.generate(
        3,
        (i) => Report(id: i, type: 'Other', zone: 'Fiapre', description: '',
            urgency: 'low', status: 'pending', createdAt: DateTime(2026)),
      );
      s.pickups = [
        Pickup(id: 1, wasteType: 'General Waste', timeSlot: 'Any time', notes: '',
            status: 'scheduled', date: DateTime(2026), createdAt: DateTime(2026)),
      ];
      expect(s.score, 180);
      expect(s.level, 'ECO RISING');
    });
  });
}
