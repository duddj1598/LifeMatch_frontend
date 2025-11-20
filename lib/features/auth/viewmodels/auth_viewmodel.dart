// lib/features/01_auth/viewmodels/auth_viewmodel.dart

import 'package:flutter/material.dart';
// 1. 의존하는 서비스들을 임포트
import 'package:lifematch_frontend/features/auth/services/auth_service.dart';
import 'package:lifematch_frontend/core/services/storage_service.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

// 2. 'ChangeNotifier'를 상속(extends)하여 ViewModel을 만듭니다.
class AuthViewModel extends ChangeNotifier {

  // 3. 의존성: 서비스들을 내부에 가집니다. (나중에 DI로 주입하면 더 좋습니다)
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();

  // 4. 상태: UI가 감시(watch)할 변수들
  bool _isLoading = false;
  bool get isLoading => _isLoading; // UI가 읽을 수 있도록 public getter 제공

  String? _errorMessage;
  String? get errorMessage => _errorMessage; // UI가 에러 메시지를 읽을 수 있도록 getter 제공

  String _encryptPassword(String password) {
    final bytes = utf8.encode(password); // 1. 비밀번호를 바이트로 변환
    final digest = sha256.convert(bytes); // 2. SHA-256 해시 생성
    return digest.toString(); // 3. 해시 값을 문자열로 반환
  }

  // 5. 상태 변경 헬퍼: 상태를 변경하고 UI에 알림 (notifyListeners)
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners(); //이 함수가 호출되면 UI가 새로고침
  }

  void _setError(String? message) {
    _errorMessage = message;
    // 에러 발생 시 로딩은 해제
    if (message != null) {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- 회원가입 로직 (UI가 호출할 함수) ---
  // --- 회원가입 로직 (UI가 호출할 함수) ---
  Future<bool> signup({
    required String email,
    required String nickname,
    required String password,
  }) async {
    _setLoading(true); // 1. 로딩 시작
    _setError(null);   // 2. 이전 에러 메시지 초기화

    try {
      // ⭐️ 3. (수정) 회원가입 시에도 비밀번호를 암호화합니다.
      final encryptedPassword = _encryptPassword(password);

      // ⭐️ 4. (수정) 암호화된 비밀번호를 전송합니다.
      await _authService.signup(
        email: email,
        nickname: nickname,
        password: encryptedPassword, // 👈 암호화된 값
      );

      _setLoading(false); // 5. 로딩 종료
      return true; // ⭐️ UI에 "성공" 알림

    } catch (e) {
      _setError(e.toString().replaceFirst("Exception: ", ""));
      return false; // ⭐️ UI에 "실패" 알림
    }
  }

  void _setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }
  // --- (임시) 로그인 로직 (나중에 사용) ---
  Future<bool?> login(String email, String password) async {
    _setLoading(true);
    _setErrorMessage(null);

    try {
      print("[로그인 1] 암호화 시작");
      final encryptedPassword = _encryptPassword(password);

      print("[로그인 2] API 서비스 호출");
      final Map<String, dynamic> responseData =
      await _authService.login(email, encryptedPassword);
      print("🔥🔥 로그인 서버 응답 전체: $responseData");


      print("[로그인 3] 200 OK 받음. 데이터: $responseData");
      final String? accessToken = responseData['accessToken'];
      final bool? hasCompletedSurvey = responseData['hasCompletedSurvey'];
      final String? backendNickname = responseData['nickname'];

      if (accessToken != null) {
        print("[로그인 4] JWT 디코딩 시도");
        String? jwtNickname;
        try {
          Map<String, dynamic> payload = Jwt.parseJwt(accessToken);
          jwtNickname = payload['nickname'];
        } catch (e) { jwtNickname = null; }

        final String? nickname = backendNickname ?? jwtNickname;

        print("[로그인 5] 'saveToken' 호출 시도");
        await _storageService.saveToken(accessToken);

        print("[로그인 6] 'saveUserId' 호출 시도");
        final String? userId = responseData["user_id"];

        if (userId != null) {
          await _storageService.saveUserId(userId);
        } else {
          print("🚨 서버에서 user_id를 보내지 않음!");
        }


        print("[로그인 7] 'saveNickname' 호출 시도");
        if (nickname != null && nickname.isNotEmpty) {
          await _storageService.saveNickname(nickname);
        }

        print("[로그인 8] 'saveLifestyleType' 호출 시도");
        if (hasCompletedSurvey != null) {
          await _storageService.saveLifestyleType(hasCompletedSurvey.toString());
        }

        print("[로그인 9] '_setLoading(false)' 호출 시도");
        _setLoading(false);

        print("[로그인 10] 성공! 반환");
        return hasCompletedSurvey;
      } else {
        _setErrorMessage("로그인에 실패했습니다. (토큰 없음)");
        _setLoading(false);
        return null;
      }

    } catch (e) {
      print("🚨🚨 [로그인 치명적 오류] 🚨🚨");
      print(e.toString()); // ⭐️ 오류 내용 출력
      _setErrorMessage(e.toString());
      _setLoading(false);
      throw Exception(e.toString());
    }
  }
}
