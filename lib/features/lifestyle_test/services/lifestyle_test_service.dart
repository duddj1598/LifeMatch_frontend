import 'package:dio/dio.dart';
import 'package:lifematch_frontend/core/services/api_client.dart'; // dio 인스턴스
import 'package:lifematch_frontend/features/lifestyle_test/models/lifestyle_test_model.dart';

import '../../../core/services/api_client.dart' as ApiClient; // (다음 단계에서 만들 모델)

class LifestyleTestService {
  final Dio dio = ApiClient.dio; // api_client.dart의 dio 인스턴스

  /// API: (GET) /user/lifestyle-test/questions
  /// 백엔드에서 질문 목록을 불러옵니다.
  Future<QuestionParts> getQuestions() async {
    try {
      final response = await dio.get('/user/lifestyle-test/questions');

      // ⭐️ 백엔드 응답 형식: {"status": 200, "data": {...}}
      // data.data가 실제 QuestionParts 객체입니다.
      return QuestionParts.fromJson(response.data['data']);

    } on DioException catch (e) {
      print("질문 로딩 실패: ${e.response?.data}");
      throw Exception('질문 목록을 불러오는데 실패했습니다.');
    }
  }

  /// API: (POST) /user/lifestyle-test/result
  /// 선택한 답변(option_ids)과 user_id를 서버로 전송합니다.
  Future<LifestyleTestResultDetail> submitTest(String userId, List<int> selectedOptionIds) async {
    try {
      final response = await dio.post(
        '/user/lifestyle-test/result',
        data: {
          'user_id': userId,
          'selected_option_ids': selectedOptionIds,
        },
      );

      // ⭐️ 백엔드 응답 형식: {"status": 200, "user_id": ..., "result": {...}}
      // data.result가 실제 LifestyleTestResultDetail 객체입니다.
      return LifestyleTestResultDetail.fromJson(response.data['result']);

    } on DioException catch (e) {
      print("결과 제출 실패: ${e.response?.data}");
      throw Exception('결과를 제출하는데 실패했습니다.');
    }
  }
}