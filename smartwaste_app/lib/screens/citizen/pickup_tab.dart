import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../state/citizen_state.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';

class PickupTab extends StatefulWidget {
  const PickupTab({super.key});
  @override
  State<PickupTab> createState() => _PickupTabState();
}

class _PickupTabState extends State<PickupTab> {
  final _notes = TextEditingController();
  String _type = Pickup.wasteTypes.first;
  String _slot = Pickup.timeSlots.first;
  DateTime _date = DateTime.now().add(const Duration(days: 1));
  bool _busy = false;

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(now.year, now.month, now.day).add(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 90)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _submit() async {
    setState(() => _busy = true);
    try {
      await context.read<CitizenState>().schedulePickup(
            wasteType: _type, date: _date, timeSlot: _slot, notes: _notes.text.trim());
      if (!mounted) return;
      _notes.clear();
      toast(context, '✓ Pickup scheduled! +${Pickup.points} eco points');
    } catch (_) {
      if (mounted) toast(context, 'Could not schedule. Check your connection and try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pickups = context.watch<CitizenState>().pickups;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Panel(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const PanelTitle('Schedule a Bulk Pickup'),
            DropdownButtonFormField<String>(
              initialValue: _type,
              isExpanded: true,
              dropdownColor: C.surface2,
              decoration: const InputDecoration(labelText: 'WASTE TYPE'),
              items: Pickup.wasteTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (v) => setState(() => _type = v ?? _type),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(10),
              child: InputDecorator(
                decoration: const InputDecoration(
                    labelText: 'PICKUP DATE', suffixIcon: Icon(Icons.calendar_today, size: 18, color: C.text3)),
                child: Text(DateFormat('EEE, dd MMM yyyy').format(_date)),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _slot,
              isExpanded: true,
              dropdownColor: C.surface2,
              decoration: const InputDecoration(labelText: 'PREFERRED TIME'),
              items: Pickup.timeSlots.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (v) => setState(() => _slot = v ?? _slot),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notes,
              maxLines: 3,
              minLines: 2,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                  labelText: 'NOTES (OPTIONAL)', hintText: 'Any special instructions…', alignLabelWithHint: true),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _busy ? null : _submit,
              child: _busy
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text('Schedule Pickup (+${Pickup.points} pts)'),
            ),
          ]),
        ),
        Panel(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const PanelTitle('My Pickups'),
            if (pickups.isEmpty)
              const EmptyState('📅', 'No pickups scheduled yet.')
            else
              ...pickups.map(_item),
          ]),
        ),
      ],
    );
  }

  Widget _item(Pickup p) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: C.surface2,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: C.border),
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: C.purple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: C.purple.withValues(alpha: 0.2)),
            ),
            child: Column(children: [
              Text('${p.date.day}', style: mono(size: 18, color: C.purple, weight: FontWeight.w700)),
              Text(DateFormat('MMM').format(p.date).toUpperCase(), style: mono(size: 9)),
            ]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(p.wasteType, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
              Text(p.timeSlot, style: mono(size: 11)),
              if (p.notes.isNotEmpty) Text(p.notes, style: mono(size: 11), maxLines: 2, overflow: TextOverflow.ellipsis),
            ]),
          ),
          Pill(p.status, C.purple),
        ]),
      );
}
