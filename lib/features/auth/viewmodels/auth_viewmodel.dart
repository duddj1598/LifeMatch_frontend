// lib/features/01_auth/viewmodels/auth_viewmodel.dart

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

  // SHA256 비밀번호 암호화
  String _encryptPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    if (message != null) {
      _isLoading = false;
      notifyListeners();
    }
  }

  // -------------------------------------------------------
  // 🔥 회원가입 로직 수정 — 백엔드와 동일 구조로 맞춤
  // -------------------------------------------------------
  Future<bool> signup({
    required String userId,
    required String email,
    required String nickname,
    required String password,
    required String securityQuestion,   // ⭐ 추가됨
    required String securityAnswer,     // ⭐ 추가됨
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final encryptedPassword = _encryptPassword(password);

      // ⭐ 백엔드 스키마에 맞춘 signup 호출
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
      _setError(e.toString().replaceFirst("Exception: ", ""));
      return false;
    }
  }

  void _setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  // -------------------------------------------------------
  // 🔐 로그인 로직 (수정 없음)
  // -------------------------------------------------------
  Future<bool?> login(String email, String password) async {
    _setLoading(true);
    _setErrorMessage(null);

    try {
      final encryptedPassword = _encryptPassword(password);

      final Map<String, dynamic> responseData =
      await _authService.login(email, encryptedPassword);

      final String? accessToken = responseData['accessToken'];
      final bool? hasCompletedSurvey = responseData['hasCompletedSurvey'];
      final String? backendNickname = responseData['nickname'];

      if (accessToken != null) {
        Map<String, dynamic> payload = {};
        try {
          payload = Jwt.parseJwt(accessToken);
        } catch (_) {}

        final String? jwtNickname = payload['nickname'];
        final String? nickname = backendNickname ?? jwtNickname;

        await _storageService.saveToken(accessToken);

        final String? userId = responseData["user_id"];
        if (userId != null) await _storageService.saveUserId(userId);

        if (nickname != null && nickname.isNotEmpty) {
          await _storageService.saveNickname(nickname);
        }

        if (hasCompletedSurvey != null) {
          await _storageService.saveLifestyleType(hasCompletedSurvey.toString());
        }

        _setLoading(false);
        return hasCompletedSurvey;
      } else {
        _setErrorMessage("로그인에 실패했습니다. (토큰 없음)");
        _setLoading(false);
        return null;
      }

    } catch (e) {
      _setErrorMessage(e.toString());
      _setLoading(false);
      throw Exception(e.toString());
    }
  }
}
