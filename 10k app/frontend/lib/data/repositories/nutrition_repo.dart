import 'package:dio/dio.dart';
import '../models/food_item.dart';
import '../models/mess_menu.dart';
import '../models/daily_summary.dart';
import '../models/nutrition_goal.dart';
import '../models/weekly_nutrition.dart';
import '../../core/constants/api_constants.dart';

class NutritionRepository {
  final Dio _dio = Dio(BaseOptions(baseUrl: ApiConstants.nutrition));

  Future<List<MessMenu>> getMenuForDay(String day) async {
    final res = await _dio.get('/menu', queryParameters: {'day': day});
    return (res.data as List).map((e) => MessMenu.fromJson(e)).toList();
  }

  Future<List<MessMenu>> getTodayMenu() async {
    final res = await _dio.get('/menu/today');
    return (res.data as List).map((e) => MessMenu.fromJson(e)).toList();
  }

  Future<void> logFood({
    required String logDate,
    required String mealType,
    required int foodItemId,
    double servings = 1.0,
  }) async {
    await _dio.post('/log', data: {
      'logDate': logDate,
      'mealType': mealType,
      'foodItemId': foodItemId,
      'servings': servings,
    });
  }

  Future<void> deleteLog(int id) async {
    await _dio.delete('/log/$id');
  }

  Future<DailySummary> getDailySummary(String date) async {
    final res = await _dio.get('/summary', queryParameters: {'date': date});
    return DailySummary.fromJson(res.data);
  }

  Future<FoodItem> addCustomFood({
    required String name,
    required double calories,
    required double proteinG,
    required double carbsG,
    required double fatG,
    String? servingSize,
  }) async {
    final res = await _dio.post('/food/custom', data: {
      'name': name,
      'calories': calories,
      'proteinG': proteinG,
      'carbsG': carbsG,
      'fatG': fatG,
      'servingSize': servingSize,
    });
    return FoodItem.fromJson(res.data);
  }

  Future<List<FoodItem>> searchFoods(String query) async {
    final res = await _dio.get('/food/search', queryParameters: {'q': query});
    return (res.data as List).map((e) => FoodItem.fromJson(e)).toList();
  }

  Future<NutritionGoal> getGoal() async {
    final res = await _dio.get('/goals');
    return NutritionGoal.fromJson(res.data);
  }

  Future<NutritionGoal> updateGoal({
    required double goalCalories,
    required double goalProtein,
    required double goalCarbs,
    required double goalFat,
  }) async {
    final res = await _dio.put('/goals', data: {
      'goalCalories': goalCalories,
      'goalProtein': goalProtein,
      'goalCarbs': goalCarbs,
      'goalFat': goalFat,
    });
    return NutritionGoal.fromJson(res.data);
  }

  Future<List<WeeklyNutrition>> getWeeklyHistory({int days = 7}) async {
    final res = await _dio.get('/history/weekly', queryParameters: {'days': days});
    return (res.data as List).map((e) => WeeklyNutrition.fromJson(e)).toList();
  }

  Future<List<FoodItem>> getFoodsByCategory(String category) async {
    final res = await _dio.get('/food/browse', queryParameters: {'category': category});
    return (res.data as List).map((e) => FoodItem.fromJson(e)).toList();
  }
}
