import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  // 1. flutter_secure_storage 인스턴스 생성
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // 2. ⭐️ 토큰을 저장할 때 사용할 키(key)
  static const String _tokenKey = 'access_token';
  static const String _userIdKey = 'user_id';

  static const String _nicknameKey = 'user_nickname';

  // --- 👇 3. (오류 해결) 'saveToken' 함수 ---
  /// (로그인 성공 시) 토큰을 기기에 저장합니다.
  Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: _tokenKey, value: token);
    } catch (e) {
      print("토큰 저장 실패: $e");
      // (오류 처리)
    }
  }

  Future<void> saveNickname(String nickname) async {
    await _storage.write(key: _nicknameKey, value: nickname);
  }
  Future<String?> getNickname() async {
    return await _storage.read(key: _nicknameKey);
  }

  // --- 4. (나중에 필요함) 저장된 토큰을 읽어오는 함수 ---
  /// (앱 시작 시) 저장된 토큰을 불러옵니다.
  Future<String?> getToken() async {
    try {
      final token = await _storage.read(key: _tokenKey);
      return token;
    } catch (e) {
      print("토큰 읽기 실패: $e");
      return null;
    }
  }

  // --- 5. (나중에 필요함) 토큰을 삭제하는 함수 ---
  /// (로그아웃 시) 저장된 토큰을 삭제합니다.
  Future<void> deleteToken() async {
    try {
      await _storage.delete(key: _tokenKey);
    } catch (e) {
      print("토큰 삭제 실패: $e");
      // (오류 처리)
    }
  }

  Future<void> deleteNickname() async {
    await _storage.delete(key: _nicknameKey);
  }

  /// (로그인 성공 시) user_id (이메일/닉네임)를 저장합니다.
  Future<void> saveUserId(String userId) async {
    await _storage.write(key: _userIdKey, value: userId);
  }

  /// 저장된 user_id를 불러옵니다.
  Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }

  /// (로그아웃 시) 저장된 user_id를 삭제합니다.
  Future<void> deleteUserId() async {
    await _storage.delete(key: _userIdKey);
  }
}