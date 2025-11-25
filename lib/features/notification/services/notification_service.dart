import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lifematch_frontend/core/services/storage_service.dart';

class NotificationService {
  static const String baseUrl = "http://10.0.2.2:8000";

  final StorageService _storage = StorageService();

  // ---------------------------------------------------------
  // 🔒 알림 목록 조회
  // ---------------------------------------------------------
  Future<Map<String, dynamic>> getNotifications() async {
    final token = await _storage.getToken(); // 🔥 수정됨

    final response = await http.get(
      Uri.parse('$baseUrl/api/notifications/'),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("알림 목록 조회 실패: ${response.body}");
    }
  }

  // ---------------------------------------------------------
  // 🔒 초대/신청 응답(수락/거절)
  // ---------------------------------------------------------
  Future<bool> respondToAction(String actionId, String action) async {
    final token = await _storage.getToken(); // 🔥 수정됨
    final userId = await _storage.getUserId();

    if (userId == null) {
      print("❌ Error: 사용자 ID를 찾을 수 없습니다.");
      return false;
    }

    final Map<String, dynamic> requestBody = {
      "user_id": userId, // ⭐️ [필수] 서버 스키마에 맞춰 user_id 추가
      "action": action,
    };

    final response = await http.post(
      Uri.parse('$baseUrl/api/notifications/$actionId/respond'),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(requestBody), // ⭐️ 수정된 요청 본문 사용
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print("🚨🚨 ${response.statusCode} 에러 응답 본문: ${response.body}");
      return false;
    }
  }
}
