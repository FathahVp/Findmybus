import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bus_provider.dart';
import '../widgets/search_bar_widget.dart';
import 'passenger_screen.dart';
import 'driver_screen.dart';
import 'cell_tower_screen.dart';
import 'crowdsource_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tabIndex = 0;

  final List<({String label, IconData icon})> _tabs = [
    (label: 'Passenger', icon: Icons.person),
    (label: 'Driver',    icon: Icons.directions_bus),
    (label: 'Cell Tower',icon: Icons.cell_tower),
    (label: 'Community', icon: Icons.people),
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BusProvider>();
    final bus = provider.selectedBus!;
    final route = provider.routeFor(bus);

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF16A34A), Color(0xFF15803D)]),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.directions_bus, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 10),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('BusTrack Kerala', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                      Text('Perinthalmanna Region', style: TextStyle(color: Color(0xFF475569), fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),

            // ── Search ──────────────────────────────────────────────────
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: BusSearchBar(),
            ),
            const SizedBox(height: 8),

            // ── Selected bus strip ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  border: Border.all(color: Colors.white.withOpacity(0.06)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8, height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: bus.status == 'running' ? const Color(0xFF4ADE80) : const Color(0xFFF59E0B),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(bus.id, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                    const SizedBox(width: 8),
                    Text(route.short, style: const TextStyle(color: Color(0xFF475569), fontSize: 12)),
                    const Spacer(),
                    // Bus switcher dots
                    ...provider.buses.map((b) => GestureDetector(
                      onTap: () => provider.selectBus(b),
                      child: Container(
                        width: 8, height: 8, margin: const EdgeInsets.only(left: 5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: provider.selectedBus?.id == b.id
                            ? (b.status == 'running' ? const Color(0xFF4ADE80) : const Color(0xFFF59E0B))
                            : Colors.white.withOpacity(0.15),
                        ),
                      ),
                    )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            // ── Tab bar ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: List.generate(_tabs.length, (i) {
                    final selected = _tabIndex == i;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _tabIndex = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: selected ? Colors.white.withOpacity(0.1) : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              Icon(_tabs[i].icon, size: 18,
                                color: selected ? Colors.white : const Color(0xFF475569)),
                              const SizedBox(height: 2),
                              Text(_tabs[i].label,
                                style: TextStyle(
                                  fontSize: 9, fontWeight: FontWeight.w700,
                                  color: selected ? Colors.white : const Color(0xFF475569),
                                )),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // ── Content ─────────────────────────────────────────────────
            Expanded(
              child: IndexedStack(
                index: _tabIndex,
                children: const [
                  PassengerScreen(),
                  DriverScreen(),
                  CellTowerScreen(),
                  CrowdsourceScreen(),
                ],
              ),
            ),
          ],
        ),
      ),

      // ── Alarm overlay ────────────────────────────────────────────────
      floatingActionButton: provider.alarmActive ? _AlarmOverlay() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class _AlarmOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.read<BusProvider>();
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: Colors.black.withOpacity(0.85),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120, height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(colors: [Color(0xFFEF4444), Color(0xFFB91C1C)]),
              boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.4), blurRadius: 40, spreadRadius: 10)],
            ),
            child: const Center(child: Text('🔔', style: TextStyle(fontSize: 52))),
          ),
          const SizedBox(height: 24),
          const Text('അലാറം!', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text(provider.alarmStop ?? '', style: const TextStyle(color: Color(0xFFFCA5A5), fontSize: 18)),
          const SizedBox(height: 6),
          const Text('അടുത്ത് വരുന്നു!', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => provider.dismissAlarm(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF0F172A),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
            ),
            child: const Text('✅  ശരി, മനസ്സിലായി', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
