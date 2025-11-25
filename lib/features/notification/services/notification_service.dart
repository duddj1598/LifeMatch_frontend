import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lifematch_frontend/core/services/storage_service.dart';

class NotificationService {
  static const String baseUrl = "http://localhost:8000";

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

    final response = await http.post(
      Uri.parse('$baseUrl/api/notifications/$actionId/respond'),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"action": action}),
    );

    return response.statusCode == 200;
  }
}
