// ── driver_screen.dart ────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bus_provider.dart';

class DriverScreen extends StatelessWidget {
  const DriverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BusProvider>();
    final bus = provider.selectedBus!;
    final route = provider.routeFor(bus);
    final isOn = bus.status == 'running';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Text('🚌  Driver App — ${bus.id}',
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11, letterSpacing: 2)),
            const SizedBox(height: 20),

            // Big toggle
            GestureDetector(
              onTap: () => provider.toggleDriverStatus(bus),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 100, height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: isOn
                    ? [const Color(0xFF16A34A), const Color(0xFF15803D)]
                    : [const Color(0xFF374151), const Color(0xFF1F2937)]),
                  border: Border.all(color: isOn ? const Color(0xFF4ADE80) : const Color(0xFF374151), width: 3),
                  boxShadow: isOn ? [BoxShadow(color: const Color(0xFF16A34A).withOpacity(0.5), blurRadius: 30)] : [],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(isOn ? '📡' : '⭕', style: const TextStyle(fontSize: 28)),
                    Text(isOn ? 'ON' : 'OFF',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(isOn ? 'Location sharing active' : 'Tap to start sharing',
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),

            if (isOn) ...[
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => provider.advanceBus(bus),
                child: Container(
                  width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)]),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(child: Text('▶  Next Stop Simulate',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14))),
                ),
              ),
            ],

            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(10),
              ),
              child: GridView.count(
                crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 3,
                children: [
                  _InfoTile('Route', route.short),
                  _InfoTile('Driver', bus.driver),
                  _InfoTile('Network', '2G / Cell Tower'),
                  _InfoTile('Battery', '87%'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label, value;
  const _InfoTile(this.label, this.value);
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(label, style: const TextStyle(color: Color(0xFF475569), fontSize: 10)),
      Text(value, style: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 12, fontWeight: FontWeight.w700)),
    ],
  );
}
