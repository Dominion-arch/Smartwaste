import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/auth_controller.dart';
import '../../state/bins_state.dart';
import '../../state/citizen_state.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';
import 'home_tab.dart';
import 'report_tab.dart';
import 'pickup_tab.dart';
import 'recycle_tab.dart';
import 'eco_tab.dart';

class CitizenShell extends StatelessWidget {
  const CitizenShell({super.key});
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (_) => CitizenState()..load(),
        child: const _CitizenScaffold(),
      );
}

class _CitizenScaffold extends StatefulWidget {
  const _CitizenScaffold();
  @override
  State<_CitizenScaffold> createState() => _CitizenScaffoldState();
}

class _CitizenScaffoldState extends State<_CitizenScaffold> {
  int _index = 0;
  late final BinsState _bins;

  static const _titles = ['Home', 'Report an Issue', 'Schedule Pickup', 'Recycling Guide', 'My Eco Impact'];

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
    final live = context.select<BinsState, bool>((b) => b.connected);
    final pages = <Widget>[
      HomeTab(onGo: (i) => setState(() => _index = i)),
      const ReportTab(),
      const PickupTab(),
      const RecycleTab(),
      const EcoTab(),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          const Logo(color: C.purple),
          const SizedBox(width: 10),
          ConnDot(live: live),
        ]),
        actions: [
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
            child: Text(_titles[_index],
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          ),
          Expanded(child: IndexedStack(index: _index, children: pages)),
        ]),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.campaign_outlined), label: 'Report'),
          BottomNavigationBarItem(icon: Icon(Icons.event_outlined), label: 'Pickup'),
          BottomNavigationBarItem(icon: Icon(Icons.recycling), label: 'Recycle'),
          BottomNavigationBarItem(icon: Icon(Icons.eco_outlined), label: 'Eco'),
        ],
      ),
    );
  }
}
