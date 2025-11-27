import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lifematch_frontend/core/services/api_client.dart';

class ChatService {
  final storage = const FlutterSecureStorage();

  // JWT 헤더 불러오기
  Future<Map<String, String>> _getHeaders() async {
    final token = await storage.read(key: 'access_token');

    if (token == null) {
      throw Exception("토큰이 없습니다. 로그인하세요.");
    }

    return {
      "authorization": "Bearer $token",
      "Content-Type": "application/json",
    };
  }

  // ---------------------------------------------------------
  // 1. 채팅방 목록 조회
  // ---------------------------------------------------------
  Future<List<dynamic>> getChatRooms() async {
    try {
      final headers = await _getHeaders();

      final response = await dio.get(
        '/api/chat/list',
        options: Options(headers: headers),
      );

      final data = response.data;

      // 🔥 여기서 list 꺼내기
      if (data is Map && data['list'] is List) {
        return data['list'];
      }

      throw Exception("지원하지 않는 응답 형식: $data");

    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? "채팅방 목록 불러오기 실패");
    }
  }


  // ---------------------------------------------------------
  // 2. 채팅 메시지 조회
  // ---------------------------------------------------------
  Future<Map<String, dynamic>> getChatMessages(String chatId, {int? messageId}) async {
    try {
      final headers = await _getHeaders();

      final response = await dio.get(
        '/api/chat/$chatId/message',
        queryParameters: {
          if (messageId != null) "message_id": messageId,
          "size": 20,
        },
        options: Options(headers: headers),
      );

      final data = response.data;

      if (data is Map<String, dynamic>) {
        return data;  // 🔥 이 dict에는 messages + next_message_id 가 들어 있음
      }

      throw Exception("지원하지 않는 응답 형식: $data");
    } on DioException catch (e) {
      print("채팅 내역 오류: ${e.response?.data}");
      throw Exception(e.response?.data['detail'] ?? "채팅 내역 불러오기 실패");
    }
  }


  // ---------------------------------------------------------
  // 3. 메시지 전송
  // ---------------------------------------------------------
  Future<void> sendMessage(String chatId, String content) async {
    try {
      final headers = await _getHeaders();

      await dio.post(
        '/api/chat/$chatId/message',
        data: {
          "content": content, // ⭐️ [수정] 백엔드 ChatMessageCreate 스키마에 맞게 "content" 사용
          "attachments": [],  // ⭐️ [추가] attachments 필드도 빈 리스트로 전송
        },
        options: Options(headers: headers),
      );

    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? "메시지 전송 실패");
    }
  }

  // ---------------------------------------------------------
  // 4. 채팅방 나가기
  // ---------------------------------------------------------
  Future<bool> leaveChatRoom(String chatId) async {
    try {
      final headers = await _getHeaders();

      final response = await dio.delete(
        '/api/chat/leave',
        queryParameters: {"chat_id": chatId},
        options: Options(headers: headers),
      );

      return response.statusCode == 200;
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? "채팅방 나가기 실패");
    }
  }

  // ---------------------------------------------------------
  // 5. 🔥 채팅방 생성 (DM 또는 Group)
  // ---------------------------------------------------------
  Future<Map<String, dynamic>> createChatRoom({
    required String type, // "group" 또는 "dm"
    String? groupId,
    List<String>? targetIds, // DM일 경우 상대방의 user_id 목록 (1개)
  }) async {
    try {
      final headers = await _getHeaders();

      // 요청 본문 구성
      final data = {
        "type": type,
        if (groupId != null) "group_id": groupId,
        if (targetIds != null) "target_ids": targetIds,
      };

      final response = await dio.post(
        '/api/chat/create', // ⭐️ 채팅방 생성 엔드포인트
        data: data,
        options: Options(headers: headers),
      );

      final responseData = response.data;

      if (responseData is Map<String, dynamic> && responseData.containsKey('chat_id')) {
        // 성공 응답 (chat_id, members 등이 포함됨)
        return responseData;
      }

      throw Exception("채팅방 생성 응답 오류");

    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? "채팅방 생성 실패");
    }
  }
}
