import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';

class BodyWeightRepository {
  final Dio _dio = Dio(BaseOptions(baseUrl: ApiConstants.bodyWeight));

  Future<Map<String, dynamic>> logWeight({
    required String date,
    required double weightKg,
  }) async {
    final res = await _dio.post('', data: {'date': date, 'weightKg': weightKg});
    return res.data as Map<String, dynamic>;
  }

  Future<List<dynamic>> getHistory({int days = 30}) async {
    final res = await _dio.get('/history', queryParameters: {'days': days});
    return res.data as List<dynamic>;
  }

  Future<Map<String, dynamic>?> getLatest() async {
    try {
      final res = await _dio.get('/latest');
      if (res.statusCode == 204 || res.data == null) return null;
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response?.statusCode == 204) return null;
      rethrow;
    }
  }
}
