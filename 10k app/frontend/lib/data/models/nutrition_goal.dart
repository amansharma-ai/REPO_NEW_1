class NutritionGoal {
  final double goalCalories;
  final double goalProtein;
  final double goalCarbs;
  final double goalFat;

  const NutritionGoal({
    required this.goalCalories,
    required this.goalProtein,
    required this.goalCarbs,
    required this.goalFat,
  });

  factory NutritionGoal.fromJson(Map<String, dynamic> json) => NutritionGoal(
        goalCalories: (json['goalCalories'] as num).toDouble(),
        goalProtein: (json['goalProtein'] as num).toDouble(),
        goalCarbs: (json['goalCarbs'] as num).toDouble(),
        goalFat: (json['goalFat'] as num).toDouble(),
      );
}
