import 'package:dio/dio.dart';
import 'package:lifematch_frontend/core/services/api_client.dart' as ApiClient;
import 'package:lifematch_frontend/features/lifestyle_test/models/lifestyle_test_model.dart';

class LifestyleTestService {
  final Dio dio = ApiClient.dio; // api_client.dart의 dio 인스턴스

  /// 질문 가져오기
  Future<QuestionParts> getQuestions() async {
    try {
      final response = await dio.get('/user/lifestyle-test/questions');
      return QuestionParts.fromJson(response.data['data']);
    } on DioException catch (e) {
      print("질문 로딩 실패: ${e.response?.data}");
      throw Exception('질문 목록을 불러오는데 실패했습니다.');
    }
  }

  /// 검사 결과 제출
  Future<LifestyleTestResultDetail> submitTest(
      String accessToken,
      String userId,   // 추가!!
      List<int> selectedOptionIds,
      ) async {

    try {
      final response = await dio.post(
        '/user/lifestyle-test/result',
        data: {
          "user_id": userId,                    // 🔥 추가!!
          "selected_option_ids": selectedOptionIds,
        },
        options: Options(
          headers: {
            "Authorization": "Bearer $accessToken",
          },
        ),
      );

      return LifestyleTestResultDetail.fromJson(response.data['result']);

    } on DioException catch (e) {
      print("🚨 [SUBMIT ERROR] = ${e.response?.data}");
      throw Exception('결과 제출 실패');
    }
  }
}
