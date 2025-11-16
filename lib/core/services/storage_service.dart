import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  // 1. flutter_secure_storage 인스턴스 생성
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // 2. ⭐️ 키(Key) 정의
  static const String _tokenKey = 'access_token';
  static const String _userIdKey = 'user_id';
  static const String _nicknameKey = 'user_nickname';
  static const String _lifestyleTypeKey = 'lifestyle_type';

  // --- 👇 3. (오류 해결) 'saveToken' 함수 ---
  /// (로그인 성공 시) 토큰을 기기에 저장합니다.
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  // --- 👇 4. (필수) 'saveUserId' 함수 ---
  /// (로그인 성공 시) user_id (이메일/닉네임)를 저장합니다.
  Future<void> saveUserId(String userId) async {
    await _storage.write(key: _userIdKey, value: userId);
  }

  // --- 👇 5. (필수) 'saveNickname' 함수 ---
  /// (로그인 성공 시) 닉네임을 저장합니다.
  Future<void> saveNickname(String nickname) async {
    await _storage.write(key: _nicknameKey, value: nickname);
  }

  // --- 👇 6. (필수) 'saveLifestyleType' 함수 ---
  /// (로그인/검사완료 시) 라이프스타일 유형("true"/"false")을 저장합니다.
  Future<void> saveLifestyleType(String typeName) async {
    await _storage.write(key: _lifestyleTypeKey, value: typeName);
  }

  // --- 7. (나중에 필요함) 토큰을 읽어오는 함수 ---
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // --- 8. (나중에 필요함) user_id를 읽어오는 함수 ---
  Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }

  // --- 9. (나중에 필요함) 닉네임을 읽어오는 함수 ---
  Future<String?> getNickname() async {
    return await _storage.read(key: _nicknameKey);
  }

  // --- 10. (나중에 필요함) 유형을 읽어오는 함수 ---
  Future<String?> getLifestyleType() async {
    return await _storage.read(key: _lifestyleTypeKey);
  }

  // --- 11. (로그아웃 시) 모든 정보를 삭제하는 함수 ---
  Future<void> deleteAll() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userIdKey);
    await _storage.delete(key: _nicknameKey);
    await _storage.delete(key: _lifestyleTypeKey);
  }
}