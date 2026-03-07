import 'dart:convert';

import 'package:iitpkd_one/features/schedule/data/models/meal_day.dart';

/// Represents the full 14-day rotating mess menu.
///
/// Contains 14 [MealDay] entries (7 odd-week + 7 even-week)
/// and the [campus] this menu applies to.
class MessMenu {
  final String campus;
  final List<MealDay> days;

  const MessMenu({required this.campus, required this.days});

  factory MessMenu.fromJson(Map<String, dynamic> json) {
    return MessMenu(
      campus: json['campus'] as String,
      days: (json['days'] as List<dynamic>)
          .map((e) => MealDay.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'campus': campus,
      'days': days.map((d) => d.toJson()).toList(),
    };
  }

  /// Returns meals for a specific [weekType] ("odd"/"even") and [day].
  MealDay? getMealsForDay(String weekType, String day) {
    try {
      return days.firstWhere(
        (d) => d.weekType == weekType && d.day == day.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  /// Serializes to a JSON string for Hive storage.
  String encode() => jsonEncode(toJson());

  /// Deserializes a JSON string from Hive.
  static MessMenu decode(String jsonStr) {
    return MessMenu.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
  }
}
