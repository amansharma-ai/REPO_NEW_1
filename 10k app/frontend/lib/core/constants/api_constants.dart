class ApiConstants {
  static const String baseUrl = 'http://10.0.2.2:8081/api';
  static const String nutrition = '$baseUrl/nutrition';
  static const String nutritionGoals = '$nutrition/goals';
  static const String nutritionWeekly = '$nutrition/history/weekly';
  static const String workouts = '$baseUrl/workouts';
  static const String exercises = '$baseUrl/exercises';
  static const String challenges = '$baseUrl/challenges';
  static String exerciseBest(int id) => '$workouts/exercises/$id/best';
  static const String bodyWeight = '$baseUrl/body-weight';
  static String exerciseProgress(int id) => '$workouts/exercises/$id/progress';
  static const String workoutStats = '$workouts/stats';
  static const String weeklyVolume = '$workouts/volume/weekly';
  static const String userProfile = '$baseUrl/user/profile';
  static const String nutritionBrowse = '$nutrition/food/browse';
}
