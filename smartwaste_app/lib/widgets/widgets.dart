import 'package:flutter/material.dart';
import '../theme.dart';

class Panel extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color? borderColor;
  final Color? color;
  const Panel({
    super.key, required this.child,
    this.padding = const EdgeInsets.all(16), this.borderColor, this.color,
  });

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: padding,
        decoration: BoxDecoration(
          color: color ?? C.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor ?? C.border),
        ),
        child: child,
      );
}

class PanelTitle extends StatelessWidget {
  final String text;
  const PanelTitle(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
      );
}

class MonoLabel extends StatelessWidget {
  final String text;
  final Color color;
  const MonoLabel(this.text, {super.key, this.color = C.text3});
  @override
  Widget build(BuildContext context) =>
      Text(text.toUpperCase(), style: mono(size: 10, color: color));
}

class StatTile extends StatelessWidget {
  final String label, value;
  final String? sub;
  final Color color;
  const StatTile({
    super.key, required this.label, required this.value, required this.color, this.sub,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: C.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: C.border),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          MonoLabel(label),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
          ),
          if (sub != null) ...[
            const SizedBox(height: 4),
            Text(sub!, style: const TextStyle(fontSize: 11, color: C.text3)),
          ],
        ]),
      );
}

class Pill extends StatelessWidget {
  final String text;
  final Color color;
  const Pill(this.text, this.color, {super.key});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(text.toUpperCase(), style: mono(size: 9, color: color, weight: FontWeight.w700)),
      );
}

class EmptyState extends StatelessWidget {
  final String icon, message;
  const EmptyState(this.icon, this.message, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(icon, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 10),
            Text(message, textAlign: TextAlign.center, style: mono(size: 12)),
          ]),
        ),
      );
}

class BinRow extends StatelessWidget {
  final String id, subtitle;
  final double fill;
  const BinRow({super.key, required this.id, required this.subtitle, required this.fill});

  @override
  Widget build(BuildContext context) {
    final col = C.fill(fill);
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: C.surface2,
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: col, width: 3)),
      ),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(id, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            Text(subtitle, style: mono(size: 11)),
          ]),
        ),
        Text('${fill.round()}%', style: mono(size: 13, color: col, weight: FontWeight.w700)),
      ]),
    );
  }
}

class ConnDot extends StatelessWidget {
  final bool live;
  const ConnDot({super.key, required this.live});
  @override
  Widget build(BuildContext context) {
    final c = live ? C.accent : C.danger;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 7, height: 7, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
      const SizedBox(width: 5),
      Text(live ? 'LIVE' : 'OFFLINE', style: mono(size: 10, color: c, weight: FontWeight.w700)),
    ]);
  }
}

class Logo extends StatelessWidget {
  final Color color;
  final double size;
  const Logo({super.key, required this.color, this.size = 18});
  @override
  Widget build(BuildContext context) => Text.rich(TextSpan(
        style: TextStyle(fontSize: size, fontWeight: FontWeight.w800),
        children: [const TextSpan(text: 'Smart'), TextSpan(text: 'Waste', style: TextStyle(color: color))],
      ));
}

void toast(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
