import 'package:dio/dio.dart';
import '../models/exercise.dart';
import '../../core/constants/api_constants.dart';

class ExerciseRepository {
  final Dio _dio = Dio(BaseOptions(baseUrl: ApiConstants.exercises));

  Future<List<Exercise>> getExercises({String? type, String? muscleGroup}) async {
    final params = <String, dynamic>{};
    if (type != null) params['type'] = type;
    if (muscleGroup != null) params['muscleGroup'] = muscleGroup;
    final res = await _dio.get('', queryParameters: params);
    return (res.data as List).map((e) => Exercise.fromJson(e)).toList();
  }

  Future<Exercise> addExercise(Exercise exercise) async {
    final res = await _dio.post('', data: exercise.toJson());
    return Exercise.fromJson(res.data);
  }
}
