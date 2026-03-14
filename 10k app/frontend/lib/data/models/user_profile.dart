class UserProfile {
  final double heightCm;
  final double weightKg;
  final int age;
  final String gender;
  final String activityLevel;
  final String fitnessGoal;
  final double bmr;
  final double tdee;
  final double goalCalories;
  final double goalProtein;
  final double goalCarbs;
  final double goalFat;

  const UserProfile({
    required this.heightCm,
    required this.weightKg,
    required this.age,
    required this.gender,
    required this.activityLevel,
    required this.fitnessGoal,
    required this.bmr,
    required this.tdee,
    required this.goalCalories,
    required this.goalProtein,
    required this.goalCarbs,
    required this.goalFat,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      heightCm: (json['heightCm'] as num).toDouble(),
      weightKg: (json['weightKg'] as num).toDouble(),
      age: (json['age'] as num).toInt(),
      gender: json['gender'] as String,
      activityLevel: json['activityLevel'] as String,
      fitnessGoal: json['fitnessGoal'] as String,
      bmr: (json['bmr'] as num).toDouble(),
      tdee: (json['tdee'] as num).toDouble(),
      goalCalories: (json['goalCalories'] as num).toDouble(),
      goalProtein: (json['goalProtein'] as num).toDouble(),
      goalCarbs: (json['goalCarbs'] as num).toDouble(),
      goalFat: (json['goalFat'] as num).toDouble(),
    );
  }
}
