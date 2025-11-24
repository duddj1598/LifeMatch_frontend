import 'dart:convert';
import 'package:http/http.dart' as http;

class ProfileApi {
  static const String baseUrl = "http://10.0.2.2:8000/api/user";

  /// ------------------------------------------
  /// 1) 내 프로필 조회 (JWT → 백에서 user 식별)
  /// GET /api/user/profile
  /// ------------------------------------------
  static Future<Map<String, dynamic>?> getUserProfile(
      String accessToken) async {
    final url = Uri.parse("$baseUrl/profile");

    try {
      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $accessToken",
          "Content-Type": "application/json",
        },
      );

      print("🔵 GET /profile status: ${response.statusCode}");
      print("🔵 body: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("❌ 프로필 조회 실패: ${response.body}");
        return null;
      }
    } catch (e) {
      print("🔥 GET 프로필 오류: $e");
      return null;
    }
  }

  /// ------------------------------------------
  /// 2) 프로필 수정
  /// PATCH /api/user/profile
  /// (JWT로 사용자 자동 식별)
  /// ------------------------------------------
  static Future<bool> updateProfile(
      String accessToken, Map<String, dynamic> profileData) async {
    final url = Uri.parse("$baseUrl/profile");

    try {
      final response = await http.patch(
        url,
        headers: {
          "Authorization": "Bearer $accessToken",
          "Content-Type": "application/json",
        },
        body: jsonEncode(profileData),
      );

      print("🟣 PATCH /profile → ${response.statusCode}");
      print("🟣 request: ${jsonEncode(profileData)}");

      return response.statusCode == 200;
    } catch (e) {
      print("🔥 PATCH 프로필 수정 오류: $e");
      return false;
    }
  }

  /// ------------------------------------------
  /// 3) 알림 설정 수정
  /// PATCH /api/user/settings/notifications
  /// ------------------------------------------
  static Future<bool> updateNotificationSettings(
      String accessToken,
      Map<String, dynamic> settings,
      ) async {
    final url = Uri.parse("$baseUrl/settings/notifications");

    try {
      final response = await http.patch(
        url,
        headers: {
          "Authorization": "Bearer $accessToken",
          "Content-Type": "application/json",
        },
        body: jsonEncode(settings),
      );

      print("🟡 PATCH /notifications → ${response.statusCode}");
      print("🟡 request: ${jsonEncode(settings)}");

      return response.statusCode == 200;
    } catch (e) {
      print("🔥 PATCH 알림 설정 오류: $e");
      return false;
    }
  }
}
