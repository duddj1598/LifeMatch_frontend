// lib/features/group/services/group_service.dart

import 'dart:convert';
import 'package:dio/dio.dart'; // ⭐️ http 대신 Dio 사용
import 'package:lifematch_frontend/core/services/api_client.dart' as ApiClient;
import 'package:lifematch_frontend/core/services/storage_service.dart';
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

  Future<GroupModel> createGroup({
    required String groupName,
    required String description,
    required String category,
    required int capacity,
    required String location,
    String? imageUrl, // 선택 사항
  }) async {
    try {
      final String? accessToken = await _storageService.getToken();
      final String? myId = await _storageService.getUserId(); // 내 ID (Leader ID) 가정을 위해 추가
      final String? myNickname = await _storageService.getNickname(); // 내 닉네임 가정을 위해 추가

      if (accessToken == null || myId == null || myNickname == null) {
        throw Exception("사용자 정보(토큰, ID, 닉네임)가 부족합니다. 다시 로그인 해주세요.");
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

        // GroupModel의 ID는 백엔드 응답에서 'id' 또는 'group_id'로 받아야 합니다.
        final String newGroupId = jsonResponse['id'] ?? jsonResponse['group_id'] ?? '';

        if (newGroupId.isEmpty) {
          throw Exception("소모임은 생성되었으나, 서버 응답에 그룹 ID가 없습니다.");
        }

        // ⭐️ [수정] GroupModel 객체 생성
        final GroupModel newGroup = GroupModel(
          id: newGroupId, // Firestore 문서 ID
          groupName: jsonResponse['group_name'] ?? groupName,
          category: category,
          description: jsonResponse['description'] ?? description,

          // ⭐️ 필수 필드: 서버 응답 또는 기본값/로컬 정보를 사용
          currentMember: jsonResponse['current_member'] ?? 1, // 생성자는 멤버 1명
          maxMember: jsonResponse['max_member'] ?? capacity,
          leaderId: myId, // 로컬에 저장된 사용자 ID를 리더 ID로 가정
          leaderNickname: myNickname, // 로컬에 저장된 닉네임을 리더 닉네임으로 가정
          members: [myNickname], // 생성자 본인만 포함

          // Nullable 필드
          groupImage: jsonResponse['group_image'] ?? imageUrl,
          createdAt: jsonResponse['created_at'],
          chatId: jsonResponse['chat_id'],
        );

        return newGroup;
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

  Future<List<GroupModel>> getGroupList({String? category,String? q}) async {
    try {
      // 1. 토큰을 가져와 헤더에 포함합니다.
      final String? accessToken = await _storageService.getToken();

      final Map<String, dynamic> headers = {
        'Content-Type': 'application/json',
      };
      if (accessToken != null) {
        headers['Authorization'] = 'Bearer $accessToken';
      }

      // 2. 쿼리 파라미터 설정
      final Map<String, dynamic> queryParams = {};

      queryParams['q'] = q?.trim() ?? "";

      // ⭐️ category가 유효하면 쿼리 파라미터에 추가
      if (category != null && category.isNotEmpty && category != '전체') {
        // 서버 API 명세에 맞춰 쿼리 파라미터 이름 설정 (예: category_name)
        queryParams['category'] = category;
        print("➡️ [GroupService] 그룹 목록 조회 요청 (Category: $category)");
      } else {
        print("➡️ [GroupService] 그룹 목록 조회 요청 (전체 카테고리)");
      }


      // 3. Dio GET 요청
      final response = await dio.get(
        '/api/group', // ⭐️ 소모임 목록 엔드포인트 가정
        queryParameters: queryParams, // ⭐️ 쿼리 파라미터 전달
        options: Options(
          headers: headers,
        ),
      );

      if (response.statusCode == 200) {
        // 4. 응답 데이터를 GroupModel 리스트로 변환
        final List<dynamic> jsonList = response.data;

        return jsonList.map((json) {
          // GroupModel.fromJson에 id를 명시적으로 전달하거나, JSON 응답 내 'id'를 사용합니다.
          final String groupId = json['id'] ?? '';
          return GroupModel.fromJson(json, groupId);
        }).toList();

      } else {
        throw Exception("그룹 목록 로드 실패: Status Code ${response.statusCode}");
      }
    } on DioException catch (e) {
      print("❌ [Group API ERROR] ${e.response?.data}");
      throw Exception(e.response?.data['detail'] ?? '그룹 목록 로드 실패');
    } catch (e) {
      throw Exception('알 수 없는 오류 발생: $e');
    }
  }
}