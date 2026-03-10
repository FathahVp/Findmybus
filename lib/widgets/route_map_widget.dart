// route_map_widget.dart
import 'package:flutter/material.dart';
import '../models/route_model.dart';

class RouteMapWidget extends StatelessWidget {
  final Bus bus;
  final BusRoute route;
  const RouteMapWidget({super.key, required this.bus, required this.route});

  Color get _busColor => bus.status == 'running' ? const Color(0xFF16A34A) : const Color(0xFFF59E0B);

  @override
  Widget build(BuildContext context) {
    final stops = route.stops;
    final n = stops.length - 1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('LIVE ROUTE MAP', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10, letterSpacing: 2)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: _busColor.withOpacity(0.2),
                border: Border.all(color: _busColor),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(children: [
                Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: _busColor)),
                const SizedBox(width: 4),
                Text(bus.status == 'running' ? 'Live' : 'Stopped',
                  style: TextStyle(color: _busColor, fontSize: 11, fontWeight: FontWeight.w700)),
              ]),
            ),
          ]),
          const SizedBox(height: 24),

          // Route line
          LayoutBuilder(builder: (ctx, constraints) {
            final w = constraints.maxWidth;
            return SizedBox(
              height: 60,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Background line
                  Positioned(top: 20, left: 0, right: 0, child: Container(height: 3,
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(4)))),
                  // Progress line
                  Positioned(top: 20, left: 0, child: AnimatedContainer(
                    duration: const Duration(milliseconds: 800),
                    width: w * bus.progress, height: 3,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF22D3EE), Color(0xFF16A34A)]),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  )),
                  // Bus icon
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 800),
                    top: 2, left: (w * bus.progress - 18).clamp(0, w - 36),
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle, color: _busColor,
                        boxShadow: [BoxShadow(color: _busColor.withOpacity(0.5), blurRadius: 14)],
                      ),
                      child: const Center(child: Icon(Icons.directions_bus, color: Colors.white, size: 18)),
                    ),
                  ),
                  // Stop dots + labels
                  ...stops.asMap().entries.map((e) {
                    final x = (e.key / n) * w;
                    final passed = e.key / n <= bus.progress;
                    return Positioned(
                      top: 16,
                      left: x - 5,
                      child: Column(children: [
                        Container(
                          width: 10, height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: passed ? const Color(0xFF22D3EE) : Colors.white.withOpacity(0.3),
                          ),
                        ),
                        const SizedBox(height: 4),
                        SizedBox(
                          width: 50,
                          child: Text(e.value.split(' ')[0],
                            style: TextStyle(
                              color: passed ? const Color(0xFFE2E8F0) : const Color(0xFF64748B),
                              fontSize: 8, fontWeight: passed ? FontWeight.w600 : FontWeight.w400,
                            ),
                            textAlign: TextAlign.center, overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ]),
                    );
                  }),
                ],
              ),
            );
          }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
