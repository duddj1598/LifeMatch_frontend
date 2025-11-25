// lib/features/group/services/group_service.dart

import 'dart:convert';
import 'package:dio/dio.dart'; // ⭐️ http 대신 Dio 사용
import 'package:lifematch_frontend/core/services/api_client.dart' as ApiClient;
import 'package:lifematch_frontend/core/services/storage_service.dart';
import '../../team_management/screens/team_management_screen.dart';
import '../models/group_model.dart';

class GroupService {
  // ⭐️ ApiClient에서 설정된 Dio 인스턴스를 사용합니다.
  final Dio dio = ApiClient.dio;
  final StorageService _storageService = StorageService();

  // -------------------------------------------------
  // 🔍 그룹 상세 조회 API 연결 (GET /api/group/{group_id})
  // -------------------------------------------------
  /// 특정 소모임의 상세 정보를 가져옵니다.
  Future<GroupModel> getGroupDetail(String groupId) async {
    try {
      // 1. 토큰을 가져와 헤더에 포함합니다.
      final String? accessToken = await _storageService.getToken();

      final Map<String, dynamic> headers = {
        'Content-Type': 'application/json',
      };
      if (accessToken != null) {
        headers['Authorization'] = 'Bearer $accessToken';
      }

      // 2. Dio GET 요청 (BaseUrl이 이미 ApiClient에 설정되어 있으므로 상대 경로만 사용)
      final response = await dio.get(
        '/api/group/$groupId', // ⭐️ 상대 경로 사용
        options: Options(
          headers: headers,
        ),
      );

      if (response.statusCode == 200) {
        // 3. 응답 데이터를 GroupModel로 변환하여 반환합니다.
        // Dio는 자동으로 JSON 디코딩을 처리합니다.
        final Map<String, dynamic> jsonResponse = response.data;

        // 백엔드 라우터가 GroupRead를 반환하며, Firestore 문서 ID가 'id' 필드에 포함되어 있습니다.
        // GroupModel.fromJson에 id를 명시적으로 전달하거나, JSON 응답 내 'id'를 사용합니다.
        final String receivedId = jsonResponse['id'] ?? groupId;

        return GroupModel.fromJson(jsonResponse, receivedId);

      } else {
        // 404 등 기타 상태 코드 처리
        throw Exception("그룹 상세 정보 로드 실패: Status Code ${response.statusCode}");
      }
    } on DioException catch (e) {
      // DioException을 통해 HTTP 에러를 처리합니다.
      if (e.response?.statusCode == 404) {
        throw Exception("요청하신 그룹 ID($groupId)를 찾을 수 없습니다.");
      }
      print("❌ [Group API ERROR] ${e.response?.data}");
      throw Exception(e.response?.data['detail'] ?? '그룹 상세 정보 로드 실패');
    } catch (e) {
      throw Exception('알 수 없는 오류 발생: $e');
    }
  }

  Future<GroupDetail> createGroup({
    required String groupName,
    required String description,
    required String category,
    required int capacity,
    required String location,
    String? imageUrl, // 선택 사항
  }) async {
    try {
      final String? accessToken = await _storageService.getToken();

      if (accessToken == null) {
        throw Exception("로그인 토큰이 없습니다. 다시 로그인 해주세요.");
      }

      final Map<String, dynamic> data = {
        'group_name': groupName,
        'description': description,
        'category': category,
        'capacity': capacity,
        'location': location,
        // 'image_url': imageUrl, // 서버 모델에 따라 필드명 조정 필요
      };

      final response = await dio.post(
        '/api/group/create',
        data: data,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse = response.data;

        // 서버 응답과 입력 받은 인자를 조합하여 GroupDetail 객체 생성
        final GroupDetail newGroupDetail = GroupDetail(
          groupId: jsonResponse['id'] ?? jsonResponse['group_id'] ?? '',
          groupName: jsonResponse['group_name'] ?? groupName, // 응답 없으면 입력값 사용
          groupTopic: category, // ⭐️ 인자로 받은 'category'를 'groupTopic'에 할당
          groupDescription: jsonResponse['description'] ?? description, // 응답 없으면 입력값 사용
          currentCapacity: jsonResponse['current_member'] ?? 1,
          maxCapacity: jsonResponse['max_member'] ?? capacity, // 응답 없으면 입력값 사용
          members: (jsonResponse['members'] as List<dynamic>?)?.map((id) => id.toString()).toList() ?? [],
        );

        if (newGroupDetail.groupId.isEmpty) {
          throw Exception("소모임은 생성되었으나, 서버 응답에 그룹 ID가 없습니다.");
        }

        return newGroupDetail;
      } else {
        throw Exception("소모임 생성 실패: Status Code ${response.statusCode}");
      }
    } on DioException catch (e) {
      print("❌ [Create Group API ERROR] ${e.response?.data}");
      throw Exception(e.response?.data['detail'] ?? '소모임 생성 중 오류 발생');
    } catch (e) {
      throw Exception('알 수 없는 오류 발생: $e');
    }
  }

// -------------------------------------------------
// 🔒 (참고: 로그인 유저 그룹 목록도 Dio로 수정)
// -------------------------------------------------
/// 로그인된 유저가 속한 그룹 정보를 가져옵니다. (가정된 엔드포인트: /api/group/my-groups)
// 이전에 작성했던 getMyGroups 함수도 Dio를 사용하도록 수정할 수 있습니다.
/*
  Future<List<GroupModel>> getMyGroups() async {
    final String? accessToken = await _storageService.getToken();

    if (accessToken == null) {
      throw Exception("로그인 토큰이 없습니다. 다시 로그인 해주세요.");
    }

    try {
      final response = await dio.get(
        '/api/group/my-groups', // ⭐️ 상대 경로 사용
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      // List 형태의 응답을 가정
      final List<dynamic> jsonList = response.data;

      return jsonList.map((json) {
        final String groupId = json['id'];
        return GroupModel.fromJson(json, groupId);
      }).toList();

    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? '내 그룹 정보 로드 실패');
    }
  }
  */
}