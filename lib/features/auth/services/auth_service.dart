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