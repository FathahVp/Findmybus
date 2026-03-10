class BusRoute {
  final int id;
  final String name;
  final String short;
  final String color;
  final String duration;
  final String fare;
  final List<String> stops;
  final List<String> departures;

  const BusRoute({
    required this.id,
    required this.name,
    required this.short,
    required this.color,
    required this.duration,
    required this.fare,
    required this.stops,
    required this.departures,
  });
}

class Bus {
  final String id;
  final int routeId;
  final String driver;
  double progress;
  String status; // "running" | "stopped"
  int delay;

  Bus({
    required this.id,
    required this.routeId,
    required this.driver,
    required this.progress,
    required this.status,
    required this.delay,
  });
}

class CrowdReport {
  final int id;
  final String type;
  final String busId;
  final String stop;
  final String message;
  final String time;
  int votes;
  bool userVoted;

  CrowdReport({
    required this.id,
    required this.type,
    required this.busId,
    required this.stop,
    required this.message,
    required this.time,
    required this.votes,
    required this.userVoted,
  });
}

// ── Static Data ──────────────────────────────────────────────────────────────

final List<BusRoute> kRoutes = [
  const BusRoute(
    id: 1,
    name: "Perinthalmanna → Kozhikode",
    short: "PTM → KZD",
    color: "#3b82f6",
    duration: "150",
    fare: "₹85",
    stops: ["Perinthalmanna","Angadippuram","Ramapuram","Makkaraparamb",
            "Malappuram","Melmuri","Valluvambram","Kondotty","Pulikkal",
            "Ramanattukara","Farook","Meenchantha","Kozhikode"],
    departures: ["05:00","06:15","07:30","08:45","10:00","11:30",
                 "13:00","14:30","16:00","17:30","19:00","21:00"],
  ),
  const BusRoute(
    id: 2,
    name: "Perinthalmanna → Palakkad",
    short: "PTM → PKD",
    color: "#f59e0b",
    duration: "135",
    fare: "₹75",
    stops: ["Perinthalmanna","Nattukal","Kumaramputhur","Mannarkkad",
            "Kalladikode","Mundur","Olavakkode","Palakkad"],
    departures: ["00:30","00:50","05:20","06:20","07:00","08:00",
                 "09:00","10:00","19:20","21:00","22:20","23:40"],
  ),
  const BusRoute(
    id: 3,
    name: "Perinthalmanna → Thrissur",
    short: "PTM → TCR",
    color: "#10b981",
    duration: "180",
    fare: "₹110",
    stops: ["Perinthalmanna","Koppam","Pattambi","Koottanad",
            "Kunnamkulam","Keechery","Amala Hospital","Thrissur"],
    departures: ["05:40","06:40","07:30","10:15","13:00","16:00","20:10","22:00"],
  ),
  const BusRoute(
    id: 4,
    name: "Perinthalmanna → Ernakulam",
    short: "PTM → EKM",
    color: "#8b5cf6",
    duration: "250",
    fare: "₹194",
    stops: ["Perinthalmanna","Pattambi","Shoranur","Thrissur",
            "Chalakudy","Angamaly","Aluva","Vytilla Hub","Ernakulam"],
    departures: ["04:30","05:40","07:30","08:00","13:00","16:00","20:10","22:00"],
  ),
  const BusRoute(
    id: 5,
    name: "Perinthalmanna → Trivandrum",
    short: "PTM → TVM",
    color: "#ef4444",
    duration: "570",
    fare: "₹432",
    stops: ["Perinthalmanna","Pattambi","Shoranur","Thrissur","Chalakudy",
            "Angamaly","Aluva","Ernakulam","Cherthala","Alappuzha",
            "Kayamkulam","Karunagapally","Kollam","Attingal","Trivandrum"],
    departures: ["22:40","05:40","07:30","20:10","21:10","22:00","23:20"],
  ),
  const BusRoute(
    id: 6,
    name: "Perinthalmanna → Pala",
    short: "PTM → PALA",
    color: "#06b6d4",
    duration: "300",
    fare: "₹165",
    stops: ["Perinthalmanna","Thrissur","Chalakudy","Perumbavoor","Muvattupuzha","Pala"],
    departures: ["02:00","04:50","05:50","06:30","07:40","08:30","12:30","17:00","20:30","23:50"],
  ),
];

final List<Bus> kBuses = [
  Bus(id: "KL-10-A-1122", routeId: 1, driver: "Rajan K.",    progress: 0.25, status: "running", delay: 0),
  Bus(id: "KL-10-B-3344", routeId: 1, driver: "Suresh P.",   progress: 0.70, status: "running", delay: 8),
  Bus(id: "KL-10-C-5566", routeId: 2, driver: "Anil M.",     progress: 0.40, status: "running", delay: 0),
  Bus(id: "KL-10-D-7788", routeId: 2, driver: "Biju T.",     progress: 0.10, status: "stopped", delay: 15),
  Bus(id: "KL-10-E-9900", routeId: 3, driver: "Vineesh R.",  progress: 0.55, status: "running", delay: 5),
  Bus(id: "KL-10-F-1111", routeId: 4, driver: "Shaji M.",    progress: 0.35, status: "running", delay: 0),
  Bus(id: "KL-10-G-2222", routeId: 5, driver: "Pradeep K.",  progress: 0.60, status: "running", delay: 20),
  Bus(id: "KL-10-H-3333", routeId: 6, driver: "Santhosh V.", progress: 0.45, status: "running", delay: 0),
];
