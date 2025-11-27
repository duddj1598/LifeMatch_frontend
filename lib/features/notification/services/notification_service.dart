import 'package:dio/dio.dart';
import 'package:lifematch_frontend/core/services/api_client.dart' as ApiClient;
import 'package:lifematch_frontend/core/services/storage_service.dart';

class NotificationService {
  final Dio dio = ApiClient.dio; // 🔥 공통 Dio 인스턴스
  final StorageService _storage = StorageService();

  // ---------------------------------------------------------
  // 🔒 알림 목록 조회 (Dio)
  // ---------------------------------------------------------
  Future<Map<String, dynamic>> getNotifications() async {
    final token = await _storage.getToken();

    try {
      final response = await dio.get(
        '/api/notifications/',
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );

      return response.data;

    } on DioException catch (e) {
      print("🚨 알림 목록 조회 실패: ${e.response?.data}");
      throw Exception("알림 목록 조회 실패");
    }
  }

  // ---------------------------------------------------------
  // 🔒 초대/신청 응답(수락/거절) - Dio 버전
  // ---------------------------------------------------------
  Future<bool> respondToAction(String actionId, String action) async {
    final token = await _storage.getToken();
    final userId = await _storage.getUserId();

    if (userId == null) {
      print("❌ Error: 사용자 ID를 찾을 수 없습니다.");
      return false;
    }

    try {
      final response = await dio.post(
        '/api/notifications/$actionId/respond',
        data: {
          "user_id": userId, // 🔥 필수 값
          "action": action,
        },
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );

      return response.statusCode == 200;

    } on DioException catch (e) {
      print("🚨 응답 처리 실패: ${e.response?.data}");
      return false;
    }
  }
}
