import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bus_provider.dart';
import '../models/route_model.dart';
import '../widgets/route_map_widget.dart';

class PassengerScreen extends StatefulWidget {
  const PassengerScreen({super.key});
  @override
  State<PassengerScreen> createState() => _PassengerScreenState();
}

class _PassengerScreenState extends State<PassengerScreen> {
  bool _showAlarmSheet = false;
  int _stopsAway = 2;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BusProvider>();
    final bus = provider.selectedBus!;
    final route = provider.routeFor(bus);
    final stops = route.stops;
    final currentIdx = (bus.progress * (stops.length - 1)).floor().clamp(0, stops.length - 1);
    final nextStop = stops[(currentIdx + 1).clamp(0, stops.length - 1)];
    final remainMin = ((1 - bus.progress) * int.parse(route.duration)).round();
    final eta = bus.status == 'running' ? '$remainMin min' : 'Stopped';
    final routeColor = _hexColor(route.color);

    // Upcoming departures
    final now = TimeOfDay.now();
    final nowMins = now.hour * 60 + now.minute;
    final upcoming = route.departures.where((t) {
      final parts = t.split(':');
      return int.parse(parts[0]) * 60 + int.parse(parts[1]) > nowMins;
    }).take(4).toList();

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Route header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: routeColor.withOpacity(0.1),
                  border: Border.all(color: routeColor.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: routeColor)),
                    const SizedBox(width: 10),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(route.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                        Text('🕐 ${_fmtDuration(route.duration)}  •  🎫 ${route.fare}',
                          style: const TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                      ],
                    )),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Map
              RouteMapWidget(bus: bus, route: route),
              const SizedBox(height: 12),

              // ETA cards
              Row(children: [
                Expanded(child: _InfoCard(label: 'NEXT STOP', value: nextStop, color: const Color(0xFF22D3EE))),
                const SizedBox(width: 10),
                Expanded(child: _InfoCard(
                  label: 'ETA ${stops.last.toUpperCase()}',
                  value: eta,
                  color: bus.status == 'running' ? const Color(0xFF4ADE80) : const Color(0xFFFBBF24),
                )),
              ]),

              if (bus.delay > 0) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('⚠️  ${bus.delay} min delay reported',
                    style: const TextStyle(color: Color(0xFFF87171), fontSize: 12, fontWeight: FontWeight.w700)),
                ),
              ],

              const SizedBox(height: 12),

              // ── ALARM BUTTON ─────────────────────────────────────────
              provider.alarmStop == null
                ? GestureDetector(
                    onTap: () => setState(() => _showAlarmSheet = true),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF1E3A5F), Color(0xFF1E40AF)]),
                        border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('🔔', style: TextStyle(fontSize: 18)),
                          SizedBox(width: 8),
                          Text('Destination Alarm Set ചെയ്യൂ',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                        ],
                      ),
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withOpacity(0.12),
                      border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.35)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Text('🔔', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 10),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(provider.alarmStop!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                            Text('${provider.stopsAwayAlert} stop${provider.stopsAwayAlert > 1 ? "s" : ""} മുൻപ് alert',
                              style: const TextStyle(color: Color(0xFF60A5FA), fontSize: 11)),
                          ],
                        )),
                        TextButton(
                          onPressed: () => provider.cancelAlarm(),
                          child: const Text('Cancel', style: TextStyle(color: Color(0xFFF87171), fontSize: 12)),
                        ),
                        TextButton(
                          onPressed: () => setState(() => _showAlarmSheet = true),
                          child: const Text('Edit', style: TextStyle(color: Color(0xFF60A5FA), fontSize: 12)),
                        ),
                      ],
                    ),
                  ),

              // Upcoming departures
              if (upcoming.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('🕐  NEXT DEPARTURES FROM PERINTHALMANNA',
                  style: TextStyle(color: Color(0xFF475569), fontSize: 10, letterSpacing: 1)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: upcoming.asMap().entries.map((e) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: e.key == 0 ? routeColor.withOpacity(0.2) : Colors.white.withOpacity(0.04),
                      border: Border.all(color: e.key == 0 ? routeColor.withOpacity(0.5) : Colors.white.withOpacity(0.08)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(e.value,
                      style: TextStyle(color: e.key == 0 ? Colors.white : const Color(0xFF64748B),
                        fontWeight: e.key == 0 ? FontWeight.w700 : FontWeight.w400, fontSize: 13)),
                  )).toList(),
                ),
              ],

              // Stops list
              const SizedBox(height: 16),
              const Text('UPCOMING STOPS', style: TextStyle(color: Color(0xFF475569), fontSize: 11, letterSpacing: 1)),
              const SizedBox(height: 8),
              ...stops.skip(currentIdx).toList().asMap().entries.map((e) {
                final isNext = e.key == 0;
                final isAlarm = stops[currentIdx + e.key] == provider.alarmStop;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Container(
                        width: 8, height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isNext ? const Color(0xFF22D3EE) : Colors.white.withOpacity(0.15),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Text(e.value,
                        style: TextStyle(color: isNext ? Colors.white : const Color(0xFF64748B), fontSize: 13))),
                      if (isAlarm) const Text('🔔', style: TextStyle(fontSize: 14)),
                      if (isNext) const Text('Next ›', style: TextStyle(color: Color(0xFF22D3EE), fontSize: 11)),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),

        // ── Alarm bottom sheet ──────────────────────────────────────────
        if (_showAlarmSheet)
          GestureDetector(
            onTap: () => setState(() => _showAlarmSheet = false),
            child: Container(color: Colors.black.withOpacity(0.6)),
          ),
        if (_showAlarmSheet)
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
              decoration: const BoxDecoration(
                color: Color(0xFF1E293B),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Row(
                      children: [
                        const Text('🔔  ഏത് stop-ൽ അലാറം?',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                        const Spacer(),
                        IconButton(onPressed: () => setState(() => _showAlarmSheet = false),
                          icon: const Icon(Icons.close, color: Color(0xFF64748B))),
                      ],
                    ),
                  ),
                  // Stops ahead
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('എത്ര stops മുൻപ് alert?',
                            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                          const SizedBox(height: 8),
                          Row(
                            children: [1, 2, 3].map((n) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: GestureDetector(
                                onTap: () => setState(() => _stopsAway = n),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: _stopsAway == n ? const Color(0xFF3B82F6) : Colors.white.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text('$n stop${n > 1 ? "s" : ""} മുൻപ്',
                                    style: TextStyle(color: _stopsAway == n ? Colors.white : const Color(0xFF64748B),
                                      fontWeight: FontWeight.w700, fontSize: 12)),
                                ),
                              ),
                            )).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: stops.length,
                      itemBuilder: (ctx, i) {
                        final passed = i / (stops.length - 1) <= bus.progress;
                        final isSelected = stops[i] == provider.alarmStop;
                        return GestureDetector(
                          onTap: passed ? null : () {
                            context.read<BusProvider>().setAlarm(bus.id, stops[i], _stopsAway);
                            setState(() => _showAlarmSheet = false);
                          },
                          child: Opacity(
                            opacity: passed ? 0.35 : 1,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFF3B82F6).withOpacity(0.15) : Colors.white.withOpacity(0.03),
                                border: Border.all(color: isSelected ? const Color(0xFF3B82F6) : Colors.white.withOpacity(0.06)),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Text(passed ? '✓' : isSelected ? '🔔' : i == stops.length - 1 ? '🏁' : '📍',
                                    style: const TextStyle(fontSize: 18)),
                                  const SizedBox(width: 10),
                                  Expanded(child: Text(stops[i],
                                    style: TextStyle(color: passed ? const Color(0xFF475569) : Colors.white,
                                      fontWeight: FontWeight.w600, fontSize: 13))),
                                  if (i == stops.length - 1 && !passed)
                                    const Text('FINAL', style: TextStyle(color: Color(0xFFF59E0B), fontSize: 10, fontWeight: FontWeight.w700)),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
      ],
    );
  }

  String _fmtDuration(String mins) {
    final m = int.parse(mins);
    return m >= 60 ? '${m ~/ 60}h ${m % 60}m' : '${m}m';
  }

  Color _hexColor(String hex) {
    return Color(int.parse(hex.replaceFirst('#', '0xFF')));
  }
}

class _InfoCard extends StatelessWidget {
  final String label, value;
  final Color color;
  const _InfoCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      border: Border.all(color: color.withOpacity(0.2)),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 10)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13)),
      ],
    ),
  );
}
