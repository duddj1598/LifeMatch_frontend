// lib/features/01_auth/viewmodels/auth_viewmodel.dart

import 'package:flutter/material.dart';
// 1. 의존하는 서비스들을 임포트
import 'package:lifematch_frontend/features/auth/services/auth_service.dart';
import 'package:lifematch_frontend/core/services/storage_service.dart';

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
  Future<bool> signup({
    required String email,
    required String nickname,
    required String password,
  }) async {
    _setLoading(true); // 1. 로딩 시작
    _setError(null);   // 2. 이전 에러 메시지 초기화

    try {
      // 실제 API 로직(서비스) 호출
      await _authService.signup(
        email: email,
        nickname: nickname,
        password: password,
      );

      _setLoading(false); // 4. 로딩 종료
      return true; // ⭐️ UI에 "성공" 알림

    } catch (e) {
      // 실패 시
      // e.toString()이 "Exception: 이미 사용 중인 이메일입니다." 처럼
      // "Exception: "을 포함하므로, 이를 제거하고 에러 메시지 저장
      _setError(e.toString().replaceFirst("Exception: ", ""));
      return false; // ⭐️ UI에 "실패" 알림
    }

  }
  void _setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }
  // --- (임시) 로그인 로직 (나중에 사용) ---
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _setErrorMessage(null); // ⭐️ 오타 확인: _setErrorMessage

    try {
      // ⭐️ 1. email 변수명을 id로 사용 (서비스 로직과 동일하게)
      final Map<String, dynamic> responseData =
      await _authService.login(email, password);

      // ⭐️ 2. 백엔드 응답에서 accessToken을 직접 추출
      final String? accessToken = responseData['accessToken'];

      if (accessToken != null) {
        // ⭐️ 3. 토큰만 StorageService에 저장
        await _storageService.saveToken(accessToken);

        // ⭐️ 4. (중요) refreshToken은 없으므로 저장하지 않음
        // (UserInfo도 없으므로 저장하지 않음)

        _setLoading(false);
        return true;
      } else {
        _setErrorMessage("로그인에 실패했습니다. (토큰 없음)"); // ⭐️ 오타 확인
        _setLoading(false);
        return false;
      }

    } catch (e) {
      _setErrorMessage(e.toString()); // ⭐️ 오타 확인
      _setLoading(false);
      return false;
    }
  }
}