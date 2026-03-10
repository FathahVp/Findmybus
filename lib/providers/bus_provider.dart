import 'dart:async';
import 'package:flutter/material.dart';
import '../models/route_model.dart';

class BusProvider extends ChangeNotifier {
  List<Bus> buses = List.from(kBuses.map((b) => Bus(
    id: b.id, routeId: b.routeId, driver: b.driver,
    progress: b.progress, status: b.status, delay: b.delay,
  )));

  Bus? selectedBus;
  Timer? _ticker;

  // Alarm
  String? alarmBusId;
  String? alarmStop;
  int stopsAwayAlert = 2;
  bool alarmFired = false;
  bool alarmActive = false;

  // Offline
  Map<String, bool> downloaded = {'routes': false, 'stops': false, 'schedules': false};
  String networkMode = '2G';

  BusProvider() {
    selectedBus = buses.first;
    _startAutoMove();
  }

  void _startAutoMove() {
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      for (final bus in buses) {
        if (bus.status == 'running') {
          bus.progress = (bus.progress + 0.002).clamp(0.0, 1.0);
        }
      }
      _checkAlarm();
      notifyListeners();
    });
  }

  void selectBus(Bus bus) {
    selectedBus = bus;
    notifyListeners();
  }

  void toggleDriverStatus(Bus bus) {
    bus.status = bus.status == 'running' ? 'stopped' : 'running';
    notifyListeners();
  }

  void advanceBus(Bus bus) {
    bus.progress = (bus.progress + 0.08).clamp(0.0, 1.0);
    notifyListeners();
  }

  // ── Alarm ────────────────────────────────────────────────────────────────
  void setAlarm(String busId, String stop, int stopsAway) {
    alarmBusId = busId;
    alarmStop = stop;
    stopsAwayAlert = stopsAway;
    alarmFired = false;
    alarmActive = false;
    notifyListeners();
  }

  void cancelAlarm() {
    alarmBusId = null;
    alarmStop = null;
    alarmFired = false;
    alarmActive = false;
    notifyListeners();
  }

  void dismissAlarm() {
    alarmActive = false;
    notifyListeners();
  }

  void _checkAlarm() {
    if (alarmBusId == null || alarmStop == null || alarmFired) return;
    final bus = buses.firstWhere((b) => b.id == alarmBusId, orElse: () => buses.first);
    final route = kRoutes.firstWhere((r) => r.id == bus.routeId);
    final alarmIdx = route.stops.indexOf(alarmStop!);
    if (alarmIdx == -1) return;
    final triggerIdx = (alarmIdx - stopsAwayAlert).clamp(0, route.stops.length - 1);
    final triggerProgress = triggerIdx / (route.stops.length - 1);
    if (bus.progress >= triggerProgress) {
      alarmFired = true;
      alarmActive = true;
    }
  }

  // ── Offline ───────────────────────────────────────────────────────────────
  Future<void> downloadPackage(String key) async {
    await Future.delayed(const Duration(seconds: 2));
    downloaded[key] = true;
    notifyListeners();
  }

  void setNetworkMode(String mode) {
    networkMode = mode;
    notifyListeners();
  }

  BusRoute routeFor(Bus bus) => kRoutes.firstWhere((r) => r.id == bus.routeId);

  List<Bus> searchBuses(String query) {
    if (query.isEmpty) return [];
    final q = query.toLowerCase();
    return buses.where((b) {
      final route = routeFor(b);
      return b.id.toLowerCase().contains(q) ||
             b.driver.toLowerCase().contains(q) ||
             route.name.toLowerCase().contains(q) ||
             route.stops.any((s) => s.toLowerCase().contains(q));
    }).toList();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
