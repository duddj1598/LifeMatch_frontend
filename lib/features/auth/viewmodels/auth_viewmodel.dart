// lib/features/auth/viewmodels/auth_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Provider import (사용하지 않더라도 기본 유지)
import 'package:lifematch_frontend/features/auth/services/auth_service.dart';
import 'package:lifematch_frontend/core/services/storage_service.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'dart:convert';

import '../../../core/services/api_client.dart' as ApiClient;
// crypto import 제거 (AuthService로 이동)
// import 'package:crypto/crypto.dart';

class AuthViewModel extends ChangeNotifier {
  // ⚠️ 주의: Stack Overflow를 해결하려면 이 부분은 Provider를 통해 주입받아야 합니다.
  final AuthService _authService = AuthService(dio: ApiClient.dio);
  final StorageService _storageService = StorageService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // 🔐 SHA256 암호화 함수 제거 (AuthService로 이동)
  // String encryptPassword(String password) { ... }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  // -------------------------------------------------------
  // 🔥 회원가입 (AuthService로 평문 비밀번호 전달)
  // -------------------------------------------------------
  Future<bool> signup({
    required String userId,
    required String email,
    required String nickname,
    required String password, // ⭐️ 평문 비밀번호를 받음
    required String securityQuestion,
    required String securityAnswer,
  }) async {
    _setLoading(true);
    _setErrorMessage(null);

    try {
      // ⭐️ 해싱은 AuthService에서 담당
      await _authService.signup(
        userId: userId,
        email: email,
        nickname: nickname,
        password: password, // ⭐️ 평문 전달
        securityQuestion: securityQuestion,
        securityAnswer: securityAnswer,
      );

      _setLoading(false);
      return true;

    } catch (e) {
      _setErrorMessage(e.toString().replaceFirst("Exception: ", ""));
      _setLoading(false);
      return false;
    }
  }

  // -------------------------------------------------------
  // 🔐 로그인 (AuthService로 평문 비밀번호 전달)
  // -------------------------------------------------------
  Future<bool?> login(String email, String password) async {
    _setLoading(true);
    _setErrorMessage(null);

    try {
      // ⭐️ 해싱은 AuthService에서 담당
      final Map<String, dynamic> responseData =
      await _authService.login(email, password); // ⭐️ 평문 전달

      final String? accessToken = responseData['accessToken'];
      final bool hasCompletedSurvey = responseData['hasCompletedSurvey'] == true;
      final String? backendNickname = responseData['nickname'];

      if (accessToken == null) {
        _setErrorMessage("로그인 실패: 토큰 없음");
        _setLoading(false);
        return null;
      }

      // 🔥 JWT 디코딩
      Map<String, dynamic> payload = Jwt.parseJwt(accessToken);

      // 🔥 Firestore user_doc_id 가져오기
      final String? userDocId = payload["sub"];

      // -------------------------------
      // 🔥 저장해야 할 값들
      // -------------------------------
      await _storageService.saveToken(accessToken);

      if (userDocId != null) {
        await _storageService.saveUserId(userDocId);
      }

      if (backendNickname != null && backendNickname.isNotEmpty) {
        await _storageService.saveNickname(backendNickname);
      }

      await _storageService.saveLifestyleType(
          hasCompletedSurvey.toString());

      _setLoading(false);
      return hasCompletedSurvey;

    } catch (e) {
      _setErrorMessage(e.toString());
      _setLoading(false);
      rethrow; // ⭐️ 예외 발생 시 상위 _handleLogin의 catch로 전파
    }
  }
}