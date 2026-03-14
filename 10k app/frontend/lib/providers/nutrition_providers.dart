import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/nutrition_repo.dart';
import '../data/models/daily_summary.dart';
import '../data/models/food_item.dart';
import '../data/models/mess_menu.dart';
import '../data/models/nutrition_goal.dart';
import '../data/models/weekly_nutrition.dart';

final nutritionRepositoryProvider = Provider((ref) => NutritionRepository());

final todayMenuProvider = FutureProvider<List<MessMenu>>((ref) {
  return ref.watch(nutritionRepositoryProvider).getTodayMenu();
});

final menuByDayProvider = FutureProvider.family<List<MessMenu>, String>((ref, day) {
  return ref.watch(nutritionRepositoryProvider).getMenuForDay(day);
});

final dailySummaryProvider = FutureProvider.family<DailySummary, String>((ref, date) {
  return ref.watch(nutritionRepositoryProvider).getDailySummary(date);
});

final foodSearchProvider = FutureProvider.family<List<FoodItem>, String>((ref, query) {
  if (query.isEmpty) return [];
  return ref.watch(nutritionRepositoryProvider).searchFoods(query);
});

final selectedNutritionDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

final nutritionGoalProvider = FutureProvider<NutritionGoal>(
    (ref) => ref.watch(nutritionRepositoryProvider).getGoal());

final weeklyNutritionProvider = FutureProvider.family<List<WeeklyNutrition>, int>(
    (ref, days) => ref.watch(nutritionRepositoryProvider).getWeeklyHistory(days: days));

final foodByCategoryProvider = FutureProvider.family<List<FoodItem>, String>(
    (ref, category) => ref.watch(nutritionRepositoryProvider).getFoodsByCategory(category));
