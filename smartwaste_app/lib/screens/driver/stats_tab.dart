import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../state/auth_controller.dart';
import '../../state/driver_state.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';

class StatsTab extends StatelessWidget {
  final List<Bin> stops;
  const StatsTab({super.key, required this.stops});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<AuthController>().profile!;
    final driver = context.watch<DriverState>();

    final done = stops.where((s) => driver.isDone(s.id)).length;
    final total = stops.length;
    final urgentLeft = stops.where((s) => s.fill >= 90 && !driver.isDone(s.id)).length;
    final zones = stops.map((b) => b.zone).toSet().toList()..sort();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(children: [
          Expanded(child: StatTile(label: 'Collected today', value: '$done', color: C.accent, sub: 'of $total stops')),
          const SizedBox(width: 10),
          Expanded(child: StatTile(label: 'Urgent left', value: '$urgentLeft', color: C.danger)),
          const SizedBox(width: 10),
          Expanded(child: StatTile(label: 'All time', value: '${driver.allTime}', color: C.info, sub: 'bins')),
        ]),
        const SizedBox(height: 12),
        Panel(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const PanelTitle('Assignment'),
            _row('Truck', profile.truckId.isEmpty ? '—' : profile.truckId),
            _row('Route', profile.route.isEmpty ? '—' : profile.route),
            _row('Zone', profile.zone.isEmpty ? '—' : profile.zone),
            _row('Email', profile.email.isEmpty ? '—' : profile.email),
          ]),
        ),
        Panel(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const PanelTitle('Zone Coverage'),
            if (zones.isEmpty)
              Text('No stops yet.', style: mono(size: 12))
            else
              Wrap(spacing: 8, runSpacing: 8, children: [
                for (final z in zones) _zoneChip(z),
              ]),
          ]),
        ),
      ],
    );
  }

  Widget _zoneChip(String z) {
    final inZone = stops.where((b) => b.zone == z).toList();
    // Reads collected state via a Builder so this stays const-free but rebuilds with the provider.
    return Builder(builder: (context) {
      final driver = context.watch<DriverState>();
      final d = inZone.where((b) => driver.isDone(b.id)).length;
      final col = d == inZone.length ? C.accent : d > 0 ? C.warn : C.text3;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: C.surface2,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: C.border),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(z, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: col)),
          Text('$d/${inZone.length} done', style: mono(size: 11)),
        ]),
      );
    });
  }

  Widget _row(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(k.toUpperCase(), style: mono(size: 11)),
          Flexible(child: Text(v, textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
        ]),
      );
}
