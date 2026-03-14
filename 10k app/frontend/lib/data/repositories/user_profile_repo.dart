import 'package:dio/dio.dart';
import '../models/user_profile.dart';
import '../../core/constants/api_constants.dart';

class UserProfileRepository {
  final Dio _dio = Dio(BaseOptions(baseUrl: ApiConstants.userProfile));

  Future<UserProfile> getProfile() async {
    final res = await _dio.get('');
    return UserProfile.fromJson(res.data);
  }

  Future<UserProfile> updateProfile({
    required double heightCm,
    required double weightKg,
    required int age,
    required String gender,
    required String activityLevel,
    required String fitnessGoal,
  }) async {
    final res = await _dio.put('', data: {
      'heightCm': heightCm,
      'weightKg': weightKg,
      'age': age,
      'gender': gender,
      'activityLevel': activityLevel,
      'fitnessGoal': fitnessGoal,
    });
    return UserProfile.fromJson(res.data);
  }
}
