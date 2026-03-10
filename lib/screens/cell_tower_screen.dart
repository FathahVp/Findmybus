import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bus_provider.dart';

class CellTowerScreen extends StatefulWidget {
  const CellTowerScreen({super.key});
  @override
  State<CellTowerScreen> createState() => _CellTowerScreenState();
}

class _CellTowerScreenState extends State<CellTowerScreen> {
  bool _scanning = false;
  String? _locResult;
  List<Map<String, dynamic>> _towers = [
    {'id': 'BSNL-PTM-01', 'signal': 87, 'dist': '0.4 km', 'active': true},
    {'id': 'BSNL-PTM-02', 'signal': 62, 'dist': '1.1 km', 'active': true},
    {'id': 'JIO-PTM-07',  'signal': 45, 'dist': '1.8 km', 'active': false},
  ];

  void _scan() async {
    setState(() { _scanning = true; _locResult = null; });
    await Future.delayed(const Duration(milliseconds: 2200));
    setState(() {
      _scanning = false;
      _locResult = '10.9781° N, 76.2388° E  ±120m\nCell Tower Triangulation';
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BusProvider>();
    final modes = ['2G', '3G', '4G', 'Offline'];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
      child: Column(
        children: [
          // Network mode
          _Card(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('NETWORK MODE', style: TextStyle(color: Color(0xFF475569), fontSize: 11, letterSpacing: 1)),
              const SizedBox(height: 12),
              Row(
                children: modes.map((m) => Expanded(child: Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: GestureDetector(
                    onTap: () => provider.setNetworkMode(m),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                        gradient: provider.networkMode == m ? LinearGradient(colors: _modeColors(m)) : null,
                        color: provider.networkMode == m ? null : Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(child: Text(m,
                        style: TextStyle(
                          color: provider.networkMode == m ? Colors.white : const Color(0xFF475569),
                          fontWeight: FontWeight.w700, fontSize: 12))),
                    ),
                  ),
                ))).toList(),
              ),
              const SizedBox(height: 10),
              Text(_modeDesc(provider.networkMode),
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 11)),
            ],
          )),
          const SizedBox(height: 14),

          // Towers
          _Card(child: Column(
            children: [
              Row(
                children: [
                  const Text('📡  NEARBY CELL TOWERS',
                    style: TextStyle(color: Color(0xFF475569), fontSize: 11, letterSpacing: 1)),
                  const Spacer(),
                  GestureDetector(
                    onTap: _scanning ? null : _scan,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        gradient: _scanning ? null : const LinearGradient(colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)]),
                        color: _scanning ? Colors.white.withOpacity(0.05) : null,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(_scanning ? 'Scanning...' : '🔄 Scan',
                        style: TextStyle(
                          color: _scanning ? const Color(0xFF475569) : Colors.white,
                          fontSize: 11, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ..._towers.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(children: [
                  // signal bars
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [1, 2, 3, 4].map((i) => Container(
                      width: 4, height: 4.0 + i * 4,
                      margin: const EdgeInsets.only(right: 2),
                      decoration: BoxDecoration(
                        color: t['signal'] >= i * 25
                          ? (t['signal'] > 70 ? const Color(0xFF4ADE80) : t['signal'] > 40 ? const Color(0xFFFBBF24) : const Color(0xFFF87171))
                          : Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    )).toList(),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t['id'], style: TextStyle(color: t['active'] ? Colors.white : const Color(0xFF475569), fontSize: 12, fontWeight: FontWeight.w600)),
                      Text(t['dist'], style: const TextStyle(color: Color(0xFF475569), fontSize: 10)),
                    ],
                  )),
                  Text('${t['signal']}%', style: TextStyle(
                    color: t['signal'] > 70 ? const Color(0xFF4ADE80) : t['signal'] > 40 ? const Color(0xFFFBBF24) : const Color(0xFFF87171),
                    fontWeight: FontWeight.w700, fontSize: 12)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: t['active'] ? const Color(0xFF22C55E).withOpacity(0.15) : Colors.white.withOpacity(0.05),
                      border: Border.all(color: t['active'] ? const Color(0xFF22C55E).withOpacity(0.3) : Colors.white.withOpacity(0.08)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(t['active'] ? 'LIVE' : 'IDLE',
                      style: TextStyle(color: t['active'] ? const Color(0xFF4ADE80) : const Color(0xFF475569), fontSize: 9, fontWeight: FontWeight.w700)),
                  ),
                ]),
              )),

              // Location result
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _locResult != null ? const Color(0xFF22D3EE).withOpacity(0.08) : Colors.white.withOpacity(0.03),
                  border: Border.all(color: _locResult != null ? const Color(0xFF22D3EE).withOpacity(0.25) : Colors.white.withOpacity(0.06)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _scanning
                  ? const Row(children: [
                      SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF3B82F6))),
                      SizedBox(width: 8),
                      Text('Triangulating position...', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                    ])
                  : _locResult != null
                    ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('📍  Triangulated Location', style: TextStyle(color: Color(0xFF22D3EE), fontWeight: FontWeight.w700, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(_locResult!, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                      ])
                    : const Text('Scan ചെയ്ത് location triangulate ചെയ്യൂ →',
                        style: TextStyle(color: Color(0xFF334155), fontSize: 12)),
              ),
            ],
          )),
          const SizedBox(height: 14),

          // Offline panel
          _OfflinePanel(),
        ],
      ),
    );
  }

  List<Color> _modeColors(String m) {
    switch (m) {
      case '4G': return [const Color(0xFF059669), const Color(0xFF047857)];
      case '3G': return [const Color(0xFFB45309), const Color(0xFF92400E)];
      case 'Offline': return [const Color(0xFF7C3AED), const Color(0xFF6D28D9)];
      default: return [const Color(0xFF1E40AF), const Color(0xFF1D4ED8)];
    }
  }

  String _modeDesc(String m) {
    switch (m) {
      case 'Offline': return '📡 Cell Tower data മാത്രം — internet ഇല്ലാതെ പ്രവർത്തിക്കും';
      case '2G': return '⚡ Low bandwidth mode — compressed location packets';
      case '3G': return '✅ Standard mode — real-time updates every 10s';
      default: return '🚀 Full mode — real-time updates every 3s + HD map';
    }
  }
}

class _OfflinePanel extends StatefulWidget {
  @override
  State<_OfflinePanel> createState() => _OfflinePanelState();
}

class _OfflinePanelState extends State<_OfflinePanel> {
  final Map<String, bool> _done = {'routes': false, 'stops': false, 'schedules': false};
  final Map<String, bool> _loading = {'routes': false, 'stops': false, 'schedules': false};

  final List<Map<String, String>> _items = [
    {'key': 'routes',    'label': 'Route Maps',     'icon': '🗺️', 'size': '1.2 MB', 'desc': '6 routes, stop coordinates'},
    {'key': 'stops',     'label': 'Stop Data',      'icon': '📍', 'size': '0.4 MB', 'desc': 'All stop names & sequences'},
    {'key': 'schedules', 'label': 'Bus Schedules',  'icon': '🕐', 'size': '0.8 MB', 'desc': 'Departure times, fares'},
  ];

  void _download(String key) async {
    setState(() => _loading[key] = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() { _done[key] = true; _loading[key] = false; });
  }

  @override
  Widget build(BuildContext context) {
    final allDone = _done.values.every((v) => v);
    return _Card(child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: allDone ? const Color(0xFF16A34A).withOpacity(0.1) : const Color(0xFFF59E0B).withOpacity(0.08),
            border: Border.all(color: allDone ? const Color(0xFF16A34A).withOpacity(0.25) : const Color(0xFFF59E0B).withOpacity(0.2)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(children: [
            Text(allDone ? '✅' : '📶', style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(allDone ? 'Offline Mode Ready!' : 'Download ചെയ്യൂ — Offline ആക്കൂ',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
              const Text('Internet ഇല്ലാതെ app പ്രവർത്തിക്കും',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 11)),
            ])),
          ]),
        ),
        const SizedBox(height: 14),
        ..._items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: _done[item['key']]! ? const Color(0xFF16A34A).withOpacity(0.15) : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(child: Text(item['icon']!, style: const TextStyle(fontSize: 18))),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(item['label']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
              Text('${item['desc']}  •  ${item['size']}', style: const TextStyle(color: Color(0xFF475569), fontSize: 10)),
              if (_loading[item['key']]!) ...[
                const SizedBox(height: 4),
                const LinearProgressIndicator(color: Color(0xFF3B82F6), backgroundColor: Color(0xFF1E293B)),
              ],
            ])),
            const SizedBox(width: 8),
            _done[item['key']]!
              ? const Text('✓ Done', style: TextStyle(color: Color(0xFF4ADE80), fontWeight: FontWeight.w700, fontSize: 11))
              : GestureDetector(
                  onTap: _loading[item['key']]! ? null : () => _download(item['key']!),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)]),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('⬇ Download', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                  ),
                ),
          ]),
        )),
      ],
    ));
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFF0F172A),
      border: Border.all(color: Colors.white.withOpacity(0.07)),
      borderRadius: BorderRadius.circular(16),
    ),
    child: child,
  );
}
