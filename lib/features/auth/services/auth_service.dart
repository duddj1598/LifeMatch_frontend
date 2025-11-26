// lib/features/auth/services/auth_service.dart

import 'package:dio/dio.dart';
import 'package:lifematch_frontend/core/services/api_client.dart'; // DioClient를 사용하지 않는다면 제거 가능
import 'package:lifematch_frontend/core/models/token_data.dart'; // 사용하지 않는다면 제거 가능
// import 'package:lifematch_frontend/features/auth/viewmodels/auth_viewmodel.dart'; // ⭐️ ViewModel 참조 제거

// ⭐️ SHA256 암호화를 위한 import 추가
import 'dart:convert';
import 'package:crypto/crypto.dart';

class AuthService {
  // ⭐️ Dio 인스턴스를 필수로 정의
  final Dio dio;

  // ⭐️ 생성자를 통해 Dio 인스턴스 주입
  AuthService({required this.dio});

  // 🔐 SHA256 암호화 함수 (ViewModel에서 가져옴)
  String _encryptPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }


  // --- 회원가입 함수 (해싱 적용) ---
  Future<void> signup({
    required String userId,
    required String email,
    required String nickname,
    required String password, // ⭐️ 평문 비밀번호 받음
    required String securityQuestion,
    required String securityAnswer,
  }) async {
    try {
      final encryptedPassword = _encryptPassword(password); // ⭐️ 해싱 적용

      await dio.post(
        '/api/auth/signup',
        data: {
          'user_email': email,
          'user_id': userId,
          'user_nickname': nickname,
          'user_password': encryptedPassword, // ⭐️ 해싱된 비밀번호 전송

          'user_security_question': securityQuestion,
          'user_security_answer': securityAnswer,
          'user_lifestyle_vector': [],
          'user_joined_groups_id': null,
          'user_owned_groups_id': null,
          'panel_id': null,
          'user_lifestyle_type': null,
        },
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? "회원가입 실패");
    }
  }


  // --- 로그인 함수 (해싱 적용) ---
  Future<Map<String, dynamic>> login(String id, String password) async {
    try {
      final encryptedPassword = _encryptPassword(password); // ⭐️ 해싱 적용

      final response = await dio.get(
        '/api/auth/login',
        queryParameters: {
          'id': id,
          'password': encryptedPassword, // ⭐️ 해싱된 비밀번호 전송
        },
      );

      return response.data;

    } on DioException catch (e) {
      print("로그인 실패: ${e.response?.data}");
      throw Exception(e.response?.data['detail'] ?? '로그인 실패');
    } catch (e) {
      print("알 수 없는 오류: $e");
      throw Exception('알 수 없는 오류 발생');
    }
  }

  // --- 아이디 찾기 ---
  Future<String> findUserId({
    required String email,
    required String securityQuestion,
    required String securityAnswer,
  }) async {
    try {
      final response = await dio.post(
        '/api/auth/find-id',
        data: {
          'user_email': email,
          'security_question': securityQuestion,
          'security_answer': securityAnswer,
        },
      );
      print("아이디 찾기 응답: ${response.data}");
      return response.data['user_id'];
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? "아이디 찾기 실패");
    }
  }

  // --- 비밀번호 재설정 함수 (해싱 적용) ---
  Future<bool> resetPassword({
    required String loginId,
    required String email,
    required String securityQuestion,
    required String securityAnswer,
    required String newPassword, // ⭐️ 평문 비밀번호 받음
  }) async {
    try {
      // ⭐️⭐️ [핵심 수정] 새 비밀번호를 해싱하여 전송 ⭐️⭐️
      final String encryptedNewPassword = _encryptPassword(newPassword);

      final response = await dio.put(
        '/api/auth/reset-password',
        data: {
          'login_id': loginId,
          'user_email': email,
          'security_question': securityQuestion,
          'security_answer': securityAnswer,
          'new_password': encryptedNewPassword, // ⭐️ 해싱된 비밀번호 전송
        },
      );

      print("비밀번호 재설정 응답: ${response.data}");

      return response.statusCode == 200;
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? "비밀번호 재설정 실패");
    }
  }
}