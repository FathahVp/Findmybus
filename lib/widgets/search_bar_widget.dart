import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bus_provider.dart';
import '../models/route_model.dart';

class BusSearchBar extends StatefulWidget {
  const BusSearchBar({super.key});
  @override
  State<BusSearchBar> createState() => _BusSearchBarState();
}

class _BusSearchBarState extends State<BusSearchBar> {
  final _ctrl = TextEditingController();
  bool _focused = false;
  List<Bus> _results = [];

  @override
  Widget build(BuildContext context) {
    final provider = context.read<BusProvider>();

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: _focused ? Colors.white.withOpacity(0.08) : Colors.white.withOpacity(0.05),
            border: Border.all(color: _focused ? const Color(0xFF22D3EE).withOpacity(0.4) : Colors.white.withOpacity(0.08)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(children: [
            const Padding(padding: EdgeInsets.only(left: 12), child: Icon(Icons.search, color: Color(0xFF64748B), size: 18)),
            Expanded(child: TextField(
              controller: _ctrl,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: const InputDecoration(
                hintText: 'ബസ് നം. അല്ലെങ്കിൽ റൂട്ട് സർച്ച് ചെയ്യൂ...',
                hintStyle: TextStyle(color: Color(0xFF475569), fontSize: 13),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              ),
              onChanged: (q) => setState(() => _results = provider.searchBuses(q)),
              onTap: () => setState(() => _focused = true),
              onSubmitted: (_) => setState(() => _focused = false),
            )),
            if (_ctrl.text.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.close, color: Color(0xFF475569), size: 18),
                onPressed: () => setState(() { _ctrl.clear(); _results = []; }),
              ),
          ]),
        ),

        // Results
        if (_focused && _results.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20)],
            ),
            child: Column(
              children: _results.map((bus) {
                final route = provider.routeFor(bus);
                final stopIdx = (bus.progress * (route.stops.length - 1)).floor();
                final currentStop = route.stops[stopIdx.clamp(0, route.stops.length - 1)];
                return GestureDetector(
                  onTap: () {
                    provider.selectBus(bus);
                    setState(() { _ctrl.clear(); _results = []; _focused = false; });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
                    ),
                    child: Row(children: [
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: bus.status == 'running'
                            ? const Color(0xFF16A34A).withOpacity(0.15)
                            : const Color(0xFFF59E0B).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(child: Icon(Icons.directions_bus,
                          color: bus.status == 'running' ? const Color(0xFF4ADE80) : const Color(0xFFFBBF24),
                          size: 18)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(bus.id, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                        Text(route.name, style: const TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                        Text('📍 ഇപ്പോൾ: $currentStop  •  ${bus.driver}',
                          style: const TextStyle(color: Color(0xFF475569), fontSize: 10)),
                      ])),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: bus.status == 'running'
                            ? const Color(0xFF16A34A).withOpacity(0.15)
                            : const Color(0xFFF59E0B).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          bus.status == 'running' ? '● Live' : '● Stopped',
                          style: TextStyle(
                            color: bus.status == 'running' ? const Color(0xFF4ADE80) : const Color(0xFFFBBF24),
                            fontSize: 10, fontWeight: FontWeight.w700)),
                      ),
                    ]),
                  ),
                );
              }).toList(),
            ),
          ),

        // Quick tags
        if (!_focused || _ctrl.text.isEmpty) ...[
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['Trivandrum', 'Ernakulam', 'Pala', 'Malappuram', 'Kozhikode'].map((tag) =>
                GestureDetector(
                  onTap: () {
                    _ctrl.text = tag;
                    setState(() { _results = provider.searchBuses(tag); _focused = true; });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      border: Border.all(color: Colors.white.withOpacity(0.06)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('🔍 $tag', style: const TextStyle(color: Color(0xFF475569), fontSize: 10)),
                  ),
                ),
              ).toList(),
            ),
          ),
        ],
      ],
    );
  }
}
