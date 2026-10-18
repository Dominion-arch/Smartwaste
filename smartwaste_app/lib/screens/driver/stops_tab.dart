import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/models.dart';
import '../../state/bins_state.dart';
import '../../state/driver_state.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';

class StopsTab extends StatefulWidget {
  final List<Bin> stops;
  const StopsTab({super.key, required this.stops});
  @override
  State<StopsTab> createState() => _StopsTabState();
}

class _StopsTabState extends State<StopsTab> {
  String _filter = 'all';
  final Set<String> _saving = {};

  Future<void> _collect(Bin b) async {
    setState(() => _saving.add(b.id));
    try {
      await context.read<DriverState>().markCollected(b.id);
      if (mounted) toast(context, '✓ ${b.id} marked as collected');
    } catch (_) {
      if (mounted) toast(context, 'Could not save — check your connection and try again.');
    } finally {
      if (mounted) setState(() => _saving.remove(b.id));
    }
  }

  Future<void> _navigate(Bin b) async {
    final uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=${b.lat},${b.lng}&travelmode=driving');
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) toast(context, 'Could not open maps.');
  }

  @override
  Widget build(BuildContext context) {
    final driver = context.watch<DriverState>();
    final binsState = context.watch<BinsState>();
    final stops = widget.stops;

    final total = stops.length;
    final done = stops.where((s) => driver.isDone(s.id)).length;
    final urgent = stops.where((s) => s.fill >= 90 && !driver.isDone(s.id)).length;
    final pct = total == 0 ? 0 : ((done / total) * 100).round();

    final list = switch (_filter) {
      'urgent' => stops.where((s) => s.fill >= 90 && !driver.isDone(s.id)).toList(),
      'pending' => stops.where((s) => !driver.isDone(s.id)).toList(),
      'done' => stops.where((s) => driver.isDone(s.id)).toList(),
      _ => stops,
    };

    return RefreshIndicator(
      color: C.info,
      onRefresh: () async => Future.wait([binsState.refresh(), driver.load()]),
      child: ListView(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: .9,
            children: [
              StatTile(label: 'Stops', value: '$total', color: C.info),
              StatTile(label: 'Done', value: '$done', color: C.accent),
              StatTile(label: 'Urgent', value: '$urgent', color: C.danger),
              StatTile(label: 'Done %', value: '$pct%', color: C.warn),
            ],
          ),
          const SizedBox(height: 12),
          Panel(
            padding: const EdgeInsets.all(14),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const MonoLabel('Shift progress'),
                Text('$done / $total stops', style: mono(size: 11, color: C.text2)),
              ]),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: total == 0 ? 0 : done / total,
                  minHeight: 8, backgroundColor: C.surface2, color: C.info),
              ),
            ]),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              for (final f in const [('all', 'All'), ('urgent', 'Urgent'), ('pending', 'Pending'), ('done', 'Done')])
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(f.$2),
                    selected: _filter == f.$1,
                    onSelected: (_) => setState(() => _filter = f.$1),
                    selectedColor: C.info.withValues(alpha: 0.2),
                    backgroundColor: C.surface2,
                    side: BorderSide(color: _filter == f.$1 ? C.info : C.border2),
                    labelStyle: TextStyle(
                        color: _filter == f.$1 ? C.info : C.text2, fontWeight: FontWeight.w700, fontSize: 12),
                  ),
                ),
            ]),
          ),
          const SizedBox(height: 12),
          if (!binsState.loaded)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator(color: C.info, strokeWidth: 2)),
            )
          else if (stops.isEmpty)
            const EmptyState('📡', 'No bins to show yet.\nStops appear once sensors are online.')
          else if (list.isEmpty)
            EmptyState(
              _filter == 'done' ? '✅' : _filter == 'urgent' ? '🎉' : '📭',
              _filter == 'done'
                  ? 'No collections yet this shift.'
                  : _filter == 'urgent'
                      ? 'No urgent bins right now!'
                      : 'No stops match this filter.',
            )
          else
            ...list.map((b) => _card(b, stops.indexOf(b) + 1, driver.isDone(b.id))),
        ],
      ),
    );
  }

  Widget _card(Bin b, int number, bool done) {
    final col = C.fill(b.fill);
    final tag = b.fill >= 90 ? ('URGENT', C.danger) : b.fill >= 75 ? ('HIGH', C.warn) : null;
    final saving = _saving.contains(b.id);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: C.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: done ? C.border : (tag?.$2.withValues(alpha: 0.4) ?? C.border)),
      ),
      child: Opacity(
        opacity: done ? .6 : 1,
        child: Row(children: [
          Container(
            width: 34, height: 34, alignment: Alignment.center,
            decoration: BoxDecoration(color: col.withValues(alpha: 0.13), borderRadius: BorderRadius.circular(9)),
            child: Text(done ? '✓' : '$number',
                style: mono(size: 13, color: col, weight: FontWeight.w700)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Flexible(child: Text(b.id, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700))),
                if (tag != null && !done) ...[const SizedBox(width: 6), Pill(tag.$1, tag.$2)],
              ]),
              Text('${b.zone} · ${b.type}', style: mono(size: 11)),
              if (done) Text('✓ Collected this shift', style: mono(size: 11, color: C.accent)),
            ]),
          ),
          SizedBox(
            width: 48, height: 48,
            child: Stack(alignment: Alignment.center, children: [
              SizedBox(
                width: 46, height: 46,
                child: CircularProgressIndicator(
                  value: (b.fill / 100).clamp(0.0, 1.0),
                  strokeWidth: 5, backgroundColor: const Color(0xFF1E242E), color: col),
              ),
              Text('${b.fill.round()}%', style: mono(size: 10, color: col, weight: FontWeight.w700)),
            ]),
          ),
          const SizedBox(width: 6),
          if (b.hasLocation)
            IconButton(
              tooltip: 'Navigate',
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.navigation_outlined, color: C.info, size: 22),
              onPressed: () => _navigate(b),
            ),
          if (done)
            const Pill('Done', C.accent)
          else
            SizedBox(
              height: 36,
              child: ElevatedButton(
                onPressed: saving ? null : () => _collect(b),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(72, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: saving
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Collect', style: TextStyle(fontSize: 12)),
              ),
            ),
        ]),
      ),
    );
  }
}
