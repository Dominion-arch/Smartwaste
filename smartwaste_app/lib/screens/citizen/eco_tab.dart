import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../state/citizen_state.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';
import 'home_tab.dart' show ActivityRow;

class EcoTab extends StatelessWidget {
  const EcoTab({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<CitizenState>();
    final pct = (s.score / 1000).clamp(0.0, 1.0);
    final feed = s.activity.take(8).toList();

    return RefreshIndicator(
      color: C.purple,
      onRefresh: s.load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Panel(
            child: Column(children: [
              const Align(alignment: Alignment.centerLeft, child: PanelTitle('🌱 My Eco Score')),
              Text('${s.score}', style: mono(size: 56, color: C.accent, weight: FontWeight.w700)),
              Text('Total Points', style: const TextStyle(fontSize: 12, color: C.text3)),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: pct, minHeight: 8, backgroundColor: C.surface2, color: C.accent),
              ),
              const SizedBox(height: 6),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('0', style: mono(size: 10)),
                Text(s.level, style: mono(size: 10, color: C.accent)),
                Text('1000', style: mono(size: 10)),
              ]),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: _count('${s.reports.length}', 'Reports filed', C.purple)),
                const SizedBox(width: 10),
                Expanded(child: _count('${s.pickups.length}', 'Pickups booked', C.info)),
              ]),
            ]),
          ),
          Panel(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const PanelTitle('🏆 Activity Feed'),
              if (feed.isEmpty) const EmptyState('🌱', 'No activity yet.') else ...feed.map((a) => ActivityRow(a)),
            ]),
          ),
          Panel(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const PanelTitle('Earn Points'),
              _earn('📢', 'Report an issue', '+${Report.points} pts'),
              _earn('📅', 'Schedule a pickup', '+${Pickup.points} pts'),
              const SizedBox(height: 4),
              Text('More ways to earn are coming soon.', style: mono(size: 11)),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _count(String v, String label, Color c) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: C.surface2, borderRadius: BorderRadius.circular(10)),
        child: Column(children: [
          Text(v, style: mono(size: 22, color: c, weight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(label, style: mono(size: 11)),
        ]),
      );

  Widget _earn(String icon, String title, String pts) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: C.surface2,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: C.border),
        ),
        child: Row(children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
          Text(pts, style: mono(size: 11, color: C.accent, weight: FontWeight.w700)),
        ]),
      );
}
