import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../state/auth_controller.dart';
import '../../state/bins_state.dart';
import '../../state/citizen_state.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';

class HomeTab extends StatelessWidget {
  final void Function(int tabIndex) onGo;
  const HomeTab({super.key, required this.onGo});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<AuthController>().profile!;
    final binsState = context.watch<BinsState>();
    final citizen = context.watch<CitizenState>();

    final zoneBins = binsState.inZone(profile.zone);
    final over = zoneBins.where((b) => b.fill >= 80).length;
    final shown = (zoneBins.isNotEmpty ? zoneBins : binsState.bins).take(8).toList();
    final acts = citizen.activity.take(4).toList();

    return RefreshIndicator(
      color: C.purple,
      onRefresh: () async {
        await Future.wait([binsState.refresh(), citizen.load()]);
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Panel(
            borderColor: C.purple.withValues(alpha: 0.25),
            color: C.purple.withValues(alpha: 0.06),
            child: Row(children: [
              const Text('📱', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(profile.name.isEmpty ? 'Citizen' : profile.name,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  Text('${profile.zone.isEmpty ? '—' : profile.zone} · Member', style: mono(size: 11)),
                ]),
              ),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                const MonoLabel('Eco score'),
                Text('${citizen.score}',
                    style: mono(size: 22, color: C.accent, weight: FontWeight.w700)),
              ]),
            ]),
          ),
          Row(children: [
            Expanded(
              child: StatTile(
                label: 'Your Zone',
                value: profile.zone.isEmpty ? '—' : profile.zone,
                color: C.purple,
                sub: over > 0 ? '⚠ $over need attention' : '✓ All clear',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: StatTile(
                label: 'Bins Near You',
                value: '${zoneBins.isNotEmpty ? zoneBins.length : binsState.bins.length}',
                color: C.accent,
                sub: '$over at risk',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: StatTile(
                label: 'City Avg',
                value: '${binsState.avgFill}%',
                color: C.info,
                sub: 'all zones',
              ),
            ),
          ]),
          const SizedBox(height: 12),
          Panel(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const PanelTitle('Bins in Your Zone'),
              if (!binsState.loaded)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator(color: C.purple, strokeWidth: 2)),
                )
              else if (shown.isEmpty)
                const EmptyState('📡', 'No bin data yet — sensors may still be coming online.')
              else
                ...shown.map((b) => BinRow(id: b.id, subtitle: '${b.zone} · ${b.type}', fill: b.fill)),
            ]),
          ),
          Panel(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const PanelTitle('Quick Actions'),
              _action('📢  Report an Issue', '+50 pts', () => onGo(1)),
              _action('📅  Schedule Pickup', '+30 pts', () => onGo(2)),
              _action('♻️  Recycling Guide', null, () => onGo(3)),
              _action('🌱  My Eco Impact', null, () => onGo(4)),
            ]),
          ),
          Panel(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const PanelTitle('Recent Activity'),
              if (acts.isEmpty)
                Text('No activity yet.', style: mono(size: 12))
              else
                ...acts.map((a) => ActivityRow(a)),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _action(String label, String? pts, VoidCallback onTap) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: C.purple.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: C.purple.withValues(alpha: 0.2)),
            ),
            child: Row(children: [
              Expanded(
                child: Text(label,
                    style: const TextStyle(color: C.purple, fontWeight: FontWeight.w700, fontSize: 13)),
              ),
              if (pts != null) Text(pts, style: mono(size: 12, color: C.accent)),
            ]),
          ),
        ),
      );
}

class ActivityRow extends StatelessWidget {
  final Activity a;
  const ActivityRow(this.a, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(children: [
          Text(a.icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(a.title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              Text(DateFormat('dd MMM, HH:mm').format(a.time), style: mono(size: 10)),
            ]),
          ),
          Text('+${a.points}', style: mono(size: 12, color: C.accent, weight: FontWeight.w700)),
        ]),
      );
}
