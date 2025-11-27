import 'package:dio/dio.dart';
import 'package:lifematch_frontend/core/services/api_client.dart' as ApiClient;

class ProfileApi {
  static final Dio dio = ApiClient.dio;

  /// ------------------------------------------
  /// 1) 내 프로필 조회
  /// GET /api/user/profile
  /// ------------------------------------------
  static Future<Map<String, dynamic>?> getUserProfile(String accessToken) async {
    try {
      final response = await dio.get(
        '/api/user/profile',
        options: Options(
          headers: {
            "Authorization": "Bearer $accessToken",
          },
        ),
      );

      print("🔵 GET /api/user/profile status: ${response.statusCode}");
      print("🔵 body: ${response.data}");

      return response.data;

    } on DioException catch (e) {
      print("❌ 프로필 조회 실패: ${e.response?.data}");
      return null;
    } catch (e) {
      print("🔥 GET 프로필 오류: $e");
      return null;
    }
  }

  /// ------------------------------------------
  /// 2) 프로필 수정
  /// PATCH /api/user/profile
  /// ------------------------------------------
  static Future<bool> updateProfile(
      String accessToken,
      Map<String, dynamic> profileData,
      ) async {
    try {
      final response = await dio.patch(
        '/api/user/profile',
        data: profileData,
        options: Options(
          headers: {
            "Authorization": "Bearer $accessToken",
          },
        ),
      );

      print("🟣 PATCH /api/user/profile → ${response.statusCode}");
      print("🟣 request: $profileData");

      return response.statusCode == 200;

    } on DioException catch (e) {
      print("❌ PATCH 프로필 수정 실패: ${e.response?.data}");
      return false;
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
    try {
      final response = await dio.patch(
        '/api/user/settings/notifications',
        data: settings,
        options: Options(
          headers: {
            "Authorization": "Bearer $accessToken",
          },
        ),
      );

      print("🟡 PATCH /api/user/settings/notifications → ${response.statusCode}");
      print("🟡 request: $settings");

      return response.statusCode == 200;

    } on DioException catch (e) {
      print("❌ PATCH 알림 설정 실패: ${e.response?.data}");
      return false;
    } catch (e) {
      print("🔥 PATCH 알림 설정 오류: $e");
      return false;
    }
  }
}
