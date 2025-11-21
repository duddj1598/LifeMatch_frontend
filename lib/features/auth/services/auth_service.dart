import 'package:dio/dio.dart';
import 'package:lifematch_frontend/core/services/api_client.dart';
import 'package:lifematch_frontend/core/models/token_data.dart';

class AuthService {

  // --- 회원가입 함수 ---
  Future<void> signup({
    required String userId,
    required String email,
    required String nickname,
    required String password,
    required String securityQuestion,
    required String securityAnswer,
  }) async {
    try {
      await dio.post(
        '/api/auth/signup',
        data: {
          'user_email': email,
          'user_id': userId,
          'user_nickname': nickname,
          'user_password': password,

          // 본인 인증 필드 (백엔드 필수)
          'user_security_question': securityQuestion,
          'user_security_answer': securityAnswer,

          // Optional but required keys
          'user_lifestyle_vector': [],
          'user_joined_groups_id': null,
          'user_owned_groups_id': null,
          'panel_id': null,
          'user_lifestyle_type': null,
        },
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? "회원가입 실패");
    }
  }



  // --- 로그인 함수 ---
  Future<Map<String, dynamic>> login(String id, String password) async {
    try {
      // ⭐️ 2. dio.post -> dio.get
      final response = await dio.get(
        '/api/auth/login', // (이 경로가 맞는지 확인하세요)
        // ⭐️ 3. data: {} -> queryParameters: {}
        queryParameters: {
          'id': id,       // 백엔드의 (id: str)
          'password': password, // 백엔드의 (password: str)
        },
      );

      // ⭐️ 4. 백엔드가 {"status": 200, "accessToken": ...}를 반환
      return response.data;

    } on DioException catch (e) {
      // (오류 처리)
      print("로그인 실패: ${e.response?.data}");
      throw Exception(e.response?.data['detail'] ?? '로그인 실패');
    } catch (e) {
      print("알 수 없는 오류: $e");
      throw Exception('알 수 없는 오류 발생');
    }
  }
}