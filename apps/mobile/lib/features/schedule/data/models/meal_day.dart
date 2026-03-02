import 'dart:convert';

/// Represents the meals served during a single meal slot.
class Meals {
  final List<String> breakfast;
  final List<String> lunch;
  final List<String> snacks;
  final List<String> dinner;

  const Meals({
    required this.breakfast,
    required this.lunch,
    required this.snacks,
    required this.dinner,
  });

  factory Meals.fromJson(Map<String, dynamic> json) {
    return Meals(
      breakfast: (json['breakfast'] as List<dynamic>).cast<String>(),
      lunch: (json['lunch'] as List<dynamic>).cast<String>(),
      snacks: (json['snacks'] as List<dynamic>).cast<String>(),
      dinner: (json['dinner'] as List<dynamic>).cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'breakfast': breakfast,
      'lunch': lunch,
      'snacks': snacks,
      'dinner': dinner,
    };
  }
}

/// Represents a single day's mess menu within the 14-day cycle.
///
/// The [weekType] is either "odd" or "even" (Week 1 or Week 2).
/// The [day] is lowercase day name (e.g. "monday").
class MealDay {
  final String weekType;
  final String day;
  final Meals meals;

  const MealDay({
    required this.weekType,
    required this.day,
    required this.meals,
  });

  factory MealDay.fromJson(Map<String, dynamic> json) {
    return MealDay(
      weekType: json['week_type'] as String,
      day: json['day'] as String,
      meals: Meals.fromJson(json['meals'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'week_type': weekType,
      'day': day,
      'meals': meals.toJson(),
    };
  }

  /// Serializes a list of [MealDay] to a JSON string for Hive storage.
  static String encodeList(List<MealDay> days) {
    return jsonEncode(days.map((d) => d.toJson()).toList());
  }

  /// Deserializes a JSON string from Hive into a list of [MealDay].
  static List<MealDay> decodeList(String jsonStr) {
    final list = jsonDecode(jsonStr) as List<dynamic>;
    return list
        .map((e) => MealDay.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
