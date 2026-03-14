class MacroCalculator {
  // ── Default daily goals ───────────────────────────────────────────────
  static const double defaultCalorieGoal = 2200;
  static const double defaultProteinGoal = 120; // grams
  static const double defaultCarbsGoal = 280; // grams
  static const double defaultFatGoal = 70; // grams

  // ── Calorie multipliers per gram ──────────────────────────────────────
  static const double caloriesPerGramProtein = 4.0;
  static const double caloriesPerGramCarbs = 4.0;
  static const double caloriesPerGramFat = 9.0;

  /// Calculates total calories from individual macronutrient gram values.
  static double caloriesFromMacros({
    required double proteinG,
    required double carbsG,
    required double fatG,
  }) {
    return (proteinG * caloriesPerGramProtein) +
        (carbsG * caloriesPerGramCarbs) +
        (fatG * caloriesPerGramFat);
  }

  /// Returns a value between 0.0 and 1.0 representing progress toward a goal.
  /// Clamps the result so it never exceeds 1.0.
  static double percentage(double current, double goal) {
    if (goal <= 0) return 0;
    return (current / goal).clamp(0.0, 1.0);
  }

  /// Returns the raw percentage (can exceed 100) as an integer.
  static int percentageInt(double current, double goal) {
    if (goal <= 0) return 0;
    return ((current / goal) * 100).round();
  }

  /// Remaining amount toward a goal, floored at 0.
  static double remaining(double current, double goal) {
    return (goal - current).clamp(0.0, double.infinity);
  }

  /// Macro split as percentages that sum to 100.
  /// Returns a map with keys: protein, carbs, fat.
  static Map<String, double> macroSplitPercent({
    required double proteinG,
    required double carbsG,
    required double fatG,
  }) {
    final total = caloriesFromMacros(
      proteinG: proteinG,
      carbsG: carbsG,
      fatG: fatG,
    );

    if (total == 0) {
      return {'protein': 0, 'carbs': 0, 'fat': 0};
    }

    return {
      'protein': (proteinG * caloriesPerGramProtein / total) * 100,
      'carbs': (carbsG * caloriesPerGramCarbs / total) * 100,
      'fat': (fatG * caloriesPerGramFat / total) * 100,
    };
  }
}
