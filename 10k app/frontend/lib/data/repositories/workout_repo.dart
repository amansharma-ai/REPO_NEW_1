import 'package:dio/dio.dart';
import '../models/workout.dart';
import '../../core/constants/api_constants.dart';

class WorkoutRepository {
  final Dio _dio = Dio(BaseOptions(baseUrl: ApiConstants.workouts));

  Future<Workout> createWorkout(Workout workout) async {
    final res = await _dio.post('', data: workout.toJson());
    return Workout.fromJson(res.data);
  }

  Future<List<Workout>> getWorkoutsByDate(String date) async {
    final res = await _dio.get('', queryParameters: {'date': date});
    return (res.data as List).map((e) => Workout.fromJson(e)).toList();
  }

  Future<List<Workout>> getWorkoutHistory(String from, String to) async {
    final res = await _dio.get('/history', queryParameters: {'from': from, 'to': to});
    return (res.data as List).map((e) => Workout.fromJson(e)).toList();
  }

  Future<Map<String, dynamic>> getExerciseHistory(int exerciseId) async {
    final res = await _dio.get('/exercises/$exerciseId/history');
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getExerciseBestSet(int exerciseId) async {
    final res = await _dio.get('/exercises/$exerciseId/best');
    return res.data as Map<String, dynamic>;
  }

  Future<Workout> updateWorkout(int id, Workout workout) async {
    final res = await _dio.put('/$id', data: workout.toJson());
    return Workout.fromJson(res.data);
  }

  Future<void> deleteWorkout(int id) async {
    await _dio.delete('/$id');
  }

  Future<Map<String, dynamic>> getExerciseProgress(int exerciseId) async {
    final res = await _dio.get('/exercises/$exerciseId/progress');
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getWorkoutStats() async {
    final res = await _dio.get('/stats');
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getWeeklyVolume({int weeks = 8}) async {
    final res = await _dio.get('/volume/weekly', queryParameters: {'weeks': weeks});
    return res.data as Map<String, dynamic>;
  }
}
