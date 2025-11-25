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

  // --- 아이디 찾기 ---
  Future<String> findUserId({
    required String email,
    required String securityQuestion,
    required String securityAnswer,
  }) async {
    try {
      final response = await dio.post(
        '/api/auth/find-id',
        data: {
          'user_email': email,
          'security_question': securityQuestion,
          'security_answer': securityAnswer,
        },
      );

      print("아이디 찾기 응답: ${response.data}");

      // FastAPI: FindIdResponse(status, user_nickname)
      return response.data['user_id'];
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? "아이디 찾기 실패");
    }
  }

  // --- 비밀번호 재설정 ---
  Future<bool> resetPassword({
    required String loginId,
    required String email,
    required String securityQuestion,
    required String securityAnswer,
    required String newPassword,
  }) async {
    try {
      final response = await dio.put(
        '/api/auth/reset-password',
        data: {
          'login_id': loginId,
          'user_email': email,
          'security_question': securityQuestion,
          'security_answer': securityAnswer,
          'new_password': newPassword,
        },
      );

      print("비밀번호 재설정 응답: ${response.data}");

      return response.statusCode == 200;
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? "비밀번호 재설정 실패");
    }
  }
}