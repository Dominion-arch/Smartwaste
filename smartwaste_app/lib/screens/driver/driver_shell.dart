import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/auth_controller.dart';
import '../../state/bins_state.dart';
import '../../state/driver_state.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';
import 'stops_tab.dart';
import 'map_tab.dart';
import 'stats_tab.dart';

class DriverShell extends StatelessWidget {
  const DriverShell({super.key});
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (_) => DriverState()..load(),
        child: const _DriverScaffold(),
      );
}

class _DriverScaffold extends StatefulWidget {
  const _DriverScaffold();
  @override
  State<_DriverScaffold> createState() => _DriverScaffoldState();
}

class _DriverScaffoldState extends State<_DriverScaffold> {
  int _index = 0;
  late final BinsState _bins;

  static const _titles = ['My Stops', 'Route Map', 'My Stats'];
  static const _subs = [
    'Live fill levels from connected bins',
    'Visual overview of your stops',
    'Performance & assignment info',
  ];

  @override
  void initState() {
    super.initState();
    _bins = context.read<BinsState>()..start();
  }

  @override
  void dispose() {
    _bins.stop();
    super.dispose();
  }

  Future<void> _confirmSignOut() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: C.surface,
        title: const Text('Sign out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sign Out')),
        ],
      ),
    );
    if (ok == true && mounted) context.read<AuthController>().signOut();
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<AuthController>().profile!;
    final binsState = context.watch<BinsState>();
    final driver = context.watch<DriverState>();
    final stops = DriverState.stopsFor(binsState.bins, profile.zone);
    final urgent = stops.where((s) => s.fill >= 90 && !driver.isDone(s.id)).length;

    final pages = <Widget>[
      StopsTab(stops: stops),
      MapTab(stops: stops),
      StatsTab(stops: stops),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          const Logo(color: C.info),
          const SizedBox(width: 10),
          ConnDot(live: binsState.connected),
        ]),
        actions: [
          if (profile.route.isNotEmpty)
            Center(child: Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Pill(profile.route, C.info),
            )),
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout, size: 20, color: C.text2),
            onPressed: _confirmSignOut,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_titles[_index], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              Text(
                _index == 0
                    ? '${profile.name.isEmpty ? 'Driver' : profile.name} · ${profile.truckId.isEmpty ? 'TRK-?' : profile.truckId} · ${profile.zone.isEmpty ? '—' : profile.zone}'
                    : _subs[_index],
                style: const TextStyle(fontSize: 12, color: C.text3),
              ),
            ]),
          ),
          Expanded(child: IndexedStack(index: _index, children: pages)),
        ]),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: [
          BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: urgent > 0,
              label: Text('$urgent'),
              backgroundColor: C.danger,
              child: const Icon(Icons.local_shipping_outlined),
            ),
            label: 'Stops',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: 'Map'),
          const BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Stats'),
        ],
      ),
    );
  }
}
