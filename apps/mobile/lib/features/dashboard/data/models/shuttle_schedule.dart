import 'dart:convert';

/// Represents a shuttle bus schedule entry.
///
/// Shuttle data is semi-static (updates roughly once per semester)
/// and should be cached in Hive with a weekly TTL.
class ShuttleSchedule {
  final String id;
  final String from;
  final String to;
  final List<String> via;
  final String time; // "HH:mm" format, e.g. "09:00"
  final bool isOutsideTrip;
  final List<String> days;

  const ShuttleSchedule({
    required this.id,
    required this.from,
    required this.to,
    required this.via,
    required this.time,
    required this.isOutsideTrip,
    required this.days,
  });

  factory ShuttleSchedule.fromJson(Map<String, dynamic> json) {
    return ShuttleSchedule(
      id: json['id'] as String,
      from: json['from'] as String,
      to: json['to'] as String,
      via: (json['via'] as List<dynamic>).cast<String>(),
      time: json['time'] as String,
      isOutsideTrip: json['is_outside_trip'] as bool,
      days: (json['days'] as List<dynamic>).cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'from': from,
      'to': to,
      'via': via,
      'time': time,
      'is_outside_trip': isOutsideTrip,
      'days': days,
    };
  }

  /// Parses the [time] string ("HH:mm") into a [DateTime] for today.
  DateTime get todayDateTime {
    final parts = time.split(':');
    final now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  /// Calculates the number of minutes until this shuttle departs.
  /// Returns negative values if the departure time has already passed.
  int get minutesUntilDeparture {
    return todayDateTime.difference(DateTime.now()).inMinutes;
  }

  /// Whether this shuttle hasn't departed yet today.
  bool get isUpcoming => minutesUntilDeparture > 0;

  /// Whether this shuttle runs on the given day (lowercase, e.g. "monday").
  bool runsOnDay(String day) => days.contains(day.toLowerCase());

  /// Serializes a list of [ShuttleSchedule] to a JSON string for Hive storage.
  static String encodeList(List<ShuttleSchedule> schedules) {
    return jsonEncode(schedules.map((s) => s.toJson()).toList());
  }

  /// Deserializes a JSON string from Hive into a list of [ShuttleSchedule].
  static List<ShuttleSchedule> decodeList(String jsonStr) {
    final list = jsonDecode(jsonStr) as List<dynamic>;
    return list
        .map((e) => ShuttleSchedule.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
