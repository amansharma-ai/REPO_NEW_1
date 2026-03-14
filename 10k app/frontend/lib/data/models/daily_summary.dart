class DailySummary {
  final String date;
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final double goalCalories;
  final double goalProtein;
  final double goalCarbs;
  final double goalFat;
  final List<MealSummary> meals;

  const DailySummary({
    required this.date,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    required this.goalCalories,
    required this.goalProtein,
    required this.goalCarbs,
    required this.goalFat,
    required this.meals,
  });

  factory DailySummary.fromJson(Map<String, dynamic> json) {
    return DailySummary(
      date: json['date'] as String,
      totalCalories: (json['totalCalories'] as num).toDouble(),
      totalProtein: (json['totalProtein'] as num).toDouble(),
      totalCarbs: (json['totalCarbs'] as num).toDouble(),
      totalFat: (json['totalFat'] as num).toDouble(),
      goalCalories: (json['goalCalories'] as num).toDouble(),
      goalProtein: (json['goalProtein'] as num).toDouble(),
      goalCarbs: (json['goalCarbs'] as num).toDouble(),
      goalFat: (json['goalFat'] as num).toDouble(),
      meals: (json['meals'] as List<dynamic>?)
              ?.map((e) => MealSummary.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class MealSummary {
  final String mealType;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final List<LogEntry> items;

  const MealSummary({
    required this.mealType,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.items,
  });

  factory MealSummary.fromJson(Map<String, dynamic> json) {
    return MealSummary(
      mealType: json['mealType'] as String,
      calories: (json['calories'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => LogEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class LogEntry {
  final int logId;
  final int foodItemId;
  final String foodName;
  final double servings;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  const LogEntry({
    required this.logId,
    required this.foodItemId,
    required this.foodName,
    required this.servings,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  factory LogEntry.fromJson(Map<String, dynamic> json) {
    return LogEntry(
      logId: json['logId'] as int,
      foodItemId: json['foodItemId'] as int,
      foodName: json['foodName'] as String,
      servings: (json['servings'] as num).toDouble(),
      calories: (json['calories'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
    );
  }
}
