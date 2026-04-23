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
  final String? arrivalTime; // "HH:mm" format, e.g. "09:25"
  final bool isOutsideTrip;
  final bool isMultipleBuses;
  final List<String> days;

  const ShuttleSchedule({
    required this.id,
    required this.from,
    required this.to,
    required this.via,
    required this.time,
    this.arrivalTime,
    required this.isOutsideTrip,
    this.isMultipleBuses = false,
    required this.days,
  });

  factory ShuttleSchedule.fromJson(Map<String, dynamic> json) {
    return ShuttleSchedule(
      id: '${json['id']}',
      from: json['from'] as String,
      to: json['to'] as String,
      via: (json['via'] as List<dynamic>).cast<String>(),
      time: json['time'] as String,
      arrivalTime: (json['arrival_time'] ?? json['arrivalTime']) as String?,
      isOutsideTrip: (json['is_outside_trip'] ?? json['isOutsideTrip']) as bool,
      isMultipleBuses:
          (json['is_multiple_buses'] ?? json['isMultipleBuses'] ?? false)
              as bool,
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
      'arrival_time': arrivalTime,
      'is_outside_trip': isOutsideTrip,
      'is_multiple_buses': isMultipleBuses,
      'days': days,
    };
  }

  /// Parses the [time] string ("HH:mm") into a [DateTime] for today.
  /// Also supports 12-hour values like "09:00 PM".
  DateTime get todayDateTime {
    final parsed = _parseHourMinute(time);
    final now = DateTime.now();

    if (parsed == null) {
      return DateTime(now.year, now.month, now.day);
    }

    return DateTime(now.year, now.month, now.day, parsed.$1, parsed.$2);
  }

  /// Calculates the number of minutes until this shuttle departs.
  /// Returns negative values if the departure time has already passed.
  int get minutesUntilDeparture {
    if (_parseHourMinute(time) == null) {
      return -1;
    }

    return todayDateTime.difference(DateTime.now()).inMinutes;
  }

  /// Whether this shuttle hasn't departed yet today.
  bool get isUpcoming => minutesUntilDeparture > 0;

  (int, int)? _parseHourMinute(String input) {
    final normalized = input.trim().toUpperCase().replaceAll('.', ':');

    final twelveHour = RegExp(
      r'^(\d{1,2}):(\d{2})\s*([AP]M)$',
    ).firstMatch(normalized);
    if (twelveHour != null) {
      final hour = int.tryParse(twelveHour.group(1)!);
      final minute = int.tryParse(twelveHour.group(2)!);
      final meridiem = twelveHour.group(3)!;

      if (hour == null ||
          minute == null ||
          hour < 1 ||
          hour > 12 ||
          minute < 0 ||
          minute > 59) {
        return null;
      }

      var hour24 = hour % 12;
      if (meridiem == 'PM') {
        hour24 += 12;
      }

      return (hour24, minute);
    }

    final twentyFourHour = RegExp(
      r'^(\d{1,2}):(\d{2})$',
    ).firstMatch(normalized);
    if (twentyFourHour != null) {
      final hour = int.tryParse(twentyFourHour.group(1)!);
      final minute = int.tryParse(twentyFourHour.group(2)!);

      if (hour == null ||
          minute == null ||
          hour < 0 ||
          hour > 23 ||
          minute < 0 ||
          minute > 59) {
        return null;
      }

      return (hour, minute);
    }

    return null;
  }

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
