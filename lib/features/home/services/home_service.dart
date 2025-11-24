import 'package:dio/dio.dart';
import 'package:lifematch_frontend/core/services/api_client.dart' as ApiClient;
import 'package:lifematch_frontend/features/home/models/home_recommendation_model.dart';


class HomeService {
  final Dio dio = ApiClient.dio;

  /// 홈 추천 데이터 가져오기 (JWT 필요)
  Future<HomeRecommendation> getHomeRecommendations(String accessToken) async {
    try {
      final response = await dio.get(
        '/api/home/recommendations',
        options: Options(
          headers: {
            "Authorization": "Bearer $accessToken",   // 🔥 JWT 추가됨
          },
        ),
      );

      return HomeRecommendation.fromJson(response.data['data']);

    } on DioException catch (e) {
      print("❌ [홈 API ERROR] ${e.response?.data}");
      throw Exception('홈 추천 데이터 불러오기 실패');
    }
  }
}
