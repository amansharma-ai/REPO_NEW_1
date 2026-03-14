class WeeklyNutrition {
  final DateTime date;
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;

  const WeeklyNutrition({
    required this.date,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
  });

  factory WeeklyNutrition.fromJson(Map<String, dynamic> json) => WeeklyNutrition(
        date: _parseDate(json['date']),
        totalCalories: (json['totalCalories'] as num).toDouble(),
        totalProtein: (json['totalProtein'] as num).toDouble(),
        totalCarbs: (json['totalCarbs'] as num).toDouble(),
        totalFat: (json['totalFat'] as num).toDouble(),
      );

  static DateTime _parseDate(dynamic raw) {
    if (raw is String) return DateTime.parse(raw);
    if (raw is List) return DateTime(raw[0] as int, raw[1] as int, raw[2] as int);
    throw ArgumentError('Unknown date format: $raw');
  }
}
