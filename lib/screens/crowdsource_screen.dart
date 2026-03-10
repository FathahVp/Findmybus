import 'package:flutter/material.dart';
import '../models/route_model.dart';

// ── crowdsource_screen.dart ───────────────────────────────────────────────────

class CrowdsourceScreen extends StatefulWidget {
  const CrowdsourceScreen({super.key});
  @override
  State<CrowdsourceScreen> createState() => _CrowdsourceScreenState();
}

class _CrowdsourceScreenState extends State<CrowdsourceScreen> {
  bool _showForm = false;
  String _reportType = 'delay';
  String _selectedBus = 'KL-10-A-1122';
  final _msgCtrl = TextEditingController();
  bool _submitted = false;

  List<Map<String, dynamic>> _reports = [
    {'id': 1, 'type': 'delay',     'bus': 'KL-10-A-1122', 'stop': 'Malappuram',  'msg': 'ഏകദേശം 10 മിനിറ്റ് delay ഉണ്ട്',      'time': '5 min ago',  'votes': 8,  'voted': false},
    {'id': 2, 'type': 'crowd',     'bus': 'KL-10-B-3344', 'stop': 'Kondotty',    'msg': 'ബസ് നിറഞ്ഞിരിക്കുന്നു, seat ഇല്ല',    'time': '12 min ago', 'votes': 14, 'voted': false},
    {'id': 3, 'type': 'breakdown', 'bus': 'KL-10-D-7788', 'stop': 'Mannarkkad', 'msg': 'ബസ് breakdown ആയി, next bus കാക്കുക',   'time': '20 min ago', 'votes': 22, 'voted': true},
    {'id': 4, 'type': 'good',      'bus': 'KL-10-E-9900', 'stop': 'Pattambi',   'msg': 'On time, seat ഉണ്ട്! 👍',               'time': '3 min ago',  'votes': 5,  'voted': false},
  ];

  static const _types = {
    'delay':     {'icon': '⏰', 'label': 'Delay',     'color': Color(0xFFF59E0B)},
    'crowd':     {'icon': '👥', 'label': 'Crowd',     'color': Color(0xFF8B5CF6)},
    'breakdown': {'icon': '🔧', 'label': 'Breakdown', 'color': Color(0xFFEF4444)},
    'good':      {'icon': '✅', 'label': 'Good',      'color': Color(0xFF22C55E)},
  };

  void _vote(int id) => setState(() {
    final r = _reports.firstWhere((r) => r['id'] == id);
    r['voted'] = !r['voted'];
    r['votes'] += r['voted'] ? 1 : -1;
  });

  void _submit() async {
    if (_msgCtrl.text.trim().isEmpty) return;
    setState(() => _submitted = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    setState(() {
      _reports.insert(0, {
        'id': DateTime.now().millisecondsSinceEpoch,
        'type': _reportType, 'bus': _selectedBus,
        'stop': '', 'msg': _msgCtrl.text.trim(),
        'time': 'ഇപ്പോൾ', 'votes': 1, 'voted': true,
      });
      _submitted = false; _showForm = false; _msgCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
      child: Column(
        children: [
          // Stats
          Row(children: [
            _StatCard('${_reports.length + 47}', 'Reports Today', const Color(0xFF3B82F6)),
            const SizedBox(width: 8),
            _StatCard('234', 'Active Users', const Color(0xFF10B981)),
            const SizedBox(width: 8),
            _StatCard('94%', 'Accuracy', const Color(0xFF8B5CF6)),
          ]),
          const SizedBox(height: 12),

          // Report button
          GestureDetector(
            onTap: () => setState(() => _showForm = !_showForm),
            child: Container(
              width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                gradient: _showForm ? null : const LinearGradient(colors: [Color(0xFF065F46), Color(0xFF059669)]),
                color: _showForm ? Colors.white.withOpacity(0.05) : null,
                border: _showForm ? Border.all(color: Colors.white.withOpacity(0.1)) : null,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: Text(_showForm ? '✕  Cancel' : '✏️  Report ചെയ്യൂ',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14))),
            ),
          ),

          // Form
          if (_showForm) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                border: Border.all(color: Colors.white.withOpacity(0.07)),
                borderRadius: BorderRadius.circular(16),
              ),
              child: _submitted
                ? const Column(children: [
                    SizedBox(height: 20),
                    Text('✅', style: TextStyle(fontSize: 40)),
                    SizedBox(height: 8),
                    Text('Report submit ആയി!', style: TextStyle(color: Color(0xFF4ADE80), fontWeight: FontWeight.w700, fontSize: 16)),
                    SizedBox(height: 4),
                    Text('നന്ദി! നിങ്ങളുടെ report മറ്റ് യാത്രക്കാരെ സഹായിക്കും',
                      style: TextStyle(color: Color(0xFF475569), fontSize: 12), textAlign: TextAlign.center),
                    SizedBox(height: 20),
                  ])
                : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('NEW REPORT', style: TextStyle(color: Color(0xFF475569), fontSize: 11, letterSpacing: 1)),
                    const SizedBox(height: 12),
                    // Type selector
                    GridView.count(
                      crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 6, mainAxisSpacing: 6, childAspectRatio: 3.5,
                      children: _types.entries.map((e) => GestureDetector(
                        onTap: () => setState(() => _reportType = e.key),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: _reportType == e.key ? (e.value['color'] as Color).withOpacity(0.15) : Colors.white.withOpacity(0.03),
                            border: Border.all(color: _reportType == e.key ? e.value['color'] as Color : Colors.white.withOpacity(0.08)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Text(e.value['icon'] as String, style: const TextStyle(fontSize: 14)),
                            const SizedBox(width: 5),
                            Text(e.value['label'] as String,
                              style: TextStyle(color: _reportType == e.key ? Colors.white : const Color(0xFF64748B),
                                fontWeight: FontWeight.w600, fontSize: 12)),
                          ]),
                        ),
                      )).toList(),
                    ),
                    const SizedBox(height: 12),
                    // Bus select
                    DropdownButtonFormField<String>(
                      value: _selectedBus,
                      dropdownColor: const Color(0xFF1E293B),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      decoration: InputDecoration(
                        filled: true, fillColor: Colors.white.withOpacity(0.05),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
                      ),
                      items: kBuses.map((b) {
                        final r = kRoutes.firstWhere((r) => r.id == b.routeId);
                        return DropdownMenuItem(value: b.id, child: Text('${b.id} — ${r.short}'));
                      }).toList(),
                      onChanged: (v) => setState(() => _selectedBus = v!),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _msgCtrl,
                      maxLines: 2,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      decoration: InputDecoration(
                        hintText: 'എന്ത് പ്രശ്നമാണ്? (Malayalam / English)',
                        hintStyle: const TextStyle(color: Color(0xFF475569)),
                        filled: true, fillColor: Colors.white.withOpacity(0.05),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
                      ),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: _submit,
                      child: Container(
                        width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)]),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(child: Text('📤  Submit Report',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13))),
                      ),
                    ),
                  ]),
            ),
          ],

          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              border: Border.all(color: Colors.white.withOpacity(0.07)),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('📡  LIVE REPORTS', style: TextStyle(color: Color(0xFF475569), fontSize: 11, letterSpacing: 1)),
                const SizedBox(height: 10),
                ..._reports.map((r) {
                  final cfg = _types[r['type']]!;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Container(
                        width: 34, height: 34,
                        decoration: BoxDecoration(
                          color: (cfg['color'] as Color).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(child: Text(cfg['icon'] as String, style: const TextStyle(fontSize: 16))),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Text((cfg['label'] as String).toUpperCase(),
                            style: TextStyle(color: cfg['color'] as Color, fontSize: 10, fontWeight: FontWeight.w700)),
                          Text('  •  ${r['bus']}  •  ${r['time']}',
                            style: const TextStyle(color: Color(0xFF334155), fontSize: 10)),
                        ]),
                        const SizedBox(height: 3),
                        Text(r['msg'], style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 12)),
                        if ((r['stop'] as String).isNotEmpty)
                          Text('📍 ${r['stop']}', style: const TextStyle(color: Color(0xFF475569), fontSize: 10)),
                      ])),
                      GestureDetector(
                        onTap: () => _vote(r['id']),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: r['voted'] ? const Color(0xFF3B82F6).withOpacity(0.2) : Colors.white.withOpacity(0.04),
                            border: Border.all(color: r['voted'] ? const Color(0xFF3B82F6).withOpacity(0.4) : Colors.white.withOpacity(0.08)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(children: [
                            const Text('👍', style: TextStyle(fontSize: 12)),
                            Text('${r['votes']}', style: TextStyle(
                              color: r['voted'] ? const Color(0xFF60A5FA) : const Color(0xFF475569),
                              fontSize: 10, fontWeight: FontWeight.w700)),
                          ]),
                        ),
                      ),
                    ]),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value, label;
  final Color color;
  const _StatCard(this.value, this.label, this.color);
  @override
  Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 12),
    decoration: BoxDecoration(
      color: const Color(0xFF0F172A),
      border: Border.all(color: Colors.white.withOpacity(0.07)),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(children: [
      Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w800)),
      const SizedBox(height: 3),
      Text(label, style: const TextStyle(color: Color(0xFF475569), fontSize: 9), textAlign: TextAlign.center),
    ]),
  ));
}
