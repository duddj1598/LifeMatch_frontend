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
  Future<void> sendMessage(String chatId, String message) async {
    try {
      final headers = await _getHeaders();

      await dio.post(
        '/api/chat/$chatId/message',
        data: {"message": message},
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
}
