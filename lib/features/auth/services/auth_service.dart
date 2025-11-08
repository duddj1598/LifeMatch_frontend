import 'package:dio/dio.dart';
import 'package:lifematch_frontend/core/services/api_client.dart';
import 'package:lifematch_frontend/core/models/token_data.dart';

class AuthService {

  // --- 회원가입 함수 ---
  Future<void> signup({
    required String email,
    required String nickname,
    required String password,
  }) async {
    try {
      //FastAPI의 /api/auth/signup 엔드포인트 호출
      await dio.post(
        '/api/auth/signup',
        data: {
          'user_email': email,
          'user_nickname': nickname,
          'user_password': password,
        },
      );
      // 회원가입 성공 시 (200 OK) 별다른 데이터를 반환하지 않음 (void)

    } on DioException catch (e) {
      // API 요청 실패 시
      if (e.response?.statusCode == 400) {
        // 400 Bad Request (이메일 중복 등 백엔드에서 보낸 오류)
        // FastAPI의 detail 메시지를 그대로 예외로 던집니다.
        throw Exception(e.response?.data['detail'] ?? "이미 사용 중인 이메일입니다.");
      }
      // 그 외 네트워크 오류 등
      throw Exception("회원가입 중 알 수 없는 오류가 발생했습니다.");
    }
  }

  // --- 로그인 함수 ---
  Future<TokenData> login(String email, String password) async {
    try {
      final response = await dio.post(
        '/api/auth/login',
        data: {
          'user_email': email,
          'user_password': password,
        },
      );

      // 성공 시 JSON 데이터를 TokenData 모델 객체로 변환하여 반환
      return TokenData.fromJson(response.data['data']);

    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        // 401 Unauthorized (아이디/비밀번호 틀림)
        throw Exception(e.response?.data['message'] ?? "로그인 정보가 올바르지 않습니다.");
      }
      throw Exception("로그인 중 알 수 없는 오류가 발생했습니다.");
    }
  }
}