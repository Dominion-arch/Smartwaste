import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../config.dart';
import '../../models/models.dart';
import '../../state/auth_controller.dart';
import '../../state/citizen_state.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';

class ReportTab extends StatefulWidget {
  const ReportTab({super.key});
  @override
  State<ReportTab> createState() => _ReportTabState();
}

class _ReportTabState extends State<ReportTab> {
  final _desc = TextEditingController();
  String? _type;
  String? _zone;
  String _urgency = 'medium';
  bool _busy = false;

  @override
  void dispose() {
    _desc.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_type == null) return toast(context, 'Please select an issue type.');
    if (_desc.text.trim().isEmpty) return toast(context, 'Please add a description.');
    final zone = _zone ?? context.read<AuthController>().profile!.zone;
    setState(() => _busy = true);
    try {
      await context.read<CitizenState>().submitReport(
            type: _type!,
            zone: zone.isEmpty ? AppConfig.zones.first : zone,
            description: _desc.text.trim(),
            urgency: _urgency,
          );
      if (!mounted) return;
      _desc.clear();
      setState(() => _type = null);
      toast(context, '✓ Report submitted! +${Report.points} eco points');
    } catch (_) {
      if (mounted) toast(context, 'Could not submit. Check your connection and try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<AuthController>().profile!;
    final reports = context.watch<CitizenState>().reports;
    final zoneValue = _zone ??
        (AppConfig.zones.contains(profile.zone) ? profile.zone : AppConfig.zones.first);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Panel(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const PanelTitle('Report an Issue'),
            DropdownButtonFormField<String>(
              initialValue: _type,
              dropdownColor: C.surface2,
              decoration: const InputDecoration(labelText: 'ISSUE TYPE'),
              hint: const Text('Select type…'),
              items: Report.types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (v) => setState(() => _type = v),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: zoneValue,
              dropdownColor: C.surface2,
              decoration: const InputDecoration(labelText: 'ZONE / LOCATION'),
              items: AppConfig.zones.map((z) => DropdownMenuItem(value: z, child: Text(z))).toList(),
              onChanged: (v) => setState(() => _zone = v),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _desc,
              maxLines: 4,
              minLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                  labelText: 'DESCRIPTION', hintText: 'Describe the issue clearly…', alignLabelWithHint: true),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _urgency,
              dropdownColor: C.surface2,
              decoration: const InputDecoration(labelText: 'URGENCY'),
              items: const [
                DropdownMenuItem(value: 'low', child: Text('Low — can wait a few days')),
                DropdownMenuItem(value: 'medium', child: Text('Medium — needs attention soon')),
                DropdownMenuItem(value: 'high', child: Text('High — health / safety risk')),
              ],
              onChanged: (v) => setState(() => _urgency = v ?? 'medium'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _busy ? null : _submit,
              child: _busy
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text('Submit Report (+${Report.points} pts)'),
            ),
          ]),
        ),
        Panel(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const PanelTitle('My Reports'),
            if (reports.isEmpty)
              const EmptyState('📭', 'No reports yet.')
            else
              ...reports.map(_item),
          ]),
        ),
      ],
    );
  }

  Widget _item(Report r) {
    final (label, color) = switch (r.status) {
      'resolved' => ('✓ Resolved', C.accent),
      'review' => ('In Review', C.info),
      _ => ('Pending', C.warn),
    };
    final desc = r.description.length > 80 ? '${r.description.substring(0, 80)}…' : r.description;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: C.surface2,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: C.border),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(Report.icon(r.type), style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(r.type, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            Text('${r.zone} · ${r.urgency} urgency', style: mono(size: 11)),
            if (desc.isNotEmpty) Text(desc, style: mono(size: 11)),
            const SizedBox(height: 2),
            Text(DateFormat('dd MMM, HH:mm').format(r.createdAt), style: mono(size: 10)),
          ]),
        ),
        const SizedBox(width: 8),
        Pill(label, color),
      ]),
    );
  }
}
