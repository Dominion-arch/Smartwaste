String _s(dynamic value, [String fallback = '']) {
  if (value == null) return fallback;
  return value.toString().trim();
}

int _i(dynamic value, [int fallback = 0]) {
  if (value == null) return fallback;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString()) ?? fallback;
}

double _f(dynamic value, [double fallback = 0]) {
  if (value == null) return fallback;
  if (value is num) return value.toDouble();
  final n = value.toString().replaceAll('%', '').trim();
  return double.tryParse(n) ?? fallback;
}

bool _b(dynamic value, [bool fallback = false]) {
  if (value == null) return fallback;
  if (value is bool) return value;
  if (value is String) return value.toLowerCase() == 'true';
  return fallback;
}

DateTime _dt(dynamic value, [DateTime? fallback]) {
  if (value == null) return fallback ?? DateTime.now();
  if (value is DateTime) return value.toLocal();
  if (value is String) {
    final parsed = DateTime.tryParse(value)?.toLocal();
    if (parsed != null) return parsed;
  }
  return fallback ?? DateTime.now();
}

class Bin {
  final String id, zone, type;
  final double fill, lat, lng;
  final bool sensorOk;
  final DateTime lastUpdate;

  const Bin({
    required this.id, required this.zone, required this.type,
    required this.fill, required this.lat, required this.lng,
    required this.sensorOk, required this.lastUpdate,
  });

  bool get hasLocation => lat != 0 || lng != 0;

  factory Bin.fromJson(Map<String, dynamic> j) {
    final zone = _s(j['zone']).trim();
    return Bin(
      id: _s(j['id']),
      zone: zone.isEmpty ? '—' : zone,
      type: _s(j['type'], 'General'),
      fill: double.parse(_f(j['fill']).toStringAsFixed(1)),
      lat: _f(j['lat']),
      lng: _f(j['lng']),
      sensorOk: _b(j['sensor_ok'], true) && !_b(j['sensorOk'], false),
      lastUpdate: _dt(j['last_update']),
    );
  }
}

class Profile {
  final String id, email, name, role, zone, truckId, route;
  const Profile({
    required this.id, required this.email, required this.name, required this.role,
    required this.zone, required this.truckId, required this.route,
  });

  factory Profile.fromJson(Map<String, dynamic> j) => Profile(
        id: _s(j['id']),
        email: _s(j['email']),
        name: _s(j['name']),
        role: _s(j['role'], 'citizen').toLowerCase(),
        zone: _s(j['zone']),
        truckId: _s(j['truck_id']),
        route: _s(j['route']),
      );
}

class Report {
  static const points = 50;
  final int id;
  final String type, zone, description, urgency, status;
  final DateTime createdAt;
  const Report({
    required this.id, required this.type, required this.zone, required this.description,
    required this.urgency, required this.status, required this.createdAt,
  });

  factory Report.fromJson(Map<String, dynamic> j) => Report(
        id: _i(j['id']),
        type: _s(j['type']),
        zone: _s(j['zone']),
        description: _s(j['description']),
        urgency: _s(j['urgency'], 'medium').toLowerCase(),
        status: _s(j['status'], 'pending').toLowerCase(),
        createdAt: _dt(j['created_at']),
      );

  static const types = <String>[
    'Illegal Dumping', 'Overflowing Bin', 'Missed Collection',
    'Damaged Bin', 'Bad Odour', 'Other',
  ];

  static String icon(String type) => const {
        'Illegal Dumping': '🚯', 'Overflowing Bin': '🗑️', 'Missed Collection': '📭',
        'Damaged Bin': '⚠️', 'Bad Odour': '🤢', 'Other': '📋',
      }[type] ?? '📋';
}

class Pickup {
  static const points = 30;
  final int id;
  final String wasteType, timeSlot, notes, status;
  final DateTime date, createdAt;
  const Pickup({
    required this.id, required this.wasteType, required this.timeSlot, required this.notes,
    required this.status, required this.date, required this.createdAt,
  });

  factory Pickup.fromJson(Map<String, dynamic> j) => Pickup(
        id: _i(j['id']),
        wasteType: _s(j['waste_type']),
        timeSlot: _s(j['time_slot'], 'Any time'),
        notes: _s(j['notes']),
        status: _s(j['status'], 'scheduled').toLowerCase(),
        date: _dt(j['pickup_date']),
        createdAt: _dt(j['created_at']),
      );

  static const wasteTypes = <String>[
    'General Waste', 'Old Furniture / Appliances', 'Garden / Green Waste',
    'Construction Rubble', 'Electronics (E-Waste)', 'Hazardous Materials',
  ];
  static const timeSlots = <String>[
    'Morning (7am – 12pm)', 'Afternoon (12pm – 5pm)', 'Any time',
  ];
}

class Activity {
  final String icon, title;
  final int points;
  final DateTime time;
  const Activity(this.icon, this.title, this.points, this.time);
}
