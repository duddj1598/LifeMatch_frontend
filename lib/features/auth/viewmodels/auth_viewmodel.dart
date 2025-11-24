// lib/features/auth/viewmodels/auth_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:lifematch_frontend/features/auth/services/auth_service.dart';
import 'package:lifematch_frontend/core/services/storage_service.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // 🔐 SHA256 암호화
  String _encryptPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  // -------------------------------------------------------
  // 🔥 회원가입 (백엔드 스키마 완전히 반영)
  // -------------------------------------------------------
  Future<bool> signup({
    required String userId,
    required String email,
    required String nickname,
    required String password,
    required String securityQuestion,
    required String securityAnswer,
  }) async {
    _setLoading(true);
    _setErrorMessage(null);

    try {
      final encryptedPassword = _encryptPassword(password);

      await _authService.signup(
        userId: userId,
        email: email,
        nickname: nickname,
        password: encryptedPassword,
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
  // 🔐 로그인 (JWT 기반 처리)
  // -------------------------------------------------------
  Future<bool?> login(String email, String password) async {
    _setLoading(true);
    _setErrorMessage(null);

    try {
      final encryptedPassword = _encryptPassword(password);

      final Map<String, dynamic> responseData =
      await _authService.login(email, encryptedPassword);

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
      return null;
    }
  }
}
