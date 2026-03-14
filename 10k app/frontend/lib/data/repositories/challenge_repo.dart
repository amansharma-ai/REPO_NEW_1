import 'package:dio/dio.dart';
import '../models/daily_challenge.dart';
import '../../core/constants/api_constants.dart';

class ChallengeRepository {
  final Dio _dio = Dio(BaseOptions(baseUrl: ApiConstants.challenges));

  Future<List<DailyChallenge>> getTodayChallenges() async {
    final res = await _dio.get('/today');
    return (res.data as List).map((e) => DailyChallenge.fromJson(e)).toList();
  }

  Future<List<DailyChallenge>> forceRegenerate() async {
    final res = await _dio.post('/generate');
    return (res.data as List).map((e) => DailyChallenge.fromJson(e)).toList();
  }

  Future<DailyChallenge> markCompleted(int id) async {
    final res = await _dio.put('/$id/complete');
    return DailyChallenge.fromJson(res.data);
  }
}
