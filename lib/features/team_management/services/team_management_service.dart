import 'package:dio/dio.dart';
import 'package:lifematch_frontend/core/services/api_client.dart'; // dio 인스턴스 (Base URL 설정 필요)
import 'package:lifematch_frontend/core/services/storage_service.dart'; // 토큰 관리를 위한 서비스
import 'package:lifematch_frontend/features/auth/models/user_group_model.dart'; // UserGroup 모델

class TeamManagementService {
  // dio 인스턴스는 api_client.dart에서 전역으로 정의된 것을 사용합니다.
  final Dio _dio = dio;
  final StorageService _storageService = StorageService();

  // JWT 헤더 생성 헬퍼 함수
  Future<Map<String, String>> _getHeaders() async {
    final token = await _storageService.getToken();

    if (token == null) {
      // ⚠️ 토큰이 없을 경우, 로그인 필요 예외 발생
      throw Exception("토큰이 없습니다. 로그인 상태를 확인하세요.");
    }

    return {
      "authorization": "Bearer $token",
      "Content-Type": "application/json",
    };
  }

  // ---------------------------------------------------------
  // ⭐️ 내가 관리/참여하는 소모임 목록을 가져오는 통합 함수
  // ---------------------------------------------------------
  /// '/api/auth/managed'와 '/api/auth/joined' API를 호출하여
  /// 내가 리더인 그룹과 멤버인 그룹 목록을 반환합니다.
  Future<Map<String, List<UserGroup>>> getMyGroupLists() async {
    final headers = await _getHeaders();
    List<UserGroup> managedGroups = [];
    List<UserGroup> joinedGroups = [];

    // 1. 내가 관리하는 소모임 목록 호출: /api/auth/managed
    try {
      final Response managedResponse = await _dio.get(
        '/api/auth/managed',
        options: Options(headers: headers),
      );

      // 백엔드 스키마 (MyGroupListResponse)에 맞춰 'groups' 키를 파싱
      final data = managedResponse.data as Map<String, dynamic>;

      if (data.containsKey('groups') && data['groups'] is List) {
        managedGroups = (data['groups'] as List)
            .map((json) => UserGroup.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    } on DioException catch (e) {
      print("❌ 관리 소모임 목록 API 오류: ${e.response?.data}");
      // 401 Unauthorized 에러 등의 상세 정보를 사용자에게 전달
      throw Exception(e.response?.data['detail'] ?? "관리 소모임 목록 불러오기 실패");
    }

    // 2. 내가 참여하는 소모임 목록 호출: /api/auth/joined
    try {
      final Response joinedResponse = await _dio.get(
        '/api/auth/joined',
        options: Options(headers: headers),
      );

      // 백엔드 스키마 (MyGroupListResponse)에 맞춰 'groups' 키를 파싱
      final data = joinedResponse.data as Map<String, dynamic>;

      if (data.containsKey('groups') && data['groups'] is List) {
        // 관리 소모임 목록 ID 집합 생성 (중복 제거용)
        final Set<String> managedIds = managedGroups.map((g) => g.id).toSet();

        joinedGroups = (data['groups'] as List)
            .map((json) => UserGroup.fromJson(json as Map<String, dynamic>))
        // ⭐️ 리더인 그룹이 참여 목록에 중복되지 않도록 필터링
            .where((group) => !managedIds.contains(group.id))
            .toList();
      }
    } on DioException catch (e) {
      print("❌ 참여 소모임 목록 API 오류: ${e.response?.data}");
      throw Exception(e.response?.data['detail'] ?? "참여 소모임 목록 불러오기 실패");
    }

    return {
      'managed': managedGroups,
      'joined': joinedGroups,
    };
  }
}